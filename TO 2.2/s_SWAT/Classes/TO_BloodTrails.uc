//=============================================================================
// TO_BloodTrails
//=============================================================================
//
// Tactical Ops
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen
//=============================================================================

class TO_BloodTrails expands PlayerShadow;

var	Texture	BloodSplat[5];
var	bool		bDecalAttached;


///////////////////////////////////////
// Destroyed
///////////////////////////////////////

event Destroyed()
{
	if ( bDecalAttached )
		DetachDecal();
}

 
///////////////////////////////////////
// SpawnBloodSplat
///////////////////////////////////////

simulated function	SpawnBloodSplat(float	Scale)
{
	local Actor HitActor;
	local Vector HitNormal, HitLocation, ShadowStart, ShadowDir;

	if ( FRand() > 0.75 )
		Texture = BloodSplat[0];
	else
		Texture = BloodSplat[1];

  // SCheck
	DrawScale = Scale * FRand();
	default.DrawScale = DrawScale;

	ShadowDir = vect(0.1, 0.1, -0.1);

	ShadowStart = Owner.Location + Owner.CollisionRadius * ShadowDir;
	HitActor = Trace(HitLocation, HitNormal, ShadowStart - vect(0,0,300), ShadowStart, false);

	if ( HitActor == None )
	{
		//log("SpawnBloodSplat - HitActor == None - O: "$Owner);
		destroy();
		return;
	}

	//log("SpawnBloodSplat - "$Scale$" - "$Owner);
	SetLocation(HitLocation);
	SetRotation(rotator(HitNormal));
	bDecalAttached = true;
	AttachDecal(10, ShadowDir);
	SetTimer(30.0, false);
}


///////////////////////////////////////
// Timer
///////////////////////////////////////

simulated function	Timer()
{
//	if (bDecalAttached)
//		DetachDecal();
//		bDecalAttached = false;
	destroy();
}


event Update(Actor L)
{
}

///////////////////////////////////////
// defaultproperties 
///////////////////////////////////////

defaultproperties
{
     BloodSplat(0)=Texture'Botpack.BloodSplat5'
     BloodSplat(1)=Texture'Botpack.BloodSplat2'
     Texture=None
}
