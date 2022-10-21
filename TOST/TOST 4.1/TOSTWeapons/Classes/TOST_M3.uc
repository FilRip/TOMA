//----------------------------------------------------------------------------
// Project : TOST
// File    : TOST_M3.uc
// Version : 0.5
// Author  : BugBunny/Shag
//----------------------------------------------------------------------------
// Version	Changes
// 0.5		+ first release
//----------------------------------------------------------------------------

class TOST_M3 extends TOST_Mossberg;

defaultproperties
{
	AmmoName="Shells"
	BackupAmmoName=""

	FireModes(0)=FM_FullAuto

	clipSize=8
	clipAmmo=8
	MaxClip=40
	ClipInc=8
	RoundPerMin=76
	DamageRadius=1.0
	NumPellets=10
	MaxDamage=20.5
	Price=1500
	ClipPrice=4
	WeaponID=23
	MaxRange=1300.0

	BotAimError=0.18
	PlayerAimError=0.176

	VRecoil=1000.0
	HRecoil=10.0

	MuzScale=6.0
	MuzX=617
	MuzY=468
	XSurroundCorrection=1.8
	YSurroundCorrection=0.9

	FireSound=Sound'TODatas.M3Shoot'
	WeaponDescription="Classification: BW SPS 12 Shotgun."
	AutoSwitchPriority=23
	PickupMessage="You picked up an BW SPS 12 Shotgun!"
	ItemName="BWSPS12"
	PlayerViewOffset=(X=180.0,Y=160.0,Z=-200.0)
	PlayerViewMesh=SkeletalMesh'TOModels.spasMesh'
	PlayerViewScale=0.125
	PickupViewMesh=LodMesh'TOModels.pSPAS12'
	ThirdPersonMesh=LodMesh'TOModels.wSPAS12'
	Mesh=LodMesh'TOModels.pm3'

	SolidTex=texture'TOST4TexSolid.HUD.SPAS12'
	TransTex=texture'TOST4TexTrans.HUD.SPAS12'
}
