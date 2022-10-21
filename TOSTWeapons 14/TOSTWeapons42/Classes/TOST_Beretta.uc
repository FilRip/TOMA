//----------------------------------------------------------------------------
// Project : TOST
// File    : TOST_Beretta.uc
// Version : 0.5
// Author  : BugBunny/Shag
//----------------------------------------------------------------------------
// Version	Changes
// 0.5		+ first release
//----------------------------------------------------------------------------

class TOST_Beretta extends TOSTWeaponNoRecoilBug;

var() texture	MuzzleFlashVariations;

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
	{
		if ( (FRand() > 0.98) && (AnimSequence != 'idle1') )
			PlayAnim('idle1', 0.15);
		else
			LoopAnim('idle',0.2, 0.3);
	}
	else
		LoopAnim('FIXLAST',0.2, 0.3);
}

simulated function PlayFiring()
{
	Super.PlayFiring();

	if ( ClipAmmo < 2 )
		PlaySynchedAnim('FIRELAST', 60.0 / RoundPerMin, 0.01);
}

simulated function PlaySelect()
{
	if ( !hasanim('Select') )
		Mesh=PlayerViewMesh;

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
	AmmoName="9mm"
	BackupAmmoName=""

	MaxDamage=54.000000
	clipSize=15
	clipAmmo=15
	MaxClip=4
	RoundPerMin=300
	Price=300
	ClipPrice=20
	BotAimError=0.22
	PlayerAimError=0.11
	VRecoil=300.0
	HRecoil=5.0
	WeaponID=13
	WeaponClass=1
	WeaponWeight=4.0
	aReloadWeapon=(AnimSeq=Reload,AnimRate=0.45)
	MaxWallPiercing=8.000000
	MaxRange=1440.000000

	FireModes(0)=FM_SingleFire
	bUseFireModes=true

	EmptyClipSound=Sound'TODatas.Empty1'

	MuzzleFlashVariations=Texture'TODatas.Muzzle.Muz6'
	MuzScale=3.700000
	MuzRadius=64
	MuzX=691
	MuzY=504
	XSurroundCorrection=1.09
	YSurroundCorrection=0.8

	WeaponDescription="Classification: Beretta 92F 9mm"
	InstFlash=-0.200000
	InstFog=(X=325.000000,Y=225.000000,Z=50.000000)
	PickupAmmoCount=30
	FiringSpeed=1.500000
	AltProjectileClass=Class's_SWAT.s_LaserDotChild'
	MyDamageType=shot

	shaketime=0.300000
	shakemag=250.000000
	shakevert=10.000000

	AIRating=0.50000
	RefireRate=0.800000
	AltRefireRate=0.870000
	FireSound=Sound'TODatas.Weapons.BerFire'
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
	AutoSwitchPriority=13
	InventoryGroup=2
	PickupMessage="You picked up the Beretta 92F pistol !"
	ItemName="Beretta 92F"
	PlayerViewOffset=(X=240.000000,Y=140.000000,Z=-300.000000)
	PlayerViewMesh=SkeletalMesh'TOModels.berettaMesh'
	PlayerViewScale=0.1250000
	PickupViewMesh=LodMesh'TOModels.pBeretta'
	ThirdPersonMesh=LodMesh'TOModels.wBeretta'
	bMuzzleFlashParticles=false
	MuzzleFlashStyle=STY_Translucent
	MuzzleFlashMesh=LodMesh'TOModels.TO3rdMuzzle63'
	MuzzleFlashScale=0.1
	MuzzleFlashTexture=Texture'TOModels.3rdmuzzle8'
	PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
	bHidden=True
	Mesh=LodMesh'TOModels.pberetta'
	bNoSmooth=False
	CollisionRadius=20.000000
	CollisionHeight=10.000000

	Mass=15.000000
	bHasMultiSkins=true
	ArmsNb=3

	SolidTex=texture'TOST4TexSolid.HUD.Beretta'
	TransTex=texture'TOST4TexTrans.HUD.Beretta'
}


