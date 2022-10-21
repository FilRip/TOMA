class TO_GUIBaseButton extends UWindow.UWindowDialogControl;

var TO_GUIBaseTab OwnerTab;
var TO_GUIBaseMgr OwnerInterface;
var s_HUD OwnerHUD;
var PlayerPawn OwnerPlayer;
var bool bMouseover;
var bool bMouseDown;
var float ButtonCenter;
var float ButtonSpacing;
var Font ButtonFont;
var bool PlaySound;

native(552) static final operator(16) Color * (Color A, float B)
{
}

simulated function Created ()
{
}

simulated function Close (optional bool bByParent)
{
}

simulated function Paint (Canvas Canvas, float X, float Y)
{
}

function MouseMove (float X, float Y)
{
}

function MouseLeave ()
{
}

function LMouseDown (float X, float Y)
{
}

function LMouseUp (float X, float Y)
{
}

simulated function SetWidth (Canvas Canvas, int Width)
{
}

simulated function bool TOUIButton_CheckMousepos (float X, float Y)
{
}


defaultproperties
{
}

