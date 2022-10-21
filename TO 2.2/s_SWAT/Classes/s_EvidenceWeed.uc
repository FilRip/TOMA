//=============================================================================
// s_EvidenceWeed
//=============================================================================
//
// Tactical Ops -- an Unreal Tournament modification
// -- http://www.planetunreal.com/tacticalops
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen and Benoit "JAH" Delayen
//=============================================================================

class s_EvidenceWeed extends s_Evidence;
 
 
///////////////////////////////////////
// defaultproperties 
///////////////////////////////////////

defaultproperties
{
     PickupMessage="You found evidence: Marijuana!"
     PickupViewMesh=LodMesh'TOModels.ev_weed'
     Mesh=LodMesh'TOModels.ev_weed'
     DrawScale=0.750000
     CollisionRadius=15.000000
     CollisionHeight=12.000000
}
