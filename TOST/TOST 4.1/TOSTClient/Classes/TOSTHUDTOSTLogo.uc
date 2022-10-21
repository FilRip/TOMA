//----------------------------------------------------------------------------
// Project : TOST
// File    : TOSTHUDTOSTLogo.uc
// Version : 1.0
// Author  : BugBunny
//----------------------------------------------------------------------------
// Version	Changes
// 0.5		+ first release
// 0.6		+ first beta release
// 1.0		+ first public release
//----------------------------------------------------------------------------

class TOSTHUDTOSTLogo expands TOSTHUDMutator config (TOSTUser);

#exec TEXTURE IMPORT NAME=TOST4Logo FILE=Textures\TOSTLogoSmall.PCX MIPS=OFF FLAGS=2

var	bool		bInitialized;

var string		VersionStr;
var string		TOPVersionStr;

var string		CustomLogoTexture;
var string		ServerText[4];

var float		FadeTimer;

var Texture		CustomLogo;

var int			LogoHeight;

var config	float	FadeIn;
var config	float	FadeOut;
var config	float	TotalTime;

simulated function	Init()
{
	super.Init();
	if (TotalTime < 2)
		TotalTime = 2;
	if (FadeIn < 0.5)
		FadeIn = 0.5;
	if (FadeIn > (TotalTime - 1) / 2)
		FadeIn = (TotalTime - 1) / 2;
	if (FadeOut < 0.5)
		FadeOut = 0.5;
	if (FadeOut > (TotalTime - 1) / 2)
		FadeOut = (TotalTime - 1) / 2;
	SaveConfig();
}

simulated function	PostRender(Canvas C)
{
	super.PostRender(C);

	if (bInitialized)
		DrawLogo(C);
}

simulated function Tick(float Delta)
{
	if (CustomLogoTexture != "" && CustomLogo == None)
	{
		CustomLogo = Texture(DynamicLoadObject(CustomLogoTexture, class'Texture', true));
	}

	if (!bInitialized)
		return;

	if (FadeTimer < TotalTime)
		FadeTimer += Delta;
	else
		Destroy();
}

simulated function	DrawLogo(Canvas C)
{
	local	float	FadeValue;
	local	int		i;

	if (FadeTimer > 0)
	{

		if (FadeTimer <= FadeIn) {
			FadeValue = FadeTimer / FadeIn;
			C.Style = ERenderStyle.STY_Translucent;
		} else {
			if (FadeTimer > TotalTime - FadeOut)
			{
				if (FadeTimer >= TotalTime)
					FadeValue = 0;
				else
					FadeValue = (TotalTime-FadeTimer) / FadeOut;
				C.Style = ERenderStyle.STY_Translucent;
			} else {
				FadeValue = 1;
				C.Style = ERenderStyle.STY_Masked;
			}
		}

		// logocolor
		C.DrawColor.R = 240 * FadeValue;
		C.DrawColor.G = 240 * FadeValue;
		C.DrawColor.B = 240 * FadeValue;

		if (TOPVersionStr != "")
			i = 0;
		else
			i = 4;

		C.SetPos(C.ClipX * 0.11, (C.ClipY * 0.79) - 76 - i);
		C.DrawIcon(texture'TOST4Logo', 1.0);

        if (CustomLogo != none)
        {
			C.SetPos(12.00,C.ClipY*0.2);
	        C.DrawIcon(CustomLogo, 1.00);
	    }

	    i*=2;

		C.DrawColor = MyHUD.WhiteColor * FadeValue;

		C.Font = MyHUD.MyFonts.GetSmallestFont(C.ClipX);
		C.SetPos(C.ClipX * 0.11 + 140, (C.ClipY * 0.79) - 80 + i);
		C.DrawText("this server is taking advantage of");

		C.Font = MyHUD.MyFonts.GetMediumFont(C.ClipX);
		C.SetPos(C.ClipX * 0.11 + 140, (C.ClipY * 0.79) - 64 + i);
		C.DrawText(VersionStr);

		C.Font = MyHUD.MyFonts.GetSmallestFont(C.ClipX);
		C.SetPos(C.ClipX * 0.11 + 140, (C.ClipY * 0.79) - 40 + i);
		C.DrawText("http://tost.tactical-ops.to");

		if (TOPVersionStr != "")
		{
			C.Font = MyHUD.MyFonts.GetSmallestFont(C.ClipX);
			C.SetPos(C.ClipX * 0.11 + 140, (C.ClipY * 0.79) - 22);
			C.DrawText(TOPVersionStr);
		}

		C.Font = MyHUD.MyFonts.GetSmallFont(C.ClipX);
		for (i=0; i<4; i++)
		{
			if (LogoHeight > 0)
				C.SetPos(12, C.ClipY*0.2 + LogoHeight + 4 + i*16);
			else
				C.SetPos(12, C.ClipY*0.2 + 132 + i*16);
			C.DrawText(ServerText[i]);
		}
	}
}

defaultproperties
{
	bInitialized=false

	FadeIn=1.500000
	FadeOut=1.500000
	TotalTime=6.000000

	CommClass=class'TOSTHUDLogoComm'
}
