class TO_GUIBaseTab extends UWindowDialogClientWindow;

var TO_GUIBaseMgr OwnerInterface;
var S_Player OwnerPlayer;
var PlayerPawn OwnerPlayerPawn;
var s_HUD OwnerHUD;
var byte Resolution;
var string Title;
var string Hint;
var string AltHint;
var float SpaceTitle[5];
var float Padding[5];
var float Top;
var float Left;
var float Width;
var float Height;
var float Center;
var bool bInitialized;
var bool bDraw;
var bool Scroll;
var bool ShowNav;

native(549) static final operator(20) Color - (Color A, Color B);

native(550) static final operator(16) Color * (float A, Color B);

native(551) static final operator(20) Color + (Color A, Color B);

native(552) static final operator(16) Color * (Color A, float B);

simulated function Created ()
{
}

simulated function Close (optional bool bByParent)
{
}

simulated function ResolutionChanged (float W, float H)
{
}

simulated function BeforePaint (Canvas Canvas, float X, float Y)
{
}

simulated function Paint (Canvas Canvas, float X, float Y)
{
}

simulated function EscClose ()
{
}

simulated function OwnerTick (float Delta)
{
}

simulated function OwnerTimer ()
{
}

simulated function OwnerToggleMode ()
{
}

simulated function BeforeShow ()
{
}

simulated function BeforeHide ()
{
}

simulated function TOUITab_Init (Canvas Canvas)
{
}
