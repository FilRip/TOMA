//=============================================================================
// TO_IntroHUD
//=============================================================================
//
// Tactical Ops
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen
//=============================================================================

class TO_IntroHUD extends CHNullHud;


#exec TEXTURE IMPORT NAME=TOLogo1 FILE=..\TODatas\Textures\GUI\Index1.pcx GROUP="Icons" MIPS=OFF FLAGS=2 
#exec TEXTURE IMPORT NAME=TOLogo2 FILE=..\TODatas\Textures\GUI\Index2.pcx GROUP="Icons" MIPS=OFF FLAGS=2 
#exec TEXTURE IMPORT NAME=TOLogo3 FILE=..\TODatas\Textures\GUI\Index3.pcx GROUP="Icons" MIPS=OFF FLAGS=2 


var	float		LogoFadeTime, OldScale;
var	float		Scale, Scale256, Scale128, XO, YO;


///////////////////////////////////////
// PostRender
///////////////////////////////////////

function PostRender( canvas Canvas )
{
	local	color	currentcolor;
	
	Scale = Canvas.ClipX / 1024;

	if (Scale != OldScale)
	{
		OldScale = Scale;
		Scale256 = 256 * Scale;
		Scale128 = 128 * Scale;
		XO = Canvas.ClipX / 2;
		YO = Canvas.ClipY / 2 - Scale128;
	}

//	Canvas.bNoSmooth = false;

	currentcolor = Canvas.DrawColor;
	Canvas.Style = ERenderStyle.STY_Translucent;
	Canvas.DrawColor = WhiteColor * LogoFadeTime;
	Canvas.SetPos(0, 0);

	Canvas.SetPos(XO - Scale128 - Scale256, YO);
	Canvas.DrawTile(Texture'TOLogo1', Scale256, Scale256, 0, 0, 256, 256);
	Canvas.SetPos(XO - Scale128, YO);
	Canvas.DrawTile(Texture'TOLogo2', Scale256, Scale256, 0, 0, 256, 256);
	Canvas.SetPos(XO + Scale128, YO);
	Canvas.DrawTile(Texture'TOLogo3', Scale256, Scale256, 0, 0, 256, 256);

	Canvas.DrawColor = currentcolor;
//	Canvas.bNoSmooth = true;

	Super.PostRender(Canvas);
}


///////////////////////////////////////
// Tick
///////////////////////////////////////

function Tick(float Delta)
{
	if (LogoFadeTime < 1.0)
	{
		LogoFadeTime += Delta / 4;
		if (LogoFadeTime > 1.0)
			LogoFadeTime = 1.0;
	}

	if (ESCFadeTime < 1.0 && Level.TimeSeconds > 3)
	{
		ESCFadeTime += Delta / 4;
		if (ESCFadeTime > 1.0)
			ESCFadeTime = 1.0;
	}
}

defaultproperties
{
}
