class TOPAM expands Mutator;

event PreBeginPlay ()
{
	Log("Add Monsters to PlayerModels - Made by FilRip.");
	SetTimer(2,false);
}

function ModifyLogin(out Class<PlayerPawn> SpawnClass,out string Portal,out string Options)
{
	if (SpawnClass==Class'S_Player_T')
		SpawnClass=Class'TOPAMPlayer';
	if (NextMutator!=None)
		NextMutator.ModifyLogin(SpawnClass,Portal,Options);
}

defaultproperties
{
}
