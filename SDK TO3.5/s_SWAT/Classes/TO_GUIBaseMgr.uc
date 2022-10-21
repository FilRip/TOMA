class TO_GUIBaseMgr extends Engine.Actor;

var TO_DesignInfo Design;
var TO_GUIBaseTab Tabs;
var byte CurrentTab;
var UWindowRootWindow Root;
var s_HUD OwnerHUD;
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

function TOUI_Tool_AddTab (byte Tab, Class<TO_GUIBaseTab> tabclass)
{
}


defaultproperties
{
}

