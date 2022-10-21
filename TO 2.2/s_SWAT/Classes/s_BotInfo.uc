//=============================================================================
// s_BotInfo
//=============================================================================
//
// Tactical Ops 
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen and Benoit "JAH" Delayen
//=============================================================================

class s_BotInfo extends ChallengeBotInfo
		config;

 
///////////////////////////////////////
// CHGetBotClass
///////////////////////////////////////

function class<bot> CHGetBotClass(int n)
{
	return class<bot>( DynamicLoadObject("s_SWAT.s_BotMCounterTerrorist1", class'Class') );
}


///////////////////////////////////////
// GetBotTeam
///////////////////////////////////////

function int GetBotTeam(int num)
{
	return 255;
}


///////////////////////////////////////
// SetBotName
///////////////////////////////////////

function SetBotName( coerce string NewName, int n )
{	
}


///////////////////////////////////////
// GetBotName
///////////////////////////////////////

function String GetBotName(int n)
{
	return BotNames[n];
}


///////////////////////////////////////
// CHIndividualize
///////////////////////////////////////

function CHIndividualize(bot NewBot, int n, int NumBots)
{
	n = Clamp(n,0,31);

	// Set bot's skin
	//NewBot.Static.SetMultiSkin(NewBot, BotSkins[n], BotFaces[n], BotTeams[n]);

	// Set bot's name.
	if ( (BotNames[n] == "") || (ConfigUsed[n] == 1) )
		BotNames[n] = "Bot";

	Level.Game.ChangeName( NewBot, BotNames[n], false );
	if ( BotNames[n] != NewBot.PlayerReplicationInfo.PlayerName )
		Level.Game.ChangeName( NewBot, ("Bot"$NumBots), false);

	ConfigUsed[n] = 1;

	// adjust bot skill
	NewBot.InitializeSkill(Difficulty + BotSkills[n]);

	//if ( (FavoriteWeapon[n] != "") && (FavoriteWeapon[n] != "None") )
	//	NewBot.FavoriteWeapon = class<Weapon>(DynamicLoadObject(FavoriteWeapon[n],class'Class'));
	
	//NewBot.Accuracy = BotAccuracy[n];
	NewBot.Accuracy = -1.00000;

	//NewBot.CombatStyle = NewBot.Default.CombatStyle + 0.7 * CombatStyle[n];
	//NewBot.CombatStyle = NewBot.Default.CombatStyle - 0.7;
	NewBot.CombatStyle = 0.5;

	NewBot.BaseAggressiveness = 0.5 * (NewBot.Default.Aggressiveness + NewBot.CombatStyle);
	
	NewBot.BaseAlertness = Alertness[n];
	
	// NewBot.CampingRate = Camping[n]
	NewBot.CampingRate = Camping[n] + FRand() / 2.0;
	
	//NewBot.bJumpy = ( BotJumpy[n] != 0 );
	NewBot.bJumpy = false;

	//NewBot.StrafingAbility = StrafingAbility[n];
	NewBot.StrafingAbility = -1.0;
/*
	if ( VoiceType[n] != "" && VoiceType[n] != "None" )
		NewBot.PlayerReplicationInfo.VoiceType = class<VoicePack>(DynamicLoadObject(VoiceType[n], class'Class'));
	
	if ( NewBot.PlayerReplicationInfo.VoiceType == None )
		NewBot.PlayerReplicationInfo.VoiceType = class<VoicePack>(DynamicLoadObject(NewBot.VoiceType, class'Class'));
*/
}



///////////////////////////////////////
// defaultproperties
///////////////////////////////////////

defaultproperties
{
     Difficulty=7
     BotNames(0)="Boris The Blade"
     BotNames(1)="Leon"
     BotNames(2)="James Gong"
     BotNames(3)="Chuck Morris"
     BotNames(4)="Nikita"
     BotNames(5)="Steven Seagull"
     BotNames(6)="Rick Hunter"
     BotNames(7)="Bruce Sweellis"
     BotNames(8)="Sylvester Stallion"
     BotNames(9)="Arnold Schweatzer"
     BotNames(10)="Jean Claude VanDamn"
     BotNames(11)="Mickey Knox"
     BotNames(12)="Clark Gabble"
     BotNames(13)="Clyde Barrow"
     BotNames(15)="Vladimir Putino"
     BotNames(16)="Jean Paul BelloMundo"
     BotNames(17)="Christopher Walker"
     BotNames(18)="Chris Bluker"
     BotNames(19)="Pinda Kaas"
     BotNames(20)="J.C. -AWARE- V.D."
     BotNames(21)="Ford Knocks"
     BotNames(22)="Tony Montana"
     BotNames(23)="Erik -SideKick- Canto"
     BotNames(24)="Benicio del Rojas"
     BotNames(25)="Hannibal del FoCuS"
     BotNames(26)="Blah Knight"
     BotNames(27)="Jack's Smirking Revenge"
     BotNames(28)="King Shag of the Jungle"
     BotNames(29)="The Dude"
     BotNames(30)="Scare Bear"
     BotNames(31)="Goku"
}
