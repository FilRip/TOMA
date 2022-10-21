//=============================================================================
// s_ThrowingKnife
//=============================================================================
//
// Tactical Ops 
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen and Benoit "JAH" Delayen
//=============================================================================
 
class s_ThrowingKnife extends Projectile;

var bool	bCanHitOwner, bHitWater;
var	Actor	LastHit;
var Pawn	Owner;
var	int		hitCount;


///////////////////////////////////////
// Touch
///////////////////////////////////////

simulated function Touch( actor Other )
{
	if ( Other == LastHit )
		return;

	LastHit = Other;
	if ( Other.bIsPawn )
		ProcessTouch(Other, Other.Location);
}


///////////////////////////////////////
// PostBeginPlay
///////////////////////////////////////

simulated function PostBeginPlay()
{
	local vector X,Y,Z;
	local rotator RandRot;

	Super.PostBeginPlay();

	if ( Role == ROLE_Authority )
	{
		GetAxes(Instigator.ViewRotation,X,Y,Z);	
		Velocity = X * (Instigator.Velocity Dot X)*0.4 + Vector(Rotation) * (Speed + FRand() * 100);
		Velocity.z += 150;
		MaxSpeed = 1500;
		RotationRate.Pitch = 100000* 2 *FRand() - 100000;
		bCanHitOwner = false;
		if (Instigator.HeadRegion.Zone.bWaterZone)
		{
			bHitWater = true;
			Disable('Tick');
			Velocity=0.6*Velocity;			
		}
	}	

	SetTimer(0.5, false);
}


///////////////////////////////////////
// ZoneChange
///////////////////////////////////////

simulated function ZoneChange( Zoneinfo NewZone )
{
	local waterring w;
	
	if ( !NewZone.bWaterZone || bHitWater ) 
		return;

	bHitWater = true;
	w = Spawn(class'WaterRing',,,,rot(16384,0,0));
	w.DrawScale = 0.2;
	w.RemoteRole = ROLE_None;
	Velocity=0.6*Velocity;
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
	local int dam;

	if ( Other == Level )
		return;

	if ( (Pawn(Other) == Owner) && !bCanHitOwner)
		return;

	if ( (Role == Role_Authority) && (Pawn(Other) != None) )
	{
		dam = damage * VSize(Velocity) / 800;
		Pawn(Other).TakeDamage(dam, Instigator, HitLocation, dam * 50 * Vector(Rotation), 'stabbed');
	}

	Destroy();
}


///////////////////////////////////////
// HitWall
///////////////////////////////////////

simulated function HitWall( vector HitNormal, actor Wall )
{
	local	ut_SpriteSmokePuff		s;
	local	ut_Sparks				sp;
	local	TO_KnifePickup			k;
	local	bool					bReduceSFX;
	local	rotator					knifeRotation;
	local	int						dam;
	local	vector					knifePosCorrection;

	hitCount++;

	if ( hitCount > 10 ) 
	{		
		// Will become pickup if it hits too many walls (fail-safe)
		if ( Role == Role_Authority )
			k = Spawn(class'TO_KnifePickup', self, , Location, knifeRotation );
		
		Destroy();
	}

	if (s_SWATGame(Level.Game) != None)
		bReduceSFX = s_SWATGame(Level.Game).bReduceSFX;
	else
		bReduceSFX = true;

	bCanHitOwner = True;
	knifeRotation = rotator(-self.velocity);
	knifeRotation.pitch += 16384 + (FRand() - 0.5) * 10000;

	// If hit a damage triggered mover, give damage to mover 
	if ( (Role == Role_Authority) && (Mover(Wall) != None) && Mover(Wall).bDamageTriggered ) 
	{
		dam = damage * VSize(Velocity) / 800;
		Wall.TakeDamage( dam, Instigator, Location, MomentumTransfer * Normal(Velocity), '');
	}

	// Knife 'sticks' to wall
	if ( VSize(Velocity) > 400 								// Velocity must be high enough
	&& FRand() > 0.5 										// Sometimes it isn't the blade that hits the wall
	&& (Mover(Wall) == None)								// Mustn't stick on movers
	&& Abs(HitNormal dot (-Normal(self.velocity))) > 0.4) // Won't stick if the angle isn't right
	{	
		if ( Role == Role_Authority )
		{
			knifePosCorrection = Normal(self.velocity) * Abs(HitNormal dot (-Normal(self.velocity)) ) * 5;
			k = Spawn(class'TO_KnifePickup', self, , Location - knifePosCorrection, knifeRotation );
			k.SetPhysics(PHYS_None);
		}

		if ( Level.NetMode != NM_DedicatedServer )
		{
			sp = Spawn(class'ut_Sparks', self, , , rotator(HitNormal));
			sp.RemoteRole = ROLE_None;
			PlaySound(Sound'TODatas.Weapons.knifewall', SLOT_Misc, 1.5 );
		}
		Destroy();
	}
	// Knife becomes pickup and falls to floor
	else if ( VSize(Velocity) < 40 ) 
	{	// Will become a pickup if the velocity is very low
		if ( Role == Role_Authority )
			k = Spawn(class'TO_KnifePickup', self, , Location, knifeRotation );
		Destroy();
	}
	// Knife rebounces on wall
	else
	{
		velocity = 0.25 * (( Velocity dot HitNormal ) * HitNormal * (-2.0) + Velocity);
		PlaySound(ImpactSound, SLOT_Misc, 1.5 );
	
		if ( Level.NetMode != NM_DedicatedServer )
		{
			if (!bReduceSFX || (bReduceSFX && (FRand() < 0.5)) ) 
			{
				s = Spawn(class'ut_SpriteSmokePuff', self, , , rotator(HitNormal));
				s.DrawScale = 1 * FRand() * 0.5;
				s.RemoteRole = ROLE_None;
			}		
		}
	}
}


///////////////////////////////////////
// Timer
///////////////////////////////////////

simulated function Timer()
{
	bCanHitOwner = true;
}



///////////////////////////////////////
// defaultproperties
///////////////////////////////////////

defaultproperties
{
     speed=800.000000
     MaxSpeed=1000.000000
     Damage=80.000000
     MomentumTransfer=600
     MyDamageType=GrenadeDeath
     ImpactSound=Sound'UnrealShare.Eightball.GrenadeFloor'
     Physics=PHYS_Falling
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=0.000000
     Mesh=LodMesh'TOModels.tknife'
     DrawScale=1.020000
     AmbientGlow=64
     bUnlit=True
     bBounce=True
     bFixedRotationDir=True
     DesiredRotation=(Pitch=12000,Yaw=5666,Roll=2334)
}
