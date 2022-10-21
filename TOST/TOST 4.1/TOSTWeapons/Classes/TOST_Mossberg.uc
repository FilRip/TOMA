//----------------------------------------------------------------------------
// Project : TOST
// File    : TOST_Mossberg.uc
// Version : 0.5
// Author  : BugBunny/Shag
//----------------------------------------------------------------------------
// Version	Changes
// 0.5		+ first release
//----------------------------------------------------------------------------

class TOST_Mossberg extends TOSTWeapon;

var()	texture		MuzzleFlashVariations;

var		float		DamageRadius;
var		int			NumPellets;
var		int			BackRemainingClip, BackClipAmmo; // For client management

enum EShotReloadPhase
{
	SRP_PreReload,
	SRP_Reloading,
	SRP_PostReload,
};

var	EShotReloadPhase	ReloadPhase;

function GenerateBullet()
{
	local	s_SWATGame	SG;
	local	int					i;
	local	float				DR;

	SG = s_SWATGame(Level.Game);

	if ( UseAmmo(1) )
	{
		DR = DamageRadius / 2.0;
		FiringEffects();

		for (i=0; i<NumPellets; i++)
		{

			// If playing a singleplayer game, keep track of the player's shots
			if ( Owner.IsA('PlayerPawn') && (s_SWATGame(Level.Game) != None)
				&& (s_SWATGame(Level.Game).bSinglePlayer && s_Player(Owner) != None) )
				s_SWATGame(Level.Game).IncrementPlayerShotsFired(Pawn(Owner));

			if ( (i%NumPellets)==0 )
			{
				if ( (SG != None) && SG.bEnableBallistics )
					TraceFireBallistics(AimError * (FRand() * DamageRadius - DR) );
				else
					TraceFire(AimError * (FRand() * DamageRadius - DR) );
			}
			else
			{
				if ( (SG != None) && SG.bEnableBallistics )
					TraceFireBallisticsLow(AimError * (FRand() * DamageRadius - DR) );
				else
					TraceFireLow(AimError * (FRand() * DamageRadius - DR) );
			}
		}
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

	if ( (FRand() > 0.98) && (AnimSequence != 'idle1') )
		PlayAnim('idle1', 0.15);
	else
		LoopAnim('idle',0.2, 0.3);
}

simulated function PlayReloadWeapon()
{
	Super.PlayReloadWeapon();

	ReloadPhase = SRP_PreReload;

	PlayAnim('RELOAD', 0.5, 0.1);
}

simulated function PlayInsertShell()
{
	PlayAnim('INSERTSHELL', 0.6, 0.1);
}

simulated function PlayReloadEnd()
{
	PlayAnim('RELOADEND', 0.9, 0.1);
}

simulated function PlayPump()
{
	PlayWeaponSound(sound'MossPump');
}

simulated function PlayInsertShellSound()
{
	PlayWeaponSound(Sound'Moss_insert');
}

simulated function EjectShell()
{
	local vector X, Y, Z;

	if ( (Role != Role_Authority) || (Pawn(Owner) == None) )
		return;

	GetAxes(Pawn(Owner).ViewRotation, X, Y, Z);

	SpawnShellCase(X, Y, Z);
}

state ServerReloadWeapon
{
	ignores s_ReloadW, ChangeFireMode;

	function Fire(float F) {}
	function AltFire(float F) {}

	function BeginState()
	{
		bPointing = false;
		bReloadingWeapon = true;
	}

	function EndState()
	{
		bReloadingWeapon = false;
	}

	function AnimEnd()
	{
		if ( ReloadPhase == SRP_PostReload )
		{
			bReloadingWeapon = false;
			bCanClientFire = true;
			finish();
		}
		else
		{
			if ( (ReloadPhase != SRP_PreReload))
			{
				ClipAmmo++;
				RemainingClip--;
			}

			if ( (ClipAmmo < ClipSize) && (RemainingClip > 0) && (Pawn(Owner).bFire == 0) )
			{
				ReloadPhase = SRP_Reloading;
				PlayInsertShell();
			}
			else
			{
				ReloadPhase = SRP_PostReload;
				PlayReloadEnd();
			}
		}
	}

Begin:
	sleep(0.0);
}

state ClientReloadWeapon
{
	ignores s_ReloadW, ChangeFireMode;

	simulated function bool ClientFire( float Value ) { return false; }
	simulated function bool ClientAltFire( float Value ) { return false; }

	simulated function BeginState()
	{
		bReloadingWeapon = true;
		BackRemainingClip = RemainingClip;
		BackClipAmmo = ClipAmmo;
	}

	simulated function EndState()
	{
		bReloadingWeapon = false;
	}

	simulated function AnimEnd()
	{
		if ( (ReloadPhase != SRP_PreReload))
		{
			BackClipAmmo++;
			BackRemainingClip--;
		}

		if ( ReloadPhase == SRP_PostReload )
		{
			// Here to make sure Lag does not disable client firing animations
			bCanClientFire = true;

			bReloadingWeapon = false;
			PlayIdleAnim();
			GotoState('');
		}
		else
		{
			if ( (BackClipAmmo < ClipSize) && (BackRemainingClip > 0) && (Pawn(Owner).bFire == 0) )
			{
				ReloadPhase = SRP_Reloading;
				PlayInsertShell();
			}
			else
			{
				ReloadPhase = SRP_PostReload;
				PlayReloadEnd();
			}
		}
	}
}

defaultproperties
{
	AmmoName="Shells"
	BackupAmmoName=""

	DamageRadius=1.2
	NumPellets=10
	MaxDamage=18.5
	clipSize=8
	clipAmmo=8
	MaxClip=40
	ClipInc=8
	RoundPerMin=110
	Price=1200
	ClipPrice=4

	bStaticAimError=true
	BotAimError=0.18
	PlayerAimError=0.19
	VRecoil=1500.0
	HRecoil=1.0
	bHasMultiSkins=true
	WeaponID=22
	WeaponClass=2
	WeaponWeight=20.0
	aReloadWeapon=(AnimSeq=Reload)
	MaxWallPiercing=8.0
	MaxRange=1300.0

	FireModes(0)=FM_SingleFire
	bUseFireModes=true

	MuzzleFlashVariations=Texture'TODatas.Muzzle.Muz7'
	MuzScale=6.0
	MuzX=610
	MuzY=450
	MuzRadius=64
	XSurroundCorrection=1.88
	YSurroundCorrection=0.9

	WeaponDescription="Classification: Berg 509 Shotgun."
	InstFlash=-0.2
	InstFog=(X=375.00,Y=225.0,Z=70.0)
	PickupAmmoCount=30
	FiringSpeed=1.5
	MyDamageType=shot
	shaketime=0.3
	shakevert=10.0
	AIRating=0.55
	RefireRate=0.8
	AltRefireRate=0.87
	FireSound=Sound'TODatas.Weapons.MossShoot'
	SelectSound=Sound'TODatas.Weapons.Pistol_select'
	bDrawMuzzleFlash=true
	MuzzleScale=1.0
	FlashY=0.1
	FlashO=0.008
	FlashC=0.035
	FlashLength=0.01
	FlashS=128
	AutoSwitchPriority=22
	InventoryGroup=3
	PickupMessage="You picked up the Berg 509 Shotgun!"
	ItemName="Berg509"
	PlayerViewOffset=(X=195.0,Y=170.0,Z=-205.0)
	PlayerViewMesh=SkeletalMesh'TOModels.mossbergMesh'
	PlayerViewScale=0.125
	PickupViewMesh=LodMesh'TOModels.pmossberg'
	ThirdPersonMesh=LodMesh'TOModels.wmossberg'
	Mesh=LodMesh'TOModels.pmossberg'
	bMuzzleFlashParticles=false
	MuzzleFlashStyle=STY_Translucent
	MuzzleFlashMesh=LodMesh'TOModels.TO3rdMuzzle61'
	MuzzleFlashScale=0.1
	MuzzleFlashTexture=Texture'TOModels.3rdmuzzle6'
	PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
	bHidden=true
	bNoSmooth=false
	CollisionRadius=24.0
	CollisionHeight=12.0
	Mass=25.0
	ArmsNb=3

	bUseShellCase=false
	ShellCaseType="s_SWAT.s_12gaShellcase"

	SolidTex=texture'TOST4TexSolid.HUD.Mossberg'
	TransTex=texture'TOST4TexTrans.HUD.Mossberg'
}
