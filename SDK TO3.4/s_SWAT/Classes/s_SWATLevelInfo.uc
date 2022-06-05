class s_SWATLevelInfo extends NavigationPoint;

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
	O_C4TargetLocation
};

enum EObjectiveMeaning
{
	OM_Nothing,
	OM_TeamNotification,
	OM_GameNotification,
	OM_RoundWin
};

struct s_Objective
{
	var() EObjectivePriority ObjectivePriority;
	var() EObjectiveType ObjectiveType;
	var() name Target;
	var() EObjectiveMeaning ObjectiveMeaning;
	var Actor ActorTarget;
	var Pawn Leader;
	var bool bObjectiveAccomplished;
};

var(TO_Scenario) string ScenarioName;
var(TO_Scenario) string ScenarioComment1;
var(TO_Scenario) string ScenarioComment2;
var(TO_Scenario) string CT_Mission1;
var(TO_Scenario) string CT_Mission2;
var(TO_Scenario) string CT_Mission3;
var(TO_Scenario) string CT_Mission4;
var(TO_Scenario) string Terr_Mission1;
var(TO_Scenario) string Terr_Mission2;
var(TO_Scenario) string Terr_Mission3;
var(TO_Scenario) string Terr_Mission4;
var(Obsolete) bool bAllHostagesRescuedEndRound;
var(Obsolete) bool bHostageRescueObjective;
var(TO_Rules) int MaxEvidence;
var(TO_Objectives) s_Objective SWAT_Objectives[10];
var(TO_Objectives) s_Objective Terr_Objectives[10];

function PreBeginPlay ()
{
}

function PostBeginPlay ()
{
}

function ConvertActor ()
{
}

function s_Objective GetTeamObjective (int Team, int Num)
{
}

function name GetTeamObjectiveName (int Team, int Num)
{
}

function name GetObjectiveMeaningName (int Team, int Num)
{
}

function name GetTeamObjPriorityName (int Team, int Num)
{
}

function SetObjectiveLeader (int Team, int Num, Pawn Bot)
{
}
