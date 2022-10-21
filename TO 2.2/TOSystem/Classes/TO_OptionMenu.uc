//=============================================================================
// TO_OptionMenu
//=============================================================================
//
// Tactical Ops
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen
//=============================================================================


class TO_OptionMenu extends UWindowPulldownMenu;

var UWindowPulldownMenuItem Preferences, Desktop, Advanced, Player;
// var UWindowPulldownMenuItem Prioritize;

var localized string PreferencesName;
var localized string PreferencesHelp;
//var localized string PrioritizeName;
//var localized string PrioritizeHelp;
var localized string DesktopName;
var localized string DesktopHelp;
var localized string PlayerMenuName;
var localized string PlayerMenuHelp;

var Class<UWindowWindow> PlayerWindowClass;
var class<UWindowWindow> WeaponPriorityWindowClass;


///////////////////////////////////////
// Created
///////////////////////////////////////

function Created()
{
	Super.Created();

	Preferences = AddMenuItem(PreferencesName, None);
	Player = AddMenuItem(PlayerMenuName, None);
//	Prioritize = AddMenuItem(PrioritizeName, None);

	AddMenuItem("-", None);

	Desktop = AddMenuItem(DesktopName, None);
	Desktop.bChecked = Root.Console.ShowDesktop;
}


///////////////////////////////////////
// UWindowWindow
///////////////////////////////////////

function UWindowWindow PlayerSetup()
{
	return Root.CreateWindow(PlayerWindowClass, 100, 100, 200, 200, Self, True);
}


///////////////////////////////////////
// ShowPreferences
///////////////////////////////////////

function ShowPreferences(optional bool bNetworkSettings)
{
	local TO_PreferencesWindow O;

	O = TO_PreferencesWindow(Root.CreateWindow(Class'TO_PreferencesWindow', 100, 100, 200, 200, Self, True));
	if (bNetworkSettings)
		TO_PreferencesClientWindow(O.ClientArea).ShowNetworkTab();
}


///////////////////////////////////////
// ExecuteItem
///////////////////////////////////////

function ExecuteItem(UWindowPulldownMenuItem I) 
{
	switch (I)
	{
	case Preferences:
		ShowPreferences();
		break;
/*	case Prioritize:
		// Create prioritize weapons dialog.
		Root.CreateWindow(WeaponPriorityWindowClass, 100, 100, 200, 200, Self, True);
		break; */
	case Desktop:
		// Toggle show desktop.
		Desktop.bChecked = !Desktop.bChecked;
		Root.Console.ShowDesktop = !Root.Console.ShowDesktop;
		Root.Console.bNoDrawWorld = Root.Console.ShowDesktop;
		Root.Console.SaveConfig();
		break;
	case Player:
		// Create player dialog.
		PlayerSetup();
		break;
	}

	Super.ExecuteItem(I);
}


///////////////////////////////////////
// Select
///////////////////////////////////////

function Select(UWindowPulldownMenuItem I) 
{
	switch (I)
	{
		case Preferences:
			TO_MenuBar(GetMenuBar()).SetHelp(PreferencesHelp);
			break;
	/*	case Prioritize:
			TO_MenuBar(GetMenuBar()).SetHelp(PrioritizeHelp);
			break; */
		case Desktop:
			TO_MenuBar(GetMenuBar()).SetHelp(DesktopHelp);
			break;
		case Player:
			TO_MenuBar(GetMenuBar()).SetHelp(PlayerMenuHelp);
			break;
	}

	Super.Select(I);
}


///////////////////////////////////////
// defaultproperties
///////////////////////////////////////
/*
    PrioritizeName="&Weapons"
     PrioritizeHelp="Change your weapon priority, view and set weapon options."
*/

defaultproperties
{
     PreferencesName="P&references"
     PreferencesHelp="Change your game options, audio and video setup, HUD configuration, controls and other options."
     DesktopName="Show &Desktop"
     DesktopHelp="Toggle between showing your game behind the menus, or the desktop logo."
     PlayerMenuName="UT &Player Setup"
     PlayerMenuHelp="Configure your player setup for multiplayer and botmatch UT with TO weapons gaming."
     PlayerWindowClass=Class'UTMenu.UTPlayerWindow'
     WeaponPriorityWindowClass=Class'UTMenu.UTWeaponPriorityWindow'
}
