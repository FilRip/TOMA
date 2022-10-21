//=============================================================================
// s_ExplosiveC4.
//=============================================================================
//
// Tactical Ops
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen and Benoit "JAH" Delayen
//=============================================================================

class s_ExplosiveC4 extends Actor;
//class s_ExplosiveC4 extends Projectile;
// Decoration

var float CDSpeed, CountDown;
var	int		Count, MaxCount, ChangeCount;
var	bool	bPlantedInBombingSpot, bExploded, bToldToLeave;

var()	sound							SoundActivated;
var()	sound							SoundFailed;
var()	sound							SoundCompleted;
var		bool							bBeingActivated;
var		Actor							DefusedBy, CurrentBombingZone;
var		int								C4RadiusRange;
var		float							C4Duration; // defuse time


//simulated singular function Touch(Actor Other) {}
//simulated function HitWall (vector HitNormal, actor Wall) {}


///////////////////////////////////////
// BeginPlay 
///////////////////////////////////////

simulated function BeginPlay()
{
	Texture'TOModels.TOTexts.C4display'.NotifyActor = Self;
}


///////////////////////////////////////
// PostBeginPlay 
///////////////////////////////////////

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	CDSpeed = 1;
	MaxCount = 18;
	CountDown = (MaxCount + 0.7) * 3;
	ChangeCount = 0;
	SetTimer(CDSpeed, false);
}


///////////////////////////////////////
// Destroyed 
///////////////////////////////////////

simulated function Destroyed()
{
	Texture'TOModels.TOTexts.C4display'.NotifyActor = None;
}


///////////////////////////////////////
// RenderTexture 
///////////////////////////////////////

simulated event RenderTexture(ScriptedTexture Tex)
{
	local Color C;
	local string Temp;
	
	Temp = String(Max(int(CountDown), 0));

	while (Len(Temp) < 4) 
		Temp = "0"$Temp;

	C.R = 0;
	C.G = 0;
	C.B = 0;

	Tex.DrawColoredText( 30, 90, Temp, Font'LEDFont', C );	
}
 

///////////////////////////////////////
// Tick 
///////////////////////////////////////

simulated function Tick( float DeltaTime )
{
	CountDown -= DeltaTime;
}


///////////////////////////////////////
// Timer 
///////////////////////////////////////

simulated function Timer()
{
	local	s_SWATGame	SG;

	if ( Role == Role_Authority )
	{
		SG = s_SWATGame(Level.Game);

		if ( bExploded )
		{	
			if ( SG != None )
			{
				SG.C4Exploded( bPlantedInBombingSpot, CurrentBombingZone );
			}
			else 
				log("s_ExplosiveC4 - Timer - SG == None");

			Destroy();
			return;
		}
	
		// Tell Everyone to leave!
		if ( (CountDown < 11.0)	&& !bToldToLeave )			
		{
			SG.SendGlobalBotObjective( None, 0.8, 2, 'O_GoHome', false);
			bToldToLeave = true;
		}
	}

	Count++;
	if ( Count >= MaxCount )
	{
		if ( ChangeCount == 2 )
			C4Explode();
		else
		{
			Count = 0;
			CDSpeed /= 2.0;
			MaxCount *= 2.0;
			ChangeCount++;

			// Tell SF to come and defuse me!
			if ( (ChangeCount < 2) && (Role == Role_Authority) )
				SG.SendGlobalBotObjective( Self, 1.0, 1, 'O_DefuseC4', false);
		}
	}

	if ( Level.NetMode != NM_DedicatedServer )
	{
		if ( CountDown < 5.0 )
			playsound(Sound'UTMenu.SpeechWindowClick', SLOT_Misc, 3.0,, 4096.0*4.0, 1.25);
		else
			playsound(Sound'UTMenu.SpeechWindowClick', SLOT_Misc, 3.0,, 4096.0*4.0, 1.10);
	}

	SetTimer(CDSpeed, false);
//	s_SWATGame(Level.Game).EndGame("Target succefully bombed !");
//	s_SWATGame(Level.Game).SetWinner(0);
//Disable('Tick');
//	spawn(class's_C4ShockWave',,,Location);	
//	RemoteRole = ROLE_SimulatedProxy;	 
 //	Destroy();
}


///////////////////////////////////////
// C4Explode 
///////////////////////////////////////

simulated function C4Explode()
{
	local TO_GrenadeExplosion	expl;
	local	ShockWave		SW;
	local	int					i;

	if ( (Role != Role_Authority) || !IsRoundPeriodPlaying() )
	{
		destroy();
		return;
	}

	// Check Current Bombing Zone.
	CurrentBombingZone = None;
	for (i=0; i<4; i++)
	{
		if ( (Touching[i] != None) && (Touching[i].IsA('s_ZoneControlPoint')) && s_ZoneControlPoint(Touching[i]).bBombingZone )
		{			
			CurrentBombingZone = Touching[i];
			break;
		}
	}

	// Do not endround by kills, but make Ts win their objective.
	s_SWATGame(Level.Game).bC4Explodes = true;

	SW = spawn(class's_C4ShockWave',,,Location);
	SW.Instigator = None;
	//SW.RemoteRole = ROLE_None;

	expl = spawn(class'TO_GrenadeExplosion',,, Location);
	expl.Scale = 4.0;
	expl.Instigator = None;
	//expl.RemoteRole = ROLE_None;

	bExploded = true;
	SetTimer(2.0, false);
}


//
// Defusing
//


///////////////////////////////////////
// IsRoundPeriodPlaying
///////////////////////////////////////

function bool IsRoundPeriodPlaying()
{
	local	s_SWATGame	SG;

	SG = s_SWATGame(Level.Game);
	if (SG != None)
	{ 
		if (SG.GamePeriod == GP_RoundPlaying)
			return true;
	}

	return false;
}


///////////////////////////////////////
// IsRelevant 
///////////////////////////////////////
// Only Special Forces can defuse the bomb

function bool	IsRelevant(Actor Other)
{
	local	Pawn	P;

	// Hack to test
	//return true;

	P = Pawn(Other);

	if (P != None)
	{
		if ( (P.PlayerReplicationInfo != None) && (P.PlayerReplicationInfo.Team == 1) )
			return true;
	}

	return false;
}


///////////////////////////////////////
// C4Activate 
///////////////////////////////////////
// Starting to defuse the bomb

function bool C4Activate(Actor Defuser)
{
	local	Actor	A;

	if ( bBeingActivated || !IsRelevant(Defuser) )
		return false;

	if ( !IsRoundPeriodPlaying() )
		return false;

	//log("s_ExplosiveC4 - C4Activate");

	DefusedBy = Defuser;
	bBeingActivated = true;

	if ( SoundActivated != None )
		PlaySound(SoundActivated, SLOT_None, 4.0);

	return true;
}


///////////////////////////////////////
// C4Failed 
///////////////////////////////////////
// Failed to defuse the bomb

function C4Failed()
{
	local	Actor	A;

	//log("s_ExplosiveC4 - C4Failed");

	if ( SoundFailed != None )
		PlaySound(SoundFailed, SLOT_None, 4.0);

	bBeingActivated = false;
}


///////////////////////////////////////
// C4Complete 
///////////////////////////////////////
// bomb defused

function C4Complete()
{
	local	Actor				A;
	local	s_SWATGame	SW;

	//log("s_ExplosiveC4 - C4Complete");

	if ( SoundCompleted != None )
		PlaySound(SoundCompleted, SLOT_None, 4.0);

	bBeingActivated = false;

	SW = s_SWATGame(Level.Game);
	if (SW != None)
		SW.C4Defused( DefusedBy );
	else 
		log("s_ExplosiveC4 - C4Complete - SW == None");

	Destroy();
}


///////////////////////////////////////
// defaultproperties 
///////////////////////////////////////
/*
	bStatic=false
	bStasis=false
*/

defaultproperties
{
     C4RadiusRange=100
     C4Duration=10.000000
     bAlwaysRelevant=True
     Physics=PHYS_Falling
     RemoteRole=ROLE_SimulatedProxy
     DrawType=DT_Mesh
     Mesh=LodMesh'TOModels.eC4'
     AmbientGlow=255
     CollisionRadius=30.000000
     CollisionHeight=12.000000
     bCollideActors=True
     bCollideWorld=True
     bBlockActors=True
     bBlockPlayers=True
     NetPriority=2.700000
}
