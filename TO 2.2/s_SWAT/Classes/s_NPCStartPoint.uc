//=============================================================================
// s_NPCStartPoint
//=============================================================================
//
// Tactical Ops
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen and Benoit "JAH" Delayen
//=============================================================================

class s_NPCStartPoint extends NavigationPoint;

var(SWAT_NPC)	bool	bHostage;
var(SWAT_NPC)	bool	bIsFree;
  
 
///////////////////////////////////////
// defaultproperties 
///////////////////////////////////////

defaultproperties
{
     bHostage=True
     bIsFree=True
     bDirectional=True
     Texture=Texture'TODatas.Engine.SWATNPC'
}
