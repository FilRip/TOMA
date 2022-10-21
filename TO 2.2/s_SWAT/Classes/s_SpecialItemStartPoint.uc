//=============================================================================
// s_SpecialItemStartPoint
//=============================================================================
//
// Tactical Ops
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen and Benoit "JAH" Delayen
//=============================================================================

class s_SpecialItemStartPoint extends NavigationPoint;

var(s_SpecialItemStartPoint)	bool	bIsCocaine;
var(s_SpecialItemStartPoint)	bool	bIsOICW;
var(s_SpecialItemStartPoint)	float	Weight;
   

///////////////////////////////////////
// defaultproperties 
///////////////////////////////////////
//Texture=Texture'SWATNPC'

defaultproperties
{
     bIsCocaine=True
     Weight=10.000000
}
