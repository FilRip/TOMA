//=============================================================================
// s_ConcussionChunk
//=============================================================================
//
// Tactical Ops 
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen and Benoit "JAH" Delayen
//=============================================================================

class s_ConcussionChunk extends UTChunk;

var	float	BaseVelocity;

 
///////////////////////////////////////
// PostBeginPlay 
///////////////////////////////////////

function PostBeginPlay()
{
	local rotator RandRot;

	Super.PostBeginPlay();

	if ( Role == ROLE_Authority )
	{
		Velocity.z = BaseVelocity * FRand() / 3;
		velocity.y = BaseVelocity * (FRand()-0.5);
		velocity.x = BaseVelocity * (FRand()-0.5);

		if (Region.zone.bWaterZone)
			Velocity *= 0.5;
	}


}


///////////////////////////////////////
// defaultproperties 
///////////////////////////////////////

defaultproperties
{
     BaseVelocity=4000.000000
     Physics=PHYS_Falling
     LifeSpan=4.100000
     Mesh=LodMesh'Botpack.chunk2M'
     AmbientGlow=38
}
