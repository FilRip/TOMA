//----------------------------------------------------------------------------
// Project : TOST
// File    : TOSTGUIBaseButton.uc
// Version : 4.0
// Author  : BugBunny (based on code by J3rky)
//----------------------------------------------------------------------------
// Version	Changes
// 4.0		+ First Release
//----------------------------------------------------------------------------

class TOSTGUIBaseButton expands UWindowDialogControl;

// -properties-

var TO_GUIBaseMgr	OwnerInterface;
var PlayerPawn		OwnerPlayer;
var s_Hud			OwnerHud;
var TO_GUIBaseTab	OwnerTab;

var font			ButtonFont;
var float			ButtonSpacing, ButtonCenter;

var bool			bMousedown, bMouseover;
var bool			PlaySound;

// -operators-

// color
native(552) static final operator(16) color *     ( color A, float B );

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
	local texture	bg;

	// box
	OwnerInterface.Tool_DrawBox(Canvas, 2, 2, WinWidth-4, WinHeight-4);

	// background
	Canvas.Style = OwnerHud.ERenderStyle.STY_NORMAL;
	if (bMousedown)
	{
		Canvas.DrawColor = OwnerInterface.Design.ColorYellow * 0.7;
		bg = texture'tilewhite';
	}
	else if (bMouseover)
	{
		Canvas.DrawColor = OwnerInterface.Design.ColorTeam[OwnerPlayer.PlayerReplicationInfo.Team] * 0.7;
		bg = texture'tilewhite';
	}
	else
	{
		Canvas.DrawColor = OwnerInterface.Design.ColorWhite;
		bg = texture'debug16';
	}
	Canvas.SetPos(2, 2);
	Canvas.DrawTile(bg, WinWidth-4, WinHeight-4, 0, 0, 16, 16);

	// caption
	Canvas.Font = ButtonFont;
	Canvas.StrLen(Text, xl, yl);
	if (bMouseover)
	{
		Canvas.DrawColor = OwnerInterface.Design.ColorDarkgrey;
	}
	else
	{
		Canvas.DrawColor = OwnerInterface.Design.ColorWhite;
	}
	Canvas.SetPos(ButtonCenter-0.5*xl, ButtonSpacing);
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
	if (OwnerTab != None)
	{
		OwnerTab.Notify(self, DE_Click);
	}

	if (PlaySound)
	{
		OwnerPlayer.PlaySound(Sound'LightSwitch', SLOT_None);
	}
}


// * RMouseDown
function RMouseDown (float x, float y)
{
	if (!CheckMousepos(x, y))
	{
		return;
	}

	bMousedown = true;
}

// * RMouseUp
function RMouseUp (float x, float y)
{
	if (!CheckMousepos(x, y))
	{
		return;
	}

	bMousedown = false;
	if (OwnerTab != None)
	{
		OwnerTab.Notify(self, DE_RClick);
	}

	if (PlaySound)
	{
		OwnerPlayer.PlaySound(Sound'LightSwitch', SLOT_None);
	}
}

// -methods (exported)-

simulated function SetWidth (Canvas Canvas, int width)
{
	local	float	cx, cy;

	OwnerHUD.Design.SetHeadlineFont(Canvas);

	WinWidth = width;
	WinHeight = OwnerHud.Design.LineHeight + 3;

	ButtonFont = Canvas.Font;
	Canvas.TextSize("Test", cx, cy);
	ButtonSpacing = (WinHeight - cy) / 2;
	ButtonCenter = 0.5*WinWidth;
}

// -methods (input)-

simulated function bool CheckMousepos (float x, float y)
{
	if ( (x < 2) || (x > WinWidth-2) || (y < 2) || (y > WinHeight-2) )
	{
		return false;
	}

	return true;
}

defaultproperties
{
	PlaySound=true
}
