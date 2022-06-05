class TO_GUIBaseMgr extends Actor;

const UIT_NONE=255;
const UIT_DEBRIEFING=9;
const UIT_CREDITS=8;
const UIT_MAIN=7;
const UIT_BRIEFING=6;
const UIT_CHAT=5;
const UIT_BUYMENU=4;
const UIT_SKINSEL=3;
const UIT_TEAMSEL=2;
const UIT_SERVER=1;
const UIT_SCORES=10;

var s_HUD OwnerHUD;
var TO_DesignInfo Design;
var UWindowRootWindow Root;
var TO_GUIBaseTab Tabs[255];
var byte CurrentTab;
var bool bAltHint;
var byte AltHintTime;

simulated function Destroyed ()
{
}

simulated function BeforeDestroy ()
{
}

simulated function Tick (float DeltaTime)
{
}

simulated function OwnerInit (s_HUD HUD, TO_DesignInfo di)
{
}

simulated function OwnerTimer ()
{
}

simulated function OwnerToggleMode ()
{
}

simulated function OwnerScrollScores ()
{
}

simulated function ResolutionChanged (float W, float H)
{
}

simulated function Render (Canvas Canvas)
{
}

simulated function SelectTab (byte Tab)
{
}

simulated function HideTab (byte Tab)
{
}

simulated function Hide ()
{
}

simulated function ToggleTab (byte Tab)
{
}

simulated function bool Visible ()
{
}

simulated function bool IsVisible (byte Tab)
{
}

simulated function TO_GUIBaseTab GetCurrentTab ()
{
}

simulated function Tool_DrawClippedText (Canvas Canvas, string Text, float X, float Y, float W)
{
}

simulated function Tool_DrawBox (Canvas Canvas, float X, float Y, float W, float H)
{
}

simulated function TOUI_Tool_AddTab (byte Tab, Class<TO_GUIBaseTab> tabclass)
{
}
