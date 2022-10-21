//=============================================================================
// TO_MenuButton
//=============================================================================
//
// Tactical Ops -- an Unreal Tournament modification
// -- http://www.planetunreal.com/tacticalops
//
// Source code rights:
// Copyright (C) 2000/2001 j3rky
//=============================================================================

class TO_MenuButton expands UWindowButton;

var float DisplayPosX;
var float DisplayPosY;

function Hide ()
{
	WinLeft = -4096;
	WinTop = -4096.00;
}

function Show ()
{
	WinLeft = DisplayPosX;
	WinTop = DisplayPosY;
}

defaultproperties
{
}
