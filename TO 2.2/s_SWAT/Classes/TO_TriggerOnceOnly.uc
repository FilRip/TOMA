//=============================================================================
// TO_TriggerOnceOnly.
//=============================================================================
// Transmit the trigger message, but only once per round.
//=============================================================================
// Created by Mathieu 'EMH_Mark3' Mallet for Tactical Ops
//=============================================================================

class TO_TriggerOnceOnly expands TO_Logic;

var	bool	Triggered;

auto state() IsResetableActor {

	function BeginPlay() {
		Triggered = false;
	}	

	function Trigger( actor Other, pawn EventInstigator ) {
		local	Actor	A;

		if ((Event != '') && !Triggered) {

			foreach AllActors( class 'Actor', A, Event)
				A.Trigger( Other, EventInstigator );
			Triggered = true;

		}

	}

}

defaultproperties
{
     InitialState=IsResetableActor
}
