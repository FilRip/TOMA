//=============================================================================
// TO_ProjSmokeGren
//=============================================================================
//
// Tactical Ops 
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen and Benoit "JAH" Delayen
//=============================================================================

class TO_ProjSmokeGren extends s_GrenadeAway;

var bool	bExploded;


///////////////////////////////////////
// BeginPlay
///////////////////////////////////////

simulated function BeginPlay()
{
	local	Texture	GrenadeSkin;

	GrenadeSkin = Texture(DynamicLoadObject("TOModels.gren_smoke", class'Texture'));
	MultiSkins[1] = GrenadeSkin;	

	if ( Level.Netmode != NM_DedicatedServer )
		SetTimer(5.0, false);

	Super.BeginPlay();
}


///////////////////////////////////////
// Destroyed 
///////////////////////////////////////

simulated event Destroyed()
{
	Super.Destroyed();

	bHidden = true;
	AmbientSound = None;
}


///////////////////////////////////////
// Explosion
///////////////////////////////////////
 
simulated function Explosion(vector HitLocation)
{
	// Create smoke effect
	//Spawn(class'TO_SmokeGenerator', Self,, Location);
	
	// disable smoke grenade projectile
	bNoSmoke = true;
	bExploded = true;
	//AmbientSound = None;

	//SetTimer(30, false);
	SoundVolume = 128;
	SetTimer(0.01, false);
}
 

///////////////////////////////////////
// Timer
///////////////////////////////////////

simulated function Timer()
{
	if ( bExploded )
	{
		if ( Level.Netmode != NM_DedicatedServer )
		{
			Spawn(class'TO_SmokeLarge',,, Location + Vect(0,0,2));

			if ( Level.bDropDetail || !Level.bHighDetailMode )
				SetTimer(1.5 + FRand() * 0.5, false);
			else
				SetTimer(1.0 + FRand() * 0.2, false);
		}
		//destroy();
	}
	else
		Super.Timer();
}


///////////////////////////////////////
// defaultproperties 
///////////////////////////////////////
//Mesh=LodMesh'TOModels.pflashbang'

defaultproperties
{
     bNoSmoke=False
     bServerTiming=False
     ImpactPitch=0.500000
     LifeSpan=34.000000
     AmbientSound=Sound'TODatas.Weapons.SmokeGrenSound'
     SoundRadius=64
     SoundVolume=48
}
