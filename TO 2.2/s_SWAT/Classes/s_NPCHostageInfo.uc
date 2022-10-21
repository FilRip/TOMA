//=============================================================================
// s_NPCHostageInfo
//=============================================================================
//
// Tactical Ops -- an Unreal Tournament modification
// -- http://www.planetunreal.com/tacticalops
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen and Benoit "JAH" Delayen
//=============================================================================

class s_NPCHostageInfo extends Info;

 
var() config string VoiceType[32];
var() config String BotFaces[32];
var() config bool	bAdjustSkill;
var() config bool	bRandomOrder;
var   config byte	Difficulty;

var() config string BotNames[32];
var() config int BotTeams[32];
var() config float BotSkills[32];
var() config float BotAccuracy[32];
var() config float CombatStyle[32]; 
var() config float Alertness[32];
var() config float Camping[32];
var() config float StrafingAbility[32];
var() config string FavoriteWeapon[32];
var	  byte ConfigUsed[32];
var() config string BotClasses[32];
var() config string BotSkins[32];
var() config byte BotJumpy[32];
var string AvailableClasses[32], AvailableDescriptions[32], NextBotClass;
var int NumClasses;
var localized string Skills[8];

var int PlayerKills, PlayerDeaths;
var float AdjustedDifficulty;


///////////////////////////////////////
// PreBeginPlay
///////////////////////////////////////

function PreBeginPlay()
{
	//DON'T Call parent prebeginplay
}


///////////////////////////////////////
// PostBeginPlay
///////////////////////////////////////

function PostBeginPlay()
{
	local String NextBotClass, NextBotDesc;

	Super.PostBeginPlay();

	NumClasses = 0;
	GetNextIntDesc("Bot", 0, NextBotClass, NextBotDesc); 
	while ( (NextBotClass != "") && (NumClasses < 32) )
	{
		AvailableClasses[NumClasses] = NextBotClass;
		AvailableDescriptions[NumClasses] = NextBotDesc;
		NumClasses++;
		GetNextIntDesc("Bot", NumClasses, NextBotClass, NextBotDesc); 
	}
}


///////////////////////////////////////
// AdjustSkill
///////////////////////////////////////

function AdjustSkill(Bot B, bool bWinner)
{
	local float BotSkill;

	BotSkill = B.Skill;
	if ( !b.bNovice )
		BotSkill += 4;

	if ( bWinner )
	{
		PlayerKills += 1;
		AdjustedDifficulty = FMax(0, AdjustedDifficulty - 2/Min(PlayerKills, 10));
		if ( BotSkill > AdjustedDifficulty )
			B.Skill = AdjustedDifficulty;
		if ( B.Skill < 4 )
		{
			B.bNovice = true;
			if ( B.Skill > 3 )
			{
				B.Skill = 3;
				B.bThreePlus = true;
			}
		}
		else
		{
			B.Skill -= 4;
			B.bNovice = false;
		}
	}
	else
	{
		PlayerDeaths += 1;
		AdjustedDifficulty += FMin(7,2/Min(PlayerDeaths, 10));
		if ( BotSkill < AdjustedDifficulty )
			B.Skill = AdjustedDifficulty;
		if ( B.Skill < 4 )
		{
			B.bNovice = true;
			if ( B.Skill > 3 )
			{
				B.Skill = 3;
				B.bThreePlus = true;
			}
		}
		else
		{
			B.Skill -= 4;
			B.bNovice = false;
		}
	}
	if ( abs(AdjustedDifficulty - Difficulty) >= 1 )
	{
		Difficulty = AdjustedDifficulty;
		SaveConfig();
	}
}


///////////////////////////////////////
// SetBotClass
///////////////////////////////////////

function SetBotClass(String ClassName, int n)
{
	BotClasses[n] = ClassName;
}


///////////////////////////////////////
// SetBotName
///////////////////////////////////////

function SetBotName( coerce string NewName, int n )
{
	BotNames[n] = NewName;
}


///////////////////////////////////////
// GetBotName
///////////////////////////////////////

function String GetBotName(int n)
{
	return BotNames[n];
}


///////////////////////////////////////
// GetBotTeam
///////////////////////////////////////

function int GetBotTeam(int num)
{
	return BotTeams[Num];
}


///////////////////////////////////////
// SetBotTeam
///////////////////////////////////////

function SetBotTeam(int NewTeam, int n)
{
	BotTeams[n] = NewTeam;
}


///////////////////////////////////////
// SetBotFace
///////////////////////////////////////

function SetBotFace(coerce string NewFace, int n)
{
	BotFaces[n] = NewFace;
}


///////////////////////////////////////
// GetBotFace
///////////////////////////////////////

function String GetBotFace(int n)
{
	return BotFaces[n];
}


///////////////////////////////////////
// CHIndividualize
///////////////////////////////////////

function CHIndividualize(bot NewBot, int n, int NumBots)
{
	local			int   v, num;

	// Clamp to use only the 8 first models and textures
	v = Clamp(n,0,8);

	// But 32 hostages allowed !
	n = Clamp(n,0,31);

	// Set bot's skin
	//NewBot.Static.SetMultiSkin(NewBot, BotSkins[v], BotFaces[v], 255);

	num = class'TOPModels.TO_ModelHandler'.static.GetRandomHostageModel();
	NewBot.Mesh = class'TOPModels.TO_ModelHandler'.default.ModelMesh[num];
	NewBot.static.SetMultiSkin(NewBot, "", "", num);

	// Set bot's name.
	if ( (BotNames[n] == "") || (ConfigUsed[n] == 1) )
		BotNames[n] = "Bot";

	Level.Game.ChangeName( NewBot, BotNames[n], false );
	if ( BotNames[n] != NewBot.PlayerReplicationInfo.PlayerName )
		Level.Game.ChangeName( NewBot, ("Bot"$NumBots), false);

	ConfigUsed[n] = 1;

	// adjust bot skill
	NewBot.InitializeSkill(Difficulty + BotSkills[n]);

	if ( (FavoriteWeapon[n] != "") && (FavoriteWeapon[n] != "None") )
		NewBot.FavoriteWeapon = class<Weapon>(DynamicLoadObject(FavoriteWeapon[n],class'Class'));
	NewBot.Accuracy = BotAccuracy[n];
	NewBot.CombatStyle = NewBot.Default.CombatStyle + 0.7 * CombatStyle[n];
	NewBot.BaseAggressiveness = 0.5 * (NewBot.Default.Aggressiveness + NewBot.CombatStyle);
	NewBot.BaseAlertness = Alertness[n];
	NewBot.CampingRate = Camping[n];
	NewBot.bJumpy = ( BotJumpy[n] != 0 );
	NewBot.StrafingAbility = StrafingAbility[n];

	if ( VoiceType[n] != "" && VoiceType[n] != "None" )
		NewBot.PlayerReplicationInfo.VoiceType = class<VoicePack>(DynamicLoadObject(VoiceType[n], class'Class'));
	
	if(NewBot.PlayerReplicationInfo.VoiceType == None)
		NewBot.PlayerReplicationInfo.VoiceType = class<VoicePack>(DynamicLoadObject(NewBot.VoiceType, class'Class'));
}


///////////////////////////////////////
// GetAvailableClasses
///////////////////////////////////////

function String GetAvailableClasses(int n)
{
	return AvailableClasses[n];
}


///////////////////////////////////////
// ChooseBotInfo
///////////////////////////////////////

function int ChooseBotInfo()
{
	local int n, start;

	if ( bRandomOrder )
		n = Rand(16);
	else 
		n = 0;

	start = n;
	while ( (n < 32) && (ConfigUsed[n] == 1) )
		n++;

	if ( (n == 32) && bRandomOrder )
	{
		n = 0;
		while ( (n < start) && (ConfigUsed[n] == 1) )
			n++;
	}

	if ( n > 31 )
		n = 31;

	return n;
}


///////////////////////////////////////
// CHGetBotClass
///////////////////////////////////////

function class<bot> CHGetBotClass(int n)
{
	return class<bot>( DynamicLoadObject(GetBotClassName(n), class'Class') );
}


///////////////////////////////////////
// GetBotSkin
///////////////////////////////////////

function string GetBotSkin( int num )
{
	return BotSkins[Num];
}


///////////////////////////////////////
// SetBotSkin
///////////////////////////////////////

function SetBotSkin( coerce string NewSkin, int n )
{
	BotSkins[n] = NewSkin;
}


///////////////////////////////////////
// GetBotClassName
///////////////////////////////////////

function String GetBotClassName(int n)
{
	if ( (n < 0) || (n > 31) )
		return AvailableClasses[Rand(NumClasses)];

	if ( BotClasses[n] == "" )
		BotClasses[n] = AvailableClasses[Rand(NumClasses)];

	return BotClasses[n];
}


///////////////////////////////////////
// GetBotIndex
///////////////////////////////////////

function int GetBotIndex( coerce string BotName )
{
	local int i;
	local bool found;

	found = false;
	for (i=0; i<ArrayCount(BotNames)-1; i++)
		if (BotNames[i] == BotName)
		{
			found = true;
			break;
		}

	if (!found)
		i = -1;

	return i;
}

 
///////////////////////////////////////
// defaultproperties
///////////////////////////////////////

defaultproperties
{
     BotFaces(0)="TODatas.mate"
     BotFaces(1)="TODatas.mate"
     BotFaces(2)="TODatas.mate"
     BotFaces(3)="TODatas.mate"
     BotFaces(4)="TODatas.mate"
     BotFaces(5)="TODatas.mate"
     BotFaces(6)="TODatas.mate"
     BotFaces(7)="TODatas.mate"
     BotFaces(8)="TODatas.mate"
     BotFaces(9)="TODatas.mate"
     BotFaces(10)="TODatas.mate"
     BotFaces(11)="TODatas.mate"
     BotFaces(12)="TODatas.mate"
     BotFaces(13)="TODatas.mate"
     BotFaces(14)="TODatas.mate"
     BotFaces(15)="TODatas.mate"
     BotFaces(16)="TODatas.mate"
     BotFaces(17)="TODatas.mate"
     BotFaces(18)="TODatas.mate"
     BotFaces(19)="TODatas.mate"
     BotFaces(20)="TODatas.mate"
     BotFaces(21)="TODatas.mate"
     BotFaces(22)="TODatas.mate"
     BotFaces(23)="TODatas.mate"
     BotFaces(24)="TODatas.mate"
     BotFaces(25)="TODatas.mate"
     BotFaces(26)="TODatas.mate"
     BotFaces(27)="TODatas.mate"
     BotFaces(28)="TODatas.mate"
     BotFaces(29)="TODatas.mate"
     BotFaces(30)="TODatas.mate"
     BotFaces(31)="TODatas.mate"
     BotNames(0)="Hostage1"
     BotNames(1)="Hostage2"
     BotNames(2)="Hostage3"
     BotNames(3)="Hostage4"
     BotNames(4)="Hostage5"
     BotNames(5)="Hostage6"
     BotNames(6)="Hostage7"
     BotNames(7)="Hostage8"
     BotNames(8)="Hostage9"
     BotNames(9)="Hostage10"
     BotNames(10)="Hostage11"
     BotNames(11)="Hostage12"
     BotNames(12)="Hostage13"
     BotNames(13)="Hostage14"
     BotNames(14)="Hostage15"
     BotNames(15)="Hostage16"
     BotNames(16)="Hostage17"
     BotNames(17)="Hostage18"
     BotNames(18)="Hostage19"
     BotNames(19)="Hostage20"
     BotNames(20)="Hostage21"
     BotNames(21)="Hostage22"
     BotNames(22)="Hostage23"
     BotNames(23)="Hostage24"
     BotNames(24)="Hostage25"
     BotNames(25)="Hostage26"
     BotNames(26)="Hostage27"
     BotNames(27)="Hostage28"
     BotNames(28)="Hostage29"
     BotNames(29)="Hostage30"
     BotNames(30)="Hostage31"
     BotNames(31)="Hostage32"
     BotTeams(0)=255
     BotTeams(2)=255
     BotTeams(3)=1
     BotTeams(4)=255
     BotTeams(5)=2
     BotTeams(6)=255
     BotTeams(7)=3
     BotTeams(8)=255
     BotTeams(10)=255
     BotTeams(11)=1
     BotTeams(12)=255
     BotTeams(13)=2
     BotTeams(14)=255
     BotTeams(15)=3
     BotTeams(16)=255
     BotTeams(18)=255
     BotTeams(19)=1
     BotTeams(20)=255
     BotTeams(21)=2
     BotTeams(22)=255
     BotTeams(23)=3
     BotTeams(24)=255
     BotTeams(26)=255
     BotTeams(27)=1
     BotTeams(28)=255
     BotTeams(29)=2
     BotTeams(30)=255
     BotTeams(31)=3
     BotAccuracy(17)=0.200000
     BotAccuracy(18)=0.900000
     BotAccuracy(19)=0.600000
     BotAccuracy(20)=0.500000
     BotAccuracy(24)=1.000000
     BotAccuracy(27)=0.500000
     BotAccuracy(28)=0.500000
     BotAccuracy(29)=0.600000
     CombatStyle(16)=0.500000
     CombatStyle(18)=-0.500000
     CombatStyle(19)=-0.500000
     CombatStyle(20)=-1.000000
     CombatStyle(21)=-0.500000
     CombatStyle(22)=0.500000
     CombatStyle(23)=1.000000
     CombatStyle(26)=0.500000
     CombatStyle(30)=0.500000
     Alertness(18)=-0.300000
     Alertness(20)=0.300000
     Alertness(22)=0.300000
     Alertness(24)=0.300000
     Alertness(29)=0.400000
     Camping(18)=1.000000
     Camping(28)=0.500000
     StrafingAbility(17)=0.500000
     StrafingAbility(20)=0.500000
     StrafingAbility(21)=1.000000
     StrafingAbility(22)=0.500000
     StrafingAbility(23)=0.500000
     StrafingAbility(24)=0.500000
     StrafingAbility(25)=0.500000
     StrafingAbility(26)=0.500000
     StrafingAbility(29)=1.000000
     BotClasses(0)="s_SWAT.s_NPCHostage_M2"
     BotClasses(1)="s_SWAT.s_NPCHostage_M2"
     BotClasses(2)="s_SWAT.s_NPCHostage_M2"
     BotClasses(3)="s_SWAT.s_NPCHostage_M2"
     BotClasses(4)="s_SWAT.s_NPCHostage_M2"
     BotClasses(5)="s_SWAT.s_NPCHostage_M2"
     BotClasses(6)="s_SWAT.s_NPCHostage_M2"
     BotClasses(7)="s_SWAT.s_NPCHostage_M2"
     BotClasses(8)="s_SWAT.s_NPCHostage_M2"
     BotClasses(9)="s_SWAT.s_NPCHostage_M2"
     BotClasses(10)="s_SWAT.s_NPCHostage_M2"
     BotClasses(11)="s_SWAT.s_NPCHostage_M2"
     BotClasses(12)="s_SWAT.s_NPCHostage_M2"
     BotClasses(13)="s_SWAT.s_NPCHostage_M2"
     BotClasses(14)="s_SWAT.s_NPCHostage_M2"
     BotClasses(15)="s_SWAT.s_NPCHostage_M2"
     BotClasses(16)="s_SWAT.s_NPCHostage_M2"
     BotClasses(17)="s_SWAT.s_NPCHostage_M2"
     BotClasses(18)="s_SWAT.s_NPCHostage_M2"
     BotClasses(19)="s_SWAT.s_NPCHostage_M2"
     BotClasses(20)="s_SWAT.s_NPCHostage_M2"
     BotClasses(21)="s_SWAT.s_NPCHostage_M2"
     BotClasses(22)="s_SWAT.s_NPCHostage_M2"
     BotClasses(23)="s_SWAT.s_NPCHostage_M2"
     BotClasses(24)="s_SWAT.s_NPCHostage_M2"
     BotClasses(25)="s_SWAT.s_NPCHostage_M2"
     BotClasses(26)="s_SWAT.s_NPCHostage_M2"
     BotClasses(27)="s_SWAT.s_NPCHostage_M2"
     BotClasses(28)="s_SWAT.s_NPCHostage_M2"
     BotClasses(29)="s_SWAT.s_NPCHostage_M2"
     BotClasses(30)="s_SWAT.s_NPCHostage_M2"
     BotClasses(31)="s_SWAT.s_NPCHostage_M2"
     BotSkins(0)="TODatas.ButcherHostage.hprison"
     BotSkins(1)="TODatas.ButcherHostage.hprison"
     BotSkins(2)="TODatas.ButcherHostage.hprison"
     BotSkins(3)="TODatas.ButcherHostage.hprison"
     BotSkins(4)="TODatas.ButcherHostage.hprison"
     BotSkins(5)="TODatas.ButcherHostage.hprison"
     BotSkins(6)="TODatas.ButcherHostage.hprison"
     BotSkins(7)="TODatas.ButcherHostage.hprison"
     BotSkins(8)="TODatas.ButcherHostage.hprison"
     BotSkins(9)="TODatas.ButcherHostage.hprison"
     BotSkins(10)="TODatas.ButcherHostage.hprison"
     BotSkins(11)="TODatas.ButcherHostage.hprison"
     BotSkins(12)="TODatas.ButcherHostage.hprison"
     BotSkins(13)="TODatas.ButcherHostage.hprison"
     BotSkins(14)="TODatas.ButcherHostage.hprison"
     BotSkins(15)="TODatas.ButcherHostage.hprison"
     BotSkins(16)="TODatas.ButcherHostage.hprison"
     BotSkins(17)="TODatas.ButcherHostage.hprison"
     BotSkins(18)="TODatas.ButcherHostage.hprison"
     BotSkins(19)="TODatas.ButcherHostage.hprison"
     BotSkins(20)="TODatas.ButcherHostage.hprison"
     BotSkins(21)="TODatas.ButcherHostage.hprison"
     BotSkins(22)="TODatas.ButcherHostage.hprison"
     BotSkins(23)="TODatas.ButcherHostage.hprison"
     BotSkins(24)="TODatas.ButcherHostage.hprison"
     BotSkins(25)="TODatas.ButcherHostage.hprison"
     BotSkins(26)="TODatas.ButcherHostage.hprison"
     BotSkins(27)="TODatas.ButcherHostage.hprison"
     BotSkins(28)="TODatas.ButcherHostage.hprison"
     BotSkins(29)="TODatas.ButcherHostage.hprison"
     BotSkins(30)="TODatas.ButcherHostage.hprison"
     BotSkins(31)="TODatas.ButcherHostage.hprison"
     BotJumpy(30)=1
     BotJumpy(31)=1
     Skills(0)="Novice"
     Skills(1)="Average"
     Skills(2)="Experienced"
     Skills(3)="Skilled"
     Skills(4)="Adept"
     Skills(5)="Masterful"
     Skills(6)="Inhuman"
     Skills(7)="Godlike"
}
