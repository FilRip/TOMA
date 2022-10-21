//=============================================================================
// TO_ConsoleTimer
//=============================================================================
//
// Tactical Ops
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen
//=============================================================================
  
class TO_ConsoleTimer extends TacticalOpsMapActors;
//class TO_ConsoleTimer extends NavigationPoint;

enum EInstigator
{
	EI_Terrorists,	
	EI_SpecialForces,	
	EI_BothTeams,
	EI_OtherActor,
	EI_Any,
};

var()	EInstigator				CanBeActivatedBy;

var()	bool							bCanResumeProgress;
var()	bool							bDisplayProgressBar;
var()	float							CTDuration;
var()	float							CTRadiusRange;
var()	string						CTMessage;

var()	sound							SoundActivated;
var()	sound							SoundFailed;
var()	sound							SoundCompleted;

var(Events) name        EventActivated;
var(Events) name        EventFailed;
var(Events) name        EventCompleted;

var		bool							bActive;
var		bool							bBeingActivated;
var		Actor							instigatedBy;
var		float							Progress, ProgressStart;	

/*
///////////////////////////////////////
// replication
///////////////////////////////////////

replication
{
	// Send to clients
	reliable if ( bNetInitial && (Role == ROLE_Authority) )
		CTMessage, bDisplayProgressBar, CTDuration;
}
*/

///////////////////////////////////////
// IsRevelant 
///////////////////////////////////////

final function bool	IsRevelant(Actor Other)
{
	local	Pawn	P;

	// Anyone
	if ( CanBeActivatedBy == EI_Any )
		return true;

	P = Pawn(Other);

	// Non players
	if ( (P == None) && (CanBeActivatedBy == EI_OtherActor) )
		return true;

	if (P != None)
	{
		if ( CanBeActivatedBy == EI_BothTeams )
			return true;

		if ( (P.PlayerReplicationInfo != None) && (P.PlayerReplicationInfo.Team == CanBeActivatedBy) )
			return true;
	}

	return false;
}


///////////////////////////////////////
// CTActivate 
///////////////////////////////////////
// Activating the device

final function bool CTActivate(Actor Instigator)
{
	local	Actor	A;

	if ( !bActive || bBeingActivated || !IsRevelant(Instigator) )
		return false;

	if ( !IsRoundPeriodPlaying() )
		return false;

	//log("TO_ConsoleTimer::CTActivate");

	instigatedBy = Instigator;
	bActive = false;
	bBeingActivated = true;
	
	if ( bCanResumeProgress )
	{
		ProgressStart = Level.TimeSeconds - Progress;
	}

	if ( SoundActivated != None )
		PlaySound(SoundActivated, SLOT_None, 4.0);

	// Broadcast the Trigger message to all matching actors.
	if (EventActivated != '')
		foreach AllActors(class'Actor', A, EventActivated)
			A.Trigger(instigatedBy, Pawn(instigatedBy) );

	return true;
}


///////////////////////////////////////
// CTFailed 
///////////////////////////////////////
// Failed to use the device [CTDuration] seconds

final function CTFailed()
{
	local	Actor	A;

	//log("TO_ConsoleTimer::CTFailed");

	if ( SoundFailed != None )
		PlaySound(SoundFailed, SLOT_None, 4.0);

	// Broadcast the Trigger message to all matching actors.
	if (EventFailed != '' && IsRoundPeriodPlaying()	)
		foreach AllActors(class'Actor', A, EventFailed)
			A.Trigger(instigatedBy, Pawn(instigatedBy) );

	if ( !bCanResumeProgress )
		Progress = 0.0;
	else
		Progress = Level.TimeSeconds - ProgressStart;

	bActive = true;
	bBeingActivated = false;
}


///////////////////////////////////////
// CTComplete 
///////////////////////////////////////
// activation complete

final function CTComplete()
{
	local	Actor				A;
	local	s_SWATGame	SW;

	//log("TO_ConsoleTimer::CTComplete");

	if ( SoundCompleted != None )
		PlaySound(SoundCompleted, SLOT_None, 4.0);

	// Broadcast the Trigger message to all matching actors.
	if ( (EventCompleted != '') && IsRoundPeriodPlaying() )
		foreach AllActors(class'Actor', A, EventCompleted)
			A.Trigger(instigatedBy, Pawn(instigatedBy) );

	bActive = false;
	bBeingActivated = false;
	Progress = 0.0;

	SW = s_SWATGame(Level.Game);
	if (SW != None)
	{
		SW.ObjectiveAccomplished(Self);
	}
	else 
		log("TO_ConsoleTimer::CTComplete - SW == None");
}


///////////////////////////////////////
// RoundReset 
///////////////////////////////////////

function RoundReset()
{
	Progress = 0.0;
	bActive = true;
	bBeingActivated = false;
}


///////////////////////////////////////
// defaultproperties 
///////////////////////////////////////

defaultproperties
{
     CanBeActivatedBy=EI_Any
     bDisplayProgressBar=True
     CTDuration=10.000000
     CTRadiusRange=100.000000
     CTMessage="Defusing bomb..."
     bActive=True
     CollisionRadius=20.000000
     CollisionHeight=20.000000
     bCollideActors=True
     bBlockActors=True
     bBlockPlayers=True
}
