class TOST_C4Lazer extends TOST_C4;

defaultproperties
{
    ExplosiveC4Class=Class'TOST_ExplosiveC4Lazer'
    price=700
    WeaponDescription="Classification: C4 w/ Laser Detonator"
    PickupMessage="You picked up a Laser C4 !"
    ItemName="Laser C4"

	MultiSkins(1)=texture'TOSTScreen'
	PlayerViewMesh=SkeletalMesh'TOModels.C4mesh'
    PickupViewMesh=LodMesh'TOSTC4P'
    ThirdPersonMesh=LodMesh'TOSTC43l'
    Mesh=LodMesh'TOSTC4P'

	SolidTex=texture'LazerC4Solid'
	TransTex=texture'C4Trans'

	PlayerViewSkin=texture'TOSTC4PRed'
	WorldViewSkin=texture'TOSTC4WRed'
}

