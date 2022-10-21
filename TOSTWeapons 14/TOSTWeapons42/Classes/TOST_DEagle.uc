//----------------------------------------------------------------------------
// Project : TOST
// File    : TOST_DEagle.uc
// Version : 0.5
// Author  : BugBunny/Shag
//----------------------------------------------------------------------------
// Version	Changes
// 0.5		+ first release
//----------------------------------------------------------------------------

class TOST_DEagle extends TOSTWeaponNoRecoilBug;

var()	texture		MuzzleFlashVariations;
var		s_LaserDot	LaserDot;
var		bool		dotted;

replication
{
	reliable if ( bNetOwner && (Role == ROLE_Authority) )
		LaserDot, dotted;
}

simulated function PostRender( canvas Canvas )
{
	Super.PostRender(Canvas);

	bOwnsCrosshair = true;
	if ( (LaserDot == None) && (s_BPlayer(Owner) != None) && !s_BPlayer(Owner).bHideCrosshairs )
			bOwnsCrosshair = false;
}

event Destroyed()
{
	Super.Destroyed();

	if ( LaserDot != None )
		KillLaserDot();
}

simulated function KillLaserDot()
{
	LaserDot.Destroy();
	LaserDot = None;
}

simulated function Tick(float deltatime)
{
	Super.Tick(deltatime);

	if ( LaserDot != None )
	{
		if ( (Owner != None) && (Pawn(Owner) != None) )
		{
			if ( Pawn(Owner).PlayerReplicationInfo.bIsSpectator || (Pawn(Owner).Weapon != Self) )
			{
				KillLaserDot();
				return;
			}
		}
	}
}

function AltFire( float Value )
{
	if ( LaserDot == None )
	{
		LaserDot = Spawn(class's_SWAT.s_LaserDotChild', Self);
		dotted = true;
	}
	else
	{
		KillLaserDot();
		dotted = false;
	}
}

State DownWeapon
{
	ignores Fire, AltFire, Animend;

	function BeginState()
	{
		if ( LaserDot != None )
			KillLaserDot();

		Super.BeginState();
	}
}

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
		PlaySynchedAnim('FIRELAST', 60.0 / RoundPerMin, 0.01);
}

function BecomePickup()
{
	if ( LaserDot != None )
		KillLaserDot();

	Super.BecomePickup();
}

simulated function SetAimError()
{
	Super.SetAimError();

	if ( LaserDot != None )
		AimError /= 1.66;
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
	if ( dotted && LaserDot == none )
		LaserDot = Spawn(class's_SWAT.s_LaserDotChild', Self);
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
	AmmoName=".50Mag"
	BackupAmmoName=""

	MaxDamage=68.0
	clipSize=7
	clipAmmo=7
	MaxClip=7
	RoundPerMin=200
	Price=500
	ClipPrice=25
	BotAimError=0.24
	PlayerAimError=0.12
	VRecoil=450.0
	HRecoil=2.0
	WeaponID=11
	WeaponClass=1
	WeaponWeight=6.0
	aReloadWeapon=(AnimSeq=Reload,AnimRate=0.5)
	MaxWallPiercing=8.0
	MaxRange=2400.0

	FireModes(0)=FM_SingleFire
	bUseFireModes=true

	MuzScale=2.7
	MuzX=682
	MuzY=504
	MuzzleFlashVariations=Texture'TODatas.Muzzle.Muz1'
	MuzRadius=64
	XSurroundCorrection=1.01
	YSurroundCorrection=0.8

	WeaponDescription="Classification: Desert Eagle .50 w/ Laser Aim"
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
	FireSound=Sound'TODatas.Weapons.deagle_Fire1'
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
	AutoSwitchPriority=11
	InventoryGroup=2
	PickupMessage="You picked up the Desert Eagle pistol !"
	ItemName="Desert Eagle"
	PlayerViewOffset=(X=240.000000,Y=150.000000,Z=-300.000000)
	PlayerViewMesh=SkeletalMesh'TOModels.deagleMesh'
	PlayerViewScale=0.1250000
	PickupViewMesh=LodMesh'TOModels.pdeagle'
	ThirdPersonMesh=LodMesh'TOModels.wdeagle'
	bMuzzleFlashParticles=false
	MuzzleFlashStyle=STY_Translucent
	MuzzleFlashMesh=LodMesh'TOModels.TO3rdMuzzle62'
	MuzzleFlashScale=0.1
	MuzzleFlashTexture=Texture'TOModels.3rdmuzzle7'
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

	SolidTex=texture'TOST4TexSolid.HUD.DEagle'
	TransTex=texture'TOST4TexTrans.HUD.DEagle'
}

