//----------------------------------------------------------------------------
// Project : TOST
// File    : TOSTServerMutator.uc
// Version : 1.2
// Author  : BugBunny/MadOnion
//----------------------------------------------------------------------------

class TOSTServerMutator expands Mutator config;

var() config float SecurityFrequency;	// How often should the server call the client
var() config float SecurityTolerance;	// How long before the client is overdue (in secs)
var() config int SecurityLevel;		// Actions performed on cheats : 0=None, 1=Kicked, 2=Kickban
var() config int MaxInitTries;		// How many times should we try to connect to the client
var() config bool UseTOSTLog;		// Create separate TOSTLog files.
var() config int ProtectionTime;	// How long does protection password last
var() config bool AllowOtherVoicePacks;	// Allow other voice packs
var() config bool RememberStats;	// Do a player backup during a map ?
var() config bool AllowHUDExtensions;	// allow the HUD extensions (showweapon/showteaminfo)
var() config string UsedPackages;	// which packages the server uses
var() config bool EnhVoteSystem;	// use enhanced voting system
var() config bool SecureFlashbang;      // use server side controlled flashbang

var() config bool bNoUpSwimming;

var bool zzbInitialized;		// Has the mutator been initialized

// ----------------------------------------------------

var PlayerPawn zzPlayerList[32];  	// Players who have been replicated to
var TOSTRI zzPlayerRIList[32];		// Quick access to their RI's
var TOSTReporter zzReporter;		// Used to log messages
var TOSTLog zzMyLog;			// The TOST Log
var TOSTMessageMutator zzNoSummon;	// The NoSummon Message Mutator
var TOSTFlashSpawnNotification zzFlash; // Point to the flash spawn notification

var string zzVersionStr;		// Holds the version code from VUC++
var string zzsMsg[13];
var string zzMsg[37];

var float zzProtectionCountDown;

// ----------------------------------------------------

struct PlayerBackup {
	var float zzTimestamp;
	var string zzPlayerName;
	var string zzIP;
	var int zzMoney;
	var int zzKills;
	var int zzDeaths;
	var int zzRound;
	var int zzPlayTime;
	var bool zzAlive;
};
var PlayerBackup Memory[50];

// New FilRip
// package data
struct PackData {
	var int		zzNames;
	var int		zzNameSpace;
	var int		zzImports;
	var int		zzExports;
	var int		zzGenerations;
	var int		zzLazy;
};
struct PackageData {
	var string		zzPkgName;
	var int			zzCount;
	var PackData	zzVersion[3];
};
var PackageData		zzPackages[200];
var int				zzPackageCount;
var string			zzServerPackages[20];
var int				zzServerPkgCount[20];
var int				zzSrvPkgLines;
var string	zzTOSTPackage;	// name of the TOST package
var string CheckMe;
// End new FilRip

// ==================================================================================
// ssLog - serverside logging
// ==================================================================================

function zzsrvLog(string s) {
	local Pawn p;

	if (zzMyLog != None)
	{
		zzMyLog.LogEventString(s);
		zzMyLog.FileFlush();
	}
	// Send an event about the cheater to messaging spectators
	for (p = Level.PawnList; p != None; p = p.NextPawn)
	{
		if (p.IsA('MessagingSpectator'))
			p.ClientMessage(zzMsg[0]@s, '');
	}
	Log(s);
}

function SetNoUpSwim()
{
	local ZoneInfo ZI;

	if (Level.Title~="RapidWaters][")
	{
		foreach AllActors(Class'ZoneInfo',ZI)
		{
			if ( (ZI.Location == vect(600.804199,-760.311768,-476.897766)) || (ZI.Location == vect(551.197632,-217.899994,-437.349152)) )
			{
				ZI.ZoneGravity=vect(288000.00,0.00,-25000.00);
			}
		}
	}
}

function zzDecryptStrings(string zzPassword)
{
	local string zzPermString;
	local int i, j, zzk;
	local string zzCrypt, zzPass, zzKey, zzPrevPlain, zzPlain, zzPlainString;

	zzPermString="[]()/&%$§'!=?+*#-_.,;:<>@ ";
	for (i=9; i>=0; i--)
		zzPermString=Chr(48+i)$zzPermString;
	for (i=25; i>=0; i--)
		zzPermString=Chr(97+i)$zzPermString;
	for (i=25; i>=0; i--)
		zzPermString=Chr(65+i)$zzPermString;
	zzPermString = zzPermString$zzPermString;

	zzPrevPlain="A";
	zzk=0;
	for (i=0; i<37; i++)
	{
		zzPlainString = "";
		for (j=0; j<Len(zzMsg[i]); j++)
		{
			zzk++;
			if (zzk > Len(zzPassword))
				zzk = 1;
			zzPass = Mid(zzPassword, zzk-1, 1);
			zzCrypt = Mid(zzMsg[i], j, 1);
			zzKey = Mid(Mid(zzPermString, InStr(zzPermString, zzPass), 88), InStr(zzPermString, zzCrypt), 1);
			zzPlain = Mid(Mid(zzPermString, InStr(zzPermString, zzPrevPlain), 88), InStr(zzPermString, zzKey), 1);
			zzPlainString = zzPlainString$zzPlain;
			zzPrevPlain = zzPlain;
		}
		zzMsg[i] = zzPlainString;
	}
}

function zzDecryptServerStrings(string zzPassword)
{
	local string zzPermString;
	local int i, j, zzk;
	local string zzCrypt, zzPass, zzKey, zzPrevPlain, zzPlain, zzPlainString;

	zzPermString="[]()/&%$§'!=?+*#-_.,;:<>@ ";
	for (i=9; i>=0; i--)
		zzPermString=Chr(48+i)$zzPermString;
	for (i=25; i>=0; i--)
		zzPermString=Chr(97+i)$zzPermString;
	for (i=25; i>=0; i--)
		zzPermString=Chr(65+i)$zzPermString;
	zzPermString = zzPermString$zzPermString;

	zzPrevPlain="A";
	zzk=0;
	for (i=0; i<13; i++)
	{
		zzPlainString = "";
		for (j=0; j<Len(zzsMsg[i]); j++)
		{
			zzk++;
			if (zzk > Len(zzPassword))
				zzk = 1;
			zzPass = Mid(zzPassword, zzk-1, 1);
			zzCrypt = Mid(zzsMsg[i], j, 1);
			zzKey = Mid(Mid(zzPermString, InStr(zzPermString, zzPass), 88), InStr(zzPermString, zzCrypt), 1);
			zzPlain = Mid(Mid(zzPermString, InStr(zzPermString, zzPrevPlain), 88), InStr(zzPermString, zzKey), 1);
			zzPlainString = zzPlainString$zzPlain;
			zzPrevPlain = zzPlain;
		}
		zzsMsg[i] = zzPlainString;
	}
}

// ===================================================================
// PostBeginPlay - Init Logs
// ===================================================================
function PostBeginPlay()
{
    local string zzPackage;

	Super.PostBeginPlay();

	zzDecryptStrings("BugBunny");
	zzDecryptServerStrings("MadOnion");

	// prevent the erasing of normal game password
	zzProtectionCountDown = -1.0;

	// Open the ToST log
	if (UseTOSTLog)
	{
		zzMyLog = spawn(class'TOSTLog');
	}

	if (zzMyLog != None)
		zzMyLog.StartLog();

	zzsrvLog(zzVersionStr$zzMsg[1]);

	zzNoSummon = Spawn(class'TOSTMessageMutator',self);
	Level.Game.RegisterMessageMutator(zzNoSummon);

	zzReporter = Spawn(class'TOSTReporter',self);
	if (zzReporter != None)
	{
		zzReporter.zzTOST = self;
	}
	else
		zzsrvLog(zzMsg[0]@zzMsg[3]);

	if (SecureFlashbang)
		zzFlash = Spawn(class'TOSTFlashSpawnNotification');

	xxCollectPackageData();
	zzPackage = Caps(String(Self.Class));
	zzTOSTPackage = Left(zzPackage, InStr(zzPackage, "."));
//	log("TOST Package : "$zzTOSTPackage);
	SetTimer(1, true);

	if (bNoUpSwimming) SetNoUpSwim();
}

// ==================================================================================
// OnGameEnd - actions when end of a game (mapchange etc..)
// ==================================================================================

function OnGameEnd()
{
	// close the log
	zzMyLog.StopLog();
	zzMyLog.Destroy();
	zzMyLog = None;

	// remove protection password
	if (zzProtectionCountDown >= 0.0)
	{
		Level.ConsoleCommand(zzMsg[4]);
		Level.Game.BroadcastMessage(zzMsg[5]);
	}

	// save settings to ini
	zzSaveTOSTConfig();
}

// ==================================================================================
// PlayerBackup functions
// ==================================================================================

function string zzIPOnly(string zzIP)
{
	local int zzi;

	zzi = InStr(zzIP, ":");

	if (zzi != -1)
		return Left(zzIP, zzi);
	else
		return zzIP;
}

function int zzFindBPIndexByName(string zzs)
{
	local int zzi;
	local string zzcs;

	zzcs = Caps(zzs);

	while (zzi<50 && InStr(Memory[zzi].zzPlayerName, zzcs) != 0)
		zzi++;
	if (zzi==50)
		zzi = -1;
	return zzi;
}

function int zzFindBPIndexByIP(string zzIP, bool zzReconnect)
{
	local int zzi;
	local string zzIPo;

	zzIPo = zzIPOnly(zzIP);
	while (zzi<50 && (zzIPo != Memory[zzi].zzIP || (zzReconnect && Memory[zzi].zzAlive)))
		zzi++;
	if (zzi==50)
		zzi = -1;
	return zzi;
}

function int zzFindBPIndex(string zzs, string zzIP, bool zzReconnect)
{
	local int i, j;
	i = zzFindBPIndexByIP(zzIP, zzReconnect);
	j = zzFindBPIndexByName(zzs);
	if (i==-1) 	// no match by IP -> match by name
		return j;
	// match by IP or match by IP & Name, same slot
	if ((j==-1) || (j==i))
		return i;

	// match by IP & name, different slot
	// check for shared connection ("name slot" has same IP than "IP slot")
	if (Memory[j].zzIP == Memory[i].zzIP)
		return j;

	return i;
}

function int zzFindOldestBP()
{
	local int i, j;
	j = 0;
	for (i=0; i<50; i++)
	{
		if (Memory[i].zzTimestamp < Memory[j].zzTimestamp)
		{
			j=i;
		}
	}
	return j;
}

function zzEraseStats(string zzs)
{
	local int i;

	i = zzFindBPIndexByName(zzs);
	if (i != -1) {
		Memory[i].zzIP = "";
		Memory[i].zzPlayerName = "";
		Memory[i].zzMoney = 0;
		Memory[i].zzDeaths = 0;
		Memory[i].zzKills = 0;
		Memory[i].zzRound = -1;
		Memory[i].zzAlive = false;
		Memory[i].zzTimestamp = 0;
		Memory[i].zzPlayTime = 0;
	}
}

// ==================================================================================
// Timer - do some no-priority stuff
// ==================================================================================

function Timer()
{
	local int zzi, zzVotesNeeded, zzVoteCount, zzNumPlayers;
	local Pawn zzP;
	local s_Player zzVP;
	local TO_PRI zzPRI;

	zzi=0;
	while (zzi<50) {
		Memory[zzi++].zzAlive = False;
	}

	zzNumPlayers = TO_GameBasics(Level.Game).NumPlayers;
	zzVotesNeeded = Max(Min(zzNumPlayers - 2, zzNumPlayers / 2), 1);

	for( zzP=Level.PawnList; zzP!=None; zzP=zzP.NextPawn )
	{
		if ( ( (zzP.IsA('PlayerPawn')) && (!zzp.IsA('Spectator')) && NetConnection(PlayerPawn(zzP).Player) != None && (!zzP.IsA('MessagingSpectator'))))
		{

			// update Player Backup
			zzi = zzFindBPIndex(zzP.PlayerReplicationInfo.PlayerName, PlayerPawn(zzP).GetPlayerNetworkAddress(), false);
			if (zzi != -1) {
				Memory[zzi].zzPlayerName = Caps(zzP.PlayerReplicationInfo.PlayerName);
				Memory[zzi].zzMoney = s_Player(zzP).Money;
				Memory[zzi].zzKills = zzP.PlayerReplicationInfo.Score;
				Memory[zzi].zzDeaths = zzP.PlayerReplicationInfo.Deaths;
				Memory[zzi].zzTimestamp = Level.TimeSeconds;
				if (TO_SysPlayer(zzP).StartMenu == None)
					Memory[zzi].zzRound = s_GameReplicationInfo(Level.Game.GameReplicationInfo).RoundNumber;
				Memory[zzi].zzAlive = true;
				Memory[zzi].zzPlayTime = Level.TimeSeconds - zzP.PlayerReplicationInfo.StartTime;
			}
			// keep commander alive
			ModifyPlayer(zzP);

			// vote system extension
			zzVoteCount = 0;
			zzPRI = TO_PRI(zzP.PlayerReplicationInfo);
			for (zzi=0; zzi<48; zzi++)
			{
				if (zzPRI.VoteFrom[zzi] != None)
				{
					if (PlayerPawn(zzP) != None && PlayerPawn(zzP).bAdmin) {
						zzPRI.VoteFrom[zzi] = None;
					} else {
						zzVoteCount++;
					}
				}
			}
			if (EnhVoteSystem) {
				if (zzVoteCount > (zzVotesNeeded + zzPRI.Score)) {
					foreach allactors(class's_Player', zzVP)
						zzVP.ReceiveLocalizedMessage(class's_MessageVote', 1, zzPRI);

					TO_GameBasics(Level.Game).TempKickBan(s_Player(zzP), "Voted out of the game.");
				}
			}
		}
	}
}

// ==================================================================================
// Tick - The work horse on the server side.  Each time the mutator will check the
// game for new players.  If one exists.. it will add him to the list and replicate
// a ToSTRI to him.
// ==================================================================================

function Tick(float zzDeltaTime)
{
	local int zzi,zzj;
	local Pawn zzP;
	local TOSTRI zzRI;

	if ((Level.Game.bGameEnded || Level.NextSwitchCountdown < 0.5) && zzMyLog != None)
	{
		OnGameEnd();
	}

	if (zzProtectionCountDown >= 0.0)
	{
		zzProtectionCountDown -= zzDeltaTime;
		if (zzProtectionCountDown < 0.0) {
			Level.ConsoleCommand(zzMsg[4]);
			Level.Game.BroadcastMessage(zzMsg[6]);
		}
	}

	// Clean up after player who have left.

	for (zzI=0;zzI<32;zzI++)
	{
		zzP = zzPlayerList[zzi];
		zzRI = zzPlayerRIList[zzi];
		if ( ( (zzP == None) || (zzP.bDeleteMe) ) && (zzRI!=None) )
		{
			zzPlayerList[zzI] = None;
			zzPlayerRIList[zzI].Destroy();
			zzPlayerRIList[zzI] = None;
			zzP = None;
		}
	}

	for( zzP=Level.PawnList; zzP!=None; zzP=zzP.NextPawn )
	{
		if ( ( (zzP.IsA('PlayerPawn')) && (!zzp.IsA('Spectator')) && NetConnection(PlayerPawn(zzP).Player) != None && (!zzP.IsA('MessagingSpectator'))))
		{
			if (zzFindPIndexFor(zzP) == -1)
			{
				// Add new player

				zzsrvLog("["$zzP.PlayerReplicationInfo.PlayerName$"] "$zzMsg[24]);

				zzi = 0;
				while ( (zzi<32) && (zzPlayerList[zzi]!=None) )
				  zzi++;

				zzPlayerList[zzi] = PlayerPawn(zzP);

				zzRI = Spawn(class'TOSTRI', zzP);
				if (zzRI==None)
				{
					zzsrvLog(zzMsg[25]);
				}
				else
				{
					zzPlayerRIList[zzi] = zzRI;
					// decrypt the serverside strings only once and "replicate" them here
					for (zzi=0; zzi<13; zzi++)
					{
						zzRI.zzsMsg[zzi] = zzsMsg[zzi];
					}

					zzRI.zzTOST = self;
					zzRI.zzReporter = zzReporter;
					zzRI.zzSecurityLevel = SecurityLevel;
					zzRI.zzAllowHUD = AllowHUDExtensions;
					zzRI.zzVoicePackFix = !AllowOtherVoicePacks;
					zzRI.zzTimeOutGrace = Level.TimeSeconds + (SecurityFrequency * Level.TimeDilation * 3);
				}

				ModifyPlayer(zzP);
				zzSetupCommander(zzP.FindInventoryType(class'TOSTCommander'), zzP);

				// check for Player Backup
				zzi = zzFindBPIndex(zzP.PlayerReplicationInfo.PlayerName, PlayerPawn(zzP).GetPlayerNetworkAddress(), true);
				if (zzi != -1) {
					// reconnect
					Memory[zzi].zzTimestamp = Level.TimeSeconds;
					Memory[zzi].zzPlayerName = Caps(zzP.PlayerReplicationInfo.PlayerName);
					Memory[zzi].zzIP = zzIPOnly(PlayerPawn(zzP).GetPlayerNetworkAddress());
					if (RememberStats) {
						zzsrvlog(zzMsg[30]$zzP.PlayerReplicationInfo.PlayerName);
						if (Memory[zzi].zzRound == s_GameReplicationInfo(Level.Game.GameReplicationInfo).RoundNumber) {
							s_Player(zzP).Money = Memory[zzi].zzMoney - 1000;
						} else {
							s_Player(zzP).Money = Memory[zzi].zzMoney;
						}
						zzP.PlayerReplicationInfo.Score = Memory[zzi].zzKills;
						zzP.PlayerReplicationInfo.Deaths = Memory[zzi].zzDeaths;
						zzP.PlayerReplicationInfo.StartTime = Level.TimeSeconds - Memory[zzi].zzPlayTime;
					}
					if (TO_SysPlayer(zzP).StartMenu == None)
						Memory[zzi].zzRound = s_GameReplicationInfo(Level.Game.GameReplicationInfo).RoundNumber;
				} else {
					// new
					zzi = zzFindOldestBP();
					Memory[zzi].zzTimestamp = Level.TimeSeconds;
					Memory[zzi].zzPlayerName = Caps(zzP.PlayerReplicationInfo.PlayerName);
					Memory[zzi].zzIP = zzIPOnly(PlayerPawn(zzP).GetPlayerNetworkAddress());
					Memory[zzi].zzMoney = s_Player(zzP).Money;
					Memory[zzi].zzKills = zzP.PlayerReplicationInfo.Score;
					Memory[zzi].zzDeaths = zzP.PlayerReplicationInfo.Deaths;
					if (TO_SysPlayer(zzP).StartMenu == None)
						Memory[zzi].zzRound = s_GameReplicationInfo(Level.Game.GameReplicationInfo).RoundNumber;
					Memory[zzi].zzPlayTime = 0;
				}

			}
		}

	}
} // Tick

// ==================================================================================
// ModifyPlayer - Give every player a Commander item
// ==================================================================================
function ModifyPlayer(Pawn zzOther)
{
	local Inventory zzInv;

	zzInv = zzOther.FindInventoryType(class'TOSTCommander');
	if ( zzInv == None )
	{
		zzInv = Spawn(class'TOSTCommander', zzOther);
		if( zzInv != None )
		{
			zzInv.GiveTo(zzOther);
			zzInv.bHeldItem = True;
			zzSetupCommander(zzInv, zzOther);
		}
	}
}

function zzSetupCommander(Inventory zzInv, Pawn zzOther)
{
	local int zzi;

	zzi = zzFindPIndexFor(zzOther);
	if (zzi != -1)
		TOSTCommander(zzInv).zzMaster = zzPlayerRIList[zzi];
}

// ==================================================================================
// FindPIndexFor - Finds the zzPlayerList Index for a pawn.
// ==================================================================================

function int zzFindPIndexFor(pawn zzP)
{
	local int zzi;

	for (zzi=0;zzi<32;zzi++)
	{
		if ( (zzPlayerList[zzi]!=None) && (zzPlayerList[zzi]==zzP) )
			return zzi;
	}

	return -1;

}

// =================================================================================
// FindPIndexByPID - Find the zzPlayerList Index for a pawn by the PlayerID
// =================================================================================

function int zzFindPIndexByPID(int zzPID)
{
	local int zzi;

	for (zzi=0;zzi<32;zzi++)
	{
		if ( (zzPlayerList[zzi]!=None) && (zzPlayerList[zzi].PlayerReplicationInfo != None) && (zzPlayerList[zzi].PlayerReplicationInfo.PlayerID == zzPID) )
			return zzi;
	}

	return -1;
}

// ==================================================================================
// TKKickBan - kick TK's
// ==================================================================================

exec function zzTKKickBan(int zzpid)
{
	local Pawn zzaPawn;
	local string zzIP;

	for( zzaPawn=Level.PawnList; zzaPawn!=None; zzaPawn=zzaPawn.NextPawn )
		if (zzaPawn.bIsPlayer && zzaPawn.PlayerReplicationInfo.PlayerID == zzpid && (PlayerPawn(zzaPawn)==None || NetConnection(PlayerPawn(zzaPawn).Player)!=None ) )
		{
			zzIP = PlayerPawn(zzaPawn).GetPlayerNetworkAddress();
			if ( Level.Game.CheckIPPolicy(zzIP) )
			{
				s_SWATGame(Level.Game).KickBan(PlayerPawn(zzaPawn), zzMsg[21]@GetHumanName());
				Level.Game.BroadcastMessage(zzMsg[22]@zzaPawn.GetHumanName()@zzMsg[23]);
			}
			return;
		}
}

// ==================================================================================
// LCTPlayer - return the player in the designated team that has logged on last ...
// ==================================================================================

function Pawn zzLCTPlayer(int zzteam)
{
	local Pawn zzckPawn, zzclPawn;

	// Initialize Lists

	zzckPawn=Level.Pawnlist;
	zzclPawn=None;

	// find first human Player on the designated team in the list

	while ( zzclPawn == None ) {
		if	(	zzckPawn.IsA('s_Player')
			&&	zzckPawn.PlayerReplicationInfo.Team == zzteam )
		{
			zzclPawn = zzckPawn;
		}
		if (zzckPawn.NextPawn != None) {
			zzckPawn = zzckPawn.NextPawn;
		}
	}

 	// find and return pointer to the player on the designated team that has logged on last

	for( zzckPawn=Level.PawnList; zzckPawn!=None; zzckPawn=zzckPawn.NextPawn ) {
		if	(	zzckPawn.IsA('s_Player')
			&&	zzckPawn.PlayerReplicationInfo.Team == zzteam
			&& 	zzckPawn.PlayerReplicationInfo.StartTime > zzclPawn.PlayerReplicationInfo.StartTime)
		{
			zzclPawn = zzckPawn;
		}
	}
	return zzclPawn;
}

// ==================================================================================
// Client commands
// ==================================================================================

function zzTOSTInfo(PlayerPawn zzSender)
{
	local String zzGamePassword;

	zzSender.ClientMessage(zzMsg[15]$zzVersionStr);
	zzSender.ClientMessage(zzMsg[16]$RememberStats);
	zzSender.ClientMessage(zzMsg[2]$AllowHUDExtensions);
	zzSender.ClientMessage(zzMsg[18]$SecurityLevel$" - "$SecurityFrequency$"s");
	if (zzSender.bAdmin)
		zzSender.ClientMessage(zzMsg[17]$UseTOSTLog);
	if (zzProtectionCountDown > 0.0)
	{
		if (zzSender.bAdmin) {
			zzGamePassword = Level.ConsoleCommand(zzMsg[8]);
			zzSender.ClientMessage(zzMsg[19]$zzMsg[20]$zzGamePassword$")");
		} else {
			zzSender.ClientMessage(zzMsg[19]);
		}
	}
}

function zzToggleTeamInfo(PlayerPawn zzSender)
{
	local int zzi;
	zzi = zzFindPIndexFor(zzSender);
	if (zzi >= 0) {
		zzPlayerRIList[zzi].zzToggleTeamInfo();
	}
}

function zzToggleWeaponInfo(PlayerPawn zzSender)
{
	local int zzi;
	zzi = zzFindPIndexFor(zzSender);
	if (zzi >= 0) {
		zzPlayerRIList[zzi].zzToggleWeaponInfo();
	}
}

function zzMkTeams(PlayerPawn zzSender)
{
	local int zzTcount, zzTerrTeamCount, zzSwatTeamCount;
	local Pawn zzaPawn;
	local PlayerReplicationInfo zzPRI;

	if (zzSender.bAdmin) {
		zzTerrTeamCount = 0;
		zzSwatTeamCount = 0;
		foreach AllActors(class'PlayerReplicationInfo', zzPRI) // get number of players per team
		{
			if (zzPRI.Team == 0) {
				zzTerrTeamCount++;
			} else {
				if (zzPRI.Team == 1) {
					zzSwatTeamCount++;
				}
			}
		}
		zzTCount = (zzTerrTeamCount - zzSwatTeamCount)/2;
		if (zzTCount > 0)	{ // in case there are more player on Terror
			do {
				zzaPawn = zzLCTPlayer(0);
				Level.Game.ChangeTeam(zzaPawn, 1);
				Level.Game.AcceptInventory(zzaPawn);
				Level.Game.addDefaultInventory(zzaPawn);
				zzTcount--;
			} until (zzTcount == 0)
			Level.Game.BroadcastMessage(zzMsg[11]);
		} else {
			if (zzTCount < 0) { // in case there are more players on SF
				do {
					zzaPawn =zzLCTPlayer(1);
					Level.Game.ChangeTeam(zzaPawn, 0);
					Level.Game.AcceptInventory(zzaPawn);
					Level.Game.addDefaultInventory(zzaPawn);
					zzTcount++;
				} until (zzTcount == 0)
				Level.Game.BroadcastMessage(zzMsg[11]);
			} else {
				zzSender.ClientMessage(zzMsg[10]);
			}
		}
	} else {
		zzSender.ClientMessage(zzMsg[9]);
	}
}

function zzKickTK(PlayerPawn zzSender)
{
	local Pawn zzaPawn;

	if (zzSender.bAdmin) {
		for(zzaPawn=Level.PawnList; zzaPawn!=None; zzaPawn=zzaPawn.NextPawn )
		{
			// scan for player pawns (not admins) with score lower than 0 and kick them
			if (zzaPawn.isA('s_Player') && zzaPawn.PlayerReplicationInfo.Score < 0 && !PlayerPawn(zzaPawn).bAdmin)
			{
				zzTKKickBan(zzaPawn.PlayerReplicationInfo.PlayerID);
			}
		}
	} else {
		zzSender.ClientMessage(zzMsg[9]);
	}
}

function zzProtectSrv(PlayerPawn zzSender)
{
	local int zzi,zzj;
	local String zzGamePassword;

	if (zzSender.bAdmin) {
		zzGamePassword = Level.ConsoleCommand(zzMsg[8]); 	// check if password is on
		if (zzGamePassword == "") {			// if password is turned on, delete it else set it
			// get a random password
			for (zzj=0; zzj<6; zzj++)
			{
				zzi = Rand(26);
				zzGamePassword = zzGamePassword$Chr(zzi+65);
			}
			Level.ConsoleCommand(zzMsg[4]$" "$zzGamePassword);
			Level.Game.BroadcastMessage(zzMsg[7]);
			zzProtectionCountDown = ProtectionTime;
			zzSender.ClientMessage(zzMsg[12]$zzGamePassword$zzMsg[13]$ProtectionTime$zzMsg[14]);
		} else {
			zzProtectionCountDown = -1.0;
			Level.ConsoleCommand(zzMsg[4]);
			Level.Game.BroadcastMessage(zzMsg[5]);
		}
	} else {
		zzSender.ClientMessage(zzMsg[9]);
	}
}

function zzXKick(PlayerPawn zzMyPlayer, coerce string s)
{
	if ( !zzMyPlayer.bAdmin )
		return;

	zzEraseStats(s);
	zzMyPlayer.Kick(s);
}

function zzXPKick(PlayerPawn zzMyPlayer, int PID)
{
	local Pawn aPawn;

	if ( !zzMyPlayer.bAdmin )
		return;

	for ( aPawn=Level.PawnList; aPawn!=None; aPawn=aPawn.NextPawn )
		if
		(	aPawn.bIsPlayer
			&&	aPawn.PlayerReplicationInfo.PlayerID == pid
			&&	(PlayerPawn(aPawn)==None || NetConnection(PlayerPawn(aPawn).Player)!=None ) )
		{
			zzEraseStats(aPawn.PlayerReplicationInfo.PlayerName);
			s_Player(zzMyPlayer).PKick(PID);
			return;
		}

}

function zzSaveTOSTConfig()
{
	class'TOSTServerMutator'.static.StaticSaveConfig();
}

// ==================================================================================
// Mutate - Accepts commands from the users
// ==================================================================================

function Mutate(string zzMutateString, PlayerPawn zzSender)
{
	local String zzms;
	local Inventory zzInv;

	zzms = Caps(zzMutateString);

	// Return info about TOST
	if (zzms ~= zzMsg[31])
	{
		zzTOSTInfo(zzSender);
	}

	// Toggle team info
	if (zzms ~= zzMsg[32])
	{
		zzToggleTeamInfo(zzSender);
	}

	// Toggle weapon info
	if (zzms ~= zzMsg[33])
	{
		zzToggleWeaponInfo(zzSender);
	}

	// Make teams
	if (zzms ~= zzMsg[34])
	{
		zzMkTeams(zzSender);
	}

	// Kick all TK's
	if (zzms ~= zzMsg[35])
	{
		zzKickTK(zzSender);
	}

	// Protect servers from quickly zzIP changing lamers by setting a random password on the server
	if (zzms ~= zzMsg[36])
	{
		zzProtectSrv(zzSender);
	}

	if ( NextMutator != None )
		NextMutator.Mutate(zzMutateString, zzSender);

} // Process the mutate commands

// ==================================================================================
// Destroyed - Shut down the log
// ==================================================================================
event Destroyed()
{
	if (zzMyLog != None)
	{
		zzMyLog.StopLog();
		zzMyLog.Destroy();
		zzMyLog = None;
	}

	Super.Destroyed();
}

// New stuff from FilRip
// code from TOST 3.0

// * CollectPackageData - collect all data for packages
function xxCollectPackageData()
{
	local string	zzUsedPackages, zzPackage, zzPkgName, zzTOSTPkg;

	zzUsedPackages = Self.ConsoleCommand("OBJ LINKERS");

 	zzPackage = xxParsePackage(zzUsedPackages);
	zzSrvPkgLines = 0;
	while (zzPackage != "")
	{
		zzPkgName = xxParseLine(zzPackage, zzPackageCount);
		zzPackage = xxParsePackage(zzUsedPackages);
		if (zzPkgName != "" && Caps(zzPkgName) != zzTOSTPackage)
		{
			if (zzPackageCount > zzSrvPkgLines*20) {
				zzSrvPkgLines++;
				zzServerPackages[zzSrvPkgLines-1] = zzPkgName;
				zzServerPkgCount[zzSrvPkgLines-1] = 1;
			} else {
				zzServerPackages[zzSrvPkgLines-1] = zzServerPackages[zzSrvPkgLines-1]$";"$zzPkgName;
				zzServerPkgCount[zzSrvPkgLines-1] = zzServerPkgCount[zzSrvPkgLines-1] + 1;
			}
		}
	}
}

// * ParsePackage - determines the package name
function string xxParsePackage(out string zzUsedPackages)
{
	local int zzPos;
	local string zzPackage;

	zzPos = instr(zzUsedPackages,".u");
	if (zzPos != -1)
	{
		zzPackage = left(zzUsedPackages, zzPos);
		zzUsedPackages = mid(zzUsedPackages, zzPos+1);
	}
	else
	{
		zzPackage = zzUsedPackages;
		zzUsedPackages = "";
	}
	return zzPackage;
}

// * ParseLine - Gets all the values of 1 full line from the obj linker
function string xxParseLine(string zzpackage, out int zzPackageCnt)
{
	local int zzPackageNo, zzSubNo, zzI;
	local string zzPackageName;
	local PackData zzTestData;

	zzPackageName = xxParsePart(zzpackage,"(Package ",")");
	// valid package name ?
	if (zzPackageName == "")
		return zzPackageName;

	// disallowed package ?
/*	if (InStr(Caps(";"$DisallowPackages$";"), Caps(";"$zzPackageName$";")) != -1)
	{
		// perform dummy parsing
		zzTestData.zzNames = int(xxParsePart(zzpackage,"="," "));
		zzTestData.zzNameSpace = int(xxParsePart(zzpackage,"/","K"));
		zzTestData.zzImports = int(xxParsePart(zzpackage,"="," "));
		zzTestData.zzExports = int(xxParsePart(zzpackage,"="," "));
		zzTestData.zzGenerations = int(xxParsePart(zzpackage,"="," "));
		zzTestData.zzLazy = int(xxParsePart(zzpackage,"="," "));

		zzPackageName = "";

		return zzPackageName;

	} else {
        */
		// already have a version of this package ?
		zzPackageNo = xxGetPackageData(zzPackageName);
		if (zzPackageNo == -1) {
			// no
			zzPackageNo = zzPackageCnt;
			zzPackageCnt++;
			zzSubNo = 0;
			zzPackages[zzPackageNo].zzPkgName = zzPackageName;
			zzPackages[zzPackageNo].zzCount = 1;
		} else {
			// yes
			zzSubNo = zzPackages[zzPackageNo].zzCount;
			zzPackageName = "";
		}
		zzTestData.zzNames = int(xxParsePart(zzpackage,"="," "));
		zzTestData.zzNameSpace = int(xxParsePart(zzpackage,"/","K"));
		zzTestData.zzImports = int(xxParsePart(zzpackage,"="," "));
		zzTestData.zzExports = int(xxParsePart(zzpackage,"="," "));
		zzTestData.zzGenerations = int(xxParsePart(zzpackage,"="," "));
		zzTestData.zzLazy = int(xxParsePart(zzpackage,"="," "));
		if (zzPackageName != "") {
			// add new (first) version
			zzPackages[zzPackageNo].zzVersion[zzSubNo] = zzTestData;
		} else {
			// test for redundant data
			for (zzI=0; zzI<zzSubNo; zzI++)
				if ((zzPackages[zzPackageNo].zzVersion[zzI].zzNames - zzPackages[zzPackageNo].zzVersion[zzI].zzGenerations == zzTestData.zzNames - zzTestData.zzGenerations)
				   && zzPackages[zzPackageNo].zzVersion[zzI].zzImports == zzTestData.zzImports
				   && zzPackages[zzPackageNo].zzVersion[zzI].zzExports == zzTestData.zzExports)
				{
					return zzPackageName;
				}
			// add new version
			zzPackages[zzPackageNo].zzVersion[zzSubNo] = zzTestData;
			zzPackages[zzPackageNo].zzCount = zzPackages[zzPackageNo].zzCount + 1;
		}
		return zzPackageName;
//	}
}

// * ParsePart - Grabs the different potions of an obj linker entry
function string xxParsePart(out string zzpackage, string zzbegin, string zzend)
{
	local int zzpos;
	local string zzpart;

	zzpos = Instr(zzpackage,zzbegin)+Len(zzbegin);
	zzpackage = Mid(zzpackage, zzpos); //shave off beginning
	zzpos = Instr(zzpackage,zzend);
	zzpart = Left(zzpackage,zzpos); //get the token until the end
	zzpackage = Mid(zzpackage, zzpos+Len(zzend)); //shave off token and end
	return zzpart;
}
// ==================================================================================
// UCRC
// ==================================================================================

// * GetPackageVersionCount - returns number of versions for the specified package
function int xxGetPackageVersionCount(int zzPackageID)
{
	return zzPackages[zzPackageID].zzCount;
}

// * GetPackageVersionCount - returns number of versions for the specified package
function string xxGetPackageName(int zzPackageID)
{
	return zzPackages[zzPackageID].zzPkgName;
}

// * GetPackageData... - returns certain package data values
function int xxGetPackageDataNames(int zzPackageID, int zzSubID)
{
	return zzPackages[zzPackageID].zzVersion[zzSubID].zzNames;
}
function int xxGetPackageDataNameSpace(int zzPackageID, int zzSubID)
{
	return zzPackages[zzPackageID].zzVersion[zzSubID].zzNameSpace;
}
function int xxGetPackageDataImports(int zzPackageID, int zzSubID)
{
	return zzPackages[zzPackageID].zzVersion[zzSubID].zzImports;
}
function int xxGetPackageDataExports(int zzPackageID, int zzSubID)
{
	return zzPackages[zzPackageID].zzVersion[zzSubID].zzExports;
}
function int xxGetPackageDataGenerations(int zzPackageID, int zzSubID)
{
	return zzPackages[zzPackageID].zzVersion[zzSubID].zzGenerations;
}
function int xxGetPackageDataLazy(int zzPackageID, int zzSubID)
{
	return zzPackages[zzPackageID].zzVersion[zzSubID].zzLazy;
}

// * GetPackageData - find package entry
function int xxGetPackageData(string zzPkgName)
{
	local int	zzI;

	for (zzI=0; zzI<zzPackageCount; zzI++)
	{
		if (zzI >= 200)
			break;
		if (Caps(zzPkgName) == Caps(zzPackages[zzI].zzPkgName))
		{
			return zzI;
		}
	}
	return -1;
}

// * GetCRCString - get CRC string of a single package
function string xxGetCRCString(int zzPackageID, int zzSubID)
{
	return (zzPackages[zzPackageID].zzPkgName@zzPackages[zzPackageID].zzVersion[zzSubID].zzNames@zzPackages[zzPackageID].zzVersion[zzSubID].zzNameSpace@
		zzPackages[zzPackageID].zzVersion[zzSubID].zzImports@zzPackages[zzPackageID].zzVersion[zzSubID].zzExports@zzPackages[zzPackageID].zzVersion[zzSubID].zzGenerations@
		zzPackages[zzPackageID].zzVersion[zzSubID].zzLazy);
}

// End new stuff from FilRip
/*
     zzVersionStr="TOST v1.2"

     zzsMsg(0)="(C)opyright 2002 TOST Team - so you finally decoded all the strings - congratulations"
     zzsMsg(1)="ACTORRESETTER;BOTPACK;CORE;ENGINE;EDITOR;FIRE;UTSERVERADMIN;UWEB;UWINDOW;IPDRV;IPSERVER;UBROWSER;UMENU;UNREALI;UNREALSHARE;UTBROWSER;UTMENU"
     zzsMsg(2)="S_SWAT;TODATAS;TODECOS;TOMODELS;TOPMODELS;TOSYSTEM"
     zzsMsg(3)="(no longer used)"
     zzsMsg(4)="SelfTest failed (ErrorCode : "
     zzsMsg(5)="hacking TOST"
     zzsMsg(6)="Internal checksum test failed (CheckSum : "
     zzsMsg(7)="Some tests did not take place on client"
     zzsMsg(8)="Voice"
     zzsMsg(9)="CheckTimeStamp failed"
     zzsMsg(10)="Suspicious RootWindow detected : "
     zzsMsg(11)="using a suspicious RootWindow : "
     zzsMsg(12)="TOST failing on self test - please reconnect"

     zzMsg(0)="[TOST]"
     zzMsg(1)=" loaded..."
     zzMsg(2)="HUD extensions avaiable :"
     zzMsg(3)="Get ready for a lot of errors, can't spawn Reporter"
     zzMsg(4)="set engine.gameinfo GamePassword"
     zzMsg(5)="TOST: Password protection has been removed ..."
     zzMsg(6)="TOST: Password protection has been automatically removed ..."
     zzMsg(7)="TOST: Server has been password protected ..."
     zzMsg(8)="get engine.gameinfo GamePassword"
     zzMsg(9)="Insufficient privileges in order to perform this operation!"
     zzMsg(10)="TOST: Teams are ok! No action taken ..."
     zzMsg(11)="TOST: Admin has forced even teams ..."
     zzMsg(12)="Password is '"
     zzMsg(13)="' for "
     zzMsg(14)=" seconds"
     zzMsg(15)="This server is running "
     zzMsg(16)="Backup Players : "
     zzMsg(17)="Uses Log : "
     zzMsg(18)="Security Level : "
     zzMsg(19)="Server is currently protected"
     zzMsg(20)=" (Password : "
     zzMsg(21)="Teamkiller banned by TOST:"
     zzMsg(22)="TOST: Admin has kickbanned"
     zzMsg(23)="for Teamkilling!"
     zzMsg(24)="Spawning TOST Replication Info"
     zzMsg(25)="Critical Error: TOSTRI = None"
     zzMsg(26)="TOST : What do we have here ?! "
     zzMsg(27)=" tries to clean his stats... tststs"
     zzMsg(28)="TOST : Welcome back "
     zzMsg(29)=" ! Hope you have a more stable connection this time..."
     zzMsg(30)="TOST : Reconnect - recovering old values for "
     zzMsg(31)="TOSTINFO"
     zzMsg(32)="SHOWTEAMINFO"
     zzMsg(33)="SHOWWEAPON"
     zzMsg(34)="MKTEAMS"
     zzMsg(35)="KICKTK"
     zzMsg(36)="PROTECTSRV"
*/

defaultproperties
{
	MaxInitTries=15
	SecurityLevel=1
	SecurityFrequency=5
	SecurityTolerance=20
	ProtectionTime=120
	UseTOSTLog=True
	AllowOtherVoicePacks=False
	RememberStats=True
	AllowHUDExtensions=True
	UsedPackages=""
	EnhVoteSystem=True
	SecureFlashbang=True
     zzVersionStr="TOST v1.3F"
     zzsMsg(0)="0Aixy]po?]'cQ0wzV;2-yi%8!?U)6LsIn0)b,51k [!X_3u9)]6s*)wLiy4rG3uo,3'do]#9+3§5%3nmHz)=2"
     zzsMsg(1)="Ky/')79]o]x9+k,[7si-§r;95jn@'0*2tm7+&§$0f70>xxMw1i[.t!50]s25A94uv?z[&x>5a[4(*]v]9zjB/q a.d)=§38[f?p%'/w+v0k!=48+v0k!=/]q'jnO9pCu[sjBn>=qu54"
     zzsMsg(2)="?j@-b=X?'z4Fe!Y?'z8!96Y?'89]y93ZN58'zrx4:m<$18qy9§"
     zzsMsg(3)="/$vq]3$&sjw2-?'8vB3v1il9T"
     zzsMsg(4)=".99ql *8c,x40$9dz#Fwu_VJ]yXs1"
     zzsMsg(5)="W39;v7pQI5]+"
     zzsMsg(6)="m>2iB6u>L:1u?§&*pPGiC]NSs[zq+gkM.zu56Czjt6"
     zzsMsg(7)="&'?2cgi%xwfE($TGx2eUo<rXCt)(9rC1I->73:3"
     zzsMsg(8)="e&r§("
     zzsMsg(9)="fRu04gD/z[*j80iG2;0vv"
     zzsMsg(10)="mQ84&r823?R#Jx7Z9,0§;A<x(98*7wYs1"
     zzsMsg(11)="j8x_qV+Wh(5'qw23;8OE!21aA&x>5Fs1"
     zzsMsg(12)="I5]+d@r5_7(&QHvJhw/%RMh]#Qy:DyptGwcek08w*15D"
     zzMsg(0)="9 zDrF"
     zzMsg(1)="=*Cc7ApMxm"
     zzMsg(2)="O3n:=%tXIvuFp2E)UV(_r7qH:"
     zzMsg(3)="1.O<FkiC]Ffz0F)8.7E<CoGe34<ty@sco$fQDGj!(vv8[8lCspM"
     zzMsg(4)="rj(.ezxBvoL-,2wDvp6>G[%_b8&mDi7="
     zzMsg(5)="gs1n]u!K8x1eCcapsu2X>7tFpJ:fR><Cq6J;?y6GZwTf q"
     zzMsg(6)=":;uyZqP1? up0Y5<6<viv3*w3v*q&,bt4IC*$l;osSfrvx 3Frd5zt§pa.qx"
     zzMsg(7)="*hDrgD99[q§3Mhj&E/Cq)v<i&mDi7=MDzjEb2QbwTf q"
     zzMsg(8)="I>5D.v.s9-EBry_u9_zI46LipK8x1eCc"
     zzMsg(9)="jevzimCk[:z3D.Bh$?tqzkN>DECC0YA3MtlIDbMe)ClKHaA0Lorm[VSf[@+"
     zzMsg(10)="<sqAS8T1t9sq$=?LCt?O4:u$z/bFpQtX7rvvj4 "
     zzMsg(11)="$s1n]u5czt2@hj?q?60XBpae7g6@tb0LwEqm "
     zzMsg(12)=")&Rq1pp=MDJ>h"
     zzMsg(13)="x2fz7r"
     zzMsg(14)="qGjkLpuO"
     zzMsg(15)="R]ywq qMug[;i0LrtqxhEjX"
     zzMsg(16)="B&z5w;A!Vf=dzA>0D"
     zzMsg(17)="]=j0q2>_Jt1"
     zzMsg(18)="5Lo?<h82+L9=§xLtq"
     zzMsg(19)="S2$DZ[F=J>>RnxkvFi$k<zur!o=!p"
     zzMsg(20)="Ta#K84Di0jI:u"
     zzMsg(21)="*Km9vkCqxM@#wz h35§!@6;u5]"
     zzMsg(22)="/s1n]u5czt2@hj?q_vru-p$ hw"
     zzMsg(23)="zvC@*Km9vkCq1EjB"
     zzMsg(24)=":9!(v;vqQ6;u5&8[8i<k2Sf3w@I=wI"
     zzMsg(25)="ECox*k2KE2Am<tID[s1n>hv=4]*l-"
     zzMsg(26)="fzDrdtqW1xS<_8>wYZhj§gHhn$?Lkv1"
     zzMsg(27)=" A2-m]E<;B>Ijt[@hr/q ye5@-4 xHwn@r3"
     zzMsg(28)="[l1yS:u_Hxo9k_L<@s5M"
     zzMsg(29)="m!5(grmSB#wJhj§gHaPHBtkS:AX5JjS-y@qv>7m3lvAsA0EHbDiS q"
     zzMsg(30)="*sqAW0D8[vy@qv>7Dovrd2Lxg[dEjXonpT@/1)'4E,vC@"
     zzMsg(31)="*;uymr_z"
     zzMsg(32)="8*x5uX:20Ei6"
     zzMsg(33)="1bGy4$m(wl"
     zzMsg(34)="@o)!m93"
     zzMsg(35)="e>k(Ih"
     zzMsg(36)="2zjEb2Qpw1"
     CheckMe="ACTORRESETTER;BOTPACK;CORE;ENGINE;EDITOR;FIRE;UTSERVERADMIN;UWEB;UWINDOW;IPDRV;IPSERVER;UBROWSER;UMENU;UNREALI;UNREALSHARE;UTBROWSER;UTMENU;S_SWAT;TODATAS;TODECOS;TOMODELS;TOPMODELS;TOSYSTEM"
     bNoUpSwimming=true
}
