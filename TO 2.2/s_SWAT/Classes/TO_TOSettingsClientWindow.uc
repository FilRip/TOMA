//=============================================================================
// TO_TOSettingsClientWindow
//=============================================================================
//
// Tactical Ops
// - http://www.planetunreal.com/tacticalops
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen
//=============================================================================

Class TO_TOSettingsClientWindow expands UMenuPageWindow
	config;

var	s_BPlayer					sP;
var	class<s_BPlayer>	sPClass;

// HQVoices
var UWindowCheckbox		HQVoicesCheck;
var localized string	HQVoicesText;
var localized string	HQVoicesHelp;

// AutoReload
var UWindowCheckbox		AutoReloadCheck;
var localized string	AutoReloadText;
var localized string	AutoReloadHelp;

// Hide Crosshairs
var UWindowCheckbox		CrosshairCheck;
var localized string	CrosshairText;
var localized string	CrosshairHelp;

// Hide Widescreen
var UWindowCheckbox		WidescreenCheck;
var localized string	WidescreenText;
var localized string	WidescreenHelp;

// Hide deathmessages
var UWindowCheckbox		DeathMsgCheck;
var localized string	DeathMsgText;
var localized string	DeathMsgHelp;

// HUD Transparency Fix (Modulation not supported)
var UWindowCheckbox		HUDModFixCheck;
var localized string	HUDModFixText;
var localized string	HUDModFixHelp;

var bool							Initialized;

var	UWindowLabelControl	Label;
var	string	LabelText;


///////////////////////////////////////
// Created
///////////////////////////////////////

function Created()
{
	local int ControlWidth, ControlLeft, ControlRight, Increment, YPos;

	Super.Created();

	ControlWidth = WinWidth / 1.5;

//	ControlMid = WinWidth/2 - ControlWidth /2;
//	ControlLeft = (WinWidth/2 - ControlWidth)/2;
	ControlLeft = WinWidth/2 - ControlWidth /2;;
	ControlRight = WinWidth/2 + ControlLeft;
	Increment = 20;
	YPos = 20;


	sP = s_BPlayer(GetPlayerOwner());
	// Temp ugly hack
	if ( sP == None )
	{
		Label = UWindowLabelControl(CreateControl(class'UWindowLabelControl', 10, YPos, WinWidth, 1));
		Label.SetText(LabelText);
		return;
	}
/*
	sPClass = class<s_BPlayer>(DynamicLoadObject("s_SWAT.s_BPlayer", class'Class' ));
	if ( sPClass == None )
		log("TO_TOSettingsClientWindow::Created - sPClass == None");
*/

	/*
	// HQVoices
	HQVoicesCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', ControlLeft, 35, ControlWidth, 1));
	HQVoicesCheck.SetText(HQVoicesText);
	HQVoicesCheck.SetHelpText(HQVoicesHelp);
	HQVoicesCheck.SetFont(F_Normal);
	HQVoicesCheck.Align = TA_Left;

	if (GetPlayerOwner().GetDefaultURL("HQVoices") == "True")
		HQVoicesCheck.bChecked = true;
	else
		HQVoicesCheck.bChecked = false;
	YPos += Increment;
*/
	// AutoReload
	AutoReloadCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', ControlLeft, YPos, ControlWidth, 1));
	AutoReloadCheck.SetText(AutoReloadText);
	AutoReloadCheck.SetHelpText(AutoReloadHelp);
	AutoReloadCheck.SetFont(F_Normal);
	AutoReloadCheck.Align = TA_Left;

	if ( sP != None )
		AutoReloadCheck.bChecked = sP.bAutomaticReload;
	//else
	//	AutoReloadCheck.bChecked = sPClass.default.bAutomaticReload;
	/*
	if (GetPlayerOwner().GetDefaultURL("AutoReload") == "True")
		AutoReloadCheck.bChecked = true;
	else
		AutoReloadCheck.bChecked = false;
		*/
	YPos += Increment;

	// Hide Crosshairs
	CrosshairCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', ControlLeft, YPos, ControlWidth, 1));
	CrosshairCheck.SetText(CrosshairText);
	CrosshairCheck.SetHelpText(CrosshairHelp);
	CrosshairCheck.SetFont(F_Normal);
	CrosshairCheck.Align = TA_Left;

	if ( sP != None )
		CrosshairCheck.bChecked = sP.bHideCrosshairs;
	//else
	//	CrosshairCheck.bChecked = sPClass.default.bHideCrosshairs;
	/*
	if (GetPlayerOwner().GetDefaultURL("HideCrossHairs") == "True")
		CrosshairCheck.bChecked = true;
	else
		CrosshairCheck.bChecked = false;
	*/
	YPos += Increment;


	WidescreenCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', ControlLeft, YPos, ControlWidth, 1));
	WidescreenCheck.SetText(WidescreenText);
	WidescreenCheck.SetHelpText(WidescreenHelp);
	WidescreenCheck.SetFont(F_Normal);
	WidescreenCheck.Align = TA_Left;

	if ( sP != None )
		WidescreenCheck.bChecked = sP.bHideWidescreen;
	//else
	//	WidescreenCheck.bChecked = sPClass.default.bHideWidescreen;
/*
	if (GetPlayerOwner().GetDefaultURL("HideWidescreen") == "True")
		WidescreenCheck.bChecked = true;
	else
		WidescreenCheck.bChecked = false;
	*/
	YPos += Increment;

	// Hide DeathMsg
	DeathMsgCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', ControlLeft, YPos, ControlWidth, 1));
	DeathMsgCheck.SetText(DeathMsgText);
	DeathMsgCheck.SetHelpText(DeathMsgHelp);
	DeathMsgCheck.SetFont(F_Normal);
	DeathMsgCheck.Align = TA_Left;

	if ( sP != None )
		DeathMsgCheck.bChecked = sP.bHideDeathMsg;
	//else
	//	DeathMsgCheck.bChecked = sPClass.default.bHideDeathMsg;
/*
	if (GetPlayerOwner().GetDefaultURL("HideDeathMsg") == "True")
		DeathMsgCheck.bChecked = true;
	else
		DeathMsgCheck.bChecked = false;
	*/
	YPos += Increment;


	HUDModFixCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', ControlLeft, YPos, ControlWidth, 1));
	HUDModFixCheck.SetText(HUDModFixText);
	HUDModFixCheck.SetHelpText(HUDModFixHelp);
	HUDModFixCheck.SetFont(F_Normal);
	HUDModFixCheck.Align = TA_Left;

	if ( sP != None )
		HUDModFixCheck.bChecked = sP.bHUDModFix;
	//else
	//	HUDModFixCheck.bChecked = sPClass.default.bHUDModFix;
/*
	if (GetPlayerOwner().GetDefaultURL("HUDModFix") == "True")
		HUDModFixCheck.bChecked = true;
	else
		HUDModFixCheck.bChecked = false;
*/
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

	//ControlLeft = (WinWidth/2 - ControlWidth)/2;
	ControlLeft = WinWidth/2 - ControlWidth /2;
	ControlRight = WinWidth/2 + ControlLeft;

	CenterWidth = (WinWidth/4)*3;
	CenterPos = (WinWidth - CenterWidth)/2;
/*
	HQVoicesCheck.SetSize(ControlWidth, 1);
	HQVoicesCheck.WinLeft = ControlLeft;
*/
	AutoReloadCheck.SetSize(ControlWidth, 1);
	AutoReloadCheck.WinLeft = ControlLeft;

	CrosshairCheck.SetSize(ControlWidth, 1);
	CrosshairCheck.WinLeft = ControlLeft;

	WidescreenCheck.SetSize(ControlWidth, 1);
	WidescreenCheck.WinLeft = ControlLeft;

	DeathMsgCheck.SetSize(ControlWidth, 1);
	DeathMsgCheck.WinLeft = ControlLeft;

	HUDModFixCheck.SetSize(ControlWidth, 1);
	HUDModFixCheck.WinLeft = ControlLeft;

	if ( Label != None )
		Label.SetSize(WinWidth, 1);
}


///////////////////////////////////////
// Notify
///////////////////////////////////////

function Notify(UWindowDialogControl C, byte E)
{
	local int I;

	Super.Notify(C, E);

	if (!Initialized)
		return;

	switch(E)
	{
	case DE_Change:
		switch(C)
		{
			//case HQVoicesCheck:
			//	HQVoicesChanged();

			case AutoReloadCheck:
				AutoReloadChanged();

			case CrosshairCheck:
				CrosshairChanged();
				break;
			case WidescreenCheck:
				WidescreenChanged();
				break;
			case DeathMsgCheck:
				DeathMsgChanged();
				break;
			case HUDModFixCheck:
				HUDModFixChanged();
				break;
		}
	}
}

/*
///////////////////////////////////////
// HQVoicesChanged
///////////////////////////////////////

function HQVoicesChanged()
{
	if (HQVoicesCheck.bChecked)
		GetPlayerOwner().UpdateURL("HQVoices", "True", true);
	else
		GetPlayerOwner().UpdateURL("HQVoices", "False", true);
}
*/


///////////////////////////////////////
// AutoReloadChanged
///////////////////////////////////////

function AutoReloadChanged()
{
	if ( sP != None )
	{
		sP.bAutomaticReload = AutoReloadCheck.bChecked;
		sP.ServerSetAutoReload(AutoReloadCheck.bChecked);
	}
	//else
	//	sPClass.default.bAutomaticReload = AutoReloadCheck.bChecked;
	/*
	if (AutoReloadCheck.bChecked)
		GetPlayerOwner().UpdateURL("AutoReload", "True", true);
	else
		GetPlayerOwner().UpdateURL("AutoReload", "False", true);
	*/
}


///////////////////////////////////////
// CrosshairChanged
///////////////////////////////////////

function CrosshairChanged()
{
	if ( sP != None )
		sP.bHideCrosshairs = CrosshairCheck.bChecked;
	//else
	//	sPClass.default.bHideCrosshairs = CrosshairCheck.bChecked;
	/*
	if (CrosshairCheck.bChecked)
		GetPlayerOwner().UpdateURL("HideCrosshairs", "True", true);
	else
		GetPlayerOwner().UpdateURL("HideCrosshairs", "False", true);
	*/
}



///////////////////////////////////////
// WidescreenChanged
///////////////////////////////////////

function WidescreenChanged()
{
	if ( sP != None )
		sP.bHideWidescreen = WidescreenCheck.bChecked;
	//else
	//	sPClass.default.bHideWidescreen = WidescreenCheck.bChecked;
	/*
	if (WidescreenCheck.bChecked)
		GetPlayerOwner().UpdateURL("HideWidescreen", "True", true);
	else
		GetPlayerOwner().UpdateURL("HideWidescreen", "False", true);
	*/
}


///////////////////////////////////////
// DeathMsgChanged
///////////////////////////////////////

function DeathMsgChanged()
{
	if ( sP != None )
	{
		sP.bHideDeathMsg = DeathMsgCheck.bChecked;
		sP.ServerSetHideDeathMsg(DeathMsgCheck.bChecked);
	}
	//else
	//	sPClass.default.bHideDeathMsg = DeathMsgCheck.bChecked;
/*
	if (DeathMsgCheck.bChecked)
		GetPlayerOwner().UpdateURL("HideDeathMsg", "True", true);
	else
		GetPlayerOwner().UpdateURL("HideDeathMsg", "False", true);
*/
}


///////////////////////////////////////
// HUDModFixChanged
///////////////////////////////////////

function HUDModFixChanged()
{
	if ( sP != None )
		sP.bHUDModFix = HUDModFixCheck.bChecked;
	//else
	//	sPClass.default.bHUDModFix = HUDModFixCheck.bChecked;
/*
	if (HUDModFixCheck.bChecked)
		GetPlayerOwner().UpdateURL("HUDModFix", "True", true);
	else
		GetPlayerOwner().UpdateURL("HUDModFix", "False", true);
*/
}


///////////////////////////////////////
// SaveConfigs
///////////////////////////////////////

function SaveConfigs()
{
	GetPlayerOwner().SaveConfig();

	//log("!!!!!!!!!!!!!!!!!!!!!!!!!!!is good");
	if ( sP != None )
		sP.SaveConfig();
/*
	else
	{
		sPClass.SaveConfig();
		sPClass.static.StaticSaveConfig();
	}
*/
	//GetPlayerOwner().myHUD.SaveConfig();
	//Super.SaveConfigs();
}


///////////////////////////////////////
// defaultproperties
///////////////////////////////////////

defaultproperties
{
     HQVoicesText="HQ Voices"
     HQVoicesHelp="If checked, more speech samples will be played (better, but more RAM needed)"
     AutoReloadText="Automatic Reloading"
     AutoReloadHelp="If checked, Weapon will automatically reload, without having to press the reload key."
     CrosshairText="Hide Crosshairs"
     CrosshairHelp="If checked, crosshairs won't be displayed"
     WidescreenText="Hide Widescreen"
     WidescreenHelp="If checked, Widescreen won't be used when spectating"
     DeathMsgText="Hide Death messages"
     DeathMsgHelp="If checked, death messages won't be displayed in-game"
     HUDModFixText="HUD Transparency Fix"
     HUDModFixHelp="Check this option if you can't see the sniper' Scopes or the Night Vision properly."
     LabelText="You can only access these options during a game."
}
