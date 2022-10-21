//----------------------------------------------------------------------------
// Project : TOSTIRC
// File    : IRCLink.uc
// Author  : [BB]Stark <stark@bbclan.de>
// $LastChange: 01.08.2003 10:08:32$
//----------------------------------------------------------------------------
// Based on RFC2812 - http://www.rfc-editor.org/rfc/rfc2812.txt
// new Flood-protection: https://www.quakenet.org/phpBB2/viewtopic.php?t=1463
//----------------------------------------------------------------------------
// ideas:   maybe B/W mode if +c?
//          need-op line
//          split after 512 chars
//----------------------------------------------------------------------------

class IRCLink expands UBrowserBufferedTCPLink;

const MyQueueSize = 32;
var TOSTServerReporter Master;
var bool    bLoggedIn, bOnChan, bModerated, bColor, bOp, bVoice, bDebug;
var int     ServerPort, Head, Tail, Count, nickcounter, warncounter, warncounter2, warncounter3, BindError;
var IpAddr  ServerIpAddr;
var string  ServerAddress, NickName, UserIdent, FullName, DefaultChannel,
            ServerPassword, DisconnectReason, MyQueue[32], myChanList;
var int     MODES, NICKLEN;                 // 005-vars from IRC-Server
var string  CHANTYPES, PREFIX, CHANMODES;   // --- " ---
var int     floodcount;
var float   SendWaitTime;
var bool    bWaitISON;

struct Mode {
   var bool   prefix;
   var string char;
   var string param;
};

struct Entry005 {
    var string key;
    var string value;
};

function Initialize(TOSTServerReporter SR)
{
    Master = SR;
    bDebug = Master.bdebug;
    Connect();
    setTimer(Master.IRCReconnectTime, True); // automatic connection-lost-check all x seconds
}

function PostBeginPlay()
{
	Super.PostBeginPlay();
	Disable('Tick');
}

function Connect()
{
	local int myRand, servercount, i;
	local string temp;

    if (Master == none) return;

	bLoggedIn = False;

    NickName = Master.BotNick;
	FullName = Master.BotRealName@Master.PieceVersion;
	UserIdent = Master.BotIdent;
	DefaultChannel = Master.IRCChannel;

    for (i=0; i<ArrayCount(Master.IRCServer); i++)
    {
        if (Master.IRCServer[i] != "") servercount++;
        else break;
    }

    if (servercount==0) {
        Master.Xlog("ERROR: The first IRC server may not be empty. Edit your ini-file!");
        Master.bEnable = false;
        return;
    }

    temp = Master.IRCServer[Rand(servercount)];

    ServerAddress = ParseDelimited(temp, ":", 1, false);
    ServerPort = int(ParseDelimited(temp, ":", 2, false));
    if (ServerPort==0) ServerPort = 6667;
    ServerPassword = ParseDelimited(temp, ":", 3, false);

    if (bDebug) Master.Xlog("debug#3:"@ ServerAddress@ServerPort@ServerPassword);

	ResetBuffer();
	ServerIpAddr.Port = ServerPort;
	Master.XLog("Resolving"@ServerAddress );
	Resolve(ServerAddress);
	nickcounter = 1;
}

function Resolved( IpAddr Addr )
{
	ServerIpAddr.Addr = Addr.Addr;

	if( ServerIpAddr.Addr == 0 )
	{
		Master.XLog("Invalid Adress");
		return;
	}
	Master.XLog("Server is "$ServerAddress$":"$ServerIpAddr.Port);

	if(  BindPort(Level.Game.GetServerPort()+7+BindError, true) == 0 )
	{
		Master.XLog("Error while trying to bind the port" @ Level.Game.GetServerPort()+7+BindError);
		BindError=BindError+20;
		return;
	}
	Open( ServerIpAddr );
}

event Closed()
{
    Master.XLog("The IRC Connection has been closed");
    Master.XLog("Reconnecting in max. "$Master.IRCReconnectTime$" seconds");
}

event Timer()
{
	if (!IsConnected())
	{
        Master.XLog("Trying to reconnect...");
        Connect();
    } else if (bLoggedIn && !bOnChan)
    {
        Master.XLog("Trying to join"@defaultchannel@"...");
        JoinChannel(defaultchannel, Master.IRCChannelKey);
    } else if (bLoggedIn && Master.Botnick != Nickname) {
        SendBufferedData("NICK "$Master.Botnick$CRLF);
    }
}

event Opened()
{
	Master.XLog("IRC-connection established!");
	Enable('Tick');
	GotoState('LoggingIn');
}

function Tick(float DeltaTime)
{
	local string Line;

    if (bLoggedin)
    {

        SendWaitTime += DeltaTime;

    	// data out:
        if (SendWaitTime >= 0.33)
        {
            if (!bWaitISON) {
                SubmitOne();
            }
        	SendWaitTime = 0;
    	}
    }

    // data in:
	DoBufferQueueIO();
	if(ReadBufferedLine(Line))
		ProcessInput(Line);
}


function JoinChannel(string chan, optional string key)
{
    chan = addPrefix(chan);
	SendBufferedData("JOIN " $ chan @ key $ CRLF);
}

function PartChannel(string chan, optional string partmsg)
{
    chan = addPrefix(chan);
   	SendBufferedData("PART " $ chan @ partmsg $ CRLF);
    myChanList = Master.ReplaceText(myChanList, chan, "");
    if (bDebug) Master.XLog ("debug#8"@myChanList);
}

function ProcessInput(string Line)
{
	// Respond to PING
	if(Left(Line, 5) == "PING ")
		SendBufferedData("PONG "$Mid(Line, 5)$CRLF);
}

state LoggingIn
{
	function ProcessInput(string Line)
	{
		local string RAW;

        if (ParseDelimited(Line, " ", 1)== "ERROR")
			Master.XLog("Error:"@ChopLeft(ParseDelimited(Line, ":", 2, True)));

        RAW = ParseDelimited(Line, " ", 2);
        if (bDebug) Master.XLog("debug#1: "$Line);

		switch (RAW)
		{
            case "001":
      			  // >> :splatterworld3.de.quakenet.org 001 dsdsdsdsdsdsdsd :Welcome to the Internet Relay Network, dsdsdsdsdsdsdsd
                  nickname = ParseDelimited(Line, " ", 3, false);
                  Master.XLog("Logged in as"@nickname@"!");
                GotoState('LoggedIn');
    			break;
            case "432": // see below
            case "433":
                Master.XLog("Error! "$Line);
    			if (nickcounter < 3)
    			{
	      			Master.XLog("Login failed as"@nickname);
    				nickname = Left(nickname$Chr((Rand(10) + 48)),NICKLEN);
    				Master.XLog("Trying to login as" @ NickName $ "...");
	       			SendBufferedData("NICK "$nickname$CRLF);
    				nickcounter++;
    			}
    			else
    			{
    				nickname = "tost"$Chr(Rand(10) + 48)$Chr(Rand(10) + 48);
    				SendBufferedData("NICK "$nickname$CRLF);
    				nickcounter = 1;
    			}
                break;
            case "451":
                Master.XLog("Error! "$Line);
                Master.XLog("Login failed as"@nickname@"(maybe the IRC-Server needs a password to connect or you specified a wrong one.");
                break;
 		}
        Global.ProcessInput(Line);
	}

Begin:
	if (Master.bEnable)
	{
        Master.XLog("Trying to login as"@NickName$"...");
        if (ServerPassword!="")
            SendBufferedData("PASS "$ServerPassword$LF);
       	SendBufferedData("NICK "$NickName$LF);
    	SendBufferedData("USER "$UserIdent$" 0 * :"$FullName$LF);
    }
}

state LoggedIn
{
	function ProcessInput(string Line)
	{
		local string RAWcmd, command, param0, param1, param2, Sender;
        local int pos, tmpint;

        if (bDebug) Master.XLog("debug#20: "$Line);

		RAWcmd = Caps(ParseDelimited(Line, " ", 2));
		Sender = ParseDelimited(Line, ":!", 2);

		if (Left(Line, 19) ~= "ERROR :Closing Link")
		{
			Master.XLog("disconnected: " $ Line);
			bLoggedIn = false;

			if (Right(Line, 14) ~= "(Excess Flood)")
			{
		      if (Master.IRCAntiFloodBytes > 1000) tmpint = 900;
		      else tmpint = Master.IRCAntiFloodBytes - 50;
              Master.Xlog("Excess Flood detected! :( Changing IRCAntiFloodBytes from " $Master.IRCAntiFloodBytes$ " to " $tmpint);
              Master.IRCAntiFloodBytes = tmpint;
		      Master.SaveConfig();
            }
			return;

		}

        // anti-flood:
        else if (RAWcmd == "303")
		{
            floodcount = 0;
            bWaitISON = false;
            if (bDebug) Master.XLog("got ISON response");
		}

		else if (RAWcmd == "INVITE")
		{
            param0 = Chop(ParseDelimited(Line, " ", 3, false)); // chan
            param1 = Chop(ParseDelimited(Line, " ", 4, false)); // nick

            if (nickname ~= param0 && defaultchannel ~= param1)
                JoinChannel(param1, Master.IRCChannelKey);
		}

        else if (RAWcmd == "JOIN")
        {
            pos = InStr(Line, " JOIN :");
            param0 = Chop(Right(Line, Len(Line)-pos-7)); // chan
            pos = InStr(Line, "!");
            param1 = Mid(Line, 1, pos-1); // nick

            if (hasPrefix(param0) && param1 ~= nickname) // the bot joined a channel
            {
                if (param0 ~= defaultchannel)
                {
                    bOnChan = true;
                    SendBufferedData("MODE " $ param0 $ CRLF); // get chan-modes
                }
                Master.XLog("Joined channel:" @ param0);
                myChanList = myChanList @ param0;
                if (bDebug) Master.XLog("debug#2: " $ myChanList);
            }
        }


        else if (RAWcmd == "KICK")
		{
  			param0 = RemoveNickPrefix(Chop(ParseDelimited(Line, " ", 4, false))); // nick
  			if (param0 ~= nickname)
  			{
                param0 = ChopLeft(ParseDelimited(Line, " ", 1, false)); // kicker
                param1 = ChopLeft(ParseDelimited(Line, " ", 3, false)); // channel
                param2 = ChopLeft(ParseDelimited(Line, " ", 5, true)); // reason
                Master.Xlog("I was kicked from "$param1$" by "$param0$" ("$ Master.stripMircCodes(param2) $") Try to rejoin...");
                bOnChan = false;
                myChanList = Master.ReplaceText(myChanList, param1, "");
                if (param1~=defaultchannel)
                    param1 = param1 @ Master.IRCChannelKey;
                JoinChannel(param1);
            }
		}

        else if (RAWcmd == "MODE")
		{
            param0 = ChopLeft(ParseDelimited(Line, " ", 3, false)); // chan

            if (defaultchannel ~= param0)
                processModes (Line);
		}

        else if (RAWcmd == "PRIVMSG")
		{
			param0 = RemoveNickPrefix(Chop(ParseDelimited(Line, " ", 3))); // target nick
			param1 = ChopLeft(ParseDelimited(Line, " ", 4, false)); // password argument

			if (param0 ~= nickname && CheckPassword(param1))
			{
                command = ChopLeft(ParseDelimited(Line, " ", 5, false));
    			param0 = ChopLeft(ParseDelimited(Line, " ", 6, true));
                param1 = ChopLeft(ParseDelimited(Line, " ", 6, false));
                param2 = ChopLeft(ParseDelimited(Line, " ", 7, true));

                switch (Caps(command))
                {
                    case "HELP":
                        showHelp(Sender, param1);
                        break;
                    case "SET":
                        setValue(Sender, param1, param2);
                        break;
                    case "JOIN":
                        SendNotice(Sender, "Trying to join" @ param1 @ param2);
                        JoinChannel(param1, param2);
                        break;
                    case "PART":
                        if (param1~=defaultchannel)
                            SendNotice(Sender, "You can't part the reporting-channel!");
                        else
                        {
                            SendNotice(Sender, "Parting" @ param1);
                            PartChannel(param1, param2);
                        }
                        break;
                    case "ADMINSAY":
                        adminSay(Sender, param0);
                        break;
                    case "SENDRAW":
                        SendNotice(Sender, "sending RAW command:" @ param0);
                        AddToBuffer( param0 $ CRLF );
                        break;
                    case "STATUS":
                        botstats(Sender);
                        break;

                    default:
                        SendNotice(Sender, "unknown command!");
                        showHelp(Sender, "");
                }
			}
		}

        else if (RAWcmd == "005")
		{
            process005(Line);
            defaultchannel = addPrefix(defaultchannel);
            Master.IRCChannel = defaultchannel;
		}

        else if (RAWcmd == "324") // get channel modes after join
        {
            param1 = ChopLeft(ParseDelimited(Line, " ", 4, false)); // chan
			param2 = ChopLeft(ParseDelimited(Line, " ", 5, false)); // channel-modes (+cnmst etc.)
			if (param1~=defaultchannel)
			{
                bModerated = (InStr(param2, "m")>0);
                bColor = (InStr(param2, "c")>0);
            }
        }

        else if (RAWcmd == "404") // cannot send to channel
        {
            if (warncounter<5)
                Master.XLog("ERROR: " $ ChopLeft(ParseDelimited(Line, " ", 4, true)) );
            warncounter++;
        }

        // 432    ERR_ERRONEUSNICKNAME
        // 433    ERR_NICKNAMEINUSE
        else if (RAWcmd == "432" || RAWcmd == "433")
		{
			Master.XLog("Nickchange failed as"@nickname);
		}

		// succesfull nickchange
        else if (RAWcmd == "NICK")
		{
            param1 = Mid(Line, 1, InStr(Line, "!")-1); // oldnick
            if (param1 == NickName)
            {
    			NickName = Chop(ParseDelimited(Line, " ", 3, false)); // newnick
                NickName = NickName;
                Master.BotNick = NickName;
                Master.Xlog("Nickname changed from " $ param1 $ " to " $ NickName);
                Master.SaveConfig();
            }
		}

        // cannot join a channel
        else if (RAWcmd == "471" ||
                 RAWcmd == "473" ||
                 RAWcmd == "474" ||
                 RAWcmd == "475" ||
                 RAWcmd == "477" )
        {
            if (warncounter<5)
            {
                Master.Xlog("ERROR: " $ ChopLeft(ParseDelimited(Line, " ", 4, true)) );
                SendBufferedData("PRIVMSG "$DefaultChannel$" :"$ "Let me in!" $CRLF);
                warncounter++;
            }
        }

		else if (ParseDelimited(Line, " ", 1) == "PING")
		  SendBufferedData("PONG "$RAWcmd);
	}
Begin:
	myChanList = "";
	floodcount = 0;
    if ( Master.IRCperform1 != "") SendBufferedData( Master.ReplaceText(Master.IRCperform1, "%nick%", nickname) $CRLF );
	if ( Master.IRCperform2 != "") SendBufferedData( Master.ReplaceText(Master.IRCperform2, "%nick%", nickname) $CRLF );
    defaultchannel = addPrefix(defaultchannel);
	JoinChannel(defaultchannel, Master.IRCChannelKey);
	bLoggedIn = True;
}

function DestroyLink(string s)
{
	SetTimer(0.0, False); // Turn off reconnect-Timer
    bLoggedIn = False;
	SendBufferedData("QUIT :"$s$CRLF);
}

function SendMessage(string Message)
{
	if (!Master.bMute &&
        Master.RealPlayers>0 &&
        CanSend() )

        AddToBuffer("PRIVMSG "$DefaultChannel$" :"$Message$CRLF);
}

function SendFastMessage(string Message)
{
	if (!Master.bMute &&
        Master.RealPlayers>0 &&
        CanSend() )

        SendBufferedData("PRIVMSG "$DefaultChannel$" :"$Message$CRLF);
}

function SendNotice(string DestNick, string NoticeMsg)
{
	if (DestNick != "" && NoticeMsg != "")
        AddToBuffer("NOTICE "$DestNick$" :"$NoticeMsg$CRLF);
}

function SetTopic(string Topic)
{
    AddToBuffer("TOPIC "$DefaultChannel$" :"$Topic$CRLF);
}

function string RemoveNickPrefix(string Nick)
{
	while(Nick != "" && InStr(":@+", Left(Nick, 1)) != -1)
		Nick = Mid(Nick, 1);
	return Nick;
}

function bool CheckPassword(string pwd)
{
	return (pwd == Master.BotAdminPassword);
}

function AddToBuffer(string s)
{
	MyQueue[Head] = s;
	Head = (Head + 1) % MyQueueSize;
	if (Head == Tail) Master.XLog("WARNING, QUEUE OVERFLOW!!!");
	Count = Min(Count+1,MyQueueSize);
}

function SubmitOne()
{
	if (bLoggedin)
	{
		if (Head == Tail) return;

        if (floodcount + Len(MyQueue[Tail]) >= Master.IRCAntiFloodBytes) {
            if (bDebug) Master.Xlog("floodcount="$floodcount$" sending ISON command");
            SendBufferedData("ISON Q"$LF);
            bWaitISON = true;

   		} else {
            floodcount += Len(MyQueue[Tail]);
            SendBufferedData(MyQueue[Tail]);
      		Tail = (Tail + 1) % MyQueueSize;
       		Count = Max(Count-1,0);
   		}

	}
}

function ClearBuffer()
{
	Head = 0;
	Tail = 0;
	Count = 0;
}

function bool BufferIsEmpty()
{
	return (Head == Tail);
}

function showhelp(string Sender, string word)
{
    local string answer[5];
    local int i;

    switch (word)
    {
        case "help":    answer[0] = "This Help... O_o";
                        break;
        case "status": answer[0] = "Shows the bot configuration.";
                        break;
        case "join":    answer[0] = "Let's the Bot join a channel";
                        answer[1] = "Remember: it only JOINS the channel. If you want to switch reporting to another channel,";
                        answer[2] = "you have to use the command \"SET CHANNEL #mychan\", too.";
                        break;
        case "part":    answer[0] = "Let's the Bot part(leave) a channel";
                        break;

        case "adminsay": answer[0] = "Sends an admin-message to the server-console.";
                         answer[1] = "A leading # will display it centered on screen.";
                         break;

        case "sendraw":  answer[0] = "Sends a IRC-RAW command to the IRC-Server.";
                         answer[1] = "for example PRIVMSG, MODE, NOTICE, etc.";
                         break;

        case "set":     answer[0] = "Changes various settings of the bot.";
                        answer[1] = Master.IRCBold $ "Usage:" $ Master.IRCBold @ "set <value> <option>";
                        answer[2] = Master.IRCBold $ "Values:";
                        answer[3] = "nick, ident, realname, password, channel, channelkey, reconnecttime, antiflood, servername, repeatgameinfo, taglayout, teamname1, teamname2 (option = text)";
                        answer[4] = "mute, setTopic, showJoin, showSay, showScore, showKill, showGameInfo, showWeapon, showHealth, showHitparade, showKick, showTOSTKick, showTOPInfo, showServer, sortByFrags, debug (option = on|off)";
                        break;
        default:        answer[0] = Master.IRCBold $ "Bot usage:" $ Master.IRCBold @ "/MSG "$nickname$" password command <options>";
                        answer[1] = Master.IRCBold $ "commands:" $ Master.IRCBold @ "status, join, part, set, adminsay, sendraw";
                        answer[2] = "get more help with:";
                        answer[3] = "/MSG "$nickname$" password help command";
    }

    for (i=0; i<ArrayCount(answer); i++)
    {
        if (answer[i]!="")
            Sendnotice(Sender, answer[i]);
        else break;
    }
}

function botstats(string Sender)
{
    local string vars1, vars2, vars3, enabled, disabled;

    vars1 = vars1 @ Master.IRCBold $ "BotNick:" $ Master.IRCBold @ Master.BotNick;
    vars1 = vars1 @ Master.IRCBold $ "BotRealName:" $ Master.IRCBold @ Master.BotRealName;
    vars1= vars1 @ Master.IRCBold $ "BotIdent:" $ Master.IRCBold @ Master.BotIdent;

    vars2 = vars2 @ Master.IRCBold $ "Server:" $ Master.IRCBold @ ServerAddress;
    vars2 = vars2 @ Master.IRCBold $ "Port:" $ Master.IRCBold @ ServerPort;
    vars2 = vars2 @ Master.IRCBold $ "IRCChannel:" $ Master.IRCBold @ Master.IRCChannel;
    vars2 = vars2 @ Master.IRCBold $ "IRCChannelKey:" $ Master.IRCBold @ Master.IRCChannelKey;
    vars2 = vars2 @ Master.IRCBold $ "IRCReconnectTime:" $ Master.IRCBold @ Master.IRCReconnectTime;
    vars2 = vars2 @ Master.IRCBold $ "IRCAntiFloodBytes:" $ Master.IRCBold @ Master.IRCAntiFloodBytes;

    vars3 = vars3 @ Master.IRCBold $ "TOServerName:" $ Master.IRCBold @ Master.TOServerName;
    vars3 = vars3 @ Master.IRCBold $ "RepeatGameInfo:" $ Master.IRCBold @ Master.RepeatGameInfo;
    vars3 = vars3 @ Master.IRCBold $ "TeamNames[0]:" $ Master.IRCBold @ Master.TeamNames[0];
    vars3 = vars3 @ Master.IRCBold $ "TeamNames[1]:" $ Master.IRCBold @ Master.TeamNames[1];

    if (Master.bMute) enabled=enabled@"Mute";
    else disabled=disabled@"Mute";

    if (Master.bSetTopic) enabled=enabled@"setTopic";
    else disabled=disabled@"setTopic";

    if (Master.bShowJoin) enabled=enabled@"showJoin";
    else disabled=disabled@"showJoin";

    if (Master.bShowSay) enabled=enabled@"showSay";
    else disabled=disabled@"showSay";

    if (Master.bShowScore) enabled=enabled@"showScore";
    else disabled=disabled@"showScore";

    if (Master.bShowKill) enabled=enabled@"showKill";
    else disabled=disabled@"showKill";

    if (Master.bShowGameInfo) enabled=enabled@"showGameInfo";
    else disabled=disabled@"showGameInfo";

    if (Master.bShowWeapon) enabled=enabled@"showWeapon";
    else disabled=disabled@"showWeapon";

    if (Master.bShowHealth) enabled=enabled@"showHealth";
    else disabled=disabled@"showHealth";

    if (Master.bShowHitparade) enabled=enabled@"showHitparade";
    else disabled=disabled@"showHitparade";

    if (Master.bShowKick) enabled=enabled@"showKick";
    else disabled=disabled@"showKick";

    if (Master.bShowTOSTKick) enabled=enabled@"showTOSTKick";
    else disabled=disabled@"showTOSTKick";

    if (Master.bShowTOPInfo) enabled=enabled@"showTOPInfo";
    else disabled=disabled@"showTOPInfo";

    if (Master.bShowServer) enabled=enabled@"showServer";
    else disabled=disabled@"showServer";

    if (Master.bSortByFrags) enabled=enabled@"sortByFrags";
    else disabled=disabled@"sortByFrags";

    if (Master.bDebug) enabled=enabled@"debug";
    else disabled=disabled@"debug";

    SendNotice(Sender, vars1);
    SendNotice(Sender, vars2);
    SendNotice(Sender, vars3);
    SendNotice(Sender, Master.IRCBold$"Enabled:"$Master.IRCBold@enabled);
    SendNotice(Sender, Master.IRCBold$"Disabled:"$Master.IRCBold@disabled);
}

function setValue(string Sender, string key, string value)
{
    local bool bError, bOn, bIsAString;
    local float tempfloat;
    local int tempint;
    local string tempstring;

    bOn = (value ~= "on");
    switch (Caps(key))
    {
        case "NICK":
            if (value != "") {
                nickname=value;
                Master.BotNick=value;
                SendBufferedData("NICK "$value$CRLF);
                bIsAString = True;
            }
            break;

        case "IDENT":
    		Master.BotIdent = value;
    		bIsAString = True;
    		break;

    	case "REALNAME":
    		Master.BotRealName = value;
    		bIsAString = True;
    		break;

        case "CHANNEL":
            defaultchannel = addPrefix(value);
    		Master.IRCChannel = value;
    		// reset mode-flags:
            bOp = False;
    		bVoice = False;
    		bColor = False;
    		bModerated = False;

            if (InStr(myChanList, value) != -1)
            {
    		   bOnChan = True;
    		   SendBufferedData("MODE "$value$CRLF); // get channel modes
            }
            else
            {
               bOnChan = False;
               JoinChannel(value, Master.IRCChannelKey);
            }

    		bIsAString = True;
    		break;

        case "CHANNELKEY":
    		Master.IRCChannelKey = value;
    		bIsAString = True;
    		break;

    	case "PASSWORD":
            if (Len(value)>3)
            {
                Master.BotAdminPassword = value;
                bIsAString = True;
            } else bError = true;
            break;

        case "ANTIFLOOD":
            tempint = int(value);
		    if ((tempint <= 200) || (tempint > 1000)) tempint = 800;
		    Master.IRCAntiFloodBytes = tempint;
		    bIsAString = true;
		    break;

		case "PERFORM1":
            Master.IRCPerform1 = value;
            bIsAString = true;
            break;

		case "PERFORM2":
            Master.IRCPerform2 = value;
            bIsAString = true;
            break;

		case "RECONECTTIME":
            tempint = int(value);
  		    if (tempint < 20) tempint = 20;
            Master.IRCReconnectTime = tempint;
            bIsAString = true;
            break;

		case "REPEATGAMEINFO":
            Master.RepeatGameInfo = int(value);
            bIsAString = true;
            break;

		case "SERVERNAME":
            Master.TOServerName = value;
            bIsAString = true;
            break;

        case "TAGLAYOUT":
            Master.TagLayout = value;
            bIsAString = true;
            break;

        case "TEAMNAME1":
            Master.TeamNames[0] = value;
            bIsAString = true;
            break;

        case "TEAMNAME2":
            Master.TeamNames[1] = value;
            bIsAString = true;
            break;

    	case "MUTE":
            Master.bMute = bOn;
            break;

    	case "TOPIC":
            Master.bSetTopic = bOn;
            break;

        case "SHOWJOIN":
            Master.bShowJoin = bOn;
            break;

        case "SHOWSAY":
            Master.bShowSay = bOn;
            break;

        case "SHOWSCORE":
            Master.bShowScore = bOn;
            break;

        case "SHOWKILL":
            Master.bShowKill = bOn;
            break;

        case "SHOWGAMEINFO":
            Master.bShowGameInfo = bOn;
            break;

        case "SHOWWEAPON":
            Master.bShowWeapon = bOn;
            break;

        case "SHOWHEALTH":
            Master.bShowHealth = bOn;
            break;

        case "SHOWHITPARADE":
            Master.bShowHitparade = bOn;
            break;

        case "SHOWKICK":
            Master.bShowKick = bOn;
            break;

        case "SHOWTOSTKICK":
            Master.bShowTOSTkick = bOn;
            break;

        case "SHOWTOPINFO":
            Master.bShowTOPInfo = bOn;
            break;

        case "SHOWSERVER":
            Master.bShowServer = bOn;
            break;

        case "DEBUG":
            Master.bDebug = bOn;
            bDebug = bOn;
            break;

        case "SORTBYFRAGS":
            Master.bSortByFrags = bOn;
            break;

        default:
            bError = true;
    }

    if (!bError)
    {
        if (bIsAString)
        {
            SendNotice(Sender, key $ " is now: " $ value);
            Master.XLog("excuted function by"@ Sender $": set" @ key @ "=" @ value);
        } else {
            SendNotice(Sender, key $ " is now: " $ Master.OnOff(bOn));
            Master.XLog("excuted function by"@ Sender $": set" @ key @ "=" @ Master.OnOff(bOn));
        }
        Master.SaveConfig();
    }
}

function bool canSend ()
{
    if (bDebug) Master.Xlog("debug#23:"@bcolor@bop@bvoice@bmoderated@bOnchan);
    //Master.Xlog(warncounter2@warncounter3);

    if (bColor && bOp)
    {
        SendBufferedData("MODE "$ defaultchannel $" -c"$CRLF);
        bColor = false;
    }
    else if (bColor)
    {
        if (warncounter2 < 1)
        {
            SendBufferedData("PRIVMSG" @defaultchannel@ ":Please remove chan-mode +c (color-protection)!"$CRLF);
            Master.XLog("Please remove chan-mode +c in the reporting-channel! (color-protection)");
        }
        warncounter2++;
    }
    else if (bModerated && !bOp && !bVoice)
    {
        if (warncounter3 < 1)
        {
            Master.XLog("Please remove chan-mode +m in the reporting-channel! (moderated)");
        }
        warncounter3++;
    }
    return ( bOnChan && ( bOp || (bVoice && bModerated) || !bModerated ) && !bColor );
}

function adminSay(string Sender, string text)
{
    local Pawn P;

	if (Left(text, 1) == "#")
	{
		text = Right(text, Len(text)-1);
		for( P=Level.PawnList; P!=None; P=P.nextPawn )
			if( P.IsA('PlayerPawn') )
			{
				PlayerPawn(P).ClearProgressMessages();
				PlayerPawn(P).SetProgressTime(6);
				PlayerPawn(P).SetProgressMessage("(IRC) " $ Sender $": " $ text, 0);
			}
	} else
	   foreach Level.Game.AllActors(class'Pawn', P)
	       if (P.bIsPlayer)
	           P.ClientMessage("(IRC) " $ Sender $": " $ text);

	SendNotice(Sender, "Admin-message \"" $ text $ "\" sent.");
    Master.XLog(Sender @ "used adminSay:"@text);
}

// Mode parsing by darix:
function processModes ( string modeline ) {
    local string Params[32];
    local int size, i, index;
    local string modes, temp;
    local bool addState;

    modeline = Chop(ParseDelimited(modeline, " ", 2, true));
    size = SplitString ( modeline, " ", Params );

    if (size != 0) {
        modes = Params[2];
        index = 0;

        if (bDebug) {
            Master.XLog ( "debug#5: size   : "$size );
            Master.XLog ( "debug#5: command: "$Params[0] );
            Master.XLog ( "debug#5: target : "$Params[1] );
            Master.XLog ( "debug#5: modes  : "$Params[2] );
            for ( i = 3 ; i < size; i++ ) {
               Master.XLog ( "debug#5: param "$i-2$" : "$Params[i] );
            }
        }
        for (i = 0; i < Len(modes); i++) {
            temp = Mid (modes, i, 1);
            if (temp == "+")
                addState = true;
            else if (temp == "-")
                addState = false;
            else {
                // set global vars down here...
                if (Params[index+3] ~= nickname)
                {
                    if (temp=="o")
                    {
                        bOp = addState;
                        if (bOp) Master.setTopic();
                    }
                    else if (temp=="v") bVoice = addState;
                }
                else if (temp=="c")
                    bColor = addState;
                else if (temp=="m")
                    bModerated = addState;

                index++;
           }
        }
    }
}

function process005 (string line) {
/*
 * We should parse:
 * <server> 005 <nick> WHOX WALLCHOPS WALLVOICES USERIP CPRIVMSG CNOTICE SILENCE=15 MODES=6 MAXCHANNELS=20 MAXBANS=45 NICKLEN=15 TOPICLEN=250 AWAYLEN=160 KICKLEN=250 :are supported by this server
 * <server> 005 <nick> CHANTYPES=#& PREFIX=(ov)@+ CHANMODES=b,k,l,imnpstrDcCu CASEMAPPING=rfc1459 NETWORK=QuakeNet :are supported by this server
 */
    local int size, i;
    local string entries[32];
    local string temp[32];

    line = ParseDelimited(line, " ", 4, true); // clean left side
    line = Left (line, InStr (line, ":" )-1 ); // clean right side

    size = SplitString ( line, " ", entries );

    for ( i=0 ; i < size; i++ ) {
        SplitString ( entries[i], "=", temp );
        if (bDebug) Master.XLog("debug#9:"@temp[0]@temp[1]);

        //set global vars:
        switch (Caps(temp[0]))
        {
            case "NICKLEN":
                NICKLEN = int(temp[1]);
                break;
            case "MODES":
                MODES = int(temp[1]);
                break;
            case "CHANTYPES":
                CHANTYPES = temp[1];
                break;
            case "PREFIX":
                PREFIX = temp[1];
                break;
            case "CHANMODES":
                CHANMODES = temp[1];
                break;
        }
    }
}

function int SplitString ( coerce string Src, string Divider, out string Parts[32] ) {
    local string temp;
    local int index;

    index = 0;

    if ( Divider != "" || Src != "" ){
        while ( Src != "" ) {
            temp = removePart ( Src, Divider );
            if ( temp != "" ) {
                 parts[index] = temp;
                 index++;
            }
        }
    }
    return index;
}

function string removePart ( out string Src, string Divider ) {
   local int pos;
   local string result;

   pos = InStr ( Src, Divider );

    if ( pos == -1 ) {
        result = Src;
        Src = "";
    }
    else {
        result = Left( Src, pos);
        Src = Mid ( Src, pos + len ( Divider ) );
    }
    return result;
}

function string addPrefix (string chan)
{
    if (hasPrefix(chan)) return chan;
    else return "#"$chan;
}

function bool hasPrefix (string chan)
{
    return (InStr(CHANTYPES, Left(chan, 1)) != -1 );
}

function string ChopLeft(string Text)
{
	while(Text != "" && InStr(": !", Left(Text, 1)) != -1)
		Text = Mid(Text, 1);
	return Text;
}

function string Chop(string Text)
{
	while(Text != "" && InStr(": !", Left(Text, 1)) != -1)
		Text = Mid(Text, 1);
	while(Text != "" && InStr(": !", Right(Text, 1)) != -1)
		Text = Left(Text, Len(Text)-1);

	return Text;
}

defaultproperties
{
    bHidden=True
    CHANTYPES="#"
    NICKLEN=15
    warncounter=0
    warncounter2=0
    warncounter3=0
}
