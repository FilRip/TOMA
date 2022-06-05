class TO_GUIBaseButton extends UWindowDialogControl;

var TO_GUIBaseMgr OwnerInterface;
var PlayerPawn OwnerPlayer;
var s_HUD OwnerHUD;
var TO_GUIBaseTab OwnerTab;
var Font ButtonFont;
var float ButtonSpacing;
var float ButtonCenter;
var bool bMouseDown;
var bool bMouseover;
var bool PlaySound;

native(552) static final operator(16) Color * (Color A, float B);

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
