//----------------------------------------------------------------------------
// Project : TOST
// File    : TOST_RagingBull.uc
// Version : 0.5
// Author  : BugBunny/Shag
//----------------------------------------------------------------------------
// Version	Changes
// 0.5		+ first release
//----------------------------------------------------------------------------

class TOST_RagingBull extends TOSTWeapon;

var()	texture	MuzzleFlashVariations;

simulated event RenderOverlays(canvas Canvas)
{
	MFTexture = MuzzleFlashVariations;

	Super.RenderOverlays(Canvas);
}

simulated function PlayIdleAnim()
{
	if ( Mesh == PickupViewMesh )
		return;

	if ( (FRand() > 0.98) && (AnimSequence != 'idle1') )
		PlayAnim('idle1', 0.1);
	else
		LoopAnim('idle',0.2, 0.3);
}

simulated function PlayClipOut()
{
	PlayWeaponSound(Sound'TODatas.BerClipIn');
}

simulated function PlayClipIn()
{
	PlayWeaponSound(Sound'TODatas.BerClipOut');
}

simulated function PlayClipReload()
{
	PlayWeaponSound(Sound'TODatas.BerSlideIn');
}

defaultproperties
{
	AmmoName=".50Mag"
	BackupAmmoName=""
	bUseShellCase=false

	MaxDamage=90.0
	clipSize=6
	clipAmmo=6
	MaxClip=7
	RoundPerMin=170
	Price=700
	ClipPrice=30
	BotAimError=0.20
	PlayerAimError=0.10
	VRecoil=750.0
	HRecoil=20.0
	WeaponID=11
	WeaponClass=1
	WeaponWeight=10.0
	aReloadWeapon=(AnimSeq=Reload,AnimRate=0.3)
	MaxWallPiercing=32.0
	MaxRange=1920.0

	FireModes(0)=FM_SingleFire
	bUseFireModes=true

	MuzScale=2.700000
	MuzX=635
	MuzY=486
	MuzzleFlashVariations=Texture'TODatas.Muzzle.Muz1'
	MuzRadius=64
	XSurroundCorrection=1.07
	YSurroundCorrection=0.9

	WeaponDescription="Classification: Raging Cobra sixshooter."
	InstFlash=-0.200000
	InstFog=(X=325.000000,Y=230.000000,Z=50.000000)
	PickupAmmoCount=30
	FiringSpeed=1.500000
	MyDamageType=shot

	shaketime=0.300000
	shakemag=250.000000
	shakevert=10.000000

	AIRating=0.50000
	RefireRate=0.800000
	AltRefireRate=0.870000
	FireSound=Sound'TODatas.ragingfire'
	SelectSound=Sound'TODatas.Weapons.Pistol_select'
	DeathMessage="%k riddled %o full of holes with the %w."
	NameColor=(R=200,G=200)
	bDrawMuzzleFlash=True
	MuzzleScale=0.500000
	FlashY=-0.030000
	FlashO=0.005000
	FlashC=0.002000
	FlashLength=0.001000
	FlashS=64
	AutoSwitchPriority=14
	InventoryGroup=2
	PickupMessage="You picked up a Raging Cobra sixshooter!"
	ItemName="RagingCobra"
	PlayerViewOffset=(X=180.000000,Y=160.000000,Z=-260.000000)
	PlayerViewMesh=SkeletalMesh'TOModels.ragingMesh'
	PlayerViewScale=0.13
	PickupViewMesh=LodMesh'TOModels.pRagingBull'
	ThirdPersonMesh=LodMesh'TOModels.wRagingBull'
	bMuzzleFlashParticles=false
	MuzzleFlashStyle=STY_Translucent
	MuzzleFlashMesh=LodMesh'TOModels.TO3rdMuzzle63'
	MuzzleFlashScale=0.1
	MuzzleFlashTexture=Texture'TOModels.3rdmuzzle8'
	PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
	bHidden=True
	Mesh=LodMesh'TOModels.pdeagle'
	bNoSmooth=False
	CollisionRadius=20.000000
	CollisionHeight=10.000000

	ShellCaseType="s_SWAT.s_50bmgShellCase"

	Mass=15.000000
	bHasMultiSkins=true
	ArmsNb=3

	SolidTex=texture'TOST4TexSolid.HUD.Bull'
	TransTex=texture'TOST4TexTrans.HUD.Bull'
}

