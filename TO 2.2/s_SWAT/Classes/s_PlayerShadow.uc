//=============================================================================
// s_PlayerShadow
//=============================================================================
//
// Tactical Ops
// - http://www.planetunreal.com/tacticalops
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen
//=============================================================================

class s_PlayerShadow expands PlayerShadow;

var	Texture	WalkTexture;


///////////////////////////////////////
// ForceUpdate
///////////////////////////////////////

final simulated function ForceUpdate()
{
	local Actor HitActor;
	local Vector HitNormal, HitLocation, ShadowStart, ShadowDir;
/*
	if (Owner == None)
	{
		log("s_PlayerShadow - ForceUpdate - Owner == None");
		//Destroy();
		return;
	}
*/
	ShadowDir = vect(0.1, 0.1, -0.1);

	ShadowStart = Owner.Location + Owner.CollisionRadius * ShadowDir;
	HitActor = Trace(HitLocation, HitNormal, ShadowStart - vect(0,0,300), ShadowStart, false);

	if ( HitActor == None )
		return;

	SetLocation(HitLocation);
	SetRotation(rotator(HitNormal));
	WalkTexture = AttachDecal(10, ShadowDir);
	DetachDecal();
}


///////////////////////////////////////
// Update
///////////////////////////////////////

event Update(Actor L)
{
	/*
	local Actor HitActor;
	local Vector HitNormal,HitLocation, ShadowStart, ShadowDir;

	SetTimer(0.08, false);
	if ( OldOwnerLocation == Owner.Location )
		return;

	OldOwnerLocation = Owner.Location;

	DetachDecal();

	if ( Owner.Style == STY_Translucent )
		return;

	if ( L == None )
		ShadowDir = vect(0.1,0.1,0);
	else
	{
		ShadowDir = Normal(Owner.Location - L.Location);

		if ( ShadowDir.Z > 0 )
			ShadowDir.Z *= -1;
	}
 

	ShadowStart = Owner.Location + Owner.CollisionRadius * ShadowDir;
	HitActor = Trace(HitLocation, HitNormal, ShadowStart - vect(0,0,300), ShadowStart, false);

	if ( HitActor == None )
		return;

	SetLocation(HitLocation);
	SetRotation(rotator(HitNormal));
	AttachDecal(10, ShadowDir);
	*/
}

defaultproperties
{
}
