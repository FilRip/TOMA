//=============================================================================
// s_Concussion
//=============================================================================
//
// Tactical Ops 
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen and Benoit "JAH" Delayen
//=============================================================================

class s_Concussion extends s_GrenadeAway;


///////////////////////////////////////
// BeginPlay
///////////////////////////////////////

simulated function BeginPlay()
{
	local	Texture	GrenadeSkin;

	GrenadeSkin = Texture(DynamicLoadObject("TOModels.gren_conc", class'Texture'));
	MultiSkins[1] = GrenadeSkin;	

	Super.BeginPlay();
}


///////////////////////////////////////
// Explosion
///////////////////////////////////////

simulated function Explosion(vector HitLocation)
{
	local int i;
	local s_ConcussionChunk C;
	local	TO_GrenadeExplosion	expl;

	bHidden = true;
	for (i=0; i < 10; i++)
	{
		C = Spawn(class's_ConcussionChunk',,,Location,);
		C.DrawScale *= 0.5;
		//C.RemoteRole = ROLE_None;
	}

	expl = spawn(class'TO_ExplConc',,,HitLocation);
//	expl.Scale = 0.5;
//	expl.RemoteRole = ROLE_None;

	Destroy();
}

defaultproperties
{
}
