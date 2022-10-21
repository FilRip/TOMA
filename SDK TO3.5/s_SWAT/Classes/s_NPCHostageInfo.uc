class s_NPCHostageInfo extends Engine.Info;

var float AdjustedDifficulty;
var int NumClasses;
var byte Difficulty;
var byte ConfigUsed;
var int PlayerDeaths;
var int PlayerKills;
var int BotTeams;
var bool bRandomOrder;
var float BotSkills;
var float BotAccuracy;
var float CombatStyle;
var float Alertness;
var float Camping;
var float StrafingAbility;
var byte BotJumpy;
var bool bAdjustSkill;

function int GetBotIndex (coerce string BotName)
{
}

function string GetBotClassName (int N)
{
}

function SetBotSkin (coerce string NewSkin, int N)
{
}

function string GetBotSkin (int Num)
{
}

function Class<Bot> CHGetBotClass (int N)
{
}

function int ChooseBotInfo ()
{
}

function string GetAvailableClasses (int N)
{
}

function CHIndividualize (Bot NewBot, int N, int NumBots)
{
}

function string GetBotFace (int N)
{
}

function SetBotFace (coerce string NewFace, int N)
{
}

function SetBotTeam (int NewTeam, int N)
{
}

function int GetBotTeam (int Num)
{
}

function string GetBotName (int N)
{
}

function SetBotName (coerce string NewName, int N)
{
}

function SetBotClass (string ClassName, int N)
{
}

function AdjustSkill (Bot B, bool bWinner)
{
}

function PostBeginPlay ()
{
}

function PreBeginPlay ()
{
}


defaultproperties
{
}

