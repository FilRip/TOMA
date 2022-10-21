//=============================================================================
// TO_PreferencesWindow
//=============================================================================
//
// Tactical Ops
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen
//=============================================================================


class TO_PreferencesWindow extends UMenuFramedWindow;


///////////////////////////////////////
// Created
///////////////////////////////////////

function Created() 
{
	bStatusBar = False;
	bSizable = True;

	Super.Created();

	MinWinWidth = 200;
	MinWinHeight = 100;

	SetSizePos();
}


///////////////////////////////////////
// SetSizePos
///////////////////////////////////////

function SetSizePos()
{
	local float W, H;

	GetDesiredDimensions(W, H);

	if(Root.WinHeight < 400)
		SetSize(290, Min(Root.WinHeight - 32, H + (LookAndFeel.FrameT.H + LookAndFeel.FrameB.H)));
	else
		SetSize(290, Min(Root.WinHeight - 50, H + (LookAndFeel.FrameT.H + LookAndFeel.FrameB.H)));

	WinLeft = Root.WinWidth/2 - WinWidth/2;
	WinTop = Root.WinHeight/2 - WinHeight/2;
}


///////////////////////////////////////
// ResolutionChanged
///////////////////////////////////////

function ResolutionChanged(float W, float H)
{
	SetSizePos();
	Super.ResolutionChanged(W, H);
}


///////////////////////////////////////
// Resized
///////////////////////////////////////

function Resized()
{
	if(WinWidth != 290)
		WinWidth = 290;

	Super.Resized();
}


///////////////////////////////////////
// defaultproperties
///////////////////////////////////////

defaultproperties
{
     ClientClass=Class'TOSystem.TO_PreferencesClientWindow'
     WindowTitle="Preferences"
}
