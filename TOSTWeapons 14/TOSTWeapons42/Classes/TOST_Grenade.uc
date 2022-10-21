//----------------------------------------------------------------------------
// Project : TOST
// File    : TOST_Grenade.uc
// Version : 0.5
// Author  : BugBunny/Shag
//----------------------------------------------------------------------------
// Version	Changes
// 0.5		+ first release
// added timer switching
//----------------------------------------------------------------------------

class TOST_Grenade extends TOSTGrenade;

defaultproperties
{
	NadeModeEnabled=true

	WeaponDescription="Classification: High Yield High Explosive Grenade"
	PickupMessage="You picked up a HE Grenade !"
	ItemName="HE Grenade"
	PlayerViewOffset=(X=170.0,Y=190.0,Z=-270.0)
	PlayerViewMesh=SkeletalMesh'TOModels.GrenHEMesh'
	PlayerViewScale=0.12
	PickupViewMesh=LodMesh'TOModels.wgrenadeHE'
	ThirdPersonMesh=LodMesh'TOModels.wgrenadeHE'
	Mesh=LodMesh'TOModels.wgrenadeHE'

	NadeAwayClass=class'TOST_GrenadeAway'

	SolidTex=texture'TOST4TexSolid.HUD.HE'
	TransTex=texture'TOST4TexTrans.HUD.HE'
}

