class TOMAFAMAS expands s_Weapon;
// Original code from Laurent "Shag" Delayen

#exec OBJ LOAD FILE=..\Sounds\TOMASounds21.uax PACKAGE=TOMASounds21

var() texture MuzzleFlashVariations;

simulated event RenderOverlays(canvas Canvas)
{
	MFTexture=MuzzleFlashVariations;
	Super.RenderOverlays(Canvas);
}

function AltFire(float Value)
{
}

simulated function PlayIdleAnim()
{
	if (Mesh==PickupViewMesh)
		return;

	if ((FRand()>0.98) && (AnimSequence!='idle1'))
		PlayAnim('idle1',0.07);
	else
		LoopAnim('idle',0.2,0.3);
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
     MuzzleFlashVariations=Texture'TODatas.Muzzle.Muz3'
    MaxDamage=25
    clipSize=25
    clipAmmo=25
    MaxClip=6
    RoundPerMin=950
    bTracingBullets=True
    TraceFrequency=4
    price=3500
    BotAimError=0.64
    PlayerAimError=0.32
    VRecoil=100
    HRecoil=7
    bHasMultiSkins=True
    ArmsNb=5
    WeaponID=32
    WeaponClass=3
    WeaponWeight=25
    aReloadWeapon=(AnimSeq=Reload,AnimRate=0.50)
    MaxWallPiercing=25
    MaxRange=5760
    ProjectileSpeed=15000
    FireModes(0)=FM_FullAuto
    FireModes(1)=FM_BurstFire
    FireModes(2)=FM_SingleFire
    bUseFireModes=True
     MuzScale=3.500000
     MuzX=621
     MuzY=471
     MuzRadius=64
    ShellCaseType="s_SWAT.TO_556SC"
    WeaponDescription="Classification: FAMAS"
    PickupAmmoCount=25
    bRapidFire=True
    FireOffset=(X=8,Y=-5, Z=0)
    MyDamageType=shot
    shakemag=250
    shaketime=0.30
    shakevert=6
    AIRating=0.70
    RefireRate=0.99
    AltRefireRate=0.99
    FireSound=Sound'TOMASounds21.Weapons.famasfire'
    SelectSound=Sound'Botpack.enforcer.Cocking'
    DeathMessage="%k's %w turned %o into a leaky piece of meat."
    NameColor=(R=255,G=255,B=0,A=0)
    bDrawMuzzleFlash=True
    MuzzleScale=0.700000
    FlashY=-0.06
    FlashC=0
    FlashLength=0
    FlashS=64
    AutoSwitchPriority=32
    InventoryGroup=4
    PickupMessage="You got the FAMAS!"
    ItemName="FAMAS"
    PlayerViewOffset=(X=250,Y=120,Z=-80)
    PlayerViewMesh=LodMesh'TOMAModels21.FAMAS'
    PlayerViewScale=0.13
    BobDamping=0.98
    PickupViewMesh=LodMesh'TOMAModels21.pFAMAS'
    ThirdPersonMesh=LodMesh'TOMAModels21.wFAMAS'
    StatusIcon=Texture'Botpack.Icons.UseMini'
     MuzzleFlashStyle=STY_Translucent
     MuzzleFlashMesh=LodMesh'TOModels.TO3rdMuzzleHK33'
     MuzzleFlashScale=0.100000
     MuzzleFlashTexture=Texture'TOModels.3rdmuzzle5'
    PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
    Mesh=LodMesh'TOMAModels21.pFAMAS'
    CollisionHeight=10
}
