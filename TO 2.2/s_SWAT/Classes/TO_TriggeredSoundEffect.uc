//=============================================================================
// TO_TriggeredSoundEffect.
//=============================================================================
class TO_TriggeredSoundEffect expands Keypoint;

var()   sound    Sound;    	// What to play
var()	float	 Volume;	// Volume percentage
var()	float	 Radius;	// Sound range (in unreal units)
var()	float	 Pitch;		// Sound pitch (1.0 = normal pitch)


function Trigger( actor Other, pawn EventInstigator )
{
	PlaySound(Sound, Slot_None, Volume, , Radius, Pitch);
}

defaultproperties
{
     Volume=1.000000
     Radius=4096.000000
     Pitch=1.000000
}
