//=============================================================================
// TO_SetMoverKeyframe.
//=============================================================================
// When triggered, interpolate the mover matching this actor's event field
// to a specified keyframe. Does not work well when going 'backwards' (e.g.
// from key 3 to key 2)
//=============================================================================
// Created by Mathieu 'EMH_Mark3' Mallet for Tactical Ops
//=============================================================================

class TO_SetMoverKeyframe expands TO_Logic;

var()	int		Keyframe;
var()	float	MoveTime;

function Trigger( actor Other, pawn EventInstigator ) {
		local actor	A;

		if (Event != '')
			foreach AllActors( class 'Actor', A, Event)
				if (Mover(A) != None)
					Mover(A).InterpolateTo(Keyframe, MoveTime);

}

defaultproperties
{
     Keyframe=1
     MoveTime=1.000000
}
