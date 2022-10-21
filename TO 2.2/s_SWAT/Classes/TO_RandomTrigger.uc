//=============================================================================
// TO_RandomTrigger.
//=============================================================================
// When triggered, send a trigger message to one of the actors who's tag is in
// this actor's Events field.
//=============================================================================
// Created by Mathieu 'EMH_Mark3' Mallet for Tactical Ops
//=============================================================================

class TO_RandomTrigger expands TO_Logic;

var() name  Events[8];      		// What events to call (must be at least one event)
var int		numEvents;

function BeginPlay () 
{
	local int i;
	
	// Calculate how many events the user specified
	numEvents=8;
	for (i=0; i<8; i++) {
		if (Events[i] == '') {
			numEvents=i;
			break;
		}
	}
}

function Trigger( actor Other, pawn EventInstigator )
{
	local int i;
	local actor A;

	i = Rand(numEvents);

	// Broadcast the Trigger message to all matching actors.
	if( Events[i] != '' )
		foreach AllActors( class 'Actor', A, Events[i] )
			A.Trigger( Other, EventInstigator );

}

defaultproperties
{
}
