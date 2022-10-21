//=============================================================================
// s_SettingsCW
//=============================================================================
//
// Tactical Ops
// - http://www.planetunreal.com/tacticalops
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen and Benoit "JAH" Delayen
//=============================================================================
 
class s_SettingsCW extends UMenuPageWindow
	config;

var	UMenuBotmatchClientWindow BotmatchParent;
var bool											Initialized;
var float											ControlOffset;
var bool											bControlRight;

// Enable Ballistics
var UWindowCheckbox		EnableBallisticsCheck;
var localized string	EnableBallisticsText;
var localized string	EnableBallisticsHelp;

// Reduce SFX
var UWindowCheckbox		ReduceSFXCheck;
var localized string	ReduceSFXText;
var localized string	ReduceSFXHelp;

// Disable real damages
var UWindowCheckbox		DisableRealDamagesCheck;
var localized string	DisableRealDamagesText;
var localized string	DisableRealDamagesHelp;

// Disable IDLE manager
var UWindowCheckbox		DisableIDLEManagerCheck;
var localized string	DisableIDLEManagerText;
var localized string	DisableIDLEManagerHelp;

// LinuxFix
var UWindowCheckbox		LinuxFixCheck;
var localized string	LinuxFixText;
var localized string	LinuxFixHelp;


// DisableActorResetter
var UWindowCheckbox		DisableActorResetterCheck;
var localized string	DisableActorResetterText;
var localized string	DisableActorResetterHelp;


///////////////////////////////////////
// Created
///////////////////////////////////////

function Created()
{
	local int ControlWidth, ControlLeft, ControlRight;
	local int CenterWidth, CenterPos, ButtonWidth, ButtonLeft;

	Super.Created();

	ControlWidth = WinWidth / 1.5;
	ControlLeft = WinWidth/2 - ControlWidth/2;
	ControlRight = WinWidth/2 + ControlLeft;

	CenterWidth = (WinWidth/4)*3;
	CenterPos = (WinWidth - CenterWidth)/2;

	ButtonWidth = WinWidth - 140;
	ButtonLeft = WinWidth - ButtonWidth - 40;

	ControlOffset += 20;

	BotmatchParent = UMenuBotmatchClientWindow(GetParent(class'UMenuBotmatchClientWindow'));
	if (BotmatchParent == None)
		Log("Error: UMenuStartMatchClientWindow without UMenuBotmatchClientWindow parent.");

	// Changed to
	// EnableBallistics
	EnableBallisticsCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', ControlLeft, ControlOffset, ControlWidth, 1));
	EnableBallisticsCheck.SetText(EnableBallisticsText);
	EnableBallisticsCheck.SetHelpText(EnableBallisticsHelp);
	EnableBallisticsCheck.SetFont(F_Normal);
	EnableBallisticsCheck.Align = TA_Left;

	ControlOffset += 25;

	// ReduceSFX
	ReduceSFXCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', ControlLeft, ControlOffset, ControlWidth, 1));
	ReduceSFXCheck.SetText(ReduceSFXText);
	ReduceSFXCheck.SetHelpText(ReduceSFXHelp);
	ReduceSFXCheck.SetFont(F_Normal);
	ReduceSFXCheck.Align = TA_Left;

	ControlOffset += 25;

	// DisableRealDamages
	DisableRealDamagesCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', ControlLeft, ControlOffset, ControlWidth, 1));
	DisableRealDamagesCheck.SetText(DisableRealDamagesText);
	DisableRealDamagesCheck.SetHelpText(DisableRealDamagesHelp);
	DisableRealDamagesCheck.SetFont(F_Normal);
	DisableRealDamagesCheck.Align = TA_Left;

	// DisableIDLEManager
	ControlOffset += 25;

	DisableIDLEManagerCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', ControlLeft, ControlOffset, ControlWidth, 1));
	DisableIDLEManagerCheck.SetText(DisableIDLEManagerText);
	DisableIDLEManagerCheck.SetHelpText(DisableIDLEManagerHelp);
	DisableIDLEManagerCheck.SetFont(F_Normal);
	DisableIDLEManagerCheck.Align = TA_Left;

	ControlOffset += 25;

	// LinuxFix
	LinuxFixCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', ControlLeft, ControlOffset, ControlWidth, 1));
	LinuxFixCheck.SetText(LinuxFixText);
	LinuxFixCheck.SetHelpText(LinuxFixHelp);
	LinuxFixCheck.SetFont(F_Normal);
	LinuxFixCheck.Align = TA_Left;

	// DisableActorResetter
	ControlOffset += 25;

	DisableActorResetterCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', ControlLeft, ControlOffset, ControlWidth, 1));
	DisableActorResetterCheck.SetText(DisableActorResetterText);
	DisableActorResetterCheck.SetHelpText(DisableActorResetterHelp);
	DisableActorResetterCheck.SetFont(F_Normal);
	DisableActorResetterCheck.Align = TA_Left;
}


///////////////////////////////////////
// AfterCreate
///////////////////////////////////////

function AfterCreate()
{
	Super.AfterCreate();

	DesiredWidth = 270;
	DesiredHeight = ControlOffset;

	LoadCurrentValues();
	Initialized = true;
}


///////////////////////////////////////
// BeforePaint
///////////////////////////////////////

function BeforePaint(Canvas C, float X, float Y)
{
	local int ControlWidth, ControlLeft, ControlRight;
	local int CenterWidth, CenterPos, ButtonWidth, ButtonLeft;

	Super.BeforePaint(C, X, Y);

	ControlWidth = WinWidth / 1.5;
	ControlLeft = WinWidth/2 - ControlWidth/2;
	ControlRight = WinWidth/2 + ControlLeft;

	CenterWidth = (WinWidth/4)*3;
	CenterPos = (WinWidth - CenterWidth)/2;

	EnableBallisticsCheck.SetSize(ControlWidth, 1);
	EnableBallisticsCheck.WinLeft = ControlLeft;

	ReduceSFXCheck.SetSize(ControlWidth, 1);
	ReduceSFXCheck.WinLeft = ControlLeft;

	DisableRealDamagesCheck.SetSize(ControlWidth, 1);
	DisableRealDamagesCheck.WinLeft = ControlLeft;

	DisableIDLEManagerCheck.SetSize(ControlWidth, 1);
	DisableIDLEManagerCheck.WinLeft = ControlLeft;

	LinuxFixCheck.SetSize(ControlWidth, 1);
	LinuxFixCheck.WinLeft = ControlLeft;

	DisableActorResetterCheck.SetSize(ControlWidth, 1);
	DisableActorResetterCheck.WinLeft = ControlLeft;
}

/*
///////////////////////////////////////
// Paint
///////////////////////////////////////

function Paint(Canvas C, float X, float Y)
{
	local	bool	bNoSmooth;

	Super.Paint(C, X, Y);

	bNoSmooth = C.bNoSmooth;
	C.bNoSmooth = false;
	DrawStretchedTexture(C, 0, 0, WinWidth, WinHeight, Texture'RulesLOGO');
	C.bNoSmooth = bNoSmooth;
}
*/

///////////////////////////////////////
// Notify
///////////////////////////////////////

function Notify(UWindowDialogControl C, byte E)
{
	if (!Initialized)
		return;

	Super.Notify(C, E);

	switch(E)
	{
	case DE_Change:
		switch(C)
		{
			case EnableBallisticsCheck:
				EnableBallisticsCheckChanged();
				break;

			case ReduceSFXCheck:
				ReduceSFXCheckChanged();
				break;

			case DisableRealDamagesCheck:
				DisableRealDamagesCheckChanged();
				break;

			case	DisableIDLEManagerCheck:
				DisableIDLEManagerCheckChanged();
				break;

			case LinuxFixCheck:
				LinuxFixChanged();
				break;

			case	DisableActorResetterCheck:
				DisableActorResetterCheckChanged();
				break;
		}
	}
}


///////////////////////////////////////
// EnableBallisticsCheckChanged
///////////////////////////////////////

function EnableBallisticsCheckChanged()
{
	Class<s_SWATGame>(BotmatchParent.GameClass).Default.bEnableBallistics = EnableBallisticsCheck.bChecked;
}


///////////////////////////////////////
// ReduceSFXCheckChanged
///////////////////////////////////////

function ReduceSFXCheckChanged()
{
	Class<s_SWATGame>(BotmatchParent.GameClass).Default.bReduceSFX = ReduceSFXCheck.bChecked;
}


///////////////////////////////////////
// DisableRealDamagesCheckChanged
///////////////////////////////////////

function DisableRealDamagesCheckChanged()
{
	Class<s_SWATGame>(BotmatchParent.GameClass).Default.bDisableRealDamages = DisableRealDamagesCheck.bChecked;
}


///////////////////////////////////////
// DisableIDLEManagerCheckChanged
///////////////////////////////////////

function DisableIDLEManagerCheckChanged()
{
	Class<s_SWATGame>(BotmatchParent.GameClass).Default.bDisableIDLEManager = DisableIDLEManagerCheck.bChecked;
}


///////////////////////////////////////
// LinuxFixChanged
///////////////////////////////////////

function LinuxFixChanged()
{
	Class<s_SWATGame>(BotmatchParent.GameClass).Default.bLinuxFix = LinuxFixCheck.bChecked;
}


///////////////////////////////////////
// DisableActorResetterCheckChanged
///////////////////////////////////////

function DisableActorResetterCheckChanged()
{
	Class<s_SWATGame>(BotmatchParent.GameClass).Default.bDisableActorResetter = DisableActorResetterCheck.bChecked;
}


///////////////////////////////////////
// LoadCurrentValues
///////////////////////////////////////

function LoadCurrentValues()
{
	EnableBallisticsCheck.bChecked = Class<s_SWATGame>(BotmatchParent.GameClass).Default.bEnableBallistics;
	ReduceSFXCheck.bChecked = Class<s_SWATGame>(BotmatchParent.GameClass).Default.bReduceSFX;
	DisableRealDamagesCheck.bChecked = Class<s_SWATGame>(BotmatchParent.GameClass).Default.bDisableRealDamages;
	DisableIDLEManagerCheck.bChecked = Class<s_SWATGame>(BotmatchParent.GameClass).Default.bDisableIDLEManager;
	LinuxFixCheck.bChecked = Class<s_SWATGame>(BotmatchParent.GameClass).Default.bLinuxFix;
	DisableActorResetterCheck.bChecked = Class<s_SWATGame>(BotmatchParent.GameClass).Default.bDisableActorResetter;
}


///////////////////////////////////////
// SaveConfigs
///////////////////////////////////////

function SaveConfigs()
{
	Super.SaveConfigs();

	BotmatchParent.GameClass.static.StaticSaveConfig();
	GetPlayerOwner().SaveConfig();
}


///////////////////////////////////////
// defaultproperties
///////////////////////////////////////

defaultproperties
{
     EnableBallisticsText="Enable ballistics"
     EnableBallisticsHelp="Enable wall penetration and projectile delay. Does decrease (network) performance."
     ReduceSFXText="Reduce effects"
     ReduceSFXHelp="Reduce in-game SFX to improve (network) performance."
     DisableRealDamagesText="Disable real damages"
     DisableRealDamagesHelp="Disable real damages if you want to live longer."
     DisableIDLEManagerText="Disable IDLEManager"
     DisableIDLEManagerHelp="Disable IDLE player checking (Kills IDLE players and Kick them from the server)."
     LinuxFixText="Linux fix"
     LinuxFixHelp="Prevent linux servers crashing by disabling money pickups when a player/bot dies."
     DisableActorResetterText="Disable ActorResetter"
     DisableActorResetterHelp="Disable Actor resetting every round (like breaking glass)."
}
