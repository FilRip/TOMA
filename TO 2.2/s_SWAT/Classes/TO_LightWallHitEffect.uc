//=============================================================================
// TO_LightWallHitEffect
//=============================================================================
//
// Tactical Ops
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen
//=============================================================================

class TO_LightWallHitEffect extends UT_WallHit;


///////////////////////////////////////
// SpawnSound 
///////////////////////////////////////

simulated function SpawnSound()
{
	local float decision;

	decision = FRand();

	if ( decision < 0.25 ) 
		PlaySound(sound'ricochet',, 0.5,,1200, 0.5 + FRand());		
	else if ( decision < 0.5 )
		PlaySound(sound'Impact1',, 0.66,,1000);
	else if ( decision < 0.75 )
		PlaySound(sound'Impact2',, 0.66,,1000);
}


///////////////////////////////////////
// SpawnEffects 
///////////////////////////////////////

simulated function SpawnEffects()
{
	local Actor A;

	if ( !Level.bDropDetail )
		SpawnSound();

	if ( !Level.bHighDetailMode )
		return;

	if ( Level.bDropDetail )
	{
		if ( FRand() > 0.4 )
			Spawn(class'Pock');
		return;
	}

	Spawn(class'Pock');

	if ( Region.Zone.bWaterZone )
		return;

	A = Spawn(class'UT_SpriteSmokePuff',,,Location + 8 * Vector(Rotation));
	A.RemoteRole = ROLE_None;

	if ( FRand() < 0.5 )
		spawn(class'UT_Spark',,,Location + 8 * Vector(Rotation));
}


///////////////////////////////////////
// defaultproperties 
///////////////////////////////////////

defaultproperties
{
     MaxChips=0
     MaxSparks=1
     DrawScale=0.120000
}
