// $Id: TOSTServerReporter.uc 538 2004-04-09 21:59:47Z stark $
//----------------------------------------------------------------------------
// Project : TOSTIRC
// Author  : [BB]Stark <stark@bbclan.de>
//----------------------------------------------------------------------------

class TOSTServerReporter expands TOSTPiece;

// config:
var config bool     bEnable, bMute, bSetTopic, bShowJoin, bShowSay, bShowScore,
                    bShowKill, bShowGameInfo, bShowWeapon, bShowHealth, bShowHitparade,
                    bShowKick, bShowTOSTKick, bShowTOPInfo, bShowServer, bSortByFrags, bNoColors;
var config string   BotNick, BotRealName, BotIdent, BotAdminPassword, IRCServer[10],
                    IRCPerform1, IRCPerform2, IRCChannel, IRCChannelKey, TOServerName,
                    TagLayout, TeamNames[2];
var config int      IRCReconnectTime, RepeatGameInfo, IRCAntiFloodBytes;
var config int		LastServer;

// internal:
var int             PlayerNameLen;
var IRCLink         IRCLink;
var	s_GameReplicationInfo TGRI;
var bool            bGameStarted, CWMode, HPMessage;
var int             lastMsg, RealPlayers;
var s_SWATGame      sGame;
var string          lastLocalizedMsg, TOPchar;

var	s_ExplosiveC4	C4;
var bool			bCheckForDefuse, bCheckForDefuseAbort;
var float			defuseStartTime;

var int				RescuedHostages;

var int				EscapedTerr;

struct renamebuffer {
	var	Pawn   Player;
	var string OldName;
};
var renamebuffer nameHistory[32];

const IRCBold = "";
const IRCColor = "";
const IRCULine = "";
const IRCReverse = "";
const IRCColorTeams0 = "04";
const IRCColorTeams1 = "12";
const IRCColorTeams2 = "14";
const IRCColorTeams3 = "14";
const IRCColorEvent = "03";
const IRCColorRed = "04";
const IRCColorYellow = "08";
const IRCColorGreen = "03";

// *** INIT

function		EventInit()
{
    local int i;
    local TOSTServerTools MyTools;

    Disable('Tick');

	if (bEnable)
    {
        RealPlayers = 0;

        TGRI = s_GameReplicationInfo(Level.Game.GameReplicationInfo);
        sGame= s_SWATGame(Level.Game);

    	if (BotAdminPassword == "")
        {
            for (i = 0; i < 4; i++)
            {
                BotAdminPassword = BotAdminPassword$Chr(Rand(25)+65);  // upper case
                BotAdminPassword = BotAdminPassword$Rand(10);          // number
                BotAdminPassword = BotAdminPassword$Chr(Rand(25)+97);  // lower case
            }
            XLog("A random admin-password has been generated. You can find and edit it in your ini-file.");
        }

        BotIdent = Lower(BotIdent);
        if (IRCLink == None)
            IRCLink = Spawn(class'TOSTIRC.IRCLink');
        IRCLink.Initialize(self);
        MyTools = spawn(class'TOSTTools.TOSTServerTools');
    	HPMessage = MyTools.HPMessage;
    	MyTools.Destroy();

        SaveConfig();

    } else
        XLog("the reporter is currently disabled. Add \"bEnable=True\" to your ini-file to enable it.");

    super.EventInit();
}

function Tick (float delta)
{
	local float defusePercentage;
	local string s;

	if (sGame==None) return;

	if (sGame.bBombDefusion)
	{
		if (bCheckForDefuse && C4!=None && C4.bBeingActivated)
		{
			bCheckForDefuse = false;
			bCheckforDefuseAbort = true;
			defuseStartTime = C4.CountDown;
			if (defuseStartTime < C4.C4Duration)
				IRCLink.SendMessage(GetTime()@IRCBold$ "Defusing started (good luck)" $IRCColor);
			else
				IRCLink.SendMessage(GetTime()@IRCBold$ "Defusing started" $IRCColor);
		}

		if (bCheckForDefuseAbort && C4!=None && !C4.bBeingActivated)
		{
			bCheckForDefuse = true;
			bCheckforDefuseAbort = false;
			defusePercentage = (defuseStartTime-C4.CountDown) / C4.C4Duration * 100;
			IRCLink.SendMessage(GetTime()@IRCBold$ "Defusing aborted at " $ Float2String(defusePercentage, 0) $ "%" $ IRCColor);
		}
	}
	else if (sGame.bHasHostages)
	{
		if (sGame.nbRescuedHostages > RescuedHostages)
		{
			IRCLink.SendMessage(GetTime()@IRCBold$sGame.nbRescuedHostages@"of"@sGame.nbHostages@"Hostages rescued" $ IRCColor);
			RescuedHostages = sGame.nbRescuedHostages;
		}
	}
	else
	{
        if (sGame.Escaped_Terr > EscapedTerr)
		{
			if (sGame.Escaped_Terr>1) s="s";
			IRCLink.SendMessage(GetTime()@IRCBold$sGame.Escaped_Terr@"Terrorist"$s$" escaped" $ IRCColor);
			EscapedTerr = sGame.Escaped_Terr;
		}
	}
}

// *** TOST SETTINGS

function		GetSettings(TOSTPiece Sender)
{
	local int	 Bits;
	local string tmp;

	// bool's:
    Bits = 0;
	if (bMute) Bits += 1;
    if (bShowJoin) Bits += 2;
    if (bShowSay) Bits += 4;
    if (bShowScore) Bits += 8;
    if (bShowKill) Bits += 16;
    if (bShowGameInfo) Bits += 32;
    if (bShowWeapon) Bits += 64;
    if (bShowHealth) Bits += 128;
    if (bShowHitParade) Bits += 256;
    if (bShowKick) Bits += 512;
    if (bSetTopic) Bits += 1024;
    if (bShowServer) Bits += 2048;
	if (bShowTOPInfo) Bits += 4096;
	if (bShowTOSTKick) Bits += 8192;
	if (bEnable) Bits += 16384;

    // others:
    tmp = "";
    tmp = tmp $ BotNick $ ";";
    tmp = tmp $ BotRealName $ ";";
    tmp = tmp $ BotIdent $ ";";
    tmp = tmp $ IRCChannel $ ";";
    tmp = tmp $ IRCChannelKey $ ";";
    tmp = tmp $ IRCperform1 $ ";";
    tmp = tmp $ IRCperform2 $ ";";

	Params.Param4 = string(Bits)$";"$tmp;
	SendAnswerMessage(Sender, 143);
}

function		SetSettings(TOSTPiece Sender, string Settings)
{
	local	int			i, j, pos;
	local	string		s;

	s = Settings;
	if (s != "")
	{
    	j = InStr(s, ";");
		if (j != -1)
		{
			i = int(Left(s, j));
			s = Mid(s, j+1);
		} else {
			i = int(s);
			s = "";
		}

      	// bool's:
		bMute = ((i & 1) == 1);
		bShowJoin = ((i & 2) == 2);
		bShowSay = ((i & 4) == 4);
		bShowScore = ((i & 8) == 8);
		bShowKill = ((i & 16) == 16);
		bShowGameInfo = ((i & 32) == 32);
		bShowWeapon = ((i & 64) == 64);
		bShowHealth = ((i & 128) == 128);
		bShowHitParade = ((i & 256) == 256);
		bShowKick = ((i & 512) == 512);
		bSetTopic = ((i & 1024) == 1024);
		bShowServer = ((i & 2048) == 2048);
		bShowTOPInfo = ((i & 4096) == 4096);
		bShowTOSTKick = ((i & 8192) == 8192);
		bEnable = ((i & 16384) == 16384);

	    if (s != "")
		{
	        pos = 0;
            while (true)
	        {
        		j = InStr(s, ";");
    			if (j != -1)
    			{
    				switch (pos)
    				{
                        case 0 :    BotNick = Left(s, j);
                                    break;
                        case 1 :    BotRealName = Left(s, j);
                                    break;
                        case 2 :    BotIdent = Left(s, j);
                                    break;
                        case 3 :    IRCChannel = Left(s, j);
                                    break;
                        case 4 :    IRCChannelKey = Left(s, j);
                                    break;
                        case 5 :    IRCperform1 = Left(s, j);
                                    break;
                        case 6 :    IRCperform2 = Left(s, j);
                                    break;
    				}
                    s = Mid(s, j+1);
                    pos++;
    			}
    			else break;
    		}
		}
    }
	SaveConfig();
}

// *** EVENTS

function		EventGamePeriodChanged(int GP)
{
	if (bEnable)
        switch (GP)
    	{
    		case 0:   GP_PreRound(); break;
    		case 1:   GP_RoundPlaying(); break;
    		case 2:   GP_PostRound(); break;
    		case 3:   GP_RoundRestarting(); break;
      		case 4:   GP_PostMatch(); break;
    	}

	super.EventGamePeriodChanged(GP);
}

function GP_PreRound ()
{
	if (bShowScore && sGame.RoundNumber > 1 && InStr(GetTime(), "-") == -1)
        ShowNewRoundStatus();
}

function GP_Roundplaying ()
{
	lastMsg=0;
    lastLocalizedMsg="";

    if (sGame.RoundNumber==1)
    {
        bGameStarted = True;
        setTopic();
        showVersions();
    }

    if (sGame.RoundNumber % RepeatGameInfo == 0)
        showGameInfo();

    IRCLink.SendMessage(GetTime()@"Round #"$ sGame.RoundNumber $" started!");

    if (sGame.bBombDefusion)
        showBombOwner();

    RescuedHostages = 0;
    EscapedTerr = 0;
    Enable('Tick');
}

function GP_PostRound ()
{
    local string tmp;

    bCheckforDefuse = false;
    bCheckforDefuseAbort = false;

	tmp = "Round End!";

    if (bShowScore)
    	IRCLink.SendMessage(GetTime()@tmp);
    else {
        tmp = tmp @ formatTag("T: "$int(TGRI.Teams[0].Score)$" SF: "$int(TGRI.Teams[1].Score));
        IRCLink.SendMessage(GetTime()@tmp);
    }

    Disable('Tick');
}

function GP_RoundRestarting ()
{
    IRCLink.SendMessage(GetTime()@"Round restarted!");
}

function GP_PostMatch ()
{
}

function 		EventPlayerConnect(Pawn Player)
{
    local int i;

    RealPlayers++;

    if (bEnable)
    {
	    if (bShowJoin && bGameStarted)
	        IRCLink.SendMessage(GetTime()@IRCColorEvent$Player.PlayerReplicationInfo.PlayerName@"entered the game");

		i = TOST.FindPlayerIndex(PlayerPawn(Player));
		if (i != -1)
		{
			nameHistory[i].Player = Player;
			nameHistory[i].OldName = Player.PlayerReplicationInfo.PlayerName;
		}
    }
	super.EventPlayerConnect(Player);
}

function 		EventPlayerDisconnect(Pawn Player)
{
    local int i;

    if (bEnable)
    {
	    if (bShowJoin && bGameStarted)
	        IRCLink.SendMessage(GetTime()@IRCColorEvent$Player.PlayerReplicationInfo.PlayerName@"left the game");

	    RealPlayers--;

	    i = TOST.FindPlayerIndex(PlayerPawn(Player));
		if (i != -1)
		{
			nameHistory[i].Player = none;
			nameHistory[i].OldName = "";
		}
    }

    super.EventPlayerDisconnect(Player);
}


function 		EventNameChange(Pawn Player)
{
    local int i;

    if (bEnable)
    {
	   	i = TOST.FindPlayerIndex(PlayerPawn(Player));
		if (i != -1 && (nameHistory[i].OldName != Player.PlayerReplicationInfo.PlayerName) )
		{
	        IRCLink.SendMessage(formatTag("Rename")@nameHistory[i].OldName@"is now known as"@Player.PlayerReplicationInfo.PlayerName);
	        nameHistory[i].OldName = Player.PlayerReplicationInfo.PlayerName;
		}
    }

    Super.EventNameChange(Player);
}

function 		EventAfterPickup(Inventory Item, Pawn Other)
{
    if (bEnable)
    {
    if (Item.IsA('s_C4'))
        IRCLink.SendMessage(GetTime()@IRCColorEvent$Other.PlayerReplicationInfo.PlayerName@"picked up the bomb"$IRCColor);
    else if (Item.IsA('s_OICW'))
        IRCLink.SendMessage(GetTime()@IRCColorEvent$Other.PlayerReplicationInfo.PlayerName@"picked up the"@Item.ItemName$IRCColor);
    }
	if (NextPiece != none)
		NextPiece.EventAfterPickup(Item, Other);
}

function		EventAfterEndGame(string Reason)
{
    if (bEnable)
        EndGameQuit("reconnecting, T: "$int(TGRI.Teams[0].Score)$" SF: "$int(TGRI.Teams[1].Score));

	if (NextPiece != none)
		NextPiece.EventAfterEndGame(Reason);
}

// Mutator
function bool	EventRestartGame()
{
    if (bEnable)
        EndGameQuit("maprestart");

	if (NextPiece != none)
		return NextPiece.EventRestartGame();
	return false;
}

function bool 	EventPreventDeath(Pawn Victim, Pawn InstigatedBy, name DamageType, vector HitLocation)
{
	local string msg, weapon, reason;

	if (Victim != none && Victim.PlayerReplicationInfo != none && InstigatedBy != none && InstigatedBy.PlayerReplicationInfo != none)
	    dLog(Victim.PlayerReplicationInfo.PlayerName@InstigatedBy.PlayerReplicationInfo.PlayerName@string(damageType));

    if (bEnable && RealPlayers>0 && bShowKill)
    {
	    if (InstigatedBy == Victim || InstigatedBy == None)
		{
	        if ( DamageType == 'Explosion' ) reason="blew himself up with a nade";
			else if ( DamageType == 'fell' ) reason="fell to death";
			else if ( DamageType == 'Drowned' ) reason="drowned";
			//else if ( DamageType == 'Suicided' ) reason="suicided"; // suicide is also the DamageType for Punish
	        else reason ="died";
	        IRCLink.SendMessage(GetTime()@IRCColorTeams(Victim.PlayerReplicationInfo.Team)$Victim.PlayerReplicationInfo.PlayerName$IRCColor@reason);

		} else {
	        if (DamageType == 'shot')
	            weapon = GetWeapon(InstigatedBy);
	        else if (DamageType == 'stab')
	            weapon = "Combatknife";
	    	else if (DamageType == 'Explosion')
	            weapon = "nade";
	    	else if (DamageType == 'stabbed')
	            weapon = "thrown Combatknife";
	        else if (Damagetype == 'Decapitated')
	            weapon = "Combatknife"; // hmz not sure...
	        else
	            weapon = "";

	        msg = IRCColorTeams(InstigatedBy.PlayerReplicationInfo.Team);
	        msg = msg $ InstigatedBy.PlayerReplicationInfo.PlayerName;
	        if (HPMessage && bShowHealth) msg = msg $ getHP(InstigatedBy);
	        msg = msg $ IRCColor;

	        if (InstigatedBy.PlayerReplicationInfo.Team == Victim.PlayerReplicationInfo.Team)
	            msg = msg @ "teamkilled";
	        else
	            msg = msg @ "killed";

	        msg = msg $ IRCColorTeams(Victim.PlayerReplicationInfo.Team);
	        msg = msg @ Victim.PlayerReplicationInfo.PlayerName;
	        msg = msg $ IRCColor;
	        if (bShowWeapon && weapon != "")
	            msg = msg @ "with "$AnAPrefix(weapon)@weapon;

	        IRCLink.SendMessage(GetTime()@msg);
	    }
    }

    if (NextPiece != none)
		return NextPiece.EventPreventDeath(Victim, InstigatedBy, DamageType, HitLocation);
	return false;
}

function bool 	EventTeamMessage( Actor Sender, Pawn Receiver, PlayerReplicationInfo PRI, coerce string S, name Type, optional bool bBeep )
{
    local string tmp;

    if (bEnable && bShowSay &&
        string(type)=="Say" &&
        (!PRI.bIsSpectator || PRI.bAdmin) &&
        PRI.PlayerName==Receiver.PlayerReplicationInfo.PlayerName)
    {
        tmp = GetTime();
        if (PRI.bAdmin)
            tmp = tmp@formatTag("Admin");

        tmp = tmp @ PRI.PlayerName$":"@S;
        IRCLink.SendMessage(tmp);
    }

	if (NextPiece != none)
		return NextPiece.EventTeamMessage(Sender, Receiver, PRI, S, Type, bBeep);
	return true;
}

function bool 	EventBroadcastMessage( Actor Sender, Pawn Receiver, out coerce string Msg, out optional name Type, optional bool bBeep)
{
    if (bEnable && string(Sender.Class)=="UTServerAdmin.UTServerAdminSpectator" && string(Receiver.Class)=="UTServerAdmin.UTServerAdminSpectator")
        IRCLink.SendMessage(formatTag("Web-Admin")@Msg);

	else if (bEnable && string(Sender.Class)=="s_SWAT.TO_Spectator" && string(Receiver.Class)=="s_SWAT.TO_Spectator"
            && IRClink.ParseDelimited(Msg, ":", 1, false)==Receiver.PlayerReplicationInfo.PlayerName )
        IRCLink.SendMessage(formatTag("Spectator")@Msg);

	else if (bEnable && Receiver.PlayerReplicationInfo.PlayerName==Left(Msg, Len(Receiver.PlayerReplicationInfo.PlayerName)) && Receiver.IsA('s_Player') )
       	if (InStr(Msg, " became a server administrator.")!= -1)
            IRCLink.SendMessage(formatTag("Login")@Msg);
        else if ( InStr(Msg, " gave up administrator abilities.") != -1 )
            IRCLink.SendMessage(formatTag("Logout")@Msg);
        else if ( InStr(Msg, " for teamkilling!") != -1 )
            IRCLink.SendMessage(GetTime()@ReplaceText(Msg, " punishes ", " punished "));

    if (NextPiece != none)
		return NextPiece.EventBroadcastMessage(Sender, Receiver, Msg, Type, bBeep);
	return true;
}

function bool 	EventBroadcastLocalizedMessage( Actor Sender, Pawn Receiver, out class<LocalMessage> Message, out optional int switch, out optional PlayerReplicationInfo RelatedPRI_1, out optional PlayerReplicationInfo RelatedPRI_2, out optional Object optionalObject )
{
    local string S;
    /*
    WinMessage(0)="D R A W  G A M E !"
    WinMessage(1)="Special Forces exterminated!"
    WinMessage(2)="Terrorists exterminated!"
    WinMessage(3)="All Hostages rescued!"
    WinMessage(4)="Most of the Terrorists have escaped!"
    WinMessage(5)="Most of the Special Forces have escaped!"
    WinMessage(6)="Terrorists failed to escape!"
    WinMessage(7)="Special Forces failed to escape!"
    WinMessage(8)="Playing last round before map change!"
    WinMessage(9)="Special Forces win the round!"
    WinMessage(10)="Terrorists win the round!"
    11 dropped C4
    12 planted C4
    13 defused C4
    */

    S = Message.static.GetString(Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);

    if (bEnable)
    {
	    if (lastLocalizedMsg!=S)
	       if ( (switch>=0 && switch<=2) ||
	            (switch==3 && InStr(S, "is now on") == -1) ||
	            (switch>=4 && switch<=7) ||
	             switch==9 ||
	             switch==10 )
	        	IRCLink.SendMessage(GetTime()@IRCBold$S$IRCColor);
	        else if (switch==12) {
            	foreach Level.Game.AllActors(class's_ExplosiveC4', C4) break;
        		bCheckForDefuse = true;
        		bCheckForDefuseAbort = false;
        		IRCLink.SendMessage(GetTime()@IRCBold$S$IRCColor);
        		Enable('Tick');
			}
			else if (switch==13) {
	        	IRCLink.SendMessage(GetTime() @ IRCBold $ S $ " (" $ Float2String(FMax(0.0, C4.CountDown), 2) $ " sec. left)" $ IRCColor);
	        	Disable('Tick');
	        }
	        else if (switch==11 || switch==8)
	        	IRCLink.SendMessage(GetTime()@IRCColorEvent$S$IRCColor);
	        else if (switch==3) ; // nothing
	        else dLog("debug#6: switch="$switch@"Message="$S@"Map="$Level.Title);

	    lastLocalizedMsg=S;
    }

	if (NextPiece != none)
		return NextPiece.EventBroadcastLocalizedMessage(Sender, Receiver, Message, switch, RelatedPRI_1, RelatedPRI_2, optionalObject );
	return true;
}

// *** Message Handling

function	EventMessage(TOSTPiece Sender, int MsgIndex)
{
    local int i;
    local TOSTPiece P;
    local string IP, kickOrBan, hitDmg, hitFF, hitline, warn;
    local int hitDmgID, hitFFID;
    local PlayerPawn PP;

    if (bEnable && Sender!=none && IRCLink!=none)
    {

	    //xlog(Sender.Piecename@MsgIndex);

		switch (MsgIndex)
		{
	        // send a String to IRC, generic Interface for other Pieces
	        case BaseMessage :      IRCLink.SendMessage(formatTag(Sender.PieceName)@Sender.Params.Param4);
	                                break;

	        // *** catch TOST Messages
	        // mkteams
	        case 102 :              IRCLink.SendMessage(formatTag(Sender.PieceName)@"Even teams forced!");
	                                break;

	        // fteamchg
	        case 103 :              IRCLink.SendMessage(formatTag(Sender.PieceName)@"Teamswitch forced on"@FindPlayerByID(Sender.Params.Param1).PlayerReplicationInfo.PlayerName);
	                                break;

	        // samapchg
	        case 105 :              P = TOST.GetPieceByName("TOST Map Handling");
	                            	if (P != None)
	                            	   if (TOSTMapHandling(P).FindMapIndex(Sender.Params.Param4) != -1)
	                                        EndGameQuit("mapchange", formatTag(Sender.PieceName)@"Switching to Map"@Caps(Sender.Params.Param4));
	                                break;

	        // punish
	        case 106 :              PP = FindPlayerByID(Sender.Params.Param1);
	                                if (Sender.Params.Param2==0 || Sender.Params.Param2 >= PP.Health )
	                                    IRCLink.SendMessage(formatTag(Sender.PieceName)@Sender.Params.Param6.PlayerReplicationInfo.PlayerName$" punishes "$PP.PlayerReplicationInfo.PlayerName$" with death!");
	                                else
	                                    IRCLink.SendMessage(formatTag(Sender.PieceName)@Sender.Params.Param6.PlayerReplicationInfo.PlayerName$" punishes "$PP.PlayerReplicationInfo.PlayerName$" to "$Sender.Params.Param2$" hp!");
	                                break;

			// kicks/bans:
			/*
			case 107 :
			case 108 :
			case 109 :				i=0; // kick only
									if (MsgIndex==108) i=1; // tempkickban
									if (MsgIndex==109) i=2; // kickban
									if (Sender.Params.Param6==None && bShowTOSTKick)
										ReportKicks(Sender, findPlayerbyID(Sender.Params.Param1), Sender.Params.Param4, i);
									if (Sender.Params.Param6!=None && bShowKick)
									    ReportKicks(Sender, Sender.Params.Param6, Sender.Params.Param4, i);
									break;
			*/

	        // adminreset
	        case 110 :              if (lastMsg!=MsgIndex)
	                                    IRCLink.SendMessage(formatTag(Sender.PieceName)@"Adminreset");
	                                lastMsg = MsgIndex;
	                                break;

	        // endround
	        case 111 :              if (lastMsg!=MsgIndex)
	                                    IRCLink.SendMessage(formatTag(Sender.PieceName)@"Endround");
	                                lastMsg = MsgIndex;
	                                break;

	        // sasay
	        case 112 :              IRCLink.SendMessage(formatTag(Sender.PieceName)@"AdminSay:"@Sender.Params.Param4);
	                                break;

	        // protectserv
	        case 113 :              IRCLink.SendMessage(formatTag(Sender.PieceName)@"ProtectSrv executed");
	                                break;

	        // CW mode
	        case 117 :              CWMode = Sender.Params.Param5;
									if (Sender.Params.Param5)
	                                    IRCLink.SendMessage(formatTag(Sender.PieceName)@"CW-Mode enabled");
	                                else
	                                    IRCLink.SendMessage(formatTag(Sender.PieceName)@"CW-Mode disabled");
	                                break;

	        // forcename
	        case 118 :              //not supported atm... :(
	                                break;

	        // TOSTSettings
	        case 143 :	            GetSettings(Sender);
									break;

	        // sasetnextmap
	        case 151 :              P = TOST.GetPieceByName("TOST Map Handling");
	                            	if (P != None)
	                            	   if (TOSTMapHandling(P).FindMapIndex(Sender.Params.Param4) != -1)
	                                        IRCLink.SendMessage(formatTag(Sender.PieceName)@"Upcoming map is"@Caps(Sender.Params.Param4)@"(set by admin)");
	                                break;

	        // NotifyCheat /
			// kick(ban)s by TOST+TOP
	        case 191 :              if (Sender.Params.Param5) i = 2;
	                                else i = 0;

	                                if (Sender.Params.Param4!="" && bShowTOSTKick)
										ReportKicks(Sender, Sender.Params.Param6, Sender.Params.Param4, i);
	                                if (Sender.Params.Param4=="" && bShowKick)
	                                    ReportKicks(Sender, Sender.Params.Param6, "", i);
	                                break;

	        // salogin & salogout
	        case 205 :				if (!Sender.Params.Param5 || CWMode)
	                                {
	                                    if (Sender.Params.Param1>0) IRCLink.SendMessage(formatTag(Sender.PieceName)@Sender.Params.Param6.PlayerReplicationInfo.PlayerName$" logged in as Semi-Admin Level "$Sender.Params.Param1);
									    else IRCLink.SendMessage(formatTag(Sender.PieceName)@Sender.Params.Param6.PlayerReplicationInfo.PlayerName$" gave up Semi-Admin abilities");
									}
	                                break;

	        // hitparade old
	        case 251 :              if (bShowHitParade)
	                                    IRCLink.SendMessage(formatTag(Sender.PieceName)@Sender.Params.Param4);
	        // hitparade new
	        case 252 :              if (bShowHitParade)
	                                {
	                                    dlog(Sender.Params.Param4);
	                                    hitDmgID = int(IRCLink.ParseDelimited(Sender.Params.Param4, ";", 1, false));
	                                    hitDmg = IRCLink.ParseDelimited(Sender.Params.Param4, ";", 2, false);
	                                    hitFFID = int(IRCLink.ParseDelimited(Sender.Params.Param4, ";", 3, false));
	                                    hitFF = IRCLink.ParseDelimited(Sender.Params.Param4, ";", 4, false);
	                                    hitline = "";
	                                    if (hitDmgID>0)
	                                        hitline = hitline $ IRCULine $ "best fragger:" $ IRCULine @ FindPlayerbyID(hitDmgID).PlayerreplicationInfo.PlayerName $ " (" $ hitdmg $ " dmg) ";
	                                    if (hitFFID>0)
	                                        hitline = hitline $ IRCULine $ "most FF by:" $ IRCULine @ FindPlayerbyID(hitFFID).PlayerreplicationInfo.PlayerName $ " (" $ hitFF $ " dmg)";

	                                    if (hitline!="")
	                                        IRCLink.SendMessage(formatTag(Sender.PieceName)@hitline);
	                                }
	                                break;

	        // SApause
	        case 130 :              if (Level.Pauser!="")
	        							IRCLink.SendMessage(formatTag(Sender.PieceName)@"Game paused!");
	        						else
										IRCLink.SendMessage(formatTag(Sender.PieceName)@"Game unpaused!");
	                                break;

	        // fordemorec:
	        case 132 :              if (Sender.Params.Param1!=0)
	                                    IRCLink.SendMessage(formatTag(Sender.PieceName)@FindPlayerByID(Sender.Params.Param1).PlayerReplicationInfo.Playername@"was forced to record a demo by"@Sender.Params.Param6.PlayerReplicationInfo.PlayerName);
	                                else
	                                    IRCLink.SendMessage(formatTag(Sender.PieceName)@"All Players were forced to record a demo by"@Sender.Params.Param6.PlayerReplicationInfo.PlayerName);
	                                break;
	        // mkclanteams:
	        case 134 :              IRCLink.SendMessage(formatTag(Sender.PieceName)@"MkClansTeams executed.");
	                                break;

	        // Mute:
	        case 135 :              if (Sender.Params.Param1>0)
	                            	{
	                                    if (Sender.Params.Param2==0)
	                                        IRCLink.SendMessage(formatTag(Sender.PieceName)@FindPlayerByID(Sender.Params.Param1).PlayerReplicationInfo.Playername@"was unmuted by"@Sender.Params.Param6.PlayerReplicationInfo.PlayerName);
	                                    else if (Sender.Params.Param2==-1)
	                                        IRCLink.SendMessage(formatTag(Sender.PieceName)@FindPlayerByID(Sender.Params.Param1).PlayerReplicationInfo.Playername@"was muted until end of the map by"@Sender.Params.Param6.PlayerReplicationInfo.PlayerName);
	                                    else
	                                        IRCLink.SendMessage(formatTag(Sender.PieceName)@FindPlayerByID(Sender.Params.Param1).PlayerReplicationInfo.Playername@"was muted for"@Sender.Params.Param2@"minutes by"@Sender.Params.Param6.PlayerReplicationInfo.PlayerName);
	                                }
	                                break;
	        // WarnPlayer:
	        case 136 :              warn = formatTag(Sender.PieceName)@FindPlayerByID(Sender.Params.Param1).PlayerReplicationInfo.Playername@"got a warning from"@Sender.Params.Param6.PlayerReplicationInfo.PlayerName;
	                                if (Sender.Params.Param4!="")
	                                    warn = warn @"(Reason: "$Sender.Params.Param4$")";
	                                IRCLink.SendMessage(warn);
	                                break;

	        // Setting loaded: (add name)
	        case 141 :              IRCLink.SendMessage(formatTag(Sender.PieceName)@"Setting #" $ Sender.Params.Param1 $ " loaded by"@Sender.Params.Param6.PlayerReplicationInfo.PlayerName);
	                                break;

		} // switch
	}
	dLog("debug#7:"@Sender.PieceName@MsgIndex);

	super.EventMessage(Sender, MsgIndex);
}

function	EventAnswerMessage(TOSTPiece Sender, int MsgIndex)
{
	switch (MsgIndex)
	{
		// SetSettings - report back error messages
		case 144 : SetSettings(Sender, Sender.Params.Param4);
                   break;
	}
}

// *** MAIN functions

function ReportKicks (TOSTPiece Sender, PlayerPawn Player, string Reason, optional int mode)
{
	local string IP, kickOrBan;

	kickOrBan = "kicked";
	if (mode==1) kickOrBan = "tempkickbanned";
	if (mode==2) kickOrBan = "kickbanned";

	IP = Player.GetPlayerNetworkAddress();
	IP = Left(IP, InStr(IP, ":"));

	if (Reason!="") Reason = "for " $ Reason;

	IRCLink.SendMessage(formatTag(Sender.PieceName) @ Player.PlayerReplicationInfo.PlayerName @ "("$IP$")" @ "has been " $ kickOrBan @ Reason);
}

function ShowBombOwner()
{
    local Pawn PWN;
    local PlayerReplicationInfo PRI;
    local TO_PRI TOPRI;
	local TO_BRI TOBRI;

	foreach Level.Game.AllActors(class'Pawn', PWN)
	{
       PRI = PWN.PlayerReplicationInfo;
       TOPRI = TO_PRI(PRI); // Player
	   TOBRI = TO_BRI(PRI); // Bot
	   if ( (TOBRI != None && TOBRI.bHasBomb == true) ||
		    (TOPRI != none && TOPRI.bHasBomb == true) )
	   {
	       IRCLink.SendMessage(GetTime()@IRCColorEvent$PRI.PlayerName@"has the bomb!"$IRCColor);
	       break;
	   }
    }
}

function EndGameQuit(string QuitMsg, optional string lastwords)
{
    IRCLink.QuitMessage = QuitMsg;
	IRCLink.GotoState('disconnect');
	if (lastwords!="")
        IRCLink.SendFastMessage(GetTime()@lastwords);
}

function setTopic()
{
    local string topic;

    if (bSetTopic)
    {
        topic = PieceName$":"@Level.Title;
        if (bShowServer) topic = topic@ "on" @TOServerName;
        IRCLink.SetTopic(topic);
    }
}

function ShowGameInfo()
{
    local string tmp, tmp2;

    if (bShowServer)
        tmp = formatTag("Server")@TOServerName$" ";
    tmp = tmp $ formatTag("Map")@Level.Title;

    tmp2 = formatTag("TimeLimit")@sGame.TimeLimit;
    if (sGame.RoundLimit>0)
        tmp2 = tmp2 @ formatTag("RoundLimit")@sGame.RoundLimit;
    tmp2 = tmp2 @ formatTag("RoundTime")@sGame.RoundDuration;
    tmp2 = tmp2 @ formatTag("FF")@int(sGame.FriendlyFireScale*100.0)$"%";

    //optional if True:
    if (sGame.bAllowGhostCam)
        tmp2 = tmp2 @ formatTag("GhostCam")@OnOff(sGame.bAllowGhostCam);
    if (sGame.bMirrorDamage)
        tmp2 = tmp2 @ formatTag("MirrorDamage")@OnOff(sGame.bMirrorDamage);
    if (sGame.bEnableBallistics)
        tmp2 = tmp2 @ formatTag("Ballistics")@OnOff(sGame.bEnableBallistics);
    //if (!sGame.bExplosionsFF)
    //    tmp2 = tmp2 @ formatTag("Nade FF")@OnOff(sGame.bExplosionsFF);

    IRCLink.SendMessage(tmp);
    IRCLink.SendMessage(tmp2);
}

function showVersions()
{
   	IRCLink.SendMessage(formatTag("TOST")@Mid(TOST.TOSTVersion, 5)@formatTag("IRCReporter")@PieceVersion);
}

/*
  function by =(UFO)=PimpMan
  modified by Stark
*/
function ShowNewRoundStatus()
{
	local TeamInfo TI;
	local PlayerReplicationInfo PRI, PRI2;
	local TO_PRI TOPRI;
	local TO_BRI TOBRI;
   	local bool bHaveSpec;
	local int x, Special[32], Terror[32];
	local int specialcount, specialscore, specialkills, specialdeaths, specialping;
	local int terrorcount, terrorscore, terrorkills, terrordeaths, terrorping;
	local string s, terrorplayername, specialplayername, specline;

	specialcount = 0;
	terrorcount = 0;

	for (x= 0; x < 32; x++)
	{
		Special[x]= -1;
		Terror[x]= -1;
	}

	for (x = 0; x < 32; x++) {
		PRI = TGRI.PRIArray[x];
		if (PRI != none && !PRI.IsA('s_NCPHostage')) {
            TOPRI=TO_PRI(PRI);
            TOBRI=TO_BRI(PRI);
			if (PRI.Team == 0)
			{
				Terror[terrorcount] = x;
				terrorcount++;
                terrordeaths += PRI.Deaths;
                terrorkills += PRI.Score;
                terrorping += PRI.Ping;
                if (TOPRI != none)
					terrorscore += TOPRI.InflictedDmg/10;
			    if (TOBRI != none) terrorscore += TOBRI.InflictedDmg/10;
			}
			else if (PRI.Team == 1)
			{
    			Special[specialcount] = x;
	       		specialcount++;
                specialdeaths += PRI.Deaths;
                specialkills += PRI.Score;
                specialping += PRI.Ping;
                if (TOPRI != none)
					specialscore += TOPRI.InflictedDmg/10;
				if (TOBRI != none) specialscore += TOBRI.InflictedDmg/10;
    		}
		}
	}
	terrorping = terrorping/terrorcount;
	specialping = specialping/specialcount;

	TI = TGRI.Teams[0];
	s = IRCBold$IRCColorTeams0$PostPad(TeamNames[0]$":"@int(TI.Score), PlayerNameLen+17," ")$"|";
	TI = TGRI.Teams[1];
	s = s$IRCColorTeams1$"  "$PostPad(TeamNames[1]$":"@int(TI.Score), PlayerNameLen+16," ");
	IRCLink.SendMessage(""$s);
	IRCLink.SendMessage(IRCColorTeams0$PostPad("PlayerName",PlayerNameLen+1," ")$"| Scr K/D  Ping |"
                       @IRCColorTeams1$PostPad("PlayerName",PlayerNameLen+1," ")$"| Scr K/D  Ping");

	SortArray(Terror, terrorcount, bSortByFrags);
	SortArray(Special, specialcount, bSortByFrags);

	// output:
	for (x = 0; x < 32; x++)
	{
		if (Terror[x]!= -1 && Special[x]!= -1) //players on both sides
		{
			PRI = TGRI.PRIArray[Terror[x]];
			PRI2 = TGRI.PRIarray[Special[x]];
			IRCLink.SendMessage(playerInfo(PRI, True)@playerInfo(PRI2));
		}
		else if (Special[x]== -1 && Terror[x]!= -1)	// only terrorist
		{
           	PRI = TGRI.PRIArray[Terror[x]];
			IRCLink.SendMessage(playerInfo(PRI, True));
		}
		else if (Terror[x]== -1 && Special[x]!= -1)	// only special forces
		{
			PRI = TGRI.PRIArray[Special[x]];
			IRCLink.SendMessage(PostPad("",PlayerNameLen+17," ")$IRCColorTeams0$"| "$playerInfo(PRI));
		}
		else break; // nobody
	}

	// new stat line:
	if (terrorcount>1 || specialcount >1)
    IRCLink.SendMessage(IRCBold$IRCColorTeams0$"total:"$PrePad(terrorscore@PostPad(terrorkills$"/"$terrordeaths, 5," ")@PrePad(terrorping,3," ")$" |",PlayerNameLen+12, " ")
                       @IRCColorTeams1$"total:"$PrePad(specialscore@PostPad(specialkills$"/"$specialdeaths, 5," ")@PrePad(specialping,3," "),PlayerNameLen+10, " "));

    // specs:
    bHaveSpec = false;
    specline = "";

    for (x = 0; x < 32; x++)
    {
        PRI = TGRI.PRIArray[x];
        if (PRI != none)
            TOPRI = TO_PRI(PRI);
        if (PRI != none && TOPRI != none && TOPRI.bRealSpectator)
        {
            specline = specline $ PRI.PlayerName $ " ";
            bHaveSpec = true;
        }
    }
    if (bHaveSpec) IRCLink.SendMessage(IRCColorEvent$IRCBold$"Spectators: "$IRCBold$specline);
}

function string playerInfo (PlayerReplicationInfo PRI, optional bool bEndofLine)
{
    local string pname, line;
    local TO_PRI TOPRI;
    local TO_BRI TOBRI;
    local int dmg, namepadding, toppadding;

    TOPRI=TO_PRI(PRI); // Player
    TOBRI=TO_BRI(PRI); // Bot

    if (TOPRI != none)
    {
        dmg = TOPRI.InflictedDmg/10;
        line = getTOPstatus(int(TOPRI.TOPStatus), toppadding);
        namepadding = PlayerNameLen+1-toppadding;
    }
    else if (TOBRI != none)
    {
        dmg = TOBRI.InflictedDmg/10;
        line = "";
        namepadding = PlayerNameLen+1;
    }
    pname = PRI.PlayerName;
    line = line $
        IRCColorTeams(PRI.Team)$
        PostPad(Left(pname, namepadding), namepadding," ")
        $"|"$PrePad(dmg,4," ")
        @PostPad(int(PRI.Score)$"/"$int(PRI.Deaths),5," ")
        @PrePad(PRI.Ping,3," ");

    if (bEndOfLine) line = line @ "|";
    return line;
}

function string getTOPstatus (int TOPStatus, out int toplen)
{
    local string top;

    // 0 = Waiting for connection, 1 = Checking, 2=Ok, 3=OldTP, 4=NoTP, 5=Cheat

    if (TGRI.bTOProtectActive && bShowTOPInfo)
    {
        toplen = Len(TopChar);
        switch (TOPStatus)
        {
            case 0 :    top =  IRCColorYellow$TOPChar$IRCColor;
                        break;
            case 1 :    top = IRCColorYellow$TOPChar$IRCColor $ IRCColorYellow$TOPChar$IRCColor;
                        toplen *= 2;
                        break;
            case 2 :    top = IRCColorGreen$TOPChar$IRCColor;
                        break;
            case 3 :    top = IRCColorRed$TOPChar$IRCColor $ IRCColorGreen$TOPChar$IRCColor;
                        toplen *= 2;
                        break;
            case 4 :    top = IRCColorRed$TOPChar$IRCColor $ IRCColorYellow$TOPChar$IRCColor;
                        toplen *= 2;
                        break;
            case 5 :    top = IRCColorRed$TOPChar$IRCColor;
                        break;
        }

    return IRCBold $ top $ IRCBold;
    }

    else {
        toplen = 0;
        return "";
    }
}

// *** HELPERS

static function string FormatTime(int Time)
{
	local int Hours,Mins,Secs;
	local string minus;

	minus = "";
	Hours = Abs(Time/3600);
	Mins  = Abs((Time%3600)/60);
	Secs  = Abs(Time%60);
    if (Time<0) minus = "-";

	if (Hours == 0) return minus$Mins$":"$PrePad(Secs,2,"0");
	else return minus$Hours$":"$PrePad(Mins,2,"0")$":"$PrePad(Secs,2,"0");
}

function string GetTime()
{
	if (TGRI.TimeLimit == 0) return FormatTime(TGRI.ElapsedTime);
	else return FormatTime(TGRI.RemainingTime);
}

function string GetWeapon(pawn Player)
{
	if (Player.Weapon.ItemName != "")
		return Player.Weapon.ItemName;
	else
		return "unknown";
}

function string GetHP(pawn Player)
{
 	if(Player.Health > 0)
 		return "("$Player.Health $ " HP)";
	else
 		return "(dead)";
}

function string formatTag(string in)
{
    return ReplaceText(TagLayout, "%text%", in);
}

function string AnAPrefix(string in)
{
    local string vocal;

    vocal = "AEIUO";
    if (InStr(vocal, Caps(Left(in,1))) != -1 )
        return "an";
    else
        return "a";
}

function SortArray (out int A[32], int count, optional bool bFrags)
{
	local int i, j, help;
	local bool bChanged;
	local PlayerReplicationInfo PRI, PRI2;
	local TO_PRI TOPRI, TOPRI2; // Player
	local TO_BRI TOBRI, TOBRI2; // Bot

	// Bubblesort:
	i = 0;
	bChanged = true;
	while (bChanged && (i < count-1))
	{
		bChanged = false;
		j = count-1;
		while (j > i)
		{
   			PRI = TGRI.PRIArray[A[j]];
   			PRI2 = TGRI.PRIArray[A[j-1]];
			if (comparePRI(PRI, PRI2, bFrags)==2)
			{
				help = A[j-1];
				A[j-1] = A[j];
				A[j] = help;
				bChanged = true;
			}
            j--;
		}
		i++;
	}
}

function int comparePRI (PlayerReplicationInfo PRI, PlayerReplicationInfo PRI2, bool bFrags)
{
	local int A, B, C, D;
	local TO_PRI TOPRI, TOPRI2; // Player
	local TO_BRI TOBRI, TOBRI2; // Bot

	if (bFrags)
	{
        // Sort by Kills/Death
		A = int(PRI.Score);
		B = int(PRI2.Score);
        C = int(PRI.Deaths);
		D = int(PRI2.Deaths);
    } else {
        // Sort by Score
		TOPRI=TO_PRI(PRI);
        TOBRI=TO_BRI(PRI);
        TOPRI2=TO_PRI(PRI2);
        TOBRI2=TO_BRI(PRI2);
        if (TOPRI != none) A = TOPRI.InflictedDmg;
        else A = TOBRI.InflictedDmg;
        if (TOPRI2 != none) B = TOPRI2.InflictedDmg;
        else B = TOBRI2.InflictedDmg;
        C = int(PRI.Score);
		D = int(PRI2.Score);
    }

	if (A<B || (A==B)&&(C>D)) return 0; // A<B
	if (A==B && C==D) return 1; // A==B
	if (A>B || (A==B)&&(C<D)) return 2; // A>B
}

function string OnOff(bool B)
{
    if (B) return "on";
    else return "off";
}

// strips mIRC-like color codes:
function string stripMircCodes (string Text)
{
    local int i, tmp;
    local string Output;

    Text = ReplaceText(Text, IRCBold, ""); // bold
    Text = ReplaceText(Text, chr(019), ""); // reset
    Text = ReplaceText(Text, IRCUline, ""); // uline
    Text = ReplaceText(Text, IRCReverse, ""); // reverse

    // color:
    i = InStr(Text, IRCColor);
    while (i != -1) {
        Output = Output $ Left(Text, i);
        if (InStr("0123456789", Mid(Text, i+1, 1)) != -1) tmp = 3;
        else tmp = 1;
        Text = Mid(Text, i + tmp);
        i = InStr(Text, IRCColor);
    }
    Output = Output $ Text;
    return Output;
}

function string IRCColorTeams (int i)
{
    switch (i)
    {
        case 0: return IRCColorTeams0;
        case 1: return IRCColorTeams1;
        case 2: return IRCColorTeams2;
        case 3: return IRCColorTeams3;
    }
}

static function string Float2String(float FloatVar, optional int Precision)
{
	local int i;

	if (Precision == 0) Precision = -1;
	i = InStr(string(FloatVar), ".");

	if (i != -1)
		return Left(string(FloatVar), i+Precision+1);
	else
		return string(FloatVar);
}

defaultproperties
{
// Debug=true // ==debug-build
bHidden=True
PieceName="TOST IRC"
PieceVersion="2.0.2.49"
PieceOrder=9999
ServerOnly=True
BaseMessage=280

// config:
bEnable=False
bMute=False
bShowJoin=True
bShowSay=True
bShowScore=True
bShowKill=True
bShowGameInfo=True
bShowWeapon=True
bShowHealth=True
bShowHitparade=True
bShowKick=True
bShowTOSTKick=True
bShowTOPInfo=True
bSetTopic=True
bShowServer=True
bSortByFrags=False
bNoColors=False
BotNick="TOSTlive"
BotRealName="TOSTIRC serverside bot"
BotIdent="TOSTIRC"
BotAdminPassword=""
IRCServer(0)="irc.quakenet.org:6667"
IRCServer(1)="splatterworld.de.quakenet.org:6667"
IRCServer(2)="b0rk.uk.quakenet.org:6667"
IRCServer(3)="mediatraffic.fi.quakenet.org:6667"
IRCServer(4)="ngi.it.quakenet.org:6667"
IRCServer(5)="tiscali.dk.quakenet.org:6667"
IRCPerform1=""
IRCPerform2=""
IRCChannel=""
IRCChannelKey=""
IRCReconnectTime=60
IRCAntiFloodBytes=1000
TOServerName="IdidntEditMyConfigFile"
RepeatGameInfo=3
TagLayout="( %text% )"
TeamNames(0)="Terrorists"
TeamNames(1)="Special Forces"

//internal
TOPchar="*"
PlayerNameLen=22

}


