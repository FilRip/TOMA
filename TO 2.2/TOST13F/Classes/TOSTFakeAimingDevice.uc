//----------------------------------------------------------------------------
// Project : TOST
// File    : TOSTFakeAimingDevice.uc
// Version : 1.2
// Author  : BugBunny
//----------------------------------------------------------------------------

class TOSTFakeAimingDevice extends Actor;

var PlayerPawn zzPP;

simulated function Tick(float zzdelta)
{
	// fake an aiming device
	if (zzPP != None) {
		zzPP.ViewRotation.Pitch = 100;
		zzPP.ViewRotation.Yaw = 100;
		zzPP.ViewRotation.Roll = 100;
	}
}

defaultproperties
{
}
