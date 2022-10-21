//----------------------------------------------------------------------------
// Project : TOST
// File    : TOSTGUICheckBox.uc
// Version : 4.0
// Author  : BugBunny (based on code by J3rky)
//----------------------------------------------------------------------------
// Version	Changes
// 4.0		+ First Release
//----------------------------------------------------------------------------

#exec TEXTURE IMPORT NAME=CheckBox	FILE=Textures\TOSTCheckBox.pcx	GROUP="GUI" MIPS=OFF FLAGS=2

class TOSTGUICheckBox expands UWindowDialogControl;

// -properties-

var TO_GUIBaseMgr	OwnerInterface;
var PlayerPawn		OwnerPlayer;
var s_Hud			OwnerHud;
var TO_GUIBaseTab	OwnerTab;

var font		ButtonFont;
var float		ButtonSpacing, ButtonCenter;

var bool		bMousedown, bMouseover;
var bool		PlaySound;

var bool		bChecked;

// -operators-

// color
native(552) static final operator(16) color *( color A, float B );

// -methods (engine)-

// * Created
simulated function Created ()
{
	OwnerPlayer = GetPlayerOwner();
	OwnerHud = s_Hud(OwnerPlayer.myHud);
	OwnerInterface = OwnerHud.UserInterface;

	Super.Created();
}

// * Close
simulated function Close (optional bool bByParent)
{
	OwnerPlayer = None;
	OwnerHud = None;
	OwnerInterface = None;

	Super.Close(bByParent);
}

// * Paint
simulated function Paint (Canvas Canvas, float x, float y)
{
	local float	xl, yl;

	// background
	if (bMousedown)
	{
		Canvas.DrawColor = OwnerInterface.Design.ColorYellow * 0.7;
	}
	else if (bMouseover)
	{
		Canvas.DrawColor = OwnerInterface.Design.ColorTeam[OwnerPlayer.PlayerReplicationInfo.Team] * 0.7;
	}
	else
	{
		Canvas.DrawColor = OwnerInterface.Design.ColorWhite;
	}

	Canvas.Style = OwnerHud.ERenderStyle.STY_Translucent;							// left
	Canvas.SetPos(1, 3);
	Canvas.DrawTile(Texture'checkbox', 48, 19, 1, 1, 48, 19);
	Canvas.Style = OwnerHud.ERenderStyle.STY_Masked;
	Canvas.SetPos(1, 3);
	if (bChecked)
		Canvas.DrawTile(Texture'checkbox', 48, 19, 51, 1, 48, 19);
	else
		Canvas.DrawTile(Texture'checkbox', 48, 19, 51, 21, 48, 19);

	// caption
	Canvas.Font = ButtonFont;
	Canvas.StrLen(Text, xl, yl);
	Canvas.DrawColor = OwnerInterface.Design.ColorWhite;
	Canvas.Style = OwnerHud.ERenderStyle.STY_Normal;
	Canvas.SetPos(48+10+ButtonSpacing, ButtonSpacing);
	Canvas.DrawText(Text, true);
}

// * MouseMove
function MouseMove (float x, float y)
{
	bMouseover = CheckMousepos(x, y);

	if (bMouseover && (OwnerTab != None) )
	{
		OwnerTab.Notify(self, DE_MouseMove);
	}
}

// * MouseLeave
function MouseLeave ()
{
	bMouseover = false;
	bMousedown = false;

	if (OwnerTab != None)
	{
		OwnerTab.Notify(self, DE_MouseLeave);
	}
}

// * LMouseDown
function LMouseDown (float x, float y)
{
	if (!CheckMousepos(x, y))
	{
		return;
	}

	bMousedown = true;

	if (OwnerTab != None)
	{
		OwnerTab.Notify(self, DE_LMouseDown);
	}
}

// * LMouseUp
function LMouseUp (float x, float y)
{
	if (!CheckMousepos(x, y))
	{
		return;
	}

	bMousedown = false;
	bChecked = !bChecked;
	if (OwnerTab != None)
	{
		OwnerTab.Notify(self, DE_Click);
	}

	if (PlaySound)
	{
		OwnerPlayer.PlaySound(Sound'LightSwitch', SLOT_None);
	}
}

// -methods (exported)-

// * SetWidth
simulated function SetWidth (Canvas Canvas, int width)
{
	OwnerHUD.Design.SetHeadlineFont(Canvas);

	WinWidth = width;
	WinHeight = OwnerHud.Design.LineHeight + 3;

	ButtonFont = Canvas.Font;
	ButtonSpacing = OwnerHud.Design.LineSpacing + 2;
	ButtonCenter = 0.5*WinWidth;
}

// -methods (input)-

simulated function bool CheckMousepos (float x, float y)
{
	if ( (x < 2) || (x > 50) || (y < 2) || (y > WinHeight-2) )
	{
		return false;
	}

	return true;
}

// -defaultproperties-

defaultproperties
{
	PlaySound=true
}
