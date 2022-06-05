class TO_ScenarioInfo extends TacticalOpsMapActors;

enum EObjectivePriority
{
	OP_None,
	OP_Always,
	OP_AlwaysPrioritary,
	OP_AlwaysOrder,
	OP_AlwaysOrderPrioritary,
	OP_Once,
	OP_OncePrioritary,
	OP_OnceOrder,
	OP_OnceOrderPrioritary
};

enum EObjectiveType
{
	O_DoNothing,
	O_GoHome,
	O_AssaultEnemy,
	O_FindClosestBuyPoint,
	O_SeekForHostages,
	O_GotoLocation,
	O_TriggerTarget,
	O_CollectSpecialItem,
	O_Escape,
	O_CollectEvidence,
	O_C4TargetLocation,
	O_ActivateTO_ConsoleTimer
};

struct s_ObjectivePriv
{
	var Actor ActorTarget;
	var Pawn Leader;
	var bool bObjectiveAccomplished;
};

struct s_ObjectivePub
{
	var() EObjectivePriority ObjectivePriority;
	var() EObjectiveType ObjectiveType;
	var() name Target;
	var() name EventAccomplished;
	var() bool bWinRound;
	var() bool bToggle;
	var() bool bToggleTo;
};

var(TO_Scenario) localized string ScenarioName;
var(TO_Scenario) localized string ScenarioDescription1;
var(TO_Scenario) localized string ScenarioDescription2;
var(TO_Scenario) localized string SF_Objective1;
var(TO_Scenario) localized string SF_Objective2;
var(TO_Scenario) localized string SF_Objective3;
var(TO_Scenario) localized string SF_Objective4;
var(TO_Scenario) localized string Terr_Objective1;
var(TO_Scenario) localized string Terr_Objective2;
var(TO_Scenario) localized string Terr_Objective3;
var(TO_Scenario) localized string Terr_Objective4;
var(TO_Scenario) Texture ObjShot1;
var(TO_Scenario) Texture ObjShot2;
var(TO_Scenario) Texture ObjShot3;
var(TO_Scenario) Texture ObjShot4;
var(TO_Settings) byte MaxEvidence;
var(TO_Settings) bool bShowDefaultWinMessages;
var(TO_Settings) bool bSFAttitudeOffensive;
var(TO_Settings) bool bTerrAttitudeOffensive;
var(TO_Settings) float LeaderThreshold;
var(TO_Settings) ETeams DefaultLooser;
var(TO_Settings) localized string DefaultLooseMessage;
var(TO_Settings) int WinAmount;
var(TO_Settings) name EventBeginRound;
var(TO_Settings) name EventEndRound;
var(TO_Objectives) s_ObjectivePub SF_Objectives[10];
var(TO_Objectives) s_ObjectivePub Terr_Objectives[10];
var s_ObjectivePriv SF_ObjectivesPriv[10];
var s_ObjectivePriv Terr_ObjectivesPriv[10];

function PostBeginPlay ()
{
}

function PreBeginPlay ()
{
}

function s_ObjectivePub GetTeamObjectivePub (byte Team, byte Num)
{
}

function s_ObjectivePriv GetTeamObjectivePriv (byte Team, byte Num)
{
}

function name GetTeamObjectiveName (byte Team, byte Num)
{
}

function SetObjectiveLeader (byte Team, byte Num, Pawn Bot)
{
}

function SetAccomplishedObjective (byte Team, byte Num, bool bval)
{
}

function SetTeamObjTypeName (byte Team, byte Num, name ObjName)
{
}

function SetTeamObjPriorityName (byte Team, byte Num, name ObjName)
{
}
