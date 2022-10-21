//----------------------------------------------------------------------------
// Project : TOST
// File    : TOST_MP5N.uc
// Version : 0.5
// Author  : BugBunny/Shag
//----------------------------------------------------------------------------
// Version	Changes
// 0.5		+ first release
//----------------------------------------------------------------------------

class TOST_MP5N expands TOSTWeapon;

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
	AmmoName="9mm"
	BackupAmmoName=""

	MaxDamage=25.0
	clipSize=30
	clipAmmo=30
	MaxClip=5
	RoundPerMin=790
	Price=1500
	ClipPrice=40
	BotAimError=0.28
	PlayerAimError=0.14
	VRecoil=75.0
	HRecoil=20.0
	WeaponWeight=15.0
	WeaponID=20
	WeaponClass=2
	aReloadWeapon=(AnimSeq=Reload,AnimRate=0.4)
	MaxWallPiercing=15.000000
	MaxRange=2880.0
	ProjectileSpeed=15000.000000
	FireModes(0)=FM_FullAuto
	FireModes(1)=FM_BurstFire
	FireModes(2)=FM_SingleFire
	bUseFireModes=true

	MuzzleFlashVariations=Texture'TODatas.Muzzle.Muz2'
	MuzScale=4.00000
	MuzX=643
	MuzY=475
	MuzRadius=64
	XSurroundCorrection=1.2
	YSurroundCorrection=0.9

	WeaponDescription="Classification: MP5 Navy machine gun."
	PickupAmmoCount=30
	bRapidFire=True
	Mass=25.000000
	MyDamageType=shot
	shakemag=250.000000
	shaketime=0.300000
	shakevert=7.000000
	AIRating=0.600000
	RefireRate=0.990000
	AltRefireRate=0.990000
	FireSound=Sound'TODatas.Weapons.MP5_Fire1'
	SelectSound=None

	DeathMessage="%k's %w turned %o into a leaky piece of meat."
	NameColor=(B=0)
	bDrawMuzzleFlash=True
	MuzzleScale=0.700000
	FlashY=-0.050000
	FlashC=0.002000
	FlashLength=0.001000
	FlashS=64
	AutoSwitchPriority=20
	InventoryGroup=3
	PickupMessage="You got the MP5 Navy machine gun!"
	ItemName="MP5Navy"
	PlayerViewOffset=(X=150.000000,Y=150.000000,Z=-260.000000)
	PlayerViewMesh=SkeletalMesh'TOModels.mp5navyMesh'
	PlayerViewScale=0.125000
	BobDamping=0.975000
	PickupViewMesh=LodMesh'TOModels.pmp5n'
	ThirdPersonMesh=LodMesh'TOModels.wmp5n'
	Mesh=LodMesh'TOModels.pmp5n'
	bMuzzleFlashParticles=false
	MuzzleFlashStyle=STY_Translucent
	MuzzleFlashMesh=LodMesh'TOModels.TO3rdMuzzleSMG'
	MuzzleFlashScale=0.1
	MuzzleFlashTexture=Texture'TOModels.3rdmuzzle2'
	PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
	bNoSmooth=false

	FireOffset=(X=0.0,Y=15.0,Z=-9.0)
	CollisionRadius=25.000000
	CollisionHeight=10.000000

	bHasMultiSkins=true
	ArmsNb=3

	SolidTex=texture'TOST4TexSolid.HUD.MP5A2'
	TransTex=texture'TOST4TexTrans.HUD.MP5A2'
}

