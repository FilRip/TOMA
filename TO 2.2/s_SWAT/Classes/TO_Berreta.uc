//=============================================================================
// TO_Berreta
//=============================================================================
//
// Tactical Ops
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen
//=============================================================================

class TO_Berreta extends s_Weapon;

var()								texture			MuzzleFlashVariations;


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
	{
		if ( (FRand() > 0.98) && (AnimSequence != 'idle1') ) 
			PlayAnim('idle1', 0.15);
		else 
			LoopAnim('idle',0.2, 0.3);
	}
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
		PlaySynchedAnim('FIRELAST', 60.0 / RoundPerMin, 0.01);
}


///////////////////////////////////////
// PlayClipOut 
///////////////////////////////////////

simulated function PlayClipOut()
{
	//if ( Level.NetMode != NM_DedicatedServer )	
	//	PlaySound(Sound'TODatas.BerClipIn', SLOT_None, 4.0);
	PlayWeaponSound(Sound'BerClipIn');
}


///////////////////////////////////////
// PlayClipIn 
///////////////////////////////////////

simulated function PlayClipIn()
{
	//if ( Level.NetMode != NM_DedicatedServer )	
	//	PlaySound(Sound'TODatas.BerClipOut', SLOT_None, 4.0);
	PlayWeaponSound(Sound'BerClipOut');
}


///////////////////////////////////////
// PlayClipReload
///////////////////////////////////////

simulated function PlayClipReload()
{
	//if ( Level.NetMode != NM_DedicatedServer )	
	//	PlaySound(Sound'TODatas.BerReload', SLOT_None, 4.0);
	PlayWeaponSound(Sound'BerReload');
}

/*
simulated function TweenDown()
{
	if ( IsAnimating() && (AnimSequence != '') && (GetAnimGroup(AnimSequence) == 'Select') )
		TweenAnim( AnimSequence, AnimFrame * 0.4 );
	else
		PlayAnim('Down', 1.0, 0.05);
}
*/

///////////////////////////////////////
// defaultproperties 
///////////////////////////////////////
//PlayerViewOffset=(X=275.000000,Y=100.000000,Z=-50.000000)

defaultproperties
{
     MuzzleFlashVariations=Texture'TODatas.Muzzle.Muz6'
     clipSize=15
     clipAmmo=15
     MaxClip=4
     RoundPerMin=300
     price=500
     ClipPrice=15
     BotAimError=0.200000
     PlayerAimError=0.100000
     VRecoil=300.000000
     HRecoil=5.000000
     bHasMultiSkins=True
     ArmsNb=3
     WeaponID=13
     WeaponClass=1
     WeaponWeight=5.000000
     aReloadWeapon=(AnimSeq=Reload,AnimRate=0.450000)
     EmptyClipSound=Sound'TODatas.Weapons.Empty1'
     MaxWallPiercing=8.000000
     MaxRange=1440.000000
     bHeavyWallHit=False
     FireModes(0)=FM_SingleFire
     bUseFireModes=True
     MuzScale=3.700000
     MuzX=616
     MuzY=485
     MuzRadius=64
     WeaponDescription="Classification: Beretta 92F"
     InstFlash=-0.200000
     InstFog=(X=325.000000,Y=225.000000,Z=50.000000)
     PickupAmmoCount=30
     FiringSpeed=1.500000
     FireOffset=(Y=-10.000000,Z=-4.000000)
     MyDamageType=shot
     shakemag=250.000000
     shaketime=0.300000
     shakevert=10.000000
     AIRating=0.500000
     RefireRate=0.800000
     AltRefireRate=0.870000
     FireSound=Sound'TODatas.Weapons.BerFire'
     SelectSound=Sound'Botpack.enforcer.Cocking'
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
     PickupMessage="You picked up a Beretta 92F pistol!"
     ItemName="Beretta92F"
     PlayerViewOffset=(X=250.000000,Y=80.000000,Z=-110.000000)
     PlayerViewMesh=LodMesh'TOModels.Berreta'
     PlayerViewScale=0.125000
     PickupViewMesh=LodMesh'TOModels.pberetta'
     ThirdPersonMesh=LodMesh'TOModels.wberetta'
     bMuzzleFlashParticles=True
     MuzzleFlashStyle=STY_Translucent
     MuzzleFlashMesh=LodMesh'Botpack.muzzEF3'
     MuzzleFlashScale=0.080000
     MuzzleFlashTexture=Texture'Botpack.Skins.Muzzy2'
     PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
     bHidden=True
     Mesh=LodMesh'TOModels.pberetta'
     CollisionRadius=20.000000
     CollisionHeight=10.000000
     Mass=15.000000
}
