//----------------------------------------------------------------------------
// Project : TOST
// File    : TOSTServerTools.uc
// Version : 1.1
// Author  : BugBunny
//----------------------------------------------------------------------------
// Version	Changes
// 0.5		+ first release
// 0.6		+ first beta release
// 1.0		+ first public release
// 1.1		# TO 340 compability
//----------------------------------------------------------------------------

class TOSTServerTools expands TOSTPiece config;

const	MemorySize = 75;

var	bool	StopRecursion;

struct PlayerBackup {
	var float 	Timestamp;
	var string 	PlayerName;
	var string 	IP;
	var int 	Money;
	var int		Score;
	var int 	Kills;
	var int 	Deaths;
	var int 	Round;
	var int 	PlayTime;
	var int 	Renames;
	var int		TKCount;
	var int		SALevel;
	var PlayerPawn	Player;
};

var PlayerBackup 	Memory[75];	// array size must be greater or equal to memorysize
var PlayerPawn		PendingPlayers[32];

var config	bool	RememberStats;
var config	int		RenameStopper;
var config	int		MaxTeamKills;
var config	bool	TKHandling;
var config	bool	AutoMkTeams;
var config	bool	HPMessage;
var config	bool	EnhVoteSystem;
var config	bool	CWMode;

var string			NextMapChosen;
var string			OldPassword;
var int				ProtectionCountDown;
var bool			ForcedRename;

// - helper

event	Destroyed()
{
	if (ProtectionCountDown > 0)
	{
    	ProtectionCountDown = 0;
        if (OldPassword != "") {
         	Level.ConsoleCommand("set engine.gameinfo GamePassword"@OldPassword);
        } else {
           	Level.ConsoleCommand("set engine.gameinfo GamePassword");
	    }
	}
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

	if(Player.Weapon.ItemName != "") {
		FirstChar = Left ( Player.Weapon.ItemName, 1);
		if ( FirstChar ~= "a" || FirstChar ~= "e" || FirstChar ~= "i" || FirstChar ~= "o" || FirstChar ~= "u" )
			return " with an " $ Player.Weapon.ItemName;
		else
			return " with a " $ Player.Weapon.ItemName;
	} else {
		return " with an unknown weapon";
	}
}

// * IPOnly - returns the IP without the port
function string IPOnly(string IP)
{
	local int i;

	i = InStr(IP, ":");

	if (i != -1)
		return Left(IP, i);
	else
		return IP;
}

// * FindPlayerMemory - find memory index of given player
function int	FindPlayerMemory(PlayerPawn Player)
{
	local int i;

	for (i=0; i<MemorySize; i++)
	{
		if (Memory[i].Player == Player)
			return i;
	}
	return -1;
}

// * FindPlayerBackup - check for reconnecting players
function int	FindPlayerBackup(string IP, string PlayerName)
{
	local	int	i, j, k;

	IP = IPOnly(IP);

	// scan for name first
	i = 0;
	while (i<MemorySize && Caps(Left(Memory[i].PlayerName, 20)) != Caps(Left(PlayerName, 20)))
		i++;
	if (i >= MemorySize-1)
		i = -1;

	// now scan for IP
	j = 0;
	k = -1;
	while (j<MemorySize)
	{
		// IP match (better than a name match) - only stored players
		if (Memory[j].IP == IP && Memory[j].Player == none)
		{
			k=j;
			if (i==j)			// Name & IP match (best case)
			{
				return i;
			}
		}
		j++;
	}
	if (k == -1) 	// no matching IP -> return name match index
		return i;
	else			// return matching IP index
		return k;
}

// * FindOldestBP - get the index of the player that was absent the longest time
function int FindOldestBP()
{
	local int i, j;
	j = 74;
	for (i=0; i<MemorySize; i++)
	{
		if (Memory[i].Timestamp < Memory[j].Timestamp && Memory[i].Player == none)
		{
			j=i;
		}
	}
	return j;
}

// * RefreshMemory - store all data of players
function	RefreshMemory()
{
	local	int		i;
	for (i=0; i<MemorySize; i++)
	{
		if (Memory[i].Player != none && Memory[i].Player.PlayerReplicationInfo.Team != 255)
		{
			Memory[i].Money = s_Player(Memory[i].Player).Money;
			Memory[i].Score = TO_PRI(Memory[i].Player.PlayerReplicationInfo).InflictedDmg;
			Memory[i].Round = s_GameReplicationInfo(Level.Game.GameReplicationInfo).RoundNumber;
			Memory[i].Kills = Memory[i].Player.PlayerReplicationInfo.Score;
			Memory[i].Deaths = Memory[i].Player.PlayerReplicationInfo.Deaths;
			Memory[i].Timestamp = Level.TimeSeconds;
			Memory[i].PlayTime = Level.TimeSeconds - Memory[i].Player.PlayerReplicationInfo.StartTime;
		}
	}
}

// * AnnounceRename - publish player renaming
function AnnounceRename(string OldName, string NewName, bool IsAlive, optional bool Forced)
{
	local Pawn P;
	local int  i;
	local string	s;

	if (Forced)
		s = "(forced by admin)";
	for( P=Level.PawnList; P!=None; P=P.nextPawn )
		if( P.bIsPlayer || MessagingSpectator(P) != None )
		{
			if (P.Health <= 0 || IsAlive) {
				NotifyPlayer(1, PlayerPawn(P), OldName@"is now known as"@NewName@s);
			} else {
				NotifyPlayer(2, PlayerPawn(P), OldName@"is now known as"@NewName@s);
			}
		}
	XLog(OldName$" is now known as "$NewName@s);
}

// * EraseStats - erase all memories of given player
function 	EraseStats(int PID, string PlayerName)
{
	local int i;

	for (i=0; i<MemorySize; i++)
	{
		if (Memory[i].Player != none && (Memory[i].Player.PlayerReplicationInfo.PlayerID == PID || Memory[i].Player.PlayerReplicationInfo.PlayerName == PlayerName))
		{
			Memory[i].IP = "";
			Memory[i].PlayerName = "";
			Memory[i].Score = 0;
			Memory[i].Money = 0;
			Memory[i].Deaths = 0;
			Memory[i].Kills = 0;
			Memory[i].Round = -1;
			Memory[i].PlayTime = 0;
			Memory[i].TKCount = 0;
			Memory[i].Timestamp = 0;
			Memory[i].SALevel = 0;
			return;
		}
	}
}

// * AddPlayer - add/refresh a newly connected player
function		AddPlayer(PlayerPawn P)
{
	local	int			i;

	i = FindPlayerBackup(P.GetPlayerNetworkAddress(), P.PlayerReplicationInfo.PlayerName);

	if (i != -1 && RememberStats) {
		// reconnect
		Memory[i].Timestamp = Level.TimeSeconds;
		if (P.PlayerReplicationInfo.PlayerName != Memory[I].PlayerName)
		{
			Memory[i].Renames--;
			if (Memory[i].Renames < 0 && RenameStopper != 0) {
				P.SetName(Memory[I].PlayerName);
				Memory[i].Player.PlayerReplicationInfo.PlayerName = Memory[I].PlayerName;
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
		Memory[i].SALevel = 0;
	} else {
		// new
		i = FindOldestBP();
		Memory[i].Timestamp = Level.TimeSeconds;
		Memory[i].PlayerName = P.PlayerReplicationInfo.PlayerName;
		Memory[i].IP = IPOnly(P.GetPlayerNetworkAddress());
		Memory[i].Money = s_Player(P).Money;
		Memory[i].Round = s_GameReplicationInfo(Level.Game.GameReplicationInfo).RoundNumber;
		Memory[i].Score = TO_PRI(P.PlayerReplicationInfo).InflictedDmg;
		Memory[i].Kills = P.PlayerReplicationInfo.Score;
		Memory[i].Deaths = P.PlayerReplicationInfo.Deaths;
		Memory[i].PlayTime = 0;
		Memory[i].Renames = RenameStopper;
		Memory[i].Player = P;
		Memory[i].TKCount = 0;
		Memory[i].SALevel = 0;
	}
}

// * LCTPlayer - return the player in the designated team that has logged on last ...
function	Pawn	LCTPlayer(int Team)
{
	local Pawn	ckPawn, clPawn;
	local bool	AdminCheck;
	local int	i;

   	// Initialize Lists
   	ckPawn=Level.Pawnlist;
  	clPawn=None;

   	// find first human Player on the designated team in the list
   	AdminCheck = false;
   	while (clPawn == None )
	{
    	if (ckPawn.IsA('s_Player') && ckPawn.PlayerReplicationInfo.Team == Team)
      	{
      		i = FindPlayerMemory(PlayerPawn(ckPawn));
      		if (i != -1 && (AdminCheck || (!(Memory[i].SALevel > 0) && !(ckPawn.PlayerReplicationInfo.bAdmin))))
	        	clPawn = ckPawn;
      	}
       	ckPawn = ckPawn.NextPawn;
       	if (ckPawn == none)
       	{
		   	ckPawn=Level.Pawnlist;
		   	AdminCheck = true;
       	}
   	}

    // find and return pointer to the player on the designated team that has logged on last
	for( ckPawn=Level.PawnList; ckPawn!=None; ckPawn=ckPawn.NextPawn )
	{
   		i = FindPlayerMemory(PlayerPawn(ckPawn));
   		if (i != -1 && (!(Memory[i].SALevel > 0) && !(ckPawn.PlayerReplicationInfo.bAdmin)))
   		{
	    	if (ckPawn.IsA('s_Player')
			  	&& ckPawn.PlayerReplicationInfo.Team == team
        	 	&& ckPawn.PlayerReplicationInfo.StartTime > clPawn.PlayerReplicationInfo.StartTime)
	      	{
    	     	clPawn = ckPawn;
      		}
      	}
   	}
   	return clPawn;
}

// * ChangeBombOwner - give the bomb to someone else ...
function	ChangeBombOwner(Pawn Pawn)
{
	s_C4(Pawn.FindInventoryType(class's_SWAT.s_C4')).destroy();
	s_SWATGame(Level.Game).GiveBomb();
}

// * PlayerChangeTeam - moves player to given team
function	PlayerChangeTeam(PlayerPawn Player, byte Team, bool RemoveWeapons)
{
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
}

// * MkTeams - even teams
function	MkTeams(bool RemoveWeapons, optional PlayerPawn Player)
{
	local	int		Tcount, TerrTeamCount, SwatTeamCount;
   	local	PlayerReplicationInfo PRI;

   	TerrTeamCount = 0;
   	SwatTeamCount = 0;
   	foreach AllActors(class'PlayerReplicationInfo', PRI) // get number of players per team
   	{
       	if (PRI.Team == 0) {
           	TerrTeamCount++;
       	} else {
           	if (PRI.Team == 1) {
           		SwatTeamCount++;
           	}
       	}
   	}
	TCount = (TerrTeamCount - SwatTeamCount)/2;

	if (TCount != 0)
	{
	   	while (TCount != 0)
	    {
	       	// switch teams
	       	if (TCount > 0)
	    	{
		        PlayerChangeTeam(PlayerPawn(LCTPlayer(0)), 1, RemoveWeapons);
		        TCount--;
		    } else {
		        PlayerChangeTeam(PlayerPawn(LCTPlayer(1)), 0, RemoveWeapons);
		        TCount++;
		    }
	    }
		if (Player != none)
	    	Level.Game.BroadcastMessage(PieceName@": Admin executed MkTeams");
	    else
	    	Level.Game.BroadcastMessage(PieceName@": Auto MkTeams executed");
    } else {
    	if (Player != none)
    		NotifyPlayer(1, Player, "MkTeams: teams are even");
    }
}

// * FTeamChg - force team change on player
function	FTeamChg(int PID, bool RemoveWeapons)
{
	local	PlayerPawn	Player;

	Player = FindPlayerByID(PID);
	if (Player != none)
	{
		// change teams
    	if (Player.PlayerReplicationInfo.Team == 0)
            PlayerChangeTeam(Player, 1, RemoveWeapons);
        else
            PlayerChangeTeam(Player, 0, RemoveWeapons);
        Level.Game.BroadcastMessage(PieceName@": Admin has forced a teamchange on :"@Player.PlayerReplicationInfo.PlayerName);
    }
}

// * KickBanTK - kick all players with negative score
function KickBanTK(optional int PID)
{
	local Pawn 		aPawn;
	local string 	IP;
	local int		i;

	for(aPawn=Level.PawnList; aPawn!=None; aPawn=aPawn.NextPawn )
   	{
   		if ((PID != 0 && aPawn.PlayerReplicationInfo.PlayerID != PID) || !aPawn.IsA('s_Player'))
   			continue;
   		i = FindPlayerMemory(PlayerPawn(aPawn));
       	// scan for player pawns (not admins) with score lower than 0 and kick them
       	if (aPawn.PlayerReplicationInfo.Score < 0 && !PlayerPawn(aPawn).bAdmin && NetConnection(PlayerPawn(aPawn).Player)!=None && i != -1 && Memory[i].SALevel == 0)
       	{
        	IP = PlayerPawn(aPawn).GetPlayerNetworkAddress();
        	if ( Level.Game.CheckIPPolicy(IP) )
   			{
				Params.Param4="teamkilling (Admin)";
				Params.Param5=true;
				Params.Param6=PlayerPawn(aPawn);
				SendMessage(191);
           		s_SWATGame(Level.Game).KickBan(PlayerPawn(aPawn), "Kickbanned for teamkilling");
           		Level.Game.BroadcastMessage(PieceName@": Admin has kickbanned"@aPawn.GetHumanName()@"for teamkilling!");
       		}
	 	}
   	}
}

// * TOSTInfo - send some TOST Infos to requesting player
function	TOSTInfo(PlayerPawn Player)
{
	local	TOSTPiece	next;

	NotifyPlayer(2, Player, TOST.TOSTVersion@"Info");
	NotifyPlayer(2, Player, "Loaded Pieces :");
	next = TOST.Piece;
	while (next != None)
	{
		NotifyPlayer(2, Player, " Piece :"@next.PieceName@"(Version"@next.PieceVersion$")");
		next = next.NextPiece;
	}
}

// * ChangeMap - change map instantly
function	ChangeMap(string Map, optional PlayerPawn Player)
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
		if (TOSTMapHandling(P).FindMapIndex(Map) != -1) {
			NextMapChosen = Map;
		} else {
			if (Player != None)
				NotifyPlayer(1, Player, PieceName@": Map"@Map@"does not exist on the server");
		}
	} else {
		NextMapChosen = Map;
	}
	if (NextMapChosen != "") {
		BroadcastClientMessage(110);
	} else {
		BroadcastClientMessage(111);
	}
}

// * Punish - punish player with damage or death (damage = 0)
function	Punish(PlayerPawn Player, int PID, optional int Damage)
{
	local	PlayerPawn	Victim;

	Victim = FindPlayerByID(PID);
	if (Victim != none)
	{
		if (Damage < 0)
		{
			if (Victim.Health < -Damage)
			{
				Victim.KilledBy( none );
				Level.BroadcastMessage(Player.PlayerReplicationInfo.PlayerName$" punishes "$Victim.PlayerReplicationInfo.PlayerName$" with death!");
	   		} else {
	   			Level.BroadcastMessage(Player.PlayerReplicationInfo.PlayerName$" punishes "$Victim.PlayerReplicationInfo.PlayerName$" with "$(Victim.Health + Damage)$"hp damage!");
				Victim.Health = -Damage;
	   		}
		} else {
			if (Damage == 0 || Victim.Health < Damage)
			{
				Victim.KilledBy( none );
				Level.BroadcastMessage(Player.PlayerReplicationInfo.PlayerName$" punishes "$Victim.PlayerReplicationInfo.PlayerName$" with death!");
	   		} else {
				Victim.Health -= Damage;
	   			Level.BroadcastMessage(Player.PlayerReplicationInfo.PlayerName$" punishes "$Victim.PlayerReplicationInfo.PlayerName$" with "$Damage$"hp damage!");
	   		}
	   	}
   	}
}

// * Kick - kick player
function	Kick(PlayerPawn Player, int PID, string PlayerName, bool EraseStats)
{
	local	PlayerPawn	Victim;

	if (PlayerName != "")
		Victim = FindPlayerByName(PlayerName);
	if (Victim == None)
		Victim = FindPlayerByID(PID);
	if (Victim != None)
	{
		if (Player != None)
			NotifyAll(0, Player.PlayerReplicationInfo.PlayerName$" kicked "$Victim.PlayerReplicationInfo.PlayerName);
		else
			NotifyAll(0, Victim.PlayerReplicationInfo.PlayerName$" was kicked for "$PlayerName);
		if (EraseStats)
		{
			Params.Param1 = PID;
			Params.Param4 = PlayerName;
			SendMessage(101);
		}
		Params.Param4="";
		Params.Param5=false;
		Params.Param6=Victim;
		SendMessage(191);
		TO_GameBasics(Level.Game).Kick(Victim);
	}
}

// * TempKickBan - tempkickban player
function	TempKickBan(PlayerPawn Player, int PID, string PlayerName, int Days, int Mins)
{
	local	PlayerPawn	Victim;
	local	TOSTBanList	BanList;

	if (PlayerName != "")
		Victim = FindPlayerByName(PlayerName);
	if (Victim == None)
		Victim = FindPlayerByID(PID);
	if (Victim != None)
	{
		Params.Param4="";
		Params.Param5=true;
		Params.Param6=Victim;
		SendMessage(191);
		BanList = TOSTBanList(TOST.GetPieceByName("TOST Ban List"));
		// handled by ban list ?
		if (BanList == none || (Days == 0 && Mins == 0))
		{
			// no - do the standard stuff
			if (Player != None)
			{
				NotifyAll(0, Player.PlayerReplicationInfo.PlayerName$" tempkickbanned "$Victim.PlayerReplicationInfo.PlayerName);
				TO_GameBasics(Level.Game).TempKickBan(Victim, "Admin :"$Player.PlayerReplicationInfo.PlayerName);
			} else {
				NotifyAll(0, Victim.PlayerReplicationInfo.PlayerName$" was tempkickbanned for "$PlayerName);
				TO_GameBasics(Level.Game).TempKickBan(Victim, PlayerName);
			}
		} else {
			// special banlist stuff
			if (Player != None)
			{
				NotifyAll(0, Player.PlayerReplicationInfo.PlayerName$" tempkickbanned "$Victim.PlayerReplicationInfo.PlayerName@"for"@Days@"days and"@Mins@" minutes.");
				BanList.AddIP(IPOnly(Victim.GetPlayerNetworkAddress()), Days, Mins);
				TO_GameBasics(Level.Game).Kick(Victim);
			} else {
				NotifyAll(0, Victim.PlayerReplicationInfo.PlayerName$" was tempkickbanned for "$PlayerName@"for"@Days@"days and"@Mins@" minutes.");
				BanList.AddIP(IPOnly(Victim.GetPlayerNetworkAddress()), Days, Mins);
				TO_GameBasics(Level.Game).Kick(Victim);
			}
		}
	}
}

// * KickBan - kickban player
function	KickBan(PlayerPawn Player, int PID, string PlayerName)
{
	local	PlayerPawn	Victim;

	if (PlayerName != "")
		Victim = FindPlayerByName(PlayerName);
	if (Victim == None)
		Victim = FindPlayerByID(PID);
	if (Victim != None)
	{
		Params.Param4="";
		Params.Param5=true;
		Params.Param6=Victim;
		SendMessage(191);
		if (Player != None) {
			NotifyAll(0, Player.PlayerReplicationInfo.PlayerName$" kickbanned "$Victim.PlayerReplicationInfo.PlayerName);
			TO_GameBasics(Level.Game).KickBan(Victim, "Admin :"$Player.PlayerReplicationInfo.PlayerName);
		} else {
			NotifyAll(0, Victim.PlayerReplicationInfo.PlayerName$" was kickbanned for "$PlayerName);
			TO_GameBasics(Level.Game).KickBan(Victim, PlayerName);
		}
	}
}

// * AdminReset - restart map
function 	AdminReset()
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
function	EndRound()
{
	s_SWATGame(Level.Game).RoundEnded();
	s_SWATGame(Level.Game).RestartRound();
}

// * SASay - send a message to all players on the screencenter
function SASay(string Msg)
{
	local Pawn P;

	for( P=Level.PawnList; P!=None; P=P.nextPawn )
		if( P.IsA('PlayerPawn') )
		{
			PlayerPawn(P).ClearProgressMessages();
			PlayerPawn(P).SetProgressTime(6);
			PlayerPawn(P).SetProgressMessage(Msg,0);
		}
}

// * ProtectSrv - apply random pasword for given time to the server
function ProtectSrv(PlayerPawn Sender, optional int Duration)
{
	local int 	i;
	local string GamePassword;

   	GamePassword = Level.ConsoleCommand("get engine.gameinfo GamePassword");    // check if password is on
	if ( ProtectionCountDown <= 0 ) {	// if password is turned on, delete it else set it
								        // get a random password
		if (GamePassword != "")
   	    	OldPassword = GamePassword;
       	for (i=0; i<6; i++)
        {
       	    GamePassword = GamePassword$Chr(65+Rand(26));
        }
       	Level.ConsoleCommand("set engine.gameinfo GamePassword"@GamePassword);
   	 	NotifyAll(0, "Server has been password protected ...");
   	 	if (Duration == 0)
	        ProtectionCountDown = 120;
	    else
	        ProtectionCountDown = Duration;
       	NotifyPlayer(0, Sender, "Password is '"$GamePassword$"' for"@ProtectionCountDown@"seconds");
       	SetTimer(ProtectionCountDown, false);
   	} else {
        ProtectionCountDown = 0;
   		SetTimer(0, false);
        if (OldPassword != "")
        {
         	Level.ConsoleCommand("set engine.gameinfo GamePassword"@OldPassword);
           	NotifyAll(0, "Password protection has been removed ...");
         	NotifyAll(0, "Old password has been restored ...");
         	OldPassword = "";
        } else {
           	Level.ConsoleCommand("set engine.gameinfo GamePassword");
           	NotifyAll(0, "Password protection has been removed ...");
	    }
    }
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
	if (P != none)
	{
		if ( (Level.Game != None) && Level.Game.AllowsBroadcast(Sender, Len(Msg)))
		{
			if (Level.Game.MessageMutator != None)
			{
				if ( Level.Game.MessageMutator.MutatorTeamMessage(Self, P, Sender.PlayerReplicationInfo, Msg, 'Whisper', true) )
					P.TeamMessage( Sender.PlayerReplicationInfo, "(Whisper)"@Msg, 'Say', true );
			} else
				P.TeamMessage( Sender.PlayerReplicationInfo, "(Whisper)"@Msg, 'Say', true );
		}
	}
}

// * ChangeMutator - edit mutator entry in TOSTServerActor
function	ChangeMutator(int Index, string Mutator)
{
	TOST.SA.ChangeMutatorEntry(Index, Mutator);
}

// * ChangePiece - change piece entry in TOSTServerMutator
function	ChangePiece(int Index, string Piece)
{
	TOST.ChangePieceEntry(Index, Piece);
}

// SApause - pause the game as semi admin
function    SApause(PlayerPawn Pauser)
{
    if (Level.Pauser=="")
        Level.Pauser = Pauser.PlayerReplicationInfo.PlayerName;
    else
        Level.Pauser="";
}

// * ProcessVotes - enhance vote system
function	ProcessVotes()
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

		j = FindPlayerMemory(PlayerPawn(P));

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
    			TO_GameBasics(Level.Game).TempKickBan(s_Player(P), "Voted out of the game.");
			}
		}
	}
}

// ChangeSALevel - keep track of SA level
function	ChangeSALevel (PlayerPawn Player, int Level)
{
	local	int	i;

	i = FindPlayerMemory(Player);
	if (i != -1)
		Memory[i].SALevel = Level;
}

// Force Rename - force name change on player (not affecting renamestopper)
function	ForceRename (int PID, string NewName)
{
	local	int i;
	local	PlayerPawn	Player;

	Player = FindPlayerByID(PID);
	if (Player != None && Player.PlayerReplicationInfo.PlayerName != NewName)
	{
		ForcedRename = true;
		AnnounceRename(Player.PlayerReplicationInfo.PlayerName, NewName, (Player.Health > 0), true);
		Player.SetName(NewName);
		i = FindPlayerMemory(Player);
		if (i != -1)
			Memory[i].PlayerName = NewName;
		ForcedRename = false;
	}
}

// * SETTINGS
function		GetSettings(TOSTPiece Sender)
{
	local	int	Bits;

	Bits = 0;
	if (RememberStats)
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

	Params.Param4 = string(((RenameStopper & 0xFF) << 24) + ((MaxTeamKills & 0xFF) << 16) + ((Bits & 0xFF) << 8));
	SendAnswerMessage(Sender, 143);
}

function		SetSettings(TOSTPiece Sender, string Settings)
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

		RenameStopper = ((i >> 24) & 0xFF);
		MaxTeamKills = ((i >> 16) & 0xFF);

		i = (i >> 8) & 0xFF;

		RememberStats = ((i & 1) == 1);
		TKHandling = ((i & 2) == 2);
		AutoMkTeams = ((i & 4) == 4);
		HPMessage = ((i & 8) == 8);
		EnhVoteSystem = ((i & 16) == 16);

		b = CWMode;
		CWMode = ((i & 32) == 32);

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
		case 109 :	Params.Param5 = RememberStats;
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
	}
	if ((Index >= 100 && Index <= 116) || (Index >= 125 && Index <= 127))
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
		case 101 :	Level.Game.ConsoleCommand("set Engine.GameInfo GamePassword"@s);
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
		case 109 :	RememberStats = b;
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
					}
					break;
		case 126 :	SG.RoundLimit = i;
					break;
		case 127 :	SG.bAllowBehindView = b;
					break;
	}
	SG.SaveConfig();
	SaveConfig();
}

// * EVENT HANDLING

function	EventPostInit()
{
	// propagate startup CW mode
	Params.Param5 = CWMode;
	SendMessage(BaseMessage + 17);

	super.EventPostInit();
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

function 	EventPlayerDisconnect(Pawn Player)
{
	local	int		i;

	i = FindPlayerMemory(PlayerPawn(Player));
	if (i != -1)
	{
		Memory[i].Player = none;
		Memory[i].SALevel = 0;
	}

	super.EventPlayerDisconnect(Player);
}

function 	EventNameChange(Pawn Other)
{
	local	int i;

	if (StopRecursion || ForcedRename)
		Super.EventNameChange(Other);
	else
	{
		i = FindPlayerMemory(PlayerPawn(Other));
		if (i==-1)
		{
			Super.EventNameChange(Other);
		} else {
            if (Other.PlayerReplicationInfo.PlayerName != Memory[I].PlayerName)
			{
				Memory[i].Renames--;
				if (Memory[i].Renames < 0 && RenameStopper != 0) {
					StopRecursion = true;
					NotifyPlayer(1, Memory[i].Player, "No more name changes allowed this map...");
					Memory[i].Player.SetName(Memory[I].PlayerName);
					Memory[i].Player.PlayerReplicationInfo.PlayerName = Memory[I].PlayerName;
					if (Memory[i].Renames < -RenameStopper)
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

function	EventGamePeriodChanged(int GP)
{
	local	int	i;
	// AutoMkTeams
	if (AutoMkTeams && GP==0 && !CWMode)
		MkTeams(false, none);
	// check for AdminReset -> reset backup data
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
		TO_DeathMatchPlus(Level.Game).EndTime = 0;
	}
	super.EventGamePeriodChanged(GP);
}

function 	EventScoreKill(Pawn Killer, Pawn Other)
{
	local	int		i;

	// TK Handling
	if(	Killer != none && Other != none && Killer.IsA('PlayerPawn') && Killer != Other && Killer.PlayerReplicationInfo.Team == Other.PlayerReplicationInfo.Team)
	{
		i = FindPlayerMemory(PlayerPawn(Killer));
		if (i != -1)
		{
			Memory[i].TKCount++;
			if (TKHandling && !CWMode)
			{
				if (Memory[i].TKCount > MaxTeamKills)
				{
					Params.Param4="too many teamkills";
					Params.Param5=true;
					Params.Param6=PlayerPawn(Killer);
					SendMessage(191);
					NotifyRest(0, PlayerPawn(Killer), Killer.PlayerReplicationInfo.PlayerName $" was tempkickbanned for too many teamkills.");
					s_SWATGame(Level.Game).TempKickBan(PlayerPawn(Killer), "Too many TeamKills!");
				} else {
					if(Memory[i].TKCount == MaxTeamKills)
						NotifyPlayer(1, PlayerPawn(Killer), "Your next teamkill will get you tempkickbanned!");
					else
						NotifyPlayer(1, PlayerPawn(Killer), "You have"@Memory[i].TKCount@"/"@MaxTeamKills@"teamkills.");
				}
			}
		}
	}
	Super.EventScoreKill(Killer, Other);
}

function	Timer()
{
	if (ProtectionCountDown > 0)
	{
		ProtectionCountDown = 0;
        if (OldPassword != "")
        {
         	Level.ConsoleCommand("set engine.gameinfo GamePassword"@OldPassword);
           	NotifyAll(0, "Password protection has been removed automatically...");
         	NotifyAll(0, "Old password has been restored ...");
         	OldPassword = "";
        } else {
           	Level.ConsoleCommand("set engine.gameinfo GamePassword");
           	NotifyAll(0, "Password protection has been removed automatically...");
	    }
	}
}

function	int		EventTimer()
{
	ProcessVotes();

	if (NextMapChosen != "")
		Level.ServerTravel(NextMapChosen$"?game=s_SWAT.s_SWATGame", false);

	return 0;
}

function bool 	EventBroadcastLocalizedMessage( Actor Sender, Pawn Receiver, out class<LocalMessage> Message, out optional int Switch, out optional PlayerReplicationInfo RelatedPRI_1, out optional PlayerReplicationInfo RelatedPRI_2, out optional Object OptionalObject )
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


function 	EventTakeDamage( out int ActualDamage, Pawn Victim, Pawn InstigatedBy, out Vector HitLocation, out vector Momentum, name DamageType)
{
	local 	int 	i;
	local 	Pawn 	P;
	local	int		rnd;

	// fix hossies kill score
	if (Victim.IsA('s_NPCHostage') && ActualDamage >= (Victim.Health - ActualDamage))
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

		if (instigatedBy.IsA('s_Player'))
		{
			TO_PRI(instigatedBy.PlayerReplicationInfo).InflictedDmg -= i;
   		} else {
			if (instigatedBy.IsA('s_Bot'))
			{
				TO_BRI(instigatedBy.PlayerReplicationInfo).InflictedDmg -= i;
			}
		}
	}

	if (!(InstigatedBy == none || Victim == none || (InstigatedBy.PlayerReplicationInfo.PlayerName == "Player" && InstigatedBy.PlayerReplicationInfo.PlayerID == 0)))
	{
		if (instigatedBy != none && Victim.IsA('s_Player') && Victim.Health-ActualDamage <= 0)
		{
			// TOStats support
			if(DamageType == 'explosion')
				TOST.LogHook.LogEventString(TOST.LogHook.GetTimeStamp()$Chr(9)$"killwid"$Chr(9)$InstigatedBy.PlayerReplicationInfo.PlayerID$Chr(9)$"3"$Chr(9)$Victim.PlayerReplicationInfo.PlayerID$Chr(9)$s_Weapon(Victim.Weapon).WeaponID);
			else
				TOST.LogHook.LogEventString(TOST.LogHook.GetTimeStamp()$Chr(9)$"killwid"$Chr(9)$InstigatedBy.PlayerReplicationInfo.PlayerID$Chr(9)$s_Weapon(InstigatedBy.Weapon).WeaponID$Chr(9)$Victim.PlayerReplicationInfo.PlayerID$Chr(9)$s_Weapon(Victim.Weapon).WeaponID);

			// HP Message
			if( HPMessage )
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

function	Tick(float Delta)
{
	local	int	i;
	local	Pawn	P;
	// check for players in queue
	for (i=0; i<32; i++)
	{
		if (PendingPlayers[i] != none && PendingPlayers[i].GetPlayerNetworkAddress() != "" && PendingPlayers[i].PlayerReplicationInfo.Team != 255)
		{
			AddPlayer(PendingPlayers[i]);
			PendingPlayers[i] = none;
		}
	}
	// refresh stats
	if (RememberStats)
		RefreshMemory();

	// fix behindview bug
	if (!TO_GameBasics(Level.Game).bAllowBehindView)
		for (P=Level.PawnList;P!=none;P=P.NextPawn)
		{
			if (s_Player(P) != none && !s_Player(P).bAdmin)
				P.bBehindView=false;
		}

}

// * MESSAGE HANDLING

function bool	EventCheckClearance(TOSTPiece Sender, PlayerPawn Player, int MsgType, out int Allowed)
{
	// allow TOSTInfo & Whisper for everyone
	if ((MsgType == BaseMessage+0) || (MsgType == BaseMessage+19))
	{
		Allowed = 1;
		return true;
	}

	// allow reading values
	if (MsgType == 120 && ((Sender.Params.Param1 >= 102 && Sender.Params.Param1 <= 116) || (Sender.Params.Param1 >= 125 && Sender.Params.Param1 <= 127)))
	{
		Allowed = 1;
		return true;
	}

	return super.EventCheckClearance(Sender, Player, MsgType, Allowed);
}

function	EventMessage(TOSTPiece Sender, int MsgIndex)
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
		case BaseMessage+2 :	MkTeams(Sender.Params.Param5, Sender.Params.Param6);
								break;
		// FTeamChg
		case BaseMessage+3 :	FTeamChg(Sender.Params.Param1, Sender.Params.Param5);
								break;
		// KickBanTK
		case BaseMessage+4 :	KickBanTK(Sender.Params.Param1);
								break;
		// ChangeMap
		case BaseMessage+5 :	ChangeMap(Sender.Params.Param4, Sender.Params.Param6);
								break;
		// Punish
		case BaseMessage+6 :	Punish(Sender.Params.Param6, Sender.Params.Param1, Sender.Params.Param2);
								break;
		// Kick
		case BaseMessage+7 :	Kick(Sender.Params.Param6, Sender.Params.Param1, Sender.Params.Param4, Sender.Params.Param5);
								break;
		// TempKickBan
		case BaseMessage+8 :	TempKickBan(Sender.Params.Param6, Sender.Params.Param1, Sender.Params.Param4, Sender.Params.Param2, int(Sender.Params.Param3));
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
		case BaseMessage+12 :	SASay(Sender.Params.Param4);
								break;
		// ProtectSrv
		case BaseMessage+13 :	ProtectSrv(Sender.Params.Param6, Sender.Params.Param1);
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

function		EventAnswerMessage(TOSTPiece Sender, int MsgIndex)
{
	switch (MsgIndex)
	{
		// SetSettings - report back error messages
		case 144 			:	SetSettings(Sender, Sender.Params.Param4);
								break;
	}
}

function	TranslateMessage(TOSTPiece Sender)
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
		case BaseMessage+13 : Sender.Params.Param4 = "ProtectSrv"; break;
		case BaseMessage+14 : Sender.Params.Param4 = "ShowIP"; break;
		case BaseMessage+15 : Sender.Params.Param4 = "ChangeMutator"; break;
		case BaseMessage+16 : Sender.Params.Param4 = "ChangePiece"; break;
		case BaseMessage+18 : Sender.Params.Param4 = "ForceName"; break;
		case BaseMessage+19 : Sender.Params.Param4 = "Whisper"; break;

		case 120			:
		case 121			: TranslateValueMessage(Sender); break;
		default : break;
	}
}

function	TranslateValueMessage(TOSTPiece Sender)
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
	}
}

defaultproperties
{
	bHidden=True

	PieceName="TOST Server Tools"
	PieceVersion="1.2.1.0"
	ServerOnly=true

	RememberStats=true
	RenameStopper=3
	TKHandling=true
	MaxTeamKills=4
	AutoMkTeams=true
	HPMessage=true
	EnhVoteSystem=true

	CountDown=0
	BaseMessage=100
}
