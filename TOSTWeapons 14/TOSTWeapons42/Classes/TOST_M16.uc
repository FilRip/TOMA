//----------------------------------------------------------------------------
// Project : TOST
// File    : TOST_M16.uc
// Version : 0.5
// Author  : BugBunny/Shag
//----------------------------------------------------------------------------
// Version	Changes
// 0.5		+ first release
//----------------------------------------------------------------------------

class TOST_M16 expands TOSTWeaponNoRecoilBug;

var() 	texture		MuzzleFlashVariations;
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

	if (LaserDot != None)
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

simulated function PlayAltFiring()
{
}

function AltFire( float Value )
{
	if ( LaserDot == None )
	{
		LaserDot = Spawn(class's_SWAT.s_LaserDotChild', Self, , Location, Rotation);
		dotted = true;
	}
	else
	{
		KillLaserDot();
		dotted = false;
	}

	Pawn(Owner).bAltFire = 0;
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

function BecomePickup()
{
	if ( LaserDot != None )
		KillLaserDot();

	Super.BecomePickup();
}

simulated event RenderOverlays(canvas Canvas)
{
	MFTexture = MuzzleFlashVariations;

	Super.RenderOverlays(Canvas);
}

simulated function SetAimError()
{
	Super.SetAimError();

	if ( LaserDot != None )
		AimError /= 1.66;
}

simulated function ClipIn()
{
	PlayWeaponSound(Sound'TODatas.OICWClipin1');
}

simulated function ClipOut()
{
	PlayWeaponSound(Sound'TODatas.OICWClipout1');
}

simulated function ClipLever()
{
	PlayWeaponSound(Sound'TODatas.OICWClipout2');
}

simulated function PlaySelect()
{
	bForceFire = false;
	bForceAltFire = false;
	bCanClientFire = false;
	if ( !IsAnimating() || (AnimSequence != 'Select') )
		PlayAnim('Select',1.0,0.0);

	if ( !IsAnimating() || (AnimSequence != 'Select') )
	{// this fix the no recoil when fast pickup switch
		if ( s_Player(owner) != none )
			s_Player(owner).NextWeapon();
	}
	else
	{
		Owner.PlaySound(SelectSound, SLOT_Misc, Pawn(Owner).SoundDampening);
		if ( dotted && LaserDot == none )
			LaserDot = Spawn(class's_SWAT.s_LaserDotChild', Self);
	}
}

defaultproperties
{
	AmmoName="5.56mm"
	BackupAmmoName=""

	FireModes(0)=FM_SingleFire
	FireModes(1)=FM_BurstFire
	bUseFireModes=true
	bSingleFireBasedROF=true

	MuzzleFlashVariations=Texture'TODatas.Muzzle.Muz3'
	MaxDamage=55.0
	clipSize=20
	clipAmmo=20
	MaxClip=4
	RoundPerMin=280
	bTracingBullets=true
	TraceFrequency=4
	Price=3850
	ClipPrice=50
	BotAimError=1.0
	PlayerAimError=0.5
	VRecoil=300.0
	HRecoil=2.0
	WeaponID=34
	WeaponClass=3
	WeaponWeight=22.0
	aReloadWeapon=(AnimSeq=Reload,AnimRate=0.35)
	MaxWallPiercing=30.0
	MaxRange=14400.0
	ProjectileSpeed=15000.0

	MuzRadius=64
	MuzScale=3.000000
	MuzX=606
	MuzY=451
	XSurroundCorrection=1.15
	YSurroundCorrection=0.9

	WeaponDescription="Classification: M16 A2 w/ Laser Aim"
	PickupAmmoCount=20
	bRapidFire=false
	Mass=25.000000
	MyDamageType=shot
	shakemag=250.000000
	shaketime=0.300000
	shakevert=9.000000
	AIRating=0.650000
	RefireRate=0.990000
	AltRefireRate=0.990000
	FireSound=Sound'TODatas.Weapons.SR9_fire'
	SelectSound=Sound'TODatas.Weapons.Pistol_select'
	DeathMessage="%k's %w turned %o into a leaky piece of meat."
	NameColor=(B=0)
	bDrawMuzzleFlash=True
	MuzzleScale=0.800000
	FlashY=-0.060000
	FlashC=0.002000
	FlashLength=0.001000
	FlashS=64
	AutoSwitchPriority=34
	InventoryGroup=4
	PickupMessage="You picked up the M16A2 !"
	ItemName="M16A2"
	PlayerViewOffset=(X=220.000000,Y=160.000000,Z=-230.000000)
	PlayerViewMesh=SkeletalMesh'TOModels.m16Mesh'
	PlayerViewScale=0.12
	BobDamping=0.975000
	PickupViewMesh=LodMesh'TOModels.pM16'
	ThirdPersonMesh=LodMesh'TOModels.wM16'
	Mesh=LodMesh'TOModels.phksr9'
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
	ArmsNb=6

	ShellCaseType="s_SWAT.s_762ShellCase"

	SolidTex=texture'TOST4TexSolid.HUD.M16'
	TransTex=texture'TOST4TexTrans.HUD.M16'
}
