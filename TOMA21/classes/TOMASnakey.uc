class TOMASnakey extends TOMAChrek;

function ForceMeshToExist()
{
	Spawn(class'TOMASnakeyp');
}

defaultproperties
{
    NameOfMonster="Snakey"
    mesh=LodMesh'TOMAModels21.snakey'
	sshot1="TOMATex21.Sshot.Snakey"
	skin=None
	Texture=None
	MultiSkins(0)=texture'TOMATex21.Skins.JSnakey_04'
	MultiSkins(1)=Texture'TOMATex21.Skins.JSnakey_01'
	MultiSkins(2)=Texture'TOMATex21.Skins.JSnakey_02'
	MultiSkins(3)=texture'TOMATex21.Skins.JSnakey_01'
}

