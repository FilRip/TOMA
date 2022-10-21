class TOST_C4Timer extends TOST_C4;

defaultproperties
{
	NadeModeEnabled=true

    ExplosiveC4Class=Class'TOST_ExplosiveC4Timer'
    price=800
    WeaponDescription="Classification: C4 w/ Timer Detonator"
    PickupMessage="You picked up a C4 Timer !"
    ItemName="Timer C4"
	NadeMode=1
	MinNadeMode=0
	MaxNadeMode=2

	MultiSkins(1)=texture'TOSTScreen'
	PlayerViewMesh=SkeletalMesh'TOModels.C4mesh'
    PickupViewMesh=LodMesh'TOSTC4P'
    ThirdPersonMesh=LodMesh'TOSTC43'
    Mesh=LodMesh'TOSTC4P'

	SolidTex=texture'TimerC4Solid'
	TransTex=texture'C4Trans'

	PlayerViewSkin=texture'TOSTC4PBlue'
	WorldViewSkin=texture'TOSTC4WBlue'
}

