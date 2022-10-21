//=============================================================================
// TO_ScenarioInfo
//=============================================================================
//
// Tactical Ops
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen
//=============================================================================
  
class TO_ScenarioInfo extends TacticalOpsMapActors;


var(TO_Scenario)	string		ScenarioName;
var(TO_Scenario)	string		ScenarioDescription1;				// Scenario
var(TO_Scenario)	string		ScenarioDescription2;

var(TO_Scenario)	string		SF_Objective1;					// Counter Terrorists objectives
var(TO_Scenario)	string		SF_Objective2;
var(TO_Scenario)	string		SF_Objective3;
var(TO_Scenario)	string		SF_Objective4;

var(TO_Scenario)	string		Terr_Objective1;				// Terrorists objectives
var(TO_Scenario)	string		Terr_Objective2;
var(TO_Scenario)	string		Terr_Objective3;
var(TO_Scenario)	string		Terr_Objective4;

var(TO_Scenario)	Texture		ObjShot1;
var(TO_Scenario)	Texture		ObjShot2;
var(TO_Scenario)	Texture		ObjShot3;
var(TO_Scenario)	Texture		ObjShot4;

var(TO_Settings)	byte			MaxEvidence;						// Max number of Evidence to spawn

var(TO_Settings)	bool			bShowDefaultWinMessages;
var(TO_Settings)	bool			bSFAttitudeOffensive;
var(TO_Settings)	bool			bTerrAttitudeOffensive;
var(TO_Settings)	float			LeaderThreshold;
var(TO_Settings)	ETeams		DefaultLooser;					// If round ends by timelimit
var(TO_Settings)	string		DefaultLooseMessage;
var(TO_Settings)	int				WinAmount;


var(TO_Settings)	name			EventBeginRound;
var(TO_Settings)	name			EventEndRound;

enum EObjectiveType
{
	O_DoNothing,							// Wait
	O_GoHome,									// Go to random home base s_ZoneControlPoint (bHomeBase)
	O_AssaultEnemy,						// Go to random Enemy home base s_ZoneControlPoint (bHomeBase)
	O_FindClosestBuyPoint,		// Go to nearest s_ZoneControlPoint (bBuyZone)
	O_SeekForHostages,				// Go to nearest Target and follow path, Then Brings back hostages to home base and 'lock' them
	O_GotoLocation,						// Go to nearest Target and follow path (s_SWATPathNode)
	O_TriggerTarget,					// Go to Target and trigger it
	O_CollectSpecialItem,			// Go to SpecialItem and pick it (Cocaine, ..) (s_SpecialItemStartPoint)
	O_Escape,									// Go to nearest s_ZoneControlPoint (bEscapeZone)
	O_CollectEvidence,				// Go to Evidence and pick it up.
	O_C4TargetLocation,				// Go to Target and drop C4 in Location
	O_ActivateTO_ConsoleTimer, // Go to ConsoleTimer and activate it.
//	O_C4TargetMover,					// Go to Target and stick C4 on mover
};

// In Order means the objective is accomplished by the bots only if all previous Objectives have been
// accomplished (except for OP_Always objectives)
enum EObjectivePriority
{
	OP_None,									// Never done
	OP_Always,								// accomplished several times, no order, doesn't interfere with round wining.
	OP_AlwaysPrioritary,			// accomplished several times, no order and is vital to win the round.	
	OP_AlwaysOrder,						// accomplished several times in Order, doesn't interfere with round wining.
	OP_AlwaysOrderPrioritary,	// accomplished several times in Order and is vital to win the round.	
	OP_Once,									// accomplished once, no order, doesn't interfere with round wining.
	OP_OncePrioritary,				// accomplished once and is vital to win the round.
	OP_OnceOrder,							// accomplished once in Order, doesn't interfere with round wining.
	OP_OnceOrderPrioritary,		// accomplished once in Order and is vital to win the round.
};

/*
// When the objective is complete
enum EObjectiveMeaning
{
	OM_Nothing,								// Nothing happens
	OM_TeamNotification,			// Send a notification to whole team
	OM_GameNotification,			// Send a notification to every player
	OM_RoundWin,							// Round is won 
};
*/

// Public Objective Structure
struct s_ObjectivePub
{
	var() EObjectivePriority	ObjectivePriority;						
	var() EObjectiveType			ObjectiveType;
	var()	Name								Target;
//	var()	EObjectiveMeaning		ObjectiveMeaning;
	var()	name								EventAccomplished;		// Trigger matching actors when accomplished
	var()	bool								bWinRound;						// Shortcut to win the round
	var()	bool								bToggle;							// Objective can be toggled?
	var()	bool								bToggleTo;						// If toggable, then must we make it accomplished or not?
};

// Private Objective Structure
struct s_ObjectivePriv
{
	var		Actor								ActorTarget;
	var		Pawn								Leader;							// Leader bot that will work on that objective (for Once only objectives)
	var		bool								bObjectiveAccomplished;
};

var(TO_Objectives)		s_ObjectivePub		SF_Objectives[10];
var(TO_Objectives)		s_ObjectivePub		Terr_Objectives[10];				
var										s_ObjectivePriv		SF_ObjectivesPriv[10];
var										s_ObjectivePriv		Terr_ObjectivesPriv[10];				


///////////////////////////////////////
// PostBeginPlay 
///////////////////////////////////////

function PostBeginPlay()
{
	Super.PostBeginPlay();

	if (Level.NetMode == NM_Client)
		return;

	if ( (Level.Game != None) && Level.Game.IsA('s_SWATGame') )
		s_SWATGame(Level.Game).SI = Self;
	else
		log("TO_ScenarioInfo - PostBeginPlay - Couldn't register class");
}


///////////////////////////////////////
// PreBeginPlay 
///////////////////////////////////////

function PreBeginPlay()
{
	local	byte		i;
	local	Actor	Act;

	Super.PreBeginPlay();

	if (Level.NetMode == NM_Client)
		return;

	foreach AllActors(class 'Actor', Act)
	{
		//SF_Objectives[i].ActorTarget, SF_Objectives[i].Target)
		for (i = 0; i < 10; i++)
		{
			if (SF_Objectives[i].Target != '' && SF_Objectives[i].Target == Act.Tag)
				SF_ObjectivesPriv[i].ActorTarget = Act;

			if (Terr_Objectives[i].Target != '' && Terr_Objectives[i].Target == Act.Tag)
				Terr_ObjectivesPriv[i].ActorTarget = Act;
		}
	}
}


///////////////////////////////////////
// GetTeamObjectivePub
///////////////////////////////////////

function s_ObjectivePub GetTeamObjectivePub(byte Team, byte num)
{
	if (Team == 1)
		return (SF_Objectives[num]);
	else
		return (Terr_Objectives[num]);
}


///////////////////////////////////////
// GetTeamObjectivePriv
///////////////////////////////////////

function s_ObjectivePriv GetTeamObjectivePriv(byte Team, byte num)
{
	if (Team == 1)
		return (SF_ObjectivesPriv[num]);
	else
		return (Terr_ObjectivesPriv[num]);
}


///////////////////////////////////////
// GetTeamObjectiveName
///////////////////////////////////////

function name GetTeamObjectiveName(byte Team, byte num)
{
	local	EObjectiveType	Obj;

	if (Team == 1)
		Obj = SF_Objectives[num].ObjectiveType;
	else
		Obj = Terr_Objectives[num].ObjectiveType;

	switch (Obj)
	{
		case 	O_DoNothing						: return 'O_DoNothing';	break;			
		case	O_GoHome							:	return 'O_GoHome'; 		break;					
		case	O_AssaultEnemy				:	return 'O_AssaultEnemy';	break;				
		case	O_FindClosestBuyPoint	:	return 'O_FindClosestBuyPoint'; break;
		case	O_SeekForHostages			:	return 'O_SeekForHostages';		break;
		case	O_GotoLocation				: return 'O_GotoLocation';		break;			
		case	O_TriggerTarget				: return 'O_TriggerTarget';		break;
		case	O_CollectSpecialItem	:	return 'O_CollectSpecialItem';	break;
		case	O_Escape							:	return 'O_Escape';	break;
		case	O_CollectEvidence			:	return 'O_CollectEvidence';	break;
		case	O_C4TargetLocation		:	return 'O_C4TargetLocation'; break;
		case	O_ActivateTO_ConsoleTimer : return 'O_ActivateTO_ConsoleTimer'; break;
	}
	return 'O_DoNothing';
}

 
///////////////////////////////////////
// SetObjectiveLeader
///////////////////////////////////////

function SetObjectiveLeader(byte Team, byte num, Pawn Bot)
{
	if (Team == 1)
		SF_ObjectivesPriv[num].Leader = Bot;
	else
		Terr_ObjectivesPriv[num].Leader = Bot;
}


///////////////////////////////////////
// SetAccomplishedObjective
///////////////////////////////////////

function SetAccomplishedObjective(byte Team, byte num, bool bVal)
{
	if (Team == 1)
		SF_ObjectivesPriv[num].bObjectiveAccomplished = bVal;
	else
		Terr_ObjectivesPriv[num].bObjectiveAccomplished = bVal;
}


///////////////////////////////////////
// SetTeamObjTypeName
///////////////////////////////////////

function SetTeamObjTypeName(byte Team, byte num, name ObjName)
{
	local	EObjectiveType	Obj;

	Obj = O_DoNothing;
	switch (ObjName)
	{
		case 	'O_DoNothing'						: Obj = O_DoNothing;	break;			
		case	'O_GoHome'							:	Obj = O_GoHome; 		break;					
		case	'O_AssaultEnemy'				:	Obj = O_AssaultEnemy;	break;				
		case	'O_FindClosestBuyPoint'	:	Obj = O_FindClosestBuyPoint; break;
		case	'O_SeekForHostages'			:	Obj = O_SeekForHostages;		break;
		case	'O_GotoLocation'				: Obj = O_GotoLocation;		break;			
		case	'O_TriggerTarget'				: Obj = O_TriggerTarget;		break;
		case	'O_CollectSpecialItem'	:	Obj = O_CollectSpecialItem;	break;
		case	'O_Escape'							:	Obj = O_Escape;	break;
		case	'O_CollectEvidence'			:	Obj = O_CollectEvidence;	break;
		case	'O_C4TargetLocation'		:	Obj = O_C4TargetLocation; break;
		case	'O_ActivateTO_ConsoleTimer'	: Obj = O_ActivateTO_ConsoleTimer; break;
	}

	if (Team == 1)
		SF_Objectives[num].ObjectiveType = Obj;
	else
		Terr_Objectives[num].ObjectiveType = Obj;
}

/*
///////////////////////////////////////
// SetTeamObjMeaningName
///////////////////////////////////////

function SetTeamObjMeaningName(byte Team, byte num, name ObjName)
{
	local	EObjectiveMeaning	Obj;

	Obj = OM_Nothing;
	switch (ObjName)
	{
		case 	'OM_Nothing'						: Obj = OM_Nothing;	break;			
		case	'OM_TeamNotification'		:	Obj = OM_TeamNotification; 		break;					
		case	'OM_GameNotification'		:	Obj = OM_GameNotification;	break;				
		case	'OM_RoundWin'						:	Obj = OM_RoundWin; break;
	}

	if (Team == 1)
		SF_Objectives[num].ObjectiveMeaning = Obj;
	else
		Terr_Objectives[num].ObjectiveMeaning = Obj;
}
*/

///////////////////////////////////////
// SetTeamObjPriorityName
///////////////////////////////////////

function SetTeamObjPriorityName(byte Team, byte num, name ObjName)
{
	local	EObjectivePriority	Obj;

	Obj = OP_None;
	switch (ObjName)
	{
		case 	'OP_None'									: Obj = OP_None;	break;			
		case	'OP_Always'								:	Obj = OP_Always; 		break;					
		case	'OP_AlwaysPrioritary'			:	Obj = OP_AlwaysPrioritary;	break;				
		case	'OP_AlwaysOrder'					:	Obj = OP_AlwaysOrder; break;
		case	'OP_AlwaysOrderPrioritary':	Obj = OP_AlwaysOrderPrioritary;		break;
		case	'OP_Once'									: Obj = OP_Once;		break;			
		case	'OP_OncePrioritary'				: Obj = OP_OncePrioritary;		break;
		case	'OP_OnceOrder'						:	Obj = OP_OnceOrder;	break;
		case	'OP_OnceOrderPrioritary'	:	Obj = OP_OnceOrderPrioritary;	break;
	}

	if (Team == 1)
		SF_Objectives[num].ObjectivePriority = Obj;
	else
		Terr_Objectives[num].ObjectivePriority = Obj;
}


///////////////////////////////////////
// defaultproperties 
///////////////////////////////////////

defaultproperties
{
     MaxEvidence=8
     bShowDefaultWinMessages=True
     bSFAttitudeOffensive=True
     bTerrAttitudeOffensive=True
     LeaderThreshold=0.300000
     DefaultLooseMessage="DRAW Game"
     WinAmount=1000
     Texture=Texture'TODatas.Engine.SWATLevelInfo'
}
