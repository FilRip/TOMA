//=============================================================================
// s_Glock
//=============================================================================
//
// Tactical Ops 
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen
//=============================================================================

class s_Glock extends s_Weapon;

var()								texture			MuzzleFlashVariations;


///////////////////////////////////////
// AltFire
///////////////////////////////////////

function AltFire( float Value )
{
}


///////////////////////////////////////
// RenderOverlays 
///////////////////////////////////////

simulated event RenderOverlays(canvas Canvas)
{
	MFTexture = MuzzleFlashVariations;

	Super.RenderOverlays(Canvas);
}


///////////////////////////////////////
// PlayIdleAnim 
///////////////////////////////////////

simulated function PlayIdleAnim()
{
	if ( Mesh == PickupViewMesh )
		return;

	if ( ClipAmmo > 0 )
		LoopAnim('idle',0.2, 0.3);
	else
		LoopAnim('FIXLAST',0.2, 0.3);
}


///////////////////////////////////////
// ForceStillFrame
///////////////////////////////////////

simulated function ForceStillFrame()
{
	TweenToStill();

	if ( ClipAmmo > 0 )
		PlayAnim('Fix', 2.0, 0.1);
	else
		LoopAnim('FIXLAST',0.2, 0.3);
}


///////////////////////////////////////
// PlayFiring 
///////////////////////////////////////

simulated function PlayFiring()
{
	Super.PlayFiring();

	if ( ClipAmmo < 2 )
		PlaySynchedAnim('FIRELAST', rofmultiplier / RoundPerMin, 0.01);
}


///////////////////////////////////////
// PlayClipOut 
///////////////////////////////////////

simulated function PlayClipOut()
{
	//if ( Level.NetMode != NM_DedicatedServer )	
	//	PlaySound(Sound'TODatas.BerClipIn', SLOT_None, 4.0);
	PlayWeaponSound(Sound'TODatas.BerClipIn');
}


///////////////////////////////////////
// PlayClipIn 
///////////////////////////////////////

simulated function PlayClipIn()
{
	//if ( Level.NetMode != NM_DedicatedServer )	
	//	PlaySound(Sound'TODatas.BerClipOut', SLOT_None, 4.0);
	PlayWeaponSound(Sound'TODatas.BerClipOut');
}


///////////////////////////////////////
// PlayClipReload² 
///////////////////////////////////////

simulated function PlayClipReload()
{
	//if ( Level.NetMode != NM_DedicatedServer )	
	//	PlaySound(Sound'TODatas.BerReload', SLOT_None, 4.0);
	PlayWeaponSound(Sound'TODatas.BerReload');
}


///////////////////////////////////////
// defaultproperties 
///////////////////////////////////////
// PlayerViewOffset=(X=350.000000,Y=125.000000,Z=-100.000000)

defaultproperties
{
     MuzzleFlashVariations=Texture'TODatas.Muzzle.Muz9'
     clipSize=13
     clipAmmo=13
     MaxClip=5
     RoundPerMin=240
     price=400
     ClipPrice=15
     bSingleFireBasedROF=True
     BotAimError=0.220000
     PlayerAimError=0.110000
     VRecoil=250.000000
     HRecoil=10.000000
     bHasMultiSkins=True
     ArmsNb=3
     WeaponID=12
     WeaponClass=1
     WeaponWeight=2.000000
     aReloadWeapon=(AnimSeq=Reload,AnimRate=0.400000)
     EmptyClipSound=Sound'TODatas.Weapons.Empty1'
     MaxWallPiercing=5.000000
     MaxRange=1440.000000
     bHeavyWallHit=False
     FireModes(0)=FM_SingleFire
     FireModes(1)=FM_BurstFire
     bUseFireModes=True
     MuzScale=2.500000
     MuzX=645
     MuzY=495
     MuzRadius=64
     WeaponDescription="Classification: Glock21"
     InstFlash=-0.200000
     InstFog=(X=400.000000,Y=225.000000,Z=95.000000)
     PickupAmmoCount=30
     FiringSpeed=1.500000
     FireOffset=(X=8.000000,Y=-5.000000)
     MyDamageType=shot
     shakemag=250.000000
     shaketime=0.300000
     shakevert=6.000000
     AIRating=0.400000
     RefireRate=0.800000
     AltRefireRate=0.870000
     FireSound=Sound'TODatas.Weapons.glockfire'
     SelectSound=Sound'Botpack.enforcer.Cocking'
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
     PickupMessage="You picked up a Glock21!"
     ItemName="Glock21"
     PlayerViewOffset=(X=345.000000,Y=110.000000,Z=-145.000000)
     PlayerViewMesh=LodMesh'TOModels.Glock'
     PlayerViewScale=0.125000
     PickupViewMesh=LodMesh'TOModels.pGlock'
     ThirdPersonMesh=LodMesh'TOModels.wGlock'
     bMuzzleFlashParticles=True
     MuzzleFlashStyle=STY_Translucent
     MuzzleFlashMesh=LodMesh'Botpack.muzzEF3'
     MuzzleFlashScale=0.080000
     MuzzleFlashTexture=Texture'Botpack.Skins.Muzzy2'
     PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
     bHidden=True
     Mesh=LodMesh'TOModels.pGlock'
     CollisionRadius=20.000000
     CollisionHeight=10.000000
     Mass=15.000000
}
