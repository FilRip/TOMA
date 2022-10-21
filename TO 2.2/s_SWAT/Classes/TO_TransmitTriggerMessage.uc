//=============================================================================
// TO_TransmitTriggerMessage.
//=============================================================================
// Transmit the trigger message.
//=============================================================================
// Created by Mathieu 'EMH_Mark3' Mallet for Tactical Ops
//=============================================================================

class TO_TransmitTriggerMessage expands TO_Logic;

function Trigger( actor Other, pawn EventInstigator ) {
	local	Actor	A;

	if (Event != '')
		foreach AllActors( class 'Actor', A, Event)
			A.Trigger( Other, EventInstigator);

}

defaultproperties
{
}
