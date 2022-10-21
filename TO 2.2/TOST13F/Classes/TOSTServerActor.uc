//----------------------------------------------------------------------------
// Project : TOST
// File    : TOSTServerActor.uc
// Version : 1.2
// Author  : BugBunny
//----------------------------------------------------------------------------

class TOSTServerActor expands Info;

function BeginPlay()
{
	local TOSTServerMutator zzTSM;

	Super.PostBeginPlay();

	// Make sure it wasn't added as a mutator
	
	foreach AllActors(class 'TOSTServerMutator', zzTSM)
	{
		return;
	}

	zzTSM = Level.Spawn(Class'TOSTServerMutator');
	zzTSM.NextMutator = Level.Game.BaseMutator;
	Level.Game.BaseMutator = zzTSM;
}