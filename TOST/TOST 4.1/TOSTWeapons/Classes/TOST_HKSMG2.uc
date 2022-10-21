//----------------------------------------------------------------------------
// Project : TOST
// File    : TOST_HKSMG2.uc
// Version : 0.5
// Author  : BugBunny/Shag
//----------------------------------------------------------------------------
// Version	Changes
// 0.5		+ first release
//----------------------------------------------------------------------------

class TOST_HKSMG2 expands TOSTWeapon;

var() texture MuzzleFlashVariations;

simulated event RenderOverlays(canvas Canvas)
{
	MFTexture = MuzzleFlashVariations;

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
	AmmoName=".9mm"
	BackupAmmoName=""

	MaxDamage=21.0
	clipSize=30
	clipAmmo=30
	MaxClip=6
	RoundPerMin=900
	FireModes(0)=FM_FullAuto
	bUseFireModes=true
	Price=900
	ClipPrice=30
	BotAimError=0.32
	PlayerAimError=0.16
	VRecoil=60.0
	HRecoil=30.0
	WeaponWeight=5.0
	WeaponID=21
	WeaponClass=2
	aReloadWeapon=(AnimSeq=Reload,AnimRate=0.35)
	MaxWallPiercing=12.0
	MaxRange=1440.0
	ProjectileSpeed=15000.0

	MuzScale=3.000000
	MuzX=647
	MuzY=470
	MuzzleFlashVariations=Texture'TODatas.Muzzle.Muz1'
	MuzRadius=64
	XSurroundCorrection=1.15
	YSurroundCorrection=0.9

	WeaponDescription="Classification: AP II machine gun."
	PickupAmmoCount=32
	bRapidFire=true
	MyDamageType=shot
	shakemag=400.0
	shaketime=0.3
	shakevert=9.0
	AIRating=0.55
	FireSound=Sound'TODatas.smg2fire'
	SelectSound=None
	SoundRadius=96
	NameColor=(B=0)
	bDrawMuzzleFlash=true
	MuzzleScale=0.5
	FlashLength=0.001
	FlashS=64
	AutoSwitchPriority=26
	InventoryGroup=3
	PickupMessage="You got the AP II machine gun!"
	ItemName="APII"
	PlayerViewOffset=(X=150.0,Y=160.0,Z=-220.0)
	PlayerViewMesh=SkeletalMesh'TOModels.smg2Mesh'
	PlayerViewScale=0.125
	BobDamping=0.975
	PickupViewMesh=LodMesh'TOModels.pHKSMG2'
	ThirdPersonMesh=LodMesh'TOModels.wHKSMG2'
	bMuzzleFlashParticles=false
	MuzzleFlashStyle=STY_Translucent
	MuzzleFlashMesh=LodMesh'TOModels.TO3rdMuzzleSMGII'
	MuzzleFlashScale=0.1
	MuzzleFlashTexture=Texture'TOModels.3rdmuzzle2'
	PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
	Mesh=LodMesh'TOModels.mac10p'
	bNoSmooth=false
	CollisionRadius=20.0
	CollisionHeight=10.0

	Mass=18.0
	bHasMultiSkins=true
	ArmsNb=3

	SolidTex=texture'TOST4TexSolid.HUD.SMG2'
	TransTex=texture'TOST4TexTrans.HUD.SMG2'
}
