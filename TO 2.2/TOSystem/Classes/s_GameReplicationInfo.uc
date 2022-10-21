//=============================================================================
// s_GameReplicationInfo
//=============================================================================
//
// Tactical Ops
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen
//=============================================================================
 
class s_GameReplicationInfo extends TournamentGameReplicationInfo;

//var TeamInfo Teams[6];
var				int								RoundStarted;
var				int								RoundDuration;
var				int								RoundNumber;
var				bool							bPreRound, bAllowGhostCam, bMirrorDamage, bEnableBallistics;
var				int								friendlyfirescale;



///////////////////////////////////////
// replication
///////////////////////////////////////

replication
{
	// Send to clients
	reliable if ( Role == ROLE_Authority )
		bPreRound, RoundDuration, RoundStarted, RoundNumber, bAllowGhostCam, 
		bMirrorDamage, bEnableBallistics, friendlyfirescale;

//	reliable if( Role == ROLE_Authority )
//		ResetTime;
}


///////////////////////////////////////
// PostBeginPlay
///////////////////////////////////////

simulated function PostBeginPlay()
{
	local int i;

	Super.PostBeginPlay();

	if ( TournamentGameInfo(Level.Game) != None)
	{
		TotalGames = TournamentGameInfo(Level.Game).EndStatsClass.Default.TotalGames;
		TotalFrags = TournamentGameInfo(Level.Game).EndStatsClass.Default.TotalFrags;
		TotalDeaths = TournamentGameInfo(Level.Game).EndStatsClass.Default.TotalDeaths;
		//TotalFlags = TO_TournamentGameInfo(Level.Game).EndStatsClass.Default.TotalFlags;
		for (i=0; i<3; i++)
		{
			BestPlayers[2-i] = TournamentGameInfo(Level.Game).EndStatsClass.Default.BestPlayers[i];
			BestFPHs[2-i] = TournamentGameInfo(Level.Game).EndStatsClass.Default.BestFPHs[i];
			BestRecordDate[2-i] = TournamentGameInfo(Level.Game).EndStatsClass.Default.BestRecordDate[i];
		}
	}
}


simulated function Timer()
{
	local PlayerReplicationInfo PRI;
	local int i, FragAcc;

	if ( Level.NetMode == NM_Client )
	{
		if ( (Level.TimeSeconds - SecondCount) >= (1.0/Level.TimeDilation) )
		{
			ElapsedTime++;
			if ( RemainingMinute != 0 )
			{
				RemainingTime = RemainingMinute;
				RemainingMinute = 0;
			}
			if ( /*(RemainingTime > 0) &&*/ !bStopCountDown )
				RemainingTime--;
			SecondCount += Level.TimeDilation;
		}
	}

	for (i=0; i<32; i++)
		PRIArray[i] = None;
	i=0;
	foreach AllActors(class'PlayerReplicationInfo', PRI)
	{
		if ( i < 32 )
			PRIArray[i++] = PRI;
	}

	// Update various information.
	UpdateTimer = 0;
	for (i=0; i<32; i++)
		if (PRIArray[i] != None)
			FragAcc += PRIArray[i].Score;
	SumFrags = FragAcc;

	if ( Level.Game != None )
		NumPlayers = Level.Game.NumPlayers;
}


///////////////////////////////////////
// defaultproperties
///////////////////////////////////////

defaultproperties
{
     RoundDuration=5
     NetUpdateFrequency=2.000000
}
