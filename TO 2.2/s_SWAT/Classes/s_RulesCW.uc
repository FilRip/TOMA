//=============================================================================
// s_RulesCW
//=============================================================================
//
// Tactical Ops
// - http://www.planetunreal.com/tacticalops
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen and Benoit "JAH" Delayen
//=============================================================================

class s_RulesCW extends UTRulesCWindow
	config;


// Friendly Fire Scale
var							UWindowHSliderControl FFSlider;
var localized		string								FFText;
var localized		string								FFHelp;

// Round limit
var						UWindowEditControl	RLEdit;
var localized string							RLText;
var localized string							RLHelp;

// Round duration
var						UWindowEditControl	RDEdit;
var localized string							RDText;
var localized string							RDHelp;

// PreRound duration
var						UWindowEditControl	PRDEdit;
var localized string							PRDText;
var localized string							PRDHelp;

// MirrorDamage
var UWindowCheckbox		EnableMirrorDamageCheck;
var localized string	EnableMirrorDamageText;
var localized string	EnableMirrorDamageHelp;

// ExplosionsFF
var UWindowCheckbox		EnableExplosionsFFCheck;
var localized string	EnableExplosionsFFText;
var localized string	EnableExplosionsFFHelp;


// AllowGhostCam
var UWindowCheckbox		AllowGhostCamCheck;
var localized string	AllowGhostCamText;
var localized string	AllowGhostCamHelp;

// MinAllowedScore
var						UWindowEditControl	MASEdit;
var localized string							MASText;
var localized string							MASHelp;

 
///////////////////////////////////////
// Created
///////////////////////////////////////

function Created()
{
	local int FFS;
	local int ControlWidth, ControlLeft, ControlRight;
	local int CenterWidth, CenterPos, ButtonWidth, ButtonLeft;

	Super.Created();

	ControlWidth = WinWidth/2.5;
	ControlLeft = (WinWidth/2 - ControlWidth)/2;
	ControlRight = WinWidth/2 + ControlLeft;
	
	CenterWidth = (WinWidth/4)*3;
	CenterPos = (WinWidth - CenterWidth)/2;

	ButtonWidth = WinWidth - 140;
	ButtonLeft = WinWidth - ButtonWidth - 40;

	Initialized = false;
	
	DesiredWidth = 220;
	DesiredHeight = 165;

	Initialized = false;

	ControlOffset = 20;

	if ( TimeEdit != None )
		TimeEdit.Align = TA_Left;

	if ( MaxPlayersEdit != None )
		MaxPlayersEdit.Align = TA_Left;

	// Round limit
	RLEdit = UWindowEditControl(CreateControl(class'UWindowEditControl', ControlLeft, ControlOffset, ControlWidth, 1));
	RLEdit.SetText(RLText);
	RLEdit.SetHelpText(RLHelp);
	RLEdit.SetFont(F_Normal);
	RLEdit.SetNumericOnly(true);
	RLEdit.SetMaxLength(2);
	RLEdit.Align = TA_Left;

	ControlOffset += 25;

	// Round duration
	RDEdit = UWindowEditControl(CreateControl(class'UWindowEditControl', ControlLeft, ControlOffset, ControlWidth, 1));
	RDEdit.SetText(RDText);
	RDEdit.SetHelpText(RDHelp);
	RDEdit.SetFont(F_Normal);
	RDEdit.SetNumericOnly(true);
	RDEdit.SetMaxLength(2);
	RDEdit.Align = TA_Left;

	// PreRound duration
	PRDEdit = UWindowEditControl(CreateControl(class'UWindowEditControl', ControlRight, ControlOffset, ControlWidth, 1));
	PRDEdit.SetText(PRDText);
	PRDEdit.SetHelpText(PRDHelp);
	PRDEdit.SetFont(F_Normal);
	PRDEdit.SetNumericOnly(true);
	PRDEdit.SetMaxLength(2);
	PRDEdit.Align = TA_Left;

	if ( MaxPlayersEdit != None )
		ControlOffset += 55;
	else
		ControlOffset += 30;

	// Friendly Fire Scale
	FFSlider = UWindowHSliderControl(CreateControl(class'UWindowHSliderControl', CenterPos, ControlOffset, CenterWidth, 1));
	if (FFSlider != None)
	{
		FFSlider.SetRange(0, 10, 1);
		FFS = Class<TO_TeamGamePlus>(BotmatchParent.GameClass).Default.FriendlyFireScale * 10;
		FFSlider.SetValue(FFS);
		FFSlider.SetText(FFText$" ["$FFS*10$"%]:");
		FFSlider.SetHelpText(FFHelp);
		FFSlider.SetFont(F_Normal);
  }

	ControlOffset += 20;

	// MirrorDamage
	EnableMirrorDamageCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', ControlLeft, ControlOffset, ControlWidth, 1));
	EnableMirrorDamageCheck.SetText(EnableMirrorDamageText);
	EnableMirrorDamageCheck.SetHelpText(EnableMirrorDamageHelp);
	EnableMirrorDamageCheck.SetFont(F_Normal);
	EnableMirrorDamageCheck.Align = TA_Left;

	ControlOffset += 20;

	// ExplosionsFF
	EnableExplosionsFFCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', ControlLeft, ControlOffset, ControlWidth, 1));
	EnableExplosionsFFCheck.SetText(EnableExplosionsFFText);
	EnableExplosionsFFCheck.SetHelpText(EnableExplosionsFFHelp);
	EnableExplosionsFFCheck.SetFont(F_Normal);
	EnableExplosionsFFCheck.Align = TA_Left;

	ControlOffset += 20;

	// AllowGhostCam
	AllowGhostCamCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', ControlLeft, ControlOffset, ControlWidth, 1));
	AllowGhostCamCheck.SetText(AllowGhostCamText);
	AllowGhostCamCheck.SetHelpText(AllowGhostCamHelp);
	AllowGhostCamCheck.SetFont(F_Normal);
	AllowGhostCamCheck.Align = TA_Left;

	// Round duration
	MASEdit = UWindowEditControl(CreateControl(class'UWindowEditControl', ControlLeft, ControlOffset, ControlWidth, 1));
	MASEdit.SetText(MASText);
	MASEdit.SetHelpText(MASHelp);
	MASEdit.SetFont(F_Normal);
	MASEdit.SetNumericOnly(true);
	MASEdit.SetMaxLength(2);
	MASEdit.Align = TA_Left;

	if (FragEdit != None)
		FragEdit.HideWindow();

	if (TourneyCheck != None)
		TourneyCheck.HideWindow();

	if (ForceRespawnCheck != None)
		ForceRespawnCheck.HideWindow();

	if (WeaponsCheck != None)
		WeaponsCheck.HideWindow();

	if (MaxSpectatorsEdit != None)
		MaxSpectatorsEdit.HideWindow();

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

	ControlWidth = WinWidth/2.5;
	ControlLeft = (WinWidth/2 - ControlWidth)/2;
	ControlRight = WinWidth/2 + ControlLeft;

	CenterWidth = (WinWidth/4)*3;
	CenterPos = (WinWidth - CenterWidth)/2;

	RLEdit.SetSize(ControlWidth, 1);
	RLEdit.WinLeft = ControlLeft;
	RLEdit.EditBoxWidth = 25;

	RDEdit.SetSize(ControlWidth, 1);
	RDEdit.WinLeft = ControlRight;
	RDEdit.EditBoxWidth = 25;

	PRDEdit.SetSize(ControlWidth, 1);
	PRDEdit.WinLeft = ControlLeft;
	PRDEdit.EditBoxWidth = 25;

	FFSlider.SetSize(CenterWidth, 1);
	FFSlider.SliderWidth = 90;
	FFSlider.WinLeft = CenterPos;

	EnableMirrorDamageCheck.SetSize(ControlWidth, 1);
	EnableMirrorDamageCheck.WinLeft = ControlLeft;

	EnableExplosionsFFCheck.SetSize(ControlWidth, 1);
	EnableExplosionsFFCheck.WinLeft = ControlLeft;

	AllowGhostCamCheck.SetSize(ControlWidth, 1);
	AllowGhostCamCheck.WinLeft = ControlLeft;

	MASEdit.SetSize(ControlWidth, 1);
	MASEdit.WinLeft = ControlRight;
	MASEdit.EditBoxWidth = 25;
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
		switch (C)
		{
			case RLEdit:
				RLChanged();
				break;

			case RDEdit:
				RDChanged();
				break;

			case PRDEdit:
				PRDChanged();
				break;

			case FFSlider:
				FFChanged();
				break;

			case EnableMirrorDamageCheck:
				EnableMirrorDamageCheckChanged();
				break;

			case EnableExplosionsFFCheck:
				EnableExplosionsFFCheckChanged();
				break;

			case AllowGhostCamCheck:
				AllowGhostCamCheckChanged();
				break;

			case MASEdit:
				MASChanged();
				break;
		}
	}
}


///////////////////////////////////////
// RLChanged
///////////////////////////////////////

function RLChanged()
{
	Class<s_SWATGame>(BotmatchParent.GameClass).Default.RoundLimit = int(RLEdit.GetValue());
}


///////////////////////////////////////
// RDChanged
///////////////////////////////////////

function RDChanged()
{
	Class<s_SWATGame>(BotmatchParent.GameClass).Default.RoundDuration = int(RDEdit.GetValue());
}


///////////////////////////////////////
// PRDChanged
///////////////////////////////////////

function PRDChanged()
{
	Class<s_SWATGame>(BotmatchParent.GameClass).Default.PreRoundDuration1 = int(PRDEdit.GetValue());
}


///////////////////////////////////////
// FFChanged
///////////////////////////////////////

function FFChanged()
{
	Class<TO_TeamGamePlus>(BotmatchParent.GameClass).Default.FriendlyFireScale = FFSlider.GetValue() / 10;
	FFSlider.SetText(FFText$" ["$int(FFSlider.GetValue()*10)$"%]:");
}


///////////////////////////////////////
// EnableMirrorDamageCheckChanged
///////////////////////////////////////

function EnableMirrorDamageCheckChanged()
{
	Class<s_SWATGame>(BotmatchParent.GameClass).Default.bMirrorDamage = EnableMirrorDamageCheck.bChecked;
}


///////////////////////////////////////
// EnableExplosionsFFCheckChanged
///////////////////////////////////////

function EnableExplosionsFFCheckChanged()
{
	Class<s_SWATGame>(BotmatchParent.GameClass).Default.bExplosionsFF = EnableExplosionsFFCheck.bChecked;
}


///////////////////////////////////////
// AllowGhostCamCheckChanged
///////////////////////////////////////

function AllowGhostCamCheckChanged()
{
	Class<s_SWATGame>(BotmatchParent.GameClass).Default.bAllowGhostCam = AllowGhostCamCheck.bChecked;
}


///////////////////////////////////////
// MASChanged
///////////////////////////////////////

function MASChanged()
{
	Class<s_SWATGame>(BotmatchParent.GameClass).Default.MinAllowedScore = Max(int(RDEdit.GetValue()), 0);
}


///////////////////////////////////////
// LoadCurrentValues
///////////////////////////////////////
// replaces UMenuGameRulesCWindow's version

function LoadCurrentValues()
{
	RLEdit.SetValue(string(Class<s_SWATGame>(BotmatchParent.GameClass).Default.RoundLimit));
	RDEdit.SetValue(string(Class<s_SWATGame>(BotmatchParent.GameClass).Default.RoundDuration));
	PRDEdit.SetValue(string(Class<s_SWATGame>(BotmatchParent.GameClass).Default.PreRoundDuration1));

	EnableMirrorDamageCheck.bChecked = Class<s_SWATGame>(BotmatchParent.GameClass).Default.bMirrorDamage;
	EnableExplosionsFFCheck.bChecked = Class<s_SWATGame>(BotmatchParent.GameClass).Default.bExplosionsFF;
	AllowGhostCamCheck.bChecked = Class<s_SWATGame>(BotmatchParent.GameClass).Default.bAllowGhostCam;

	MASEdit.SetValue(string(Class<s_SWATGame>(BotmatchParent.GameClass).Default.MinAllowedScore));

	FragEdit.SetValue(string(Class<TO_DeathMatchPlus>(BotmatchParent.GameClass).Default.FragLimit));

	TimeEdit.SetValue(string(Class<TO_DeathMatchPlus>(BotmatchParent.GameClass).Default.TimeLimit));

	if(MaxPlayersEdit != None)
		MaxPlayersEdit.SetValue(string(Class<TO_DeathMatchPlus>(BotmatchParent.GameClass).Default.MaxPlayers));

	if(MaxSpectatorsEdit != None)
		MaxSpectatorsEdit.SetValue(string(Class<TO_DeathMatchPlus>(BotmatchParent.GameClass).Default.MaxSpectators));

	if(BotmatchParent.bNetworkGame)
		WeaponsCheck.bChecked = Class<TO_DeathMatchPlus>(BotmatchParent.GameClass).Default.bMultiWeaponStay;
	else
		WeaponsCheck.bChecked = Class<TO_DeathMatchPlus>(BotmatchParent.GameClass).Default.bCoopWeaponMode;

	TourneyCheck.bChecked = Class<TO_DeathMatchPlus>(BotmatchParent.GameClass).Default.bTournament;

	if(ForceRespawnCheck != None)
		ForceRespawnCheck.bChecked = Class<TO_DeathMatchPlus>(BotmatchParent.GameClass).Default.bForceRespawn;
}


function TourneyChanged()
{
	Class<TO_DeathMatchPlus>(BotmatchParent.GameClass).Default.bTournament = TourneyCheck.bChecked;
}

function ForceRespawnChanged()
{
	Class<TO_DeathMatchPlus>(BotmatchParent.GameClass).Default.bForceRespawn = ForceRespawnCheck.bChecked;
}

// replaces UMenuGameRulesCWindow's version
function FragChanged()
{
	Class<TO_DeathMatchPlus>(BotmatchParent.GameClass).Default.FragLimit = int(FragEdit.GetValue());
}

// replaces UMenuGameRulesCWindow's version
function TimeChanged()
{
	Class<TO_DeathMatchPlus>(BotmatchParent.GameClass).Default.TimeLimit = int(TimeEdit.GetValue());
}

// replaces UMenuGameRulesCWindow's version
function MaxPlayersChanged()
{
	if(int(MaxPlayersEdit.GetValue()) > 16)
		MaxPlayersEdit.SetValue("16");
	if(int(MaxPlayersEdit.GetValue()) < 1)
		MaxPlayersEdit.SetValue("1");

	Class<TO_DeathMatchPlus>(BotmatchParent.GameClass).Default.MaxPlayers = int(MaxPlayersEdit.GetValue());
}

function MaxSpectatorsChanged()
{
	if(int(MaxSpectatorsEdit.GetValue()) > 16)
		MaxSpectatorsEdit.SetValue("16");
	
	if(int(MaxSpectatorsEdit.GetValue()) < 0)
		MaxSpectatorsEdit.SetValue("0");

	Class<TO_DeathMatchPlus>(BotmatchParent.GameClass).Default.MaxSpectators = int(MaxSpectatorsEdit.GetValue());
}

// replaces UMenuGameRulesCWindow's version
function WeaponsChecked()
{
	if(BotmatchParent.bNetworkGame)
		Class<TO_DeathMatchPlus>(BotmatchParent.GameClass).Default.bMultiWeaponStay = WeaponsCheck.bChecked;
	else
		Class<TO_DeathMatchPlus>(BotmatchParent.GameClass).Default.bCoopWeaponMode = WeaponsCheck.bChecked;
}


/*
function SetupNetworkOptions()
{

	// don't call UTRulesCWindow's version (force respawn)
	//	Super(UMenuGameRulesBase).SetupNetworkOptions();

} */

///////////////////////////////////////
// defaultproperties
///////////////////////////////////////

defaultproperties
{
     FFText="Friendly Fire:"
     FFHelp="Slide to adjust the amount of damage friendly fire imparts to other teammates."
     RLText="Round Limit"
     RLHelp="Maximum number of round played before map change, doesn't affect Time Limit(0 = Unlimited)."
     RDText="Round duration"
     RDHelp="Maximum round duration in minutes."
     PRDText="Briefing duration"
     PRDHelp="Pre-round Briefing duration in seconds."
     EnableMirrorDamageText="Mirror Damage"
     EnableMirrorDamageHelp="Inflicts 200% damage to attacker, when attacking other teammates."
     EnableExplosionsFFText="Explosions FF"
     EnableExplosionsFFHelp="Enables Friendly Fire for explosions."
     AllowGhostCamText="Allow Ghost Cam"
     AllowGhostCamHelp="Enables Ghost Cam when dead in online games."
     MASText="Min allowed score"
     MASHelp="Positive value. When a player's score reaches -value he will be tmpkickbanned. (0=disabled)"
}
