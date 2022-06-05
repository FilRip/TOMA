class s_NPCHostageInfo extends Info;

var() config string VoiceType[32];
var() config string BotFaces[32];
var() config bool bAdjustSkill;
var() config bool bRandomOrder;
var config byte Difficulty;
var() config string BotNames[32];
var() config int BotTeams[32];
var() config float BotSkills[32];
var() config float BotAccuracy[32];
var() config float CombatStyle[32];
var() config float Alertness[32];
var() config float Camping[32];
var() config float StrafingAbility[32];
var() config string FavoriteWeapon[32];
var byte ConfigUsed[32];
var() config string BotClasses[32];
var() config string BotSkins[32];
var() config byte BotJumpy[32];
var string AvailableClasses[32];
var string AvailableDescriptions[32];
var string NextBotClass;
var int NumClasses;
var localized string Skills[8];
var int PlayerKills;
var int PlayerDeaths;
var float AdjustedDifficulty;
var localized string HostageName;

function PreBeginPlay ()
{
}

function PostBeginPlay ()
{
}

function AdjustSkill (Bot B, bool bWinner)
{
}

function SetBotClass (string ClassName, int N)
{
}

function SetBotName (coerce string NewName, int N)
{
}

function string GetBotName (int N)
{
}

function int GetBotTeam (int Num)
{
}

function SetBotTeam (int NewTeam, int N)
{
}

function SetBotFace (coerce string NewFace, int N)
{
}

function string GetBotFace (int N)
{
}

function CHIndividualize (Bot NewBot, int N, int NumBots)
{
}

function string GetAvailableClasses (int N)
{
}

function int ChooseBotInfo ()
{
}

function Class<Bot> CHGetBotClass (int N)
{
}

function string GetBotSkin (int Num)
{
}

function SetBotSkin (coerce string NewSkin, int N)
{
}

function string GetBotClassName (int N)
{
}

function int GetBotIndex (coerce string BotName)
{
}
