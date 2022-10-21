class TO_GUIBaseUpDown extends UWindow.UWindowDialogControl;

var int Value;
var float ButtonHeight;
var TO_GUIBaseTab OwnerTab;
var TO_GUIBaseMgr OwnerInterface;
var s_HUD OwnerHUD;
var int MaxValue;
var int MinValue;
var int Data;
var PlayerPawn OwnerPlayer;
var float ButtonSpacing;
var float ClientCenter;
enum ETOUpdownStyle {
	ST_HORIZONTAL,
	ST_VERTICAL
};
var ETOUpdownStyle Style;
var int IncValue;
var float ClientHeight;
var float ClientWidth;
var bool bMouseoverPlus;
var bool bMouseoverMinus;
var bool bMouseover;
var Font LabelFont;
var Font ButtonFont;
var bool PlaySound;
var int NumDigits;

native(552) static final operator(16) Color * (Color A, float B)
{
}

simulated function Created ()
{
}

simulated function Close (optional bool bByParent)
{
}

simulated function BeforePaint (Canvas Canvas, float X, float Y)
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

function Click (float X, float Y)
{
}

function RClick (float X, float Y)
{
}

function DoubleClick (float X, float Y)
{
}

simulated function SetWidth (Canvas Canvas, int Width)
{
}

simulated function TOUIUpdown_DrawButton (Canvas Canvas, string Caption, bool minus, bool mouseover)
{
}

simulated function TOUIUpdown_DrawValue (Canvas Canvas)
{
}

simulated function TOUIUpdown_DrawLabel (Canvas Canvas)
{
}

simulated function ETOUpdownButton TOUIListbox_GetButtonAt (float X, float Y)
{
}


defaultproperties
{
}

