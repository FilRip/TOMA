//=============================================================================
// TO_PreferencesClientWindow
//=============================================================================
//
// Tactical Ops
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen
//=============================================================================

class TO_PreferencesClientWindow extends UWindowDialogClientWindow
	config;

var UMenuPageControl Pages;
var UWindowSmallCloseButton CloseButton;

var localized string GamePlayTab, InputTab, ControlsTab, AudioTab, VideoTab, NetworkTab, HUDTab, UTTab, TOTab;
var UWindowPageControlPage Network;

var	string ControlTabClass, TOSettingsTabClass, TOGameOptionsClass;


///////////////////////////////////////
// Created
///////////////////////////////////////

function Created() 
{
	Pages = UMenuPageControl(CreateWindow(class'UMenuPageControl', 0, 0, WinWidth, WinHeight - 48));
	Pages.SetMultiLine(True);
	Pages.AddPage(VideoTab, class'TO_VideoSC');
	Pages.AddPage(AudioTab, class'UMenuAudioScrollClient');
	Pages.AddPage(GamePlayTab, class<UWindowScrollingDialogClient>(DynamicLoadObject(TOGameOptionsClass, class'Class')));
	Pages.AddPage(ControlsTab, class<UWindowScrollingDialogClient>(DynamicLoadObject(ControlTabClass, class'Class')) );
	Pages.AddPage(InputTab, class'UMenuInputOptionsScrollClient');
	Pages.AddPage(HUDTab, class'UMenuHUDConfigScrollClient');
	Pages.AddPage(UTTab, class'TO_UTWeaponsWindow');
	Pages.AddPage(TOTab, class<UWindowScrollingDialogClient>(DynamicLoadObject(TOSettingsTabClass, class'Class')));
	Network = Pages.AddPage(NetworkTab, class'UMenuNetworkScrollClient');
	CloseButton = UWindowSmallCloseButton(CreateControl(class'UWindowSmallCloseButton', WinWidth-56, WinHeight-24, 48, 16));

	Super.Created();
}


///////////////////////////////////////
// ShowNetworkTab
///////////////////////////////////////

function ShowNetworkTab()
{
	Pages.GotoTab(Network, True);
}


///////////////////////////////////////
// Resized
///////////////////////////////////////

function Resized()
{
	Pages.WinWidth = WinWidth;
	Pages.WinHeight = WinHeight - 24;	// OK, Cancel area
	CloseButton.WinLeft = WinWidth-52;
	CloseButton.WinTop = WinHeight-20;
}


///////////////////////////////////////
// Paint
///////////////////////////////////////

function Paint(Canvas C, float X, float Y)
{
	local Texture T;

	T = GetLookAndFeelTexture();
	DrawUpBevel( C, 0, LookAndFeel.TabUnselectedM.H, WinWidth, WinHeight-LookAndFeel.TabUnselectedM.H, T);
}


///////////////////////////////////////
// GetDesiredDimensions
///////////////////////////////////////

function GetDesiredDimensions(out float W, out float H)
{	
	Super(UWindowWindow).GetDesiredDimensions(W, H);
	H += 30;
}


///////////////////////////////////////
// defaultproperties
///////////////////////////////////////

defaultproperties
{
     GamePlayTab="Game"
     InputTab="Input"
     ControlsTab="Controls"
     AudioTab="Audio"
     VideoTab="Video"
     NetworkTab="Network"
     HUDTab="HUD"
     UTTab="TO->UT Weapons"
     TOTab="TO Settings"
     ControlTabClass="TOPModels.TO_ControlsSC"
     TOSettingsTabClass="s_SWAT.TO_TOSettingsSC"
     TOGameOptionsClass="s_SWAT.TO_GameOptionsSC"
}
