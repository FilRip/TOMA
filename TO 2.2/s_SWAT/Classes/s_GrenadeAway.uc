//=============================================================================
// s_GrenadeAway
//=============================================================================
//
// Tactical Ops 
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen and Benoit "JAH" Delayen
//=============================================================================

class s_GrenadeAway extends Actor;
//class s_GrenadeAway extends Projectile;

var bool	bCanHitOwner, bHitWater, bBlowWhenTouch, bNoSmoke, bServerTiming;
var float Count, SmokeRate;
var int		NumExtraGrenades;

var	float	ExpTiming, ImpactPitch;


// Projectile variables.

// Motion information.
var() float    Speed;               // Initial speed of projectile.
var() float    MaxSpeed;            // Limit on speed of projectile (0 means no limit)

// Damage attributes.
var() float    Damage;         
var() int	   MomentumTransfer; // Momentum imparted by impacting projectile.
var() name	   MyDamageType;

// Projectile sound effects
var() sound    SpawnSound;		// Sound made when projectile is spawned.
var() sound	   ImpactSound;		// Sound made when projectile hits something.
var() sound    MiscSound;		// Miscellaneous Sound.

var() float		ExploWallOut;	// distance to move explosions out from wall

// explosion decal
var() class<Decal> ExplosionDecal;


simulated final function RandSpin(float spinRate)
{
	DesiredRotation = RotRand();
	RotationRate.Yaw = spinRate * 2 *FRand() - spinRate;
	RotationRate.Pitch = spinRate * 2 *FRand() - spinRate;
	RotationRate.Roll = spinRate * 2 *FRand() - spinRate;	
}

simulated singular function Touch(Actor Other)
{
	local actor HitActor;
	local vector HitLocation, HitNormal, TestLocation;
	
	if ( Other.IsA('BlockAll') )
	{
		HitWall( Normal(Location - Other.Location), Other);
		return;
	}
	if ( Other.bProjTarget || (Other.bBlockActors && Other.bBlockPlayers) )
	{
		//get exact hitlocation
	 	HitActor = Trace(HitLocation, HitNormal, Location, OldLocation, true);
		if (HitActor == Other)
		{
			if ( Other.bIsPawn 
				&& !Pawn(Other).AdjustHitLocation(HitLocation, Velocity) )
					return;
			ProcessTouch(Other, HitLocation); 
		}
		else 
			ProcessTouch(Other, Other.Location + Other.CollisionRadius * Normal(Location - Other.Location));
	}
}


///////////////////////////////////////
// ThrowGrenade
///////////////////////////////////////

final simulated function ThrowGrenade()
{
	local vector X,Y,Z;
	local rotator RandRot;              

	if ( Level.bHighDetailMode && !Level.bDropDetail ) 
		SmokeRate = 0.05;
	else 
		SmokeRate = 0.15;

	if ( Role == ROLE_Authority )
	{
		//log("s_GrenadeAway::ThrowGrenade - Speed:"@Speed);

		GetAxes(Instigator.ViewRotation, X, Y, Z);	
		Velocity = X * (Instigator.Velocity Dot X)*0.4 + Vector(Rotation) * (Speed + FRand() * 100);
		Velocity.z += 210;
		MaxSpeed = 2000;
		RandSpin(50000);	
		bCanHitOwner = false;

		if ( Instigator.HeadRegion.Zone.bWaterZone )
		{
			bHitWater = true;
			Velocity = 0.2 * Velocity;			
		}
		else
			Velocity = 0.6 * Velocity;

		if ( bNoSmoke )
			Disable('Tick');

		if ( bServerTiming )
			SetTimer(ExpTiming, false);
	}	
}


///////////////////////////////////////
// ZoneChange
///////////////////////////////////////

simulated function ZoneChange( Zoneinfo NewZone )
{
	local waterring w;
	
	if (!NewZone.bWaterZone || bHitWater) 
		return;

	bHitWater = True;
	w = Spawn(class'WaterRing',,,,rot(16384,0,0));
	w.DrawScale = 0.2;
	w.RemoteRole = ROLE_None;
	Velocity=0.6*Velocity;
}


///////////////////////////////////////
// Timer
///////////////////////////////////////

simulated function Timer()
{
	Explosion(Location + Vect(0,0,1)*16);
}


///////////////////////////////////////
// Tick
///////////////////////////////////////

simulated function Tick(float DeltaTime)
{
	local UT_SpriteSmokePuff b;

	if ( (Level.NetMode == NM_DedicatedServer) || bNoSmoke || bHitWater || Level.bDropDetail ) 
	{
		Disable('Tick');
		return;
	}

	Count += DeltaTime;
	if ( (Count > Frand() * SmokeRate + SmokeRate) ) 
	{
		b = Spawn(class'TO_SmokeLight');
		b.RemoteRole = ROLE_None;		
		Count = 0;
	}
}


///////////////////////////////////////
// Landed
///////////////////////////////////////

simulated function Landed( vector HitNormal )
{
	HitWall( HitNormal, None );
}


///////////////////////////////////////
// ProcessTouch
///////////////////////////////////////

simulated function ProcessTouch( actor Other, vector HitLocation )
{
	if ( !bBlowWhenTouch )
		return;

	if ( Other != Level && (Other != instigator || bCanHitOwner) )
		Explosion(HitLocation - Other.Location);
}


///////////////////////////////////////
// HitWall
///////////////////////////////////////

simulated function HitWall( vector HitNormal, actor Wall )
{
	bCanHitOwner = true;
	Velocity = 0.50 * (( Velocity dot HitNormal ) * HitNormal * (-2.0) + Velocity);   // Reflect off Wall w/damping
	RandSpin(100000);
	speed = VSize(Velocity);

	if ( Level.NetMode != NM_DedicatedServer )
		PlaySound(ImpactSound, SLOT_Misc, 1.5,,, ImpactPitch );

	if ( Velocity.Z > 400 )
		Velocity.Z = 0.5 * (400 + Velocity.Z);	
	else if ( speed < 20 ) 
	{
		bBounce = false;
		SetPhysics(PHYS_None);
	}
}


///////////////////////////////////////
// Explosion
///////////////////////////////////////

simulated function Explosion(vector HitLocation)
{
	local	TO_GrenadeExplosion	expl;

	bHidden = true;
	if ( Role == Role_Authority )
		expl = spawn(class'TO_GrenadeExplosion',,, HitLocation);
	//expl.RemoteRole = ROLE_None;

 	Destroy();
}


///////////////////////////////////////
// defaultproperties
///////////////////////////////////////

defaultproperties
{
     bNoSmoke=True
     bServerTiming=True
     ExpTiming=4.000000
     ImpactPitch=0.900000
     speed=600.000000
     MaxSpeed=1000.000000
     Damage=80.000000
     MomentumTransfer=50000
     MyDamageType=GrenadeDeath
     ImpactSound=Sound'UnrealShare.Eightball.GrenadeFloor'
     ExplosionDecal=Class'Botpack.BlastMark'
     bReplicateInstigator=True
     Physics=PHYS_Falling
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=5.500000
     bDirectional=True
     DrawType=DT_Mesh
     Mesh=LodMesh'TOModels.wgrenade'
     DrawScale=1.200000
     bUnlit=True
     bGameRelevant=True
     SoundVolume=0
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     bCollideActors=True
     bCollideWorld=True
     bBounce=True
     bFixedRotationDir=True
     DesiredRotation=(Pitch=12000,Yaw=5666,Roll=2334)
     NetPriority=2.500000
}
