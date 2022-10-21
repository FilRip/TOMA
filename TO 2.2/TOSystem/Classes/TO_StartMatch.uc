//=============================================================================
// TO_StartMatch
//=============================================================================
//
// Tactical Ops
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen
//=============================================================================

class TO_StartMatch expands UMenuStartMatchScrollClient;


///////////////////////////////////////
// Created
///////////////////////////////////////

function Created()
{
	ClientClass = class'TO_StartMatchCW';
	FixedAreaClass = None;
	Super(UWindowScrollingDialogClient).Created();
}


///////////////////////////////////////
// defaultproperties
///////////////////////////////////////

defaultproperties
{
}
