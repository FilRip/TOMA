//=============================================================================
// TO_RootWindow
//=============================================================================
//
// Tactical Ops
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen
//=============================================================================

//class TO_RootWindow extends UWindowRootWindow;
class TO_RootWindow extends UMenuRootWindow;

#exec TEXTURE IMPORT NAME=TOBg11	FILE=Textures\Background\TOBg11-0.bmp GROUP="StartMenu"	MIPS=OFF
#exec TEXTURE IMPORT NAME=TOBg12	FILE=Textures\Background\TOBg12-0.bmp GROUP="StartMenu"	MIPS=OFF
#exec TEXTURE IMPORT NAME=TOBg13	FILE=Textures\Background\TOBg13-0.bmp GROUP="StartMenu"	MIPS=OFF
#exec TEXTURE IMPORT NAME=TOBg21	FILE=Textures\Background\TOBg21-0.bmp GROUP="StartMenu"	MIPS=OFF
#exec TEXTURE IMPORT NAME=TOBg22	FILE=Textures\Background\TOBg22-0.bmp GROUP="StartMenu"	MIPS=OFF
#exec TEXTURE IMPORT NAME=TOBg23	FILE=Textures\Background\TOBg23-0.bmp GROUP="StartMenu"	MIPS=OFF
#exec TEXTURE IMPORT NAME=TOBg31	FILE=Textures\Background\TOBg31-0.bmp GROUP="StartMenu"	MIPS=OFF  
#exec TEXTURE IMPORT NAME=TOBg32	FILE=Textures\Background\TOBg32-0.bmp GROUP="StartMenu"	MIPS=OFF
#exec TEXTURE IMPORT NAME=TOBg33	FILE=Textures\Background\TOBg33-0.bmp GROUP="StartMenu"	MIPS=OFF
#exec TEXTURE IMPORT NAME=TOBg41	FILE=Textures\Background\TOBg41-0.bmp GROUP="StartMenu"	MIPS=OFF             
#exec TEXTURE IMPORT NAME=TOBg42	FILE=Textures\Background\TOBg42-0.bmp GROUP="StartMenu"	MIPS=OFF    
#exec TEXTURE IMPORT NAME=TOBg43	FILE=Textures\Background\TOBg43-0.bmp GROUP="StartMenu"	MIPS=OFF

var	TO_MenuBar			MenuBar;
//var	TO_StatusBar		StatusBar;
var Font						BetaFont;


///////////////////////////////////////
// Created
///////////////////////////////////////

function Created() 
{
	Super(UWindowRootWindow).Created();

	//StatusBar = TO_StatusBar(CreateWindow(class'TO_StatusBar', 0, 0, 50, 16));
	StatusBar = UMenuStatusBar(CreateWindow(class'TO_StatusBar', 0, 0, 50, 16));
	StatusBar.HideWindow();

	MenuBar = TO_MenuBar(CreateWindow(class'TO_MenuBar', 50, 0, 500, 16));

	BetaFont = Font(DynamicLoadObject("UWindowFonts.UTFont40", class'Font'));
	Resized();
}


///////////////////////////////////////
// Paint
///////////////////////////////////////

function Paint(Canvas C, float MouseX, float MouseY)
{
	local int XOffset, YOffset;
	local float W, H;

	if ( Console.bNoDrawWorld )
	{
		DrawStretchedTexture(C, 0, 0, WinWidth, WinHeight, Texture'MenuBlack');

		if ( Console.bBlackOut )
			return;

		W = WinWidth / 4;
		H = W;

		if ( H > WinHeight / 3 )
		{
			H = WinHeight / 3;
			W = H;
		}

		XOffset = (WinWidth - (4 * (W-1))) / 2;
		YOffset = (WinHeight - (3 * (H-1))) / 2;

		//C.bNoSmooth = false;

		DrawStretchedTexture(C, XOffset + (3 * (W-1)), YOffset + (2 * (H-1)), W, H, Texture'TOBg43');
		DrawStretchedTexture(C, XOffset + (2 * (W-1)), YOffset + (2 * (H-1)), W, H, Texture'TOBg33');
		DrawStretchedTexture(C, XOffset + (1 * (W-1)), YOffset + (2 * (H-1)), W, H, Texture'TOBg23');
		DrawStretchedTexture(C, XOffset + (0 * (W-1)), YOffset + (2 * (H-1)), W, H, Texture'TOBg13');

		DrawStretchedTexture(C, XOffset + (3 * (W-1)), YOffset + (1 * (H-1)), W, H, Texture'TOBg42');
		DrawStretchedTexture(C, XOffset + (2 * (W-1)), YOffset + (1 * (H-1)), W, H, Texture'TOBg32');
		DrawStretchedTexture(C, XOffset + (1 * (W-1)), YOffset + (1 * (H-1)), W, H, Texture'TOBg22');
		DrawStretchedTexture(C, XOffset + (0 * (W-1)), YOffset + (1 * (H-1)), W, H, Texture'TOBg12');

		DrawStretchedTexture(C, XOffset + (3 * (W-1)), YOffset + (0 * (H-1)), W, H, Texture'TOBg41');
		DrawStretchedTexture(C, XOffset + (2 * (W-1)), YOffset + (0 * (H-1)), W, H, Texture'TOBg31');
		DrawStretchedTexture(C, XOffset + (1 * (W-1)), YOffset + (0 * (H-1)), W, H, Texture'TOBg21');
		DrawStretchedTexture(C, XOffset + (0 * (W-1)), YOffset + (0 * (H-1)), W, H, Texture'TOBg11');

		//C.bNoSmooth = true;
	}
}


///////////////////////////////////////
// Resized
///////////////////////////////////////

function Resized()
{
	Super(UWindowRootWindow).Resized();
	
	MenuBar.WinLeft = 0;;
	MenuBar.WinTop = 0;
	MenuBar.WinWidth = WinWidth;;
	MenuBar.WinHeight = 16;

	StatusBar.WinLeft = 0;
	StatusBar.WinTop = WinHeight - StatusBar.WinHeight;
	StatusBar.WinWidth = WinWidth;
}


///////////////////////////////////////
// DoQuitGame
///////////////////////////////////////

function DoQuitGame()
{
	MenuBar.SaveConfig();

	if ( GetLevel().Game != None )
	{
		GetLevel().Game.SaveConfig();
		GetLevel().Game.GameReplicationInfo.SaveConfig();
	}

	Super(UWindowRootWindow).DoQuitGame();
}


///////////////////////////////////////
// defaultproperties
///////////////////////////////////////

defaultproperties
{
}
