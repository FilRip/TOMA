//=============================================================================
// TO_PasswordWindow
//=============================================================================
//
// Tactical Ops
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen
//=============================================================================

class TO_PasswordWindow expands UTPasswordWindow;


///////////////////////////////////////
// Created
///////////////////////////////////////

function Created()
{
	Super(UWindowFramedWindow).Created();

	OKButton = UWindowSmallButton(CreateWindow(class'UWindowSmallButton', WinWidth-108, WinHeight-24, 48, 16));
	CloseButton = UWindowSmallCloseButton(CreateWindow(class'UWindowSmallCloseButton', WinWidth-56, WinHeight-24, 48, 16));
	OKButton.Register(TO_PasswordCW(ClientArea));
	OKButton.SetText(OKText);
	SetSizePos();
	bLeaveOnScreen = true;
}


///////////////////////////////////////
// defaultproperties
///////////////////////////////////////

defaultproperties
{
     ClientClass=Class'TOPModels.TO_PasswordCW'
}
