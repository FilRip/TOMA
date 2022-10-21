//=============================================================================
// TO_RoundTimedTrigger
//=============================================================================
//
// Tactical Ops
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen
//=============================================================================
// Actor that triggers other actors depending on time (relative to current round).

class TO_RoundTimedTrigger extends TacticalOpsMapActors;

var()	bool	bRelativeToRoundBegining;
var()	float	RelativeTime;

var		s_SWATGame	SG;	
var		s_GameReplicationInfo	GRI;


///////////////////////////////////////
// PostBeginPlay 
///////////////////////////////////////

function PostBeginPlay() 
{
	Super.PostBeginPlay();

	if ( Role != Role_Authority )
		return;

	SG = s_SWATGame(Level.Game);
	if ( SG != None )
		GRI = s_GameReplicationInfo(SG.GameReplicationInfo);

	//log("TO_RoundTimedTrigger::BeginPlay - SG:"@SG);
	Enable('Timer');

	SetTimer(0.5, true);
}


///////////////////////////////////////
// Timer 
///////////////////////////////////////

function Timer() 
{
//	local	s_SWATGame	SG;
	local	Actor	A;
	
	if ( (Role < Role_Authority) || !IsRoundPeriodPlaying() || (GRI == None) )
	{
//		log("TO_RoundTimedTrigger::Timer - QUIT! - 1:"@(Role < Role_Authority)@"- 2:"@!IsRoundPeriodPlaying()@"- 3:"@(GRI == None));
		return;
	}

	if ( bRelativeToRoundBegining )
	{
//		log("TO_RoundTimedTrigger::Timer - RS-RT:"@(SG.RoundStarted - SG.RemainingTime)@" - RL:"@RelativeTime);

		if ( (GRI.RoundStarted - GRI.RemainingTime) >= RelativeTime )
		{
			Disable('Timer');	
			// Broadcast the Trigger message to all matching actors.
			if ( Event != '' )
				foreach AllActors( class 'Actor', A, Event )
				{
//					log("TO_RoundTimedTrigger::Timer - bRelativeToRoundBegining - RelativeTime:"@RelativeTime@"- RS:"@GRI.RoundStarted@"- RT:"@GRI.RemainingTime@"- RD:"@GRI.RoundDuration@"- Broadcast to:"@A@" Tag:"@A.Tag);
					A.Trigger( Self, None );
				}
		}
	}
	else
	{
//		log("TO_RoundTimedTrigger::Timer - RS-RT:"@(SG.RoundStarted - SG.RemainingTime)@" - RD-RL:"@(SG.RoundDuration * 60 - RelativeTime));

		if ( (GRI.RoundStarted - GRI.RemainingTime) >= (GRI.RoundDuration * 60 - RelativeTime) )
		{
//			log("TO_RoundTimedTrigger::Timer - !bRelativeToRoundBegining - About to broadcast message");
			Disable('Timer');
			if ( Event != '' )
				foreach AllActors( class 'Actor', A, Event )
				{
					A.Trigger( Self, None );
//					log("TO_RoundTimedTrigger::Timer - !bRelativeToRoundBegining - RelativeTime:"@RelativeTime@"- RS:"@GRI.RoundStarted@"- RT:"@GRI.RemainingTime@"- RD:"@GRI.RoundDuration@"- Broadcast to:"@A@" Tag:"@A.Tag);						
				}
		}
	}

}
// RoundStarted - RemainingTime >= RoundDuration * 60
// GRI.RoundDuration * 60 - (GRI.RoundStarted - GRI.Remainingtime);

///////////////////////////////////////
// RoundReset 
///////////////////////////////////////

function RoundReset()
{
	//log("TO_RoundTimedTrigger::RoundReset");
	//Disable('Timer');
	Enable('Timer');

	SetTimer(0.5, true);
}


///////////////////////////////////////
// defaultproperties 
///////////////////////////////////////

defaultproperties
{
     bRelativeToRoundBegining=True
     RelativeTime=1.000000
     bStatic=False
     bStasis=False
}
