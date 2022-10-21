//----------------------------------------------------------------------------
// Project : TOST
// File    : TOST_MP5KPDW.uc
// Version : 0.5
// Author  : BugBunny/Shag
//----------------------------------------------------------------------------
// Version	Changes
// 0.5		+ first release
//----------------------------------------------------------------------------

class TOST_MP5KPDW expands TOSTWeaponNoRecoilBug;

var() texture MuzzleFlashVariations;

simulated event RenderOverlays(canvas Canvas)
{
	MFTexture = None;

	Super.RenderOverlays(Canvas);
}

simulated function ClipIn()
{
	PlayWeaponSound(Sound'mp5magin');
}

simulated function ClipOut()
{
	PlayWeaponSound(Sound'mp5magout');
}

simulated function ClipLever()
{
	PlayWeaponSound(Sound'mp5maglever');
}

defaultproperties
{
	AmmoName="9mm"
	BackupAmmoName=""

	MaxDamage=24.0
	clipSize=30
	clipAmmo=30
	MaxClip=5
	RoundPerMin=825
	FireModes(0)=FM_FullAuto
	bUseFireModes=true
	bShowWeaponLight=false
	Price=1500
	ClipPrice=40
	BotAimError=0.28
	PlayerAimError=0.14
	VRecoil=60.0
	HRecoil=20.0
	WeaponWeight=15.0
	WeaponID=25
	WeaponClass=2
	aReloadWeapon=(AnimSeq=Reload,AnimRate=0.4)
	MaxWallPiercing=12.0
	ProjectileSpeed=15000.0
	MaxRange=2880.0
	MuzScale=1.0
	MuzX=645
	MuzY=476
	WeaponDescription="Classification: H&K MP5 SD3 w/ Supressor"
	PickupAmmoCount=32
	bRapidFire=True
	MyDamageType=shot
	shakemag=280.0
	shaketime=0.25
	shakevert=7.5
	AIRating=0.55
	RefireRate=0.99
	AltRefireRate=0.99
	FireSound=Sound'TODatas.Weapons.mp5silenced'
	SelectSound=Sound'TODatas.Weapons.Pistol_select'
	bDrawMuzzleFlash=true
	MuzzleScale=0.5
	AutoSwitchPriority=25
	InventoryGroup=3
	PickupMessage="You picked up the MP5 SD !"
	ItemName="MP5 SD"
	PlayerViewOffset=(X=150.0,Y=150.0,Z=-260.0)
	PlayerViewMesh=SkeletalMesh'TOModels.mp5sdMesh'

	PlayerViewScale=0.125
	BobDamping=0.975
	PickupViewMesh=LodMesh'TOModels.pMP5SD'
	ThirdPersonMesh=LodMesh'TOModels.wMP5SD'
	bMuzzleFlashParticles=True
	MuzzleFlashStyle=STY_Translucent
	MuzzleFlashMesh=LodMesh'Botpack.MuzzFlash3'
//	MuzzleFlashScale=0.25
	MuzzleFlashScale=0.0
	MuzzleFlashTexture=Texture'Botpack.Skins.Muzzy'
	PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
	Mesh=LodMesh'TOModels.pmp5kpdw'
	bNoSmooth=False

	FireOffset=(X=0.0,Y=15.0,Z=-9.0)
	CollisionRadius=20.0
	CollisionHeight=15.0
	Mass=20.0
	bHasMultiSkins=true
	ArmsNb=3

	SolidTex=texture'TOST4TexSolid.HUD.MP5SD'
	TransTex=texture'TOST4TexTrans.HUD.MP5SD'
}
