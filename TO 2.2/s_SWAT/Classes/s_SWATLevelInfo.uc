// Obsolete - Use TO_ScenarioInfo instead

class s_SWATLevelInfo extends NavigationPoint;

var(TO_Scenario)	string		ScenarioName;
var(TO_Scenario)	string		ScenarioComment1;							// Scenario
var(TO_Scenario)	string		ScenarioComment2;

var(TO_Scenario)	string		CT_Mission1;									// Counter Terrorists objectives
var(TO_Scenario)	string		CT_Mission2;
var(TO_Scenario)	string		CT_Mission3;
var(TO_Scenario)	string		CT_Mission4;

var(TO_Scenario)	string		Terr_Mission1;								// Terrorists objectives
var(TO_Scenario)	string		Terr_Mission2;
var(TO_Scenario)	string		Terr_Mission3;
var(TO_Scenario)	string		Terr_Mission4;

var(Obsolete)			bool			bAllHostagesRescuedEndRound;	// USELESS !! All hostage rescued -> end round
var(Obsolete)			bool			bHostageRescueObjective;			// USELESS !! if last objective -> end round

var(TO_Rules)			int				MaxEvidence;									// Max number of Evidence to spawn


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

// When the objective is complete
enum EObjectiveMeaning
{
	OM_Nothing,								// Nothing happens
	OM_TeamNotification,			// Send a notification to whole team
	OM_GameNotification,			// Send a notification to every player
	OM_RoundWin,							// Round is won 
};

struct s_Objective
{
	var() EObjectivePriority	ObjectivePriority;
	var() EObjectiveType			ObjectiveType;
	var()	Name								Target;
	var()	EObjectiveMeaning		ObjectiveMeaning;
	var		Actor								ActorTarget;
	
	var		Pawn								Leader;							// Leader bot that will work on that objective (for Once only objectives)

	var		bool								bObjectiveAccomplished;
//	var()	bool								bObjectiveAccomplishedToggle;
};

var(TO_Objectives)		s_Objective			SWAT_Objectives[10];
var(TO_Objectives)		s_Objective			Terr_Objectives[10];				


///////////////////////////////////////
// PreBeginPlay 
///////////////////////////////////////

function PreBeginPlay()
{
	local	int		i;
	local	Actor	Act;

	Super.PreBeginPlay();

	foreach AllActors(class 'Actor', Act)
	{
		//SWAT_Objectives[i].ActorTarget, SWAT_Objectives[i].Target)
		for (i = 0; i < 10; i++)
		{
			if (SWAT_Objectives[i].Target != '' && SWAT_Objectives[i].Target == Act.Tag)
				SWAT_Objectives[i].ActorTarget = Act;

			if (Terr_Objectives[i].Target != '' && Terr_Objectives[i].Target == Act.Tag)
				Terr_Objectives[i].ActorTarget = Act;
		}
	}
}


///////////////////////////////////////
// PostBeginPlay 
///////////////////////////////////////

function PostBeginPlay()
{
	Super.PostBeginPlay();

	// Convert class to TO_ScenarioInfo instead
//	if (Level.Game.IsA('s_SWATGame'))
//		s_SWATGame(Level.Game).SWATLevelInfo = Self;
	ConvertActor();
	destroy();
}


///////////////////////////////////////
// ConvertActor 
///////////////////////////////////////
// Convert s_SWATLevelInfo

function ConvertActor()
{
	local	TO_ScenarioInfoInternal	SI;
	local	int		i;

	SI = Spawn(class's_SWAT.TO_ScenarioInfoInternal',,, Location);

	if ( SI != None )
	{
		SI.ConvertActor(Self);

/*		SI.ScenarioName = ScenarioName;
		SI.ScenarioDescription1 = ScenarioComment1;				
		SI.ScenarioDescription2 = ScenarioComment2;

		SI.SF_Objective1 = CT_Mission1;					
		SI.SF_Objective2 = CT_Mission2;
		SI.SF_Objective3 = CT_Mission3;
		SI.SF_Objective4 = CT_Mission4;

		SI.Terr_Objective1 = Terr_Mission1;				
		SI.Terr_Objective2 = Terr_Mission2;
		SI.Terr_Objective3 = Terr_Mission3;
		SI.Terr_Objective4 = Terr_Mission4;

		SI.MaxEvidence = MaxEvidence;			

		for (i=0; i < 10; i++)
		{
			SI.SetTeamObjPriorityName(1, i, GetTeamObjPriorityName(1, i) );
			SI.SetTeamObjTypeName(1, i, GetTeamObjectiveName(1, i) );
			SI.SetTeamObjMeaningName(1, i, GetObjectiveMeaningName(1, i) );
			SI.SF_Objectives[i].Target = SWAT_Objectives[i].Target;
			SI.SF_ObjectivesPriv[i].ActorTarget = SWAT_Objectives[i].ActorTarget;

			SI.SetTeamObjPriorityName(0, i, GetTeamObjPriorityName(0, i) );
			SI.SetTeamObjTypeName(0, i, GetTeamObjectiveName(0, i) );
			SI.SetTeamObjMeaningName(0, i, GetObjectiveMeaningName(0, i) );
			SI.Terr_Objectives[i].Target = Terr_Objectives[i].Target;
			SI.Terr_ObjectivesPriv[i].ActorTarget = Terr_Objectives[i].ActorTarget;
		}
*/
	}
	else
		log("s_SWATLevelInfo - ConvertActor - SI == None");
}


///////////////////////////////////////
// GetTeamObjective
///////////////////////////////////////

function s_Objective GetTeamObjective(int Team, int num)
{
	if (Team == 1)
		return (SWAT_Objectives[num]);
	else
		return (Terr_Objectives[num]);
}


///////////////////////////////////////
// GetTeamObjectiveName
///////////////////////////////////////

function name GetTeamObjectiveName(int Team, int num)
{
	local	EObjectiveType	Obj;

	if (Team == 1)
		Obj = SWAT_Objectives[num].ObjectiveType;
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
	}
	return 'O_DoNothing';
}


///////////////////////////////////////
// GetObjectiveMeaningName
///////////////////////////////////////

function name GetObjectiveMeaningName(int Team, int num)
{
	local	EObjectiveMeaning	Obj;

	if (Team == 1)
		Obj = SWAT_Objectives[num].ObjectiveMeaning;
	else
		Obj = Terr_Objectives[num].ObjectiveMeaning;

	switch (Obj)
	{
		case 	OM_Nothing						: return 'OM_Nothing';	break;			
		case	OM_TeamNotification		:	return 'OM_TeamNotification'; 		break;					
		case	OM_GameNotification		:	return 'OM_GameNotification';	break;				
		case	OM_RoundWin						:	return 'OM_RoundWin'; break;
	}
	return 'OM_Nothing';
}


///////////////////////////////////////
// GetTeamObjPriorityName
///////////////////////////////////////

function name GetTeamObjPriorityName(int Team, int num)
{
	local	EObjectivePriority	Obj;

	if (Team == 1)
		Obj = SWAT_Objectives[num].ObjectivePriority;
	else
		Obj = Terr_Objectives[num].ObjectivePriority;

	switch (Obj)
	{
		case 	OP_None										: return 'OP_None';	break;			
		case	OP_Always									:	return 'OP_Always'; 		break;					
		case	OP_AlwaysPrioritary				:	return 'OP_AlwaysPrioritary';	break;				
		case	OP_AlwaysOrder						:	return 'OP_AlwaysOrder'; break;
		case	OP_AlwaysOrderPrioritary	:	return 'OP_AlwaysOrderPrioritary';		break;
		case	OP_Once										: return 'OP_Once';		break;			
		case	OP_OncePrioritary					: return 'OP_OncePrioritary';		break;
		case	OP_OnceOrder							:	return 'OP_OnceOrder';	break;
		case	OP_OnceOrderPrioritary		:	return 'OP_OnceOrderPrioritary';	break;
	}

	return 'OP_None';
}


///////////////////////////////////////
// SetObjectiveLeader
///////////////////////////////////////

function SetObjectiveLeader(int Team, int num, Pawn Bot)
{
	if (Team == 1)
		SWAT_Objectives[num].Leader = Bot;
	else
		Terr_Objectives[num].Leader = Bot;
}


///////////////////////////////////////
// defaultproperties 
///////////////////////////////////////

//bAllHostagesRescuedEndRound=false
// bStatic=true

defaultproperties
{
     MaxEvidence=8
     Texture=Texture'TODatas.Engine.SWATLevelInfo'
}
