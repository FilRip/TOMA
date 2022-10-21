//=============================================================================
// TO_SmokeGenerator
//=============================================================================
//
// Tactical Ops
// - http://www.planetunreal.com/tacticalops
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen
//=============================================================================

class TO_SmokeGenerator extends	Actor;


var	float SmokeRate;
var float	Life;


///////////////////////////////////////
// PostBeginPlay
///////////////////////////////////////

function	PostBeginPlay()
{
	log("TO_SmokeGenerator::PostBeginPlay");
	if ( Level.NetMode != NM_DedicatedServer )
		SetTimer(SmokeRate, false);
}


///////////////////////////////////////
// Timer
///////////////////////////////////////

function Timer()
{
	local TO_SmokeLarge b;

	log("TO_SmokeGenerator::Timer");

	if ( Owner == None )
		log("TO_SmokeGenerator::Timer - Owner==None");

	b = Spawn(class'TO_SmokeLarge',,, Owner.Location);
	b.RemoteRole = ROLE_None;		

	SetTimer(SmokeRate, false);
}

/*
///////////////////////////////////////
// Tick
///////////////////////////////////////

function Tick( float DeltaTime )
{
	Life += DeltaTime;
}
*/

///////////////////////////////////////
// defaultproperties 
///////////////////////////////////////

defaultproperties
{
     SmokeRate=1.000000
     bHidden=True
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=30.000000
     AmbientSound=Sound'TODatas.Weapons.SmokeGrenSound'
     DrawType=DT_None
     Texture=None
     SoundRadius=64
}
