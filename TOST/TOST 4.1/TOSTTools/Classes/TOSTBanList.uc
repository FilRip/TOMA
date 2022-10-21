//----------------------------------------------------------------------------
// Project : TOST
// File    : TOSTBanList.uc
// Version : 0.5
// Author  : BugBunny
//----------------------------------------------------------------------------
// Version	Changes
// 0.5		+ first release
//----------------------------------------------------------------------------

class TOSTBanList expands TOSTPiece config;

var config	bool	AutoUpdate;
var config	int		LastUpdate;
var config	string	BanIP[250];
var config	int		BannedTill[250];

var PlayerPawn		PendingPlayers[32];
var TOSTBanListUpdate	Updater;

// * Helper

function	int	GetCurrentTimeStamp()
{
	return GetTimeStamp(Level.Year, Level.Month, Level.Day, Level.Hour, Level.Minute);
}

function	int	GetDayPerMonth(int Month, int Year)
{
	switch (Month)
	{
		case 2 :	if ((Year & 3) == 0)
						return 29;
					else
						return 28;
		case 4 :
		case 6 :
		case 9 :
		case 11 : 	return 30;
		default	:	return 31;
	}

}

function	int	GetFutureTimeStamp(optional int AddYear, optional int AddMonth, optional int AddDay, optional int AddHour, optional int AddMinute)
{
	local	int	Year, Month, Day, Hour, Minute;

	Year = Level.Year+AddYear;
	Month = Level.Month+AddMonth;
	Day = Level.Day+AddDay;
	Hour = Level.Hour+AddHour;
	Minute = Level.Minute+AddMinute;

	// correct time stamp
	while (Minute >= 60)
	{
		Minute -= 60;
		Hour++;
	}
	while (Hour >= 24)
	{
		Hour -= 24;
		Day++;
	}
	while (Month > 12)
	{
		Month -= 12;
		Year++;
	}
	while (Day > GetDayPerMonth(Month, Year))
	{
		Day -= GetDayPerMonth(Month, Year);
		Month++;
		if (Month > 12)
		{
			Month = 1;
			Year++;
		}
	}

	return GetTimeStamp(Year, Month, Day, Hour, Minute);
}

function 	int	GetTimeStamp(int Year, int Month, int Day, int Hour, int Minute)
{
	return ((Year & 8191) << 20) | ((Month & 31) << 16) | ((Day & 31) << 11) | ((Hour & 31) << 6) | (Minute & 63);
}

function	string	ResolveTimeStamp(int TimeStamp)
{
	local	string	Time;
	local	int		i;

	//Year
	i = (TimeStamp >> 20);
	Time = string(i);
	//Month
	i = ((TimeStamp >> 16) & 15);
	if (i < 10)
		Time = "0"$i$"."$Time;
	else
		Time = string(i)$"."$Time;
	//Day
	i = ((TimeStamp >> 11) & 31);
	if (i < 10)
		Time = "0"$i$"."$Time;
	else
		Time = string(i)$"."$Time;
	//Hour
	i = ((TimeStamp >> 6) & 31);
	if (i < 10)
		Time = Time$" 0"$i;
	else
		Time = Time$" "$i;
	// Minute
	i = (TimeStamp & 63);
	if (i < 10)
		Time = Time$":0"$i;
	else
		Time = Time$":"$i;

	return Time;
}

function	string	NoPort(string IP)
{
	local	int	i;

	i = InStr(IP, ":");
	if (i > 0)
		return Left(IP, i);
	else
		return IP;
}

function	int		FindIP(string IP)
{
	local	int		i, j;
	local	bool	Found;

	for (i=0; i<250; i++)
	{
		j = InStr(BanIP[i], "*");
		if (j > 0)
			Found = (InStr(IP, Left(BanIP[i], j)) > 0);
		else
			Found = (IP == BanIP[i]);
		if (Found)
			return i;
	}
	return -1;
}

// * MAIN PART

function	AddIP(string IP, int Days, int Minutes, optional bool GlobalBan)
{
	local	int		i;

	i = FindIP(IP);
	if (i == -1)
	{
		i=0;
		while (i<250)
		{
			if (BanIP[i] == "")
			{
				BanIP[i] = IP;
				// forever ?
				if (Days == 0 && Minutes == 0)
				{
					BannedTill[i] = 0;
					XLog("IP "$IP$" is banned forerver");
				} else {
					if (GlobalBan)
					{
						BannedTill[i] = -GetFutureTimeStamp(0, 0, Days, 0, Minutes);
						XLog("IP "$IP$" is banned until next update: "$ResolveTimeStamp(-BannedTill[i]));
					} else	{
						BannedTill[i] = GetFutureTimeStamp(0, 0, Days, 0, Minutes);
						XLog("IP "$IP$" is banned till "$ResolveTimeStamp(BannedTill[i]));
					}
				}
				SaveConfig();
				return;
			}
			i++;
		}
	}
}

function	CheckForBan(PlayerPawn Player, string IP)
{
	local	int		i;
	local	bool	IsBanned;

	i = FindIP(IP);
	IsBanned = (i != -1);

	// check BanPeriod (for lucky just in time players ;) )
	if (IsBanned)
	{
		if (((BannedTill[i] > 0) && (GetCurrentTimeStamp() > BannedTill[i])) || ((BannedTill[i] < 0) && (GetCurrentTimeStamp() > -BannedTill[i])))
		{
			// Ban period is over
			BanIP[i]="";
			BannedTill[i]=0;
			IsBanned=false;
		}
	}
	if (IsBanned)
	{
		if (BannedTill[i] == 0)
		{
			NotifyPlayer(0, Player, "Youre IP is banned on this server forever!");
			NotifyRest(1, Player, Player.PlayerReplicationInfo.PlayerName@"is banned on this server forever");
		} else {
			if (BannedTill[i] < 0) {
				NotifyPlayer(0, Player, "Youre IP is banned on this server - you are on the global TOST ban list !");
				NotifyRest(1, Player, Player.PlayerReplicationInfo.PlayerName@"is banned on this server (global ban list)");
				XLog("Someone on the global ban list tried to connect to your server :"@Player.PlayerReplicationInfo.PlayerName@"IP:"@Player.GetPlayerNetworkAddress());
			} else {
				NotifyPlayer(0, Player, "Youre IP is banned on this server till"@ResolveTimeStamp(BannedTill[i]));
				NotifyRest(1, Player, Player.PlayerReplicationInfo.PlayerName@"is banned on this server till"@ResolveTimeStamp(BannedTill[i]));
			}
		}
		TO_GameBasics(Level.Game).Kick(Player);
	}
}

function	Tick(float Delta)
{
	local	int	i;
	local	string	IP;
	// check for players in queue
	for (i=0; i<32; i++)
	{
		if (PendingPlayers[i] != none && PendingPlayers[i].GetPlayerNetworkAddress() != "")
		{
			IP = NoPort(PendingPlayers[i].GetPlayerNetworkAddress());
			CheckForBan(PendingPlayers[i], IP);
			PendingPlayers[i] = none;
		}
	}
}

// * SETTINGS
function		GetSettings(TOSTPiece Sender)
{
	local int	Bits;

	Bits = 0;
	if (AutoUpdate)
		Bits += 1;

	Params.Param4 = String(Bits);
	SendAnswerMessage(Sender, 143);
}

function		SetSettings(TOSTPiece Sender, string Settings)
{
	local	int			i, j;
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

		AutoUpdate = ((i & 1) == 1);
	}
	SaveConfig();
}

// * EVENTS

function		EventInit()
{
	local	int	i, CurTime;

	// check ban periods
	CurTime = GetCurrentTimeStamp();
	for (i=0; i<250; i++)
	{
		if (((BannedTill[i] > 0) && (CurTime > BannedTill[i])) || ((BannedTill[i] < 0) && (CurTime > -BannedTill[i])))
		{
			BanIP[i]="";
			BannedTill[i]=0;
		}
	}
	// autoupdate
	if (AutoUpdate && (CurTime > LastUpdate))
	{
		Updater = spawn(class'TOSTBanListUpdate', self);
		Updater.Master = self;
		Updater.CheckForUpdate();
		LastUpdate = GetFutureTimeStamp(0,0,1,0,0);
	}
	SaveConfig();
	super.EventInit();
}

function 	EventPlayerConnect(Pawn Player)
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

defaultproperties
{
	bHidden=True

	PieceName="TOST Ban List"
	PieceVersion="0.5.0.0"
	ServerOnly=true

	BaseMessage=180

	AutoUpdate=False
	LastUpdate=0

	BanIP(0)=""
	BanIP(1)=""
	BanIP(2)=""
	BanIP(3)=""
	BanIP(4)=""
	BanIP(5)=""
	BanIP(6)=""
	BanIP(7)=""
	BanIP(8)=""
	BanIP(9)=""
	BanIP(10)=""
	BanIP(11)=""
	BanIP(12)=""
	BanIP(13)=""
	BanIP(14)=""
	BanIP(15)=""
	BanIP(16)=""
	BanIP(17)=""
	BanIP(18)=""
	BanIP(19)=""
	BanIP(20)=""
	BanIP(21)=""
	BanIP(22)=""
	BanIP(23)=""
	BanIP(24)=""
	BanIP(25)=""
	BanIP(26)=""
	BanIP(27)=""
	BanIP(28)=""
	BanIP(29)=""
	BanIP(30)=""
	BanIP(31)=""
	BanIP(32)=""
	BanIP(33)=""
	BanIP(34)=""
	BanIP(35)=""
	BanIP(36)=""
	BanIP(37)=""
	BanIP(38)=""
	BanIP(39)=""
	BanIP(40)=""
	BanIP(41)=""
	BanIP(42)=""
	BanIP(43)=""
	BanIP(44)=""
	BanIP(45)=""
	BanIP(46)=""
	BanIP(47)=""
	BanIP(48)=""
	BanIP(49)=""
	BanIP(50)=""
	BanIP(51)=""
	BanIP(52)=""
	BanIP(53)=""
	BanIP(54)=""
	BanIP(55)=""
	BanIP(56)=""
	BanIP(57)=""
	BanIP(58)=""
	BanIP(59)=""
	BanIP(60)=""
	BanIP(61)=""
	BanIP(62)=""
	BanIP(63)=""
	BanIP(64)=""
	BanIP(65)=""
	BanIP(66)=""
	BanIP(67)=""
	BanIP(68)=""
	BanIP(69)=""
	BanIP(70)=""
	BanIP(71)=""
	BanIP(72)=""
	BanIP(73)=""
	BanIP(74)=""
	BanIP(75)=""
	BanIP(76)=""
	BanIP(77)=""
	BanIP(78)=""
	BanIP(79)=""
	BanIP(80)=""
	BanIP(81)=""
	BanIP(82)=""
	BanIP(83)=""
	BanIP(84)=""
	BanIP(85)=""
	BanIP(86)=""
	BanIP(87)=""
	BanIP(88)=""
	BanIP(89)=""
	BanIP(90)=""
	BanIP(91)=""
	BanIP(92)=""
	BanIP(93)=""
	BanIP(94)=""
	BanIP(95)=""
	BanIP(96)=""
	BanIP(97)=""
	BanIP(98)=""
	BanIP(99)=""
	BanIP(100)=""
	BanIP(101)=""
	BanIP(102)=""
	BanIP(103)=""
	BanIP(104)=""
	BanIP(105)=""
	BanIP(106)=""
	BanIP(107)=""
	BanIP(108)=""
	BanIP(109)=""
	BanIP(110)=""
	BanIP(111)=""
	BanIP(112)=""
	BanIP(113)=""
	BanIP(114)=""
	BanIP(115)=""
	BanIP(116)=""
	BanIP(117)=""
	BanIP(118)=""
	BanIP(119)=""
	BanIP(120)=""
	BanIP(121)=""
	BanIP(122)=""
	BanIP(123)=""
	BanIP(124)=""
	BanIP(125)=""
	BanIP(126)=""
	BanIP(127)=""
	BanIP(128)=""
	BanIP(129)=""
	BanIP(130)=""
	BanIP(131)=""
	BanIP(132)=""
	BanIP(133)=""
	BanIP(134)=""
	BanIP(135)=""
	BanIP(136)=""
	BanIP(137)=""
	BanIP(138)=""
	BanIP(139)=""
	BanIP(140)=""
	BanIP(141)=""
	BanIP(142)=""
	BanIP(143)=""
	BanIP(144)=""
	BanIP(145)=""
	BanIP(146)=""
	BanIP(147)=""
	BanIP(148)=""
	BanIP(149)=""
	BanIP(150)=""
	BanIP(151)=""
	BanIP(152)=""
	BanIP(153)=""
	BanIP(154)=""
	BanIP(155)=""
	BanIP(156)=""
	BanIP(157)=""
	BanIP(158)=""
	BanIP(159)=""
	BanIP(160)=""
	BanIP(161)=""
	BanIP(162)=""
	BanIP(163)=""
	BanIP(164)=""
	BanIP(165)=""
	BanIP(166)=""
	BanIP(167)=""
	BanIP(168)=""
	BanIP(169)=""
	BanIP(170)=""
	BanIP(171)=""
	BanIP(172)=""
	BanIP(173)=""
	BanIP(174)=""
	BanIP(175)=""
	BanIP(176)=""
	BanIP(177)=""
	BanIP(178)=""
	BanIP(179)=""
	BanIP(180)=""
	BanIP(181)=""
	BanIP(182)=""
	BanIP(183)=""
	BanIP(184)=""
	BanIP(185)=""
	BanIP(186)=""
	BanIP(187)=""
	BanIP(188)=""
	BanIP(189)=""
	BanIP(190)=""
	BanIP(191)=""
	BanIP(192)=""
	BanIP(193)=""
	BanIP(194)=""
	BanIP(195)=""
	BanIP(196)=""
	BanIP(197)=""
	BanIP(198)=""
	BanIP(199)=""
	BanIP(200)=""
	BanIP(201)=""
	BanIP(202)=""
	BanIP(203)=""
	BanIP(204)=""
	BanIP(205)=""
	BanIP(206)=""
	BanIP(207)=""
	BanIP(208)=""
	BanIP(209)=""
	BanIP(210)=""
	BanIP(211)=""
	BanIP(212)=""
	BanIP(213)=""
	BanIP(214)=""
	BanIP(215)=""
	BanIP(216)=""
	BanIP(217)=""
	BanIP(218)=""
	BanIP(219)=""
	BanIP(220)=""
	BanIP(221)=""
	BanIP(222)=""
	BanIP(223)=""
	BanIP(224)=""
	BanIP(225)=""
	BanIP(226)=""
	BanIP(227)=""
	BanIP(228)=""
	BanIP(229)=""
	BanIP(230)=""
	BanIP(231)=""
	BanIP(232)=""
	BanIP(233)=""
	BanIP(234)=""
	BanIP(235)=""
	BanIP(236)=""
	BanIP(237)=""
	BanIP(238)=""
	BanIP(239)=""
	BanIP(240)=""
	BanIP(241)=""
	BanIP(242)=""
	BanIP(243)=""
	BanIP(244)=""
	BanIP(245)=""
	BanIP(246)=""
	BanIP(247)=""
	BanIP(248)=""
	BanIP(249)=""
}
