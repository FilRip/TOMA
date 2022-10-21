//=============================================================================
// TO_HK33
//=============================================================================
//
// Tactical Ops
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen
//=============================================================================

class TO_HK33 expands s_Weapon;

var() texture MuzzleFlashVariations;


///////////////////////////////////////
// PostRender
///////////////////////////////////////

simulated function PostRender( canvas Canvas )
{
	local s_BPlayer P;

	Super.PostRender(Canvas);
	P = s_BPlayer(Owner);
	if (P == None)
		return;

	if ( P.bSZoom ) 
	{
		if ((zoom_mode == 0 || zoom_mode == 1) && P.SZoomVal != 0.50)
			P.SZoomVal = 0.50;
		else if (zoom_mode == 2 && P.SZoomVal != 0.85)
			P.SZoomVal = 0.85;

		P.Bob = 0.1;
		bOwnsCrosshair = true;
		bMuzzleFlash = 0;
		VRecoil = 150.000000;
		HRecoil = 0.40000;
		Canvas.SetPos(0,0);

//		Canvas.bNoSmooth = false;
		if (P.bHUDModFix)
		{
			Canvas.Style = ERenderStyle.STY_Normal;
			Canvas.DrawTile(Texture'TODatas.Sniper4fix', Canvas.ClipX, Canvas.ClipY, 0, 0, 256, 256);
		}
		else
		{
			Canvas.Style = ERenderStyle.STY_Modulated;
			Canvas.DrawColor.R = 255;
			Canvas.DrawColor.G = 255;
			Canvas.DrawColor.B = 255;
		
			Canvas.DrawTile(Texture'TODatas.Sniper4', Canvas.ClipX, Canvas.ClipY, 0, 0, 256, 256);
		}
//		Canvas.bNoSmooth = true;	
	}
	else 
	{
		if (P.SZoomVal != 0.0)
			P.SZoomVal = 0.0;
		if (zoom_mode > 0)
			zoom_mode = 0;

		P.Bob = P.OriginalBob;
		VRecoil = 200.000000;
		HRecoil = 0.65000;
		if (P.bHideCrosshairs)
			bOwnsCrosshair = true;
		else
			bOwnsCrosshair = false;
	}
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
// AltFire
///////////////////////////////////////

function AltFire( float Value )
{
	ClientAltFire(Value);
}


///////////////////////////////////////
// ClientAltFire
///////////////////////////////////////

simulated function bool ClientAltFire( float Value )
{
	local	s_BPlayer	P;

	if ( Level.NetMode == NM_DedicatedServer )
		return false;

	PlaySound(Sound'scopezoom', SLOT_None);
	P = s_BPlayer(Owner);
	if ( P != None )
	{
		P.bSZoomStraight = true;
		
		zoom_mode++;
		if (zoom_mode > 1)
			zoom_mode = 0;
		if (P.bSZoom == false && zoom_mode > 0)
			P.ToggleSZoom();
		else if (P.bSZoom == true && zoom_mode == 0)
			P.ToggleSZoom();
		//PlaySound(Sound'NV_on', SLOT_None);
	}
	//GotoState('Zooming');
	return true;
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
	//if ( Level.NetMode != NM_DedicatedServer )	
	//	PlaySound(Sound'TODatas.HK33Clipout', SLOT_None, 4.0);
	PlayWeaponSound(Sound'HK33Clipout');
}


///////////////////////////////////////
// ClipOut
///////////////////////////////////////

simulated function ClipOut()
{
	//if ( Level.NetMode != NM_DedicatedServer )	
	//	PlaySound(Sound'TODatas.HK33ClipIn', SLOT_None, 4.0);
	PlayWeaponSound(Sound'HK33ClipIn');
}


///////////////////////////////////////
// ClipLever
///////////////////////////////////////

simulated function ClipLever()
{
	//if ( Level.NetMode != NM_DedicatedServer )	
	//	PlaySound(Sound'TODatas.OICWClipout2', SLOT_None, 4.0);
	PlayWeaponSound(Sound'OICWClipout2');
}


///////////////////////////////////////
// defaultproperties
///////////////////////////////////////
// MuzzleFlashVariations=Texture'Botpack.Skins.Flakmuz'

defaultproperties
{
     MuzzleFlashVariations=Texture'TODatas.Muzzle.Muz3'
     MaxDamage=35.000000
     clipSize=30
     clipAmmo=30
     MaxClip=4
     RoundPerMin=700
     bTracingBullets=True
     TraceFrequency=4
     price=4500
     ClipPrice=40
     BotAimError=0.840000
     PlayerAimError=0.420000
     VRecoil=80.000000
     HRecoil=5.000000
     RecoilMultiplier=0.015000
     bHasMultiSkins=True
     ArmsNb=4
     WeaponID=39
     WeaponClass=3
     WeaponWeight=15.000000
     aReloadWeapon=(AnimSeq=Reload,AnimRate=0.430000)
     MaxWallPiercing=20.000000
     MaxRange=9600.000000
     ProjectileSpeed=15000.000000
     FireModes(0)=FM_FullAuto
     bUseFireModes=True
     MuzScale=2.800000
     MuzX=601
     MuzY=466
     MuzRadius=64
     ShellCaseType="s_SWAT.TO_556SC"
     WeaponDescription="Classification: HK 33"
     PickupAmmoCount=30
     bRapidFire=True
     FireOffset=(X=8.000000,Y=-5.000000)
     MyDamageType=shot
     shakemag=280.000000
     shaketime=0.400000
     shakevert=9.000000
     AIRating=0.730000
     RefireRate=0.990000
     AltRefireRate=0.990000
     FireSound=Sound'TODatas.Weapons.hk33fire'
     SelectSound=Sound'Botpack.enforcer.Cocking'
     DeathMessage="%k's %w turned %o into a leaky piece of meat."
     NameColor=(B=0)
     bDrawMuzzleFlash=True
     MuzzleScale=0.700000
     FlashY=-0.060000
     FlashC=0.002000
     FlashLength=0.001000
     FlashS=64
     AutoSwitchPriority=39
     InventoryGroup=4
     PickupMessage="You got the HK 33!"
     ItemName="HK33"
     PlayerViewOffset=(X=230.000000,Y=120.000000,Z=-120.000000)
     PlayerViewMesh=LodMesh'TOModels.HK33'
     PlayerViewScale=0.120000
     BobDamping=0.975000
     PickupViewMesh=LodMesh'TOModels.phk33'
     ThirdPersonMesh=LodMesh'TOModels.whk33'
     bMuzzleFlashParticles=True
     MuzzleFlashStyle=STY_Translucent
     MuzzleFlashMesh=LodMesh'Botpack.MuzzFlash3'
     MuzzleFlashScale=0.250000
     MuzzleFlashTexture=Texture'Botpack.Skins.Muzzy'
     PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
     Mesh=LodMesh'TOModels.phk33'
     CollisionHeight=10.000000
}
