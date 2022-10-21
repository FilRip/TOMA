//=============================================================================
// s_FAMAS
//=============================================================================
//
// Tactical Ops
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen
//=============================================================================

class s_FAMAS expands s_Weapon;

var() texture MuzzleFlashVariations[6];



///////////////////////////////////////
//  RenderOverlays
///////////////////////////////////////

simulated event RenderOverlays( canvas Canvas )
{	
/*
	MuzFrame++;
	if (MuzFrame > 11)
		MuzFrame = 0;
	MFTexture = MuzzleFlashVariations[MuzFrame/2];
*/
	MFTexture = MuzzleFlashVariations[0];

	Super.RenderOverlays(Canvas);
}


///////////////////////////////////////
// AltFire
///////////////////////////////////////

function AltFire( float Value )
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
		PlayAnim('idle1', 0.07);
	else 
		LoopAnim('idle', 0.2, 0.3);
}


///////////////////////////////////////
// ClipIn
///////////////////////////////////////

simulated function ClipIn()
{
	//if ( Level.NetMode != NM_DedicatedServer )	
	//	PlaySound(Sound'TODatas.HK33Clipout', SLOT_None, 4.0);
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
/*
     MuzzleFlashVariations(0)=Texture'TODatas.Muzzle.MuzStd1'
     MuzzleFlashVariations(1)=Texture'TODatas.Muzzle.MuzStd2'
     MuzzleFlashVariations(2)=Texture'TODatas.Muzzle.MuzStd3'
     MuzzleFlashVariations(3)=Texture'TODatas.Muzzle.MuzStd4'
     MuzzleFlashVariations(4)=Texture'TODatas.Muzzle.MuzStd5'
     MuzzleFlashVariations(5)=Texture'TODatas.Muzzle.MuzStd6'

			 Misc1Sound=Sound'TODatas.Weapons.FAMAS_FAmbient'
		 Misc2Sound=Sound'TODatas.Weapons.FAMAS_FEnd'
*/

defaultproperties
{
     MuzzleFlashVariations(0)=Texture'TODatas.Muzzle.Muz4'
     MaxDamage=23.000000
     clipSize=25
     clipAmmo=25
     MaxClip=6
     RoundPerMin=950
     bTracingBullets=True
     TraceFrequency=4
     price=3500
     BotAimError=0.640000
     PlayerAimError=0.320000
     VRecoil=100.000000
     HRecoil=7.000000
     bHasMultiSkins=True
     ArmsNb=5
     WeaponID=32
     WeaponClass=3
     WeaponWeight=25.000000
     aReloadWeapon=(AnimSeq=Reload,AnimRate=0.500000)
     MaxWallPiercing=25.000000
     MaxRange=5760.000000
     ProjectileSpeed=15000.000000
     FireModes(0)=FM_FullAuto
     FireModes(1)=FM_BurstFire
     FireModes(2)=FM_SingleFire
     bUseFireModes=True
     MuzScale=2.500000
     MuzX=622
     MuzY=455
     MuzRadius=64
     ShellCaseType="s_SWAT.TO_556SC"
     WeaponDescription="Classification: FAMAS"
     PickupAmmoCount=25
     bRapidFire=True
     FireOffset=(X=8.000000,Y=-5.000000)
     MyDamageType=shot
     shakemag=250.000000
     shaketime=0.300000
     shakevert=6.000000
     AIRating=0.700000
     RefireRate=0.990000
     AltRefireRate=0.990000
     FireSound=Sound'TODatas.Weapons.famasfire'
     SelectSound=Sound'Botpack.enforcer.Cocking'
     DeathMessage="%k's %w turned %o into a leaky piece of meat."
     NameColor=(B=0)
     bDrawMuzzleFlash=True
     MuzzleScale=0.800000
     FlashY=-0.060000
     FlashC=0.002000
     FlashLength=0.001000
     FlashS=64
     AutoSwitchPriority=32
     InventoryGroup=4
     PickupMessage="You got the FAMAS!"
     ItemName="FAMAS"
     PlayerViewOffset=(X=250.000000,Y=120.000000,Z=-80.000000)
     PlayerViewMesh=LodMesh'TOModels.FAMAS'
     PlayerViewScale=0.125000
     BobDamping=0.975000
     PickupViewMesh=LodMesh'TOModels.pFAMAS'
     ThirdPersonMesh=LodMesh'TOModels.wFAMAS'
     StatusIcon=Texture'Botpack.Icons.UseMini'
     bMuzzleFlashParticles=True
     MuzzleFlashStyle=STY_Translucent
     MuzzleFlashMesh=LodMesh'Botpack.MuzzFlash3'
     MuzzleFlashScale=0.250000
     MuzzleFlashTexture=Texture'Botpack.Skins.Muzzy'
     PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
     Mesh=LodMesh'TOModels.pFAMAS'
     CollisionHeight=10.000000
}
