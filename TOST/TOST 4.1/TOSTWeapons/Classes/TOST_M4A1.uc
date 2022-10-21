//----------------------------------------------------------------------------
// Project : TOST
// File    : TOST_M4A1.uc
// Version : 0.5
// Author  : BugBunny/Shag
//----------------------------------------------------------------------------
// Version	Changes
// 0.5		+ first release
//----------------------------------------------------------------------------

class TOST_M4A1 expands TOSTWeapon;

var() texture MuzzleFlashVariation;

simulated event RenderOverlays( canvas Canvas )
{
	MFTexture = MuzzleFlashVariation;

	Super.RenderOverlays(Canvas);
}

simulated function PlayIdleAnim()
{
	if ( Mesh == PickupViewMesh )
		return;

	if ( (FRand() > 0.98) && (AnimSequence != 'idle1') )
		PlayAnim('idle1', 0.04);
	else
		LoopAnim('idle', 0.2, 0.3);
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
	AmmoName="5.56mm"
	BackupAmmoName=""

	MaxDamage=30.5 // 30.0
	clipSize=30
	clipAmmo=30
	MaxClip=5
	RoundPerMin=675
	bTracingBullets=true
	TraceFrequency=4
	Price=3300
	ClipPrice=50
	BotAimError=0.64
	PlayerAimError=0.32
	VRecoil=110.0
	HRecoil=5.0
	WeaponID=32
	WeaponClass=3
	WeaponWeight=25.0
	aReloadWeapon=(AnimSeq=Reload,AnimRate=0.47)
	MaxWallPiercing=25.000000
	MaxRange=6000.0
	ProjectileSpeed=15000.000000
	FireModes(0)=FM_FullAuto
	FireModes(1)=FM_BurstFire
	FireModes(2)=FM_SingleFire
	bUseFireModes=true

	MuzzleFlashVariation=Texture'TODatas.Muzzle.Muz4'
	MuzRadius=64
	MuzScale=3.0
	MuzX=613
	MuzY=462
	XSurroundCorrection=1.15
	YSurroundCorrection=0.9

	WeaponDescription="Classification: M4A1 rifle."
	PickupAmmoCount=25
	bRapidFire=true
	Mass=25.000000
	MyDamageType=shot
	shakemag=250.000000
	shaketime=0.300000
	shakevert=6.000000
	AIRating=0.700000
	RefireRate=0.990000
	AltRefireRate=0.990000
	FireSound=Sound'TODatas.Weapons.m4fire'

	SelectSound=Sound'TODatas.Weapons.Pistol_select'
	DeathMessage="%k's %w turned %o into a leaky piece of meat."
	NameColor=(B=0)
	bDrawMuzzleFlash=True
	MuzzleScale=0.800000
	FlashY=-0.060000
	FlashC=0.002000
	FlashLength=0.001000
	FlashS=64
	AutoSwitchPriority=32
	InventoryGroup=4
	PickupMessage="You got the M4A1 rifle!"
	ItemName="M4A1"
	PlayerViewOffset=(X=140.000000,Y=160.000000,Z=-250.000000)
	PlayerViewMesh=SkeletalMesh'TOModels.m4a1bareMesh'
	PlayerViewScale=0.125
	BobDamping=0.975000
	PickupViewMesh=LodMesh'TOModels.pM4A1'
	ThirdPersonMesh=LodMesh'TOModels.wM4A1'
	Mesh=LodMesh'TOModels.pM4A1'
	bMuzzleFlashParticles=false
	MuzzleFlashStyle=STY_Translucent
	MuzzleFlashMesh=LodMesh'TOModels.TO3rdMuzzleM4A1'
	MuzzleFlashScale=0.1
	MuzzleFlashTexture=Texture'TOModels.3rdmuzzle1'
	PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
	bNoSmooth=false

	CollisionRadius=30.000000
	CollisionHeight=10.000000

	bHasMultiSkins=true
	ArmsNb=3

	ShellCaseType="s_SWAT.TO_556SC"

	SolidTex=texture'TOST4TexSolid.HUD.M4A1'
	TransTex=texture'TOST4TexTrans.HUD.M4A1'
}

