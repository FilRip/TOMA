//=============================================================================
// s_BotCW
//=============================================================================
//
// Tactical Ops
// - http://www.planetunreal.com/tacticalops
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen and Benoit "JAH" Delayen
//=============================================================================

class s_BotCW extends UTBotConfigClient
	config;
 
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
// Created
///////////////////////////////////////

function Created()
{
	Super.Created();

	if (ConfigBots != None)
		ConfigBots.HideWindow();
}


///////////////////////////////////////
// LoadCurrentValues
///////////////////////////////////////

// replaces UMenuBotConfigClientWindow's version
function LoadCurrentValues()
{
	local int i;

	BotConfig = class's_SWATGame'.default.BotConfigType;

	for(i=0; i<8; i++)
		Skills[i] = BotConfig.default.Skills[i];

	BaseCombo.SetSelectedIndex( Min(BotConfig.default.Difficulty, 7) );

	TauntLabel.SetText(SkillTaunts[BaseCombo.GetSelectedIndex()]);

	AutoAdjustCheck.bChecked = BotConfig.Default.bAdjustSkill;
	RandomCheck.bChecked = BotConfig.Default.bRandomOrder;

	if(BotmatchParent.bNetworkGame)
		NumBotsEdit.SetValue(string(class's_SWATGame'.Default.MinPlayers));
	else
		NumBotsEdit.SetValue(string(class's_SWATGame'.Default.InitialBots));

	if(BalanceTeamsCheck != None)
		BalanceTeamsCheck.bChecked = class's_SWATGame'.Default.bBalanceTeams;
}


///////////////////////////////////////
// NumBotsChanged
///////////////////////////////////////

// replaces UMenuBotConfigClientWindow's version
function NumBotsChanged()
{
	if (int(NumBotsEdit.GetValue()) > 16)
		NumBotsEdit.SetValue("16");

	if(BotmatchParent.bNetworkGame)
		class<s_SWATGame>(BotmatchParent.GameClass).default.MinPlayers = int(NumBotsEdit.GetValue());
	else
		class<s_SWATGame>(BotmatchParent.GameClass).default.InitialBots = int(NumBotsEdit.GetValue());
	BotmatchParent.GameClass.static.StaticSaveConfig();
}


///////////////////////////////////////
// BalanceTeamsChanged
///////////////////////////////////////

function BalanceTeamsChanged()
{
	class's_SWATGame'.Default.bBalanceTeams = BalanceTeamsCheck.bChecked;
	Log("Set BalanceTeams to: "$class's_SWATGame'.Default.bBalanceTeams);
	class's_SWATGame'.static.StaticSaveConfig();
}


///////////////////////////////////////
// defaultproperties
///////////////////////////////////////

defaultproperties
{
}
