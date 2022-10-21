//----------------------------------------------------------------------------
// Project : TOST
// File    : TOST_GrenadeSmoke.uc
// Version : 0.5
// Author  : BugBunny/Shag
//----------------------------------------------------------------------------
// Version	Changes
// 0.5		+ first release
//----------------------------------------------------------------------------

class TOST_GrenadeSmoke extends TOSTGrenade;

defaultproperties
{
	WeaponDescription="Classification: M83 Non-Toxic Smoke Grenade"
	PickupMessage="You picked up a Smoke Grenade !"
	ItemName="Smoke Grenade"
	PlayerViewOffset=(X=170.000000,Y=190.000000,Z=-270.000000)
	PlayerViewMesh=SkeletalMesh'TOModels.GrensmokeMesh'
	PlayerViewScale=0.12
	Price=450
	PickupViewMesh=LodMesh'TOModels.wgrenadesmoke'
	ThirdPersonMesh=LodMesh'TOModels.wgrenadesmoke'

	NadeAwayClass=class'TOST_ProjSmokeGren'

	SolidTex=texture'TOST4TexSolid.HUD.Smoke'
	TransTex=texture'TOST4TexTrans.HUD.Smoke'
}


