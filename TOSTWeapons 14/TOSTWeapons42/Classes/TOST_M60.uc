//----------------------------------------------------------------------------
// Project : TOST
// File    : TOST_M60.uc
// Version : 0.5
// Author  : BugBunny/Shag
//----------------------------------------------------------------------------
// Version	Changes
// 0.5		+ first release
//----------------------------------------------------------------------------

class TOST_m60 expands TOSTWeaponNoRecoilBug;

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

	if ( (AnimSequence=='autofire1') || (AnimSequence=='autofire2') || (AnimSequence=='autofire3') )
	{
		PlayAnim('firebacktoidle', 1.0, 0.05);
		return;
	}

	if ( (FRand() > 0.98) && (AnimSequence != 'idle1') )
		PlayAnim('idle1', 0.15);
	else
		LoopAnim('idle',0.2, 0.3);
}

simulated function PlayFiring()
{
	local	float	Rnd;

	Super.PlayFiring();

	if ( ShotCount > 1 )
	{
		Rnd = FRand();

		if ( Rnd < 0.33 )
			PlaySynchedAnim('autofire1', rofmultiplier / RoundPerMin, 0.02);
		else if ( Rnd < 0.66 )
			PlaySynchedAnim('autofire2', rofmultiplier / RoundPerMin, 0.02);
		else
			PlaySynchedAnim('autofire3', rofmultiplier / RoundPerMin, 0.02);
	}
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
	MaxDamage=42.0
	clipSize=100
	clipAmmo=100
	RemainingClip=0
	MaxClip=2
	RoundPerMin=550
	bTracingBullets=true
	FireModes(0)=FM_FullAuto
	bUseFireModes=true
	TraceFrequency=3
	Price=9600
	ClipPrice=500
	BotAimError=0.7
	PlayerAimError=0.35
	VRecoil=200.0
	HRecoil=30.0
	RecoilMultiplier=0.015
	WeaponID=33
	WeaponClass=3
	WeaponWeight=60.0
	aReloadWeapon=(AnimSeq=Reload,AnimRate=0.40)
	MaxWallPiercing=40.0
	MaxRange=7200.0
	ProjectileSpeed=15000.0

	MuzScale=3.0
	MuzX=589
	MuzY=452
	MuzzleFlashVariations=Texture'TODatas.Muzzle.Muz1'
	MuzRadius=64
	XSurroundCorrection=1.18
	YSurroundCorrection=0.9

	WeaponDescription="Classification: M60 E3 Machine Gun"
	PickupAmmoCount=30
	bRapidFire=true
	Mass=25.0
	MyDamageType=shot
	shakemag=280.0
	shaketime=0.3
	shakevert=8.0
	AIRating=0.65
	RefireRate=0.99
	AltRefireRate=0.99
	FireSound=Sound'TODatas.Weapons.M60fire'
	SelectSound=Sound'TODatas.Weapons.Pistol_select'
	bDrawMuzzleFlash=true
	MuzzleScale=0.7
	FlashY=-0.06
	FlashC=0.002
	FlashLength=0.001
	FlashS=64
	AutoSwitchPriority=33
	InventoryGroup=4
	PickupMessage="You picked up the M60 !"
	ItemName="M60"
	PlayerViewOffset=(X=220.0,Y=180.0,Z=-270.0)
	PlayerViewMesh=SkeletalMesh'TOModels.m60Mesh'
	PlayerViewScale=0.125
	BobDamping=0.975
	PickupViewMesh=LodMesh'TOModels.M60p'
	ThirdPersonMesh=LodMesh'TOModels.M60w'
	Mesh=LodMesh'TOModels.M60p'
	bMuzzleFlashParticles=false
	MuzzleFlashStyle=STY_Translucent
	MuzzleFlashMesh=LodMesh'TOModels.TO3rdMuzzleM60'
	MuzzleFlashScale=0.1
	MuzzleFlashTexture=Texture'TOModels.3rdmuzzle7'
	PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
	bNoSmooth=false

	CollisionRadius=30.0
	CollisionHeight=10.0

	bHasMultiSkins=true
	ArmsNb=3

	ShellCaseType="s_SWAT.TO_556SC"

	SolidTex=texture'TOST4TexSolid.HUD.M60'
	TransTex=texture'TOST4TexTrans.HUD.M60'
}
