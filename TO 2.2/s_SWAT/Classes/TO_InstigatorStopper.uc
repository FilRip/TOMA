//=============================================================================
// TO_InstigatorStopper.
//=============================================================================
// The trigger event received will be passed to actors matching the Event field
// and but not the instigator actor.
//=============================================================================
// Created by Mathieu 'EMH_Mark3' Mallet for Tactical Ops
//=============================================================================

class TO_InstigatorStopper expands TO_Logic;

function Trigger( actor Other, pawn EventInstigator )
{
	local	Actor	A;
	if( Event != '' )
		foreach AllActors( class 'Actor', A, Event)
			A.Trigger( Other, None );
}

defaultproperties
{
}
