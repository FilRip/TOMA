//=============================================================================
// TO_PZone
//=============================================================================
//
// Tactical Ops
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen
//=============================================================================

class TO_PZone extends Actor;

// Vars needed by UCEncrypt
//var string StrTab[255];
//var string zzDECSTRTAB[255];
//var string encoding_table[64];  
//var int    zzKeyNdx;  

var		Pawn			zzP;
var		float			zzFrequency;
var		bool			zzbPlayer, zzbBot, zzbNPC;
var		s_Player	zzsP;
var		s_bot			zzB;
var		s_NPCHostage	zzNPC;

var		bool			zzbPlayerChecks;

//function xxPreDecrypt() {} // @@RemoveLine


///////////////////////////////////////
// Initialize
///////////////////////////////////////

simulated function	Initialize()
{
	//log("TO_PZone::Initialize"@Owner.GetHumanName());

	zzP = Pawn(Owner);
	if ( zzP.IsA('s_Player') )
	{
		zzbPlayer = true;
		zzsP = s_Player(zzP);
		zzFrequency = 0.75;
	}
	else if ( zzP.IsA('s_Bot') )
	{
		zzbBot = true;
		zzB = s_Bot(zzP);
		zzFrequency = 1.33;
	}
	else if ( zzP.IsA('s_NPCHostage') )
	{
		zzbNPC = true;
		zzNPC = s_NPCHostage(zzP);
		zzFrequency = 2.0;
	}
	
	// Here to randomize checks.
	// to avoid doing 32 checks during the same tick..
	SetTimer(FRand()*zzFrequency + FRand(), false);
}

/*
///////////////////////////////////////
// Destroyed 
///////////////////////////////////////

simulated event Destroyed()
{
	log("TO_PZone::Destroyed"@Owner.GetHumanName());
}
*/

///////////////////////////////////////
// Timer
///////////////////////////////////////

simulated function Timer()
{
	//log("TO_PZone::Timer - T:"@Level.TimeSeconds@"Self:"@Self@"Owner:"@Owner.GetHumanName());

	// Can process check?
	if ( xxNotValidOwner() )
	{
		SetTimer(zzFrequency * 2.0, false);	
		return;
	}

	xxProcessChecks();
	
	SetTimer(zzFrequency, false);	
}


///////////////////////////////////////
// xxProcessChecks
///////////////////////////////////////

final simulated function	xxProcessChecks()
{
	local	int		zzi;
	local	bool	zzbClimbingLadder;

	//if ( zzbPlayer )
	//	log("TO_PZone::xxProcessChecks - Zone Checks T:"@Level.TimeSeconds@"Owner:"@Owner.GetHumanName());

	// Clear PZone
	xxClearPZone();

	// Zone Check
	for (zzi=0; zzi<4; zzi++)
	{
		if ( zzP.Touching[zzi] != None)
		{
			if ( zzP.Touching[zzi].IsA('s_ZoneControlPoint') )
				xxSetZone( s_ZoneControlPoint(zzP.Touching[zzi]) );
				//zzP.Touching[zzi].Touch(zzP);
			else if ( zzbPlayer && (zzP.Touching[zzi].IsA('TO_Ladder') || zzP.Touching[zzi].IsA('s_Ladder')) )
				zzbClimbingLadder = true;
		}
	}

	// Ladder check
	if ( zzbPlayer && (Role == Role_Authority) )
	{
		if (!zzbClimbingLadder && (zzsP.GetStateName() == 'Climbing') )
		{
			if ( zzsP.Region.Zone.bWaterZone )
			{
				zzsP.SetPhysics(PHYS_Swimming);
				zzsP.GotoState('PlayerSwimming');
			}
			else
				zzsP.GotoState('PlayerWalking');

			zzsP.CalculateWeight();
		}
	}
}


///////////////////////////////////////
// xxSetZone
///////////////////////////////////////

final simulated function xxSetZone( s_ZoneControlPoint Zone )
{
	local	s_SWATGame	SG;

	if ( zzbPlayer && !zzsP.PlayerReplicationInfo.bIsSpectator )
	{
		//log("TO_PZone::xxSetZone - Player");
		zzsP.bInRescueZone = zzsP.bInRescueZone || Zone.bRescuePoint;
		zzsP.bInBombingZone = zzsP.bInBombingZone || Zone.bBombingZone;
		if ( zzsP.PlayerReplicationInfo.team == Zone.OwnedTeam )
		{
			zzsP.bInBuyZone = zzsP.bInBuyZone || Zone.bBuyPoint;
			zzsP.bInHomeBase = zzsP.bInHomeBase || Zone.bHomeBase;
			if ( Zone.bEscapeZone )
			{
				//log("TO_PZone::xxSetZone - bEscapeZone");
				zzsP.bInEscapeZone = zzsP.bInEscapeZone || Zone.bEscapeZone;
				if ( Level.NetMode != NM_Client ) //Role == Role_Authority )
					zzsP.Escape();
			}
		}
	}
	else if ( Level.NetMode != NM_Client ) //Role == Role_Authority )
	{
		if ( zzbBot && !zzB.bNotPlaying )
		{
			if ( Zone.bRescuePoint )
				zzB.bInRescueZone = zzB.bInRescueZone || Zone.bRescuePoint;

			zzB.bInHostageHidingPlace = zzB.bInHostageHidingPlace || Zone.bHostageHidingPlace;
			zzB.bInBombingZone = zzB.bInBombingZone || Zone.bBombingZone;

			if ( zzB.PlayerReplicationInfo.team == Zone.OwnedTeam )
			{
				zzB.bInBuyZone = zzB.bInBuyZone || Zone.bBuyPoint;
				zzB.bInHomeBase = zzB.bInHomeBase || Zone.bHomeBase;

				if ( Zone.bEscapeZone )
				{
					zzB.bInEscapeZone = zzB.bInEscapeZone || Zone.bEscapeZone;
					zzB.Escape();
				}
			}
		}
		else if ( zzbNPC )
		{
			zzNPC.bInHostageHidingPlace = Zone.bHostageHidingPlace;

			if ( Zone.bRescuePoint )
			{
				if ( (zzNPC.Followed != None) && (s_Bot(zzNPC.Followed) != None) )
				{
					if ( s_Bot(zzNPC.Followed).HostageFollowing > 0 )
						s_Bot(zzNPC.Followed).HostageFollowing--;

					SG = s_SWATGame(Level.Game);

					if ( (s_Bot(zzNPC.Followed).HostageFollowing < 1) && (SG != None) )
						SG.ClearBotObjective(s_Bot(zzNPC.Followed));
				}

				zzNPC.Rescued();
			}
		}
	}
}


///////////////////////////////////////
// ClearPZone
///////////////////////////////////////

final simulated function xxClearPZone()
{
	if ( zzbPlayer )
	{
		zzsP.bInBuyZone = false;
		zzsP.bInHomeBase = false;
		zzsP.bInEscapeZone = false;
		zzsP.bInRescueZone = false;
		zzsP.bInBombingZone = false;
	}
	else if ( zzbBot )
	{
		zzb.bInBuyZone = false;
		zzb.bInHomeBase = false;
		zzb.bInEscapeZone = false;
		zzb.bInRescueZone = false;
		zzb.bInBombingZone = false;

		xxCheckBot();
	}
	else if ( zzbNPC )
	{
		zzNPC.bInBuyZone = false;
		zzNPC.bInHomeBase = false;
		zzNPC.bInEscapeZone = false;
		zzNPC.bInRescueZone = false;
	}
}


///////////////////////////////////////
// NotValidOwner
///////////////////////////////////////

final simulated function bool xxNotValidOwner()
{
	if ( Owner == None )
	{
		//log("TO_PZone::xxNotValidOwner - Destroying");
		Destroy();
		return true;
	}
	
	if ( zzP.PlayerReplicationInfo == None )
	{
		//log("TO_PZone::xxNotValidOwner - PlayerReplicationInfo == None");
		return true;
	}

	if ( zzbPlayer && ( zzsP.PlayerReplicationInfo.bIsSpectator || zzsP.PlayerReplicationInfo.bWaitingPlayer) )
		return true;
	else if ( zzbBot && zzb.PlayerReplicationInfo.bIsSpectator )
		return true;

	return false;
}


///////////////////////////////////////
// xxValidConsole
///////////////////////////////////////

final simulated function bool xxValidConsole()
{
	return ( (zzsP.Player != None) && (zzsP.Player.Console != None) );
}


///////////////////////////////////////
// CheckBot
///////////////////////////////////////

final simulated function xxCheckBot()
{
	if ( !zzB.bNotPlaying )
	{
		if ( (zzB.Objective == 'O_AttackEnemy') && ((Level.TimeSeconds - zzB.LastSeenTime) > 5) )
			zzB.ResetLastObj();
	}

	// Bot has a problem, send it to KIA! 
	if ( (zzB.health < 1) 
		&& (zzB.GetStateName() != 'GameEnded') && (zzB.GetStateName() != 'Dying') && (zzB.GetStateName() != 'BotBuying') )
	{
		log("TO_PZone::CheckBot - Ghost:"@zzB.GetHumanName()@"H:"@zzB.health@"s:"@zzB.GetStateName());
		zzB.TakeDamage(5, None, zzB.Location, vect(0, 0, 0), 'Suicided');
	}

}


///////////////////////////////////////
// defaultproperties 
///////////////////////////////////////

defaultproperties
{
     bHidden=True
     bAlwaysTick=True
     RemoteRole=ROLE_None
     DrawType=DT_None
     Texture=None
}
