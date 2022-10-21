//=============================================================================
// TO_ScenarioInfoInternal
//=============================================================================
//
// Tactical Ops
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen
//=============================================================================
  
class TO_ScenarioInfoInternal extends TO_ScenarioInfo;


///////////////////////////////////////
// ConvertActor 
///////////////////////////////////////
// Convert s_SWATLevelInfo to TO_ScenarioInfo

final function ConvertActor(s_SWATLevelInfo SWLI)
{
	local	int		i;

	if (SWLI != None)
	{
		ScenarioName = SWLI.ScenarioName;
		ScenarioDescription1 = SWLI.ScenarioComment1;				
		ScenarioDescription2 = SWLI.ScenarioComment2;

		SF_Objective1 = SWLI.CT_Mission1;					
		SF_Objective2 = SWLI.CT_Mission2;
		SF_Objective3 = SWLI.CT_Mission3;
		SF_Objective4 = SWLI.CT_Mission4;

		Terr_Objective1 = SWLI.Terr_Mission1;				
		Terr_Objective2 = SWLI.Terr_Mission2;
		Terr_Objective3 = SWLI.Terr_Mission3;
		Terr_Objective4 = SWLI.Terr_Mission4;

		MaxEvidence = SWLI.MaxEvidence;			

		for (i=0; i < 10; i++)
		{
			SetTeamObjPriorityName(1, i, SWLI.GetTeamObjPriorityName(1, i) );
			SetTeamObjTypeName(1, i, SWLI.GetTeamObjectiveName(1, i) );
			//SetTeamObjMeaningName(1, i, SWLI.GetObjectiveMeaningName(1, i) );
			SF_Objectives[i].Target = SWLI.SWAT_Objectives[i].Target;
			SF_ObjectivesPriv[i].ActorTarget = SWLI.SWAT_Objectives[i].ActorTarget;
			if ( SWLI.GetObjectiveMeaningName(1, i) == 'OM_RoundWin' )
				SF_Objectives[i].bWinRound = true;

			SetTeamObjPriorityName(0, i, SWLI.GetTeamObjPriorityName(0, i) );
			SetTeamObjTypeName(0, i, SWLI.GetTeamObjectiveName(0, i) );
			//SetTeamObjMeaningName(0, i, SWLI.GetObjectiveMeaningName(0, i) );
			Terr_Objectives[i].Target = SWLI.Terr_Objectives[i].Target;
			Terr_ObjectivesPriv[i].ActorTarget = SWLI.Terr_Objectives[i].ActorTarget;
			if ( SWLI.GetObjectiveMeaningName(0, i) == 'OM_RoundWin' )
				Terr_Objectives[i].bWinRound = true;

		}
	}
	else
		log("TO_ScenarioInfoInternal - ConvertActor - SWLI == None");
}


///////////////////////////////////////
// defaultproperties 
///////////////////////////////////////

defaultproperties
{
     bStatic=False
}
