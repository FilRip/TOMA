//----------------------------------------------------------------------------
// Project : TOST
// File    : TOSTLogSpawnNotify.uc
// Version : 1.0
// Author  : BugBunny
//----------------------------------------------------------------------------
// Version	Changes
// 0.5		+ first release
// 0.6		+ first beta release
// 1.0		+ first public release
//----------------------------------------------------------------------------

class TOSTLogSpawnNotify expands SpawnNotify;

var	TOSTServerMutator	TOST;
var bool				Done;

event Actor SpawnNotification(Actor A)
{
	if (!Done)
	{
		TOST.LogHook.Backup = StatLog(A);
		TOST.LogHook.Backup.bWorld = False;
		TOST.LogHook.Backup.StartLog();
		Destroy();
		Done = True;
		return TOST.LogHook;
	} else {
		return A;
	}
}

defaultproperties
{
	bHidden=True
	ActorClass=Class'StatLog'
}

