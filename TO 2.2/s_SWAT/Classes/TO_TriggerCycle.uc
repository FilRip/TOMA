//=============================================================================
// TO_TriggerCycle.
//=============================================================================
// When triggered, the trigger message will be sent to the first actor in the
// event list. When triggered again, the trigger message will be sent to the
// second actor in the event list and so on.
//=============================================================================
// Created by Mathieu 'EMH_Mark3' Mallet for Tactical Ops
//=============================================================================

class TO_TriggerCycle expands TO_Logic;

var() name  Events[8];      		// What events to call (must be at least one event)
var int		numEvents;
var	int		curEvent;

function BeginPlay () {
	local int i;
	curEvent = 0; 

	// Calculate how many events the user specified
	numEvents=8;
	for (i=0; i<8; i++) {
		if (Events[i] == '') {
			numEvents=i;
			log("TriggerCycle: Number of events:");
			log(i);
			break;
		}
	}
}

auto state() IsResetableActor {

	function Trigger( actor Other, pawn EventInstigator )
	{
		local actor A;

		// Broadcast the Trigger message to all matching actors.
		if( Events[curEvent] != '' )
			foreach AllActors( class 'Actor', A, Events[curEvent] )
				A.Trigger( Other, EventInstigator );

		curEvent = (curEvent + 1) % numEvents;

	}

}

defaultproperties
{
     InitialState=IsResetableActor
}
