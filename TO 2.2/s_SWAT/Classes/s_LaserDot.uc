//=============================================================================
// s_LaserDot
//=============================================================================
//
// Tactical Ops
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen
//=============================================================================

class s_LaserDot extends Actor;

var		s_LaserDot		LaserDot;

/*
simulated singular function Touch(Actor Other) {}
simulated function HitWall (vector HitNormal, actor Wall) {}
simulated function Explode(vector HitLocation, vector HitNormal) {}
*/

///////////////////////////////////////
// Destroyed 
///////////////////////////////////////

simulated event Destroyed()
{
	bHidden = true;
	if ( LaserDot != None )
		LaserDot.Destroy();

	Super.Destroyed();
}


///////////////////////////////////////
// CheckLaser 
///////////////////////////////////////

final simulated function CheckLaser(vector HitLocation)
{
	SetLocation(HitLocation);	

	if ( (Role == ROLE_Authority) && (LaserDot == None) )
		LaserDot = Spawn(class's_LaserDot', Owner, , HitLocation); 

	// Updating server LaserDot
	if ( LaserDot != None )
	{
		LaserDot.SetLocation(HitLocation);
		LaserDot.DrawScale = DrawScale;
	}
}


///////////////////////////////////////
// defaultproperties 
///////////////////////////////////////
// RemoteRole=ROLE_DumbProxy
// NetUpdateFrequency=2.0

defaultproperties
{
     bOwnerNoSee=True
     bReplicateInstigator=True
     Style=STY_Translucent
     Texture=Texture'TODatas.Engine.LaserDot'
     DrawScale=0.100000
     bUnlit=True
     NetPriority=2.200000
}
