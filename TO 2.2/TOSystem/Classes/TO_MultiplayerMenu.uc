//=============================================================================
// TO_MultiplayerMenu
//=============================================================================
//
// Tactical Ops
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen
//=============================================================================

class TO_MultiplayerMenu expands UWindowPulldownMenu;

var config string OnlineServices[10];

var UWindowPulldownMenuItem OnlineServiceItems[10];
var string OnlineServiceCmdType[10];
var string OnlineServiceCmdAction[10];
var string OnlineServiceHelp[10];
var int OnlineServiceCount;

var UWindowPulldownMenuItem Start, Browser, LAN, Patch, Disconnect, Reconnect, OpenLocation;
var UBrowserMainWindow BrowserWindow;

var localized string StartName;
var localized string StartHelp;
var localized string BrowserName;
var localized string BrowserHelp;
var localized string LANName;
var localized string LANHelp;
var localized string OpenLocationName;
var localized string OpenLocationHelp;
var localized string PatchName;
var localized string PatchHelp;
var localized string DisconnectName;
var localized string DisconnectHelp;
var localized string ReconnectName;
var localized string ReconnectHelp;
var localized string SuggestPlayerSetupTitle;
var localized string SuggestPlayerSetupText;
var localized string SuggestNetspeedTitle;
var localized string SuggestNetspeedText;

var config string UBrowserClassName;
var config string StartGameClassName;

var UWindowMessageBox SuggestPlayerSetup, SuggestNetspeed;
var bool bOpenLocation;
var bool bOpenLAN;


///////////////////////////////////////
// Created
///////////////////////////////////////

function Created()
{
	local int i;
	local string S;

	Super.Created();
	
	Browser = AddMenuItem(BrowserName, None);
	Start = AddMenuItem(StartName, None);
	LAN = AddMenuItem(LanName, None);
	OpenLocation = AddMenuItem(OpenLocationName, None);
	AddMenuItem("-", None);
	Disconnect = AddMenuItem(DisconnectName, None);
	Reconnect = AddMenuItem(ReconnectName, None);
	AddMenuItem("-", None);
	Patch = AddMenuItem(PatchName, None);

	if(OnlineServices[0] != "")
		AddMenuItem("-", None);

	for(i=0;i<10;i++)
	{
		if(OnlineServices[i] == "")
			break;
	
		if(ParseOption(OnlineServices[i], 0) == "LOCALIZE")
			S = Localize("OnlineServices", ParseOption(OnlineServices[i], 1), "UTMenu");
		else
			S = OnlineServices[i];

		OnlineServiceItems[i] = AddMenuItem(ParseOption(S, 0), None);
		OnlineServiceHelp[i] = ParseOption(S, 1);
		OnlineServiceCmdType[i] = ParseOption(S, 2);
		OnlineServiceCmdAction[i] = ParseOption(S, 3);
	}

	OnlineServiceCount = i;
}


///////////////////////////////////////
// WindowShown
///////////////////////////////////////

function WindowShown()
{
	Super.WindowShown();

	if(GetLevel().NetMode == NM_Client)
	{
		Disconnect.bDisabled = False;
		Reconnect.bDisabled = False;
	}
	else
	{
		Disconnect.bDisabled = True;
		Reconnect.bDisabled = GetLevel() != GetEntryLevel();
	}
}


///////////////////////////////////////
// ResolutionChanged
///////////////////////////////////////

function ResolutionChanged(float W, float H)
{
	if(BrowserWindow != None)
		BrowserWindow.ResolutionChanged(W, H);
	Super.ResolutionChanged(W, H);
}


///////////////////////////////////////
// NotifyQuitUnreal
///////////////////////////////////////

function NotifyQuitUnreal()
{
	if(BrowserWindow != None && !BrowserWindow.bWindowVisible)
		BrowserWindow.NotifyQuitUnreal();
	Super.NotifyQuitUnreal();
}


///////////////////////////////////////
// NotifyBeforeLevelChange
///////////////////////////////////////

function NotifyBeforeLevelChange()
{
	if(BrowserWindow != None && !BrowserWindow.bWindowVisible)
		BrowserWindow.NotifyBeforeLevelChange();
	Super.NotifyBeforeLevelChange();
}


///////////////////////////////////////
// NotifyAfterLevelChange
///////////////////////////////////////

function NotifyAfterLevelChange()
{
	if(BrowserWindow != None && !BrowserWindow.bWindowVisible)
		BrowserWindow.NotifyAfterLevelChange();
	Super.NotifyAfterLevelChange();
}


///////////////////////////////////////
// Select
///////////////////////////////////////

function Select(UWindowPulldownMenuItem I)
{
	local int j;

	for(j=0;j<OnlineServiceCount;j++)
	{
		if(I == OnlineServiceItems[j])
		{
			TO_MenuBar(GetMenuBar()).SetHelp(OnlineServiceHelp[j]);
		}
	}

	switch(I)
	{
	case Start:
		TO_MenuBar(GetMenuBar()).SetHelp(StartHelp);
		break;
	case Browser:
		TO_MenuBar(GetMenuBar()).SetHelp(BrowserHelp);
		break;
	case LAN:
		TO_MenuBar(GetMenuBar()).SetHelp(LANHelp);
		break;
	case OpenLocation:
		TO_MenuBar(GetMenuBar()).SetHelp(OpenLocationHelp);
		break;
	case Patch:
		TO_MenuBar(GetMenuBar()).SetHelp(PatchHelp);
		break;
	case Disconnect:
		TO_MenuBar(GetMenuBar()).SetHelp(DisconnectHelp);
		break;
	case Reconnect:
		TO_MenuBar(GetMenuBar()).SetHelp(ReconnectHelp);
		break;		
	}

	Super.Select(I);
}


///////////////////////////////////////
// ExecuteItem
///////////////////////////////////////

function ExecuteItem(UWindowPulldownMenuItem I) 
{
	local class<UMenuStartGameWindow> StartGameClass;
	local int j;
	local string S;

	for(j=0;j<OnlineServiceCount;j++)
	{
		if(I == OnlineServiceItems[j])
		{
			switch(OnlineServiceCmdType[j])
			{
			case "URL":
				S = GetPlayerOwner().ConsoleCommand("start "$OnlineServiceCmdAction[j]);
				break;
			case "CMD":
				S = GetPlayerOwner().ConsoleCommand(OnlineServiceCmdAction[j]);
				if(S != "")
					MessageBox(OnlineServiceItems[j].Caption, S, MB_OK, MR_OK);
				break;
			case "CMDQUIT":
				S = GetPlayerOwner().ConsoleCommand(OnlineServiceCmdAction[j]);
				if(S != "")
					MessageBox(OnlineServiceItems[j].Caption, S, MB_OK, MR_OK);
				else
					GetPlayerOwner().ConsoleCommand("exit");
				break;
			}
		}
	}

	switch(I)
	{
	case Start:
		// Create start network game dialog.
		StartGameClass = class<UMenuStartGameWindow>(DynamicLoadObject(StartGameClassName, class'Class'));
		Root.CreateWindow(StartGameClass, 100, 100, 200, 200, Self, True);
		break;
	case OpenLocation:
	case Browser:
	case LAN:
		bOpenLAN = (I == LAN);
		bOpenLocation = (I == OpenLocation);

		if(GetPlayerOwner().PlayerReplicationInfo.PlayerName ~= "Player")
			SuggestPlayerSetup = MessageBox(SuggestPlayerSetupTitle, SuggestPlayerSetupText, MB_YesNo, MR_None, MR_None);
		else
		if(!class'UMenuNetworkClientWindow'.default.bShownWindow && !bOpenLAN)
			SuggestNetspeed = MessageBox(SuggestNetspeedTitle, SuggestNetspeedText, MB_YesNo, MR_None, MR_None);
		else
			LoadUBrowser();
		break;
	case Patch:
		GetPlayerOwner().ConsoleCommand("start http://unreal.epicgames.com/");
		break;
	case Disconnect:
		GetPlayerOwner().ConsoleCommand("disconnect");
		Root.Console.CloseUWindow();
		break;
	case Reconnect:
		if(GetLevel().NetMode == NM_Client)
			GetPlayerOwner().ConsoleCommand("disconnect");	
		GetPlayerOwner().ConsoleCommand("reconnect");
		Root.Console.CloseUWindow();
		break;		
	}

	Super.ExecuteItem(I);
}


///////////////////////////////////////
// MessageBoxDone
///////////////////////////////////////

function MessageBoxDone(UWindowMessageBox W, MessageBoxResult Result)
{
	switch(W)
	{
	case SuggestPlayerSetup:
		switch(Result)
		{
		case MR_Yes:
			TO_MenuBar(GetMenuBar()).Options.PlayerSetup();
			break;
		case MR_No:
			LoadUBrowser();
			break;
		}
		break;
	case SuggestNetspeed:
		switch(Result)
		{
		case MR_Yes:
			TO_MenuBar(GetMenuBar()).Options.ShowPreferences(True);
			break;
		case MR_No:
			LoadUBrowser();
			break;
		}
		break;
	}
}


///////////////////////////////////////
// LoadUBrowser
///////////////////////////////////////

function LoadUBrowser()
{
	local class<UBrowserMainWindow> UBrowserClass;

	if(BrowserWindow == None)
	{
		UBrowserClass = class<UBrowserMainWindow>(DynamicLoadObject(UBrowserClassName, class'Class'));
		BrowserWindow = UBrowserMainWindow(Root.CreateWindow(UBrowserClass, 50, 30, 500, 300));
	}
	else
	{
		BrowserWindow.ShowWindow();
		BrowserWindow.BringToFront();
	}
	if(bOpenLocation)
		BrowserWindow.ShowOpenWindow();

	if(bOpenLAN)
		BrowserWindow.SelectLAN();
	else
		BrowserWindow.SelectInternet();

	bOpenLocation = False;
}


///////////////////////////////////////
// ParseOption
///////////////////////////////////////

function string ParseOption(string Input, int Pos)
{
	local int i;

	while(True)
	{
		if(Pos == 0)
		{
			i = InStr(Input, ",");
			if(i != -1)
				Input = Left(Input, i);
			return Input;
		}

		i = InStr(Input, ",");
		if(i == -1)
			return "";

		Input = Mid(Input, i+1);
		Pos--;
	}
}


///////////////////////////////////////
// defaultproperties
///////////////////////////////////////

defaultproperties
{
     OnlineServices(0)="LOCALIZE,MPlayer"
     OnlineServices(1)="LOCALIZE,Heat"
     OnlineServices(2)="LOCALIZE,WON"
     StartName="&Start New Multiplayer Game"
     StartHelp="Start your own network game which others can join."
     BrowserName="&Find Internet Games"
     BrowserHelp="Search for games currently in progress on the Internet."
     LANName="Find &LAN Games"
     LANHelp="Search for games of your local LAN."
     OpenLocationName="Open &Location"
     OpenLocationHelp="Connect to a server using its IP address or unreal:// URL."
     PatchName="Download Latest &Update"
     PatchHelp="Find the latest update to Unreal Tournament on the web!"
     DisconnectName="&Disconnect from Server"
     DisconnectHelp="Disconnect from the current server."
     ReconnectName="&Reconnect to Server"
     ReconnectHelp="Attempt to reconnect to the last server you were connected to."
     SuggestPlayerSetupTitle="Check Player Name"
     SuggestPlayerSetupText="Your name is currently set to Player.  It is recommended that you go to Player Setup and give yourself another name before playing a multiplayer game."
     SuggestNetspeedTitle="Check Internet Speed"
     SuggestNetspeedText="You haven't yet configured the type of Internet connection you will be playing with. It is recommended that you go to the Network Settings screen to ensure you have the best online gaming experience."
     UBrowserClassName="TOSystem.TO_BrowserMainWindowSC"
     StartGameClassName="TOSystem.TO_StartMPSC"
}
