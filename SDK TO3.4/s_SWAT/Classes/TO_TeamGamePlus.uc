class TO_TeamGamePlus extends TO_DeathMatchPlus;

var int NumSupportingPlayer;
var globalconfig bool bBalanceTeams;
var globalconfig bool bPlayersBalanceTeams;
var bool bBalancing;
var() config float FriendlyFireScale;
var() config int MaxTeams;
var int MaxAllowedTeams;
var TeamInfo Teams[4];
var() config int MaxTeamSize;
var localized string StartUpTeamMessage;
var localized string TeamChangeMessage;
var localized string TeamPrefix;
var localized string TeamColor[4];
var int NextBotTeam;
var byte TEAM_Red;
var byte TEAM_Blue;
var byte TEAM_Green;
var byte TEAM_Gold;
var name CurrentOrders[4];
var int PlayerTeamNum;
var() globalconfig string TOIPPolicies[250];

function PlayStartUpMessage (PlayerPawn NewPlayer)
{
}

function PostBeginPlay ()
{
}

event InitGame (string Options, out string Error)
{
}

function InitRatedGame (LadderInventory LadderObj, PlayerPawn LadderPlayer)
{
}

function CheckReady ()
{
}

function bool CheckIPPolicy (string Address)
{
}

function ParseName (out string Text, string Replace, string With)
{
}

event PostLogin (PlayerPawn NewPlayer)
{
}

function LogGameParameters (StatLog StatLog)
{
}

event PlayerPawn Login (string Portal, string Options, out string Error, Class<PlayerPawn> SpawnClass)
{
}

function Logout (Pawn Exiting)
{
}

function byte FindTeamByName (string TeamName)
{
}

function ReBalance ()
{
}

function int ReduceDamage (int Damage, name DamageType, Pawn injured, Pawn instigatedBy)
{
}

function bool ChangeTeam (Pawn Other, int NewTeam)
{
}

function AddToTeam (int Num, Pawn Other)
{
}

function bool CanSpectate (Pawn Viewer, Actor ViewTarget)
{
}

function TeamInfo GetTeam (int TeamNum)
{
}

function bool IsOnTeam (Pawn Other, int TeamNum)
{
}

function SetBotOrders (Bot NewBot)
{
}

function byte AssessBotAttitude (Bot aBot, Pawn Other)
{
}

function Actor SetDefenseFor (Bot aBot)
{
}

function bool FindSpecialAttractionFor (Bot aBot)
{
}

function SetAttractionStateFor (Bot aBot)
{
}

function PickAmbushSpotFor (Bot aBot)
{
}

function byte PriorityObjective (Bot aBot)
{
}

function ClearOrders (Pawn Leaving)
{
}

function bool WaitForPoint (Bot aBot)
{
}

function bool SendBotToGoal (Bot aBot)
{
}

function bool HandleTieUp (Bot Bumper, Bot Bumpee)
{
}

function string GetRules ()
{
}
