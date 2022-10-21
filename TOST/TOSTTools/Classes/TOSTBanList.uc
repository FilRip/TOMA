// $Id: TOSTBanList.uc 558 2004-04-13 01:25:38Z stark $
//----------------------------------------------------------------------------
// Project   : TOST
// Version   : 0.9
// Author    : BugBunny/DiLDoG/Stark
//----------------------------------------------------------------------------
// Version	Changes
// 	0.5		+ first release
//	0.6		+ Added reason/name, changed ini format
//	0.8		+ Added GUI
//	0.8.5	+ Add ban on 191 (IdentifyCheat)
//  0.9		+ new format, splitted global bans from the rest (Stark)
//----------------------------------------------------------------------------

class TOSTBanList expands TOSTPiece config;

enum BanType
{
	B_None,
	B_PermBan,
	B_TimedBan,
	B_TempBan
};

struct BanStruct
{
	var		int		ValidTil;
	var		int		TimeStamp;
	var		string	VictimIp;
	var		string	VictimName;
	var		string	AdminIP;
	var		string	AdminName;
	var		string	Reason;
};

var config	bool	AutoUpdate;
var config	int		LastUpdate;
var config	string	TOSTIPPolicy[256];
var config	string	TOSTGlobalBanlist[50];

var BanStruct		BanDetails[256];
var PlayerPawn		PendingPlayers[32];
var HTTPTransfer	HTTPLink;

var			int		Port;
var			string	Hostname;
var			string	Request;

//----------------------------------------------------------------------------
// TOST Event Handling
//----------------------------------------------------------------------------
function EventInit()
{
	// Refresh banlist
	LoadBanList();
	SaveBanList();

	super.EventInit();
}

function EventPostInit()
{
	// Check for updates if needed

	if (AutoUpdate && (LastUpdate == 0 || GetFutureTimeStamp(0,0,-1,0,0) > LastUpdate))
	{
		xLog("Requesting global BanList");
		HTTPLink = Spawn(class'HTTPTransfer', self);
		HTTPLink.Master = self;
		HTTPLink.Method = HTTP_GET;
		HTTPLink.Port = Port;
		HTTPLink.HostName = Hostname;
		HTTPLink.Request = Request;
		HTTPLink.Connect();
	}

	super.EventPostInit();
}

function EventPlayerConnect(Pawn Player)
{
	local	int		i;
	super.EventPlayerConnect(Player);

	// we do not have IPs here, so put new players in the queue
	for (i=0; i<32; i++)
	{
		if (PendingPlayers[i] == None)
		{
			PendingPlayers[i] = PlayerPawn(Player);
			break;
		}
	}
}

function EventMessage(TOSTPiece Sender, int MsgIndex)
{
	switch (MsgIndex)
	{
		// ListBan's
		case BaseMessage+0	:	GetBanList(Sender.Params.Param6);
								break;
		// Search for ban
		case BaseMessage+1	:	GetBanList(Sender.Params.Param6, Sender.Params.Param4);
								break;
		// GetDetails
		case BaseMessage+2	:	GetBanDetails(Sender.Params.Param6, Sender.Params.Param1);
								break;
		// AddBan
		case BaseMessage+3	:	AddBan(ParseBanDetails(Sender.Params.Param4), Sender.Params.Param6);
								break;
		// DelBan
		case BaseMessage+4	:	DelBan(Sender.Params.Param4, Sender.Params.Param6);
								break;
		// NotifyCheat
		//case 191			:	if (Sender.Params.Param5) AddBanComm(Sender.Params.Param6.GetPlayerNetworkAddress(), Sender.Params.Param6.PlayerReplicationInfo.PlayerName, "", Sender.PieceName, -1, -1, Sender.Params.Param4);
		//						break;
	}
	super.EventMessage(Sender, MsgIndex);
}

function EventAnswerMessage(TOSTPiece Sender, int MsgIndex)
{
	switch (MsgIndex)
	{
		// Response from HTTPLink
		case -1				:	RecieveBanList();
								return;
	}
}

function bool EventCheckClearance(TOSTPiece Sender, PlayerPawn Player, int MsgType, out int Allowed)
{
	// allow GetBanList
	if (MsgType == BaseMessage+0)
	{
		Allowed = 1;
		return true;
	}

	return super.EventCheckClearance(Sender, Player, MsgType, Allowed);
}

function Tick(float Delta)
{
	local	int	i;
	local	string	IP;
	// check for players in queue
	for (i=0; i<32; i++)
	{
		if (PendingPlayers[i] != none && PendingPlayers[i].GetPlayerNetworkAddress() != "")
		{
			IP = IPOnly(PendingPlayers[i].GetPlayerNetworkAddress());
			CheckForBan(PendingPlayers[i], IP);
			PendingPlayers[i] = none;
		}
	}
}

//----------------------------------------------------------------------------
// Main Part
//----------------------------------------------------------------------------
// * LoadBanList - Load banlist from ini into struct
function LoadBanList()
{
	local	int			i, j;
	local	BanStruct	TempDetails;

	for (i=0;i<256;i++)
	{
		// Parse the current line
		if (TOSTIPPolicy[i] != "")
		{
			TempDetails = ParseBanDetails(TOSTIPPolicy[i]);
			if (Type(TempDetails) != B_None && FindIP(TempDetails.VictimIp) == -1)
				BanDetails[j++] = TempDetails;
		}
	}
	// Clear rest of structs
	for (i=j;i<256;i++)
	{
		BanDetails[j].VictimIp = "";
	}
}

// * SaveBanList - Save ban struct to ini
function SaveBanList()
{
	local	int		i,j;
	local	int		ValidTil;

	// Store permanent bans
	for (i=0;i<256;i++)
	{
		if(Type(BanDetails[i]) == B_PermBan)
			TOSTIPPolicy[j++] = AssambleBanDetails(BanDetails[i]);
	}
	// Store timed bans
	for (i=0;i<256;i++)
	{
		if(Type(BanDetails[i]) == B_TimedBan)
			TOSTIPPolicy[j++] = AssambleBanDetails(BanDetails[i]);
	}
	// Clear rest of ini entries
	for (i=j;i<256;i++)
	{
		TOSTIPPolicy[i] = "";
	}
	SaveConfig();
}

// * RecieveBanList - Add bans from HTTPLink to the ini
function RecieveBanList()
{
	local int i, j;
	local string S;

	if (HTTPLink.bTransferFailed)
	{
		xLog("Could not update banlist, Transfer failed");
	}
	else
	{
		// Add recieved bans (new format)
		for (i=0;i<ArrayCount(TOSTGlobalBanlist);i++)
		{
			TOSTGlobalBanList[i] = HTTPLink.ResponseValue[i];
			// Logging disabled... (useless spam)
			/*
			S = TOSTGlobalBanList[i];
			while (true)
			{
				j = InStr(S, ";");
				if (j == -1) break;
				else
				{
					xLog("Banned "$ Left(S, j) $" until next update.");
					S = Mid(S, j+1);
				}
			}*/
		}
		LastUpdate = GetCurrentTimeStamp();
		SaveConfig();
	}
}

// * BanListUpdated - Notify players that banlist was changed
function BanListUpdated()
{
	SendClientMessage(221);
}

// * GetBanList - Send banlist to a player
function GetBanList(PlayerPawn Player, optional string Filter)
{
	local	int		i;

	if (Player != none)
	{
		// Start transmission
		Params.Param1 = 1;
		Params.Param4 = "";
		Params.Param6 = Player;
		for (i=0;i<256;i++)
		{
			// Filter bans if filter given
			if (Type(BanDetails[i]) != B_None  && (Filter == "" || Instr(caps(BanDetails[i].VictimIP),caps(Filter)) != -1 ||Instr(caps(BanDetails[i].VictimName),caps(Filter)) != -1))
			{
				if (BanDetails[i].VictimName == "")
					Params.Param4 = Params.Param4 $ i $ "\\*<unknown>\\*";
				else
					Params.Param4 = Params.Param4 $ i $ "\\*"$EscapeChars(BanDetails[i].VictimName)$"\\*";

				// Send in blocks of 200 chars
				if (Len(Params.Param4) > 300)
				{
					SendClientMessage(222);
					Params.Param4 = "";
					Params.Param1 = 2;
				}
			}
		}
		// Send rest
		Params.Param1 = 3;
		SendClientMessage(222);
	}
}

// * GetBanDetails - Send bandetails to a player
function GetBanDetails(PlayerPawn Player, int Index)
{
	if (Player != none)
	{
		if (Type(BanDetails[Index]) != B_None)
			Params.Param4 = AssambleBanDetails(BanDetails[Index]);
		else
			Params.Param4 = "";

		Params.Param1 = Index;
		Params.Param6 = Player;
		SendClientMessage(223);
	}
}

// * AddBanComm - Add ban from external pieces
function bool AddBanComm(string VictimIP, string VictimName, string AdminIP, string AdminName, int Days, int Minutes, string Reason)
{
	local	BanStruct	TempDetails;

	if ((Days * 1440 + Minutes) > 0)
		TempDetails.ValidTil	= GetFutureTimeStamp(0, 0, Abs(Days), 0, Abs(Minutes));
	else if ((Days ==  0) && (Minutes ==  0))
		TempDetails.ValidTil 	= -2;
	else // ((Days == -1) && (Minutes == -1))
		TempDetails.ValidTil 	= 0;

	TempDetails.TimeStamp	= GetCurrentTimeStamp();
	TempDetails.VictimIp	= IPOnly(VictimIP);
	TempDetails.VictimName	= VictimName;
	TempDetails.AdminIP		= IPOnly(AdminIP);
	TempDetails.AdminName	= AdminName;
	TempDetails.Reason		= Reason;
	return AddBan(TempDetails);
}

// * AddBan - Add a ip to the list
function bool AddBan(BanStruct TempDetails, optional PlayerPawn Player)
{
	local	int		i;

	if (Type(TempDetails) == B_None)
	{
		// Invalid ban
		xLog("Warning, Ban is not valid, adding IP "$TempDetails.VictimIP$" failed");
		if (Player != none) NotifyPlayer(2, Player, "Ban is not valid, adding IP "$TempDetails.VictimIP$" failed");
		return false;
	}

	if (Player != none)
	{
		TempDetails.AdminIP = IPOnly(Player.GetPlayerNetworkAddress());
		TempDetails.AdminName = Player.PlayerReplicationInfo.PlayerName;
	}

	i = FindIP(TempDetails.VictimIp);
	if (i == -1)
	{
		// Get first unused place
		i = 0;
		while (i++ < 256 && Type(BanDetails[i]) != B_None);

		if (i == 256)
		{
			// Banlist full
			xLog("Warning, TOSTBanList is full, adding IP "$TempDetails.VictimIP$" failed");
			if (Player != none) NotifyPlayer(2, Player, "Warning, TOSTBanList is full, adding IP "$TempDetails.VictimIP$" failed");
			return false;
		}

		// new timestamp
		TempDetails.TimeStamp = GetCurrentTimeStamp();
		BanDetails[i] = TempDetails;
	}
	else
	{
		// Keep timestamp when overwriting a ban
		TempDetails.TimeStamp = BanDetails[i].TimeStamp;
		BanDetails[i] = TempDetails;
	}

	if (Type(BanDetails[i]) == B_PermBan)
	{
		xLog(TempDetails.AdminName$" banned IP "$TempDetails.VictimIP$" permanently");
		if (Player != none) NotifyPlayer(2, Player, "IP "$TempDetails.VictimIP$" is permanently banned");
		SaveBanList();
		BanListUpdated();
	}
	else if (Type(BanDetails[i]) == B_TimedBan)
	{
		xLog(TempDetails.AdminName$" banned IP "$TempDetails.VictimIP$" untill "$ResolveTimeStamp(TempDetails.ValidTil));
		if (Player != none) NotifyPlayer(2, Player, "IP "$TempDetails.VictimIP$" is banned untill "$ResolveTimeStamp(TempDetails.ValidTil));
		SaveBanList();
		BanListUpdated();
	}
	else if (Type(BanDetails[i]) == B_TempBan)
	{
		xLog(TempDetails.AdminName$" banned IP "$TempDetails.VictimIP$" untill mapswitch");
		if (Player != none) NotifyPlayer(2, Player, "IP "$TempDetails.VictimIP$" is banned untill map switch");
		BanListUpdated();
	}

	return true;
}

// * DelBan - delete a ban by ip
function DelBan(string IP, optional PlayerPawn Player)
{
	local	int		i;

	i = FindIP(IP);
	if (i != -1)
	{
		if (Type(BanDetails[i]) == B_PermBan)
		{
			xLog("IP "$BanDetails[i].VictimIP$" was removed from permanent banlist");
			if (Player != none) NotifyPlayer(2, Player, "IP "$BanDetails[i].VictimIP$" was removed from permanent banlist");
			BanDetails[i].VictimIp = "";
			SaveBanList();
			BanListUpdated();
		}
		else if (Type(BanDetails[i]) == B_TimedBan)
		{
			xLog("IP "$BanDetails[i].VictimIP$" was removed from timed banlist");
			if (Player != none) NotifyPlayer(2, Player, "IP "$BanDetails[i].VictimIP$" was removed from timed banlist");
			BanDetails[i].VictimIp = "";
			SaveBanList();
			BanListUpdated();
		}
		else if (Type(BanDetails[i]) == B_TempBan)
		{
			xLog("IP "$BanDetails[i].VictimIP$" was removed from temp banlist");
			if (Player != none) NotifyPlayer(2, Player, "IP "$BanDetails[i].VictimIP$" was removed from temp banlist");
			BanDetails[i].VictimIp = "";
			BanListUpdated();
		}
	}
}

function CheckForBan (PlayerPawn Player, string IP)
{
	local	int		i;
	local	bool	IsBanned;
	local	string	Reason;

	i = FindIP(IP);

	if (i == -2)
	{
    	NotifyPlayer(0, Player, "Your IP is banned on this server - you are on the global TOST ban list!");
		NotifyRest(1, Player, Player.PlayerReplicationInfo.PlayerName@"is banned on this server (global ban list)");
		xLog("Someone on the global ban list tried to connect to your server :"@Player.PlayerReplicationInfo.PlayerName@"IP:"@Player.GetPlayerNetworkAddress());
		TO_GameBasics(Level.Game).Kick(Player);
	}
	else if (i != -1)
	{
		if (BanDetails[i].Reason != "") Reason = " for "$BanDetails[i].Reason;

		if (Type(BanDetails[i]) == B_PermBan)
		{
			NotifyPlayer(0, Player, "Your IP is banned on this server!");
			NotifyRest(1, Player, Player.PlayerReplicationInfo.PlayerName@"is banned on this server"$Reason);
		}
		if (Type(BanDetails[i]) == B_TimedBan)
		{
			NotifyPlayer(0, Player, "Your IP is banned on this server till"@ResolveTimeStamp(BanDetails[i].ValidTil));
			NotifyRest(1, Player, Player.PlayerReplicationInfo.PlayerName@"is banned on this server till"@ResolveTimeStamp(BanDetails[i].ValidTil)$Reason);
		}
		if (Type(BanDetails[i]) == B_tempBan)
		{
			NotifyPlayer(0, Player, "Your IP is banned on this server till the end of the map!");
			NotifyRest(1, Player, Player.PlayerReplicationInfo.PlayerName@"is banned on this server till the end of the map"$Reason);
		}
		TO_GameBasics(Level.Game).Kick(Player);
	}
}

//----------------------------------------------------------------------------
// Misc helper functions
//----------------------------------------------------------------------------
function string AssambleBanDetails(BanStruct TempDetails)
{
	local string	TempString;

	TempString = TempDetails.TimeStamp								$ "\\*";
	TempString = TempString $ TempDetails.ValidTil					$ "\\*";
	TempString = TempString $ TempDetails.VictimIp					$ "\\*";
	TempString = TempString $ EscapeChars(TempDetails.VictimName)	$ "\\*";
	TempString = TempString $ TempDetails.AdminIP					$ "\\*";
	TempString = TempString $ EscapeChars(TempDetails.AdminName)	$ "\\*";
	TempString = TempString $ EscapeChars(TempDetails.Reason)		$ "\\*";

	return TempString;
}

function BanStruct ParseBanDetails(string Entry)
{
	local BanStruct	TempDetails;
	local string	Char, Temp;
	local int		CurrentField, i;

	CurrentField=0;
	Temp="";
	for(i=0;i<Len(Entry);i++)
	{
		Char = Mid(Entry,i,1);

		// Handle Special Chars
		if(Char == "\\")
		{
			Char = Mid(Entry,++i,1);
			if(Char == "*")
			{
				// Store current field
				switch (CurrentField++)
				{
					case 0	:	if (int(Temp) <= 0)
									TempDetails.TimeStamp = GetCurrentTimeStamp();
								else
									TempDetails.TimeStamp = int(Temp);
								break;
					case 1	:	if (InStr(Temp,"+") != -1)
									TempDetails.ValidTil = GetFutureTimeStamp(0, 0, 0, 0, int(Mid(Temp,1)));
								else
									TempDetails.ValidTil = int(Temp);
								break;
					case 2	:	TempDetails.VictimIp	= Temp;
								break;
					case 3	:	TempDetails.VictimName	= Temp;
								break;
					case 4	:	TempDetails.AdminIP		= Temp;
								break;
					case 5	:	TempDetails.AdminName	= Temp;
								break;
					case 6	:	TempDetails.Reason		= Temp;
								break;
				}
				Temp = "";
				continue;
			}
		}
		Temp = Temp $ Char;
	}

	if (CurrentField != 7)
	{
		dLog("Warning: Parsing "$Entry$" failed! ("$CurrentField$" fields)");
		TempDetails.VictimIp	= "";
	}
	return TempDetails;
}

function int FindIP(string IP)
{
	local	int		i, j;
	local	bool	Found;

	// normal bans
	for (i=0; i<256; i++)
	{
		j = InStr(BanDetails[i].VictimIp, "*");
		if (j > 0)
			Found = (InStr(IP, Left(BanDetails[i].VictimIp, j)) > 0);
		else
			Found = (IP == BanDetails[i].VictimIp);
		if (Found && Type(BanDetails[i]) != B_None)
			return i;
	}

	// global bans
	for (i=0; i<ArrayCount(TOSTGlobalBanList); i++)
		if (InStr(TOSTGlobalBanList[i], IP) != -1)
			return -2;

	// not banned
	return -1;
}

function BanType Type(BanStruct TempDetails)
{
	if (TempDetails.VictimIP == "")
	 	return B_None;
	else if (TempDetails.ValidTil == -2)
		return B_TempBan;
	else if (TempDetails.ValidTil == 0)
		return B_PermBan;
 	else if (TempDetails.ValidTil > GetCurrentTimeStamp())
		return B_TimedBan;

	return B_None;
}

function string EscapeChars(string Text)
{
    local int i;
    local string Output;

    i = InStr(Text, "\\");
    while (i != -1)
	{
        Output = Output $ Left(Text, i) $ "\\\\";
        Text = Mid(Text, i + 2);
        i = InStr(Text, "\\");
    }
    Output = Output $ Text;
    return Output;
}

//----------------------------------------------------------------------------
// defaultproperties
//----------------------------------------------------------------------------
defaultproperties
{
	PieceName="TOST Ban List"
	PieceVersion="0.9.0.0"
	ServerOnly=true
	BaseMessage=180

	Port=80
	//Hostname="banlist.djemma-el-fna.de"
	//Request="http://banlist.djemma-el-fna.de/"
	Hostname="tost.tactical-ops.to"
	Request="http://tost.tactical-ops.to/banlist/"

	AutoUpdate=False
	LastUpdate=0

	TOSTIPPolicy(0)=""
	TOSTIPPolicy(1)=""
	TOSTIPPolicy(2)=""
	TOSTIPPolicy(3)=""
	TOSTIPPolicy(4)=""
	TOSTIPPolicy(5)=""
	TOSTIPPolicy(6)=""
	TOSTIPPolicy(7)=""
	TOSTIPPolicy(8)=""
	TOSTIPPolicy(9)=""
	TOSTIPPolicy(10)=""
	TOSTIPPolicy(11)=""
	TOSTIPPolicy(12)=""
	TOSTIPPolicy(13)=""
	TOSTIPPolicy(14)=""
	TOSTIPPolicy(15)=""
	TOSTIPPolicy(16)=""
	TOSTIPPolicy(17)=""
	TOSTIPPolicy(18)=""
	TOSTIPPolicy(19)=""
	TOSTIPPolicy(20)=""
	TOSTIPPolicy(21)=""
	TOSTIPPolicy(22)=""
	TOSTIPPolicy(23)=""
	TOSTIPPolicy(24)=""
	TOSTIPPolicy(25)=""
	TOSTIPPolicy(26)=""
	TOSTIPPolicy(27)=""
	TOSTIPPolicy(28)=""
	TOSTIPPolicy(29)=""
	TOSTIPPolicy(30)=""
	TOSTIPPolicy(31)=""
	TOSTIPPolicy(32)=""
	TOSTIPPolicy(33)=""
	TOSTIPPolicy(34)=""
	TOSTIPPolicy(35)=""
	TOSTIPPolicy(36)=""
	TOSTIPPolicy(37)=""
	TOSTIPPolicy(38)=""
	TOSTIPPolicy(39)=""
	TOSTIPPolicy(40)=""
	TOSTIPPolicy(41)=""
	TOSTIPPolicy(42)=""
	TOSTIPPolicy(43)=""
	TOSTIPPolicy(44)=""
	TOSTIPPolicy(45)=""
	TOSTIPPolicy(46)=""
	TOSTIPPolicy(47)=""
	TOSTIPPolicy(48)=""
	TOSTIPPolicy(49)=""
	TOSTIPPolicy(50)=""
	TOSTIPPolicy(51)=""
	TOSTIPPolicy(52)=""
	TOSTIPPolicy(53)=""
	TOSTIPPolicy(54)=""
	TOSTIPPolicy(55)=""
	TOSTIPPolicy(56)=""
	TOSTIPPolicy(57)=""
	TOSTIPPolicy(58)=""
	TOSTIPPolicy(59)=""
	TOSTIPPolicy(60)=""
	TOSTIPPolicy(61)=""
	TOSTIPPolicy(62)=""
	TOSTIPPolicy(63)=""
	TOSTIPPolicy(64)=""
	TOSTIPPolicy(65)=""
	TOSTIPPolicy(66)=""
	TOSTIPPolicy(67)=""
	TOSTIPPolicy(68)=""
	TOSTIPPolicy(69)=""
	TOSTIPPolicy(70)=""
	TOSTIPPolicy(71)=""
	TOSTIPPolicy(72)=""
	TOSTIPPolicy(73)=""
	TOSTIPPolicy(74)=""
	TOSTIPPolicy(75)=""
	TOSTIPPolicy(76)=""
	TOSTIPPolicy(77)=""
	TOSTIPPolicy(78)=""
	TOSTIPPolicy(79)=""
	TOSTIPPolicy(80)=""
	TOSTIPPolicy(81)=""
	TOSTIPPolicy(82)=""
	TOSTIPPolicy(83)=""
	TOSTIPPolicy(84)=""
	TOSTIPPolicy(85)=""
	TOSTIPPolicy(86)=""
	TOSTIPPolicy(87)=""
	TOSTIPPolicy(88)=""
	TOSTIPPolicy(89)=""
	TOSTIPPolicy(90)=""
	TOSTIPPolicy(91)=""
	TOSTIPPolicy(92)=""
	TOSTIPPolicy(93)=""
	TOSTIPPolicy(94)=""
	TOSTIPPolicy(95)=""
	TOSTIPPolicy(96)=""
	TOSTIPPolicy(97)=""
	TOSTIPPolicy(98)=""
	TOSTIPPolicy(99)=""
	TOSTIPPolicy(100)=""
	TOSTIPPolicy(101)=""
	TOSTIPPolicy(102)=""
	TOSTIPPolicy(103)=""
	TOSTIPPolicy(104)=""
	TOSTIPPolicy(105)=""
	TOSTIPPolicy(106)=""
	TOSTIPPolicy(107)=""
	TOSTIPPolicy(108)=""
	TOSTIPPolicy(109)=""
	TOSTIPPolicy(110)=""
	TOSTIPPolicy(111)=""
	TOSTIPPolicy(112)=""
	TOSTIPPolicy(113)=""
	TOSTIPPolicy(114)=""
	TOSTIPPolicy(115)=""
	TOSTIPPolicy(116)=""
	TOSTIPPolicy(117)=""
	TOSTIPPolicy(118)=""
	TOSTIPPolicy(119)=""
	TOSTIPPolicy(120)=""
	TOSTIPPolicy(121)=""
	TOSTIPPolicy(122)=""
	TOSTIPPolicy(123)=""
	TOSTIPPolicy(124)=""
	TOSTIPPolicy(125)=""
	TOSTIPPolicy(126)=""
	TOSTIPPolicy(127)=""
	TOSTIPPolicy(128)=""
	TOSTIPPolicy(129)=""
	TOSTIPPolicy(130)=""
	TOSTIPPolicy(131)=""
	TOSTIPPolicy(132)=""
	TOSTIPPolicy(133)=""
	TOSTIPPolicy(134)=""
	TOSTIPPolicy(135)=""
	TOSTIPPolicy(136)=""
	TOSTIPPolicy(137)=""
	TOSTIPPolicy(138)=""
	TOSTIPPolicy(139)=""
	TOSTIPPolicy(140)=""
	TOSTIPPolicy(141)=""
	TOSTIPPolicy(142)=""
	TOSTIPPolicy(143)=""
	TOSTIPPolicy(144)=""
	TOSTIPPolicy(145)=""
	TOSTIPPolicy(146)=""
	TOSTIPPolicy(147)=""
	TOSTIPPolicy(148)=""
	TOSTIPPolicy(149)=""
	TOSTIPPolicy(150)=""
	TOSTIPPolicy(151)=""
	TOSTIPPolicy(152)=""
	TOSTIPPolicy(153)=""
	TOSTIPPolicy(154)=""
	TOSTIPPolicy(155)=""
	TOSTIPPolicy(156)=""
	TOSTIPPolicy(157)=""
	TOSTIPPolicy(158)=""
	TOSTIPPolicy(159)=""
	TOSTIPPolicy(160)=""
	TOSTIPPolicy(161)=""
	TOSTIPPolicy(162)=""
	TOSTIPPolicy(163)=""
	TOSTIPPolicy(164)=""
	TOSTIPPolicy(165)=""
	TOSTIPPolicy(166)=""
	TOSTIPPolicy(167)=""
	TOSTIPPolicy(168)=""
	TOSTIPPolicy(169)=""
	TOSTIPPolicy(170)=""
	TOSTIPPolicy(171)=""
	TOSTIPPolicy(172)=""
	TOSTIPPolicy(173)=""
	TOSTIPPolicy(174)=""
	TOSTIPPolicy(175)=""
	TOSTIPPolicy(176)=""
	TOSTIPPolicy(177)=""
	TOSTIPPolicy(178)=""
	TOSTIPPolicy(179)=""
	TOSTIPPolicy(180)=""
	TOSTIPPolicy(181)=""
	TOSTIPPolicy(182)=""
	TOSTIPPolicy(183)=""
	TOSTIPPolicy(184)=""
	TOSTIPPolicy(185)=""
	TOSTIPPolicy(186)=""
	TOSTIPPolicy(187)=""
	TOSTIPPolicy(188)=""
	TOSTIPPolicy(189)=""
	TOSTIPPolicy(190)=""
	TOSTIPPolicy(191)=""
	TOSTIPPolicy(192)=""
	TOSTIPPolicy(193)=""
	TOSTIPPolicy(194)=""
	TOSTIPPolicy(195)=""
	TOSTIPPolicy(196)=""
	TOSTIPPolicy(197)=""
	TOSTIPPolicy(198)=""
	TOSTIPPolicy(199)=""
	TOSTIPPolicy(200)=""
	TOSTIPPolicy(201)=""
	TOSTIPPolicy(202)=""
	TOSTIPPolicy(203)=""
	TOSTIPPolicy(204)=""
	TOSTIPPolicy(205)=""
	TOSTIPPolicy(206)=""
	TOSTIPPolicy(207)=""
	TOSTIPPolicy(208)=""
	TOSTIPPolicy(209)=""
	TOSTIPPolicy(210)=""
	TOSTIPPolicy(211)=""
	TOSTIPPolicy(212)=""
	TOSTIPPolicy(213)=""
	TOSTIPPolicy(214)=""
	TOSTIPPolicy(215)=""
	TOSTIPPolicy(216)=""
	TOSTIPPolicy(217)=""
	TOSTIPPolicy(218)=""
	TOSTIPPolicy(219)=""
	TOSTIPPolicy(220)=""
	TOSTIPPolicy(221)=""
	TOSTIPPolicy(222)=""
	TOSTIPPolicy(223)=""
	TOSTIPPolicy(224)=""
	TOSTIPPolicy(225)=""
	TOSTIPPolicy(226)=""
	TOSTIPPolicy(227)=""
	TOSTIPPolicy(228)=""
	TOSTIPPolicy(229)=""
	TOSTIPPolicy(230)=""
	TOSTIPPolicy(231)=""
	TOSTIPPolicy(232)=""
	TOSTIPPolicy(233)=""
	TOSTIPPolicy(234)=""
	TOSTIPPolicy(235)=""
	TOSTIPPolicy(236)=""
	TOSTIPPolicy(237)=""
	TOSTIPPolicy(238)=""
	TOSTIPPolicy(239)=""
	TOSTIPPolicy(240)=""
	TOSTIPPolicy(241)=""
	TOSTIPPolicy(242)=""
	TOSTIPPolicy(243)=""
	TOSTIPPolicy(244)=""
	TOSTIPPolicy(245)=""
	TOSTIPPolicy(246)=""
	TOSTIPPolicy(247)=""
	TOSTIPPolicy(248)=""
	TOSTIPPolicy(249)=""
}

