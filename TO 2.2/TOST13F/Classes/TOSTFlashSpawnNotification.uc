//----------------------------------------------------------------------------
// Project : TOST
// File    : TOSTFlashSpawnNotification.uc
// Version : 1.2
// Author  : BugBunny
//----------------------------------------------------------------------------

class TOSTFlashSpawnNotification extends SpawnNotify;

simulated event Actor SpawnNotification(Actor zzA)
{
	local TOSTFlashBang zzFB;

//	if ( Level.NetMode == NM_Client )
//		return zzA;
	zzFB = spawn(class'TOSTFlashBang', zzA.Owner,,zzA.Location, zzA.Rotation);
	zzFB.Instigator = zzA.Instigator;
	zzA.Destroy();	
	
	return zzFB;
}

defaultproperties
{
     ActorClass=Class's_SWAT.s_FlashBang'
}
