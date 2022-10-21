class TO_GUIBaseTab extends UWindow.UWindowDialogClientWindow;

var TO_GUIBaseMgr OwnerInterface;
var byte Resolution;
var float Left;
var S_Player OwnerPlayer;
var s_HUD OwnerHUD;
var float Padding;
var float Width;
var float Top;
var PlayerPawn OwnerPlayerPawn;
var float Height;
var float SpaceTitle;
var bool bDraw;
var float Center;
var bool bInitialized;
var bool ShowNav;
var bool Scroll;

simulated function BeforePaint (Canvas Canvas, float X, float Y)
{
}

simulated function Created ()
{
}

simulated function Paint (Canvas Canvas, float X, float Y)
{
}

simulated function Close (optional bool bByParent)
{
}

simulated function BeforeShow ()
{
}

simulated function OwnerTick (float Delta)
{
}

simulated function BeforeHide ()
{
}

simulated function OwnerToggleMode ()
{
}

simulated function OwnerTimer ()
{
}

native(549) static final operator(20) Color - (Color A, Color B)
{
}

native(550) static final operator(16) Color * (float A, Color B)
{
}

native(551) static final operator(20) Color + (Color A, Color B)
{
}

native(552) static final operator(16) Color * (Color A, float B)
{
}

function ResolutionChanged (float W, float H)
{
}

simulated function EscClose ()
{
}

function TOUITab_Init (Canvas Canvas)
{
}


defaultproperties
{
}

