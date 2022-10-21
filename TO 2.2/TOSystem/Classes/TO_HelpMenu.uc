//=============================================================================
// TO_HelpMenu
//=============================================================================
//
// Tactical Ops
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen
//=============================================================================

class TO_HelpMenu extends UWindowPulldownMenu;

var UWindowPulldownMenuItem Context, EpicURL, TO_URL;
var UWindowPulldownMenuItem About;

var localized string ContextName;
var localized string ContextHelp;

var localized string EpicGamesURLName;
var localized string EpicGamesURLHelp;

var localized string TO_URLName;
var localized string TO_URLHelp;

var localized string AboutName;
var localized string AboutHelp;


///////////////////////////////////////
// Created
///////////////////////////////////////

function Created()
{
	Super.Created();

	Context = AddMenuItem(ContextName, None);
	AddMenuItem("-", None);
	TO_URL = AddMenuItem(TO_URLName, None);
	EpicURL = AddMenuItem(EpicGamesURLName, None);
	About = AddMenuItem(AboutName, None);
}


///////////////////////////////////////
// ExecuteItem
///////////////////////////////////////

function ExecuteItem(UWindowPulldownMenuItem I) 
{
	local TO_MenuBar MenuBar;

	MenuBar = TO_MenuBar(GetMenuBar());

	switch(I)
	{
	case Context:
		Context.bChecked = !Context.bChecked;
		MenuBar.ShowHelp = !MenuBar.ShowHelp;
		if (Context.bChecked)
		{
			if(UMenuRootWindow(Root) != None)
				if(UMenuRootWindow(Root).StatusBar != None)
					UMenuRootWindow(Root).StatusBar.ShowWindow();
		} else {
			if(UMenuRootWindow(Root) != None)
				if(UMenuRootWindow(Root).StatusBar != None)
					UMenuRootWindow(Root).StatusBar.HideWindow();
		}
		MenuBar.SaveConfig();
		break;
	case EpicURL:
		GetPlayerOwner().ConsoleCommand("start http://www.epicgames.com/");
		break;
	case TO_URL:
		GetPlayerOwner().ConsoleCommand("start http://www.tactical-ops.to/");
		break;
	case About:
		//if (class'GameInfo'.Default.DemoBuild == 1)
		//	Root.CreateWindow(class'UTCreditsWindow', 100, 100, 100, 100);
		//else
		//{
			//GetPlayerOwner().ClientTravel( "UTCredits.unr", TRAVEL_Absolute, False );
			GetPlayerOwner().ClientTravel( "CreditsTO.unr", TRAVEL_Absolute, False );
			Root.Console.CloseUWindow();
		//}
		break;
	}

	Super.ExecuteItem(I);
}


///////////////////////////////////////
// Select
///////////////////////////////////////

function Select(UWindowPulldownMenuItem I)
{
	switch(I)
	{
	case Context:
		TO_MenuBar(GetMenuBar()).SetHelp(ContextHelp);
		break;
	case EpicURL:
		TO_MenuBar(GetMenuBar()).SetHelp(EpicGamesURLHelp);
		break;
	case TO_URL:
		TO_MenuBar(GetMenuBar()).SetHelp(TO_URLHelp);
		break;
	case About:
		TO_MenuBar(GetMenuBar()).SetHelp(AboutHelp);
		break;
	}

	Super.Select(I);
}


///////////////////////////////////////
// defaultproperties
///////////////////////////////////////
/*
     AboutName="&UT Credits"
     AboutHelp="Display credits."
*/

defaultproperties
{
     ContextName="Context &Help"
     ContextHelp="Enable and disable this context help area at the bottom of the screen."
     EpicGamesURLName="About &Epic Games"
     EpicGamesURLHelp="Click to open Epic Games webpage!"
     TO_URLName="About &Tactical Ops"
     TO_URLHelp="Click to open the Tactical Ops webpage!"
     AboutName="TO &Credits"
     AboutHelp="Display credits."
}
