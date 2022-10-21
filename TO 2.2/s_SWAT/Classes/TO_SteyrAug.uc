//=============================================================================
// TO_SteyrAug
//=============================================================================
//
// Tactical Ops
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen
//=============================================================================

class TO_SteyrAug expands s_Weapon;

var() texture MuzzleFlashVariations[6];


///////////////////////////////////////
// PostRender
///////////////////////////////////////

simulated function PostRender( canvas Canvas )
{
	local s_BPlayer P;
	local	float	XO, YO, Scale, Scale128, Scale64;

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
		
		P.Bob = 0.10;
		VRecoil = 150.000000;
		HRecoil = 0.40000;
			
		bOwnsCrosshair = true;
		bMuzzleFlash = 0;
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
		
			Canvas.DrawTile(Texture'TODatas.Sniper5', Canvas.ClipX, Canvas.ClipY, 0, 0, 256, 256);

			Canvas.Style = ERenderStyle.STY_Translucent;
			XO = Canvas.ClipX / 2;
			YO = Canvas.ClipY / 2;
			Scale = Canvas.ClipX / 1024;
			Scale128 = Scale * 512;
			Scale64 = Scale * 64;
			Canvas.DrawColor.R = 192;
			Canvas.DrawColor.G = 192;
			Canvas.DrawColor.B = 192;

			Canvas.SetPos(XO - Scale128 / 2, YO - Scale128 / 2);
			Canvas.DrawTile(Texture'TODatas.Steyr2', Scale128 , Scale128, 0, 0, 128, 128);

			Canvas.DrawColor.R = 255;
			Canvas.DrawColor.G = 0;
			Canvas.DrawColor.B = 0;
		
			Canvas.SetPos(XO - Scale64 / 2, YO - Scale64 / 2);
			Canvas.DrawTile(Texture'TODatas.Steyr1', Scale64 , Scale64, 0, 0, 32, 32);
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

		if ( P.bHideCrosshairs )
			bOwnsCrosshair = true;
		else
			bOwnsCrosshair = false;
	}
}


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
		LoopAnim('idle', 0.1);
}


///////////////////////////////////////
// ClipIn
///////////////////////////////////////

simulated function ClipIn()
{
	//if ( Level.NetMode != NM_DedicatedServer )	
	//	PlaySound(Sound'TODatas.OICWClipin1', SLOT_None, 4.0);
	PlayWeaponSound(Sound'OICWClipin1');
}


///////////////////////////////////////
// ClipOut
///////////////////////////////////////

simulated function ClipOut()
{
	//if ( Level.NetMode != NM_DedicatedServer )	
	//	PlaySound(Sound'TODatas.OICWClipout1', SLOT_None, 4.0);
	PlayWeaponSound(Sound'OICWClipout1');
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
/*	MuzzleFlashVariations(0)=Texture'TODatas.Muzzle.MuzStd1'
  MuzzleFlashVariations(1)=Texture'TODatas.Muzzle.MuzStd2'
  MuzzleFlashVariations(2)=Texture'TODatas.Muzzle.MuzStd3'
  MuzzleFlashVariations(3)=Texture'TODatas.Muzzle.MuzStd4'
  MuzzleFlashVariations(4)=Texture'TODatas.Muzzle.MuzStd5'
  MuzzleFlashVariations(5)=Texture'TODatas.Muzzle.MuzStd6'
*/

defaultproperties
{
     MuzzleFlashVariations(0)=Texture'TODatas.Muzzle.Muz10'
     MaxDamage=38.000000
     clipSize=30
     clipAmmo=30
     MaxClip=5
     RoundPerMin=650
     bTracingBullets=True
     TraceFrequency=4
     price=4700
     BotAimError=0.800000
     PlayerAimError=0.400000
     VRecoil=90.000000
     HRecoil=6.000000
     bHasMultiSkins=True
     ArmsNb=4
     WeaponID=37
     WeaponClass=3
     WeaponWeight=25.000000
     aReloadWeapon=(AnimSeq=Reload,AnimRate=0.500000)
     MaxWallPiercing=25.000000
     MaxRange=9600.000000
     ProjectileSpeed=15000.000000
     FireModes(0)=FM_FullAuto
     FireModes(1)=FM_SingleFire
     bUseFireModes=True
     MuzScale=2.000000
     MuzX=620
     MuzY=442
     MuzRadius=64
     ShellCaseType="s_SWAT.TO_556SC"
     WeaponDescription="Classification: Steyr Aug"
     PickupAmmoCount=30
     bRapidFire=True
     FireOffset=(X=8.000000,Y=-5.000000)
     MyDamageType=shot
     shakemag=250.000000
     shaketime=0.300000
     shakevert=6.000000
     AIRating=0.730000
     RefireRate=0.990000
     AltRefireRate=0.990000
     FireSound=Sound'TODatas.Weapons.augfire'
     SelectSound=Sound'Botpack.enforcer.Cocking'
     DeathMessage="%k's %w turned %o into a leaky piece of meat."
     NameColor=(B=0)
     bDrawMuzzleFlash=True
     MuzzleScale=0.800000
     FlashY=-0.060000
     FlashC=0.002000
     FlashLength=0.001000
     FlashS=64
     AutoSwitchPriority=37
     InventoryGroup=4
     PickupMessage="You got the Steyr Aug!"
     ItemName="Steyr Aug"
     PlayerViewOffset=(X=300.000000,Y=100.000000,Z=-210.000000)
     PlayerViewMesh=LodMesh'TOModels.SteyrAug'
     PlayerViewScale=0.115000
     BobDamping=0.975000
     PickupViewMesh=LodMesh'TOModels.pAug'
     ThirdPersonMesh=LodMesh'TOModels.wAug'
     MuzzleFlashStyle=STY_Translucent
     MuzzleFlashMesh=LodMesh'TOModels.TO3rdMuzzleSA'
     MuzzleFlashScale=0.250000
     PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
     Mesh=LodMesh'TOModels.pAug'
     CollisionHeight=10.000000
}
