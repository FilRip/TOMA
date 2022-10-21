//------------------------------------------------------------------------------
// PROJECT : Tactical Ops ServerAdmin Tool
// FILE    : TOST_ToolsCommands.uc
// VERSION : 1.0
// INFO    : Handles sending Console Commands to the Client
// AUTHOR  : Xian
//------------------------------------------------------------------------------
// CHANGES :
// v1.0     + Initial version
//------------------------------------------------------------------------------

class TOST_ToolsCommands expands TOST_CommandList;

// =============================================================================
// Console Commands

exec simulated function xSay (coerce string Message)
{
   SendCommand(0,False,Message);
}

exec simulated function xTeamSay (coerce string Message)
{
   SendCommand(1,False,Message);
}

exec simulated function Echo (coerce string Message)
{
   SendCommand(2,False,Message);
}

exec simulated function ShowTeamInfo ()
{
   SendCommand(3,False);
}

exec simulated function ShowWeaponInfo ()
{
   SendCommand(4,False);
}

exec simulated function ShowNPC ()
{
   SendCommand(5,False);
}

exec simulated function xSet (coerce string Setting, int Value)
{
   SendCommand(6,False,Setting,,,Value);
}

exec simulated function TestRender ()
{
   SendCommand(7,False);
}

exec simulated function GetKiller ()
{
   SendCommand(0,True);
}

exec simulated function PunishTK ()
{
   SendCommand(1,True);
}

exec simulated function ForgiveTK ()
{
   SendCommand(2,True);
}

// =============================================================================
// Default Properties

defaultproperties
{
   ActorID="TOST Tools Console Commands:"

   CommandList(0)=(Command="xSay",Help="Similar to 'Say', but allows improved chat Messages which display Location, Health etc.")
   CommandList(1)=(Command="xTeamSay",Help="Similar to 'TeamSay', but allows improved chat Messages which display Location, Health etc.")
   CommandList(2)=(Command="Echo",Help="Displays a Message on the HUD and the Console of the Owner")
   CommandList(3)=(Command="#",Help="Use each letter after the '#' char: H=Health,A=Armor,N=Name,L=Location,W=Weapon,B=Nearby Teammates,T=Current Target,N=Current Name. Ex.: xTeamSay Reloading my #W")
   CommandList(4)=(Command="ShowTeamInfo",Help="Toggles display of the Info on teams: How many palyers, in total, and how many alive on each team")
   CommandList(5)=(Command="ShowWeaponInfo",Help="Toggles through some display presets on Weapon info, such as weapon icons (if installed), Ammo left, current weapons in inventory etc. To see if the render icons are installed, type" $ Chr(34) $ "TestRender" $ Chr(34))
   CommandList(6)=(Command="ShowNPC",Help="Toggles wether or not to display Hostage info (how many total hostages, on the map and how many alive)")
   CommandList(7)=(Command="xSet",Help="Sets a TOST setting and saves it. Usage: xSet <Setting> <Value>; Ex.: xSet ShowTeamInfo 1")
   CommandList(8)=(Command="GetKiller",Help="Displays the HP,AP and Weapon of the Killer")
   CommandList(9)=(Command="PunishTK",Help="Forgives the last TeamKill")
   CommandList(10)=(Command="ForgiveTK",Help="Punishes the last TeamKill")
}
