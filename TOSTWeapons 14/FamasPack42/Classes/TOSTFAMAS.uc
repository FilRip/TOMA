//----------------------------------------------------------------------------
// Project : TOST
// File    : TOSTFAMAS.uc
// Version : 0.5
// Author  : BugBunny/Shag/H-Lotti
// Note	   : Original code by Shag
//----------------------------------------------------------------------------
// Version	Changes
// 0.5		+ first release
//----------------------------------------------------------------------------

class TOSTFAMAS expands TOSTWeaponNoRecoilBug;

var() texture MuzzleFlashVariations[6];

simulated event RenderOverlays( canvas Canvas )
{
	MFTexture = MuzzleFlashVariations[0];
	Super.RenderOverlays(Canvas);
}

function AltFire( float Value )
{
}

simulated function PlayIdleAnim()
{
	if ( Mesh == PickupViewMesh )
		return;

	if ( (FRand() > 0.98) && (AnimSequence != 'idle1') )
		PlayAnim('idle1', 0.07);
	else
		LoopAnim('idle', 0.2, 0.3);
}

simulated function ClipIn()
{
	PlayWeaponSound(Sound'FAMASClipin');
}

simulated function ClipOut()
{
	PlayWeaponSound(Sound'FAMASClipout');
}

simulated function ClipLever()
{
	PlayWeaponSound(Sound'FAMASClipLever');
}

defaultproperties
{
	AmmoName="5.56mm"
	BackupAmmoName=""

    MaxDamage=23.00
    clipSize=25
    clipAmmo=25
    MaxClip=6
    RoundPerMin=950
    bTracingBullets=True
    TraceFrequency=4
	Price=3500
	ClipPrice=50
    BotAimError=0.64
    PlayerAimError=0.32
    VRecoil=100.00
    HRecoil=7.00
    WeaponID=81
    WeaponClass=3
    WeaponWeight=25.00
    aReloadWeapon=(AnimSeq=Reload,AnimRate=0.50)
    MaxWallPiercing=25.00
    MaxRange=5760.00
    ProjectileSpeed=15000.00
	FireModes(0)=FM_FullAuto
	FireModes(1)=FM_BurstFire
	FireModes(2)=FM_SingleFire
	bUseFireModes=true

    MuzzleFlashVariations(0)=Texture'TODatas.Muzzle.Muz4'
    MuzRadius=64
    MuzScale=2.50
    MuzX=622
    MuzY=455
	XSurroundCorrection=1.15
	YSurroundCorrection=0.9

    WeaponDescription="Classification: FAMAS F1 5.56mm"
    PickupAmmoCount=25
    bRapidFire=True
	Mass=25.000000
    MyDamageType=shot
    shakemag=250.00
    shaketime=0.30
    shakevert=6.00
    AIRating=0.70
    RefireRate=0.99
    AltRefireRate=0.99
    FireSound=Sound'FAMASFire'

	SelectSound=Sound'TODatas.Weapons.Pistol_select'
    DeathMessage="%k's %w turned %o into a leaky piece of meat."
    NameColor=(B=0)
    bDrawMuzzleFlash=True
    MuzzleScale=0.80
    FlashY=-0.06
    FlashC=0.002
    FlashLength=0.001
    FlashS=64
    AutoSwitchPriority=81
    InventoryGroup=4
    PickupMessage="You picked up the FAMAS F1!"
    ItemName="FAMAS F1"
    PlayerViewOffset=(X=250.00,Y=120.00,Z=-80.00)
    PlayerViewMesh=LodMesh'FAMAS'
    PlayerViewScale=0.13
    BobDamping=0.98
    PickupViewMesh=LodMesh'pFAMAS'
    ThirdPersonMesh=LodMesh'wFAMAS'
    Mesh=LodMesh'pFAMAS'
    StatusIcon=Texture'Botpack.Icons.UseMini'
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
	ArmsNb=5

	ShellCaseType="s_SWAT.TO_556SC"

	SolidTex=texture'FAMASSolid'
	TransTex=texture'FAMASTrans'
}
