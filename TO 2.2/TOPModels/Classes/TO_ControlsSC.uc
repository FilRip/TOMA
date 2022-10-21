//=============================================================================
// TO_ControlsSC
//=============================================================================
//
// Tactical Ops
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen
//=============================================================================

class TO_ControlsSC extends UWindowScrollingDialogClient;


///////////////////////////////////////
// Created
///////////////////////////////////////

function Created()
{
	ClientClass = class'TO_ControlsClientWindow';
	FixedAreaClass = None;
	Super.Created();
}


///////////////////////////////////////
// defaultproperties
///////////////////////////////////////

defaultproperties
{
}
