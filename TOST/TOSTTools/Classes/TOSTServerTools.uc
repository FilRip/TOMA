// $Id: TOSTServerTools.uc 530 2004-04-04 01:36:37Z stark $
//----------------------------------------------------------------------------
// Project   : TOST
// File      : TOSTServerTools.uc
// Version   : 1.1
// Author    : BugBunny + DiLDoG
//----------------------------------------------------------------------------
// Notes:
// 	| Backupped PlayerData | Connected players | Empty space |
// check that sapause unpauses the game allways (2min wait, reconnect while paused etc)
//----------------------------------------------------------------------------

class TOSTServerTools expands TOSTPiece config;

const MemorySize	= 75;				// Holds size of memory (connected + backup)

struct PlayerData
{
	var	PlayerPawn	Player;				// Reference to PlayerPawn when player is connected
	var	float		Timestamp;			// Contains time when player joined/leaved
	var	string		PlayerName;			// Used for backup recovery and nickchange blocker
	var	string		IP;					// Used for playerbackup

	var	float		MuteTill;			// Time when player is allowed to talk again
	var	int			Warnings;			// Stores warning count
	var	bool		bIsRecording;		// True when player is recording a demo
	var	bool		bIsLeader;			// gives player certain previlages in CWMode (not fully supported yet)

	var	int			Renames;
	var	int			TKCount;
	var	int			SALevel;
	var float		LastTeamChange;

	var	int			Money;
	var	int			Score;
	var	int			Kills;
	var	int			Deaths;
	var	int			Round;
	var	int			PlayTime;
};

var	HTTPTransfer	HTTPLink;			// Contains HTTP connection class
var	PlayerData		Memory[75];			// PlayerBackup
var	PlayerPawn		PendingPlayers[32]; // Players in queue

var			int		TotalSize;			// The current size of the array
var			int		BackupSize;			// The index+1 in array where backup ends

var	config	int		MaxRenames;			// Max renames per map
var	config	bool	PlayerBackup;		// If true settings will be restored after reconnect
var	config	int		MaxTeamKills;		// Max allowed teamkills before tempban
var	config	bool	TKHandling;			// well... name sais it all
var	config	bool	AutoMkTeams;		// Balance teams @ preround start
var	config	bool	AutoMkClanTeams;	// Make Clan Teams @ preround start
var	config	bool	HPMessage;			// Show hp message when u get killed
var	config	bool	EnhVoteSystem;		// Use improved vote system
var	config	bool	CWMode;				// CWMode Active

var	config	int		SlotReserverNumber;	// number of reserved slot
var	config	string	SlotReserverPass;	// the pass to enter when place is reserved
var	config	bool	SlotReserverSet;	// Will be set to true when slot reserver put password on server
var	config	string	ClanTag;			// tag used for makeclanteams
var	config	int		FirstPreRound;		// time 4 the first preround
var	config	int		MaxWarnings;		// Number of warnings a player needs before getting kicked
var	config	int		LastUpdate;			// Contains last update check
var	config	string	PieceVersions[32];	// Stores available tost pieces "name|version"

var			string	NextMapChosen;		// Stores upcoming map if set
var			string	OldVersionWarning;	// doh
var			bool	ForcedRename;		// Will be set to true temporary when forcing a rename
var			bool	StopRecursion;		// Prevents eventnickchange for calling itsself

var			int		BackupCounter;		// Make shure player stats are updated every 5 ticks
var			bool	DemoStatusChanged;	// true when client(s) need info refresh
var			bool	MapStarted;			// Will be set to true after first preround
var			bool	AutoClanTeams;		// true if autoclanteams is enabled current map, in CWMode make players auto join
var			bool	DisableSay;			// Only allows teamsay, for in cw's

var			int		UpdateDelay;		// Time between two updates in hours
var			string	UpdateHost;			// Host for update check
var			string	UpdateScript;		// Script on host

var			color	WarningMsgColor;	// Warning message color
var			string	IRCVersionWarning;	// List of outdated Pieces which is sent to TOSTIRC

//----------------------------------------------------------------------------
// TOST Event Handling
//----------------------------------------------------------------------------
function EventInit()
{
	// Init PlayerBackup
	BackupSize=0;
	TotalSize=0;

	super.EventInit();
}

function EventPostInit()
{
	// propagate startup CW mode
	Params.Param5 = CWMode;
	SendMessage(BaseMessage + 17);

	// Request Piece update list
	RequestUpdates();

	// Initiate the SlotReserver
	UpdateSlotReserver();

	super.EventPostInit();
}


function  EventPlayerConnect(Pawn Player)
{
	local	int		i;

	// we do not have IPs here, so put new players in the queue
	for (i=0; i<32; i++)
	{
		if (PendingPlayers[i] == None)
		{
			PendingPlayers[i] = PlayerPawn(Player);
			break;
		}
	}

	// Update slot reserver, if player is no spectator, AddPlayer should be true
	UpdateSlotReserver(!Player.PlayerReplicationInfo.bIsSpectator);

	super.EventPlayerConnect(Player);
}

function EventPlayerDisconnect(Pawn Player)
{
	// Disconnect player from backup
	DisconnectPlayer(PlayerPawn(Player));

	// Update Slot reserver
	UpdateSlotReserver();

	super.EventPlayerDisconnect(Player);
}

function EventTeamChange(Pawn Other)
{
	local int i;

	// Log player's teamchange
	i = FindPlayerIndex(PlayerPawn(Other));
	if (i != -1)
		Memory[i].LastTeamChange = Level.TimeSeconds;

	Super.EventTeamChange( Other );
}

function EventNameChange(Pawn Other)
{
	local	int 	i;
	local	bool	bMuted;

	if (StopRecursion || ForcedRename)
		Super.EventNameChange(Other);
	else
	{
		i = FindPlayerIndex(PlayerPawn(Other));
		if (i==-1)
		{
			Super.EventNameChange(Other);
		} else {
			if (Other.PlayerReplicationInfo.PlayerName != Memory[I].PlayerName)
			{
				Memory[i].Renames--;
				bMuted = IsMuted(i);
				 if (bMuted || (Memory[i].Renames < 0 && MaxRenames != 0)) {
					StopRecursion = true;
					if(bMuted)
						NotifyPlayer(1, Memory[i].Player, "No name changes allowed while muted...");
					else
						NotifyPlayer(1, Memory[i].Player, "No more name changes allowed this map...");
					Memory[i].Player.SetName(Memory[I].PlayerName);
					Memory[i].Player.PlayerReplicationInfo.PlayerName = Memory[I].PlayerName;
					if (Memory[i].Renames < -MaxRenames)
					{
						Params.Param4="Too many renames";
						Params.Param5=false;
						Params.Param6=Memory[i].Player;
						SendMessage(191);
						XLog(Memory[i].Playername@": Kicked for excessive renaming");
						NotifyPlayer(0, Memory[i].Player, "Kicked for excessive renaming");
						Other.Destroy();
					}
					StopRecursion = false;
				} else {
					AnnounceRename(Memory[I].PlayerName, Memory[i].Player.PlayerReplicationInfo.PlayerName, (Memory[i].Player.Health > 0));
					Memory[i].PlayerName = Memory[i].Player.PlayerReplicationInfo.PlayerName;
					Super.EventNameChange(Other);
				}
			} else
				Super.EventNameChange(Other);
		}
	}
}

function EventGamePeriodChanged(int GP)
{
	local	int	i;

	// AutoMkTeams / AutoMkClanteams
	if (GP == 0 && (AutoMkClanTeams || (AutoMkTeams && !CWMode)))
		UpdateTeams(AutoMkClanTeams, false);

	// check for AdminReset -> reset backup data and set preround
	if (GP==0 && s_SWATGame(Level.Game).RoundNumber==1)
	{
		for (i=0; i<ArrayCount(Memory); i++)
		{
			Memory[i].TKCount = 0;
			Memory[i].Money = 1000;
			Memory[i].Kills = 0;
			Memory[i].Deaths = 0;
			Memory[i].Round = 1;
			Memory[i].PlayTime = 0;
		}
		// Set 1st round start time if mapstarttime is set
		if ((!MapStarted) && (FirstPreround > 0))
		{
			dLog("Map start, set preround to"@FirstPreround);
			if (FirstPreround > 60) FirstPreround = 60;
			s_SWATGame(Level.Game).PreRoundDelay = FirstPreround;
		}
		// Remove Double preround
		else if (MapStarted && (FirstPreround > 0))
		{
			dLog("Adminreset, remove double preround");
			s_SWATGame(Level.Game).PreRoundDelay = s_SWATGame(Level.Game).PreRoundDuration1;
		}
		TO_DeathMatchPlus(Level.Game).EndTime = 0;
		MapStarted = true;
	}

	// 1. round playing started:
	if (IRCVersionWarning!="" && GP==1 && s_SWATGame(Level.Game).RoundNumber==1)
	{
		Params.Param4 = IRCVersionWarning;
		SendMessage(280); // send to TOSTIRC
	}

	super.EventGamePeriodChanged(GP);
}

function EventScoreKill(Pawn Killer, Pawn Other)
{
	local	int		i;

	// TK Handling
	if(	Killer != none && Other != none && Killer.IsA('PlayerPawn') && Killer != Other && Killer.PlayerReplicationInfo.Team == Other.PlayerReplicationInfo.Team)
	{
		i = FindPlayerIndex(PlayerPawn(Killer));
		if (i != -1)
		{
			Memory[i].TKCount++;
			if (TKHandling && !CWMode)
			{
				if (Memory[i].TKCount > MaxTeamKills)
					TempKickBan(none, Killer.PlayerReplicationInfo.PlayerID, 0, 0, Memory[i].TKCount$" Teamkills");
				else if (Memory[i].TKCount == MaxTeamKills)
					NotifyPlayer(1, PlayerPawn(Killer), "Your next teamkill will get you tempkickbanned!");
				else
					NotifyPlayer(1, PlayerPawn(Killer), "You have"@Memory[i].TKCount@"/"@MaxTeamKills@"teamkills.");
			}
		}
	}
	Super.EventScoreKill(Killer, Other);
}

function bool EventTeamMessage(Actor Sender, Pawn Receiver, PlayerReplicationInfo PRI, coerce string S, name Type, optional bool bBeep)
{
	local int i;

	if (Sender.IsA('PlayerPawn'))
	{
		i = FindPlayerIndex(PlayerPawn(Sender));
		if (i == -1)
			return super.EventTeamMessage(Sender, Receiver, PRI, S, Type, bBeep);

		// Only allow teamsay when DisableSay is active
		if (CWMode && DisableSay && !Memory[i].bIsLeader)
			return false;

		// Disable all messages if player is muted
		if (IsMuted(i))
			return false;

		// Disable fake whisper and teamsay messages
		if(InStr(Caps(S),"(WHISPER)") != -1 || InStr(Caps(S),"(TEAMSAY)") != -1)
			return false;
	}
	return super.EventTeamMessage(Sender, Receiver, PRI, S, Type, bBeep);
}

function int EventTimer()
{
	ProcessVotes();

	if (NextMapChosen != "")
		Level.ServerTravel(NextMapChosen$"?game=s_SWAT.s_SWATGame", false);

	return 0;
}

function Timer()
{
	// Notify players for outdated pieces
	NotifyAll(1,OldVersionWarning);
}

function bool EventBroadcastLocalizedMessage( Actor Sender, Pawn Receiver, out class<LocalMessage> Message, out optional int Switch, out optional PlayerReplicationInfo RelatedPRI_1, out optional PlayerReplicationInfo RelatedPRI_2, out optional Object OptionalObject )
{
	// TOStats Support
	if ((Message == class's_MessageRoundWinner') &&
		// only relevant messages
		((Switch <= 10) || (Switch == 12) || (Switch == 13)) &&
		// trigger only once
		(Receiver.PlayerReplicationInfo == Level.Game.GameReplicationInfo.PRIArray[0]))
		TOST.LogHook.LogEventString(TOST.LogHook.GetTimeStamp()$Chr(9)$"endroundid"$Chr(9)$Switch);
	return super.EventBroadcastLocalizedMessage(Sender, Receiver, Message, switch, RelatedPRI_1, RelatedPRI_2, optionalObject );
}

function EventTakeDamage( out int ActualDamage, Pawn Victim, Pawn InstigatedBy, out Vector HitLocation, out vector Momentum, name DamageType)
{
	local 	int 	i;
	local 	Pawn 	P;
	local	int		rnd;

	// fix hossies kill score
	if (Victim != none && Victim.IsA('s_NPCHostage') && ActualDamage >= (Victim.Health - ActualDamage))
	{
		if ( ActualDamage >= Victim.Health)
		{
			if ( ActualDamage > Victim.Mass )
				i = ActualDamage + Victim.Health;
			else
				i = ActualDamage;
		} else {
			i = 2*ActualDamage - Victim.Health;
		}

		if (instigatedBy.IsA('s_Player') && instigatedBy.PlayerReplicationInfo != none)
		{
			TO_PRI(instigatedBy.PlayerReplicationInfo).InflictedDmg -= i;
		} else {
			if (instigatedBy.IsA('s_Bot') && instigatedBy.PlayerReplicationInfo != none)
			{
				TO_BRI(instigatedBy.PlayerReplicationInfo).InflictedDmg -= i;
			}
		}
	}

	if (!(InstigatedBy == none || Victim == none || instigatedBy.PlayerReplicationInfo == none || (InstigatedBy.PlayerReplicationInfo.PlayerName == "Player" && InstigatedBy.PlayerReplicationInfo.PlayerID == 0)))
	{
		if (instigatedBy != none && Victim.IsA('s_Player') && Victim.Health-ActualDamage <= 0)
		{
			// TOStats support
			if(DamageType == 'explosion')
				TOST.LogHook.LogEventString(TOST.LogHook.GetTimeStamp()$Chr(9)$"killwid"$Chr(9)$InstigatedBy.PlayerReplicationInfo.PlayerID$Chr(9)$"3"$Chr(9)$Victim.PlayerReplicationInfo.PlayerID$Chr(9)$s_Weapon(Victim.Weapon).WeaponID);
			else
				TOST.LogHook.LogEventString(TOST.LogHook.GetTimeStamp()$Chr(9)$"killwid"$Chr(9)$InstigatedBy.PlayerReplicationInfo.PlayerID$Chr(9)$s_Weapon(InstigatedBy.Weapon).WeaponID$Chr(9)$Victim.PlayerReplicationInfo.PlayerID$Chr(9)$s_Weapon(Victim.Weapon).WeaponID);

			// HP Message
			if( HPMessage && Victim.PlayerReplicationInfo != none)
			{
				if(InstigatedBy == Victim) {
					// suicide
					NotifyPlayer(1, PlayerPawn(Victim), "You committed suicide!");
				}
				else if(InstigatedBy.PlayerReplicationInfo.Team == Victim.PlayerReplicationInfo.Team)
				{
					if(DamageType == 'explosion')
						NotifyPlayer(1, PlayerPawn(Victim), InstigatedBy.PlayerReplicationInfo.PlayerName $ " (" $	GetHPArmor(instigatedBy) $ ") teamkilled you with a nade!");
					else
						NotifyPlayer(1, PlayerPawn(Victim), InstigatedBy.PlayerReplicationInfo.PlayerName $ " (" $	GetHPArmor(instigatedBy) $ ") teamkilled you" $ GetWeapon(instigatedBy) $ "!");
					NotifyRest(1, PlayerPawn(Victim), InstigatedBy.PlayerReplicationInfo.PlayerName $" (PID: "$InstigatedBy.PlayerReplicationInfo.PlayerID$") teamkilled "$Victim.PlayerReplicationInfo.PlayerName);
				} else {
					if(DamageType == 'explosion')
						NotifyPlayer(1, PlayerPawn(Victim), InstigatedBy.PlayerReplicationInfo.PlayerName $ " (" $ GetHPArmor(instigatedBy) $ ") killed you with a nade!");
					else
						NotifyPlayer(1, PlayerPawn(Victim), InstigatedBy.PlayerReplicationInfo.PlayerName $ " (" $ GetHPArmor(instigatedBy) $ ") killed you" $ GetWeapon(instigatedBy) $ "!");
				}
			}

			// TK Handling
			if(InstigatedBy.PlayerReplicationInfo.Team == Victim.PlayerReplicationInfo.Team && instigatedBy != Victim && s_GameReplicationInfo(Level.Game.GameReplicationInfo).RoundStarted - s_GameReplicationInfo(Level.Game.GameReplicationInfo).RemainingTime < 15 && s_GameReplicationInfo(Level.Game.GameReplicationInfo).FriendlyFireScale > 0 && ActualDamage > 0)
				NotifyAll(1, InstigatedBy.PlayerReplicationInfo.PlayerName $" (PID: "$InstigatedBy.PlayerReplicationInfo.PlayerID$") shot at "$Victim.PlayerReplicationInfo.PlayerName);
		}
	}

	Super.EventTakeDamage(ActualDamage, Victim, InstigatedBy, HitLocation, Momentum, DamageType );

	if (PlayerPawn(Victim) != none && Victim.Health > ActualDamage)
	{
		rnd = FClamp(ActualDamage, 20, 60);
		if ( damageType == 'Burned' )
			PlayerPawn(Victim).ClientInstantFlash( (1+0.009375) * rnd, -rnd * vect(16.41, 11.719, 4.6875));
		else if ( damageType == 'Corroded' )
			PlayerPawn(Victim).ClientInstantFlash( (1+0.01171875) * rnd, -rnd * vect(9.375, 14.0625, 4.6875));
		else if ( damageType == 'Drowned' )
			PlayerPawn(Victim).ClientInstantFlash( 0.390, -vect(312.5,468.75,468.75));
		else
			PlayerPawn(Victim).ClientInstantFlash( 0.019 * rnd, -rnd * vect(26.5, 4.5, 4.5));
	}
}

/*
  Updates the player-scores at mapend
  on TO-Server-Package v2
*/
function EventAfterEndGame(string Reason)
{
    local s_Player sP;

    dLog("executing ScoreFix...");
    foreach AllActors(class's_Player', sP)
    {
        dLog("found s_Player");
        sP.ShowMenu(); // the used function for the "hack"...
    }

	if (NextPiece != none)
		NextPiece.EventAfterEndGame(Reason);
}

function Tick(float Delta)
{
	local	int	i;
	local	Pawn	P;

	// check for players in queue
	for (i=0; i<32; i++)
	{
		if (PendingPlayers[i] != none && PendingPlayers[i].GetPlayerNetworkAddress() != "" && PendingPlayers[i].PlayerReplicationInfo.Team != 255)
		{
			ConnectPlayer(PendingPlayers[i]);
			PendingPlayers[i] = none;
		}
	}

	// Broadcast demorec string
	if (DemoStatusChanged)
		BroadcastRecordingList();

	// Refrsh player stats every 5 ticks
	if (PlayerBackup && BackupCounter++ == 5)
	{
		BackupCounter = 0;
		RefreshPlayerStats();
	}

	// fix behindview bug
	if (!TO_GameBasics(Level.Game).bAllowBehindView)
		for (P=Level.PawnList;P!=none;P=P.NextPawn)
		{
			if (s_Player(P) != none && !s_Player(P).bAdmin)
				P.bBehindView=false;
		}
}

event Destroyed()
{
}

//----------------------------------------------------------------------------
// PlayerBackup Main functions
//----------------------------------------------------------------------------
// * ConnectPlayer - add/refresh a newly connected player
function ConnectPlayer(PlayerPawn P)
{
	local	int			i,j;

	i = FindPlayerBackup(P.GetPlayerNetworkAddress(), P.PlayerReplicationInfo.PlayerName);
	dLog("Player '"$P.PlayerReplicationInfo.PlayerName$"' Connnected, index="$i);

	if (i != -1 && PlayerBackup) {
		// Reconnect
		dLog("Player found, old name was '"$Memory[i].PlayerName$"', restoring player data");
		Memory[i].Timestamp = Level.TimeSeconds;
		if (P.PlayerReplicationInfo.PlayerName != Memory[i].PlayerName)
		{
			Memory[i].Renames--;
			if (IsMuted(i)) {
				P.SetName(Memory[I].PlayerName);
				Memory[i].Player.PlayerReplicationInfo.PlayerName = Memory[i].PlayerName;
				NotifyPlayer(1, P, "No name changes allowed while muted...");
			}
			else if (Memory[i].Renames < 0 && MaxRenames != 0) {
				P.SetName(Memory[I].PlayerName);
				Memory[i].Player.PlayerReplicationInfo.PlayerName = Memory[i].PlayerName;
				NotifyPlayer(1, P, "No more name changes allowed this map...");
			} else {
				AnnounceRename(Memory[I].PlayerName, P.PlayerReplicationInfo.PlayerName, (P.Health > 0));
				Memory[i].PlayerName = P.PlayerReplicationInfo.PlayerName;
			}
		}
		Memory[i].IP = IPOnly(P.GetPlayerNetworkAddress());
		if (Memory[i].Round == s_GameReplicationInfo(Level.Game.GameReplicationInfo).RoundNumber) {
			s_Player(P).Money = Memory[i].Money - 300;
		} else {
			s_Player(P).Money = Memory[i].Money;
		}
		Memory[i].Round = s_GameReplicationInfo(Level.Game.GameReplicationInfo).RoundNumber;
		TO_PRI(P.PlayerReplicationInfo).InflictedDmg = Memory[i].Score;
		P.PlayerReplicationInfo.Score = Memory[i].Kills;
		P.PlayerReplicationInfo.Deaths = Memory[i].Deaths;
		P.PlayerReplicationInfo.StartTime = Level.TimeSeconds - Memory[i].PlayTime;
		Memory[i].Player = P;
		Memory[i].bIsRecording = false;
		Memory[i].SALevel = 0;
		Memory[i].LastTeamChange = 0;

		// Move memory item to connected players range
		BackupSize--;
		dLog("Switch memory index "$i$" with "$BackupSize);
		SwitchBackupPlayers(i,BackupSize);
	}
	else {
		// new Player
		if (TotalSize == MemorySize)
			i = FindOldestBP();
		else
			i = TotalSize++;

		Memory[i].Player = P;
		Memory[i].Timestamp = Level.TimeSeconds;
		Memory[i].PlayerName = P.PlayerReplicationInfo.PlayerName;
		Memory[i].IP = IPOnly(P.GetPlayerNetworkAddress());

		Memory[i].MuteTill = 0;
		Memory[i].Warnings = 0;
		Memory[i].bIsRecording = false;
		Memory[i].bIsLeader = false;

		Memory[i].Money = s_Player(P).Money;
		Memory[i].Round = s_GameReplicationInfo(Level.Game.GameReplicationInfo).RoundNumber;
		Memory[i].Score = TO_PRI(P.PlayerReplicationInfo).InflictedDmg;
		Memory[i].Kills = P.PlayerReplicationInfo.Score;
		Memory[i].Deaths = P.PlayerReplicationInfo.Deaths;
		Memory[i].PlayTime = 0;
		Memory[i].Renames = MaxRenames;
		Memory[i].Player = P;
		Memory[i].TKCount = 0;
		Memory[i].SALevel = 0;
		Memory[i].LastTeamChange = 0;
	}
	DemoStatusChanged = true;
}

// * DisconnectPlayer - move player from active to backup range
function DisconnectPlayer(PlayerPawn Player)
{
	local int i;

	// Update the timestamp and move the item
	i = FindPlayerIndex(Player);
	dLog("Player '"$Player.PlayerReplicationInfo.PlayerName$"' Disconnected, index="$i);

	if (i == -1)
		return;

	if(PlayerBackup)
	{
		Memory[i].TimeStamp = Level.TimeSeconds;
		Memory[i].Money = s_Player(Memory[i].Player).Money;
		Memory[i].Score = TO_PRI(Memory[i].Player.PlayerReplicationInfo).InflictedDmg;
		Memory[i].Round = s_GameReplicationInfo(Level.Game.GameReplicationInfo).RoundNumber;
		Memory[i].Kills = Memory[i].Player.PlayerReplicationInfo.Score;
		Memory[i].Deaths = Memory[i].Player.PlayerReplicationInfo.Deaths;
		Memory[i].Timestamp = Level.TimeSeconds;
		Memory[i].PlayTime = Level.TimeSeconds - Memory[i].Player.PlayerReplicationInfo.StartTime;
		Memory[i].SALevel = 0;
		Memory[i].LastTeamChange = 0;
		Memory[i].bIsRecording = false;
		Memory[i].Player = none;
		SwitchBackupPlayers(i, BackupSize);
		BackupSize++;
	}
	else
	{
		Memory[i].Player = none;
		SwitchBackupPlayers(i, TotalSize);
		TotalSize--;
	}
}

// * RefreshPlayerStats - Refresh all player's data
function RefreshPlayerStats()
{
	local	int		i;

	for (i=BackupSize; i<TotalSize; i++)
	{
		if (Memory[i].Player != none && Memory[i].Player.PlayerReplicationInfo.Team != 255)
		{
			Memory[i].Money = s_Player(Memory[i].Player).Money;
			Memory[i].Round = s_GameReplicationInfo(Level.Game.GameReplicationInfo).RoundNumber;
			Memory[i].Kills = Memory[i].Player.PlayerReplicationInfo.Score;
			Memory[i].Deaths = Memory[i].Player.PlayerReplicationInfo.Deaths;
			Memory[i].Timestamp = Level.TimeSeconds;
			Memory[i].PlayTime = Level.TimeSeconds - Memory[i].Player.PlayerReplicationInfo.StartTime;
		}
	}
}

// * SwitchBackupPlayers - switches 2 memory structs
function SwitchBackupPlayers(int OldIndex, int NewIndex)
{
	local PlayerData tmp;

	if (OldIndex == NewIndex)
		return;

	tmp = Memory[OldIndex];
	Memory[OldIndex] = Memory[NewIndex];
	Memory[NewIndex] = tmp;
}

// * EraseStats - erase all entries in backup of given player
function EraseStats(int PID, string PlayerName)
{
	local int i;

	for (i=BackupSize; i<TotalSize; i++)
		if ((Memory[i].Player.PlayerReplicationInfo.PlayerID == PID) || (Memory[i].PlayerName == PlayerName))
		{
			Memory[i].Timestamp = 0;
			Memory[i].PlayerName = "";
			Memory[i].IP = "";
			Memory[i].MuteTill = 0;
			Memory[i].Warnings = 0;
			Memory[i].bIsRecording = false;
			Memory[i].bIsLeader = false;
			Memory[i].Score = 0;
			Memory[i].Money = 0;
			Memory[i].Deaths = 0;
			Memory[i].Kills = 0;
			Memory[i].Round = -1;
			Memory[i].PlayTime = 0;
			Memory[i].TKCount = 0;
			Memory[i].SALevel = 0;
			Memory[i].LastTeamChange = 0;
		}
}

// * FindPlayerStats - find memory index of given player
function int FindPlayerIndex(PlayerPawn Player)
{
	local int i;

	for (i=BackupSize; i<TotalSize; i++)
		if (Memory[i].Player == Player)
			return i;

	return -1;
}

// * FindPlayerStatsByID - find memory index of given player
function int FindPlayerIndexByID(int PID)
{
	local int i;

	for (i=BackupSize; i<TotalSize; i++)
		if (Memory[i].Player.PlayerReplicationInfo.PlayerID == PID)
			return i;

	return -1;
}

// * FindPlayerBackup - check for reconnecting players
function int FindPlayerBackup(string IP, string PlayerName)
{
	local int i, j, k;

	j = -1;
	k = -1;

	for ( i=0; i<BackupSize; i++ )
	{
		if (Memory[i].PlayerName == PlayerName)
			j = i;
		if (Memory[i].IP == IPOnly(IP))
			k = i;
		if ( k==j && j==i )
			return i;
	}
	if ( k == -1)
		return j;
	return k;
}

// * FindOldestBP - get the index of the player that was absent the longest time
function int FindOldestBP()
{
	local int i, min;

	min = 0;
	for (i=0; i<BackupSize; i++)
		if (Memory[i].Timestamp < Memory[min].Timestamp)
			min = i;
	return min;
}


//----------------------------------------------------------------------------
// Misc Functions functions
//----------------------------------------------------------------------------
// * AnnounceRename - publish player renaming
function AnnounceRename(string OldName, string NewName, bool IsAlive, optional bool Forced)
{
	local Pawn P;
	local int  i;
	local string	s;

	if (Forced)
		s = "(forced by admin)";
	for( P=Level.PawnList; P!=None; P=P.nextPawn )
		if( P.bIsPlayer || MessagingSpectator(P) != none )
		{
			if (!Forced && !IsAlive && P.Health > 0) {
				NotifyPlayer(2, PlayerPawn(P), OldName@"is now known as"@NewName@s);
			} else {
				NotifyPlayer(1, PlayerPawn(P), OldName@"is now known as"@NewName@s);
			}
		}
	xLog(OldName$" is now known as "$NewName@s);
}

// * LCTPlayer - return the player in the designated team that has logged on last ...
function Pawn LCTPlayer(int Team, bool UseTag, optional bool Tagged)
{
	local	Pawn	ckPawn, clPawn;
	local int	CheckLvl;
	local int	i;
	local	int		clLastTeamChange;

	// Initialize Lists
	ckPawn = Level.Pawnlist;
	clPawn = None;
	CheckLvl = 0;

	// find first human Player on the designated team in the list
	dLog("LCTPlayer: Team="$Team$" UseTag="$UseTag$" Tagged="$Tagged);
	dLog("LCTPlayer, Loop "$CheckLvl);
	while (ckPawn != none)
	{
		if (ckPawn.IsA('s_Player') && ckPawn.PlayerReplicationInfo.Team == Team)
		{
			i = FindPlayerIndex(PlayerPawn(ckPawn));
			if (i != -1 && ckPawn != clPawn
				&& (CheckLvl < 1 || Tagged == HasTag(ckPawn.PlayerReplicationInfo.PlayerName) || !UseTag)
				&& (CheckLvl < 2 || !ckPawn.PlayerReplicationInfo.bAdmin)
				&& (CheckLvl < 3 || Memory[i].SALevel < 1)
				&& (CheckLvl < 4 || ckPawn.Health < 1 || (CheckLvl > 3 && clPawn.Health > 0) || TO_GameBasics(Level.Game).GamePeriod != GP_RoundPlaying)
				&& (CheckLvl < 5 || Memory[i].LastTeamChange <= clLastTeamChange)
				&& (CheckLvl < 6 || ckPawn.PlayerReplicationInfo.PlayerID > clPawn.PlayerReplicationInfo.PlayerID))
			{
				clPawn = ckPawn;

				dLog(" > Player="$clPawn.PlayerReplicationInfo.PlayerID
					$ ", Name="$clPawn.GetHumanName()
					$ ", Tagged="$HasTag(ckPawn.PlayerReplicationInfo.PlayerName)
					$ ", Admin="$ckPawn.PlayerReplicationInfo.bAdmin
					$ ", SALevel="$Memory[i].SALevel
					$ ", Health="$ckPawn.Health
					$ ", LastTeamChange="$Memory[i].LastTeamChange
					$ ", StartTime="$ckPawn.PlayerReplicationInfo.StartTime
				);
			}
		}
		ckPawn = ckPawn.NextPawn;
		if (ckPawn == none && CheckLvl < 6)
		{
			CheckLvl++;
			dLog("LCTPlayer, Loop "$CheckLvl);
			ckPawn = Level.Pawnlist;
		}
	}
	return clPawn;
}

// * ChangeBombOwner - give the bomb to someone else ...
function ChangeBombOwner(Pawn Pawn)
{
	s_C4(Pawn.FindInventoryType(class's_SWAT.s_C4')).destroy();
	s_SWATGame(Level.Game).GiveBomb();
}

// * PlayerChangeTeam - moves player to given team
function PlayerChangeTeam(PlayerPawn Player, byte Team, bool RemoveWeapons)
{
	local int i;

	Level.Game.ChangeTeam(Player, Team);
	// msg pawn he has been moved to the other team
	Player.ClearProgressMessages();
	Player.SetProgressTime(6);
	Player.SetProgressMessage("You are now on the OPPOSITE team!",0);
	// change C4bomb owner
	if (TO_PRI(Player.PlayerReplicationInfo).bHasBomb == true)
		ChangeBombOwner(Player);
	if (RemoveWeapons)
		Level.Game.AcceptInventory(Player);
	else
		s_Player(Player).Money = s_Player(Player).Money - 1000;
	Level.Game.AddDefaultInventory(Player);

	// Update LastTeamchange
	i = FindPlayerIndex(Player);
	if (i != -1)
		Memory[i].LastTeamChange = 0;
}

// * MkTeams - even teams
function UpdateTeams(bool UseTag, bool RemoveWeapons, optional PlayerPawn Player, optional int Team, optional string Tag)
{
	local	PlayerReplicationInfo PRI;
	local	bool	PlayersMoved;
	local	string	tempstr;

	dLog("----------------- UpdateTeams ------------------");
	foreach AllActors(class'PlayerReplicationInfo', PRI) // get number of players per team
	{
		dLog(PRI.Team@"-"@PRI.PlayerID@"-"@PRI.PlayerName);
	}

	if (Tag != "")
		ClanTag = Tag;

	// Split teams using tag
	if (UseTag && ClanTag == "" && Player != none)
		NotifyPlayer(1, Player, "No tag set, Just balancing teams");
	else if (UseTag)
		PlayersMoved = TagTeams(RemoveWeapons, Team, Tag);

	// Balance teams if not CWMode MkClanTeams
	if (!UseTag || !CWMode)
		PlayersMoved = (BalanceTeams(RemoveWeapons, UseTag) || PlayersMoved);

	// Notice admin nothing happened
	if (UseTag) tempstr = "MkClanTeams"; else tempstr = "MakeTeams";

	if (!PlayersMoved && Player != none)
		NotifyPlayer(0, Player, "Teams are even");
	else if (PlayersMoved && Player != none)
		NotifyAll(0, Player.PlayerReplicationInfo.PlayerName@"executed"@tempstr);
	else if (PlayersMoved)
		NotifyAll(0, "Auto"$tempstr$" executed");

	dLog("------------------------------------------------");
}

// * BalanceTeams - Balance the teams, try to exclude tagged people, return true if players were moved
function bool BalanceTeams(bool RemoveWeapons, bool UseTag)
{
	local	PlayerReplicationInfo PRI;
	local	Pawn	P;
	local	int		Tcount, TerrTeamCount, SwatTeamCount;

	TerrTeamCount = 0;
	SwatTeamCount = 0;
	foreach AllActors(class'PlayerReplicationInfo', PRI) // get number of players per team
	{
		if (PRI.Team == 0)
			TerrTeamCount++;
		else if (PRI.Team == 1)
			SwatTeamCount++;
	}
	TCount = (TerrTeamCount - SwatTeamCount)/2;

	dLog("---------------- Balance Teams -----------------");
	dLog("Team Difference="$TCount);
	dLog("Terr(0): Total="$TerrTeamCount);
	dLog("SF(1):   Total="$SwatTeamCount);
	dLog("------------------------------------------------");

	if (TCount == 0)
	{
		dLog("Nothing to change, BalanceTeams Skipped");
		return false;
	}

	while (TCount != 0)
	{
		// switch teams
		if (TCount > 0)
		{
			P = LCTPlayer(0, UseTag);
			dLog("PlayerChangeTeam on "$PlayerPawn(P).PlayerReplicationInfo.PlayerName);
			PlayerChangeTeam(PlayerPawn(P), 1, RemoveWeapons);
			TCount--;
		}
		else
		{
			P = LCTPlayer(1, UseTag);
			dLog("PlayerChangeTeam on "$PlayerPawn(P).PlayerReplicationInfo.PlayerName);
			PlayerChangeTeam(PlayerPawn(P), 0, RemoveWeapons);
			TCount++;
		}
	}
	return true;
}

// * BalanceTeams - Split players, try to put all tagged players on same team, return true if players were moved
function bool TagTeams(bool RemoveWeapons, int Team, string Tag)
{
	local	PlayerReplicationInfo PRI;
	local	Pawn	P;
	local	int		TotalPlayers;
	local	int		TaggedPlayers[2];
	local	int		OtherPlayers[2];
	local	int		i;

	// Count (Tagged) players of both teams
	TaggedPlayers[0] = 0;	OtherPlayers[0] = 0;
	TaggedPlayers[1] = 0;	OtherPlayers[1] = 0;
	foreach AllActors(class'PlayerReplicationInfo', PRI)
	{
		if (PRI.Team <= 2)
		{
			if (HasTag(PRI.PlayerName))
				TaggedPlayers[PRI.Team]++;
			else
				OtherPlayers[PRI.Team]++;
		}
	}
	TotalPlayers = TaggedPlayers[0] + TaggedPlayers[1] + OtherPlayers[0] + OtherPlayers[1];

	// Define and the team were tagged players will be moved too
	if		(Team == 1 || Team == 2)				Team--;
	else if	(TaggedPlayers[0] < TaggedPlayers[1])	Team = 1;
	else if	(TaggedPlayers[0] > TaggedPlayers[1])	Team = 0;
	else if	(TaggedPlayers[0] == TaggedPlayers[1])	Team = int(OtherPlayers[0] > OtherPlayers[1]);

	dLog("------------------- TagTeams -------------------");
	dLog("ClanTag="$ClanTag);
	dLog("Total="$TotalPlayers$", Team="$Team$", CWMode="$CWMode);
	dLog("Terr(0): Tagged="$TaggedPlayers[0]$" Other="$OtherPlayers[0]$" Total="$(TaggedPlayers[0] + OtherPlayers[0]));
	dLog("SF(1):   Tagged="$TaggedPlayers[1]$" Other="$OtherPlayers[1]$" Total="$(TaggedPlayers[1] + OtherPlayers[1]));
	dLog("------------------------------------------------");

	// Skip if there are no tagged/untagged players
	if (TaggedPlayers[1-Team] == 0 || OtherPlayers[1-Team] == 0 || (TaggedPlayers[Team] > (TotalPlayers/2) && !CWMode))
	{
		dLog("Nothing to change, TagTeams Skipped");
		return false;
	}

	// Put players on right team
	i=0;
	while (i++ < 32
		&& TaggedPlayers[1-Team] > 0
		&& OtherPlayers[1-Team] > 0
		&& (TaggedPlayers[Team] <= (TotalPlayers/2) || CWMode))
	{
		P = LCTPlayer(1-Team, true, true);
		TaggedPlayers[1-Team]--;
   		TaggedPlayers[Team]++;
		dLog("PlayerChangeTeam on "$PlayerPawn(P).PlayerReplicationInfo.PlayerName);
   		if (P!=None)
   		{
            PlayerChangeTeam(PlayerPawn(P), Team, false);
        }
	}

	return true;
}

// * FTeamChg - force team change on player
function FTeamChg(bool RemoveWeapons, int PID, PlayerPawn Player)
{
	local	PlayerPawn	P;

	P = FindPlayerByID(PID);
	if (P != none)
	{
		// change teams
		PlayerChangeTeam(P, 1 - P.PlayerReplicationInfo.Team, RemoveWeapons);
		NotifyAll(0, Player.PlayerReplicationInfo.PlayerName@"has forced a teamchange on"@P.PlayerReplicationInfo.PlayerName);
	}
	else
	{
		NotifyPlayer(1, Player, "Player "$PID$" not found");
	}
}

// * KickBanTK - kick all players 1 or more teamkill
function KickBanTK(PlayerPawn Player, optional int PID)
{
	local int		i;

	// Tempban non-admins teamkillers
	for (i=BackupSize; i<TotalSize; i++)
	{
		dLog("Check for teamkills:"@PID@Memory[i].Player.PlayerReplicationInfo.PlayerID@Memory[i].TKCount@Memory[i].SALevel@Memory[i].Player.bAdmin);
		if ((Memory[i].Player.PlayerReplicationInfo.PlayerID == PID || PID == 0) && Memory[i].TKCount > 0 && Memory[i].SALevel == 0 && !Memory[i].Player.bAdmin)
		{
			TempKickBan(Player, Memory[i].Player.PlayerReplicationInfo.PlayerID, 0, 0, Memory[i].TKCount$" Teamkills");
		}
	}
}

// * TOSTInfo - send some TOST Infos to requesting player
function TOSTInfo(PlayerPawn Player)
{
	local	TOSTPiece	next;
	local	bool		bIsOutDated;
	local	string		temp, TOSTVersion;

	SplitStr(TOST.TOSTVersion, " ", temp, TOSTVersion);

	if	(IsOutdated("TOST",TOSTVersion))
	{
		NotifyPlayer(2, Player, "---------------------------------------------");
		NotifyPlayer(2, Player, "TOST MAIN PACKAGE IS OUTDATED");
		NotifyPlayer(2, Player, "PLEASE CONTACT A SERVERADMIN!");
		NotifyPlayer(2, Player, "---------------------------------------------");
	}
	else if (OldVersionWarning != "")
	{
		NotifyPlayer(2, Player, "---------------------------------------------");
		NotifyPlayer(2, Player, "ONE OR MORE PIECES ARE OUTDATED");
		NotifyPlayer(2, Player, "PLEASE CONTACT A SERVERADMIN!");
		NotifyPlayer(2, Player, "---------------------------------------------");
	}
	NotifyPlayer(2, Player, TOST.TOSTVersion@"Info");
	NotifyPlayer(2, Player, "Loaded Pieces :");
	next = TOST.Piece;
	while (next != None)
	{
		if(IsOutdated(next.PieceName,next.PieceVersion))
			NotifyPlayer(2, Player, " OUTDATED :"@next.PieceName@"(Version"@next.PieceVersion$")");
		else
			NotifyPlayer(2, Player, " Piece :"@next.PieceName@"(Version"@next.PieceVersion$")");

		next = next.NextPiece;
	}
}

// * ChangeMap - change map instantly
function ChangeMap(string Map, optional PlayerPawn Player)
{
	local	TOSTPiece	P;
	local	string	CurrentMap;

	NextMapChosen = "";

	if (Map == "" && Player != none) // restart current map
	{
		CurrentMap = Level.GetLocalURL();
		CurrentMap = Left(CurrentMap, InStr(CurrentMap, "?"));
		CurrentMap = Mid(CurrentMap, InStr(CurrentMap, "/")+1);
		if ( !(Right(CurrentMap,4) ~= ".unr") )
			CurrentMap = CurrentMap$".unr";
		NextMapChosen = CurrentMap;
		BroadcastClientMessage(110);
		return;
	}

	P = TOST.GetPieceByName("TOST Map Handling");
	if (P != None)
	{
		if (TOSTMapHandling(P).FindMapIndex(Map) != -1)
		{
			TOSTMapHandling(P).NextMapChosen = Map;
			TOSTMapHandling(P).SwitchMap();
		}
		else
		{
			if (Player != None)
				NotifyPlayer(1, Player, PieceName@": Map"@Map@"does not exist on the server");
		}
	}
	else {
		NextMapChosen = Map;
	}

	// Shutdown GUI if next map is chosen
	if (NextMapChosen != "") {
		BroadcastClientMessage(110);
	} else {
		BroadcastClientMessage(111);
	}
}

// * Punish - punish player with damage or death (damage = 0)
function Punish(PlayerPawn Player, int PID, int Damage, string Reason)
{
	local	PlayerPawn	Victim;

	if (Reason != "")
		Reason = " for "$Reason;

	Victim = FindPlayerByID(PID);
	if (Victim != none)
	{
		if (Damage == 0 && Victim.Health > 0)
		{
			// No damage given, kill victim if he's alive
			Victim.KilledBy( none );
			Level.BroadcastMessage(Player.PlayerReplicationInfo.PlayerName$" punishes "$Victim.PlayerReplicationInfo.PlayerName$" with death"$Reason);
		}
		else if (Damage < 0)
		{
			// Punish victem with 'Damage' hp, keep 1hp at least
			if (Victim.Health <= -Damage)
				Victim.Health = 1;
			else
				Victim.Health += Damage;
			Level.BroadcastMessage(Player.PlayerReplicationInfo.PlayerName$" punishes "$Victim.PlayerReplicationInfo.PlayerName$" with "$(-Damage)$"hp damage"$Reason);
		}
		else if (Victim.Health > Damage)
		{
			// Set player's health to 'Damage' hp
			Victim.Health = Damage;
			Level.BroadcastMessage(Player.PlayerReplicationInfo.PlayerName$" punishes "$Victim.PlayerReplicationInfo.PlayerName$" to "$Damage$"hp"$Reason);
		}
		else
		{
			NotifyPlayer(1,Player,"Player is dead already or has to little hitpoints left");
		}
	}
}

// * Kick - kick player
function Kick(PlayerPawn Player, int PID, bool EraseStats, string Reason)
{
	local	PlayerPawn	Victim;

	if (Reason != "") Reason = " for "$Reason;
	Victim = FindPlayerByID(PID);

	if (Victim != None)
	{
		if (Player != None)
			NotifyAll(0, Player.PlayerReplicationInfo.PlayerName$" kicked "$Victim.PlayerReplicationInfo.PlayerName$Reason);
		else
			NotifyAll(0, Victim.PlayerReplicationInfo.PlayerName$" was kicked"$Reason);
		if (EraseStats)
		{
			Params.Param1 = PID;
			Params.Param4 = Victim.PlayerReplicationInfo.PlayerName;
			SendMessage(101);
		}
		Params.Param4=Reason;
		Params.Param5=false;
		Params.Param6=Victim;
		SendMessage(191);
		TO_GameBasics(Level.Game).Kick(Victim);
	}
}

// * TempKickBan - tempkickban player
function TempKickBan(PlayerPawn Player, int PID, int Days, int Mins, string Reason)
{
	local	PlayerPawn	Victim;
	local	TOSTBanList	BanList;
	local	string		Message;

	Victim = FindPlayerByID(PID);

	if (Player != None)
		Message = Player.PlayerReplicationInfo.PlayerName$" tempkickbanned "$Victim.PlayerReplicationInfo.PlayerName;
	else
		Message = Victim.PlayerReplicationInfo.PlayerName$" was tempkickbanned";

	if (Reason != "")
	 	Message = Message$" for "$Reason;

	if (Victim != None)
	{
		Params.Param4=Reason;
		Params.Param5=true;
		Params.Param6=Victim;
		SendMessage(191);

		// handled by ban list ?
		BanList = TOSTBanList(TOST.GetPieceByName("TOST Ban List"));
		if (BanList == none)
		{
			// no - do the standard stuff
			NotifyAll(0, Message);
			TO_GameBasics(Level.Game).TempKickBan(Victim, "Admin :"$Player.PlayerReplicationInfo.PlayerName);

			dLog("BanList not loaded, Using TO TempKickBan");
		}
		else
		{
			// special banlist stuff
			if ((Days == 0) && (Mins == 0))
				NotifyAll(0, Message$" until mapswitch");
			else
				NotifyAll(0, Message$" for "$Days$" days and "$Mins$" minutes.");

			BanList.AddBanComm(Victim.GetPlayerNetworkAddress(), Victim.PlayerReplicationInfo.PlayerName, Player.GetPlayerNetworkAddress(), Player.PlayerReplicationInfo.PlayerName, Days, Mins, Reason);
			TO_GameBasics(Level.Game).Kick(Victim);

			dLog("BanList found, AddBanComm");
		}
	}
}

// * KickBan - kickban player
function KickBan(PlayerPawn Player, int PID, string Reason)
{
	local	PlayerPawn	Victim;
	local	TOSTBanList	BanList;
	local	string		nReason;

	if (Reason != "") nReason = " for "$Reason;
	Victim = FindPlayerByID(PID);

	if (Victim != None)
	{
		Params.Param4=Reason;
		Params.Param5=true;
		Params.Param6=Victim;
		SendMessage(191);
		BanList = TOSTBanList(TOST.GetPieceByName("TOST Ban List"));
		// handled by ban list ?
		if (BanList == none)
		{
			// no - do the standard stuff
			if (Player != None) {
				NotifyAll(0, Player.PlayerReplicationInfo.PlayerName$" kickbanned "$Victim.PlayerReplicationInfo.PlayerName$nReason);
				TO_GameBasics(Level.Game).KickBan(Victim, "Admin :"$Player.PlayerReplicationInfo.PlayerName);
			} else {
				NotifyAll(0, Victim.PlayerReplicationInfo.PlayerName$" was kickbanned"$nReason);
				TO_GameBasics(Level.Game).KickBan(Victim, Victim.PlayerReplicationInfo.PlayerName);
			}
		} else {
			// special banlist stuff
			if (Player != None)
			{
				BanList.AddBanComm(Victim.GetPlayerNetworkAddress(), Victim.PlayerReplicationInfo.PlayerName, Player.GetPlayerNetworkAddress(), Player.PlayerReplicationInfo.PlayerName, -1, -1, Reason);
				NotifyAll(0, Player.PlayerReplicationInfo.PlayerName$" kickbanned "$Victim.PlayerReplicationInfo.PlayerName$nReason);
				TO_GameBasics(Level.Game).Kick(Victim);
			} else {
				BanList.AddBanComm(Victim.GetPlayerNetworkAddress(), Victim.PlayerReplicationInfo.PlayerName, "", "TOST", -1, -1, Reason);
				NotifyAll(0, Victim.PlayerReplicationInfo.PlayerName$" was kickbanned"$nReason);
				TO_GameBasics(Level.Game).Kick(Victim);
			}
		}
	}
}

// * Warn a player, and kick him when MaxWarnings reached
function WarnPlayer(PlayerPawn Player, int PID, string Reason)
{
	local	int		i;
	local   PlayerPawn P;

	if (MaxWarnings == 0)
		return;

	i = FindPlayerIndexByID(PID);
	if (i == -1)
		return;

	P = Memory[i].Player;
	if (P == none)
		return;

	if (Reason != "") Reason = " for "$Reason;
	Memory[i].Warnings++;

	WarningMsgColor.R = 255;
	WarningMsgColor.G = 255;
	WarningMsgColor.B = 0;

	if(Memory[i].Warnings < MaxWarnings)
	{
		// Give player a warning
		NotifyPlayer(1, P, Player.PlayerReplicationInfo.PlayerName$" gave you warning "$Memory[i].Warnings$"/"$MaxWarnings$Reason);
		NotifyRest(1, P, Player.PlayerReplicationInfo.PlayerName$" gave "$P.PlayerReplicationInfo.PlayerName$" a warning"$Reason);

		P.ClearProgressMessages();
		P.SetProgressTime(6);
		P.SetProgressColor(WarningMsgColor,0);
		P.SetProgressMessage("WARNING "$Memory[i].Warnings$"/"$MaxWarnings$Reason,0);
	}
	else if(Memory[i].Warnings == MaxWarnings)
	{
		// Give him his final warning
		NotifyPlayer(1, P, Player.PlayerReplicationInfo.PlayerName$" gave you your final warning"$Reason);
		NotifyRest(1, P, Player.PlayerReplicationInfo.PlayerName$" gave "$P.PlayerReplicationInfo.PlayerName$" his final warning"$Reason);

		P.ClearProgressMessages();
		P.SetProgressTime(6);
		P.SetProgressColor(WarningMsgColor,0);
		P.SetProgressMessage("WARNING "$Memory[i].Warnings$"/"$MaxWarnings$Reason,0);
	}
	else
	{
		// notice other pieces for tempban
		Params.Param4=MaxWarnings$" Warnings"$Reason;
		Params.Param5=true;
		Params.Param6=P;
		SendMessage(191);

		// TempKickban him
		TempKickBan(Player, P.PlayerReplicationInfo.PlayerID, 0, 0, MaxWarnings$" Warnings"$Reason);
	}
}

// * Mute a player, Duration = -1 will permanant Mute, Duration = 0 will UnMute
function Mute(PlayerPawn Player, int PID, int Duration, string Reason)
{
	local	int		i;
	local   PlayerPawn P;

	i = FindPlayerIndexByID(PID);
	if (i == -1)
		return;

	P = Memory[i].Player;
	if (P == none)
		return;

	if (Reason != "") Reason = " for "$Reason;

	if (Duration == -1)
	{
		// Mute forever
		Memory[i].MuteTill = -1;
		NotifyPlayer(1, P, Player.PlayerReplicationInfo.PlayerName$" muted you for the rest of the map"$Reason);
		NotifyRest(1, P, Player.PlayerReplicationInfo.PlayerName$" muted "$P.PlayerReplicationInfo.PlayerName$" for the rest of the map"$Reason);
		dLog(Player.PlayerReplicationInfo.PlayerName$" muted "$P.PlayerReplicationInfo.PlayerName$" for the rest of the map"$Reason);
	}
	else if (Duration > 0)
	{
		// Timed mute
		Memory[i].MuteTill = Level.TimeSeconds + Duration*60;
		NotifyPlayer(1, P, Player.PlayerReplicationInfo.PlayerName$" muted you for "$Duration$" minutes"$Reason);
		NotifyRest(1, P, Player.PlayerReplicationInfo.PlayerName$" muted "$P.PlayerReplicationInfo.PlayerName$" for "$Duration$" minutes"$Reason);
		dLog(Player.PlayerReplicationInfo.PlayerName$" muted "$P.PlayerReplicationInfo.PlayerName$" for "$Duration$" minutes"$Reason);
	}
	else if (IsMuted(i))
	{
		// UnMute
		Memory[i].MuteTill = 0;
		NotifyPlayer(1, P, "you were unmuted by "$Player.PlayerReplicationInfo.PlayerName);
		NotifyRest(1, P, Player.PlayerReplicationInfo.PlayerName$" unmuted "$P.PlayerReplicationInfo.PlayerName);
		dLog(Player.PlayerReplicationInfo.PlayerName$" unmuted "$P.PlayerReplicationInfo.PlayerName);
	}
	else
	{
		NotifyPlayer(1, Player, P.PlayerReplicationInfo.PlayerName$" is not muted");
	}
}

// * AdminReset - restart map
function AdminReset()
{
	local int i;

	s_SWATGame(Level.Game).TOResetGame();

	// TK count reset
	for (i=0; i<MemorySize ; i++)
	{
		Memory[i].TKCount = 0;
		Memory[i].Money = 1000;
		Memory[i].Kills = 0;
		Memory[i].Deaths = 0;
		Memory[i].Round = 1;
		Memory[i].PlayTime = 0;
	}
	TO_DeathMatchPlus(Level.Game).EndTime = 0;
}

// * EndRound - start new round instantly
function EndRound()
{
	s_SWATGame(Level.Game).RoundEnded();
	s_SWATGame(Level.Game).RestartRound();
}

// * SASay - send a message to all players on the screencenter
function SASay(PlayerPawn Player, string Msg)
{
	local Pawn P;

	for( P=Level.PawnList; P!=None; P=P.nextPawn )
		if( P.IsA('PlayerPawn') )
		{
			PlayerPawn(P).ClearProgressMessages();
			PlayerPawn(P).SetProgressTime(6);
			PlayerPawn(P).SetProgressMessage(Msg,0);
		}

	if(Player.IsA('PlayerPawn'))
		NotifyAll(2,Player.PlayerReplicationInfo.PlayerName$": (SASay) "$Msg);
}

// * ShowIP - send IP of given player to requesting player
function ShowIP(PlayerPawn Sender, int PID)
{
	local PlayerPawn Player;

	Player = FindPlayerByID(PID);
	if (Player != None)
	{
		NotifyPlayer(1, Sender, Player.PlayerReplicationInfo.PlayerName$"'s IP is :"@Player.GetPlayerNetworkAddress());
	}
}

// * Whisper - whisper some message to given player
function Whisper(PlayerPawn Sender, int PID, string Msg)
{
	local PlayerPawn P;

	P = FindPlayerByID(PID);
	if (P != none && P != Sender)
	{
		// Disable whispering to living people from beyond the grave
		if (IsMuted(FindPlayerIndex(Sender)) || ((Sender.Health <= 0) && (P.Health > 0) ))
			return;

		if ( (Level.Game != None) && Level.Game.AllowsBroadcast(Sender, Len(Msg)))
		{
			if (Level.Game.MessageMutator != None)
			{
				if ( Level.Game.MessageMutator.MutatorTeamMessage(Self, P, Sender.PlayerReplicationInfo, Msg, 'Whisper', true) )
				{
					P.TeamMessage( Sender.PlayerReplicationInfo, "(Whisper)"@Msg, 'Say', true );
					Sender.TeamMessage( Sender.PlayerReplicationInfo, "(Whisper to "$P.PlayerReplicationInfo.PlayerName$")"@Msg, 'Say', true );
				}
			}
			else
			{
				P.TeamMessage( Sender.PlayerReplicationInfo, "(Whisper)"@Msg, 'Say', true );
				Sender.TeamMessage( Sender.PlayerReplicationInfo, "(Whisper to "$P.PlayerReplicationInfo.PlayerName$")"@Msg, 'Say', true );
			}
		}
	}
}

// * ChangeMutator - edit mutator entry in TOSTServerActor
function ChangeMutator(int Index, string Mutator)
{
	TOST.SA.ChangeMutatorEntry(Index, Mutator);
}

// * ChangePiece - change piece entry in TOSTServerMutator
function ChangePiece(int Index, string Piece)
{
	TOST.ChangePieceEntry(Index, Piece);
}

// * SApause - pause the game as semi admin
function SApause(PlayerPawn Pauser)
{
	if (Level.Pauser=="")
		Level.Pauser = "SAPause";
	else
		Level.Pauser="";
}

// * ProcessVotes - enhance vote system
function ProcessVotes()
{
	local	Pawn		P;
	local	s_Player	VP;
	local	TO_PRI		PRI;
	local	int			i, j;
	local	int			VoteCount, VoteNeeded, NumPlayers;

	NumPlayers = TO_GameBasics(Level.Game).NumPlayers;
	VoteNeeded = Max(Min(NumPlayers - 2, NumPlayers / 2), 1);

	for( P=Level.PawnList; P!=None; P=P.NextPawn )
	{
		if (!(P.IsA('PlayerPawn') && !P.IsA('Spectator') && NetConnection(PlayerPawn(P).Player) != None && !P.IsA('MessagingSpectator')))
			continue;

		j = FindPlayerIndex(PlayerPawn(P));

		// delete votes against admins
		if (EnhVoteSystem || PlayerPawn(P).bAdmin || (j != -1 && Memory[j].SALevel > 0))
		{
			VoteCount = 0;

			PRI = TO_PRI(P.PlayerReplicationInfo);
			for (i=0; i<48; i++)
				if (PRI.VoteFrom[i] != None)
				{
					if (PlayerPawn(P).bAdmin || (j != -1 && Memory[j].SALevel > 0)) {
						PRI.VoteFrom[i] = None;
					} else {
						VoteCount++;
					}
				}
		}

		// check if player is voted out after the new formula
		if (EnhVoteSystem)
		{
			if (VoteCount > 0 && (Memory[j].TKCount > 0) && VoteCount > (VoteNeeded - (1 << (Memory[j].TKCount-1))))
			{
				foreach AllActors(class's_Player', VP)
					VP.ReceiveLocalizedMessage(class's_MessageVote', 1, PRI);

				TempKickBan(none, PlayerPawn(P).PlayerReplicationInfo.PlayerID, 0, 0, VoteCount$" Votes");
			}
		}
	}
}

// * ChangeSALevel - keep track of SA level
function ChangeSALevel (PlayerPawn Player, int Level)
{
	local	int	i;

	i = FindPlayerIndex(Player);
	if (i != -1)
		Memory[i].SALevel = Level;

	if (OldVersionWarning != "")
		NotifyPlayer(1,Player,OldVersionWarning);
}

// * Force Rename - force name change on player (not affecting MaxRenames)
function ForceRename (int PID, string NewName)
{
	local	int i;
	local	PlayerPawn	Player;

	Player = FindPlayerByID(PID);
	if (Player != None && Player.PlayerReplicationInfo.PlayerName != NewName)
	{
		ForcedRename = true;
		AnnounceRename(Player.PlayerReplicationInfo.PlayerName, NewName, (Player.Health > 0), true);
		Player.SetName(NewName);
		i = FindPlayerIndex(Player);
		if (i != -1)
			Memory[i].PlayerName = NewName;
		ForcedRename = false;
	}
}

// * RecordStatusChanged - Called when palyer starts/stops a demo
function RecordStatusChanged(PlayerPawn Player, bool IsRecording)
{
	dLog("RecordStatusChanged: "$Player.PlayerReplicationInfo.PlayerName$" = "$IsRecording);

	Memory[FindPlayerIndex(Player)].bIsRecording = IsRecording;
	DemoStatusChanged = true;
}

// * ForceDemoRec - force a player to record a demo
function ForceDemoRec(PlayerPawn Player, int PID, string FileName)
{
	if ( FileName == "" ) // Get default demo name
		FileName = GetDemoName();

	if ( Player == none )
	{
		if ( PID == 0 )
			NotifyAll(1, "All players were forced to record a demo to:"@FileName);
		else
			NotifyPlayer(1, FindPlayerByID(PID), "You were forced to record a demo to:"@FileName);
	}
	else
	{
		if ( PID == 0 )
			NotifyAll(1, Player.PlayerReplicationInfo.PlayerName@"forced all players to record a demo to:"@FileName);
		else
			NotifyPlayer(1, FindPlayerByID(PID), Player.PlayerReplicationInfo.PlayerName@"forced you to record a demo to:"@FileName);
	}

	Params.Param1 = PID;
	Params.Param4 = FileName;
	BroadcastClientMessage(123);
}

// * BroadcastRecordingList - Send recording list to PID or all clients
function BroadcastRecordingList()
{
	local int		i;
	local string	temp;

	Params.Param4 = ";";
	for (i=0; i<TotalSize; i++)
		if (Memory[i].bIsRecording)
			Params.Param4 = Params.Param4 $ Memory[i].Player.PlayerReplicationInfo.PlayerID $ ";";

	// Send status to all players
	BroadcastClientMessage(124);
	dLog("BroadcastRecordingList: "$Params.Param4);
	DemoStatusChanged = false;
}

// * UpdateSlotReserver - Set's / Remove's the pass from server
function UpdateSlotReserver(optional bool AddPlayer, optional bool NewGamePassword, optional string GamePassword)
{
	local int		NumPlayers;

	if ( SlotReserverNumber > Level.Game.MaxPlayers )
		SlotReserverNumber = Level.Game.MaxPlayers;

	NumPlayers = Level.Game.NumPlayers + int(AddPlayer);

	// new password set
	if (NewGamePassword)
	{
		Level.Game.ConsoleCommand("set Engine.GameInfo GamePassword"@GamePassword);
		SlotReserverSet = false;
		dLog("New game password set to"@GamePassword);
	}
	else
	{
		GamePassword = Level.Game.ConsoleCommand("get Engine.GameInfo GamePassword");
	}

	// Dont do a thing when game password is set
	if (GamePassword != "" && !SlotReserverSet)
	{
		dLog("Slot reserver password disabled, game password already set");
	}

	// Set Slot password
	else if ( !CWMode && (SlotReserverNumber > 0 && NumPlayers >= Level.Game.MaxPlayers - SlotReserverNumber) )
	{
		Level.Game.ConsoleCommand("set Engine.GameInfo GamePassword"@SlotReserverPass);
		SlotReserverSet = (SlotReserverPass != "");

		dLog("Slot reserver set, password="$SlotReserverPass);
	}

	// if enabled, disable
	else if ( SlotReserverSet )
	{
		Level.Game.ConsoleCommand("set Engine.GameInfo GamePassword");
		SlotReserverSet = false;

		dLog("Slot reserver disabled, enough free slots");
	}
	SaveConfig();
}

//----------------------------------------------------------------------------
// TOST Message Handling
//----------------------------------------------------------------------------
function bool EventCheckClearance(TOSTPiece Sender, PlayerPawn Player, int MsgType, out int Allowed)
{
	// allow TOSTInfo & Whisper & Recordstatuschanged for everyone
	if ((MsgType == BaseMessage+0) || (MsgType == BaseMessage+19) || (MsgType == BaseMessage+31))
	{
		Allowed = 1;
		return true;
	}

	// allow reading values
	if (MsgType == 120 && ((Sender.Params.Param1 >= 102 && Sender.Params.Param1 <= 116) || (Sender.Params.Param1 >= 125 && Sender.Params.Param1 <= 127) || (Sender.Params.Param1 >= 141 && Sender.Params.Param1 <= 145)))
	{
		Allowed = 1;
		return true;
	}

	return super.EventCheckClearance(Sender, Player, MsgType, Allowed);
}

function EventMessage(TOSTPiece Sender, int MsgIndex)
{
	switch (MsgIndex)
	{
		// TOSTInfo
		case BaseMessage+0 :	TOSTInfo(Sender.Params.Param6);
								break;
		// EraseStats
		case BaseMessage+1 :	EraseStats(Sender.Params.Param1, Sender.Params.Param4);
								break;
		// MkTeams
		case BaseMessage+2 :	UpdateTeams(false, Sender.Params.Param5, Sender.Params.Param6);
								break;
		// FTeamChg
		case BaseMessage+3 :	FTeamChg(Sender.Params.Param5, Sender.Params.Param1, Sender.Params.Param6);
								break;
		// KickBanTK
		case BaseMessage+4 :	KickBanTK(Sender.Params.Param6, Sender.Params.Param1);
								break;
		// ChangeMap
		case BaseMessage+5 :	ChangeMap(Sender.Params.Param4, Sender.Params.Param6);
								break;
		// Punish
		case BaseMessage+6 :	Punish(Sender.Params.Param6, Sender.Params.Param1, Sender.Params.Param2, Sender.Params.Param4);
								break;
		// Kick
		case BaseMessage+7 :	Kick(Sender.Params.Param6, Sender.Params.Param1, Sender.Params.Param5, Sender.Params.Param4);
								break;
		// TempKickBan
		case BaseMessage+8 :	TempKickBan(Sender.Params.Param6, Sender.Params.Param1, Sender.Params.Param2, int(Sender.Params.Param3), Sender.Params.Param4);
								break;
		// KickBan
		case BaseMessage+9 :	KickBan(Sender.Params.Param6, Sender.Params.Param1, Sender.Params.Param4);
								break;
		// AdminReset
		case BaseMessage+10 :	AdminReset();
								break;
		// EndRound
		case BaseMessage+11 :	EndRound();
								break;
		// SASay
		case BaseMessage+12 :	SASay(Sender.Params.Param6, Sender.Params.Param4);
								break;
		// ShowIP
		case BaseMessage+14 :	ShowIP(Sender.Params.Param6, Sender.Params.Param1);
								break;
		// ChangeMutator
		case BaseMessage+15 :	ChangeMutator(Sender.Params.Param1, Sender.Params.Param4);
								break;
		// ChangePiece
		case BaseMessage+16 :	ChangePiece(Sender.Params.Param1, Sender.Params.Param4);
								break;
		// ForceRename
		case BaseMessage+18 :	ForceRename(Sender.Params.Param1, Sender.Params.Param4);
								break;
		// Whisper
		case BaseMessage+19 :	Whisper(Sender.Params.Param6, Sender.Params.Param1, Sender.Params.Param4);
								break;
		// SAPause
		case BaseMessage+30 :	SAPause(Sender.Params.Param6);
								break;
		// Recordstatuschanged
		case BaseMessage+31 :	RecordStatusChanged(Sender.Params.Param6, Sender.Params.Param5);
								break;
		// ForceDemoRec
		case BaseMessage+32 :	ForceDemoRec(Sender.Params.Param6, Sender.Params.Param1, Sender.Params.Param4);
								break;
		// MkClanTeams
		case BaseMessage+34 :	UpdateTeams(true, Sender.Params.Param5, Sender.Params.Param6, Sender.Params.Param1, Sender.Params.Param4);
								break;
		// Mute
		case BaseMessage+35 :	Mute(Sender.Params.Param6, Sender.Params.Param1, Sender.Params.Param2, Sender.Params.Param4);
								break;
		// WarnPlayer
		case BaseMessage+36 :	WarnPlayer(Sender.Params.Param6, Sender.Params.Param1, Sender.Params.Param4);
								break;
		// GetValue
		case 120 			:	GetValue(Sender.Params.Param6, Sender, Sender.Params.Param1);
								break;
		// SetValue
		case 121 			:	SetValue(Sender.Params.Param6, Sender.Params.Param1, Sender.Params.Param2, Sender.Params.Param3, Sender.Params.Param4, Sender.Params.Param5);
								break;
		// GetSettings
		case 143 			:	GetSettings(Sender);
								break;
		// GetMessageName
		case 203			:	TranslateMessage(Sender);
								break;
		// NotifySALevelChange
		case 205 			:	ChangeSALevel(Sender.Params.Param6, Sender.Params.Param1);
								break;
	}
	super.EventMessage(Sender, MsgIndex);
}

function EventAnswerMessage(TOSTPiece Sender, int MsgIndex)
{
	switch (MsgIndex)
	{
		// Response from HTTPLink
		case -1				:	RecieveUpdates();
								return;
		// SetSettings - report back error messages
		case 144 			:	SetSettings(Sender, Sender.Params.Param4);
								break;
	}
}

function TranslateMessage(TOSTPiece Sender)
{
	switch (Sender.Params.Param1)
	{
		case BaseMessage+0  : Sender.Params.Param4 = "TOSTInfo"; break;
		case BaseMessage+2  : Sender.Params.Param4 = "MkTeams"; break;
		case BaseMessage+3  : Sender.Params.Param4 = "FTeamChg"; break;
		case BaseMessage+4  : Sender.Params.Param4 = "KickBanTK"; break;
		case BaseMessage+5  : Sender.Params.Param4 = "SAMapChg"; break;
		case BaseMessage+6  : Sender.Params.Param4 = "Punish"; break;
		case BaseMessage+7  : Sender.Params.Param4 = "SAKick"; break;
		case BaseMessage+8  : Sender.Params.Param4 = "SATempKickBan"; break;
		case BaseMessage+9  : Sender.Params.Param4 = "SAKickBan"; break;
		case BaseMessage+10 : Sender.Params.Param4 = "SAAdminReset"; break;
		case BaseMessage+11 : Sender.Params.Param4 = "SAEndRound"; break;
		case BaseMessage+12 : Sender.Params.Param4 = "SASay"; break;
		case BaseMessage+14 : Sender.Params.Param4 = "ShowIP"; break;
		case BaseMessage+15 : Sender.Params.Param4 = "ChangeMutator"; break;
		case BaseMessage+16 : Sender.Params.Param4 = "ChangePiece"; break;
		case BaseMessage+18 : Sender.Params.Param4 = "ForceName"; break;
		case BaseMessage+19 : Sender.Params.Param4 = "Whisper"; break;
		case BaseMessage+30 : Sender.Params.Param4 = "SAPause"; break;
		case BaseMessage+32 : Sender.Params.Param4 = "ForceDemoRec"; break;
		case BaseMessage+34 : Sender.Params.Param4 = "MkClanTeams"; break;
		case BaseMessage+35 : Sender.Params.Param4 = "SAPMute"; break;
		case BaseMessage+36 : Sender.Params.Param4 = "SAPWarn"; break;

		case 120			:
		case 121			: TranslateValueMessage(Sender); break;
		default : break;
	}
}

function TranslateValueMessage(TOSTPiece Sender)
{
	switch (Sender.Params.Param2)
	{
		case 100 :	Sender.Params.Param4 = "Admin Password"; break;
		case 101 :	Sender.Params.Param4 = "Game Password"; break;
		case 102 :	Sender.Params.Param4 = "Time Limit"; break;
		case 103 :	Sender.Params.Param4 = "Round Duration"; break;
		case 104 :	Sender.Params.Param4 = "Ballistics"; break;
		case 105 :	Sender.Params.Param4 = "Allow GhostCam"; break;
		case 106 :	Sender.Params.Param4 = "Allow PunishTK"; break;
		case 107 :	Sender.Params.Param4 = "TOST EnhVoteSystem"; break;
		case 108 :	Sender.Params.Param4 = "TOST AutoMkTeams"; break;
		case 109 :	Sender.Params.Param4 = "TOST Backup"; break;
		case 110 :	Sender.Params.Param4 = "Friendly Fire Scale"; break;
		case 111 :	Sender.Params.Param4 = "Explosions FF"; break;
		case 112 :	Sender.Params.Param4 = "Mirror Damage"; break;
		case 113 :	Sender.Params.Param4 = "TOST TK Handling"; break;
		case 114 :	Sender.Params.Param4 = "TOST Max TKs"; break;
		case 115 :	Sender.Params.Param4 = "Min Allowed Score"; break;
		case 116 :	Sender.Params.Param4 = "TOST HP Messages"; break;
		case 125 :	Sender.Params.Param4 = "TOST CW Mode"; break;
		case 127 :  Sender.Params.Param4 = "Allow BehindView"; break;
		case 140 :	Sender.Params.Param4 = "TOST Slot Reserver Password"; break;
		case 141 :	Sender.Params.Param4 = "TOST Slot Reserver Number"; break;
		case 142 :	Sender.Params.Param4 = "TOST Max Warnings"; break;
		case 143 :  Sender.Params.Param4 = "TOST Allow BehindView"; break;
		case 144 :  Sender.Params.Param4 = "TOST Clan Tag"; break;
		case 145 :  Sender.Params.Param4 = "TOST Auto MkClanTeams"; break;
	}
}


//----------------------------------------------------------------------------
// TOST Settings Handling
//----------------------------------------------------------------------------
function GetSettings(TOSTPiece Sender)
{
	local	int	Bits;

	Bits = 0;
	if (PlayerBackup)
		Bits += 1;
	if (TKHandling)
		Bits += 2;
	if (AutoMkTeams)
		Bits += 4;
	if (HPMessage)
		Bits += 8;
	if (EnhVoteSystem)
		Bits += 16;
	if (CWMode)
		Bits += 32;
	if (AutoMkClanTeams)
		Bits += 64;

	Params.Param4 = string(((MaxRenames & 0xFF) << 24) + ((MaxTeamKills & 0xFF) << 16) + ((Bits & 0xFF) << 8));
	SendAnswerMessage(Sender, 143);
}

function SetSettings(TOSTPiece Sender, string Settings)
{
	local	int			i, j;
	local	string		s;
	local	bool		b;

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

		MaxRenames = ((i >> 24) & 0xFF);
		MaxTeamKills = ((i >> 16) & 0xFF);

		i = (i >> 8) & 0xFF;
		b = CWMode;

		PlayerBackup = ((i & 1) == 1);
		TKHandling = ((i & 2) == 2);
		AutoMkTeams = ((i & 4) == 4);
		HPMessage = ((i & 8) == 8);
		EnhVoteSystem = ((i & 16) == 16);
		CWMode = ((i & 32) == 32);
		AutoMkClanTeams = ((i & 32) == 64);

		if (b != CWMode)
		{
			Params.Param5 = CWMode;
			SendMessage(BaseMessage + 17);
		}
	}
	SaveConfig();
}

function	GetValue(PlayerPawn	Player, TOSTPiece Sender, int Index)
{
	Params.Param1 = Index;
	Params.Param6 = Player;

	switch (Index)
	{
		// only allow REAL admins to get the admin pass, regardless of CheckClearance
		case 100 :	if (Player.PlayerReplicationInfo.bAdmin)
						Params.Param4 = Level.Game.ConsoleCommand("get Engine.GameInfo AdminPassword");
				    break;
		case 101 :	Params.Param4 = Level.Game.ConsoleCommand("get Engine.GameInfo GamePassword");
					break;
		case 102 :	Params.Param2 = s_SWATGame(Level.Game).TimeLimit;
					break;
		case 103 :	Params.Param2 = s_SWATGame(Level.Game).RoundDuration;
					break;
		case 104 :	Params.Param5 = s_SWATGame(Level.Game).bEnableBallistics;
					break;
		case 105 :	Params.Param5 = s_SWATGame(Level.Game).bAllowGhostCam;
					break;
		case 106 :	Params.Param5 = s_SWATGame(Level.Game).bAllowPunishTK;
					break;
		case 107 :	Params.Param5 = EnhVoteSystem;
					break;
		case 108 :	Params.Param5 = AutoMkTeams;
					break;
		case 109 :	Params.Param5 = PlayerBackup;
					break;
		case 110 :	Params.Param2 = int((s_SWATGame(Level.Game).FriendlyFireScale * 100) + 0.01); // fix for rouding error at 0.53
					break;
		case 111 :	Params.Param5 = s_SWATGame(Level.Game).bExplosionFF;
					break;
		case 112 :	Params.Param5 = s_SWATGame(Level.Game).bMirrorDamage;
					break;
		case 113 :	Params.Param5 = TKHandling;
					break;
		case 114 :	Params.Param2 = MaxTeamKills;
					break;
		case 115 :	Params.Param2 = s_SWATGame(Level.Game).MinAllowedScore;
					break;
		case 116 :	Params.Param5 = HPMessage;
					break;
		case 125 :	Params.Param5 = CWMode;
					break;
		case 126 :	Params.Param2 = s_SWATGame(Level.Game).RoundLimit;
					break;
		case 127 :	Params.Param5 = s_SWATGame(Level.Game).bAllowBehindView;
					break;
		case 140 :	Params.Param4 = SlotReserverPass;
					break;
		case 141 :	Params.Param2 = SlotReserverNumber;
					break;
		case 142 :	Params.Param2 = FirstPreRound;
					break;
		case 143 :	Params.Param2 = MaxWarnings;
					break;
		case 144 :	Params.Param4 = ClanTag;
					break;
		case 145 :	Params.Param5 = AutoMkClanTeams;
					break;
	}
	if ((Index >= 100 && Index <= 116) || (Index >= 125 && Index <= 127) || (Index >= 140 && Index <= 145))
	{
		if (Player != None)
			SendClientMessage(100);
		else
			SendAnswerMessage(Sender, 120);
	}
}

function	SetValue(PlayerPawn Player, int Index, int i, float f, string s, bool b)
{
	local	s_SWATGame				SG;
	local	s_GameReplicationInfo	GRI;

	SG = s_SWATGame(Level.Game);
	GRI = s_GameReplicationInfo(Level.Game.GameReplicationInfo);

	switch (Index)
	{
		// only allow REAL admins to set the admin pass, regardless of CheckClearance
		case 100 :	if (Player == none || Player.PlayerReplicationInfo.bAdmin)
						Level.Game.ConsoleCommand("set Engine.GameInfo AdminPassword"@s);
				    break;
		case 101 :	UpdateSlotReserver(false, true,s);
					break;
		case 102 :	SG.TimeLimit = i;
					GRI.TimeLimit = i;
					break;
		case 103 :	SG.RoundDuration = i;
					GRI.RoundDuration = i;
					break;
		case 104 :	SG.bEnableBallistics = b;
					GRI.bEnableBallistics = b;
					break;
		case 105 :	SG.bAllowGhostCam = b;
					GRI.bAllowGhostCam = b;
					break;
		case 106 :	SG.bAllowPunishTK = b;
					break;
		case 107 :	EnhVoteSystem = b;
					break;
		case 108 :	AutoMkTeams = b;
					break;
		case 109 :	PlayerBackup = b;
					break;
		case 110 :	SG.FriendlyFireScale = float(i)/100.0;
					GRI.FriendlyFireScale = i;
					break;
		case 111 :	SG.bExplosionFF = b;
					break;
		case 112 :	SG.bMirrorDamage = b;
					GRI.bMirrorDamage = b;
					break;
		case 113 :	TKHandling = b;
					break;
		case 114 :	MaxTeamKills = i;
					break;
		case 115 :	SG.MinAllowedScore = i;
					break;
		case 116 :	HPMessage = b;
					break;
		case 125 :	if (CWMode != b)
					{
						CWMode = b;
						Params.Param5 = b;
						SendMessage(BaseMessage + 17);
						UpdateSlotReserver();
					}
					break;
		case 126 :	SG.RoundLimit = i;
					break;
		case 127 :	SG.bAllowBehindView = b;
					break;
		case 140 :	SlotReserverPass = s;
					break;
		case 141 :	SlotReserverNumber = i;
					break;
		case 142 :	FirstPreRound = i;
					break;
		case 143 :	MaxWarnings = i;
					break;
		case 144 :	ClanTag = s;
					break;
		case 145 :	AutoMkClanTeams = b;
					break;
	}
	SG.SaveConfig();
	SaveConfig();
}


//----------------------------------------------------------------------------
// Check for updates
//----------------------------------------------------------------------------
// * RequestUpdates - Spawn the HTTPLink and request update list
function RequestUpdates()
{
	// autoupdate
	if (GetCurrentTimeStamp() > LastUpdate)
	{
		xLog("Request Piece version list");
		HTTPLink = spawn(class'HTTPTransfer', self);
		HTTPLink.Master = self;
		HTTPLink.Method = HTTP_GET;
		HTTPLink.HostName = UpdateHost;
		HTTPLink.Request = UpdateScript;
		HTTPLink.Connect();
	}
	else
	{
		dLog("Skipped update check");
		SetOutdatedWarning();
	}
}

// * RecieveUpdates - Recieve list from HTTPLink and save them ini
function RecieveUpdates()
{
	local int i;
	local string temp;

 	// Notify players of the upload result
	if (HTTPLink.bTransferFailed)
	{
		xLog("Could not check for updates, Transfer failed");
	}
	else
	{
		for(i=0;i<32;i++)
		{
			if (HTTPLink.ResponseName[i] != "")
			{
				PieceVersions[i] = HTTPLink.ResponseName[i] $ "|" $ HTTPLink.ResponseValue[i];
				dLog("Recieved"@PieceVersions[i]);
			}
			else
			{
				PieceVersions[i] = "";
			}
		}
		// Set next update
		LastUpdate = GetFutureTimeStamp(0,0,0,UpdateDelay,0);
		SaveConfig();
		xLog("Recieved version list");
	}
	HTTPLink.Destroy();
	SetOutdatedWarning();
}

function bool IsOutdated(string sPieceName, string sVersion)
{
	local int i, j;
	local string temp, sNewVersion;

	for(i=0;i<32;i++)
	{
		SplitStr(PieceVersions[i], "|",temp, sNewVersion);
		if(temp == sPieceName)
			break;
	}
	if(i==32)
		return false;

	sVersion = sVersion $ ".";
	sNewVersion = sNewVersion $ ".";
	while (sNewVersion != "" && sVersion != "")
	{
		i = Instr(sNewVersion,".");
		j = Instr(sVersion,".");

		if(int(Left(sNewVersion,i)) > int(Left(sVersion,j)))
			return true;
		else if(int(Left(sNewVersion,i)) < int(Left(sVersion,j)))
			return false;

		sVersion = Mid(sVersion,j+1);
		sNewVersion = Mid(sNewVersion,i+1);
	}
	return false;
}

function SetOutdatedWarning()
{
	local TOSTPiece	next;
	local int		NumOutdated;
	local string	temp, TOSTVersion;

	SplitStr(TOST.TOSTVersion, " ", temp, TOSTVersion);
	if	(IsOutdated("TOST",TOSTVersion))
	{
		OldVersionWarning = "Warning, TOST is outdated, type TOSTInfo for more details";
		IRCVersionWarning = "TOST is outdated! ("$TOST.TOSTVersion$")";
	}
	else
	{
		next = TOST.Piece;
		while (next != None)
		{
			if(IsOutdated(next.PieceName,next.PieceVersion))
			{
				dLog("Found outdated piece: "$next.PieceName$" ("$next.PieceVersion$")");
				IRCVersionWarning = IRCVersionWarning @ next.PieceName$"("$next.PieceVersion$")";
				NumOutdated++;
				temp = next.PieceName;
			}
			next = next.NextPiece;
		}

		if (IRCVersionWarning!="")
			IRCVersionWarning = "The following Piece(s) are outdated: " $Trim(IRCVersionWarning)$ "!";

		if ( NumOutdated > 1 )
			OldVersionWarning = "Warning, more TOST pieces are outdated, type TOSTInfo for more details";
		else if ( NumOutdated == 1 )
			OldVersionWarning = "Warning, '"$temp$"' is outdated, type TOSTInfo for more details";
	}

	if ( OldVersionWarning == "")
	{
		dLog("TOST is up-to-date");
	}
	else
	{
		dLog("Timer set, OldVersionWarning="$OldVersionWarning);
		SetTimer(300,true);
	}
}

//----------------------------------------------------------------------------
// Small helper functions
//----------------------------------------------------------------------------
// * IsMuted - Returns if a player is muted or not
function bool IsMuted(int PlayerIndex)
{
	if (PlayerIndex != -1)
		if ( (Memory[PlayerIndex].MuteTill == -1) || (Memory[PlayerIndex].MuteTill > Level.TimeSeconds) )
			return true;

	return false;
}

// * HasTag - Returns if a player's tag matched ClanTag or not
function bool HasTag(string PlayerName)
{
	return (InStr(Caps(PlayerName),Caps(ClanTag)) != -1);
}

// * GetHPArmor - get HP & Armor of given player
function string GetHPArmor(pawn Player)
{
	local string S;

	if(Player.Health > 0) {
		S = Player.Health$" HP";
		if(Player.IsA('s_Player')) {
			S = S$", "$(s_Player(Player).HelmetCharge + s_Player(Player).VestCharge + s_Player(Player).LegsCharge) / 3 $ " Armor";
		}
		else if(Player.IsA('s_Bot')) {
			S = S$", "$(s_Bot(Player).HelmetCharge + s_Bot(Player).VestCharge + s_Bot(Player).LegsCharge) / 3 $ " Armor";
		}
	} else {
		S = "dead";
	}

	return S;
}

// * GetWeapon - get weapon name of of current weapon of given player
function string GetWeapon(pawn Player)
{
	local string FirstChar;

	if(Player != none && Player.Weapon != none && Player.Weapon.ItemName != "") {
		FirstChar = Left ( Player.Weapon.ItemName, 1);
		if ( FirstChar ~= "a" || FirstChar ~= "e" || FirstChar ~= "i" || FirstChar ~= "o" || FirstChar ~= "u" )
			return " with an " $ Player.Weapon.ItemName;
		else
			return " with a " $ Player.Weapon.ItemName;
	} else {

		return " with an unknown weapon";
	}
}

// * GetDemoName - return a name: level-date-time
function string GetDemoName()
{
	return AlphaNumeric(Level.Title$"-"$PrePad(Level.Year)$"-"$PrePad(Level.Month)$"-"$PrePad(Level.Day)$"@"$PrePad(Level.Hour)$"H"$PrePad(Level.Minute));
}

//----------------------------------------------------------------------------
// defaultproperties
//----------------------------------------------------------------------------
defaultproperties
{
	PieceName="TOST Server Tools"
	PieceVersion="1.3.3.8"
	CountDown=0
	BaseMessage=100

	UpdateDelay=5
	UpdateHost="tost.tactical-ops.de"
	UpdateScript="http://tost.tactical-ops.de/DilDoG/tostversions.dat"

	MaxRenames=3
	PlayerBackup=true
	TKHandling=true
	MaxTeamKills=4
	MaxWarnings=2
	AutoMkTeams=true
	HPMessage=true
	EnhVoteSystem=true
	CWMode=false
	SlotReserverNumber=0
	SlotReserverPass=""
	ClanTag=""
	FirstPreRound=25
	LastUpdate=0
}
