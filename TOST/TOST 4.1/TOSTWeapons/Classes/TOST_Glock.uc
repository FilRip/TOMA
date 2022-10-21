//----------------------------------------------------------------------------
// Project : TOST
// File    : TOSTWeapon.uc
// Version : 0.5
// Author  : BugBunny/Shag
//----------------------------------------------------------------------------
// Version	Changes
// 0.5		+ first release
//----------------------------------------------------------------------------

class TOST_Glock extends TOSTWeapon;

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

	if ( ClipAmmo > 0 )
	{
		if ( (FRand() > 0.98) && (AnimSequence != 'idle1') )
			PlayAnim('idle1', 0.15);
		else
			LoopAnim('idle',0.2, 0.3);
	}
	else
		LoopAnim('FIXLAST',0.2, 0.3);
}

simulated function ForceStillFrame()
{
	TweenToStill();

	if ( ClipAmmo > 0 )
		PlayAnim('Fix', 2.0, 0.1);
	else
		LoopAnim('FIXLAST',0.2, 0.3);
}

simulated function PlayFiring()
{
	Super.PlayFiring();

	if ( ClipAmmo < 2 )
		PlaySynchedAnim('FIRELAST', rofmultiplier / RoundPerMin, 0.01);
}

simulated function PlaySelect()
{
	bForceFire = false;
	bForceAltFire = false;
	bCanClientFire = false;

	if ( ClipAmmo > 0 )
	{
		if ( !IsAnimating() || (AnimSequence != 'Select') )
			PlayAnim('Select',,0.0);
	}
	else
	{
		if ( !IsAnimating() || (AnimSequence != 'SelectLast') )
			PlayAnim('SelectLast',,0.0);
	}

	Owner.PlaySound(SelectSound, SLOT_Misc, Pawn(Owner).SoundDampening);
}

simulated function TweenDown()
{
	if ( IsAnimating() && (AnimSequence != '') && (GetAnimGroup(AnimSequence) == 'Select') )
		TweenAnim( AnimSequence, AnimFrame * 0.4 );
	else if ( ClipAmmo > 0 )
		PlayAnim('Down', 1.0, 0.05);
	else
		PlayAnim('DownLast', 1.0, 0.05);
}

simulated function PlayClipOut()
{
	PlayWeaponSound(Sound'TODatas.BerClipIn');
}

simulated function PlayClipIn()
{
	PlayWeaponSound(Sound'TODatas.BerClipOut');
}

simulated function PlayClipSlideIn()
{
	PlayWeaponSound(Sound'TODatas.BerSlideIn');
}

defaultproperties
{
	AmmoName=".45ACP"
	BackupAmmoName=""

	MaxDamage=50.0
	clipSize=13
	clipAmmo=13
	MaxClip=5
	RoundPerMin=260
	Price=300
	ClipPrice=15
	BotAimError=0.20
	PlayerAimError=0.10
	VRecoil=275.0
	HRecoil=15.0
	WeaponID=12
	WeaponClass=1
	WeaponWeight=2.0
	aReloadWeapon=(AnimSeq=Reload,AnimRate=0.5)
	MaxWallPiercing=6.0
	MaxRange=1440.0

	EmptyClipSound=Sound'TODatas.Empty1'

	FireModes(0)=FM_SingleFire
	FireModes(1)=FM_BurstFire
	bUseFireModes=true
	bSingleFireBasedROF=true

	MuzScale=3.0
	MuzX=689
	MuzY=515
	MuzRadius=64
	MuzzleFlashVariations=Texture'TODatas.Muzzle.Muz9'
	XSurroundCorrection=1.02
	YSurroundCorrection=0.8

	WeaponDescription="Classification: GL 23 pistol."
	InstFlash=-0.200000
	InstFog=(X=400.000000,Y=225.000000,Z=95.000000)
	PickupAmmoCount=30
	FiringSpeed=1.500000
	MyDamageType=shot

	shakemag=250.000000
	shaketime=0.300000
	shakevert=6.000000

	AIRating=0.40000
	RefireRate=0.800000
	AltRefireRate=0.870000
	FireSound=Sound'TODatas.Weapons.glockfire'
	SelectSound=Sound'TODatas.Weapons.Pistol_select'
	DeathMessage="%k riddled %o full of holes with the %w."
	NameColor=(R=200,G=200)
	bDrawMuzzleFlash=True
	MuzzleScale=1.000000
	FlashY=0.100000
	FlashO=0.008000
	FlashC=0.035000
	FlashLength=0.010000
	FlashS=128
	AutoSwitchPriority=12
	InventoryGroup=2
	PickupMessage="You picked up a GL 23 pistol!"
	ItemName="GL23"
	PlayerViewOffset=(X=240.000000,Y=140.000000,Z=-300.000000)
	PlayerViewMesh=SkeletalMesh'TOModels.glockMesh'
	PlayerViewScale=0.125
	PickupViewMesh=LodMesh'TOModels.pGlock'
	ThirdPersonMesh=LodMesh'TOModels.wGlock'
	bMuzzleFlashParticles=false
	MuzzleFlashStyle=STY_Translucent
	MuzzleFlashMesh=LodMesh'TOModels.TO3rdMuzzleGlock'
	MuzzleFlashScale=0.1
	MuzzleFlashTexture=Texture'TOModels.3rdmuzzle3'
	PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
	bHidden=True
	Mesh=LodMesh'TOModels.pGlock'
	bNoSmooth=False
	CollisionRadius=20.000000
	CollisionHeight=10.000000
	Mass=15.000000
	bHasMultiSkins=true
	ArmsNb=3

	SolidTex=texture'TOST4TexSolid.HUD.GL23'
	TransTex=texture'TOST4TexTrans.HUD.GL23'
}
