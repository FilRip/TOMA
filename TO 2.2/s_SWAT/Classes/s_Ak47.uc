//=============================================================================
// s_Ak47
//=============================================================================
//
// Tactical Ops
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen
//=============================================================================

class s_Ak47 expands s_Weapon;

var() texture MuzzleFlashVariations;


 
///////////////////////////////////////
// RenderOverlays 
///////////////////////////////////////

simulated event RenderOverlays(canvas Canvas)
{
	MFTexture = MuzzleFlashVariations;

	Super.RenderOverlays(Canvas);
}


///////////////////////////////////////
// AltFire
///////////////////////////////////////

function AltFire( float Value )
{
}


///////////////////////////////////////
// ClientAltFire
///////////////////////////////////////

simulated function bool ClientAltFire( float Value )
{
}


///////////////////////////////////////
// PlayAltFiring
///////////////////////////////////////

simulated function PlayAltFiring()
{ 
}


///////////////////////////////////////
// PlayIdleAnim 
///////////////////////////////////////

simulated function PlayIdleAnim()
{
	if ( Mesh == PickupViewMesh )
		return;
	if ( (FRand() > 0.98) && (AnimSequence != 'idle1') ) 
		PlayAnim('idle1', 0.15);
	else 
		LoopAnim('idle',0.2, 0.3);
}


///////////////////////////////////////
// ClipIn
///////////////////////////////////////

simulated function ClipIn()
{
	//PlayOwnedSound(Sound'TODatas.HK33Clipout', SLOT_None, 255);
	PlayWeaponSound(Sound'TODatas.HK33Clipout');
}


///////////////////////////////////////
// ClipOut
///////////////////////////////////////

simulated function ClipOut()
{
	//if ( Level.NetMode != NM_DedicatedServer )	
	//	PlaySound(Sound'TODatas.OICWClipout1', SLOT_None, 4.0);
	PlayWeaponSound(Sound'TODatas.OICWClipout1');
}


///////////////////////////////////////
// ClipLever
///////////////////////////////////////

simulated function ClipLever()
{
	//if ( Level.NetMode != NM_DedicatedServer )	
	//	PlaySound(Sound'TODatas.OICWClipout2', SLOT_None, 4.0);
	PlayWeaponSound(Sound'TODatas.OICWClipout2');
}


///////////////////////////////////////
// defaultproperties
///////////////////////////////////////
// MuzzleFlashVariations=Texture'Botpack.Skins.Flakmuz'

defaultproperties
{
     MuzzleFlashVariations=Texture'TODatas.Muzzle.Muz5'
     MaxDamage=30.000000
     clipSize=30
     clipAmmo=30
     MaxClip=4
     RoundPerMin=700
     bTracingBullets=True
     TraceFrequency=4
     price=3200
     ClipPrice=40
     BotAimError=0.600000
     PlayerAimError=0.300000
     VRecoil=100.000000
     HRecoil=10.000000
     RecoilMultiplier=0.015000
     bHasMultiSkins=True
     ArmsNb=7
     WeaponID=33
     WeaponClass=3
     WeaponWeight=15.000000
     aReloadWeapon=(AnimSeq=Reload,AnimRate=0.400000)
     MaxWallPiercing=20.000000
     ProjectileSpeed=15000.000000
     FireModes(0)=FM_FullAuto
     FireModes(1)=FM_SingleFire
     bUseFireModes=True
     MuzScale=3.500000
     MuzX=595
     MuzY=452
     MuzRadius=64
     ShellCaseType="s_SWAT.TO_556SC"
     WeaponDescription="Classification: Ak 47"
     PickupAmmoCount=30
     bRapidFire=True
     FireOffset=(X=8.000000,Y=-5.000000)
     MyDamageType=shot
     shakemag=280.000000
     shaketime=0.300000
     shakevert=8.000000
     AIRating=0.650000
     RefireRate=0.990000
     AltRefireRate=0.990000
     FireSound=Sound'TODatas.Weapons.Ak47fire'
     SelectSound=Sound'Botpack.enforcer.Cocking'
     DeathMessage="%k's %w turned %o into a leaky piece of meat."
     NameColor=(B=0)
     bDrawMuzzleFlash=True
     MuzzleScale=0.700000
     FlashY=-0.060000
     FlashC=0.002000
     FlashLength=0.001000
     FlashS=64
     AutoSwitchPriority=33
     InventoryGroup=4
     PickupMessage="You got the Ak 47!"
     ItemName="Ak47"
     PlayerViewOffset=(X=200.000000,Y=105.000000,Z=-70.000000)
     PlayerViewMesh=LodMesh'TOModels.Ak47'
     PlayerViewScale=0.130000
     BobDamping=0.975000
     PickupViewMesh=LodMesh'TOModels.pAK47'
     ThirdPersonMesh=LodMesh'TOModels.wAK47'
     MuzzleFlashStyle=STY_Translucent
     MuzzleFlashMesh=LodMesh'TOModels.TO3rdMuzzleAk'
     MuzzleFlashScale=0.250000
     MuzzleFlashTexture=Texture'Botpack.Skins.Muzzy'
     PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
     Mesh=LodMesh'TOModels.pAK47'
     CollisionHeight=10.000000
}
