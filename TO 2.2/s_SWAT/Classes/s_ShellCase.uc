//=============================================================================
// s_ShellCase
//=============================================================================
//
// Tactical Ops
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen and Benoit "JAH" Delayen
//=============================================================================

class s_ShellCase extends Projectile;

var bool	bHasBounced;
var int		numBounces;
var	Sound	HitSound;

///////////////////////////////////////
// PostBeginPlay 
///////////////////////////////////////

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	//RemoteRole = Role_None;
/*	if ( Level.NetMode == NM_DedicatedServer )
		LifeSpan = 0.75;
	else*/ if ( Level.bHighDetailMode )
		LifeSpan = 10.0;

	//SetTimer(0.1, false);

	/*
	if ( Level.bDropDetail && (Level.NetMode != NM_DedicatedServer)
		&& (Level.NetMode != NM_ListenServer) )
		LifeSpan = 1.5;
*/
//	if ( Level.bDropDetail )
//		LightType = LT_None;
}

/*
///////////////////////////////////////
// Timer 
///////////////////////////////////////

simulated function Timer()
{
	LightType = LT_None;
}
*/

///////////////////////////////////////
// HitWall 
///////////////////////////////////////

simulated function HitWall( vector HitNormal, actor Wall )
{
	local vector RealHitNormal;

	if ( Level.bDropDetail )
	{
		Destroy();
		return;
	}

	if ( bHasBounced && ((numBounces > 3) || (FRand() < 0.85) || (Velocity.Z > -50)) )
		bBounce = false;

	numBounces++;
	if ( numBounces > 3 )
	{
		Destroy();
		return;
	}
	else if ( !Region.Zone.bWaterZone )
		PlaySound(HitSound, Slot_None, 0.50);

	RealHitNormal = HitNormal;
	HitNormal = Normal(HitNormal + 0.4 * VRand());

	if ( (HitNormal Dot RealHitNormal) < 0 )
		HitNormal *= -0.5; 

	Velocity = 0.5 * (Velocity - 2 * HitNormal * (Velocity Dot HitNormal));
	RandSpin(100000);
	bHasBounced = True;
}


///////////////////////////////////////
// ZoneChange 
///////////////////////////////////////

simulated function ZoneChange( Zoneinfo NewZone )
{
	if (NewZone.bWaterZone && !Region.Zone.bWaterZone) 
	{
		Velocity=0.2*Velocity;	
		PlaySound(sound 'Drip1');			
		bHasBounced=True;
	}
}


///////////////////////////////////////
// Landed 
///////////////////////////////////////

simulated function Landed( vector HitNormal )
{
	local rotator RandRot;

	if ( Level.bDropDetail )
	{
		Destroy();
		return;
	}
	if ( !Region.Zone.bWaterZone )
		PlaySound(HitSound, Slot_None, 0.50);
	if ( numBounces > 3 )
	{
		Destroy();
		return;
	}
	
	SetPhysics(PHYS_None);
	RandRot = Rotation;
	RandRot.Pitch = 0;
	RandRot.Roll = 0;
	SetRotation(RandRot);
}


///////////////////////////////////////
// Eject 
///////////////////////////////////////

final function Eject(Vector Vel)
{
	Velocity = Vel;
	RandSpin(100000);
	if ( (Instigator != None) && Instigator.HeadRegion.Zone.bWaterZone ) 
	{
		Velocity += 0.85 * Instigator.Velocity;
		Velocity = Velocity * (0.2+FRand()*0.2);
		bHasBounced=True;
	}
}


///////////////////////////////////////
// defaultproperties 
///////////////////////////////////////
/*
bUnlit=True
*/

defaultproperties
{
     HitSound=Sound'UnrealShare.AutoMag.Shell2'
     MaxSpeed=1000.000000
     bNetOptional=True
     bReplicateInstigator=False
     Physics=PHYS_Falling
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=3.000000
     Mesh=LodMesh'TOModels.s9mmsc'
     DrawScale=2.000000
     bUnlit=True
     bCollideActors=False
     bBounce=True
     bFixedRotationDir=True
     NetPriority=1.400000
}
