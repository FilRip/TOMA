// Decal base class for TOTag mutator

class TOTAGModel extends Actor;

var texture desiredtexture;

defaultproperties
{
    DrawType=DT_Mesh
    Mesh=LodMesh'Botpack.FlatMirror'
    bHidden=false
    Physics=PHYS_Flying
    CollisionHeight=1
    CollisionRadius=1
	bCollideWorld=False
	Style=STY_Normal
	DrawScale=0.25
}

