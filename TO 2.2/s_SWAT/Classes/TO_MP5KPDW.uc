//=============================================================================
// TO_MP5KPDW
//=============================================================================
//
// Tactical Ops 
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen
//=============================================================================

class TO_MP5KPDW expands s_Weapon;

var() texture MuzzleFlashVariations;


///////////////////////////////////////
// RenderOverlays 
///////////////////////////////////////

simulated event RenderOverlays(canvas Canvas)
{
	MFTexture = None;

	Super.RenderOverlays(Canvas);
}


///////////////////////////////////////
// AltFire
///////////////////////////////////////

function AltFire( float Value )
{

}


///////////////////////////////////////
// TweenDown 
///////////////////////////////////////

simulated function TweenDown()
{
	if ( IsAnimating() && (AnimSequence != '') && (GetAnimGroup(AnimSequence) == 'Select') )
		TweenAnim( AnimSequence, AnimFrame * 0.4 );
	else
		PlayAnim('Down', 0.3, 0.05);
}


///////////////////////////////////////
// ClipIn
///////////////////////////////////////

simulated function ClipIn()
{
	//if ( Level.NetMode != NM_DedicatedServer )	
	//	PlaySound(Sound'TODatas.mp5magin', SLOT_None, 4.0);
	PlayWeaponSound(Sound'mp5magin');
}


///////////////////////////////////////
// ClipOut
///////////////////////////////////////

simulated function ClipOut()
{
	//if ( Level.NetMode != NM_DedicatedServer )	
	//	PlaySound(Sound'TODatas.mp5magout', SLOT_None, 4.0);
	PlayWeaponSound(Sound'mp5magout');
}


///////////////////////////////////////
// ClipLever
///////////////////////////////////////

simulated function ClipLever()
{
	//if ( Level.NetMode != NM_DedicatedServer )	
	//	PlaySound(Sound'TODatas.mp5maglever', SLOT_None, 4.0);
	PlayWeaponSound(Sound'mp5maglever');
}


///////////////////////////////////////
// defaultproperties
///////////////////////////////////////
// PlayerViewOffset=(X=250.000000,Y=100.000000,Z=-70.000000)
//		 Misc1Sound=Sound'TODatas.Weapons.MP5k_FAmbient'
//		 Misc2Sound=Sound'TODatas.Weapons.MP5k_FEnd'

defaultproperties
{
     MaxDamage=20.000000
     clipSize=30
     clipAmmo=30
     MaxClip=5
     RoundPerMin=850
     price=1600
     ClipPrice=40
     bShowWeaponLight=False
     BotAimError=0.260000
     PlayerAimError=0.130000
     VRecoil=60.000000
     HRecoil=20.000000
     bHasMultiSkins=True
     ArmsNb=4
     WeaponID=25
     WeaponClass=2
     aReloadWeapon=(AnimSeq=Reload,AnimRate=0.400000)
     MaxWallPiercing=12.000000
     MaxRange=1920.000000
     ProjectileSpeed=15000.000000
     bHeavyWallHit=False
     FireModes(0)=FM_FullAuto
     bUseFireModes=True
     MuzX=650
     MuzY=481
     WeaponDescription="Classification: MP5K-PDW"
     PickupAmmoCount=32
     bRapidFire=True
     FireOffset=(X=8.000000,Y=-5.000000)
     MyDamageType=shot
     shakemag=280.000000
     shaketime=0.250000
     shakevert=7.500000
     AIRating=0.550000
     RefireRate=0.990000
     AltRefireRate=0.990000
     FireSound=Sound'TODatas.Weapons.mp5silenced'
     SelectSound=Sound'Botpack.enforcer.Cocking'
     DeathMessage="%k's %w turned %o into a leaky piece of meat."
     NameColor=(B=0)
     bDrawMuzzleFlash=True
     MuzzleScale=0.500000
     FlashY=0.030000
     FlashO=0.018000
     FlashC=0.002000
     FlashLength=0.001000
     FlashS=64
     AutoSwitchPriority=21
     InventoryGroup=3
     PickupMessage="You got the MP5K-PDW S.M.G.!"
     ItemName="MP5K-PDW"
     PlayerViewOffset=(X=230.000000,Y=120.000000,Z=-120.000000)
     PlayerViewMesh=LodMesh'TOModels.mp5kpdw'
     PlayerViewScale=0.135000
     BobDamping=0.975000
     PickupViewMesh=LodMesh'TOModels.pmp5kpdw'
     ThirdPersonMesh=LodMesh'TOModels.wmp5kpdw'
     bMuzzleFlashParticles=True
     MuzzleFlashStyle=STY_Translucent
     MuzzleFlashMesh=LodMesh'Botpack.MuzzFlash3'
     MuzzleFlashScale=0.250000
     MuzzleFlashTexture=Texture'Botpack.Skins.Muzzy'
     PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
     Mesh=LodMesh'TOModels.pmp5kpdw'
     CollisionRadius=20.000000
     CollisionHeight=15.000000
     Mass=18.000000
}
