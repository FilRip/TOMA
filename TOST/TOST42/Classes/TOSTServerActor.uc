//----------------------------------------------------------------------------
// Project : TOST
// File    : TOSTServerActor.uc
// Version : 1.0
// Author  : BugBunny
//----------------------------------------------------------------------------
// Version	Changes
// 0.5		+ first release
// 0.6		+ first beta release
// 1.0		+ first public release
//----------------------------------------------------------------------------

class TOSTServerActor expands Info config;

var() config string	Mutators[10];
var() config bool DisableTOST;

function BeginPlay()
{
	local TOSTServerMutator TSM;
	local class<Mutator>	M;
	local int				i;

	Super.PostBeginPlay();

	for (i=0; i<10; i++)
	{
		if (Mutators[i]!="")
		{
			M = class<Mutator>(DynamicLoadObject(Mutators[i], class'Class', true));
			log("Add mutator "$Mutators[i]);
			Level.Game.BaseMutator.AddMutator(Level.Game.Spawn(M));
		}
	}

	SaveConfig();

	if (DisableTOST)
		return;

	// Make sure it wasn't added as a mutator
	foreach AllActors(class 'TOSTServerMutator', TSM)
	{
		return;
	}
	TSM = Level.Spawn(Class'TOSTServerMutator');
	TSM.NextMutator = Level.Game.BaseMutator;
	TSM.SA = self;
	Level.Game.BaseMutator = TSM;
}

function ChangeMutatorEntry(int No, string MutatorCall)
{
	if (No >= 0 && No < 10)
		Mutators[No] = MutatorCall;
	SaveConfig();
}

defaultproperties
{
	bHidden=True
	DisableTOST=False
	Mutators(0)=""
	Mutators(1)=""
	Mutators(2)=""
	Mutators(3)=""
	Mutators(4)=""
	Mutators(5)=""
	Mutators(6)=""
	Mutators(7)=""
	Mutators(8)=""
	Mutators(9)=""
}

