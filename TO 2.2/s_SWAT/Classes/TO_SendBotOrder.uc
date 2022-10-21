//=============================================================================
// TO_SendBotOrder
//=============================================================================
//
// Tactical Ops
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen
//=============================================================================
// Actor which can be triggered send an order to the bots
// can be used for example to bring a whole team to a specific location
// NOTE: Currently only supports only 1 target
// NOTE: Some objectives can find a random target if set to NONE, refer to TO_MappingDoc.txt to find out more

class TO_SendBotOrder extends TacticalOpsMapActors;

var()	ETeams	SendTo;
var() name		Target;
var()	name		ObjectiveType;
var()	bool		bLeadersOnly;
var()	float		DesiredAssignment;

var	Actor	ActorTarget;


///////////////////////////////////////
// PreBeginPlay 
///////////////////////////////////////

function PreBeginPlay()
{
	local	Actor	A;

	if ( Target != '' )
	{
		foreach AllActors(class'Actor', A)
			if ( A.Tag == Target )
			{
				ActorTarget = A;
				break;
			}
	}
	
	Super.PreBeginPlay();
}


///////////////////////////////////////
// Trigger 
///////////////////////////////////////

function Trigger( actor Other, pawn EventInstigator )
{
	local	s_SWATGame		SG;
	local	byte					team;
	local	Actor					A;

	SG = s_SWATGame(Level.Game);

	if (SG == None)
	{
		log("TO_SendBotOrder::Trigger - SG == None");
		return;
	}
	
	if ( !IsRoundPeriodPlaying() )
		return;

	// Broadcast the Trigger message to all matching actors.
	if( Event != '' )
		foreach AllActors( class 'Actor', A, Event )
			A.Trigger( Other, EventInstigator );

	team = SendTo;
	SG.SendGlobalBotObjective( ActorTarget, DesiredAssignment, team, ObjectiveType, bLeadersOnly);
}


///////////////////////////////////////
// defaultproperties 
///////////////////////////////////////

defaultproperties
{
     ObjectiveType='
     DesiredAssignment=0.500000
}
