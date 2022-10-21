//=============================================================================
// s_raindropSprite
//=============================================================================
//
// Tactical Ops
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000 Greg '[DM]Matryx' Sweetman
// Continued by Laurent "SHAG" Delayen
//=============================================================================

class s_raindropSprite expands s_raindrop;
 

///////////////////////////////////////
// PostBeginPlay 
///////////////////////////////////////

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	
	if (FRand() < 0.3)
		Texture = Texture'RaindropFAT';
	else
		Texture = Texture'RaindropTHIN';
} 


///////////////////////////////////////
// defaultproperties 
///////////////////////////////////////

defaultproperties
{
     DrawType=DT_Sprite
     Style=STY_Translucent
     Mesh=None
}
