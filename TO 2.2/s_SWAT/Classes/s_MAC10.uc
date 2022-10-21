//=============================================================================
// s_MAC10
//=============================================================================
//
// Tactical Ops 
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen
//=============================================================================

class s_MAC10 expands s_Weapon;

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
// ClientFire
///////////////////////////////////////

simulated function bool ClientFire( float Value )
{
	if ( Super.ClientFire( Value ) )
		Enable('Tick');
}


///////////////////////////////////////
// AltFire
///////////////////////////////////////

function AltFire( float Value )
{

}


///////////////////////////////////////
// ClipIn
///////////////////////////////////////

simulated function ClipIn()
{
	//if ( Level.NetMode != NM_DedicatedServer )	
	//	PlaySound(Sound'TODatas.macmagin', SLOT_None, 4.0);
	PlayWeaponSound(Sound'TODatas.macmagin');
}


///////////////////////////////////////
// ClipOut
///////////////////////////////////////

simulated function ClipOut()
{
	//if ( Level.NetMode != NM_DedicatedServer )	
	//	PlaySound(Sound'TODatas.macmagout', SLOT_None, 4.0);
	PlayWeaponSound(Sound'TODatas.macmagout');
}


///////////////////////////////////////
// ClipLever
///////////////////////////////////////

simulated function ClipLever()
{
	//if ( Level.NetMode != NM_DedicatedServer )	
	//	PlaySound(Sound'TODatas.macmaglever', SLOT_None, 4.0);
	PlayWeaponSound(Sound'TODatas.macmaglever');
}


///////////////////////////////////////
// Draw1
///////////////////////////////////////

simulated function Draw1()
{
	//if ( Level.NetMode != NM_DedicatedServer )	
	//	PlaySound(Sound'TODatas.MACdraw1', SLOT_None, 4.0);
	PlayWeaponSound(Sound'TODatas.MACdraw1');
}


///////////////////////////////////////
// Draw2
///////////////////////////////////////

simulated function Draw2()
{
	//if ( Level.NetMode != NM_DedicatedServer )	
	//	PlaySound(Sound'TODatas.MACdraw2', SLOT_None, 4.0);
	PlayWeaponSound(Sound'TODatas.MACdraw2');
}


///////////////////////////////////////
// Down1
///////////////////////////////////////

simulated function Down1()
{
	//if ( Level.NetMode != NM_DedicatedServer )	
	//	PlaySound(Sound'TODatas.MACdown1', SLOT_None, 4.0);
	PlayWeaponSound(Sound'TODatas.MACdown1');
}


///////////////////////////////////////
// Down2
///////////////////////////////////////

simulated function Down2()
{
	//if ( Level.NetMode != NM_DedicatedServer )	
	//	PlaySound(Sound'TODatas.MACdown2', SLOT_None, 4.0);
	PlayWeaponSound(Sound'TODatas.MACdown2');
}


///////////////////////////////////////
// defaultproperties
///////////////////////////////////////
// PlayerViewOffset=(X=250.000000,Y=100.000000,Z=-70.000000)
// MuzzleFlashVariations=Texture'Botpack.Skins.Flakmuz'
//		 Misc1Sound=Sound'TODatas.Mac10Ambient'
//		 Misc2Sound=Sound'TODatas.MACEnd'

defaultproperties
{
     MuzzleFlashVariations=Texture'TODatas.Muzzle.Muz1'
     MaxDamage=15.000000
     clipSize=32
     clipAmmo=32
     MaxClip=6
     RoundPerMin=1000
     price=1000
     ClipPrice=30
     BotAimError=0.320000
     PlayerAimError=0.160000
     VRecoil=50.000000
     HRecoil=30.000000
     bHasMultiSkins=True
     ArmsNb=4
     WeaponID=21
     WeaponClass=2
     aReloadWeapon=(AnimSeq=Reload,AnimRate=0.600000)
     MaxWallPiercing=12.000000
     MaxRange=1440.000000
     ProjectileSpeed=15000.000000
     bHeavyWallHit=False
     FireModes(0)=FM_FullAuto
     bUseFireModes=True
     MuzScale=2.500000
     MuzX=643
     MuzY=499
     MuzRadius=64
     WeaponDescription="Classification: INGRAM MAC 10"
     PickupAmmoCount=32
     bRapidFire=True
     FireOffset=(X=8.000000,Y=-5.000000)
     MyDamageType=shot
     shakemag=400.000000
     shaketime=0.300000
     shakevert=9.000000
     AIRating=0.550000
     RefireRate=0.990000
     AltRefireRate=0.990000
     FireSound=Sound'TODatas.Weapons.real-mac-10'
     DeathMessage="%k's %w turned %o into a leaky piece of meat."
     NameColor=(B=0)
     bDrawMuzzleFlash=True
     MuzzleScale=0.500000
     FlashLength=0.001000
     FlashS=64
     AutoSwitchPriority=21
     InventoryGroup=3
     PickupMessage="You got the INGRAM MAC 10 S.M.G.!"
     ItemName="MAC 10"
     PlayerViewOffset=(X=240.000000,Y=100.000000,Z=-110.000000)
     PlayerViewMesh=LodMesh'TOModels.mac10'
     PlayerViewScale=0.120000
     BobDamping=0.975000
     PickupViewMesh=LodMesh'TOModels.mac10p'
     ThirdPersonMesh=LodMesh'TOModels.mac10w'
     bMuzzleFlashParticles=True
     MuzzleFlashStyle=STY_Translucent
     MuzzleFlashMesh=LodMesh'Botpack.MuzzFlash3'
     MuzzleFlashScale=0.250000
     MuzzleFlashTexture=Texture'Botpack.Skins.Muzzy'
     PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
     Mesh=LodMesh'TOModels.mac10p'
     CollisionRadius=20.000000
     CollisionHeight=10.000000
     Mass=18.000000
}
