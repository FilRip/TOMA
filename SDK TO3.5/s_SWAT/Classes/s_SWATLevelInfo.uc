class s_SWATLevelInfo extends Engine.NavigationPoint;

struct s_Objective
{
	var() EObjectivePriority ObjectivePriority;
	var() EObjectiveType ObjectiveType;
	var() name Target;
	var() EObjectiveMeaning ObjectiveMeaning;
	var Actor ActorTarget;
	var Pawn Leader;
	var bool bObjectiveAccomplished;
}
var s_Objective Terr_Objectives;
struct s_Objective
{
	var() EObjectivePriority ObjectivePriority;
	var() EObjectiveType ObjectiveType;
	var() name Target;
	var() EObjectiveMeaning ObjectiveMeaning;
	var Actor ActorTarget;
	var Pawn Leader;
	var bool bObjectiveAccomplished;
}
var s_Objective SWAT_Objectives;
var int MaxEvidence;
var bool bAllHostagesRescuedEndRound;
var bool bHostageRescueObjective;

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


defaultproperties
{
}

