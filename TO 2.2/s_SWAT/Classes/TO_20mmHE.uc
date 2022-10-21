//=============================================================================
// TO_20mmHE
//=============================================================================
//
// Tactical Ops
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen
//=============================================================================

class TO_20mmHE expands RocketMk2;

var	bool	bSmoke;

///////////////////////////////////////
// PostBeginPlay 
///////////////////////////////////////

simulated function PostBeginPlay()
{
	LightType = LT_None;

	if ( !bSmoke )
		return;

	if ( Level.bHighDetailMode )
	{
		SmokeRate = 200 / Speed; 
		if ( Level.bDropDetail )
			SoundRadius = 6;
	}
	else 
		SmokeRate = 0.2 + FRand() * 0.02;

	SetTimer(SmokeRate, true);
}


///////////////////////////////////////
// Timer 
///////////////////////////////////////

simulated function Timer()
{
	local ut_SpriteSmokePuff b;
	local	Actor	A;

	if ( Region.Zone.bWaterZone || (Level.NetMode == NM_DedicatedServer) )
		Return;

	if ( Level.bHighDetailMode )
	{
		if ( Level.bDropDetail )
			A = Spawn(class'LightSmokeTrail');
		else
			A = Spawn(class'UTSmokeTrail');

		if (A != None)
			A.ScaleGlow = 0.25;
		SmokeRate = 152 / Speed; 
	}
	else 
	{
		SmokeRate = 0.15 + FRand() * 0.01;
		b = Spawn(class'ut_SpriteSmokePuff');
		b.ScaleGlow = 0.25;
		b.RemoteRole = ROLE_None;
	}

	SetTimer(SmokeRate, false);
}


///////////////////////////////////////
// Flying 
///////////////////////////////////////

auto state Flying
{
	simulated function ProcessTouch (Actor Other, Vector HitLocation)
	{
		if ( Other != Level && Other != instigator && Other != None ) 
			Explode(HitLocation, Normal(HitLocation - Other.Location));
	}

	simulated function Explode(vector HitLocation, vector HitNormal)
	{
		local TO_GrenadeExplosion s;

		bHidden = true;
		s = spawn(class'TO_GrenadeExplosion',,, HitLocation + HitNormal * 16);
		if (s == None)
			log("Explode - couldn't spawn TO_GrenadeExplosion");
 		s.RemoteRole = ROLE_None;

 		Destroy();
	}

	function BeginState()
	{
		local vector Dir;

		Dir = vector(Rotation);
		Velocity = speed * Dir;
		Acceleration = Dir * 50;
		//PlayAnim( 'Wing', 0.2 );
		if (Region.Zone.bWaterZone)
		{
			bHitWater = true;
			Velocity = 0.6 * Velocity;
		}
	}
}


///////////////////////////////////////
// defaultproperties 
///////////////////////////////////////

defaultproperties
{
     bSmoke=True
     speed=1700.000000
     SpawnSound=None
     ImpactSound=None
     Physics=PHYS_Falling
     AnimSequence=Still
     AmbientSound=None
     LightType=LT_None
     LightBrightness=0
     LightRadius=0
}
