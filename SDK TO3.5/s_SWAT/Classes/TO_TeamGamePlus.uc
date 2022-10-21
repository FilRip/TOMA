class TO_TeamGamePlus extends TO_DeathMatchPlus;

var TeamInfo Teams;
var float FriendlyFireScale;
var int MaxTeams;
var bool bBalanceTeams;
var bool bPlayersBalanceTeams;
var int NumSupportingPlayer;
var bool bBalancing;
var int MaxAllowedTeams;
var int MaxTeamSize;
var int PlayerTeamNum;
var name CurrentOrders;
var byte TEAM_Gold;
var byte TEAM_Green;
var byte TEAM_Blue;
var byte TEAM_Red;
var int NextBotTeam;

function string GetRules ()
{
}

function byte AssessBotAttitude (Bot aBot, Pawn Other)
{
}

function Logout (Pawn Exiting)
{
}

event PlayerPawn Login (string Portal, string Options, out string Error, Class<PlayerPawn> SpawnClass)
{
}

event PostLogin (PlayerPawn NewPlayer)
{
}

event InitGame (string Options, out string Error)
{
}

function PostBeginPlay ()
{
}

function InitRatedGame (LadderInventory LadderObj, PlayerPawn LadderPlayer)
{
}

function CheckReady ()
{
}

function byte FindTeamByName (string TeamName)
{
}

function ReBalance ()
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

function bool FindSpecialAttractionFor (Bot aBot)
{
}

function ClearOrders (Pawn Leaving)
{
}

function bool HandleTieUp (Bot Bumper, Bot Bumpee)
{
}

function bool SendBotToGoal (Bot aBot)
{
}

function bool WaitForPoint (Bot aBot)
{
}

function byte PriorityObjective (Bot aBot)
{
}

function PickAmbushSpotFor (Bot aBot)
{
}

function SetAttractionStateFor (Bot aBot)
{
}

function Actor SetDefenseFor (Bot aBot)
{
}

function int ReduceDamage (int Damage, name DamageType, Pawn injured, Pawn instigatedBy)
{
}

function LogGameParameters (StatLog StatLog)
{
}

function ParseName (out string Text, string Replace, string With)
{
}

function PlayStartUpMessage (PlayerPawn NewPlayer)
{
}


defaultproperties
{
}

