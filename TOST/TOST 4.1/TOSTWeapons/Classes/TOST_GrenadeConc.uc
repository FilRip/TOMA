//----------------------------------------------------------------------------
// Project : TOST
// File    : TOST_GrenadeConc.uc
// Version : 0.5
// Author  : BugBunny/Shag
//----------------------------------------------------------------------------
// Version	Changes
// 0.5		+ first release
//----------------------------------------------------------------------------

class TOST_GrenadeConc extends TOSTGrenade;

defaultproperties
{
	Price=300
	WeaponDescription="Classification: Concussion grenade"
	PickupMessage="You picked up a Concussion grenade!"
	ItemName="Concussion Grenade"
	PickupViewMesh=LodMesh'TOModels.wgrenadeconc'
	ThirdPersonMesh=LodMesh'TOModels.wgrenadeconc'
	PlayerViewOffset=(X=170.000000,Y=190.000000,Z=-270.000000)
	PlayerViewMesh=SkeletalMesh'TOModels.GrenconcMesh'
	PlayerViewScale=0.12

	NadeAwayClass=class's_Concussion'

	SolidTex=texture'TOST4TexSolid.HUD.Concussion'
	TransTex=texture'TOST4TexTrans.HUD.Concussion'
}

