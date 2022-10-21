//----------------------------------------------------------------------------
// Project : TOST
// File    : TOSTGUILabel.uc
// Version : 4.0
// Author  : MadOnion/BugBunny (based on code by J3rky)
//----------------------------------------------------------------------------
// Version	Changes
// 4.0		+ First Release
//----------------------------------------------------------------------------

class TOSTGUILabel extends UWindowDialogControl;

// -properties-

var TO_GUIBaseMgr	OwnerInterface;
var PlayerPawn		OwnerPlayer;
var s_Hud			OwnerHud;
var TO_GUIBaseTab	OwnerTab;

var Font			LabelFont;
var float			LabelSpacing, LabelCenter;

var bool			bBackground;
var byte			Alignment;

simulated function Created()
{
	TextX = 0;
	TextY = 0;

	bBackground		= true;
	Alignment		= 1;		// 0 = left, 1 = center, 2 = right

    OwnerPlayer 	= GetPlayerOwner();
	OwnerHud 		= s_Hud(OwnerPlayer.myHud);
	OwnerInterface 	= OwnerHud.UserInterface;
}

simulated function Close (optional bool bByParent)
{
	OwnerPlayer = None;
	OwnerHud = None;
	OwnerInterface = None;

	Super.Close(bByParent);
}

simulated function Paint (Canvas Canvas, float x, float y)
{
	local float		xl, yl;
	local texture	bg;

	if (bBackground)
	{
		// box
		OwnerInterface.Tool_DrawBox(Canvas, 2, 2, WinWidth-4, WinHeight-4);

		// background
		Canvas.Style = OwnerHud.ERenderStyle.STY_NORMAL;
	    Canvas.DrawColor = OwnerInterface.Design.ColorWhite;
		bg = texture'debug16';

		Canvas.SetPos(2, 2);
		Canvas.DrawTile(bg, WinWidth-4, WinHeight-4, 0, 0, 16, 16);
	}

	// caption
	Canvas.Font = LabelFont;
	Canvas.StrLen(Text, xl, yl);
	Canvas.DrawColor = OwnerInterface.Design.ColorWhite;

	switch (Alignment)
	{
		case 0 :    Canvas.SetPos(4, LabelSpacing);
					break;
		case 1 : 	Canvas.SetPos(LabelCenter-0.5*xl, LabelSpacing);
					break;
		case 2 : 	Canvas.SetPos(WinWidth - 4 - xl, LabelSpacing);
					break;
	}
	Canvas.DrawText(Text, true);
}

simulated function SetWidth (Canvas Canvas, int width)
{
	local	float	cx, cy;

	OwnerHUD.Design.SetHeadlineFont(Canvas);

	WinWidth = width;
	WinHeight = OwnerHud.Design.LineHeight + 3;

	LabelFont = Canvas.Font;
	Canvas.TextSize("Test", cx, cy);
	LabelSpacing = (WinHeight - cy) / 2;
	LabelCenter = 0.5*WinWidth;
}

defaultproperties
{
}
