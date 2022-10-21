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

class TO_HeavyWallHitEffect extends UT_WallHit;


///////////////////////////////////////
// SpawnSound 
///////////////////////////////////////

simulated function SpawnSound()
{
	local float decision;

	decision = FRand();
	if ( decision < 0.5 ) 
		PlaySound(sound'ricochet',, 1,,1200, 0.5+FRand());		
	else if ( decision < 0.75 )
		PlaySound(sound'Impact1',, 1,,1000);
	else
		PlaySound(sound'Impact2',, 1,,1000);
}


///////////////////////////////////////
// SpawnEffects 
///////////////////////////////////////

simulated function SpawnEffects()
{
	local Actor A;
	local int j;
	local int NumSparks;
//	local vector Dir;

	if ( !Level.bDropDetail )
		SpawnSound();

	NumSparks = rand(MaxSparks);
	for ( j=0; j<MaxChips; j++ )
		if ( FRand() < ChipOdds ) 
		{
			NumSparks--;
			A = spawn(class'Chip');
			if ( A != None )
				A.RemoteRole = ROLE_None;
		}

	//Dir = Vector(Rotation);

	if ( !Level.bHighDetailMode )
		return;

	Spawn(class'Pock');

	if ( Region.Zone.bWaterZone || Level.bDropDetail )
		return;

	A = Spawn(class'UT_SpriteSmokePuff',,,Location + 8 * Vector(Rotation));
	A.RemoteRole = ROLE_None;

	if ( FRand() < 0.4 )
		Spawn(class'UT_Sparks');

	if ( NumSparks > 0 ) 
		for (j=0; j<NumSparks; j++) 
			spawn(class'UT_Spark',,,Location + 8 * Vector(Rotation));
}


///////////////////////////////////////
// defaultproperties 
///////////////////////////////////////

defaultproperties
{
     MaxSparks=4
     ChipOdds=0.500000
}
