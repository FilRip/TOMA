//=============================================================================
// TO_GameBasics
//=============================================================================
//
// Tactical Ops
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen and Benoit "JAH" Delayen
//=============================================================================

class TO_GameBasics extends TO_TeamGamePlus
		config
		abstract;
//	config(TO_Game);


var enum EGamePeriod
{
	GP_PreRound,				// waiting for round to start
	GP_RoundPlaying,		// playing..
	GP_PostRound,				// round ended.. waiting to restart
	GP_RoundRestarting, // restarting the round
	GP_PostMatch,				// game ended
} GamePeriod;

var								byte							RoundLimit;
var								byte							RoundNumber;			// Round number in current map
var								byte							RoundDelay;				// Delay between 2 rounds
//var								bool							RoundPlaying;			// Are we playing ?
var								string						RoundReason;			// End round reason
var								bool							RoundRestarting;	// Are we restarting the round ?
var()			config	int								RoundDuration;		// Current round duration
var								int								RoundStarted;			// Server version of the RoundStarted
var()			config	int								PreRoundDuration1; // Delay to buy weapons at each begining of round
var								int								PreRoundDelay;		// Server version
//var								bool							bPreRound;				// PreRound ?
var								bool							bFirstKill;

var								int								CTAmount;						// Extra money awarded to CTs
var								int								TerrAmount;         // Extra money awarded to Terr
var								int								KillPrice;					// Money awarded when killing another player
var								int								KillHostagePrice;   // Money decreased when killing a hostage
var								int								WinAmount;          // Amount given to winning team
var								int								LostAmount;         // Amount given to loosing team
var								int								RescueAmount;				// Amount given to player that rescued a hostage
var								int								RescueTeamAmount;		// Amount given to Team that rescued a hostage
var								int								EvidenceAmount;     // Amount an evidence gives to team

var								byte							WinningTeam;				// Team that won the last round.
var								byte							LTLostRounds;				// How many rounds the loosing team lost

// Hostage Rescue
var								bool							bHasHostages;				// Map has hostages
var								bool							bHostageRescueWin;
var								byte							nbHostages;					// Number of hostages in the map
var								byte							nbRescuedHostages;	// Number of rescued hostages
var								byte							nbHostagesLeft;			// Hostages left in the level					

// Escape
var								byte							Escaped_Terr, Escaped_SF;

// Bomb defusion
var								bool							bBombDefusion;			// Map has bombdefusion mission
var								byte							BombTeam;						// Team dropping the bomb
var								bool							bBombDefusionWin;		// Prioritary objective ?
var								bool							bBombGiven;
var								bool							bBombPlanted;
var								bool							bGivingBomb;
var								bool							bBombDropped;
var								bool							bC4Explodes;	// Avoids winning the round by kills. But the C4 objective instead.


var								s_NPCHostageInfo	NPCHConfig;

// Actor lists
var								TO_ScenarioInfo		SI;
var								s_Ladder					s_Ladder;						// Registers ladders in the level
var								s_Trigger					s_Trigger;					// Registered Triggers;
var								TO_ConsoleTimerPN		CTLink;							// Registered TO_ConsoleTimer actors
var								s_ZoneControlPoint	ZCPLink;

var								bool							bOldZoomType;	// Handling zoom
	
// Server settings
var()	config	bool	bEnableBallistics;
var()	config	bool	bReduceSFX;
var()	config	bool	bDisableRealDamages;
var()	config	bool	bDisableIDLEManager;
var()	config	bool	bLinuxFix;
var()	config	bool	bDisableActorResetter;
var()	config	bool	bMirrorDamage;					// Mirror damage when attacking team mates
var()	config	bool	bExplosionsFF;					// Explosions hurt team mates?
var()	config	bool	bAllowGhostCam;					// Ghost cam allowed online?
var()	config	int		MinAllowedScore;			// minimum score allowed (against lamers/cheaters).
var		s_Player	NextTempKickBan;		// For delayed tempkickbanning with minallowedscore

// Resetting actors every round.
var	ActorList				ActorManager;

// IDLE Manager
var	TO_IDLEManager	IDLEManager;

var	int			MaxMoney;

var	String	TempBanList[50];

var	PlayerPawn	TO_LocalPlayer;

//
// Overridding functions
//

//function bool CanTranslocate(Bot aBot) {return false; } 

//
// Implemented in subclass
//

function RestartRound() {}
function BeginRound() {}
function GiveBomb() {}


///////////////////////////////////////
// PostBeginPlay()
///////////////////////////////////////

event PostBeginPlay()
{
	local int i;

	//log("TO_GameBasics::PostBeginPlay");

	Super.PostBeginPlay();

	if ( Level != None )
		Level.bNoCheating = false;
	
	// Removing level weapons and objects
	//spawn(class's_Replacer', self);	
//	spawn(class's_Remover', self);	
	
	RoundNumber = 0;
	MaxTeams = 2;
	RoundDuration = Default.RoundDuration;
	bTournament = false;
	TimeLimit = Default.TimeLimit;
	if (TimeLimit == 0)
	{
		TimeLimit = 15;
		Default.TimeLimit = 15;
	}
	RemainingTime = 60 * TimeLimit;
	s_GameReplicationInfo(GameReplicationInfo).RoundStarted = RemainingTime;
	s_GameReplicationInfo(GameReplicationInfo).RoundDuration = RoundDuration;
	RoundStarted = RemainingTime;

	//bRequireReady = false;

	//log("PostBeginPlay - Calling BeginRound()");

	// actor resetter
	if ( ActorManager != None )
		ActorManager.Destroy();

	if ( !bDisableActorResetter )
		ActorManager = Spawn(class'ActorResetter.ActorList', self);
	
	if ( ActorManager != None )
		ActorManager.BackupAll();

	// IDLE Manager
	if ( IDLEManager != None )
		IDLEManager.Destroy();

	if ( !bDisableIDLEManager )
		IDLEManager = Spawn(class's_SWAT.TO_IDLEManager');

	BeginRound();

	//if ( bRatedGame )
	//{
	//	FriendlyFireScale = 0;
	//	MaxTeams = 2;
	//}

}


///////////////////////////////////////
// Destroyed 
///////////////////////////////////////

event Destroyed()
{
	//log("TO_GameBasics::Destroyed");
	TO_CleanUp();

	Super.Destroyed();
}


function TO_CleanUp()
{
	local	TO_ScenarioInfoInternal SIint;

	//log("TO_GameBasics::TO_CleanUp");
	ForEach AllActors(class'TO_ScenarioInfoInternal', SIint)
		SIint.Destroy();

	//spawn(class's_Remover', self);	

	if ( ActorManager != None )
		ActorManager.Destroy();

	if ( IDLEManager != None )
		IDLEManager.Destroy();

	if ( NPCHConfig != None )
		NPCHConfig.Destroy();

	ClearNPC();
}


///////////////////////////////////////
// ProcessServerTravel
///////////////////////////////////////

function ProcessServerTravel( string URL, bool bItems )
{
	//log("TO_Gamebasics::ProcessServerTravel"@URL);
	TO_CleanUp();

	Super.ProcessServerTravel(URL, bItems);
}


///////////////////////////////////////
// InitGame
///////////////////////////////////////

event InitGame( string Options, out string Error )
{
	Super.InitGame(Options, Error);
 
	//log("InitGame - entering");

	GamePeriod = GP_RoundRestarting;

	MaxTeams = 2;
	RoundDuration = Default.RoundDuration;
	bTournament = false;
	bChangeLevels = true;
	TimeLimit = Default.TimeLimit;
	if ( TimeLimit == 0 )
	{
		TimeLimit = 15;
		Default.TimeLimit = 15;
	}
	RemainingTime = 60 * TimeLimit;
	//bRequireReady = false;
}


///////////////////////////////////////
// InitGameReplicationInfo
///////////////////////////////////////

function InitGameReplicationInfo()
{
	local	s_GameReplicationInfo GRI;

	Super.InitGameReplicationInfo();

	//log("InitGameReplicationInfo - entering");

	//s_GameReplicationInfo(GameReplicationInfo).RoundDuration = RoundDuration;
	GRI = s_GameReplicationInfo(GameReplicationInfo);

	GRI.RoundStarted = RemainingTime;
	GRI.RoundDuration = RoundDuration;
	GRI.bAllowGhostCam = bAllowGhostCam;
	GRI.bMirrorDamage = bMirrorDamage;
	GRI.bEnableBallistics = bEnableBallistics;
	GRI.FriendlyFireScale = int(FriendlyFireScale*100.0);
}


///////////////////////////////////////
// InitRatedGame
///////////////////////////////////////

// Set game settings based on ladder information.
// Called when RatedPlayer logs in.
function InitRatedGame(LadderInventory LadderObj, PlayerPawn LadderPlayer) {}


///////////////////////////////////////
// CheckReady
///////////////////////////////////////

function CheckReady()
{
	log("CheckReady - entering");

	MaxTeams = 2;
//	RoundDuration = Default.RoundDuration;
	bTournament = false;
	TimeLimit = Default.TimeLimit;
	if (TimeLimit == 0)
		{
			TimeLimit = 15;
			Default.TimeLimit = 15;
		}
	RemainingTime= 60 * TimeLimit;
	//bRequireReady = false;
}


///////////////////////////////////////
// SetEndCams
///////////////////////////////////////

function bool SetEndCams(string Reason)
{
	local TeamInfo BestTeam;
	local int i;
	local pawn P, Best;
	local PlayerPawn player;

	// find individual winner
	for ( P=Level.PawnList; P!=None; P=P.nextPawn )
		if ( P.bIsPlayer && ((Best == None) || (P.PlayerReplicationInfo.Score > Best.PlayerReplicationInfo.Score)) )
			Best = P;

	// find winner
	BestTeam = Teams[0];
	for ( i=1; i<MaxTeams; i++ )
		if ( Teams[i].Score > BestTeam.Score )
			BestTeam = Teams[i];

// Remove sudden death overtime
/*
	for ( i=0; i<MaxTeams; i++ )
		if ( (BestTeam.TeamIndex != i) && (BestTeam.Score == Teams[i].Score) )
		{
			BroadcastLocalizedMessage( class'DeathMatchMessage', 0 );
			return false;
		}		
*/
	GameReplicationInfo.GameEndedComments = TeamPrefix@BestTeam.TeamName@GameEndedMessage;

	EndTime = Level.TimeSeconds + 3.0;
	for ( P=Level.PawnList; P!=None; P=P.nextPawn )
	{
		player = PlayerPawn(P);
		if ( Player != None )
		{
			if (!bTutorialGame)
				PlayWinMessage(Player, (Player.PlayerReplicationInfo.Team == BestTeam.TeamIndex));
			player.bBehindView = true;
			if ( Player == Best )
				Player.ViewTarget = None;
			else
				Player.ViewTarget = Best;
			player.ClientGameEnded();
		}
		P.GotoState('GameEnded');
	}
	CalcEndStats();
	return true;
}


//------------------------------------------------------------------------------
// Player start functions


event PreLogin(String Options, string Address, out string Error, out string FailCode)
{
	Super.PreLogin(Options, Address, Error, FailCode);

	if ( IsTempBanned(Address) )
		Error = IPBanned;
}


final function string SetTeamOption(String Options, String Key, String NewVal)
{
	local	String	NewOptions, Tmp, TmpKey, TmpValue;
	local	int			i, j;	
	local	bool		bFound;

	// Processing all options
	while ( GrabOption(Options, Tmp) )
	{
		GetKeyValue(Tmp, TmpKey, TmpValue);
		if ( (Key ~= TmpKey) && (TmpValue != "") )
		{
			NewOptions = NewOptions$"?"$TmpKey$"="$NewVal;
			bFound = true;
		}
		else
			NewOptions = NewOptions$"?"$Tmp;
	}

	if ( !bFound )
		log("TO_GameBasics::SetTeamOption -"@Key@"key not found in options!");

	return NewOptions;
}


///////////////////////////////////////
// Login
///////////////////////////////////////

function playerpawn Login
(
	string Portal,
	string Options,
	out string Error,
	class<playerpawn> SpawnClass
)
{
	local PlayerPawn			newPlayer;
	local NavigationPoint StartSpot;
	local String					Message;
	local byte						InTeam;

	//log("TO_GameBasics::Login");

	// Make sure player starts in NO teams
	if ( GetIntOption(Options, "Team", 254) != 255 )
		Options = SetTeamOption(Options, "team", "255");

	newPlayer = Super.Login(Portal, Options, Error, SpawnClass);

	if ( NewPlayer != None )
	{
		NewPlayer.SetCollision(false,false,false);
		NewPlayer.EyeHeight = NewPlayer.BaseEyeHeight;
		NewPlayer.SetPhysics(PHYS_None);

		SetPlayerStartPoint( NewPlayer );

		// random team
		//NewPlayer.PlayerReplicationInfo.Team = 255;
		/*
		InTeam = NewPlayer.PlayerReplicationInfo.Team;

		// Update with ability to choose player class at startup
		if ( InTeam == 1 )
			SetRandomSFModel(NewPlayer);
		else
			SetRandomTerrModel(NewPlayer);

		SetVoiceType(NewPlayer.PlayerReplicationInfo);
		*/

		//NewPlayer.GotoState('PlayerWaiting');
	}

	return newPlayer;
}


///////////////////////////////////////
// PostLogin
///////////////////////////////////////

event PostLogin( playerpawn NewPlayer )
{
	local	s_Player	P;
/*
	if ( IsTempBanned(newPlayer.GetPlayerNetworkAddress()) )
	{
		log("TO_GameBasics::PostLogin - Player Temp banned! Kicking him:"@newPlayer.GetHumanName());
		newPlayer.bHidden = true;
		newPlayer.Destroy();
		return;
	}
*/
	P = s_Player(NewPlayer);

	if ( P == None )
		log("PostLogin - big problem, not an s_Player !!");

	Super.PostLogin(NewPlayer);

	if ( Level.NetMode != NM_Standalone )
		NewPlayer.ClientChangeTeam(NewPlayer.PlayerReplicationInfo.Team);

	// Local player (listen servers or stand alone games)
	if ( NetConnection(NewPlayer.Player) == None )
	{
		TO_LocalPlayer = NewPlayer;
		//log("TO_GameBasics::PostLogin - Found local player:"@NewPlayer.GetHumanName());
	}

	//ChangeModel(NewPlayer, P.PlayerModel);
	//P.NotPlaying = true;
	P.GotoState('PlayerWaiting');
/*
	if ( (GamePeriod == GP_RoundPlaying) && bFirstKill)
	{
		// Joined when game already began
		//s_Player(NewPlayer).Died( None, 'Suicided', NewPlayer.Location );
		NewPlayer.Suicide();
		P.PlayerReplicationInfo.Score = 0;
		P.PlayerReplicationInfo.Deaths = 0;
	}
	else if (GamePeriod == GP_PreRound)
		s_Player(NewPlayer).GotoState('PreRound');
*/
}


///////////////////////////////////////
// PlayerJoined
///////////////////////////////////////
// When player left player waiting state
// When chose a team after joining a game

final function PlayerJoined( s_Player P )
{
	//P.PlayerReplicationInfo.bWaitingPlayer = false;

	if ( (GamePeriod == GP_RoundPlaying) && bFirstKill)
	{
		// Joined when game already began
		P.Health = -1;
		//P.bHidden = true;
		P.HidePlayer();

		P.GotoState('PlayerSpectating');
		return;
	}

	if ( GamePeriod == GP_PreRound )
		P.GotoState('PreRound');
	else
		P.GotoState('PlayerWalking');

	SetPlayerStartPoint( P );
	
	AddDefaultInventory( P );
}


///////////////////////////////////////
// Logout
///////////////////////////////////////

function Logout(pawn Exiting)
{
	local	TO_PRI		TOPRI;
	local	Pawn	P;
	local	int i;

	//log("TO_GameBasics::VotePlayerOut");
	
	// Remove votes
	// To avoid having players connecting and disconnecting to vote someone out.
	if ( Exiting.IsA('s_Player') )
	{
		for ( P=Level.PawnList; P!=None; P=P.nextPawn )
		{
			if ( P.IsA('s_Player') && (P != Exiting) )
			{
				TOPRI = TO_PRI(P.PlayerReplicationInfo);
				i = 0;
				while ( i < 48 )
				{
					if ( TOPRI.VoteFrom[i] == Exiting.PlayerReplicationInfo )
					{
						TOPRI.VoteFrom[i] = None;
						break;
					}
					i++;
				}
			}
		}
	}

	DropInventory(Exiting, false);

	if ( Exiting.IsA('s_NPC') )
		return;

	Super.Logout(Exiting);

	ResetNPCPlayer(Exiting);
	CheckEndGame();
}


///////////////////////////////////////
// Kick
///////////////////////////////////////

final function Kick(PlayerPawn P)
{
	log("TO_GameBasics::Kick - Kicking"@P.GetHumanName());
	// we can't kick the owner of a listen server.
	if ( P != TO_LocalPlayer )
		P.Destroy();
}


///////////////////////////////////////
// KickBan
///////////////////////////////////////

final function KickBan(PlayerPawn P, string Reason)
{
	local	int	j;
	local string IP;

	// we can't kick the owner of a listen server.
	if ( P == TO_LocalPlayer )
		return;

	IP = P.GetPlayerNetworkAddress();
	if ( CheckIPPolicy(IP) )
	{
		IP = Left(IP, InStr(IP, ":"));
		for (j=0; j<50; j++)
			if( IPPolicies[j] == "" )
				break;

		if ( j < 50 )
		{
			Log("Adding IP Ban for:"@P.GetHumanName()@"IP:"@IP@"Reason:"@Reason);
			IPPolicies[j] = "DENY,"$IP;
			SaveConfig();
		}
		else
			Log(Reason@"- Couldn't IP Ban:"@P.GetHumanName()@"IP:"@IP@" NO FREE SLOTS!");
	}

	Kick(P);
}


///////////////////////////////////////
// TempKickBan
///////////////////////////////////////

final function TempKickBan(PlayerPawn P, string Reason)
{
	local	int			j;
	local string	IP;

	// we can't kick the owner of a listen server.
	if ( P == TO_LocalPlayer )
		return;

	IP = P.GetPlayerNetworkAddress();
	if ( !IsTempBanned(IP) )
	{
		IP = Left(IP, InStr(IP, ":"));
		for (j=0; j<50; j++)
			if( TempBanList[j] == "" )
			{
				Log("Adding TEMP IP Ban for:"@P.GetHumanName()@"IP:"@IP@"Reason:"@Reason);
				TempBanList[j] = IP;
				break;
			}
	}

	Kick(P);
}


///////////////////////////////////////
// IsTempBanned
///////////////////////////////////////

final function bool IsTempBanned(string IP)
{
	local int			i,p;
	local string	ShortIP;

	if ( IP == "" )
		return false;

	//log("TO_GameBasics::IsTempBanned - IP:"@IP);

	p = InStr(IP,":");
	if ( p > 0 )
	 ShortIP = left(IP, p);
	else
	 ShortIP = IP;

	//log("TO_GameBasics::IsTempBanned - ShortIP:"@ShortIP);

	for (i=0; i<50; i++)
		if ( TempBanList[i] == ShortIP )
		{
			//log("TO_GameBasics::IsTempBanned - Found IP:"@i@TempBanList[i]);
			return true;
		}

	return false;
}


///////////////////////////////////////
// AdminLogin
///////////////////////////////////////

function AdminLogin( PlayerPawn P, string Password )
{
	Super.AdminLogin(P, Password);

	if ( P.bAdmin )
		TO_PRI(P.PlayerReplicationInfo).AdminLoginTries = 0;
	else
	{
		TO_PRI(P.PlayerReplicationInfo).AdminLoginTries++;
		if ( TO_PRI(P.PlayerReplicationInfo).AdminLoginTries > 4 )
			KickBan(P, "Failed to give right AdminPassword after 5 tries.");
	}
}


///////////////////////////////////////
// AdminLogout
///////////////////////////////////////

function AdminLogout( PlayerPawn P )
{
	local float OldScore;

	if ( P.bAdmin )
	{
		P.bAdmin = false;
		P.PlayerReplicationInfo.bAdmin = false;
		if ( P.ReducedDamageType == 'All' )
			P.ReducedDamageType = '';

		Log("Administrator logged out.");
		BroadcastMessage( P.PlayerReplicationInfo.PlayerName@"gave up administrator abilities." );
	}
}


///////////////////////////////////////
// FindTeamByName
///////////////////////////////////////

// Find a team given its name
function byte FindTeamByName( string TeamName )
{
	local byte i;

	for ( i=0; i<MaxTeams; i++ )
		if ( Teams[i].TeamName == TeamName )
			return i;

	return 255; // No Team
}
	

///////////////////////////////////////
// FindPlayerStart
///////////////////////////////////////

function NavigationPoint FindPlayerStart( Pawn Player, optional byte InTeam, optional string incomingName )
{
	local PlayerStart		Dest, Candidate[30], Best;
	local float					Score[30], BestScore, NextDist;
	local pawn					OtherPlayer;
	local int						i, num;
//	local Teleporter		Tel;
	local NavigationPoint N;
	local byte					Team,  OldTeam;

/*	if ( bStartMatch && (Player != None) && Player.IsA('TournamentPlayer') 
		&& (Level.NetMode == NM_Standalone)
		&& (TournamentPlayer(Player).StartSpot != None) )
		return TournamentPlayer(Player).StartSpot;
*/
	/*if ( (Player != None) && (Player.PlayerReplicationInfo != None) )
		Team = Player.PlayerReplicationInfo.Team;
	else
		Team = InTeam;
	*/
	Team = InTeam;
	/*
	if( incomingName!="" )
		foreach AllActors( class 'Teleporter', Tel )
			if( string(Tel.Tag)~=incomingName )
				return Tel;
	*/
	if ( Team > 1 )
	{
		if ( FRand() > 0.5 )
			Team = 1;
		else
			Team = 0;
		//return Super.FindPlayerStart(Player, InTeam, incomingName );
		/*
		if (Player != None && Player.PlayerReplicationInfo != None)
			OldTeam = Player.PlayerReplicationInfo.Team;
		else
			OldTeam = 255;

		if (OldTeam < 2 && Teams[OldTeam].Size < Teams[1 - OldTeam].Size)
			Team = Player.PlayerReplicationInfo.Team;
		else
		{
			if (Teams[0].Size < Teams[1].Size)
				Team = 0;
			else
				Team = 1;
		}
		if (!ChangeTeam(Player, Team))
			return None;
		return Player.StartSpot;
		*/
	}
		
	num = 0;
	i = 0;
	//choose candidates	
	//for ( N=Level.NavigationPointList; N!=None; N=N.nextNavigationPoint )
	foreach AllActors( class'PlayerStart', Dest )
	{
		i++;
		if ( i>100 )
			break;

		//Dest = PlayerStart(N);
		if ( (Dest != None) && (Dest.bEnabled) && (Team == Dest.TeamNumber) )
		{
			//log("FindPlayerStart - Found a playerstart, team:"$Dest.TEamNumber);
			if ( num < 30 )
				Candidate[num] = Dest;
			else if ( (Rand(num) < 30) && (FRand() < 0.66) )
				Candidate[Rand(30)] = Dest;
			num++;
		}
	}

	if ( num == 0 )
	{
		i = 0;
		log("Didn't find any player starts in list for team"@Team@"!!!"); 
		foreach AllActors( class'PlayerStart', Dest )
		{
			i++;
			if ( i>100 )
				break;
			if (num < 30)
				Candidate[num] = Dest;
			else if (Rand(num) < 30)
				Candidate[Rand(30)] = Dest;
			num++;
		}
		if ( num == 0 )
		{
			log("FindPlayerStart - Returned None");
			return None;
		}
	}

	if ( num > 30) 
		num = 30;
	
	//assess candidates
	for (i=0; i < num; i++)
	{
//		if ( Candidate[i] == LastStartSpot )
//			Score[i] = -6000.0;
//		else
			Score[i] = 4000 * FRand(); //randomize
	}		
	
	for ( OtherPlayer=Level.PawnList; OtherPlayer!=None; OtherPlayer=OtherPlayer.NextPawn)	
		/*if ( OtherPlayer.bIsPlayer && (OtherPlayer.Health > 0) && !OtherPlayer.IsA('Spectator') 
			&& (OtherPlayer.PlayerReplicationInfo.Team == InTeam) )*/
			for (i=0; i<num; i++)
				if ( OtherPlayer.Region.Zone == Candidate[i].Region.Zone ) 
				{
					NextDist = VSize(OtherPlayer.Location - Candidate[i].Location);
					if ( NextDist < 40.0 )
						Score[i] -= 1000000.0;
				}
	
	BestScore = Score[0];
	Best = Candidate[0];
	for (i=1; i<num; i++)
		if (Score[i] > BestScore)
		{
			BestScore = Score[i];
			Best = Candidate[i];
		}
	//LastStartSpot = Best;
	
	//log("FindPlayerStart - return team "$Best.TeamNumber$" from player team "$Team);
	return Best;
}



//-------------------------------------------------------------------------------------
// Level gameplay modification


///////////////////////////////////////
// ReduceExplosions
///////////////////////////////////////

final function bool ReduceExplosions( name DamageType )
{
	if ( bExplosionsFF )
		return true;

	if ( (DamageType != 'heshockwave') && (DamageType != 'explosion') && (DamageType != 'Explosion') )
		return true;

	return false;
}


///////////////////////////////////////
// SWATReduceDamage
///////////////////////////////////////

final function int SWATReduceDamage(int Damage, name DamageType, pawn injured, pawn instigatedBy, Vector HitLocation)
{
	local int reducedamage;
/*
	if ( instigatedBy != None )
		log("TO_GameBasics::SWATReduceDamage -D:"@Damage@"-DT:"@DamageType@"-injured:"@injured@"-instigatedBy:"@instigatedBy@"-HL:"@HitLocation);
	else
		log("TO_GameBasics::SWATReduceDamage -D:"@Damage@"-DT:"@DamageType@"-injured:"@injured@"-instigatedBy: None -HL:"@HitLocation);
*/
	// Damage only enabled during round playing
	// But not for bots!!
	if ( GamePeriod != GP_RoundPlaying )
	{
		if ( injured.IsA('s_Player') )
			return 0;

		else if ( injured.IsA('Bot') && instigatedBy.IsA('Pawn') && (instigatedBy != injured) )
			return 0;
	}

/*
	// Handle stomped damage
	if ( injured.IsA('s_Player') && (DamageType=='stomped') )
	{
		if ( Damage < 20 )
			return 0;
	}
*/
	if ( bDisableRealDamages )
		damage /= 2;

	if (  injured.bIsPlayer && (instigatedBy != None) && instigatedBy.bIsPlayer 
	&& (injured.PlayerReplicationInfo.Team == instigatedBy.PlayerReplicationInfo.Team) && ReduceExplosions( DamageType ) )
	{
		if ( (instigatedBy != injured) && injured.IsA('Bot') )
			Bot(Injured).YellAt(instigatedBy);
		damage = Damage * FriendlyFireScale;
	}

	if ( damage == 0 )
		return 0;

	// Explosions hit the torso and not the legs!
	if ( (DamageType == 'heshockwave') || (DamageType == 'explosion') || (DamageType == 'Explosion') )
		HitLocation.Z = 1.0;

	// Falling damage isn't protected by armor anymore.
	if ( DamageType == 'Fell' )
		return Damage;

	if (injured.IsA('s_NPC'))
		reducedamage = SWAT_NPC_ReduceDamage(Damage, DamageType, s_NPC(Injured), InstigatedBy, HitLocation);
	else if (injured.IsA('s_Bot'))
		reducedamage = SWAT_BOT_ReduceDamage(Damage, DamageType, s_Bot(Injured), InstigatedBy, HitLocation);
	else if (injured.IsA('s_Player'))
		reducedamage = SWAT_PLAYER_ReduceDamage(Damage, DamageType, s_Player(Injured), InstigatedBy, HitLocation);

	if ( (reducedamage != 0) && bMirrorDamage )
	{
		if ( (PlayerPawn(InstigatedBy) != None )
			&& (Injured.PlayerReplicationInfo.Team == PlayerPawn(InstigatedBy).PlayerReplicationInfo.Team) )
		{
			InstigatedBy.TakeDamage(Damage * 2, None, InstigatedBy.Location, Vect(0,0,0), 'MirrorDamage');
		}
	}

	//if (Damage'decapitated') || (damageType == 'shot'
/*	if ( instigatedBy == None || DamageType == 'heshockwave')
		return Damage;


	else */
	return reducedamage;
}


///////////////////////////////////////
// SWAT_NPC_ReduceDamage
///////////////////////////////////////

final function int SWAT_NPC_ReduceDamage(int Damage, name DamageType, s_NPC injured, pawn instigatedBy, Vector HitLocation)
{
	local int reducedamage;
	local sound hitsound;
	local float FFS;

	reducedamage = damage;

	if (PlayerPawn(InstigatedBy)!= None 
		&& Injured.PlayerReplicationInfo.Team == PlayerPawn(InstigatedBy).PlayerReplicationInfo.Team
		&& ReduceExplosions( DamageType ) )
		FFS = FriendlyFireScale;
	else
		FFS = 1;

	if ( HitLocation.Z > 28 )
	{
		Damage *= 1.66; // Head damage
		HitSound = Sound'hithead';
		if ( Injured.HelmetCharge > 0 )
		{
			HitSound = Sound'hithelmet';
			reducedamage = Max(0, Damage - (Damage / 2.0) * Injured.HelmetCharge / 100);
			Injured.HelmetCharge = Max(0, (Injured.HelmetCharge - (damage - reducedamage) * FFS ) );
		}
		else
			reducedamage = Damage * 2;
	}
	else if ( HitLocation.Z > 0 )
	{
		HitSound = Sound'Hitflesh';
		if ( Injured.VestCharge > 0 )
		{
			HitSound = Sound'HitKevlar';
			reducedamage = Max(0, Damage - (Damage / 2.0 ) * Injured.VestCharge / 100);
			Injured.VestCharge = Max(0, (Injured.VestCharge - (damage - reducedamage) * FFS ) );
		}
	}
	else
	{
		Damage *= 0.66;
		HitSound = Sound'Hitflesh';
		if ( Injured.LegsCharge > 0 )
		{
			HitSound = Sound'HitKevlar';
			reducedamage = Max(0, Damage - (Damage / 2.0 ) * Injured.LegsCharge / 100);
			Injured.LegsCharge = Max(0, (Injured.LegsCharge - (damage - reducedamage) * FFS ) );
		}
	}

	if ( HitSound != None )
		Injured.PlaySound(HitSound, SLOT_NONE);

	return ReduceDamage;
}


///////////////////////////////////////
// SWAT_PLAYER_ReduceDamage
///////////////////////////////////////

final function int SWAT_Player_ReduceDamage(int Damage, name DamageType, s_Player injured, pawn instigatedBy, Vector HitLocation)
{
	local int reducedamage;
	local sound hitsound;
	local float FFS;

	reducedamage = damage;

	if (PlayerPawn(InstigatedBy)!= None 
		&& Injured.PlayerReplicationInfo.Team == PlayerPawn(InstigatedBy).PlayerReplicationInfo.Team
		&& ReduceExplosions( DamageType ) )
		FFS = FriendlyFireScale;
	else
		FFS = 1;

	if (HitLocation.Z > 28)
	{
		Damage *= 1.66; // Head damage
		HitSound = Sound'hithead';
		if (Injured.HelmetCharge > 0)
		{
			HitSound = Sound'hithelmet';
			reducedamage = Max(0, Damage - (Damage / 2.0) * Injured.HelmetCharge / 100);
			Injured.HelmetCharge = Max(0, (Injured.HelmetCharge - (damage - reducedamage) * FFS ) );
		}
		else
			reducedamage = Damage * 2;
	}
	else if (HitLocation.Z > 0)
	{
		HitSound = Sound'Hitflesh';
		if (Injured.VestCharge > 0)
		{
			HitSound = Sound'HitKevlar';
			reducedamage = Max(0, Damage - (Damage / 2.0 ) * Injured.VestCharge / 100);
			Injured.VestCharge = Max(0, (Injured.VestCharge - (damage - reducedamage) * FFS ) );
		}
	}
	else
	{
		Damage *= 0.66;
		HitSound = Sound'Hitflesh';
		if (Injured.LegsCharge > 0)
		{
			HitSound = Sound'HitKevlar';
			reducedamage = Max(0, Damage - (Damage / 2.0 ) * Injured.LegsCharge / 100);
			Injured.LegsCharge = Max(0, (Injured.LegsCharge - (damage - reducedamage) * FFS ) );
		}
	}

	if (HitSound!=None)
		Injured.PlaySound(HitSound, SLOT_NONE);

	return ReduceDamage;
}


///////////////////////////////////////
// SWAT_BOT_ReduceDamage
///////////////////////////////////////

final function int SWAT_Bot_ReduceDamage(int Damage, name DamageType, s_Bot injured, pawn instigatedBy, Vector HitLocation)
{
	local int reducedamage;
	local sound hitsound;
	local float FFS;

	reducedamage = damage;

	if (PlayerPawn(InstigatedBy)!= None 
		&& Injured.PlayerReplicationInfo.Team == PlayerPawn(InstigatedBy).PlayerReplicationInfo.Team
		&& ReduceExplosions( DamageType ) )
		FFS = FriendlyFireScale;
	else
		FFS = 1;

	if (HitLocation.Z > 28)
	{
		Damage *= 1.66; // Head damage
		HitSound = Sound'hithead';
		if (Injured.HelmetCharge > 0)
		{
			HitSound = Sound'hithelmet';
			reducedamage = Max(0, Damage - (Damage / 2.0) * Injured.HelmetCharge / 100);
			Injured.HelmetCharge = Max(0, (Injured.HelmetCharge - (damage - reducedamage) * FFS ) );
		}
		else
			reducedamage = Damage * 2;
	}
	else if (HitLocation.Z > 0)
	{
		HitSound = Sound'Hitflesh';
		if (Injured.VestCharge > 0)
		{
			HitSound = Sound'HitKevlar';
			reducedamage = Max(0, Damage - (Damage / 2.0 ) * Injured.VestCharge / 100);
			Injured.VestCharge = Max(0, (Injured.VestCharge - (damage - reducedamage) * FFS ) );
		}
	}
	else
	{
		Damage *= 0.66;
		HitSound = Sound'Hitflesh';
		if (Injured.LegsCharge > 0)
		{
			HitSound = Sound'HitKevlar';
			reducedamage = Max(0, Damage - (Damage / 2.0 ) * Injured.LegsCharge / 100);
			Injured.LegsCharge = Max(0, (Injured.LegsCharge - (damage - reducedamage) * FFS ) );
		}
	}

	if ( HitSound != None )
		Injured.PlaySound(HitSound, SLOT_NONE);

	return ReduceDamage;
}


///////////////////////////////////////
// CheckTK
///////////////////////////////////////

final function bool CheckTK( Pawn Other )
{
	if ( Level.NetMode == NM_StandAlone )
		return false;

	// Minimum score allowed. Against lamers, TK and cheaters.
	if ( (Other != None) && (MinAllowedScore > 0) 
		&& (Other.PlayerReplicationInfo.Score + MinAllowedScore < 0) && Other.IsA('s_Player') )
	{
		NextTempKickBan = s_Player(Other);
		//TempKickBan(NextTempKickBan, "Minimum allowed score reached: -"$MinAllowedScore);
		return true;
	}

	return false;
}


///////////////////////////////////////
// Killed
///////////////////////////////////////

function Killed( pawn killer, pawn Other, name damageType )
{
	local	Pawn										PawnLink;
	local s_Player								P;
	local	s_Bot										B;
	local	s_NPCHostage						H;
	local	PlayerReplicationInfo		VictimPRI, KillerPRI;

	//log("killed - Other: "$Other$" - Killer: "$Killer$" - damagetype: "$damageType);
	LogKillStats(Killer, Other, damagetype);

	if ( Other.IsA('s_NPC') )
	{
		if (s_NPCHostage(Other) != None)
		{
			H = s_NPCHostage(Other);
			/*
			foreach allactors(class's_Player', P)
				if (P != None)
					P.ClientPlaySound(Sound'hostagedown',, true);
			*/
			if ( (Killer != None) && (!Killer.IsA('s_NPC')) )
				AddMoney(Killer, KillHostagePrice);

			if ( (H.Followed != None) && (s_Bot(H.Followed) != None) )
			{
				if ( s_Bot(H.Followed).HostageFollowing > 0 )
					s_Bot(H.Followed).HostageFollowing--;
				if ( s_Bot(H.Followed).HostageFollowing < 1 )
					ClearBotObjective(s_Bot(H.Followed));
				//ClearBotObjective(s_Bot(H.Followed));
				//s_Bot(H.Followed).bHostageFollowing = false;
			}

			nbHostagesLeft--;
			// In case enough hostages were rescued.
			CheckHostageWin();
		}

		Other.PlayerReplicationInfo.bIsSpectator = true;
		return;
	}

	ResetNPCPlayer(Other);

	if ( BotConfig.bAdjustSkill && (killer.IsA('PlayerPawn') || Other.IsA('PlayerPawn')) )
  {
    if ( killer.IsA('Bot') )
      BotConfig.AdjustSkill(Bot(killer),true);

    if ( Other.IsA('Bot') )
      BotConfig.AdjustSkill(Bot(Other),false);
  }

	if ( Other.PlayerReplicationInfo != None ) 
	{
		VictimPRI = Other.PlayerReplicationInfo;
		Other.PlayerReplicationInfo.Deaths += 1;
		Other.PlayerReplicationInfo.bIsSpectator = true;
	}
	else 
		VictimPRI = None;

	DropInventory(Other, true);
	Other.DieCount++;

	if ( damageType == 'MirrorDamage' )
	{ 
		// Team Killer !!
		//Other.PlayerReplicationInfo.Score -= 1;
		AddMoney(Other, -4*KillPrice);

		//CheckTK(Other);
	}
	

	if ( (Killer == None) || (Killer == Other) ) 
	{
		//Other.PlayerReplicationInfo.Score -= 1;
		KillerPRI = None;
		CheckTK(Other);
	}
	else 
	{
		//log("TO_GameBasics::Killed - "@Other.GetHumanName()@"got killed by"@Killer.GetHumanName());
		bFirstKill = true;

		if ( (s_Bot(Killer) != None) && (s_Bot(Killer).LastObjective != '') )
			s_Bot(Killer).ResetLastObj();

		if ( !killer.IsA('s_NPC') )
		{
			if ( Killer.PlayerReplicationInfo != None )
			{
				KillerPRI = Killer.PlayerReplicationInfo;
				if ( Killer.PlayerReplicationInfo.Team != Other.PlayerReplicationInfo.Team )
				{
					killer.killCount++;
					Killer.PlayerReplicationInfo.Score += 1;
					AddMoney(Killer, KillPrice);
					//PlayRandEnemyDown(Killer);
				}
				else
				{ // Team Killer !!
					Killer.PlayerReplicationInfo.Score -= 1;
					if ( damageType != 'MirrorDamage' )
						AddMoney(Killer, -4*KillPrice);
					AddMoney(Other, 4*KillPrice);
				}
			}
			else
				KillerPRI = None;

			CheckTK( Killer );
		}
	}

	BaseMutator.ScoreKill(Killer, Other);

	PlaySoundDeath(Other);
	P = s_Player(Other);
	B = s_Bot(Other);

	if ( B != None )
	{
		ClearBotObjective(B);
		B.VestCharge=0;
		B.HelmetCharge=0;
		B.LegsCharge=0;
		B.bDead = true;
		B.bNotPlaying = true;
		Other.Health = -1;
	}
	else if ( P != None )
	{
		P.VestCharge = 0;
		P.HelmetCharge = 0;
		P.LegsCharge = 0;
		P.bHasNV = false;
		P.NV_off();
		if ( P.Flashlight != None )
		{
			P.Flashlight.Destroy();
			P.Flashlight = None;
		}
		//P.PlayerRestartState = 'PlayerSpectating';
		P.SetPhysics(PHYS_None);
		P.bDead = true;
		P.bNotPlaying = true;
		Other.Health = -1;
	}

	// Sending death message to players
	if ( VictimPRI != None )
	{
		for (PawnLink=Level.PawnList; PawnLink!=None; PawnLink=PawnLink.nextPawn)
		{
			if ( PawnLink.IsA('s_Player') && !s_Player(PawnLink).bHideDeathMsg )
				s_Player(PawnLink).HUD_Add_Death_Message(KillerPRI, VictimPRI);
		}
	}

	BotCheckOrderObject(Other);
	CheckEndGame();
	//ReBalance();
	//log("killed - end");
}


///////////////////////////////////////
// LogKillStats
///////////////////////////////////////

final function LogKillStats(Pawn Killer, Pawn Other, name damagetype)
{
	local String Message, KillerWeapon, OtherWeapon;

	if ( (damageType == 'Decapitated') && (Killer != Other) && (Killer != None) )
	{
		if (Level.Game.LocalLog != None)
			Level.Game.LocalLog.LogSpecialEvent("headshot", Killer.PlayerReplicationInfo.PlayerID, Other.PlayerReplicationInfo.PlayerID);
		if (Level.Game.WorldLog != None)
			Level.Game.WorldLog.LogSpecialEvent("headshot", Killer.PlayerReplicationInfo.PlayerID, Other.PlayerReplicationInfo.PlayerID);
	}

	if ( Other.bIsPlayer )
	{
		if ( (Killer != None) && (!Killer.bIsPlayer) )
		{
			if ( LocalLog != None )
				LocalLog.LogSuicide(Other, DamageType, None);
			if ( WorldLog != None )
				WorldLog.LogSuicide(Other, DamageType, None);
			return;
		}

		if ( (Killer == Other) || (Killer == None) )
		{
			// Suicide
			if (damageType == '')
			{
				if ( LocalLog != None )
					LocalLog.LogSuicide(Other, 'Unknown', Killer);
				if ( WorldLog != None )
					WorldLog.LogSuicide(Other, 'Unknown', Killer);
			} 
			else 
			{
				if ( LocalLog != None )
					LocalLog.LogSuicide(Other, damageType, Killer);
				if ( WorldLog != None )
					WorldLog.LogSuicide(Other, damageType, Killer);
			}
		} 
		else 
		{
			if ( Killer.bIsPlayer )
			{
				KillerWeapon = "None";
				if (Killer.Weapon != None)
					KillerWeapon = Killer.Weapon.ItemName;
				OtherWeapon = "None";
				if (Other.Weapon != None)
					OtherWeapon = Other.Weapon.ItemName;
				if ( Killer.PlayerReplicationInfo.Team == Other.PlayerReplicationInfo.Team )
				{
					if ( LocalLog != None )
						LocalLog.LogTeamKill(
							Killer.PlayerReplicationInfo.PlayerID,
							Other.PlayerReplicationInfo.PlayerID,
							KillerWeapon,
							OtherWeapon,
							damageType
						);
					if ( WorldLog != None )
						WorldLog.LogTeamKill(
							Killer.PlayerReplicationInfo.PlayerID,
							Other.PlayerReplicationInfo.PlayerID,
							KillerWeapon,
							OtherWeapon,
							damageType
						);
				} 
				else 
				{
					if ( LocalLog != None )
						LocalLog.LogKill(
							Killer.PlayerReplicationInfo.PlayerID,
							Other.PlayerReplicationInfo.PlayerID,
							KillerWeapon,
							OtherWeapon,
							damageType
						);
					if ( WorldLog != None )
						WorldLog.LogKill(
							Killer.PlayerReplicationInfo.PlayerID,
							Other.PlayerReplicationInfo.PlayerID,
							KillerWeapon,
							OtherWeapon,
							damageType
						);
				}
			}
		}
	}
}


///////////////////////////////////////
// ReBalance
///////////////////////////////////////

function ReBalance()
{
	local int big, small, i, bigsize, smallsize;
	local Pawn P, A;
	local Bot B;

	if ( bBalancing || (NumBots == 0) || !bBalanceTeams)
		return;

	big = 0;
	small = 0;
	bigsize = Teams[0].Size;
	smallsize = Teams[0].Size;
	for ( i=1; i<2; i++ )
	{
		if ( Teams[i].Size > bigsize )
		{
			big = i;
			bigsize = Teams[i].Size;
		}
		else if ( Teams[i].Size < smallsize )
		{
			small = i;
			smallsize = Teams[i].Size;
		}
	}
	
	bBalancing = true;
	while ( bigsize - smallsize > 1 )
	{
		for ( P=Level.PawnList; P!=None; P=P.NextPawn )
			if ( P.bIsPlayer && (P.PlayerReplicationInfo.Team == big)
				&& P.IsA('Bot') )
			{
				B = Bot(P);
				break;

			}
		if ( B != None )
		{
			B.Health = 0;
			B.Died( None, 'Suicided', B.Location );
			bigsize--;
			smallsize++;
			ChangeTeam(B, small);
		}
		else
			Break;
	}
	bBalancing = false;

	// re-assign orders to follower bots with no leaders
	for ( P=Level.PawnList; P!=None; P=P.NextPawn )
		if ( P.bIsPlayer && P.IsA('Bot') && (BotReplicationInfo(P.PlayerReplicationInfo).RealOrders == 'Follow') )
		{
			A = Pawn(Bot(P).OrderObject);
			if ( (A == None) || A.bDeleteMe || !A.bIsPlayer || (A.PlayerReplicationInfo.Team != P.PlayerReplicationInfo.Team) )
			{
				Bot(P).OrderObject = None;
				SetBotOrders(Bot(P));
			}
		}

}


///////////////////////////////////////
// SetPlayerStartPoint
///////////////////////////////////////

function SetPlayerStartPoint( pawn aPlayer )
{
	local NavigationPoint startSpot;
	local bool						foundStart;
	local	int							i;

	while ( !foundStart )
	{
		i++;
		if (i>50)
			break;

		startSpot = FindPlayerStart(aPlayer, aPlayer.PlayerReplicationInfo.Team);
		if( startSpot == None )
		{
			log(" Player start not found!!!");
			continue;
		}	

		foundStart = aPlayer.SetLocation(startSpot.Location);
		if ( !foundStart )
			log(startspot$" Player start not useable!!!");
	}

	aPlayer.ClientSetLocation(startSpot.Location, startSpot.Rotation );
	aPlayer.ClientSetRotation(startSpot.Rotation);

	aPlayer.SetRotation(startSpot.Rotation);
	aPlayer.ViewRotation = aPlayer.Rotation;
}


///////////////////////////////////////
// RestartPlayer
///////////////////////////////////////

function bool RestartPlayer( pawn aPlayer )	
{
	local NavigationPoint startSpot;
	local bool						foundStart;
	local int							check, i;
	local	s_Player				P;

	if ( aPlayer.IsA('s_NPC') )
	{
		aPlayer.Destroy();
		return false; 
	}

	P = s_Player(aPlayer);

	// Don't restart waiting players
	if ( (P != None) && P.PlayerReplicationInfo.bWaitingPlayer )
		return false;

	// Checking if player is dead
	if ( aPlayer.IsA('s_Bot') )
		check = int(s_Bot(aPlayer).bNotPlaying);
	else if ( P != None )
		check = int(P.bNotPlaying);
	else
		check = -1;

	if ( check == 1 )
	{
		// Player just died, send to spectating

		if ( aPlayer.IsA('s_Bot') )
		{
			aPlayer.PlayerReplicationInfo.bIsSpectator = true;
			aPlayer.GotoState('GameEnded');
			aPlayer.bAlwaysRelevant = false;
			return false; // bots don't respawn when ghosts
		}
		else if ( P != None )
		{
			//P.TOStandUp(true);
			//P.bHidden = true;
			//P.SetCollision( false, false, false );
			P.PlayerRestartState = 'PlayerSpectating';
			
			return true;
		}
	}
	else if ( check == 0 )
	{
		// Restart to play
		aPlayer.PlayerReplicationInfo.bIsSpectator = false;
		aPlayer.PlayerReplicationInfo.bWaitingPlayer = false;

		aPlayer.Acceleration = vect(0,0,0);
		aPlayer.Velocity = vect(0,0,0);
		aPlayer.Health = 100;

		if ( P != None )
			P.TOStandUp(true);
		else
			aPlayer.SetCollisionSize(aPlayer.Default.CollisionRadius, aPlayer.Default.CollisionHeight);

		aPlayer.SetCollision( true, true, true );

		aPlayer.bAlwaysRelevant = true;
		aPlayer.bHidden = false;
		aPlayer.DamageScaling = aPlayer.Default.DamageScaling;
		aPlayer.SoundDampening = aPlayer.Default.SoundDampening;

		addDefaultInventory(aPlayer);

		while ( !foundStart )
		{
			i++;
			if (i>50)
				break;

			startSpot = FindPlayerStart(aPlayer, aPlayer.PlayerReplicationInfo.Team);
			if ( startSpot == None )
			{
				log("TO_GameBasics::RestartPlayer - Player start not found!!! Add more player starts in your map!!");
				break;
			}	

			foundStart = aPlayer.SetLocation(startSpot.Location);
			if ( !foundStart )
				log(startspot$" Player start not useable!!!");
		}

		aPlayer.ClientSetLocation(startSpot.Location, startSpot.Rotation );
		aPlayer.ClientSetRotation(startSpot.Rotation);

		aPlayer.SetRotation(startSpot.Rotation);
		aPlayer.ViewRotation = aPlayer.Rotation;
			
		return foundStart;
	}
}


///////////////////////////////////////
// CheckEndGame
///////////////////////////////////////

function CheckEndGame()
{
	local Pawn PawnLink;
	local int StillPlaying;
	local int t_players, t_players_t, Players;
	local int ct_players, ct_players_t;
	local bool bStillHuman, bEmptyT, bEmptySF;
	local s_bot B, D;

	if ( bGameEnded || (GamePeriod != GP_RoundPlaying) )
		return;

	// Check to see if everyone is dead
	t_players = 0;
	ct_players = 0;
	for ( PawnLink=Level.PawnList; PawnLink!=None; PawnLink=PawnLink.nextPawn )
	{
		if ( (PawnLink.PlayerReplicationInfo != None) && !PawnLink.PlayerReplicationInfo.bWaitingPlayer )
		{
			if ( PawnLink.PlayerReplicationInfo.Team  == 0 )
					t_players_t++;
			else if ( PawnLink.PlayerReplicationInfo.Team  == 1 )
				ct_players_t++;

			if ( ((s_Player(PawnLink) != None) && (!s_Player(PawnLink).bNotPlaying)) 
				|| ((s_Bot(PawnLink) != None) && (!s_Bot(PawnLink).bNotPlaying)))
			{
				StillPlaying++;
				if ( s_Player(PawnLink) != None )
					Players++;
				if ( PawnLink.PlayerReplicationInfo.Team  == 0 )
					t_players++;
				else if ( PawnLink.PlayerReplicationInfo.Team  == 1 )
					ct_players++;
			}
		}
	}

	if ( bC4Explodes )
		return;

	bEmptyT = t_players_t == 0;
	bEmptySF = ct_players_t == 0;

	if ( bEmptyT || bEmptySF )
	{
		if ( (t_players_t+ct_players_t > 1) && bBalanceTeams)
			Rebalance();
		//return;
	}
	else if ( (t_players == 0) && (ct_players == 0) )
	{
		SetWinner(2);
		BroadcastLocalizedMessage(class's_MessageRoundWinner', 0);
		EndGame("Draw game");
		return;
	}

	if ( (t_players == 0) && !bBombPlanted && !bEmptyT )
	{
		SetWinner(1);
		if ( Escaped_Terr > 0 )
		{
			BroadcastLocalizedMessage(class's_MessageRoundWinner', 6);
			EndGame("Terrorists failed to escape!");
		}
		else
		{
			BroadcastLocalizedMessage(class's_MessageRoundWinner', 2);
			EndGame("Terrorists exterminated!");
		}
	}
	else if ( (ct_players == 0) && !bEmptySF )
	{
		SetWinner(0);
		if ( Escaped_SF > 0 )
		{
			BroadcastLocalizedMessage(class's_MessageRoundWinner', 7);
			EndGame("Special Forces failed to escape!");
		}
		// Avoid Draw games or Ts loosing when SF killed by C4
		else
		{
			BroadcastLocalizedMessage(class's_MessageRoundWinner', 1);
			EndGame("Special Forces exterminated!");
		}
	}

	if ( Players == 0 )
	{
		// no humans left - get bots to be more aggressive and finish up
		for ( PawnLink=Level.PawnList; PawnLink!=None; PawnLink=PawnLink.NextPawn )
		{
			B = s_Bot(PawnLink);
			if ( B != None && !B.bNotPlaying)
			{
				B.CampingRate = 0;
				B.Aggressiveness += 0.8;
				if ( D == None )
					D = B;
				else if ( B.Enemy == None )
					B.SetEnemy(D);
			}
		}
	}		
}


///////////////////////////////////////
// EndGame
///////////////////////////////////////

function EndGame( string Reason )
{
	local	Actor			A;

	// Overriding function to handle rounds
	if ( GamePeriod == GP_RoundPlaying )
	{
		RoundDelay = 5;
		GamePeriod = GP_PostRound;
		RoundReason = Reason;

		if ( LocalLog != None )
			LocalLog.LogEventString(LocalLog.GetTimeStamp()$Chr(9)$"round_end"$Chr(9)$WinningTeam$Chr(9)$RoundReason);
		if ( WorldLog != None )
			WorldLog.LogEventString(LocalLog.GetTimeStamp()$Chr(9)$"round_end"$Chr(9)$WinningTeam$Chr(9)$RoundReason);

		// End Round trigger message
		if ( (SI != None) && (SI.EventEndRound != '') )
		{
			foreach AllActors( class 'Actor', A, SI.EventEndRound )
				A.Trigger( None, None );
		}
	}
	else if ( RoundDelay < 1 )
	{
		if ( (RemainingTime < 1) || bOverTime)
			Super.EndGame(Reason);
		else
			RestartRound();
	}
}


///////////////////////////////////////
// IsRoundPeriodPlaying
///////////////////////////////////////

final function bool IsRoundPeriodPlaying()
{
	if ( GamePeriod == GP_RoundPlaying )
		return true;
	
	return false;
}


///////////////////////////////////////
// RoundEnded
///////////////////////////////////////

final function RoundEnded()
{
	local	Pawn			P;
	local	s_C4			C4;
	local	s_Weapon	W;

	//log("TO_GameBasics::RoundEnded");

	// Tell everyone the round has ended.
	for ( P=Level.PawnList; P!=None; P=P.nextPawn )
	{
		// Remove C4 bomb
		C4 = s_C4(P.FindInventoryType(class's_SWAT.s_C4'));	
		if ( C4 != None )
		{
			//log("TO_GameBasics::RoundEnded -"@P.GetHumanName()@"had C4, destroying..");
			//P.DeleteInventory(C4);
			C4.bPlanted = true;
			C4.Destroy();
			if ( P.Weapon == None )
				P.SwitchToBestWeapon();
		}

		// remove OICW
		w = s_weapon(P.FindInventoryType(class's_SWAT.s_OICW'));
		if ( w != None )
		{
			//P.DeleteInventory(w);
			w.destroy();
			if ( P.Weapon == None )
				P.SwitchToBestWeapon();
		}

		if ( P.IsA('s_Bot') )
			s_Bot(P).RoundEnded();
		else if ( P.IsA('s_Player') )
			s_Player(P).RoundEnded();
	}

}


///////////////////////////////////////
// SetWinner
///////////////////////////////////////

final function SetWinner(int WinTeam)
{
	local s_Player P;

	// Draw game
	if ( WinTeam == 2 )
	{
		WinningTeam = 2;
		return;
	}


	if ( WinningTeam != WinTeam )
	{
		LTLostRounds = 1;
		WinningTeam = WinTeam;
	}
	else if ( LTLostRounds < 3 )
		LTLostRounds++;
	
	// Wining team score
	Teams[WinTeam].Score += 1;

	// Awarding extra money
	if ( WinTeam == 1 )
	{
		CTAmount += WinAmount;
		TerrAmount += LostAmount * LTLostRounds;
	}
	else
	{
		TerrAmount += WinAmount;
		CTAmount += LostAmount * LTLostRounds;		
	}
}


///////////////////////////////////////
// SetMoney
///////////////////////////////////////

final function SetMoney()
{
	local pawn PawnLink;
	for ( PawnLink=Level.PawnList; PawnLink!=None; PawnLink=PawnLink.nextPawn )
	{
		if ( (PawnLink.PlayerReplicationInfo != None) && (!PawnLink.PlayerReplicationInfo.bWaitingPlayer) 
			&& (PawnLink.IsA('s_Player') || PawnLink.IsA('s_Bot')) )
		{
			if ( PawnLink.PlayerReplicationInfo.Team == 0 )
				AddMoney(PawnLink, TerrAmount);
			else 
				AddMoney( Pawnlink, CTAmount);
		}
	}

	CTAmount = 0;
	TerrAmount = 0;
}


///////////////////////////////////////
// Timer
///////////////////////////////////////

function Timer()
{
	local		Pawn						P;
	Local		s_NPCHostage		Hostage;
	local		s_Player				aPlayer;
	local		s_Bot						B;

	Super.Timer();

	// Make sure someone gets the bomb.
	if ( bBombDefusion && !bBombGiven )
		GiveBomb();

	if ( GamePeriod == GP_PostRound )
	{
		//Log("Waiting to restart round...");
		RoundDelay--;

		if ( RoundDelay == 4 )
		{
			// End round messages
			for ( P=Level.PawnList; P!=None; P=P.nextPawn )
			{
				aPlayer = s_Player(P);
				if ( aPlayer != None )
					ClientPlaySoundEndRound(aPlayer, WinningTeam);
					//PlayWinRoundSound(WinningTeam);
			}
		}

		if ( RoundDelay < 1 )
			EndGame(RoundReason);
		
		return;
	}
	else if ( GamePeriod == GP_PreRound )
	{
		/*
		if (PreRoundDelay==5)
		{
			// "5secb4assault"
			s_PlayDynamicTeamSound(17, GetRandTeamVoice(0), 0, true);
			s_PlayDynamicTeamSound(17, GetRandTeamVoice(1), 1, true);
		}
		*/
		//Log("Waiting to start round...");
		PreRoundDelay--;

		// Start Round !
		if ( PreRoundDelay <=0 )
			EndPreRound();
		else
		{
			for ( P=Level.PawnList; P!=None; P=P.nextPawn )
			{
				aPlayer = s_Player(P);
				B = s_Bot(P);
				
				if ( P.PlayerReplicationInfo.bWaitingPlayer )
					continue;

				if ( aPlayer != None )
				{
					if ( aPlayer.GetStateName() != 'PreRound' )
						aPlayer.GotoState('PreRound');
					//aPlayer.bNotPlaying = false;
					//aPlayer.bFire = 0;
				}
				else if ( B != None )
				{
					if ( !(B.GetStateName() == 'PreRound' || B.GetStateName() == 'BotBuying') )
						B.GotoState('PreRound');
				}
			}
		}

		// Skipping all the other checks while being in PreRound
		return;
	}

	if ( NextTempKickBan != None )
	{
		TempKickBan(NextTempKickBan, "Minimum allowed score reached: -"$MinAllowedScore);
		NextTempKickBan = None;
	}

	// Time limit
	if ( (RoundStarted - RemainingTime >= RoundDuration * 60) && (GamePeriod == GP_RoundPlaying) )
	{
		if ( SI != None )
		{
			BroadcastLocalizedMessage(class'TO_MessageCustom', 0, None, None, SI);
			if ( SI.DefaultLooser != ET_Both )
			{
				WinAmount += SI.WinAmount;
				SetWinner(1 - SI.DefaultLooser);
			}
			else 
				SetWinner(2);
		}
		else
		{
			BroadcastLocalizedMessage(class's_MessageRoundWinner', 0);
			SetWinner(2);
		}

		EndGame("Draw game");
	}

}


///////////////////////////////////////
// EndPreRound
///////////////////////////////////////
// Called when the PreRound ends, and RoundPlaying starts

final function EndPreRound()
{
	local		Pawn			P;
	local		s_Player	aPlayer;
	local		s_Bot			B;
	local		Actor			A;

	for ( P=Level.PawnList; P!=None; P=P.nextPawn )
	{
		aPlayer = s_Player(P);

		if ( aPlayer != None )
		{
			if ( P.PlayerReplicationInfo.bWaitingPlayer )
				continue;

			if ( P.Health < 100 )
				P.Health = 100;

			aPlayer.bNotPlaying = false;
			aPlayer.EndPreRound();
			aPlayer.SetPhysics(Phys_Walking);

			aPlayer.GoToState('PlayerWalking');
			ClientPlaySoundBeginRound(aPlayer);
		}
		else if ( P.IsA('s_Bot') )
		{
			s_Bot(P).GotoState('Startup');
			s_Bot(P).SetOrders('Freelance', None, true);
			GiveTeamWeapons(P);
		}
	}	

	//PlayStartRoundSound();
	s_GameReplicationInfo(GameReplicationInfo).bPreRound = false;
	RoundDuration = Default.RoundDuration;
	s_GameReplicationInfo(GameReplicationInfo).RoundDuration = Default.RoundDuration;
	s_GameReplicationInfo(GameReplicationInfo).RoundStarted = RemainingTime;
	RoundStarted = RemainingTime;			
	GamePeriod = GP_RoundPlaying;

	// Begin Round tigger message
	if ( (SI != None) && (SI.EventBeginRound != '') )
	{
		foreach AllActors( class 'Actor', A, SI.EventBeginRound )
			A.Trigger( None, None );
	}
}


///////////////////////////////////////
// Rescued
///////////////////////////////////////

final function Rescued(s_NPCHostage H)
{
	local	Pawn			PawnLink;
	local s_Bot			B;
	local	s_Player	P;

	if ( GamePeriod != GP_RoundPlaying )
		return;

	if ( (H.Followed != None) && (H.Followed.PlayerReplicationInfo != None) && (H.Followed.PlayerReplicationInfo.Team == 1) )
	{
		AddMoney(H.Followed, RescueAmount);
		CTAmount += RescueTeamAmount;
	}

	for (PawnLink=Level.PawnList; PawnLink!=None; PawnLink=PawnLink.nextPawn )
	{
		B = s_Bot(PawnLink);
		P = s_Player(PawnLink);
		
		if ( (B != None) && ( (B.OrderObject == H) || (B.MoveTarget == H) ) )
			ResetBotObjective(B, 1.0);

		if ( P != None )
			P.ClientPlaySound(Sound'we_have_hostage',, true);
	}
		
/*
	if (H.Followed!=None)
	{
		if (H.Followed.IsA('s_Bot'))
			s_PlayDynamicTeamSound(18, s_Bot(H.Followed).GetVoiceType(), 1);
		else if (H.Followed.IsA('s_Player'))
			s_PlayDynamicTeamSound(18, s_Player(H.Followed).GetVoiceType(), 1);
		else 
			s_PlayDynamicTeamSound(18, GetRandTeamVoice(1), 1);
	}
	else
		s_PlayDynamicTeamSound(18, GetRandTeamVoice(1), 1);		

	s_PlayDynamicTeamSound(18, GetRandTeamVoice(0), 0);
*/
	
	H.Destroy();
	nbRescuedHostages++;
	nbHostagesLeft--;

	CheckHostageWin();
}


///////////////////////////////////////
// CheckHostageWin
///////////////////////////////////////

final function CheckHostageWin()
{
	if ( bHasHostages && bHostageRescueWin && (nbHostagesLeft == 0) && (nbRescuedHostages >= nbHostages * 0.75) )
	{
		SetWinner(1);
		BroadcastLocalizedMessage(class's_MessageRoundWinner', 3);
		bHasHostages = false;
		EndGame("Hostages rescued !");
	}
}


///////////////////////////////////////
// Escape
///////////////////////////////////////

final function Escape(Pawn aPawn)
{
	local	s_Bot			B;
	local	s_Player	P;
	local	TO_PRI		TOPRI;
	local	TO_BRI		TOBRI;

	if ( GamePeriod != GP_RoundPlaying )
		return;

	B = s_Bot(aPawn);
	P = s_Player(aPawn);

	// prevent firing while escaping.
	aPawn.bFire = 0;

	if (P != None && !P.bNotPlaying)
	{
		TOPRI = TO_PRI(P.PlayerReplicationInfo);
		if (TOPRI != None)
		{
			TOPRI.bEscaped = true;
		}
		else 
			log("Escape - TOPRI == None");

		if ( P.Weapon != None )
			//P.Weapon.Gotostate('idle');
			P.Weapon = None;
		P.bNotPlaying = true;
		P.ReceiveLocalizedMessage(class's_SpecialMessages', 0);
		P.PlayerReplicationInfo.bIsSpectator = true;
		P.GotoState('PlayerSpectating');
		P.Health = -1;
		P.NV_off();
		P.bHasNV = false;
		if ( P.Flashlight != None )
			P.Flashlight.Destroy();
		//P.Model = None;
		BotCheckOrderObject(P);
		//P.bDead = true;
		P.SetPhysics(PHYS_None);
		//P.Weapon = None;
		if ( P.PlayerReplicationInfo.Team == 0 )
			Escaped_Terr++;
		else
			Escaped_SF++;
	}
	else if (B != None && !B.bNotPlaying)
	{
		TOBRI = TO_BRI(B.PlayerReplicationInfo);
		if (TOBRI != None)
		{
			TOBRI.bEscaped = true;
		}
		else 
			log("Escape - TOBRI == None");

		B.bNotPlaying = true;
		B.PlayerReplicationInfo.bIsSpectator = true;
		B.PlayerReplicationInfo.bWaitingPlayer = true;
		B.GotoState('GameEnded');
		B.Health = -1;
		B.Mesh = None;
		BotCheckOrderObject(B);
		B.SetPhysics(PHYS_None);
		//B.Weapon = None;
		if (B.PlayerReplicationInfo.Team == 0)
			Escaped_Terr++;
		else
			Escaped_SF++;
		//B.bDead = true;		
	}

	if ( (Escaped_Terr > 0) && (Escaped_Terr >= Teams[0].Size * 0.66) )
	{
		BroadcastLocalizedMessage(class's_MessageRoundWinner', 4);
		SetWinner(0);
		EndGame("Most of the Terrorists have escaped !");
		return;
	}

	if ( (Escaped_SF > 0) && (Escaped_SF >= Teams[1].Size * 0.66) )
	{
		BroadcastLocalizedMessage(class's_MessageRoundWinner', 5);
		SetWinner(1);
		EndGame("Most of the Special Forces have escaped !");
		return;
	}

	CheckEndGame();
}


///////////////////////////////////////
// SetupHostages
///////////////////////////////////////

final function SetupHostages()
{
	local s_NPCStartPoint	Dest;
	local NavigationPoint StartSpot;
	local bot							Hostage;
	local s_NPCHostage		Hostag;
	local int							i;

	bHasHostages = false;			
	nbHostages = 0;
	nbRescuedHostages = 0;
	nbHostagesLeft = 0;

	if ( NPCHConfig == None )
		NPCHConfig = Spawn(class's_SWAT.s_NPCHostageInfo');

	for ( i=0; i<32; i++ )
		NPCHConfig.ConfigUsed[i] = 0;

	foreach AllActors( class's_NPCStartPoint', Dest )
	{
		// Too many hostages = lag
		//if (nbHostages > 4)
		//	break;

		if ( (Dest != None) && (Dest.bHostage) )
		{
			StartSpot = Dest;
			Hostage = SpawnNPCH(StartSpot);
			Hostag = s_NPCHostage(Hostage);
			if ( Hostag != None )
			{ 
				Hostag.bIsFree = Dest.bIsFree;
				Hostag.NPCWAff = FRand();
				Hostag.bCanUseWeapon = false;
				Hostag.Tortionary = None;
				Hostag.SetVoice();
				nbHostages++;
			}
			else
				Log("Hostage Spawn Failed !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
		}
	}

	if ( nbHostages > 0 )
	{
		bHasHostages = true;
		nbHostagesLeft = nbHostages;
	}

}


///////////////////////////////////////
// ResetNPC
///////////////////////////////////////

final function ClearNPC()
{	
	Local		s_NPCHostage		Hostage;

	ForEach AllActors(class's_NPCHostage', Hostage)
	{
		if ( Hostage != None )
			Hostage.Destroy();
	}
}


///////////////////////////////////////
// ResetNPCPlayer
///////////////////////////////////////

final function ResetNPCPlayer( Pawn aPlayer)
{	
	Local		s_NPCHostage		Hostage;

	ForEach AllActors(class's_NPCHostage', Hostage)
	{
		if ( Hostage.Followed == aPlayer )
		{
			LockHostage(None, Hostage);
			//Hostage.Followed = None;
		}

		if ( Hostage.Enemy == aPlayer )
			Hostage.Enemy = None;
	}
}


///////////////////////////////////////
// ChangeTeam
///////////////////////////////////////

function bool ChangeTeam(Pawn Other, int NewTeam)
{
	local int i, s, DesiredTeam;
	local pawn APlayer, P;
	local teaminfo SmallestTeam;

	//log("TO_GameBasics::ChangeTeam - T:"@NewTeam@Other.GetHumanName());

	if ( NewTeam == 255 )
		return true;
	
	if ( Teams[0].Size > Teams[1].Size )
	{
		SmallestTeam = Teams[1];
		s = 1;
	}
	else
	{
		SmallestTeam = Teams[0];
		s = 0;
	}

	//log("TO_GameBasics::ChangeTeam - SmallestTeam:"@s);

/*
	if ( bPlayersBalanceTeams && (Level.NetMode != NM_Standalone) )
	{
		if ( NumBots == 1 )
		{
			// join bot's team, because he will leave
			for ( P=Level.PawnList; P!=None; P=P.NextPawn )
				if ( P.IsA('Bot') )
					break;
			
			if ( (P != None) && (P.PlayerReplicationInfo != None)
				&& (Teams[P.PlayerReplicationInfo.Team].Size == SmallestTeam.Size) )
			{					
				Other.PlayerReplicationInfo.Team = 255;
				NewTeam = P.PlayerReplicationInfo.Team;
			}
			else if ( (NewTeam >= MaxTeams) 
				|| (Teams[NewTeam].Size > SmallestTeam.Size) )
			{	
				Other.PlayerReplicationInfo.Team = 255;
				NewTeam = 255;
			}
		}
		else if ( (NewTeam >= MaxTeams) 
			|| (Teams[NewTeam].Size > SmallestTeam.Size) )
		{	
			Other.PlayerReplicationInfo.Team = 255;
			NewTeam = 255;
		}
	}
*/
	if ( NewTeam > 1 )
		NewTeam = s;

	if ( Other.IsA('TournamentPlayer') )
		TournamentPlayer(Other).StartSpot = None;
/*
	if ( Other.PlayerReplicationInfo.Team != 255 )
	{
		ClearOrders(Other);
		Teams[Other.PlayerReplicationInfo.Team].Size--;
	}
*/
	//if ( Teams[NewTeam].Size < MaxTeamSize )
	//{
		AddToTeam(NewTeam, Other);
		return true;
	//}
/*
	if ( (Other.PlayerReplicationInfo.Team == 255) 
		|| ((SmallestTeam != None) && (SmallestTeam.Size < MaxTeamSize)) )
	{
		if ( s == 255 )
			s = 0;
		AddToTeam(s, Other);
		return true;
	}

	return false; */
}

/*
///////////////////////////////////////
// AddToTeam
///////////////////////////////////////

function AddToTeam( int num, Pawn Other )
{
	Super.AddToTeam(num, Other);

	if (num > 1)
		return;

	if (num == 0)
		SetRandomTerrModel(Other);
	else
		SetRandomSFModel(Other);

}
*/


///////////////////////////////////////
// AddToTeam
///////////////////////////////////////

function AddToTeam( int num, Pawn Other )
{
	local teaminfo aTeam;
	local Pawn		P;
	local bool		bSuccess;
	local string	SkinName, FaceName;
	local	actor	  StartSpot;
	local	byte		Oldteam;

	if ( (Other == None) || (Other.PlayerReplicationInfo == None) || (num == 255) )
	{
		log("Added none to team!!!");
		return;
	}

	ClearOrders(Other);
	OldTeam = Other.PlayerReplicationInfo.Team;
	aTeam = Teams[num];

	//Teams[Other.playerReplicationInfo.team].Size--;
	Other.PlayerReplicationInfo.Team = num;
	Other.PlayerReplicationInfo.TeamName = aTeam.TeamName;
	
	if ( LocalLog != None )
		LocalLog.LogTeamChange(Other);
	if ( WorldLog != None )
		WorldLog.LogTeamChange(Other);

	bSuccess = false;
	if ( Other.IsA('PlayerPawn') )
	{
		Other.PlayerReplicationInfo.TeamID = 0;
		PlayerPawn(Other).ClientChangeTeam(Other.PlayerReplicationInfo.Team);
	}
	else
		Other.PlayerReplicationInfo.TeamID = 1;

	while ( !bSuccess )
	{
		bSuccess = true;
		for ( P=Level.PawnList; P!=None; P=P.nextPawn )
            if ( P.bIsPlayer && (P != Other) 
				&& (P.PlayerReplicationInfo.Team == Other.PlayerReplicationInfo.Team) 
				&& (P.PlayerReplicationInfo.TeamId == Other.PlayerReplicationInfo.TeamId) )
				bSuccess = false;
		if ( !bSuccess )
			Other.PlayerReplicationInfo.TeamID++;
	}

	BroadcastLocalizedMessage( class'DeathMatchMessage', 3, Other.PlayerReplicationInfo, None, aTeam );

	if ( num == 0 )
		SetRandomTerrModel(Other);
	else
		SetRandomSFModel(Other);

	SetVoiceType(Other.PlayerReplicationInfo);

	StartSpot = FindPlayerStart(Other, Other.PlayerReplicationInfo.Team);
	if ( StartSpot == None )
		//StartSpot = OldStartSpot;
	{	
		log("AddToTeam - FindPlayerStart failed - Destroy");
		Other.Destroy();
		return;
	}

	Other.SetLocation(StartSpot.Location);
	Other.SetRotation(StartSpot.Rotation);
	Other.ViewRotation = StartSpot.Rotation;
	Other.SetRotation(Other.Rotation);

	aTeam.Size++;

	if ( OldTeam < 2 )//&& OldTeam != num)
		Teams[OldTeam].Size--;

	if ( bBalanceTeams && !bRatedGame )
		ReBalance();

	CheckEndGame();
}


///////////////////////////////////////
// CanSpectate
///////////////////////////////////////

function bool CanSpectate( pawn Viewer, actor ViewTarget )
{ 
	if ( ViewTarget.bIsPawn && (Pawn(ViewTarget).PlayerReplicationInfo != None)
		&& Pawn(ViewTarget).PlayerReplicationInfo.bIsSpectator )
		return false;
	if ( Viewer.PlayerReplicationInfo.bIsSpectator && (Viewer.PlayerReplicationInfo.Team == 255) )
		return true;
	return ( (Pawn(ViewTarget) != None) && Pawn(ViewTarget).bIsPlayer 
		&& (Pawn(ViewTarget).PlayerReplicationInfo.Team == Viewer.PlayerReplicationInfo.Team) );
	//return false;
}


///////////////////////////////////////
// GetTeam
///////////////////////////////////////

function TeamInfo GetTeam(int TeamNum )
{
	if ( TeamNum < ArrayCount(Teams) )
		return Teams[TeamNum];
	else return None;
}


///////////////////////////////////////
// IsOnTeam
///////////////////////////////////////

function bool IsOnTeam(Pawn Other, int TeamNum)
{
	if ( Other.PlayerReplicationInfo.Team == TeamNum )
		return true;

	return false;
}


///////////////////////////////////////
// AddBot
///////////////////////////////////////

function bool AddBot()
{
	local bot NewBot;
	local NavigationPoint StartSpot, OldStartSpot;
	local int DesiredTeam, i, MinSize;

	//log("TO_GameBasics::AddBot");

	NewBot = SpawnBot(StartSpot);
	if ( NewBot == None )
	{
		log("Failed to spawn bot");
		return false;
	}

	NewBot.Health = 100;
	DesiredTeam = NewBot.PlayerReplicationInfo.Team;
	NewBot.PlayerReplicationInfo.bIsABot = True;

	if ( (DesiredTeam == 255) || !ChangeTeam(NewBot, DesiredTeam) )
	{
		/*NextBotTeam++;
		if ( NextBotTeam >= MaxTeams )
			NextBotTeam = 0;
		DesiredTeam = NextBotTeam; */
		//MinSize = Teams[0].Size;
		DesiredTeam = 0;
		if (Teams[1].Size < Teams[0].Size)
			DesiredTeam = 1;
		if (!ChangeTeam(NewBot, DesiredTeam))
		{
			log("AddBot - ChangeTeam failed - Destroy");
			NewBot.Destroy();
			return false;
		}
	}

	NewBot.PlayerReplicationInfo.Team = DesiredTeam;
	//OldStartSpot = StartSpot;
	StartSpot = FindPlayerStart(NewBot, NewBot.PlayerReplicationInfo.Team);
	if ( StartSpot == None )
		//StartSpot = OldStartSpot;
	{	
		log("AddBot - FindPlayerStart failed - Destroy");
		NewBot.Destroy();
		return false;
	}

	NewBot.SetLocation(StartSpot.Location);
	NewBot.SetRotation(StartSpot.Rotation);
	NewBot.ViewRotation = StartSpot.Rotation;
	NewBot.SetRotation(NewBot.Rotation);

	if (NewBot.PlayerReplicationInfo.Team == 0)
		SetRandomTerrModel(NewBot);
	else
		SetRandomSFModel(NewBot);

	SetVoiceType(NewBot.PlayerReplicationInfo);

	/*
	// Set Bot skill
	NewBot.SetOrders('Freelance', None, true);
	NewBot.bJumpy = false;
	//NewBot.Skill = 0.0;
	NewBot.InitializeSkill(Difficulty + BotSkills[n]);
	//NewBot.Skill = FClamp(BotConfig.Default.Difficulty + FRand(), 0, 10);
	NewBot.CombatStyle = -1.0 + FRand() / 2;
	NewBot.StrafingAbility = -0.5000;
	NewBot.BaseAlertness = FRand();
	NewBot.CampingRate = 0.050000 + FRand() / 2;
	NewBot.AirControl = AirControl;
	*/

	//SetBotOrders(NewBot);

	// Log it.
	if (LocalLog != None)
	{
		LocalLog.LogPlayerConnect(NewBot);
		LocalLog.FlushLog();
	}
	if (WorldLog != None)
	{
		WorldLog.LogPlayerConnect(NewBot);
		WorldLog.FlushLog();
	}

	if ( GamePeriod == GP_PreRound )
	{
		//log("AddBot - Pre-Round");
		s_Bot(NewBot).GotoState('PreRound');
	}

	//if (bBalanceTeams)
	//	Rebalance();

	//log("TO_GameBasics::AddBot end");
	return true;
}


///////////////////////////////////////
// SpawnBot
///////////////////////////////////////

function Bot SpawnBot(out NavigationPoint StartSpot)
{
	local bot NewBot;
	local int BotN;
	local Pawn P;

	//log("TO_GameBasics::SpawnBot");

	/*NewBot = Super.SpawnBot(StartSpot);
	if (NewBot != None && NewBot.IsA('s_Bot'))
		return NewBot;

	if (NewBot != None)
		NewBot.Destroy();
	NewBot = None;
	
	if ( bRatedGame )
		return SpawnRatedBot(StartSpot);
*/
	Difficulty = BotConfig.Difficulty;

	if ( Difficulty >= 4 )
	{
		bNoviceMode = false;
		Difficulty = Difficulty - 4;
	}
	else
	{
		if ( Difficulty > 3 )
		{
			Difficulty = 3;
			bThreePlus = true;
		}
		bNoviceMode = true;
	}
	BotN = 1;
	
	// Find a start spot.
	StartSpot = FindPlayerStart(None, 255);
	if( StartSpot == None )
	{
		log("Could not find starting spot for Bot");
		return None;
	}

	// Try to spawn the bot.
	NewBot = Spawn(class's_BotMCounterTerrorist1',,,StartSpot.Location,StartSpot.Rotation);

	if ( NewBot == None )
		log("Couldn't spawn player at "$StartSpot);

	/*
	if ( (bHumansOnly || Level.bHumansOnly) && !NewBot.bIsHuman )
	{
		log("can't add non-human bot to this game");
		NewBot.Destroy();
		NewBot = None;
	}
*/
//	if ( NewBot == None )
//		NewBot = Spawn(BotConfig.CHGetBotClass(0),,,StartSpot.Location,StartSpot.Rotation);

	if ( NewBot != None )
	{
		// Set the player's ID.
		NewBot.PlayerReplicationInfo.PlayerID = CurrentID++;

		NewBot.PlayerReplicationInfo.Team = BotConfig.GetBotTeam(BotN);
		BotConfig.CHIndividualize(NewBot, NumBots, NumBots);
		NewBot.ViewRotation = StartSpot.Rotation;
		// broadcast a welcome message.
		BroadcastMessage( NewBot.PlayerReplicationInfo.PlayerName$EnteredMessage, false );

		ModifyBehaviour(NewBot);
		AddDefaultInventory( NewBot );
		NumBots++;
		if ( bRequireReady && (CountDown > 0) )
			NewBot.GotoState('Dying', 'WaitingForStart');
		NewBot.AirControl = AirControl;

		if ( (Level.NetMode != NM_Standalone) && (bNetReady || bRequireReady) )
		{
			// replicate skins
			for ( P=Level.PawnList; P!=None; P=P.NextPawn )
				if ( P.bIsPlayer && (P.PlayerReplicationInfo != None) && P.PlayerReplicationInfo.bWaitingPlayer && P.IsA('PlayerPawn') )
				{
					if ( NewBot.bIsMultiSkinned )
						PlayerPawn(P).ClientReplicateSkins(NewBot.MultiSkins[0], NewBot.MultiSkins[1], NewBot.MultiSkins[2], NewBot.MultiSkins[3]);
					else
						PlayerPawn(P).ClientReplicateSkins(NewBot.Skin);	
				}						
		}
	}

	//log("TO_GameBasics::SpawnBot end");
	return NewBot;
}

///////////////////////////////////////
// SetBotOrders
///////////////////////////////////////

function SetBotOrders(Bot NewBot)
{
	local Pawn P, L;
	local int num, total;

	L = None;

	// only follow players, if there are any
	if ( (NumSupportingPlayer == 0)
		 || (NumSupportingPlayer < Teams[NewBot.PlayerReplicationInfo.Team].Size/2 - 1) ) 
	{
		For ( P=Level.PawnList; P!=None; P= P.NextPawn )
			if ( P.IsA('PlayerPawn') && (P.PlayerReplicationInfo.Team == NewBot.PlayerReplicationInfo.Team)
				&& !P.IsA('Spectator') && (P.Health > 0) && (!(P.IsInState('PlayerSpectating'))) )
		{
			num++;
			if ( (L == None) || (FRand() < 1.0/float(num)) )
				L = P;
		}

		if ( L != None )
		{
			NumSupportingPlayer++;
			NewBot.SetOrders('Follow', L, true);
			return;
		}
	}
	num = 0;
	For ( P=Level.PawnList; P!=None; P= P.NextPawn )
		if ((P.Health > 0) && (P.PlayerReplicationInfo != None) && (P.PlayerReplicationInfo.Team == NewBot.PlayerReplicationInfo.Team))
		{
			total++;
			if ( (P != NewBot) && P.IsA('Bot') && (Bot(P).Orders == 'Freelance') )
			{
				num++;
				if ( (L == None) || (FRand() < 1/float(num)) )
					L = P;
			}
		}
				
	if ( (L != None) && (FRand() < float(num)/float(total)) )
	{
		NewBot.SetOrders('Follow', L, true);
		return;
	}
	NewBot.SetOrders('Freelance', None,true);
}				 


///////////////////////////////////////
// BotCanReach
///////////////////////////////////////

function bool	BotCanReachTarget(s_Bot aBot, Actor Target)
{
	//if (aBot.ActorReachable(Target) || aBot.FindPathToward(Target) != None)
		return true;

	return false;
}


///////////////////////////////////////
// FindHostages
///////////////////////////////////////

final function NavigationPoint FindHostages(s_Bot aBot)
{
	local s_ZoneControlPoint	ZCP, Best;
	local float								Score, BestScore;

	ZCP = ZCPLink;
	while (ZCP != None) 
	{
		if (ZCP.bHostageHidingPlace)
		{
			Score = FRand();
			//Score-=Vsize(Nav.Location - aBot.Location);
			if (Score > BestScore && BotCanReachTarget(aBot, ZCP) )
			{
				BestScore = Score;
				Best = ZCP;
			}
		}

		ZCP = ZCP.NextZCP;
	}
	return Best;
}


///////////////////////////////////////
// IsCloseToHidingPoint
///////////////////////////////////////

final function bool	IsCloseToHidingPoint(actor B)
{
	if (B.IsA('s_Bot') && s_Bot(B).bInHostageHidingPlace)
		return true;
	if (B.IsA('s_NPCHostage') && s_NPCHostage(B).bInHostageHidingPlace)
		return true;

	return false;
}


///////////////////////////////////////
// FindHomeBase
///////////////////////////////////////

final function NavigationPoint FindHomeBase(s_Bot aBot)
{
	local s_ZoneControlPoint	ZCP, Best;
	local float								Score, BestScore;

	ZCP = ZCPLink;
	while (ZCP != None) 
	{
		if (ZCP.bHomeBase && ZCP.OwnedTeam == aBot.PlayerReplicationInfo.Team && BotCanReachTarget(aBot, ZCP) )
		{
			Score = FRand();

			if (Score > BestScore)
			{
				BestScore = Score;
				Best = ZCP;
			}
		}
		ZCP = ZCP.NextZCP;
	}
	return Best;
}


///////////////////////////////////////
// FindEnemyBase
///////////////////////////////////////

final function NavigationPoint FindEnemyBase(s_Bot aBot)
{
	local s_ZoneControlPoint	ZCP, Best;
	local float								Score, BestScore;

	ZCP = ZCPLink;
	while (ZCP != None) 
	{
		if (ZCP.bHomeBase && ZCP.OwnedTeam != aBot.PlayerReplicationInfo.Team && BotCanReachTarget(aBot, ZCP) )
		{
			Score = FRand();

			if (Score > BestScore)
			{
				BestScore = Score;
				Best = ZCP;
			}
		}
		ZCP = ZCP.NextZCP;
	}
	return Best;
}

 
///////////////////////////////////////
// FindRescuePoint
///////////////////////////////////////

final function NavigationPoint FindRescuePoint(s_Bot aBot)
{
	local s_ZoneControlPoint	ZCP, Best;
	local float								Score, BestScore;

	ZCP = ZCPLink;
	while (ZCP != None) 
	{
		if (ZCP.bRescuePoint && BotCanReachTarget(aBot, ZCP) )
		{
			Score = FRand();
		
			if (Score > BestScore)
			{
				BestScore = Score;
				Best = ZCP;
			}
		}
		ZCP = ZCP.NextZCP;
	}
	return Best;
}


///////////////////////////////////////
// FindBuyPoint
///////////////////////////////////////

final function NavigationPoint FindBuyPoint(s_Bot aBot)
{
	local s_ZoneControlPoint	ZCP, Best;
	local float								Score, BestScore;

	ZCP = ZCPLink;
	while (ZCP != None) 
	{
		if (ZCP.bBuyPoint && ZCP.OwnedTeam == aBot.PlayerReplicationInfo.Team && BotCanReachTarget(aBot, ZCP) )
		{
			Score = FRand();

			if (Score > BestScore)
			{
				BestScore = Score;
				Best = ZCP;
			}
		}
		ZCP = ZCP.NextZCP;
	}
	return Best;
}


///////////////////////////////////////
// FindEscapeZone
///////////////////////////////////////

final function NavigationPoint FindEscapeZone(s_Bot aBot)
{
	local s_ZoneControlPoint	ZCP, Best;
	local float								Score, BestScore;

	ZCP = ZCPLink;
	while (ZCP != None) 
	{
		if (ZCP.bEscapeZone && ZCP.OwnedTeam==aBot.PlayerReplicationInfo.Team && BotCanReachTarget(aBot, ZCP) )
		{
			Score = FRand();

			if (Score > BestScore)
			{
				BestScore = Score;
				Best = ZCP;
			}
		}
		ZCP = ZCP.NextZCP;
	}
	return Best;
}


///////////////////////////////////////
// FindC4TargetLocation
///////////////////////////////////////

final function NavigationPoint FindC4TargetLocation(s_Bot aBot)
{
	local		s_ZoneControlPoint	ZCP, Best;
	local		float								Score, BestScore;

	ZCP = ZCPLink;
	while (ZCP != None) 
	{	
		if (ZCP.bBombingZone && BotCanReachTarget(aBot, ZCP) )
		{
			Score = FRand();

			if (Score > BestScore)
			{
				BestScore = Score;
				Best = ZCP;
			}
		}
		ZCP = ZCP.NextZCP;
	}

	return Best;
}


///////////////////////////////////////
// FindTOConsoleTimer
///////////////////////////////////////

final function Actor FindTOConsoleTimer(s_Bot aBot)
{
	local		TO_ConsoleTimerPN			CT, Best;
	local		float								Score, BestScore;

	CT = CTLink;
	while (CT != None) 
	{	
		if ( BotCanReachTarget(aBot, CT) )
		{
			Score = FRand();

			if (Score > BestScore)
			{
				BestScore = Score;
				Best = CT;
			}
		}
		CT = CT.NextCTLink;
	}

	return Best;
}


///////////////////////////////////////
// FindC4Explosive
///////////////////////////////////////

final function Actor FindC4Explosive(s_Bot aBot)
{
	local		s_ExplosiveC4			C4, Best;
	local		float								Score, BestScore;

	Best = None;
	BestScore = 0.0;
	ForEach AllActors(class's_ExplosiveC4', C4)
	{
//		if ( BotCanReachTarget(aBot, C4) )
//		{
			Score = FRand();

			if (Score > BestScore)
			{
				BestScore = Score;
				Best = C4;
			}
//		}
	}
	return Best;
}


///////////////////////////////////////
// FindC4Dropped
///////////////////////////////////////

final function Actor FindC4Dropped(s_Bot aBot)
{
	local		s_C4			C4, Best;
	local		float			Score, BestScore;

	Best = None;
	BestScore = 0.0;
	ForEach AllActors(class's_C4', C4)
	{
//		if ( BotCanReachTarget(aBot, C4) )
//		{
			Score = FRand();

			if (Score > BestScore)
			{
				BestScore = Score;
				Best = C4;
			}
//		}
	}
	return Best;
}


///////////////////////////////////////
// FindSpecialItem
///////////////////////////////////////

final function s_SpecialItem FindSpecialItem(s_Bot aBot)
{
	local		s_SpecialItem			Nav, Best;
	local		float							Score, BestScore;

	foreach AllActors(class's_SpecialItem', Nav)
	{	
		Score = FRand();

		if (Score > BestScore && BotCanReachTarget(aBot, Nav) )
		{
			BestScore = Score;
			Best = Nav;
		}
	}
	return Best;
}


///////////////////////////////////////
// FindEvidence
///////////////////////////////////////

final function s_Evidence FindEvidence(s_Bot aBot)
{
	local		s_Evidence				Nav, Best;
	local		float							Score, BestScore;

	foreach AllActors(class's_Evidence', Nav)
	{	
		Score = FRand();

		if (Score > BestScore && BotCanReachTarget(aBot, Nav) )
		{
			BestScore = Score;
			Best = Nav;
		}
	}
	return Best;
}


///////////////////////////////////////
// ResetBotObjective
///////////////////////////////////////

final function ResetBotObjective(s_Bot B, float camptime)
{
	if ( (B == None) || (B.bDoNotDisturb) )
		return;

	ClearBotObjective(B);

	if ( !B.bNotPlaying )
	{
		if ( B.SupportingPlayer != None )
		{
			if ( B.SupportingPlayer.IsA('PlayerPawn' ))
				NumSupportingPlayer--;
			B.SupportingPlayer = None;
		}

		B.MoveTarget = None;
		if ( B.Orders != 'Freelance' )
			B.SetOrders('Freelance', None);
		
		if ( camptime > 0.0 )
		{
			B.CampTime = camptime;
			B.bCampOnlyOnce = true;
			B.GotoState('Roaming', 'camp');
		}
		else if ( !B.IsInState('Roaming') )
			B.GotoState('Roaming');
	}
}


///////////////////////////////////////
// ClearBotObjective
///////////////////////////////////////

final function ClearBotObjective(s_Bot B)
{
	if ( (B == None) || B.bDoNotDisturb )
		return;

	if ( B.Orders == '' )
		B.SetOrders('Freelance', None);

	if ( B.PlayerReplicationInfo != None )
	{
		if ( B.LastObjective != '' )
		{
			if ( B.LastO_number != 255 )
				B.O_number = B.LastO_number;
			B.LastObjective = '';
		}

		// Reset Objective leader
		if ( B.O_number != 255 )
		{
			if ( B.PlayerReplicationInfo.Team == 1 )
				SI.SF_ObjectivesPriv[B.O_number].Leader = None;
			else 
				SI.Terr_ObjectivesPriv[B.O_number].Leader = None;
		}

		// Bot suspended from Objective
		B.Objective = 'O_DoNothing';
		B.O_number = 255;
		B.OrderObject = None;
	}
}


///////////////////////////////////////
// ClearOrders
///////////////////////////////////////

function ClearOrders(Pawn Leaving)
{
	BotCheckOrderObject(Leaving);
	/*local Pawn P;

	for ( P=Level.PawnList; P!=None; P=P.NextPawn )
		if ( P.IsA('Bot') && (Bot(P).OrderObject == Leaving) && !s_Bot(B).bNotPlaying )
			Bot(P).SetOrders('Freelance', None);
			*/
}


///////////////////////////////////////
// BotCheckOrderObject
///////////////////////////////////////
// BotSuppressFollowOrder
function BotCheckOrderObject(Pawn P)
{
	local Pawn A, B;

	// Check if victim was a Follower
/*	if ( (P.IsA('Bot')) && (Bot(P).Orders == 'Follow') )
		{
			if (Bot(P).OrderObject.IsA('PlayerPawn'))
				NumSupportingPlayer--;
			Bot(P).SetOrders('Freelance', None);
		}
*/
	// re-assign orders to follower bots with no leaders
	for (B=Level.PawnList; B!=None; B=B.NextPawn )
		if (B.IsA('s_Bot') && (!s_Bot(B).bNotPlaying))	
		{
			if (s_Bot(B).Enemy == P)
			{
				s_Bot(B).Enemy = None;
				ResetBotObjective(s_bot(B), 1.0);
			}
			else if ( (Bot(B).OrderObject == P) )
			{
				/*
				Bot(B).SupportingPlayer = None;
				// Bot(B).OrderObject = None;
				Bot(B).Orders = 'Freelance';
				if (P.IsA('PlayerPawn'))
					NumSupportingPlayer--;
				SetBotOrders(Bot(B));*/
				ResetBotObjective(s_bot(B), 1.0);
			}
			
		}

}


///////////////////////////////////////
// AssessBotAttitude
///////////////////////////////////////
/*
case 0: return ATTITUDE_Fear;
case 1: return ATTITUDE_Hate;
case 2: return ATTITUDE_Ignore;
case 3: return ATTITUDE_Friendly;
*/
function byte AssessBotAttitude(Bot aBot, Pawn Other)
{
	if ( Other.PlayerReplicationInfo.bWaitingPlayer || Other.PlayerReplicationInfo.bIsSpectator )
		return 2;

	if ( Other.IsA('s_Bot') && s_Bot(Other).bNotPlaying )
		return 2;

	if ( Other.IsA('s_Player') && s_Player(Other).bNotPlaying )
		return 2;

	if ( Other.IsA('s_NPCHostage') )
		return 3;

	return Super.AssessBotAttitude(aBot, Other);
}


///////////////////////////////////////
// AddDefaultInventory
///////////////////////////////////////

function AddDefaultInventory( pawn PlayerPawn )
{
	local Bot				B;

	if ( PlayerPawn.IsA('s_Player') && PlayerPawn.PlayerReplicationInfo.bWaitingPlayer )
		return;
	
//	GiveWeapon(PlayerPawn, "s_SWAT.s_OICW");
//	GiveWeapon(PlayerPawn, "s_SWAT.s_m3");

	GiveTeamWeapons(PlayerPawn);
	
	AddMoney(PlayerPawn, 1000);
//	GiveWeapon(PlayerPawn, "s_SWAT.s_MP5N");
//	Super.AddDefaultInventory(PlayerPawn);

	B = Bot(PlayerPawn);
	if ( B != None )
		B.bHasImpactHammer = false;

	BaseMutator.ModifyPlayer(PlayerPawn);

	PlayerPawn.SwitchToBestWeapon();
}	


///////////////////////////////////////
// GiveTeamWeapons
///////////////////////////////////////

final function GiveTeamWeapons(Pawn P)
{
	local	Inventory	Inv;
	local	bool			bPistol, bKnife;

	if ( (P.PlayerReplicationInfo == None) || P.PlayerReplicationInfo.bIsSpectator || P.PlayerReplicationInfo.bWaitingPlayer)
		return;

	bKnife = false;
	bPistol = false;

	for ( Inv=P.Inventory; Inv!=None; Inv=Inv.Inventory )
	{	 
		if ( Inv.IsA('s_Knife') )
		{
			bKnife = true;
			break;
		}
	}
	if ( !bKnife )
		GiveWeapon(P, "s_SWAT.s_Knife");

	// only if not carrying a pistol !!
	for ( Inv=P.Inventory; Inv!=None; Inv=Inv.Inventory )
	{	 
		if ( Inv.IsA('s_Weapon') && (s_Weapon(Inv).WeaponClass == 1) )
		{
			bPistol = true;
			break;
		}
	}

	if ( !bPistol )
	{
		if ( P.PlayerReplicationInfo.Team == 0 )
			GiveWeapon(P, "s_SWAT.s_Glock");
		else if ( P.PlayerReplicationInfo.Team == 1 )
			GiveWeapon(P, "s_SWAT.TO_Berreta");
	}
}

//------------------------------------------------------------------------------
// Game Querying.



///////////////////////////////////////
// AddMoney
///////////////////////////////////////

final function AddMoney( Pawn Dude, int Amount)
{
	local int		tmp;

	if ( Dude.IsA('s_bot') )
		s_bot(Dude).Money = Clamp(s_bot(Dude).Money + Amount, -MaxMoney, MaxMoney);
	else if ( Dude.IsA('s_Player') )
	{
		tmp = s_player(Dude).Money;
		s_player(Dude).Money = Clamp(tmp + Amount, -MaxMoney, MaxMoney);
		tmp = s_player(Dude).Money - tmp;

		if (tmp != 0)
			s_player(Dude).HUD_Add_Money_Message(tmp);
	}
}


///////////////////////////////////////
// BuyWeapon
///////////////////////////////////////

final function BuyWeapon(Pawn P, int weaponnum )
{
	local class<Weapon>					WeaponClass;
	local Weapon								NewWeapon;
	local int										Price, i;
	local Texture NewSkin;
	local	Inventory							Inv;
	local vector								X, Y, Z;

	// Check for allowed weapons
	if ( (class'TOModels.TO_WeaponsHandler'.default.WeaponStr[weaponnum] == "")
		|| !(class'TOModels.TO_WeaponsHandler'.static.IsTeamMatch(P, WeaponNum)) )
		return;

	WeaponClass = class<Weapon>(DynamicLoadObject(class'TOModels.TO_WeaponsHandler'.default.WeaponStr[weaponnum], class'Class'));

	// Pawn can buy the weapon?
	if ( (P.FindInventoryType(WeaponClass) != None) 
		|| (P.IsA('s_Player') && (s_Player(P).bNotPlaying || s_Player(P).bBuyingWeapon)) )
		return;

	if ( P.IsA('s_Player') )
		s_Player(P).bBuyingWeapon = true;

	newWeapon = Spawn(WeaponClass);

	if ( NewWeapon == None ) 
	{
		if ( P.IsA('s_Player') )
			s_Player(P).bBuyingWeapon = false;
		return;
	}

	if ( !HaveMoney(P, s_Weapon(newWeapon).Price) || !newWeapon.IsA('s_Weapon') )
	{
		NewWeapon.Destroy();
		if ( P.IsA('s_Player') )
			s_Player(P).bBuyingWeapon = false;
		return;
	}

	for( Inv=P.Inventory; Inv!=None; Inv=Inv.Inventory )
	{	 
		if ( (Inv != NewWeapon) && Inv.IsA('s_Weapon') && (s_Weapon(Inv).WeaponClass != 0) 
			&& (s_Weapon(Inv).WeaponClass == s_Weapon(NewWeapon).WeaponClass) )
		{
			P.GetAxes(P.Rotation, X, Y, Z);
	    s_Weapon(Inv).DropFrom(P.Location + 0.8 * P.CollisionRadius * X + - 0.5 * P.CollisionRadius * Y); 
		}
	}

	newWeapon.RespawnTime = 0.0;
	newWeapon.GiveTo(P);
	if ( s_Weapon(newWeapon).bHasMultiSkins )
		s_Weapon(newWeapon).SetSkins();
	newWeapon.PlayIdleAnim();
	newWeapon.GotoState('idle');
	s_Weapon(newWeapon).ForceStillFrame();

	newWeapon.bHeldItem = true;
	newWeapon.bTossedOut = false;
	newWeapon.GiveAmmo(P);
	newWeapon.SetSwitchPriority(P);
	if ( P.IsA('PlayerPawn') )
		newWeapon.SetHand(PlayerPawn(P).Handedness);
	else
		newWeapon.GotoState('Idle');

	P.PendingWeapon = newWeapon;
	if ( P.Weapon == None ) 
		P.ChangedWeapon();
	else if ( !P.Weapon.PutDown() )
		P.PendingWeapon = None;
		//P.Weapon.GotoState('DownWeapon');

	AddMoney( P, -s_Weapon(newWeapon).Price);

	if ( P.IsA('s_Player') )
		s_Player(P).bBuyingWeapon = false;
}


///////////////////////////////////////
// HaveMoney
///////////////////////////////////////

final function bool HaveMoney(Pawn Man, int Amount)
{
	if ( Man.IsA('s_Bot') )
	{
		if ( s_Bot(Man).Money >= Amount )
			Return true;
		else
			Return false;
	}
	else
	{
		if ( s_Player(Man).Money >= Amount )
			Return true;
		else
			Return false;
	}
}


///////////////////////////////////////
// BuyAmmo
///////////////////////////////////////

final function BuyAmmo( Pawn P, s_Weapon W )
{
	if ( (P == None) /*|| !IsInBuyZone(P)*/ )
		return;

	if (P.IsA('s_Player') && s_Player(P).bNotPlaying)
		return;

	if (P.IsA('s_Bot') && s_Bot(P).bNotPlaying)
		return;

	if ( (W == None) || (!W.bUseClip) )
		return;

 	if ( HaveMoney(P, W.ClipPrice) && (W.RemainingClip < W.MaxClip) )
	{
		W.RemainingClip = Min(W.RemainingClip+W.ClipInc, W.MaxClip);
		AddMoney(P, -W.ClipPrice);
		P.PlaySound( Sound'BuyAmmo', SLOT_Misc);
	}
}


///////////////////////////////////////
// BuyKnives
///////////////////////////////////////

final function BuyKnives(Pawn P)
{
	local s_Weapon	W;

	if ( (P == None) /*|| !IsInBuyZone(P)*/ )
		return;

	if (P.IsA('s_Player') && s_Player(P).bNotPlaying)
		return;

	if (P.IsA('s_Bot') && s_Bot(P).bNotPlaying)
		return;

	W = s_Weapon(P.FindInventoryType(class's_SWAT.s_Knife'));
	
	if (W == None)
		return;
 	
	if ( HaveMoney(P, W.ClipPrice) && W.ClipAmmo < W.ClipSize )
	{
		W.ClipAmmo = W.ClipSize;
		AddMoney(P, -W.ClipPrice);
		P.PlaySound( Sound'BuyAmmo', SLOT_Misc);
	}
}


///////////////////////////////////////
// RescueHostage
///////////////////////////////////////

final function RescueHostage( pawn P, s_NPCHostage H)
{
	H.PlayRescueEscort();

	// If Hostage is already following a bot
	if ( (H.Followed != None) && H.Followed.IsA('s_Bot') )
	{
		if (P != H.Followed)
		{
			if (s_Bot(H.Followed).HostageFollowing > 0)
				s_Bot(H.Followed).HostageFollowing--;
			if (s_Bot(H.Followed).HostageFollowing < 1)
				ClearBotObjective(s_Bot(H.Followed));

			if ( s_Bot(P) != None )
				s_Bot(P).HostageFollowing++;
		}
	}
	else if (s_Bot(P) != None)
		s_Bot(P).HostageFollowing++;

	H.followed = P;
	H.OrderObject = P;
	H.bIsFree = true;
	H.SetOrders('Follow', P);
	H.GotoState('Roaming');
}


///////////////////////////////////////
// LockHostage
///////////////////////////////////////

final function LockHostage( pawn P, s_NPCHostage H)
{
	if ( P != None )	
		H.PlayThreatLock();

	if ( (H.Followed != None) && H.Followed.IsA('s_Bot') /*&& P != H.Followed*/)
	{
		if ( s_Bot(H.Followed).HostageFollowing > 0 )
			s_Bot(H.Followed).HostageFollowing--;

		if ( s_Bot(H.Followed).HostageFollowing < 1 )
			ClearBotObjective(s_Bot(H.Followed));
	}

	H.bIsFree = false;
	H.followed = None;
	H.OrderObject = None;
	H.GotoState('Waiting');	
}


///////////////////////////////////////
// TerrEscortHostage
///////////////////////////////////////

final function TerrEscortHostage( pawn P, s_NPCHostage H)
{
	H.PlayThreatEscort();

	// If Hostage is already following a bot
	if ( (H.Followed != None) && H.Followed.IsA('s_Bot') )
	{
		if ( P != H.Followed )
		{
			if ( s_Bot(H.Followed).HostageFollowing > 0 )
				s_Bot(H.Followed).HostageFollowing--;

			if ( s_Bot(H.Followed).HostageFollowing < 1 )
				ClearBotObjective(s_Bot(H.Followed));
			
			if ( s_Bot(P) != None )
				s_Bot(P).HostageFollowing++;
		}
	}
	else if ( s_Bot(P) != None )
		s_Bot(P).HostageFollowing++;

	// bHostageFollowing
	H.bIsFree = true;
	H.Followed = P;
	H.OrderObject = P;
	H.SetOrders('Follow', P);
	H.GotoState('Roaming');

	
}


///////////////////////////////////////
// SpawnNPCH
///////////////////////////////////////

final function bot SpawnNPCH(NavigationPoint StartSpot)
{
	local bot NewBot;
	local int BotN;
	local Pawn P;

	if ( NPCHConfig == None )
		NPCHConfig = Spawn(class's_SWAT.s_NPCHostageInfo');

	NPCHConfig.Difficulty = BotConfig.Difficulty;
/*	Difficulty = BotConfig.Difficulty;

	if ( Difficulty >= 4 )
	{
		bNoviceMode = false;
		Difficulty = Difficulty - 4;
	}
	else
	{
		if ( Difficulty > 3 )
		{
			Difficulty = 3;
			bThreePlus = true;
		}
		bNoviceMode = true;
	}
*/
	BotN = NPCHConfig.ChooseBotInfo();

	// Try to spawn the bot.
	NewBot = Spawn(NPCHConfig.CHGetBotClass(BotN),,,StartSpot.Location,StartSpot.Rotation);

	if ( NewBot == None )
		log("Couldn't spawn player at "$StartSpot);

	if ( NewBot == None )
		NewBot = Spawn(NPCHConfig.CHGetBotClass(0),,,StartSpot.Location,StartSpot.Rotation);

	if ( NewBot != None )
	{
/*		s_NPC(NewBot).TOPRI = Spawn(class's_PRI', NewBot);
		if (s_NPC(NewBot).TOPRI == None)
			log("failed to spawn s_PRI");
		else
		{
			//s_NPC(NewBot).TOPRI.PRI = NewBot.PlayerReplicationInfo;
			//s_NPC(NewBot).TOPRI.bDoNotReplicate = true;
			//s_NPC(NewBot).TOPRI.bReduceSFX = bReduceSFX;
		}
*/
		// Set the player's ID.
		NewBot.PlayerReplicationInfo.PlayerID = CurrentID++;

		NewBot.PlayerReplicationInfo.Team = 3;
		NPCHConfig.CHIndividualize(NewBot, BotN, NumBots);
		NewBot.ViewRotation = StartSpot.Rotation;

		ModifyBehaviour(NewBot);

		NewBot.bJumpy = false;
		NewBot.CombatStyle = -1.0;
		NewBot.StrafingAbility = -0.5000;
		NewBot.BaseAlertness = 0.000000;
		NewBot.CampingRate = 0.50000;
		NewBot.AirControl = AirControl;

		//NewBot.static.SetMultiSkin(NewBot, "s_swat.ButcherSkins.hwhite", "s_swat.hwhite", 255);

		if ( (Level.NetMode != NM_Standalone) && (bNetReady || bRequireReady) )
		{
			// replicate skins
			for ( P=Level.PawnList; P!=None; P=P.NextPawn )
				if ( P.bIsPlayer && (P.PlayerReplicationInfo != None) && P.PlayerReplicationInfo.bWaitingPlayer && P.IsA('PlayerPawn') )
				{
					if ( NewBot.bIsMultiSkinned )
						PlayerPawn(P).ClientReplicateSkins(NewBot.MultiSkins[0], NewBot.MultiSkins[1], NewBot.MultiSkins[2], NewBot.MultiSkins[3]);
					else
						PlayerPawn(P).ClientReplicateSkins(NewBot.Skin);	
				}						
		}
	}

	return NewBot;
}


///////////////////////////////////////
// GiveWeapon
///////////////////////////////////////

function GiveWeapon(Pawn PlayerPawn, string aClassName )
{
	Super.GiveWeapon(PlayerPawn, aClassName);

	if ( (PlayerPawn.Weapon != None) && PlayerPawn.Weapon.IsA('s_Weapon') && s_Weapon(PlayerPawn.Weapon).bHasMultiSkins )
		s_Weapon(PlayerPawn.Weapon).SetSkins();
}


///////////////////////////////////////
// ForceSkinUpdate
///////////////////////////////////////

final function ForceSkinUpdate(pawn P)
{
	local	inventory	Inv;

	if ( (P.PlayerReplicationInfo == None) || (P.Inventory == None) )
		return;

	for( Inv=P.Inventory; Inv!=None; Inv=Inv.Inventory )
		if (Inv.IsA('s_Weapon'))
			s_Weapon(Inv).SetSkins();
}


///////////////////////////////////////
// IsInBuyZone
///////////////////////////////////////

final simulated function bool IsInBuyZone(Pawn P)
{	
	if ( P.IsA('s_Bot') && s_Bot(P).bInBuyZone )
		return true;

	if ( P.IsA('s_Player') && s_Player(P).bInBuyZone )
		return true;

	return false;
}

/*
///////////////////////////////////////
// SpawnSpray
///////////////////////////////////////

function SpawnSpray(PlayerPawn A)
{
	local DecalGenerator DecalGen;

	//log("spawn called");
	foreach AllActors(class'DecalGenerator',DecalGen)
		if ( DecalGen != None && (PlayerPawn(DecalGen.Owner) == A))
			return;
	//log("spawing spray");
	DecalGen = spawn(class's_SWAT.DecalGenerator', A);
	DecalGen.Splats = 0;
}
*/

///////////////////////////////////////
// SpawnSpecialItems
///////////////////////////////////////

final function SpawnSpecialItems()
{
	local s_SpecialItem						E;
	local s_SpecialItemStartPoint	S;
	local	int	i;

	foreach allactors(class's_SpecialItem', E)
		if ( !E.Destroy() )
			log("Failed to destroy "$E);

	i = 0;

	foreach allactors(class's_SpecialItemStartPoint', S)
	{
		if (i > 15)
			break;
		i++;
		E = None;

		if ( S.bIsCocaine )
		{
			E = Spawn(class's_SWAT.s_SpecialItemCocaine',,,S.Location,S.Rotation);

			if (E != None)
				E.Weight = S.Weight;
		}

	}
}


///////////////////////////////////////
// SpawnEvidence
///////////////////////////////////////

final function SpawnEvidence()
{
	local s_Evidence E;
	local s_EvidenceStartPoint S;
	local	int	i;

	foreach allactors(class's_Evidence', E)
		if ( !E.Destroy() )
			log("Failed to destroy "$E);

	if ( SI == None )
		return;

	i = 0;
	foreach allactors(class's_EvidenceStartPoint', S)
	{
		if ( i > SI.MaxEvidence )
			break;
		if (FRand() < 0.3)
		{
			i++;
			if ( FRand() < 0.5 )
				E = Spawn(class's_SWAT.s_EvidenceWeed',,,S.Location,S.Rotation);
			else
				E = Spawn(class's_SWAT.s_EvidenceMoney',,,S.Location,S.Rotation);

			if ( E != None )
				E.SetCollision(true);
		}
	}
}


///////////////////////////////////////
// DropEvidence
///////////////////////////////////////

final function DropEvidence(class<s_Evidence> Evidence, Pawn Other, Vector DropLocation)
{
	local s_Evidence	E;
	local float				Speed;
	local	rotator			V;

	Speed = VSize(Other.Velocity);
	V.pitch = FRand();	
	E = Spawn(Evidence,,, DropLocation);

	if ( E != None )
	{
		E.SetCollision(true);
		E.SetRotation(V);
		E.Velocity = Vector(Other.ViewRotation) * 200 * FRand() + vect(1.0, 0, 500) * FRand();
	}
	//Log("Evidence dropped !! Class: "$Evidence$"    Instance: "$E);
}


///////////////////////////////////////
// DropSpecialItem
///////////////////////////////////////

final function DropSpecialItem(class<s_SpecialItem> SpecialItem, Pawn Other, Vector DropLocation)
{
	local s_SpecialItem	E;
	local float					Speed;
	local	rotator				V;

	// Add support for Weight var later..

	Speed = VSize(Other.Velocity);
	V.pitch = FRand();	
	E = Spawn(SpecialItem,,, DropLocation);

	if ( E != None )
	{
		E.SetCollision(true);
		E.SetRotation(V);
		E.Velocity = Vector(Other.ViewRotation) * 200 * FRand() + vect(1.0, 0, 500) * FRand();
	}
}


///////////////////////////////////////
// DropMoney
///////////////////////////////////////

final function DropMoney(Pawn Other, int PezAmount, Vector DropLocation)
{
	local s_MoneyPickup	E;
	local float				Speed;
	local	rotator			V;

	//Log("TO_GameBasics::DropMoney");
	
	Speed = VSize(Other.Velocity);
	V.pitch = FRand();	
	E = Spawn(class's_MoneyPickUp',,, DropLocation);
	
	if ( E != None )
	{
		E.SetCollision(true);
		E.SetRotation(V);
		E.Velocity = Vector(Other.ViewRotation) * 200 * FRand() + vect(1.0, 0, 500) * FRand();
		E.Amount = PezAmount;
	}
	else
		Log("TO_GameBasics::DropMoney Couldn't spawn actor!");
	
}


///////////////////////////////////////
// KillInventory
///////////////////////////////////////

final function KillInventory(Pawn P)
{
	local		Inventory		Inv, InvTmp;

	// Kill all weapons
	Inv = P.Inventory;
	While ( Inv != None )
	{
		InvTmp = Inv.Inventory;
		Inv.Destroy();
		Inv = InvTmp;
	}
	
	P.Weapon = None;
}


///////////////////////////////////////
// DropInventory
///////////////////////////////////////

final function DropInventory(Pawn Other, bool bDropMoney)
{
	local   int					Eidx, PezAmount;
	local		Inventory		Inv, InvTmp;
	local		vector			X, Y, Z;
	local		s_Player		P;
	local		s_Bot				B;
	local		Vector			DropLocation;

	if ( other == none )
		return;

	//log("TO_GameBasics::DropInventory"@Other.GetHumanName()@"money:"@bDropMoney);

	P = s_Player(Other);
	B = s_Bot(Other);

	Other.GetAxes(Other.Rotation,X,Y,Z);
	DropLocation = Other.Location + 1.5 * Other.CollisionRadius * X;

// Problem with teamchanges and weapons
//	if (bLinuxFix)
//		return;

	// Drop all weapons
	Inv = Other.Inventory;
	While ( Inv != None )
	{
		// Hack because DropFrom() breaks the inventory chain.
		InvTmp = Inv.Inventory;

		if ( Inv.IsA('s_Weapon') /*&& s_Weapon(Inv) != Other.Weapon*/ && !s_Weapon(Inv).IsA('s_Knife') )
		{
			//log("TO_GameBasics::DropInventory -"@Other.GetHumanName()@"W:"@Inv.Class);

			s_Weapon(Inv).Velocity = Vector(Other.ViewRotation) * 200 * FRand() + vect(1.0, 0, 500) * FRand();
			s_Weapon(Inv).bTossedOut = true;
			s_Weapon(Inv).DropFrom(DropLocation); 
		}
		Inv = InvTmp;
	}

	// If player carries Evidence, drop da stuffs !
	if ( P != None )
	{
		Eidx = P.Eidx;
		while ( Eidx > 0 )
		{
			Eidx--;
			//log("about to drop evidence");
			DropEvidence(P.Evidence[Eidx], Other, DropLocation);
			P.Evidence[Eidx] = None;
		}
		P.Eidx = 0;

		// SpecialItems
		if ( P.bSpecialItem )
		{
			DropSpecialItem(P.SpecialItemClass, Other, DropLocation);
			P.bSpecialItem = false;
		}

		if ( !bDropMoney )
			return;

		if ( P.Money < 2000 )
		{ 
			if ( P.Money > 50 )
			{
				PezAmount = P.Money / 2;
				AddMoney(P, -PezAmount);
			}
		}
		else
		{
			PezAmount = 1000;
			AddMoney(P, -PezAmount);
		}

		if ( PezAmount > 0 )
			DropMoney(P, PezAmount, DropLocation);


	}
	else if ( B != None )
	{
		Eidx = B.Eidx;
		while (Eidx > 0)
		{
			Eidx--;
			//log("about to drop evidence");
			DropEvidence(B.Evidence[Eidx], Other, DropLocation);
			B.Evidence[Eidx] = None;
		}
		B.Eidx = 0;

		// SpecialItems
		if (B.bSpecialItem)
		{
			DropSpecialItem(B.SpecialItemClass, Other, DropLocation);
			B.bSpecialItem = false;
		}

		if ( !bDropMoney )
			return;

		if (B.Money < 2000)
		{
			if (B.Money > 50)
			{
				PezAmount = B.Money / 2;
				AddMoney(Other, -PezAmount);
			}
		}
		else
		{
			PezAmount = 1000;
			AddMoney(B, -PezAmount);
		}

		if ( PezAmount > 0 )
			DropMoney(B, PezAmount, DropLocation);
	}
}


///////////////////////////////////////
// SpawnScriptedPawn
///////////////////////////////////////

final function SpawnScriptedPawn()
{
	local FlockPawn	A;
	local	s_ScriptedPawnStartPoint	S;
	local bird1 bird1;
	local nalirabbit nalirabbit;
	local cow cow;

	foreach allactors(class'FlockPawn', A)
	{ 
		//log("found  "$p);
		A.Destroy();
	}

	foreach allactors(class's_ScriptedPawnStartPoint', S)
	{
		if (S.Type == "bird")
		{
			bird1 = spawn(class'bird1',,, S.Location);
			bird1.GoalTag = S.Tag;
			bird1.CircleRadius = S.Radius;
			bird1.bCircle = S.Boola;
		}	
		else if (S.Type == "rabbit")
		{
			nalirabbit = spawn(class'nalirabbit',,, S.Location);
			nalirabbit.WanderRadius = S.Radius;
			nalirabbit.bStayClose = S.Boola;
		}
		else if (S.Type == "cow")
		{
			cow = spawn(class'cow',,, S.Location);
			cow.WanderRadius = S.Radius;
			cow.bStayClose = S.Boola;
			cow.bHasBaby = S.Boolb;
		}
	}
}


///////////////////////////////////////
// PreCacheReferences
///////////////////////////////////////

function PreCacheReferences()
{
	//never called - here to force precaching of meshes
	spawn(class's_Player_T');
	spawn(class's_BotMCounterTerrorist1');

	spawn(class's_Knife');

	spawn(class's_Glock');
	spawn(class's_deagle');
	spawn(class'TO_Berreta');

	spawn(class's_MAC10');
	spawn(class's_MP5N');
	spawn(class'TO_MP5kPDW');
	spawn(class's_MossBerg');
	spawn(class's_m3');
	spawn(class'TO_Saiga');

	spawn(class's_Ak47');
	spawn(class'TO_hk33');
	spawn(class's_FAMAS');
	spawn(class's_hksr9');
	spawn(class's_Psg1');
	spawn(class'TO_SteyrAug');
	spawn(class's_p85');
	spawn(class's_OICW');
	spawn(class'TO_M4m203');
		
	spawn(class'TO_Grenade');
}


///////////////////////////////////////
// PickupQuery
///////////////////////////////////////

//
// Called when pawn has a chance to pick Item up (i.e. when 
// the pawn touches a weapon pickup). Should return true if 
// he wants to pick it up, false if he does not want it.
//
function bool PickupQuery( Pawn Other, Inventory item )
{
	local Mutator			M;
	local byte				bAllowPickup;
	local int					OldAmmo;
	local	Inventory		Inv;

	//if ( BaseMutator.HandlePickupQuery(Other, item, bAllowPickup) )
	//	return (bAllowPickup == 1);

	// C4, Special Forces can't pick it up
	if ( Other.PlayerReplicationInfo != None )
		if ( item.IsA('s_C4') && (Other.PlayerReplicationInfo.Team == 1) )
			return false;

	// Hack to prevent players from picking up NullAmmo 
	if ( item.IsA('NullAmmo') && Other.IsA('s_Player') )
		return false;

	if ( Other.Inventory == None )
		return true;
	else
	{
		if (item.IsA('s_weapon'))
		{
				for( Inv=Other.Inventory; Inv!=None; Inv=Inv.Inventory )
				{	 
					if (Inv.IsA('s_Weapon') && s_Weapon(Inv).WeaponClass == s_Weapon(Item).WeaponClass)
					{
						// Player can only carry a grenade.
						if (s_Weapon(Inv).WeaponClass == 5)
						{
							return false;
						}
						else if (Item.Class == Inv.Class)
						{
							//P = Pawn(Other);
							if (s_Weapon(Item) != None && s_Weapon(Item).bUseClip)
							{
								s_Weapon(Inv).RemainingClip += s_Weapon(Item).RemainingClip;
								if (s_Weapon(Inv).RemainingClip > s_Weapon(Inv).MaxClip)
									s_Weapon(Inv).RemainingClip = s_Weapon(Inv).MaxClip;
							
								if (Other.IsA('s_Player'))
									Other.ReceiveLocalizedMessage( class'PickupMessagePlus', 0, None, None, s_Weapon(Inv).Class );
								Item.PlaySound(Item.PickupSound);

								if (Level.Game.LocalLog != None)
									Level.Game.LocalLog.LogPickup(Item, Other);
								if (Level.Game.WorldLog != None)
									Level.Game.WorldLog.LogPickup(Item, Other);
							}
							Item.Destroy();
							//Item.SetRespawn();
						}
						return false;
					}
				}		
				return true;

		}
		else
			return !Other.Inventory.HandlePickupQuery(Item);
	}
}


///////////////////////////////////////
// ChangeModel
///////////////////////////////////////

final function ChangeModel( Pawn P, int num)
{
/*	log("set model"@class'TOPModels.TO_ModelHandler'.default.ModelMesh[num]
		@"num:"@num@"to"@P@"name:"@class'TOPModels.TO_ModelHandler'.default.ModelName[num]
		@"Skin1:"@class'TOPModels.TO_ModelHandler'.default.Skin1[num]
		@"Skin2:"@class'TOPModels.TO_ModelHandler'.default.Skin2[num]
		@"Skin3:"@class'TOPModels.TO_ModelHandler'.default.Skin3[num]
		@"Skin4:"@class'TOPModels.TO_ModelHandler'.default.Skin4[num]);
*/
	if ( class'TOPModels.TO_ModelHandler'.default.ModelType[num] == MT_None )
		return;

	if (P.IsA('s_Bot'))
		s_Bot(P).PlayerModel = num;
	else if (P.IsA('s_Player'))
		s_Player(P).PlayerModel = num;

	P.static.SetMultiSkin(P, "", "", num);

	// Only assign mesh if player is visible!
	if ( !(P.PlayerReplicationInfo.bWaitingPlayer || P.PlayerReplicationInfo.bIsSpectator) )
		P.Mesh = class'TOPModels.TO_ModelHandler'.default.ModelMesh[num];
}		 


///////////////////////////////////////
// ChangePModel
///////////////////////////////////////

final function ChangePModel( Pawn P, int num, int team, bool bDie)
{
	local	Actor	StartPoint;
	local	byte	OldTeam;
	local	s_Player	sP;
	local	bool	bNoWeapons, bChangeModel, bChangeTeam, bNotPlaying;

	if ( bBalancing )
		return;

	bDie = true;
	//log("TO_GameBasics::ChangePModel");

	//if ( team > 1 )
	//	team = 0;
	
	sP = s_Player(P);

	OldTeam = P.PlayerReplicationInfo.Team;
	bChangeTeam = OldTeam != team;

	// Allow only one team change per round.
	if (sP != None)
	{
		if ( sP.bAlreadyChangedTeam && bChangeTeam )
		{
			sP.ReceiveLocalizedMessage(class's_MessageVote', 7);
			return;
		}

		if ( !sP.PlayerReplicationInfo.bWaitingPlayer )
			sP.bAlreadyChangedTeam = true;

		bNotPlaying = sP.bNotPlaying || sP.PlayerReplicationInfo.bWaitingPlayer;
		bNoWeapons = sP.bDead || sP.PlayerReplicationInfo.bWaitingPlayer;
		bChangeModel = (num == 255) || (num != sP.PlayerModel);

		// Prevent player from dying during team/model switch?
		if ( bNotPlaying || (!bChangeTeam) || (GamePeriod != GP_RoundPlaying) )
			bDie = false;	
	}
	else if ( P.PlayerReplicationInfo.bWaitingPlayer || P.PlayerReplicationInfo.bIsSpectator )
		bDie = false;

	//log("TO_GameBasics::ChangePModel - P"@P.GetHumanName()@"num"@num@"team"@team@"bDie"@bDie);

	if ( bDie )
	{
		P.TakeDamage(500000, None, P.Location, vect(0,0,0), 'ChangedTeam');
		//P.Died( None, '', P.Location );		
	}
	else
	{
		//log("TO_GameBasics::ChangePModel - don't kill");
		if ( bChangeTeam && !bNoWeapons/*&& (GamePeriod == GP_RoundPlaying)*/ )
		{
			//log("TO_GameBasics::ChangePModel - drop inventory");
			// Drop specific inventory
			DropInventory(P, false);
		}
	}

	if ( bChangeTeam )
		ChangeTeam(P, team);

	// Change Team successful, change model
	if ( P.PlayerReplicationInfo.Team == Team )
	{
		if ( num == 255 )
		{
			if ( team == 1 )
				SetRandomSFModel(P);
			else
				SetRandomTerrModel(P);
		}
		else
			ChangeModel(P, num);

		// Livefeeds of current team.
		if ( bChangeTeam && (P.GetStateName() == 'PlayerSpectating') )
			PlayerPawn(P).Fire(0.0);
	}

	// giving default pistol
	if ( !bDie && bChangeTeam && !bNoWeapons && !bNotPlaying )
	{
		GiveTeamWeapons(P);
		if ( P.Weapon == None )
			P.SwitchToBestWeapon();
	}
}		 


///////////////////////////////////////
// SetRandomSFModel
///////////////////////////////////////

final function SetRandomSFModel(Pawn Other)
{
	ChangeModel(Other, class'TOPModels.TO_ModelHandler'.static.GetRandomSFModel(Other));
}


///////////////////////////////////////
// SetRandomTerrModel
///////////////////////////////////////

final function SetRandomTerrModel(Pawn Other)
{
	ChangeModel(Other, class'TOPModels.TO_ModelHandler'.static.GetRandomTerrModel(Other));
}


///////////////////////////////////////
// VotePlayerOut
///////////////////////////////////////

final function VotePlayerOut(s_Player Instigator, s_Player Victim)
{
	local	byte			i, EmptySlot, NumVotes;
	local	bool			bAlreadyVoted, bVoted, bKicked;
	local	TO_PRI		VictimTOPRI;
	local	s_Player	P;
	local int				j, NeededVotes;

	//log("TO_GameBasics::VotePlayerOut");

	EmptySlot = 255;
	VictimTOPRI = TO_PRI(Victim.PlayerReplicationInfo);

	if ( NumPlayers < 4 )
	{
		Instigator.ClientMessage("Vote: need more players.", 'Event', true);
		return;
	}

	if ( VictimTOPRI == None )
	{
		log("TO_GameBasics::VotePlayerOut - VictimTOPRI == none");
		return;
	}

	while ( /*(VictimTOPRI.VoteFrom[i] != None) &&*/ i < 48)
	{
		if ( VictimTOPRI.VoteFrom[i] == Instigator.PlayerReplicationInfo )
			// Already voted
			return;

		if ( VictimTOPRI.VoteFrom[i] == None )
		{
			if ( EmptySlot == 255 )
				EmptySlot = i;
		}
		else
			NumVotes++;

		i++;
	}

	if ( EmptySlot != 255 )
	{
		if ( VictimTOPRI.VoteFrom[EmptySlot] == None )
		{
			VictimTOPRI.VoteFrom[EmptySlot] = Instigator.PlayerReplicationInfo;
			bVoted = true;
			NumVotes++;
		}
	}
	else
		log("TO_GameBasics::VotePlayerOut - no more slots available!!");


	NeededVotes = Max(Min(NumPlayers - 2, NumPlayers / 2), 1);

	//log("TO_GameBasics::VotePlayerOut - NumVotes:"@NumVotes@"NeededVotes:"@NeededVotes@"NumPlayers:"@NumPlayers);

	// Kick Player
	if ( NumVotes > NeededVotes )
	{
		foreach allactors(class's_Player', P)
			P.ReceiveLocalizedMessage(class's_MessageVote', 1, VictimTOPRI);

		// Make it a tempkick ban.
		TempKickBan(Victim, "Voted out of the game.");		
	}
	else if ( bVoted )
	{
		foreach allactors(class's_Player', P)
			P.ReceiveLocalizedMessage(class's_MessageVote', 0, Instigator.PlayerReplicationInfo, VictimTOPRI);
	}

}


//
// Sounds


///////////////////////////////////////
// SetVoiceType
///////////////////////////////////////

final function	SetVoiceType(PlayerReplicationInfo PRI)
{
	if ( PRI.Team == 0 )
		PRI.VoiceType = class<VoicePack>(DynamicLoadObject("TODatas.VoiceT1", class'Class'));
	else
		PRI.VoiceType = class<VoicePack>(DynamicLoadObject("TODatas.VoiceSF1", class'Class'));
}


///////////////////////////////////////
// PlaySoundDeath
///////////////////////////////////////

function PlaySoundDeath(Pawn Other)
{
	local	float decision;

	// Play death sound
	decision = FRand();
	if (decision < 0.1)
		Other.PlaySound(Sound'die1', SLOT_Misc);
	else if (decision < 0.2)
		Other.PlaySound(Sound'die2', SLOT_Misc);
	else if (decision < 0.3)
		Other.PlaySound(Sound'die3', SLOT_Misc);
	else if (decision < 0.4)
		Other.PlaySound(Sound'die4', SLOT_Misc);
	else if (decision < 0.5)
		Other.PlaySound(Sound'die5', SLOT_Misc);
	else if (decision < 0.6)
		Other.PlaySound(Sound'die6', SLOT_Misc);
	else 
		Other.PlaySound(Sound'die7', SLOT_Misc);
}


///////////////////////////////////////
// ClientPlaySoundBeginRound
///////////////////////////////////////

final function ClientPlaySoundBeginRound(s_Player P)
{
	local	float	rnd;

	rnd = FRand();

	if (P.PlayerReplicationInfo.Team == 1)
	{
		if (rnd < 0.5)
			P.ClientPlaySound(Sound'SF_move3x',, true);
		else
			P.ClientPlaySound(Sound'SF_go3x',, true);
	}
	else
	{
		if (rnd < 0.5)
			P.ClientPlaySound(Sound'TER_move3x',, true);
		else
			P.ClientPlaySound(Sound'TER_go3x',, true);
	}
	//s_Player(P).ClientPlaySound(Sound'okletsgo',, true);
}


///////////////////////////////////////
// ClientPlaySoundEndRound
///////////////////////////////////////

final function ClientPlaySoundEndRound(s_Player P, Byte WinningTeam)
{
	local	float	rnd;

	rnd = FRand();

	if (P.PlayerReplicationInfo.Team == 1)
	{
		if (WinningTeam != 1)
			P.ClientPlaySound(Sound'SF_missionaborted',, true);
		else
		{
			if (rnd < 0.25)
				P.ClientPlaySound(Sound'SF_anotherjobwelldone',, true);
			else if (rnd < 0.5)
				P.ClientPlaySound(Sound'SF_congratulations',, true);
			else if (rnd < 0.75)
				P.ClientPlaySound(Sound'SF_number1',, true);
			else 
				P.ClientPlaySound(Sound'SF_welldonethebest',, true);
		}
	}
	else
	{
		if (WinningTeam != 0)
			P.ClientPlaySound(Sound'TER_missionaborted',, true);
		else
		{
			if (rnd < 0.25)
				P.ClientPlaySound(Sound'TER_i_guessed_we_showed_em',, true);
			else if (rnd < 0.5)
				P.ClientPlaySound(Sound'TER_nice_going',, true);
			else if (rnd < 0.75)
				P.ClientPlaySound(Sound'TER_no_match',, true);
			else 
				P.ClientPlaySound(Sound'TER_we_got_them_good',, true);
		}
	}
}

/*
///////////////////////////////////////
// s_PlayDynamicTeamSound()
///////////////////////////////////////

function s_PlayDynamicTeamSound(byte messageIndex, byte VoiceIndex, byte num, optional bool bOverride, optional PlayerReplicationInfo SenderPRI)
{
	local pawn P;

	for ( P=Level.PawnList; P!=None; P=P.NextPawn )
	{
		if (P!=None && P.IsA('s_BPlayer') && s_BPlayer(P).PlayerReplicationInfo!=None
			&& s_BPlayer(P).PlayerReplicationInfo.Team==num)
			s_BPlayer(P).s_PlayDynamicSound(messageIndex, VoiceIndex, bOverride, SenderPRI);
	}
}
*/

///////////////////////////////////////
// PlayRandEnemyDown()
///////////////////////////////////////

function PlayRandEnemyDown(Pawn P)
{/*
	local byte s, t;

	s=13+Rand(3);

	if (P.IsA('s_Player'))
		t=s_Player(P).GetVoiceType();
	else if (P.IsA('s_Bot'))
		t=s_Bot(P).GetVoiceType();
	else
		return;

	s_PlayDynamicTeamSound(s, t, P.PlayerReplicationInfo.Team,, P.PlayerReplicationInfo);
	*/
}

/*
///////////////////////////////////////
// GetRandTeamVoice()
///////////////////////////////////////

function byte GetRandTeamVoice(byte num)
{
	if (num==0)
		return 1;
	
	return 0;
}


///////////////////////////////////////
// PlayStartRoundSound()
///////////////////////////////////////

function PlayStartRoundSound()
{
	local byte r;
	
	r=Rand(3);
	s_PlayDynamicTeamSound(r, GetRandTeamVoice(0), 0, true);
	r=Rand(3);
	s_PlayDynamicTeamSound(r, GetRandTeamVoice(1), 1, true);
}


///////////////////////////////////////
// PlayWinRoundSound()
///////////////////////////////////////

function PlayWinRoundSound(byte num)
{
	// num = 0  terr win
	// num = 1  ct win

	local byte s, t;

	if (num==0)
		s=4;
	else if (num==1)
		s=9+Rand(3);

	if (num==0)
		t=4;
	else if (num==1)
		t=5+Rand(3);

	s_PlayDynamicTeamSound(s, GetRandTeamVoice(0), 0, true);
	s_PlayDynamicTeamSound(t, GetRandTeamVoice(1), 1, true);
}
*/


///////////////////////////////////////
// defaultproperties
///////////////////////////////////////

/*
		 PlayerModel(0)=(bIsSFmodel=True,Name="Walker",Mesh=LodMesh'Botpack.Commando')
     PlayerModel(1)=(bIsSFmodel=True,Name="S.W.A.T.",Mesh=LodMesh'Botpack.Commando')
     PlayerModel(2)=(bIsSFmodel=True,Name="Police",Mesh=LodMesh'Botpack.Commando')
     PlayerModel(3)=(Name="Camo Jaguars",Mesh=LodMesh'Botpack.Commando')
     PlayerModel(4)=(Name="Green-camo",Mesh=LodMesh'Botpack.Commando')
     PlayerModel(5)=(Name="Krazy Ivan",Mesh=LodMesh'Botpack.Soldier')
     PlayerModel(6)=(bIsSFmodel=True,Name="Carter",Mesh=LodMesh'Botpack.Commando')
     PlayerModelSkin(0)=(Skin1="TODatas.ButcherSkins.Walker",Skin2="TODatas.Walker")
     PlayerModelSkin(1)=(Skin1="TODatas.SWATganja.swat",Skin2="TODatas.swat")
     PlayerModelSkin(2)=(Skin1="TODatas.SWATganja.policeb",Skin2="TODatas.police")
     PlayerModelSkin(3)=(Skin1="TODatas.SWATganja.terror",Skin2="TODatas.tcamo")
     PlayerModelSkin(4)=(Skin1="TODatas.SWATganja.terr_green",Skin2="TODatas.green")
     PlayerModelSkin(5)=(Skin1="TODatas.ButcherSkins.Ivan",Skin2="TODatas.Krazy")
     PlayerModelSkin(6)=(Skin1="TODatas.ButcherSkins.carter",Skin2="TODatas.carter")

		 PlayerModel(2)=(bIsSFmodel=false,Name="Jungle",Mesh=LodMesh'TOPModels.TerrorMesh')
		 PlayerModelSkin(2)=(Skin1="TOPModels.ApocSkins.TERR1",Skin2="TOPModels.TERR1")



		 NetWait=0
     RestartWait=0
     CountDown=0

			 PlayerModel(0)=(bIsSFmodel=false,Name="CamoMask",Mesh=LodMesh'TOPModels.TerrorMesh')
		 PlayerModelSkin(0)=(Skin1="TOPModels.ApocSkins.ATM",Skin2="TOPModels.ATM")
		 PlayerModel(1)=(bIsSFmodel=false,Name="Camo",Mesh=LodMesh'TOPModels.TerrorMesh')
		 PlayerModelSkin(1)=(Skin1="TOPModels.ApocSkins.AT",Skin2="TOPModels.AT")
		 PlayerModel(2)=(bIsSFmodel=false,Name="Scarface",Mesh=LodMesh'TOPModels.TerrorMesh')
		 PlayerModelSkin(2)=(Skin1="TOPModels.ApocSkins.TERR2",Skin2="TOPModels.TERR2")
		 PlayerModel(3)=(bIsSFmodel=true,Name="S.W.A.T.",Mesh=LodMesh'TOPModels.TerrorMesh')
		 PlayerModelSkin(3)=(Skin1="TOPModels.ApocSkins.SWAT1",Skin2="TOPModels.SWAT1")
		 PlayerModel(4)=(bIsSFmodel=true,Name="Police",Mesh=LodMesh'TOPModels.TerrorMesh')
		 PlayerModelSkin(4)=(Skin1="TOPModels.ApocSkins.SWAT2",Skin2="TOPModels.SWAT2")

		 PlayerModel(5)=(bIsSFmodel=true,Name="Black Seal",Mesh=LodMesh'TOPModels.SealMesh')
		 PlayerModelSkin(5)=(Skin1="TOPModels.SealSkins.SealBlack",Skin2="TOPModels.SealBlack")
		 PlayerModel(6)=(bIsSFmodel=true,Name="Seal InfoCom",Mesh=LodMesh'TOPModels.SealMesh')
		 PlayerModelSkin(6)=(Skin1="TOPModels.SealSkins.SealBlue",Skin2="TOPModels.SealBlue")
		 PlayerModel(7)=(bIsSFmodel=false,Name="White Seal",Mesh=LodMesh'TOPModels.SealMesh')
		 PlayerModelSkin(7)=(Skin1="TOPModels.SealSkins.WhiteSeal",Skin2="TOPModels.WhiteSeal")
*/

defaultproperties
{
     RoundDelay=5
     RoundDuration=4
     PreRoundDuration1=10
     KillPrice=300
     KillHostagePrice=-2000
     WinAmount=1500
     LostAmount=1000
     RescueAmount=1000
     RescueTeamAmount=300
     EvidenceAmount=500
     bMirrorDamage=True
     MinAllowedScore=5
     MaxMoney=20000
     MaxAllowedTeams=2
     MaxTeamSize=12
     TeamColor(0)="Terrorists"
     TeamColor(1)="Special Forces"
     MinPlayers=8
     TimeLimit=20
     bAlwaysForceRespawn=True
     NetWait=1
     RestartWait=1
     CountDown=1
     StartUpMessage="Tactical Ops"
     InitialBots=8
     OvertimeMessage=""
     BotConfigType=Class's_SWAT.s_BotInfo'
     bNoMonsters=True
     ScoreBoardType=Class's_SWAT.s_ScoreBoard'
     BotMenuType="s_SWAT.s_BotSC"
     RulesMenuType="s_SWAT.s_RulesSC"
     SettingsMenuType="s_SWAT.s_SettingsSC"
     GameUMenuType="TOSystem.TO_GameMenu"
     MultiplayerUMenuType="TOSystem.TO_MultiplayerMenu"
     GameOptionsMenuType="TOSystem.TO_OptionMenu"
     HUDType=Class's_SWAT.s_HUD'
     MapListType=Class's_SWAT.s_MapList'
     MapPrefix="TO"
     BeaconName="Tactical Ops"
     GameName="Tactical Ops"
     DMMessageClass=Class's_SWAT.TO_DMMessage'
     MutatorClass=Class's_SWAT.TO_DMMutator'
     GameReplicationInfoClass=Class'TOSystem.s_GameReplicationInfo'
}
