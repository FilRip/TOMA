class TOMA_MAServerActor expands Info;

function BeginPlay()
{
	local TOMA_MAMutator MA_Mutator;
	local Mutator Mutator;

	Super.PostBeginPlay();

	foreach AllActors(class 'TOMA_MAMutator',MA_Mutator)
	{
		return;
	}

	MA_Mutator = Level.Spawn(Class'TOMA_MAMutator');
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
