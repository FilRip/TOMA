class VIPTOMA_ServerActor expands Info;

function BeginPlay()
{
	local VIPTOMA_Mutator MA_Mutator;
	local Mutator Mutator;

	Super.PostBeginPlay();

	foreach AllActors(class 'VIPTOMA_Mutator',MA_Mutator)
	{
		return;
	}

	MA_Mutator = Level.Spawn(Class'VIPTOMA_Mutator');
	Mutator = Level.Game.BaseMutator;

	while( Mutator.NextMutator != None )
	{
		Mutator = Mutator.NextMutator;
	}

	if ( Mutator != None )
	{
		Mutator.NextMutator = MA_Mutator;
	}
	else
	{
		Level.Game.BaseMutator = MA_Mutator;
	}
}
