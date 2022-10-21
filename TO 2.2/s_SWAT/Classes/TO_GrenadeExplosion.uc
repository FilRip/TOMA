//=============================================================================
// TO_GrenadeExplosion
//=============================================================================
//
// Tactical Ops
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen
//=============================================================================

class	TO_GrenadeExplosion	extends UT_SpriteBallExplosion;


var	bool		bCheck, bHDEffect;
var	float		Scale;

var() name	  MyDamageType;
var()	Sound		ExplSound;


///////////////////////////////////////
// PostBeginPlay 
///////////////////////////////////////

simulated function PostBeginPlay()
{
	//log("TO_GrenadeExplosion::PostBeginPlay"@Level.TimeSeconds);

	if ( !Level.bDropDetail )
		Texture = SpriteAnim[Rand(3)];	

	if ( (Level.NetMode != NM_DedicatedServer) && Level.bHighDetailMode && !Level.bDropDetail ) 
		bHDEffect = true;

	SetTimer(0.05 + FRand() * 0.04, false);

	Super(AnimSpriteEffect).PostBeginPlay();		
}


///////////////////////////////////////
// Setup 
///////////////////////////////////////

simulated function Setup()
{
	DrawScale *= Scale; 
	LightRadius *= Scale;
	LightType = LT_Steady;

	if ( Role == Role_Authority )
		ServerExplosion();

	if ( Level.NetMode != NM_DedicatedServer )
		Explosion();
}


///////////////////////////////////////
// Timer 
///////////////////////////////////////

simulated Function Timer()
{
	local	UT_SpriteBallChild SBC;

	if ( !bCheck )
	{
		// Call in timer, otherwise Scale parameter isn't changed in time.
		Setup();
		bCheck = true;
	}

	if ( Level.bDropDetail || !bHDEffect)
		return;

	if ( FRand() < 0.4 + (MissCount - 1.5 * ExpCount) * 0.25 )
	{
		ExpCount++;
		SBC = Spawn(class'UT_SpriteBallChild',Self,'', Location + (20 + 20*FRand()) * (VRand()+Vect(0,0,0.5))*Scale );
		SBC.DrawScale *= Scale;
		SBC.RemoteRole = Role_None;
	}
	else
		MissCount++;

	if ( (ExpCount < 3) && (LifeSpan > 0.45) ) 
		SetTimer(0.05 + FRand() * 0.05, false);
}


///////////////////////////////////////
// ServerExplosion 
///////////////////////////////////////

simulated function ServerExplosion()
{
	MakeSound();
	HurtRadius(250.0 * Scale, 600.0 * Scale, MyDamageType, 80000.0 * Scale, Location);
	//MakeNoise(1.0 * Scale);
}


///////////////////////////////////////
// Explosion 
///////////////////////////////////////

simulated function Explosion()
{
	local	BlastMark	BM;

	PlaySound(ExplSound,, 12.0 * Scale,, 32768 * Scale);
	//PlaySound(ExplSound, SLOT_Misc, 12.0 * Scale,, 32768 * Scale);
	//PlaySound(ExplSound, SLOT_Talk, 12.0 * Scale,, 32768 * Scale);

	if ( !Level.bDropDetail )
	{
		BM = Spawn(class'Botpack.BlastMark', self,, Location, rot(16384,0,0));
//		BM.DrawScale *= Scale;
	}
}


///////////////////////////////////////
// defaultproperties 
///////////////////////////////////////

defaultproperties
{
     Scale=1.000000
     MyDamageType=Explosion
     ExplSound=Sound'TODatas.Weapons.HEGrenExpl'
     DrawScale=5.000000
     LightType=LT_None
     LightRadius=50
}
