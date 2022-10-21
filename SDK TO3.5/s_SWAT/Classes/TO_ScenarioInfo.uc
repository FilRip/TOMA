class TO_ScenarioInfo extends TacticalOpsMapActors;

struct s_ObjectivePub
{
	var() EObjectivePriority ObjectivePriority;
	var() EObjectiveType ObjectiveType;
	var() name Target;
	var() name EventAccomplished;
	var() bool bWinRound;
	var() bool bToggle;
	var() bool bToggleTo;
}
var s_ObjectivePub SF_Objectives;
struct s_ObjectivePub
{
	var() EObjectivePriority ObjectivePriority;
	var() EObjectiveType ObjectiveType;
	var() name Target;
	var() name EventAccomplished;
	var() bool bWinRound;
	var() bool bToggle;
	var() bool bToggleTo;
}
var s_ObjectivePub Terr_Objectives;
struct s_ObjectivePriv
{
	var Actor ActorTarget;
	var Pawn Leader;
	var bool bObjectiveAccomplished;
}
var s_ObjectivePriv Terr_ObjectivesPriv;
struct s_ObjectivePriv
{
	var Actor ActorTarget;
	var Pawn Leader;
	var bool bObjectiveAccomplished;
}
var s_ObjectivePriv SF_ObjectivesPriv;
var name EventEndRound;
var name EventBeginRound;
var int WinAmount;
enum ETeams {
	ET_Terrorists,
	ET_SpecialForces,
	ET_Both
};
var ETeams DefaultLooser;
var bool bShowDefaultWinMessages;
var byte MaxEvidence;
var Texture ObjShot1;
var Texture ObjShot2;
var Texture ObjShot3;
var Texture ObjShot4;
var float LeaderThreshold;
var bool bSFAttitudeOffensive;
var bool bTerrAttitudeOffensive;

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


defaultproperties
{
}

