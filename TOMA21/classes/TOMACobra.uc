class TOMACobra extends TOMAChrek;

function ForceMeshToExist()
{
	Spawn(class'TOMACobrap');
}

defaultproperties
{
    NameOfMonster="Cobra"
    mesh=LodMesh'TOMAModels21.cobra'
	sshot1="TOMATex21.Sshot.cobra"
	skin=Texture'TOMATex21.Skins.cobr1_0'
	texture=None
	Rotation=(Pitch=0,Yaw=32768,Roll=0)
}

