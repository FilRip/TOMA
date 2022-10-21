//=============================================================================
// s_Projectile
//=============================================================================
//
// Tactical Ops
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen
//=============================================================================

class s_Projectile expands Projectile;

var		float		MaxDamage;
var		float		MaxWallPiercing, OldMaxWall;
var		float		MaxRange;	
var		float		HP;
var		float		SmokeDS;

var		Vector	OriginalLocation;
var		float		ProjectileAge;
var		Vector	AgeLocation;
//var		bool		bProcessingHit;

var		Actor		LastHitActor;

var		bool		bReduceSFX;
var   bool		bHeavyWallHit;


///////////////////////////////////////
// PostBeginPlay 
///////////////////////////////////////

simulated function PostBeginPlay()
{
	local ut_SpriteSmokePuff	s;
	local	s_Weapon						WeaponOwner;
	local	float								Rand;

	if ( (Owner == None) || !Owner.IsA('s_Weapon'))
	{
		//log("s_Projectile::PostBeginPlay - Owner == None || !Owner.IsA('s_Weapon')");
		return;
	}

	WeaponOwner = s_Weapon(Owner);
	if (s_SWATGame(Level.Game) != None)
		bReduceSFX = s_SWATGame(Level.Game).bReduceSFX;
	else
	{
		bReduceSFX = true;
		//log("s_Projectile - PostBeginPlay - SG == None !!");
	}

	//log("PostBeginPlay");
	MaxDamage = WeaponOwner.MaxDamage;
	MaxWallPiercing = WeaponOwner.MaxWallPiercing;
	MaxRange = WeaponOwner.MaxRange;
	Speed = WeaponOwner.ProjectileSpeed;

	bHeavyWallHit = WeaponOwner.bHeavyWallHit;

	SmokeDS = 0.6 + MaxWallPiercing / 24;
	Velocity = Vector(Rotation) * Speed;
	OriginalLocation = Location;
	ProjectileAge = MaxRange / 100.0;
	AgeLocation = Location;

	MakeNoise(SmokeDS);
	Rand = FRand();
	if (Rand < 0.50)
		AmbientSound = Sound'balle4';
	else 
		AmbientSound = Sound'balle_siffle1';
/*	else if (Rand < 0.40)
		AmbientSound = Sound'balle_siffle4';
	else if (Rand < 0.60)
		AmbientSound = Sound'balle_siffle5';
	else if (Rand < 0.80)
		AmbientSound = Sound'balle_siffle2';
	else if (Rand < 1.0)
		AmbientSound = Sound'balle_siffle3';
*/
	SoundRadius = 124 * SmokeDS + FRand() * 64;
  SoundVolume = 186 * SmokeDS + FRand() * 100;

	/*
	if ( !Level.bDropDetail && (!bReduceSFX  || FRand() < 0.50) ) 
	{
		s = Spawn(class'ut_SpriteSmokePuff');
		s.DrawScale = SmokeDS * FRand();
		s.RemoteRole = ROLE_None;
	}	
	*/

	LifeSpan = Max(MaxRange / Speed, 0.2);
	// Try LifeSpan instead of timer!
	//SetTimer(0.1, true);
}


///////////////////////////////////////
// Flying 
///////////////////////////////////////

auto state Flying
{
	simulated function ZoneChange( Zoneinfo NewZone )
	{
		local vector tmpVect;
		local WaterRing w;

		if ( !NewZone.bWaterZone ) 
			return;

		if ( !Level.bDropDetail ) 
		{
			w = Spawn(class'WaterRing',,,,rot(16384,0,0));
			w.DrawScale = SmokeDS / 4 * FRand();
			w.RemoteRole = ROLE_None;
		}

		PlaySound(Sound'UnrealShare.Generic.LSplash', SLOT_None, 6);
	} 

/*
	simulated function Timer()
	{
		local	float	dist;

		Super.Timer();

		// Maximum range
		dist = VSize(OriginalLocation - Location);
		if ( dist > MaxRange )
		{
			//log("s_Projectile::Flying::Timer - Maximum range reached, destroying!"@(dist/48.0)@"m");

			Explode(Location, Vector(Rotation));
			Disable('Timer');
			return;
		}
	}
*/

	simulated function ProcessTouch (Actor Other, vector HitLocation)
	{
		local Vector	X,Y,Z;
		local	vector	OldLocation;
		local	vector	tmpHL, tmpHN;
		local	float		Vdiff;

		if ( (Other == None) || (Other == instigator) )
			return;

		if ( (Other.IsA('s_Player') && s_Player(Other).bNotPlaying) 
			|| (Other.IsA('s_Bot') && s_Bot(Other).bNotPlaying) 
			|| (Other.IsA('Pawn') && Pawn(Other).PlayerReplicationInfo.bIsSpectator))
			return;

		if ( LastHitActor == Other )
		{
			Explode(Location, Vector(Rotation));
			return;
		}

		LastHitActor = Other;
		//bProcessingHit = true;

    if ( Role == ROLE_Authority )
		{
      //Other.TakeDamage(MaxDamage, instigator, HitLocation, MomentumTransfer * Vector(Rotation), 'shot');
			Other.TakeDamage(MaxDamage, instigator, HitLocation, MaxDamage * 50 * Vector(Rotation), 'shot');
			MakeNoise(MaxDamage / 100);
		}

		GetAxes(Rotation, x,y,z);
		OldLocation = Location;
		if ( (MaxWallPiercing > 0) && (setlocation(Location + x*MaxWallPiercing*1.5)) )
		{
			if (Trace(TmpHL, TmpHN, OldLocation, Location, true) != None)
			{
				Vdiff = VSize(TmpHL - OldLocation);
				//log ("Touch trace succesful - Vdiff: "$Vdiff);

				OldMaxWall = MaxWallPiercing;
				
				// Decreasing MaxWallPiercing (
				MaxWallPiercing -= (Vdiff / 3.0);
				if (MaxWallPiercing < 1)
				{
					Explode(TmpHL, TmpHN);
					return;
				}

				//if (!setlocation(TmpHL))
				//	setlocation(OldLocation);
					// Decreasing projectile power

				HP = MaxWallPiercing / OldMaxWall;
				MaxDamage *= HP;
				MaxRange *= HP;
				SmokeDS *= HP;
				Other.PlaySound(Sound'balle_PlayerHit', SLOT_None);
			}
			else
				Explode(Location, Vector(Rotation));
		}
		else
		{
			//log("weird - ProcessTouch - trace == none");
			Explode(Location, Vector(Rotation));
		}
  }


	simulated function HitWall (vector HitNormal, actor Wall)
	{
		local vector	x,y,z;
		local	vector	OldLocation, NewLocation;
		local	float		OldMaxWall, PiercingDist;
		local	vector	tmpHL, tmpHN;
		local	float		Vdiff;
		local ut_SpriteSmokePuff s;

		//log("hitwall entered - "$Wall);
		if ( Wall == None /*|| bProcessingHit*/)
			return;

		if ( Role == ROLE_Authority )
		{
			//if ( (Mover(Wall) != None) && Mover(Wall).bDamageTriggered )
			Wall.TakeDamage( MaxDamage, instigator, Location, MaxDamage * 50 * Normal(Velocity), '');

			MakeNoise(MaxDamage / 100);
		}
		

		if ( bHeavyWallHit )
			Spawn(class'TO_HeavyWallHitEffect', self, , Location, rotator(HitNormal));
		else
			Spawn(class'TO_LightWallHitEffect', self, , Location, rotator(HitNormal));

		/*
			s = Spawn(class'ut_SpriteSmokePuff');
			s.DrawScale = SmokeDS * FRand();
			s.RemoteRole = ROLE_None;
		*/
/*
		if (FRand() < 0.5)
			PlaySound(Sound 'balle_hitwall1',, 4.0,,100);
		else
			PlaySound(Sound 'balle_hitwall2',, 4.0,,100);
*/ 
		// See if Projectile can go through wall
		GetAxes(Rotation, x,y,z);
		OldLocation = Location;

		PiercingDist = 2.0;
		NewLocation = OldLocation + PiercingDist * X;
		while ( (PiercingDist < MaxWallPiercing) && !SetLocation(NewLocation) )
		{
			PiercingDist += 2.0;
			NewLocation = OldLocation + PiercingDist * X;
		}

		if ( (PiercingDist >= MaxWallPiercing) || (MaxWallPiercing < 1) )
		{
			Explode(OldLocation + ExploWallOut * Vector(Rotation), Vector(Rotation));
			return;
		}

		Vdiff = VSize(NewLocation - OldLocation);
		OldMaxWall = MaxWallPiercing;

		// Decreasing MaxWallPiercing
		MaxWallPiercing -= PiercingDist / 2.0;
		if ( MaxWallPiercing < 1 )
		{
			Explode(NewLocation + ExploWallOut * Vector(Rotation), Vector(Rotation));
			return;
		}
				
		// Spawn Explosion decal on the other side of the wall
		if ( Trace(TmpHL, TmpHN, OldLocation, NewLocation, true) != None )
		{
			if ( bHeavyWallHit )
				Spawn(class'TO_HeavyWallHitEffect', self, , TmpHL, rotator(TmpHN));
			else
				Spawn(class'TO_LightWallHitEffect', self, , TmpHL, rotator(TmpHN));
		}
				
		// Decreasing projectile power
		HP = MaxWallPiercing / OldMaxWall;
		MaxDamage *= HP;
		MaxRange *= HP;
		SmokeDS *= HP;
/*
		if (!Level.bDropDetail && (!bReduceSFX || FRand() < 0.5) ) 
		{
			s = Spawn(class'ut_SpriteSmokePuff');
			s.DrawScale = SmokeDS * FRand(); 
			s.RemoteRole = ROLE_None;
		}	
*/
	}

}


///////////////////////////////////////
// Explode 
///////////////////////////////////////

simulated function Explode(vector HitLocation, vector HitNormal)
{
	//Spawn(class'UT_LightWallHitEffect', self, , HitLocation, rotator(HitNormal));
	LifeSpan = 0.001;
	Destroy();
}


///////////////////////////////////////
// Destroyed 
///////////////////////////////////////

simulated event Destroyed()
{
	AmbientSound = None;
	bHidden = true;
}


///////////////////////////////////////
// defaultproperties 
///////////////////////////////////////

defaultproperties
{
     speed=10000.000000
     MaxSpeed=1000000.000000
     bHidden=True
     bOwnerNoSee=True
     bOnlyOwnerSee=True
     bNetOptional=True
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=5.000000
     Style=STY_None
     Mesh=LodMesh'UnrealI.TracerM'
     DrawScale=0.010000
     bUnlit=True
     NetPriority=1.500000
}
