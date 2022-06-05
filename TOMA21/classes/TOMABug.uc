class TOMABug extends TOMAChrek;

function ForceMeshToExist()
{
	Spawn(class'TOMAbugp');
}

defaultproperties
{
    NameOfMonster="Bug"
    Mesh=LodMesh'TOMAModels21.bug'
	sshot1="TOMATex21.Sshot.Bug"
	skin=None
}

