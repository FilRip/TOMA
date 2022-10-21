//----------------------------------------------------------------------------
// Project : TOST
// File    : TOST_Saiga.uc
// Version : 0.5
// Author  : BugBunny/Shag
//----------------------------------------------------------------------------
// Version	Changes
// 0.5		+ first release
//----------------------------------------------------------------------------

class TOST_Saiga expands TOSTWeaponNoRecoilBug;

var() 	Texture MuzzleFlashVariations;
var		Texture	MagTextures[8];

var		float	DamageRadius;
var		int		NumPellets;

simulated event RenderOverlays(canvas Canvas)
{
	MFTexture = MuzzleFlashVariations;

	Super.RenderOverlays(Canvas);
}

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

		SpawnSC();
	}
}

function SpawnSC()
{
	local vector X, Y, Z;

	if ( Pawn(Owner) == None )
		return;

	GetAxes(Pawn(Owner).ViewRotation, X, Y, Z);

	SpawnShellCase(X, Y, Z);
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
	PlayWeaponSound(Sound'HK33Clipout');
}

simulated function ClipOut()
{
	PlayWeaponSound(Sound'OICWClipout1');
}

simulated function PlayFiring()
{
	Super.PlayFiring();
	if ( ClipAmmo <= 8 )
		MultiSkins[2] = MagTextures[ClipAmmo-1];
	else MultiSkins[2] = MagTextures[7];
}

simulated function NotifyMagRefill()
{
	MultiSkins[2] = MagTextures[7];
}

defaultproperties
{
	AmmoName="Shells"
	BackupAmmoName=""

	FireModes(0)=FM_FullAuto
	bUseFireModes=true

	DamageRadius=1.0
	NumPellets=8
	MaxDamage=19.5
	clipSize=7
	clipAmmo=7
	MaxClip=4
	RoundPerMin=150
	Price=2500
	ClipPrice=40

	bStaticAimError=true
	BotAimError=0.15
	PlayerAimError=0.17
	VRecoil=500.0
	HRecoil=10.0
	RecoilMultiplier=0.02

	WeaponID=24
	WeaponClass=2
	AutoSwitchPriority=24
	InventoryGroup=3
	WeaponWeight=20
	aReloadWeapon=(AnimSeq=Reload,AnimRate=0.35)
	MaxWallPiercing=8
	MaxRange=1440
	ProjectileSpeed=15000.0

	MuzScale=2.8
	MuzzleFlashVariations=Texture'TODatas.Muzzle.Muz1'
	MuzX=609
	MuzY=464
	MuzRadius=64
	XSurroundCorrection=1.12
	YSurroundCorrection=0.9

	WeaponDescription="Classification: Saiga 12s Automatic Shotgun"
	PickupAmmoCount=30
	bRapidFire=true
	Mass=25.0
	MyDamageType=shot
	shakemag=300.0
	shaketime=0.5
	shakevert=10.0
	AIRating=0.6
	RefireRate=0.99
	AltRefireRate=0.99
	FireSound=Sound'TODatas.SaigaShoot'
	SelectSound=Sound'TODatas.Weapons.Pistol_select'
	bDrawMuzzleFlash=true
	MuzzleScale=0.7
	FlashY=-0.06
	FlashC=0.002
	FlashLength=0.001
	FlashS=64

	PickupMessage="You picked up the Saiga 12 !"
	ItemName="Saiga 12"
	PlayerViewOffset=(X=180.0,Y=180.0,Z=-180.0)
	PlayerViewMesh=SkeletalMesh'TOModels.saigaMesh'
	PlayerViewScale=0.125
	BobDamping=0.975
	PickupViewMesh=LodMesh'TOModels.psaiga'
	ThirdPersonMesh=LodMesh'TOModels.wsaiga'
	Mesh=LodMesh'TOModels.psaiga'
	bMuzzleFlashParticles=false
	MuzzleFlashStyle=STY_Translucent
	MuzzleFlashMesh=LodMesh'TOModels.TO3rdMuzzle61'
	MuzzleFlashScale=0.1
	MuzzleFlashTexture=Texture'TOModels.3rdmuzzle6'
	PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
	bNoSmooth=false

	CollisionRadius=30.0
	CollisionHeight=15.0

	bHasMultiSkins=true
	ArmsNb=3

	bUseShellCase=false
	ShellCaseType="s_SWAT.s_12gaShellcase"

	MagTextures(0)=Texture'TOModels.SaigaMag0'
	MagTextures(1)=Texture'TOModels.SaigaMag1'
	MagTextures(2)=Texture'TOModels.SaigaMag2'
	MagTextures(3)=Texture'TOModels.SaigaMag3'
	MagTextures(4)=Texture'TOModels.SaigaMag4'
	MagTextures(5)=Texture'TOModels.SaigaMag5'
	MagTextures(6)=Texture'TOModels.SaigaMag6'
	MagTextures(7)=Texture'TOModels.SaigaMag7'

	SolidTex=texture'TOST4TexSolid.HUD.Saiga'
	TransTex=texture'TOST4TexTrans.HUD.Saiga'
}
