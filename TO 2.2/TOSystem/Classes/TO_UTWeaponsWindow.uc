//=============================================================================
// TO_UTWeaponsWindow
//=============================================================================
//
// Tactical Ops
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen
//=============================================================================
 
class TO_UTWeaponsWindow extends UWindowScrollingDialogClient;


///////////////////////////////////////
// Created
///////////////////////////////////////

function Created()
{
	ClientClass = Class'TOSystem.TO_UTWeaponsClientWindow';
	Super.Created();
}


///////////////////////////////////////
// Created
///////////////////////////////////////

defaultproperties
{
}
