//----------------------------------------------------------------------------
// Project : TOST
// File    : TOST_Ak47.uc
// Version : 0.5
// Author  : BugBunny/Shag
//----------------------------------------------------------------------------
// Version	Changes
// 0.5		+ first release
//----------------------------------------------------------------------------

class TOST_Ak47 expands TOSTWeaponNoRecoilBug;

var() texture MuzzleFlashVariations;

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
		PlayAnim('idle1', 0.15);
	else
		LoopAnim('idle',0.2, 0.3);
}

simulated function ClipIn()
{
	PlayWeaponSound(Sound'TODatas.HK33Clipout');
}

simulated function ClipOut()
{
	PlayWeaponSound(Sound'TODatas.OICWClipout1');
}

simulated function ClipLever()
{
	PlayWeaponSound(Sound'TODatas.OICWClipout2');
}

defaultproperties
{
	AmmoName="7.62mm"
	BackupAmmoName=""
	MaxDamage=31.5
	clipSize=30
	clipAmmo=30
	MaxClip=5
	RoundPerMin=650
	bTracingBullets=true
	FireModes(0)=FM_FullAuto
	FireModes(1)=FM_SingleFire
	bUseFireModes=true
	TraceFrequency=4
	Price=3200
	ClipPrice=60
	BotAimError=0.48
	PlayerAimError=0.24
	VRecoil=120.0
	HRecoil=10.0
	RecoilMultiplier=0.015000
	WeaponID=33
	WeaponClass=3
	WeaponWeight=20.0
	aReloadWeapon=(AnimSeq=Reload,AnimRate=0.47)
	MaxWallPiercing=20.000000
	MaxRange=4800.0
	ProjectileSpeed=15000.000000

	MuzScale=4.0
	MuzX=630
	MuzY=468
	MuzzleFlashVariations=Texture'TODatas.Muzzle.Muz5'
	MuzRadius=64
	XSurroundCorrection=1.22
	YSurroundCorrection=0.9

	WeaponDescription="Classification: Kalashnikov AK-47"
	PickupAmmoCount=30
	bRapidFire=true
	Mass=25.000000
	MyDamageType=shot
	shakemag=280.000000
	shaketime=0.300000
	shakevert=8.000000
	AIRating=0.650000
	RefireRate=0.990000
	AltRefireRate=0.990000
	FireSound=Sound'TODatas.Weapons.Ak47fire'
	SelectSound=Sound'TODatas.Weapons.Pistol_select'
	DeathMessage="%k's %w turned %o into a leaky piece of meat."
	NameColor=(B=0)
	bDrawMuzzleFlash=true
	MuzzleScale=0.700000
	FlashY=-0.060000
	FlashC=0.002000
	FlashLength=0.001000
	FlashS=64
	AutoSwitchPriority=33
	InventoryGroup=4
	PickupMessage="You picked up the AK-47 !"
	ItemName="AK-47"
	PlayerViewOffset=(X=200.000000,Y=160.000000,Z=-260.000000)
	PlayerViewMesh=SkeletalMesh'TOModels.Ak47'
	PlayerViewScale=0.125000
	BobDamping=0.975000
	PickupViewMesh=LodMesh'TOModels.pAK47'
	ThirdPersonMesh=LodMesh'TOModels.wAK47'
	Mesh=LodMesh'TOModels.pAK47'
	bMuzzleFlashParticles=false
	MuzzleFlashStyle=STY_Translucent
	MuzzleFlashMesh=LodMesh'TOModels.TO3rdMuzzleAk'
	MuzzleFlashScale=0.1
	MuzzleFlashTexture=Texture'TOModels.3rdmuzzle4'
	PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
	bNoSmooth=false

	CollisionRadius=30.000000
	CollisionHeight=10.000000

	bHasMultiSkins=true
	ArmsNb=3

	ShellCaseType="s_SWAT.TO_556SC"

	SolidTex=texture'TOST4TexSolid.HUD.Ak47'
	TransTex=texture'TOST4TexTrans.HUD.Ak47'
}
