//----------------------------------------------------------------------------
// Project : TOST
// File    : TOST_Mac10.uc
// Version : 0.5
// Author  : BugBunny/Shag
//----------------------------------------------------------------------------
// Version	Changes
// 0.5		+ first release
//----------------------------------------------------------------------------

class TOST_MAC10 expands TOSTWeapon;

var() texture MuzzleFlashVariations;

simulated event RenderOverlays(canvas Canvas)
{
	MFTexture = MuzzleFlashVariations;

	Super.RenderOverlays(Canvas);
}

simulated function ClipIn()
{
	PlayWeaponSound(Sound'TODatas.macmagin');
}

simulated function ClipOut()
{
	PlayWeaponSound(Sound'TODatas.macmagout');
}

simulated function ClipLever()
{
	PlayWeaponSound(Sound'TODatas.macmaglever');
}

defaultproperties
{
	AmmoName=".45 ACP"
	BackupAmmoName=""

	MaxDamage=20.0
	clipSize=32
	clipAmmo=32
	MaxClip=6
	RoundPerMin=950
	FireModes(0)=FM_FullAuto
	bUseFireModes=true
	Price=950
	ClipPrice=30
	BotAimError=0.28
	PlayerAimError=0.14
	VRecoil=50.0
	HRecoil=35.0
	WeaponWeight=6.0
	WeaponID=21
	WeaponClass=2
	aReloadWeapon=(AnimSeq=Reload,AnimRate=0.45)
	MaxWallPiercing=12.0
	MaxRange=1440.0
	ProjectileSpeed=15000.0

	MuzScale=3.0
	MuzX=661
	MuzY=503
	MuzzleFlashVariations=Texture'TODatas.Muzzle.Muz1'
	MuzRadius=64
	XSurroundCorrection=1.07
	YSurroundCorrection=0.85

	WeaponDescription="Classification: UZI."
	PickupAmmoCount=32
	bRapidFire=true
	MyDamageType=shot
	shakemag=400.0
	shaketime=0.3
	shakevert=9.0
	AIRating=0.55
	RefireRate=0.99
	AltRefireRate=0.99
	FireSound=Sound'TODatas.real-mac-10'
	SelectSound=None
	SoundRadius=96
	DeathMessage="%k's %w turned %o into a leaky piece of meat."
	NameColor=(B=0)
	bDrawMuzzleFlash=true
	MuzzleScale=0.5
	FlashLength=0.001
	FlashS=64
	AutoSwitchPriority=21
	InventoryGroup=3
	PickupMessage="You got the UZI!"
	ItemName="UZI"
	PlayerViewOffset=(X=180.0,Y=160.0,Z=-230.0)
	PlayerViewMesh=SkeletalMesh'TOModels.mac10Mesh'
	PlayerViewScale=0.125000
	BobDamping=0.975000
	PickupViewMesh=LodMesh'TOModels.mac10p'
	ThirdPersonMesh=LodMesh'TOModels.mac10w'
	bMuzzleFlashParticles=false
	MuzzleFlashStyle=STY_Translucent
	MuzzleFlashMesh=LodMesh'TOModels.TO3rdMuzzle62'
	MuzzleFlashScale=0.1
	MuzzleFlashTexture=Texture'TOModels.3rdmuzzle7'
	PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
	Mesh=LodMesh'TOModels.mac10p'
	bNoSmooth=false
	CollisionRadius=20.0
	CollisionHeight=10.0

	Mass=18.0
	bHasMultiSkins=true
	ArmsNb=3

	SolidTex=texture'TOST4TexSolid.HUD.MAC10'
	TransTex=texture'TOST4TexTrans.HUD.MAC10'
}
