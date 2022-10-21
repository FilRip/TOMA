//=============================================================================
// TO_MenuBar
//=============================================================================
//
// Tactical Ops
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen
//=============================================================================

class TO_MenuBar extends UWindowMenuBar;


var UWindowPulldownMenu Game, Multiplayer, Stats, Tool, Help;
var TO_ModMenu Mods;
//var TO_ModsMenu Mods;
var TO_OptionMenu Options;

var UWindowMenuBarItem GameItem, MultiplayerItem, OptionsItem, StatsItem, ToolItem, HelpItem, ModItem;

var UWindowMenuBarItem OldHelpItem;

var UMenuHelpWindow HelpWindow;
var config bool			ShowHelp;

var UWindowMenuBarItem OldSelected;
var string VersionText, TOVersionText;
var bool bShowMenu;

var localized string GameName;
var localized string GameHelp;
var localized string MultiplayerName;
var localized string MultiplayerHelp;
var localized string OptionsName;
var localized string OptionsHelp;
var localized string StatsName;
var localized string StatsHelp;
var localized string ToolName;
var localized string ToolHelp;
var localized string HelpName;
var localized string HelpHelp;
var localized string VersionName;
var localized string ModName;
var localized string ModHelp;

var UMenuModMenuList ModItems;

var config string GameUMenuDefault;
var config string MultiplayerUMenuDefault;
var config string OptionsUMenuDefault;

var	config	int	Build;

var config string ModMenuClass;


///////////////////////////////////////
// Created
///////////////////////////////////////

function Created()
{
	local Class<UWindowPulldownMenu> GameUMenuType;
	local Class<UWindowPulldownMenu> MultiplayerUMenuType;
	local Class<UWindowPulldownMenu> OptionsUMenuType;

	local string GameUMenuName;
	local string MultiplayerUMenuName;
	local string OptionsUMenuName;

	Super.Created();

	bAlwaysOnTop = true;

//	log("creating gamemenu");
	GameItem = AddItem(GameName);
	if(GetLevel().Game != None)
		GameUMenuName = GetLevel().Game.Default.GameUMenuType;
	else
		GameUMenuName = GameUMenuDefault;				
	GameUMenuType = Class<UWindowPulldownMenu>(DynamicLoadObject(GameUMenuName, class'Class'));
	Game = GameItem.CreateMenu(GameUMenuType);

//	log("creating multiplayermenu");
	MultiplayerItem = AddItem(MultiplayerName);
	if(GetLevel().Game != None)
		MultiplayerUMenuName = GetLevel().Game.Default.MultiplayerUMenuType;
	else
		MultiplayerUMenuName = MultiplayerUMenuDefault;
	MultiplayerUMenuType = Class<UWindowPulldownMenu>(DynamicLoadObject(MultiplayerUMenuName, class'Class'));
	Multiplayer = MultiplayerItem.CreateMenu(MultiplayerUMenuType);

//	log("creating optionsmenu");
	OptionsItem = AddItem(OptionsName);
	if(GetLevel().Game != None)
		OptionsUMenuName = GetLevel().Game.Default.GameOptionsMenuType;
	else
		OptionsUMenuName = OptionsUMenuDefault;
	OptionsUMenuType = Class<UWindowPulldownMenu>(DynamicLoadObject(OptionsUMenuName, class'Class'));
	Options = TO_OptionMenu(OptionsItem.CreateMenu(OptionsUMenuType));

//	log("creating statsmenu");
	StatsItem = AddItem(StatsName);
	Stats = StatsItem.CreateMenu(class'TO_StatsMenu');

//	log("creating toolsmenu");
	ToolItem = AddItem(ToolName);
	Tool = ToolItem.CreateMenu(class'TO_ToolsMenu');

	//log("creating modsmenu");
	if ( LoadMods() )
	{
		ModItem = AddItem(ModName);
		Mods = TO_ModMenu(ModItem.CreateMenu(class<UMenuModMenu>(DynamicLoadObject("TOSystem.TO_ModMenu", class'class'))));
		Mods.SetupMods(ModItems);
	}
//	log("creating helpmenu");
	HelpItem = AddItem(HelpName);
	Help = HelpItem.CreateMenu(class'TO_HelpMenu');

	TO_HelpMenu(Help).Context.bChecked = ShowHelp;
	if (ShowHelp)
	{
		if(TO_RootWindow(Root) != None)
			if(TO_RootWindow(Root).StatusBar != None)
				TO_RootWindow(Root).StatusBar.ShowWindow();
	}

	bShowMenu = True;

	Spacing = 12;
}


///////////////////////////////////////
// SetHelp
///////////////////////////////////////

function SetHelp(string NewHelpText)
{
	if(TO_RootWindow(Root) != None)
		if(TO_RootWindow(Root).StatusBar != None)
			TO_RootWindow(Root).StatusBar.SetHelp(NewHelpText);
}


///////////////////////////////////////
// CloseUp
///////////////////////////////////////

function CloseUp()
{
	OldSelected = None;
	Super.CloseUp();
	ShowHelpItem(OldHelpItem);
}


///////////////////////////////////////
// HideWindow
///////////////////////////////////////

function HideWindow()
{
	if(TO_RootWindow(Root) != None)
		if(TO_RootWindow(Root).StatusBar != None)
			TO_RootWindow(Root).StatusBar.HideWindow();
	Super.HideWindow();
}


///////////////////////////////////////
// ShowWindow
///////////////////////////////////////

function ShowWindow()
{
	if (ShowHelp)
	{
		if(TO_RootWindow(Root) != None)
			if(TO_RootWindow(Root).StatusBar != None)
				TO_RootWindow(Root).StatusBar.ShowWindow();
	}
	Super.ShowWindow();
}


///////////////////////////////////////
// ShowHelpItem
///////////////////////////////////////

function ShowHelpItem(UWindowMenuBarItem I)
{
	switch(I)
	{
	case GameItem:
		SetHelp(GameHelp);
		break;	
	case MultiplayerItem:
		SetHelp(MultiplayerHelp);
		break;	
	case OptionsItem:
		SetHelp(OptionsHelp);
		break;	
	case StatsItem:
		SetHelp(StatsHelp);
		break;
	case ToolItem:
		SetHelp(ToolHelp);
		break;	
	case HelpItem:
		SetHelp(HelpHelp);
		break;	
	case ModItem:
		SetHelp(ModHelp);
	default:
		SetHelp("");
		break;	
	}
}


///////////////////////////////////////
// Select
///////////////////////////////////////

function Select(UWindowMenuBarItem I)
{
	Super.Select(I);
	OldSelected = I;

	ShowHelpItem(I);
	Super.Select(I);
}


///////////////////////////////////////
// BeforePaint
///////////////////////////////////////

function BeforePaint(Canvas C, float X, float Y)
{
	Super.BeforePaint(C, X, Y);

	if(Over != OldHelpItem)
	{
		OldHelpItem = Over;
		ShowHelpItem(Over);
	}

	if(bShowMenu)
	{
		// pull the game menu down first time menu is created
		Selected = GameItem;
		Selected.Select();
		Select(Selected);
		bShowMenu = False;
	}
}


///////////////////////////////////////
// DrawItem
///////////////////////////////////////

function DrawItem(Canvas C, UWindowList Item, float X, float Y, float W, float H)
{
	C.DrawColor.R = 255;
	C.DrawColor.G = 255;
	C.DrawColor.B = 255;
	
	if ( UWindowMenuBarItem(Item).bHelp ) 
		W = W - 16;

	UWindowMenuBarItem(Item).ItemLeft = X;
	UWindowMenuBarItem(Item).ItemWidth = W;

	LookAndFeel.Menu_DrawMenuBarItem(Self, UWindowMenuBarItem(Item), X, Y, W, H, C);
}


///////////////////////////////////////
// DrawMenuBar
///////////////////////////////////////

function DrawMenuBar(Canvas C)
{
	local float W, H;

	if ( Build != 0 )
		VersionText = TOVersionText@"Build: 21"$Build$"1.A2708";
	else
		VersionText = TOVersionText;
	// @VersionName@GetLevel().EngineVersion
	LookAndFeel.Menu_DrawMenuBar(Self, C);

	C.Font = Root.Fonts[F_Normal];
	C.DrawColor.R = 0;
	C.DrawColor.G = 0;
	C.DrawColor.B = 0;

	TextSize(C, VersionText, W, H);
	ClipText(C, WinWidth - W - 20, 3, VersionText);
}


///////////////////////////////////////
// LMouseDown
///////////////////////////////////////

function LMouseDown(float X, float Y)
{
	if(X > WinWidth - 13) GetPlayerOwner().ConsoleCommand("togglefullscreen");
	Super.LMouseDown(X, Y);
}


///////////////////////////////////////
// LoadMods
///////////////////////////////////////

function bool LoadMods()
{
	local int NumModClasses;
	local string NextModClass, NextModDesc;
	local int i;
	local UMenuModMenuList NewItem;
	local UMenuModMenuItem TempItem;

	GetPlayerOwner().GetNextIntDesc("UMenu.UMenuModMenuItem", 0, NextModClass, NextModDesc);

	if(NextModClass == "")
		return False;

	ModItems = New class'UMenuModMenuList';
	ModItems.SetupSentinel();

	while( (NextModClass != "") && (NumModClasses < 50) )
	{
		NewItem = UMenuModMenuList(ModItems.Append(class'UMenuModMenuList'));
		NewItem.MenuItemClassName = NextModClass;
		if(NextModDesc != "")
		{
			i = InStr(NextModDesc, ",");
			if(i==-1)
				NewItem.MenuCaption = NextModDesc;
			else
			{
				NewItem.MenuCaption = Left(NextModDesc, i);
				NewItem.MenuHelp= Mid(NextModDesc, i+1);
			}
		}
		else
		{
			TempItem = New class<UMenuModMenuItem>(DynamicLoadObject(NextModClass, class'Class'));
			TempItem.Setup();
			NewItem.MenuCaption = TempItem.MenuCaption;
			NewItem.MenuHelp = TempItem.MenuHelp;		
		}

		NumModClasses++;
		GetPlayerOwner().GetNextIntDesc("UMenu.UMenuModMenuItem", NumModClasses, NextModClass, NextModDesc);
	}
	
	return True;
}


///////////////////////////////////////
// NotifyQuitUnreal
///////////////////////////////////////

function NotifyQuitUnreal()
{
	local UWindowMenuBarItem I;

	for(I = UWindowMenuBarItem(Items.Next); I != None; I = UWindowMenuBarItem(I.Next))
		if(I.Menu != None)
			I.Menu.NotifyQuitUnreal();
}


///////////////////////////////////////
// NotifyBeforeLevelChange
///////////////////////////////////////

function NotifyBeforeLevelChange()
{
	local UWindowMenuBarItem I;

	for(I = UWindowMenuBarItem(Items.Next); I != None; I = UWindowMenuBarItem(I.Next))
		if(I.Menu != None)
			I.Menu.NotifyBeforeLevelChange();
}


///////////////////////////////////////
// NotifyAfterLevelChange
///////////////////////////////////////

function NotifyAfterLevelChange()
{
	local UWindowMenuBarItem I;

	for(I = UWindowMenuBarItem(Items.Next); I != None; I = UWindowMenuBarItem(I.Next))
		if(I.Menu != None)
			I.Menu.NotifyAfterLevelChange();
}


///////////////////////////////////////
// MenuCmd
///////////////////////////////////////

function MenuCmd(int Menu, int Item)
{
	bShowMenu = False;	
	Super.MenuCmd(Menu, Item);
}


///////////////////////////////////////
// defaultproperties
///////////////////////////////////////
/*
ModMenuClass="UMenu.UMenuModMenu"
ModMenuClass="TOSystem.TO_ModsMenu"
    ModName="M&od"
     ModHelp="Configure user-created mods you have installed."
*/

defaultproperties
{
     ShowHelp=True
     TOVersionText="Tactical Ops 2.2.0"
     GameName="&Game"
     GameHelp="Single player game, or quit."
     MultiplayerName="&Multiplayer"
     MultiplayerHelp="Host or join a multiplayer game."
     OptionsName="&Options"
     OptionsHelp="Configure settings."
     StatsName="&Stats"
     StatsHelp="Manage your local and world stats."
     ToolName="&Tools"
     ToolHelp="Enable various system tools."
     HelpName="&Help"
     HelpHelp="Enable or disable help."
     VersionName="- Unreal Tournament Version"
     ModName="M&od"
     ModHelp="Configure user-created mods you have installed."
     GameUMenuDefault="TOSystem.TO_GameMenu"
     MultiplayerUMenuDefault="TOSystem.TO_MultiplayerMenu"
     OptionsUMenuDefault="TOSystem.TO_OptionMenu"
     ModMenuClass="TOSystem.TO_ModMenu"
}
