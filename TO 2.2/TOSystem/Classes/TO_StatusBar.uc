//=============================================================================
// TO_StatusBar
//=============================================================================
//
// Tactical Ops
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen
//=============================================================================

class TO_StatusBar extends UMenuStatusBar;


///////////////////////////////////////
// Paint
///////////////////////////////////////

function Paint(Canvas C, float X, float Y)
{
	local GameInfo G;
	local bool bIntro;

	G = GetLevel().Game;
	bIntro = G != None && G.IsA('TO_Intro');

	C.DrawColor.R = 255;
	C.DrawColor.G = 255;
	C.DrawColor.B = 255;

	DrawUpBevel( C, 0, 0, WinWidth, WinHeight, LookAndFeel.Active);

	C.Font = Root.Fonts[F_Normal];
	C.DrawColor.R = 0;
	C.DrawColor.G = 0;
	C.DrawColor.B = 0;

	if(ContextHelp != "")
		ClipText(C, 2, 2, ContextHelp);
	else if(bIntro)
			ClipText(C, 2, 2, DefaultIntroHelp);
	else
			ClipText(C, 2, 2, DefaultHelp);
}


///////////////////////////////////////
// defaultproperties
///////////////////////////////////////

defaultproperties
{
     DefaultIntroHelp="Use the menu to join or start a new game."
}
