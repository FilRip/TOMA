//=============================================================================
// s_PlayerHead
//=============================================================================
//
// Tactical Ops -- an Unreal Tournament modification
// -- http://www.planetunreal.com/tacticalops
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen and Benoit "JAH" Delayen
//=============================================================================

class s_PlayerHead extends UTHeads;

 
///////////////////////////////////////
// Dying
///////////////////////////////////////

auto State Dying
{
	simulated function Tick(float DeltaTime)
	{
		Disable('Tick');
	}
}


///////////////////////////////////////
// defaultproperties
///////////////////////////////////////

defaultproperties
{
     Mesh=LodMesh'Botpack.headmalem'
}
