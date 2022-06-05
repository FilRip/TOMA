class TO_GUIBaseUpDown extends UWindowDialogControl;

enum ETOUpdownButton
{
	BTN_NONE,
	BTN_PLUS,
	BTN_MINUS,
	BTN_NUMBER
};

enum ETOUpdownStyle
{
	ST_HORIZONTAL,
	ST_VERTICAL
};

var TO_GUIBaseMgr OwnerInterface;
var PlayerPawn OwnerPlayer;
var s_HUD OwnerHUD;
var TO_GUIBaseTab OwnerTab;
var ETOUpdownStyle Style;
var string Label;
var int Data;
var int Value;
var int MinValue;
var int MaxValue;
var int IncValue;
var int NumDigits;
var float ButtonHeight;
var float ButtonSpacing;
var float ClientHeight;
var float ClientWidth;
var float ClientCenter;
var Font ButtonFont;
var Font LabelFont;
var bool bMouseover;
var bool bMouseoverPlus;
var bool bMouseoverMinus;
var bool PlaySound;

native(552) static final operator(16) Color * (Color A, float B);

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
