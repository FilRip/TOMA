//----------------------------------------------------------------------------
// Project : TOST
// File    : TOST_M4m203.uc
// Version : 0.5
// Author  : BugBunny/Shag
//----------------------------------------------------------------------------
// Version	Changes
// 0.5		+ first release
//----------------------------------------------------------------------------

class TOST_M4m203 expands TOSTWeapon;

var() texture MuzzleFlashVariations;

replication
{
	// Functions server calls on clients
	reliable if ( Role == ROLE_Authority )
		ClientChangeFireMode;
}

simulated event RenderOverlays( canvas Canvas )
{
	if ( !bAltMode )
		MFTexture = MuzzleFlashVariations;
	else
		MFTexture = None;

	Super.RenderOverlays(Canvas);
}

function GenerateBullet()
{
	local	s_SWATGame	SG;

	// Enhance to support UT GameTypes
	SG = s_SWATGame(Level.Game);

	if ( UseAmmo(1) )
	{
		if ( bAltMode )
			GenerateRocket();
		else
		{
			// If playing a singleplayer game, keep track of the player's shots
			if ( Owner.IsA('PlayerPawn') && (s_SWATGame(Level.Game) != None)
				&& (s_SWATGame(Level.Game).bSinglePlayer && s_Player(Owner) != None) )
				s_SWATGame(Level.Game).IncrementPlayerShotsFired(Pawn(Owner));

			FiringEffects();

			if ( (SG != None) && SG.bEnableBallistics )
				TraceFireBallistics(AimError);
			else
				TraceFire(AimError);
		}
	}
}

function GenerateRocket()
{
	local vector FireLocation, StartLoc, X,Y,Z;
	local rotator FireRot;
	local rocketmk2 r;
	local pawn PawnOwner;
	local PlayerPawn PlayerOwner;

	PawnOwner = Pawn(Owner);
	if ( PawnOwner == None )
		return;

	PlayerOwner = PlayerPawn(Owner);
	GetAxes(PawnOwner.ViewRotation,X,Y,Z);
	StartLoc = Owner.Location + TOCalcDrawOffset() + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z;

	AdjustedAim = PawnOwner.AdjustToss(AltProjectileSpeed, StartLoc, AimError, True, bAltWarnTarget);

	if ( PlayerOwner != None )
		AdjustedAim = PawnOwner.ViewRotation;

	FireLocation = StartLoc;

	r = Spawn(class'TO_40mmProj',, '', StartLoc, AdjustedAim);
}

simulated function PlayReloadWeapon()
{
	Super.PlayReloadWeapon();

	if ( !bAltMode )
		PlayAnim('Reload', 0.47, 0.05);
	else
		PlayAnim('RELOADGREN', 0.4, 0.05);
}

simulated function PlayFiring()
{
	if ( bAltMode )
		FireSound = Sound'TODatas.OICWGrenFire';
	else
		FireSound = Sound'TODatas.m4fire';

	Super.PlayFiring();

	if ( bAltMode )
		PlaySynchedAnim('firegren', rofmultiplier / RoundPerMin, 0.01);
}

simulated function PlayIdleAnim()
{
	if ( Mesh == PickupViewMesh )
		return;

	if ( !bAltMode )
	{
		if ( (FRand() > 0.98) && (AnimSequence != 'idle1') )
			PlayAnim('idle1', 0.15);
		else
			LoopAnim('idle',0.2, 0.3);
	}
	else
		LoopAnim('gren_2framer',0.2, 0.3);
}

simulated function ForceStillFrame()
{
	TweenToStill();

	if ( !bAltMode )
		PlayAnim('Fix', 2.0, 0.1);
	else
		LoopAnim('gren_2framer',0.2, 0.3);
}

simulated function bool DoChangeFireMode()
{
	local	byte	msg;

	// Force server to be da king for fire mode changing
	if ( Role < Role_Authority )
		return true;

	if ( bAltMode )
	{
		ClientChangeFireMode( false );
		ChangeFireModeSpecs( false );
		msg = 8;
	}
	else
	{
		ClientChangeFireMode( true );
		ChangeFireModeSpecs( true );
		msg = 9;
	}

	if ( Owner.IsA('s_BPlayer') )
		Pawn(Owner).ReceiveLocalizedMessage(class's_WeaponMessages', msg );

	return true;
}

simulated function ClientChangeFireMode( bool DesiredbAltMode )
{
	if ( Role == Role_Authority )
		return;

	ChangeFireModeSpecs( DesiredbAltMode );
}

simulated function ChangeFireModeSpecs( bool DesiredbAltMode )
{
	local		int			BClip, BAmmo, BClipSize, BMaxClip, BClipPrice;
	local		string	BAmmoName;

	bAltMode = DesiredbAltMode;
	bMuzzleFlash = 0;

	// Switching Ammo
	BClip = BackupClip;
	BAmmo = BackupAmmo;
	BClipSize = BackupClipSize;
	BMaxClip = BackupMaxClip;
	BClipPrice = BackupClipPrice;
	BAmmoName = BackupAmmoName;

	BackupClip = RemainingClip;
	BackupAmmo = ClipAmmo;
	BackupClipSize = ClipSize;
	BackupMaxClip = MaxClip;
	BackupClipPrice = ClipPrice;
	BackupAmmoName = AmmoName;

	RemainingClip = BClip;
	ClipAmmo = BAmmo;
	ClipSize = BClipSize;
	MaxClip = BMaxClip;
	ClipPrice = BClipPrice;
	AmmoName = BAmmoName;

	if ( bAltMode )
	{
		CurrentFireMode = 1;
		RoundPerMin = AltRoundPerMin;
	}
	else
	{
		CurrentFireMode = 0;
		RoundPerMin = Default.RoundPerMin;
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
	AmmoName="5.56mm"
	BackupAmmoName="40mm HE"

	BackupClip=0
	BackupAmmo=1
	BackupClipSize=1
	BackupMaxClip=4
	BackupClipPrice=500

	MaxDamage=30.5
	clipSize=30
	clipAmmo=30
	MaxClip=5
	RoundPerMin=675
	bTracingBullets=true
	TraceFrequency=4
	Price=10000
	ClipPrice=50

	BotAimError=0.64
	PlayerAimError=0.32
	VRecoil=110.0
	HRecoil=5.0
	WeaponID=40
	WeaponClass=3
	AutoSwitchPriority=38
	InventoryGroup=4
	WeaponWeight=30.0
	aReloadWeapon=(AnimSeq=Reload)
	MaxWallPiercing=25.0
	MaxRange=6000.0
	ProjectileSpeed=15000.0
	FireModes(0)=FM_FullAuto
	FireModes(1)=FM_SingleFire
	bUseFireModes=true

	MuzzleFlashVariations=Texture'TODatas.Muzzle.Muz3'
	MuzRadius=64
	MuzScale=4.0
	MuzX=609
	MuzY=454
	XSurroundCorrection=1.3
	YSurroundCorrection=0.9

	WeaponDescription="Classification: M4A1 m203 rifle"
	PickupAmmoCount=25
	bRapidFire=True
	Mass=25.000000
	MyDamageType=shot
	shakemag=250.0
	shaketime=0.3
	AIRating=0.73
	RefireRate=0.99
	AltRefireRate=0.99
	FireSound=None
	SelectSound=Sound'TODatas.Weapons.Pistol_select'
	bDrawMuzzleFlash=true
	MuzzleScale=0.8
	FlashY=-0.06
	FlashC=0.002
	FlashLength=0.001
	FlashS=64
	PickupMessage="You got a M4A1m203 rifle!"
	ItemName="M4m203"
	PlayerViewScale=0.125
	PlayerViewOffset=(X=140.0,Y=160.0,Z=-250.0)
	PlayerViewMesh=SkeletalMesh'TOModels.m4m203Mesh'

	BobDamping=0.975000
	PickupViewMesh=LodMesh'TOModels.pM4m203'
	ThirdPersonMesh=LodMesh'TOModels.wM4m203'
	Mesh=LodMesh'TOModels.pOICW'
	bMuzzleFlashParticles=false
	MuzzleFlashStyle=STY_Translucent
	MuzzleFlashMesh=LodMesh'TOModels.TO3rdMuzzleM4A1'
	MuzzleFlashScale=0.1
	MuzzleFlashTexture=Texture'TOModels.3rdmuzzle1'
	PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
	bNoSmooth=False

	CollisionRadius=30.0
	CollisionHeight=10.0

	bHasMultiSkins=true
	ArmsNb=3

	ShellCaseType="s_SWAT.TO_556SC"

	AltRoundPerMin=100

	SolidTex=texture'TOST4TexSolid.HUD.M4m203'
	TransTex=texture'TOST4TexTrans.HUD.M4m203'
}
