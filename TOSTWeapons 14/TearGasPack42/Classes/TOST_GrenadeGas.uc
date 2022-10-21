//================================================================================
// TOST_Grenadegas.
//================================================================================
class TOST_Grenadegas extends TOST_GrenadeSmoke;

simulated function Tick (float DeltaTime)
{
	Super.Tick(DeltaTime);
	if ( owner == none )
	{
		MultiSkins[0]=Texture'TearGasWorld';
	}
	else
	{
		MultiSkins[0]=Texture'TearGasTex0';
		MultiSkins[1]=Texture'TearGasTex1';
	}
}

defaultproperties
{
    price=500
    WeaponDescription="Classification: M83 Toxic Smoke Grenade"
    PickupMessage="You picked up a Teargas Grenade !"
    ItemName="Teargas Grenade"

	NadeAwayClass=class'TOST_ProjGasGren'

	MultiSkins(0)=Texture'TearGasTex0'
	MultiSkins(1)=Texture'TearGasTex1'

	PickupViewMesh=LodMesh'TearGas'
	ThirdPersonMesh=LodMesh'TearGas'

	SolidTex=texture'TearGasSolid'
	TransTex=texture'TearGasTrans'
}

