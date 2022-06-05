class TOMASerpico extends TOMAChrek;

function ForceMeshToExist()
{
	Spawn(class'TOMASerpicop');
}

defaultproperties
{
    NameOfMonster="Serpico"
    mesh=LodMesh'TOMAModels21.serpico'
	sshot1="TOMATex21.Sshot.Serpico"
	skin=None
	texture=none
	MultiSkins(0)=Texture'TOMATex21.Skins.Jserpico_04'
	MultiSkins(1)=Texture'TOMATex21.Skins.Jserpico_01'
	MultiSkins(2)=texture'TOMATex21.Skins.Jserpico_02'
	MultiSkins(3)=Texture'TOMATex21.Skins.Jserpico_01'
}

