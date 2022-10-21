//=============================================================================
// s_OICW
//=============================================================================
//
// Tactical Ops
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen and Benoit "JAH" Delayen
//=============================================================================

class s_OICW expands s_Weapon;

var		bool		bAltMode;
var		int			BackupClip;
var		int			BackupAmmo;
var		int			BackupClipSize, BackupMaxClip, BackupClipPrice;

var() texture MuzzleFlashVariations;


///////////////////////////////////////
// replication
///////////////////////////////////////

replication 
{
	reliable if ( Role==ROLE_Authority )
		bAltMode, BackupClip, BackupAmmo;

	// Functions server calls on clients
	reliable if ( Role == ROLE_Authority )
		ClientChangeFireMode;
}


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

		if (P.bHUDModFix)
		{
			Canvas.Style = ERenderStyle.STY_Normal;
			Canvas.DrawTile(Texture'TODatas.Sniper3fix', Canvas.ClipX, Canvas.ClipY, 0, 0, 256, 256);
		}
		else
		{
			Canvas.Style = ERenderStyle.STY_Modulated;
			Canvas.DrawColor.R = 255;
			Canvas.DrawColor.G = 255;
			Canvas.DrawColor.B = 255;
		
			Canvas.DrawTile(Texture'TODatas.Sniper3', Canvas.ClipX, Canvas.ClipY, 0, 0, 256, 256);
		}
		
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
//  RenderOverlays
///////////////////////////////////////

simulated event RenderOverlays( canvas Canvas )
{	
	/*
	MuzFrame++;
	
	if (MuzFrame > 11)
		MuzFrame = 0;
	*/
	if ( !bAltMode )
		MFTexture = MuzzleFlashVariations;
		//MFTexture = MuzzleFlashVariations[MuzFrame/2];
	else
		MFTexture = None;

	Super.RenderOverlays(Canvas);
}


///////////////////////////////////////
// RateSelf
///////////////////////////////////////

function float RateSelf( out int bUseAltMode )
{
	local float dist;

	if ( ClipAmmo <=0 )
		return -2;

	bUseAltMode = 0;

	return AIRating;
}


///////////////////////////////////////
// GenerateBullet
///////////////////////////////////////

function GenerateBullet()
{
	local	s_SWATGame	SG;

  LightType = LT_Steady;
	
	// Enhance to support UT GameTypes
	SG = s_SWATGame(Level.Game);
	//if (SG == None)
	//	log("GenerateBullet - SG == None");

//	if (Owner.IsA('s_BPlayer'))
//		AimError = 0.0;

	if ( UseAmmo(1) ) 
	{
		if ( bAltMode )
			GenerateRocket();
		else
		{
			FiringEffects();

			if ( SG != None && SG.bEnableBallistics )
				TraceFireBallistics(AimError);
			else
				TraceFire(AimError);
		}
	}
}


///////////////////////////////////////
// GenerateRocket
///////////////////////////////////////

function GenerateRocket()
{
		local vector FireLocation, StartLoc, X,Y,Z;
		local rotator FireRot;
		local rocketmk2 r;
		local pawn PawnOwner;
		local PlayerPawn PlayerOwner;
		
		PawnOwner = Pawn(Owner);
		if ( PawnOwner == None )
			return;

		//PawnOwner.PlayRecoil(FiringSpeed);
		PlayerOwner = PlayerPawn(Owner);

		GetAxes(PawnOwner.ViewRotation,X,Y,Z);
		StartLoc = Owner.Location + CalcDrawOffset() + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z; 

		AdjustedAim = PawnOwner.AdjustToss(AltProjectileSpeed, StartLoc, AimError, True, bAltWarnTarget);	
			
		if ( PlayerOwner != None )
			AdjustedAim = PawnOwner.ViewRotation;
		
		FireLocation = StartLoc;
			
		r = Spawn(class'TO_20mmHE',, '', StartLoc, AdjustedAim);
		r.DrawScale *= 0.5;
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
		if (zoom_mode > 2)
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
// AltFire
///////////////////////////////////////

function AltFire( float Value )
{
	ClientAltFire(Value);
}


///////////////////////////////////////
// PlayReloadWeapon
///////////////////////////////////////

simulated function PlayReloadWeapon()
{
	if ( !bAltMode )
		PlayAnim('Reload1', 0.4, 0.05);
	else
		PlayAnim('Reload2', 0.4, 0.05);
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

/*
///////////////////////////////////////
// DoChangeFireMode
///////////////////////////////////////

simulated function bool DoChangeFireMode()
{
	local		int			BClip;
	local		int			BAmmo;
	local		int			BClipSize, BMaxClip;
	local	byte	msg;

	//if ( (BackupClip < 1) && (BackupAmmo < 1) )
	//	return false;

	if ( Role < Role_Authority )
		return true;

	// Switching Ammo
	BClip = BackupClip;
	BAmmo = BackupAmmo;
	BClipSize = BackupClipSize;
	BMaxClip = BackupMaxClip;

	BackupClip = RemainingClip;
	BackupAmmo = ClipAmmo;
	BackupClipSize = ClipSize;
	BackupMaxClip = MaxClip;

	RemainingClip = BClip;
	ClipAmmo = BAmmo;
	ClipSize = BClipSize;
	MaxClip = BMaxClip;

	//bNeedFix = true;

	if ( bAltMode )
	{
		bAltMode = false;
		msg = 8;
		CurrentFireMode = 0;
		RoundPerMin = Default.RoundPerMin;
	}
	else
	{
		bAltMode = true;
		msg = 9;
		CurrentFireMode = 2;
		RoundPerMin = 100;
	}

	if ( Owner.IsA('s_BPlayer') )
		Pawn(Owner).ReceiveLocalizedMessage(class's_WeaponMessages', msg );

	return true;
}
*/

///////////////////////////////////////
// DoChangeFireMode
///////////////////////////////////////

simulated function bool DoChangeFireMode()
{
	local	byte	msg;

	//if ( (BackupClip < 1) && (BackupAmmo < 1) )
	//	return false;

	// Force server to be da king for fire mode changing
	if ( Role < Role_Authority )
		return true;

	//bNeedFix = true;

	if ( bAltMode )
	{
		ClientChangeFireMode( false );
		ChangeFireModeSpecs( false );
		msg = 8;
	}
	else
	{
		ClientChangeFireMode( true );
		ChangeFireModeSpecs( true );
		msg = 9;
	}

	if ( Owner.IsA('s_BPlayer') )
		Pawn(Owner).ReceiveLocalizedMessage(class's_WeaponMessages', msg );

	return true;
}


///////////////////////////////////////
// ClientChangeFireMode
///////////////////////////////////////

simulated function ClientChangeFireMode( bool DesiredbAltMode )
{
	if ( Role == Role_Authority )
		return;

	ChangeFireModeSpecs( DesiredbAltMode );
}


///////////////////////////////////////
// ChangeFireModeSpecs
///////////////////////////////////////

simulated function ChangeFireModeSpecs( bool DesiredbAltMode )
{
	local		int			BClip, BAmmo, BClipSize, BMaxClip, BClipPrice;

	bAltMode = DesiredbAltMode;
	bMuzzleFlash = 0;

	// Switching Ammo
	BClip = BackupClip;
	BAmmo = BackupAmmo;
	BClipSize = BackupClipSize;
	BMaxClip = BackupMaxClip;
	BClipPrice = BackupClipPrice;

	BackupClip = RemainingClip;
	BackupAmmo = ClipAmmo;
	BackupClipSize = ClipSize;
	BackupMaxClip = MaxClip;
	BackupClipPrice = ClipPrice;

	RemainingClip = BClip;
	ClipAmmo = BAmmo;
	ClipSize = BClipSize;
	MaxClip = BMaxClip;
	ClipPrice = BClipPrice;

	if ( bAltMode )
	{
		CurrentFireMode = 1;
		RoundPerMin = 100;
	}
	else
	{
		CurrentFireMode = 0;
		RoundPerMin = Default.RoundPerMin;
	}
}


///////////////////////////////////////
// PlayFiring
///////////////////////////////////////

simulated function PlayFiring()
{
	if ( bAltMode )
		FireSound=Sound'TODatas.OICWGrenFire';
	else
		FireSound=Sound'TODatas.OICWNormFire';

	Super.PlayFiring();
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
/*
    MuzzleFlashVariations(0)=Texture'TODatas.Muzzle.MuzStd1'
     MuzzleFlashVariations(1)=Texture'TODatas.Muzzle.MuzStd2'
     MuzzleFlashVariations(2)=Texture'TODatas.Muzzle.MuzStd3'
     MuzzleFlashVariations(3)=Texture'TODatas.Muzzle.MuzStd4'
     MuzzleFlashVariations(4)=Texture'TODatas.Muzzle.MuzStd5'
     MuzzleFlashVariations(5)=Texture'TODatas.Muzzle.MuzStd6'
*/

defaultproperties
{
     BackupClip=2
     BackupAmmo=5
     BackupClipSize=5
     BackupMaxClip=2
     BackupClipPrice=300
     MuzzleFlashVariations=Texture'TODatas.Muzzle.Muz4'
     MaxDamage=40.000000
     clipSize=25
     clipAmmo=25
     RemainingClip=6
     MaxClip=6
     RoundPerMin=600
     bTracingBullets=True
     TraceFrequency=4
     price=1234
     PlayerAimError=0.500000
     VRecoil=80.000000
     HRecoil=5.000000
     bHasMultiSkins=True
     ArmsNb=3
     WeaponID=38
     WeaponClass=3
     WeaponWeight=25.000000
     aReloadWeapon=(AnimSeq=Reload)
     MaxWallPiercing=25.000000
     MaxRange=12000.000000
     ProjectileSpeed=15000.000000
     FireModes(0)=FM_FullAuto
     FireModes(1)=FM_SingleFire
     bUseFireModes=True
     MuzScale=3.000000
     MuzX=590
     MuzY=455
     MuzRadius=64
     ShellCaseType="s_SWAT.TO_556SC"
     WeaponDescription="Classification: Objective Infantry Combat Weapon"
     PickupAmmoCount=25
     bRapidFire=True
     FireOffset=(X=5.000000,Y=5.000000,Z=-5.000000)
     MyDamageType=shot
     shakemag=250.000000
     shaketime=0.300000
     AIRating=0.730000
     RefireRate=0.990000
     AltRefireRate=0.990000
     SelectSound=Sound'Botpack.enforcer.Cocking'
     DeathMessage="%k's %w turned %o into a leaky piece of meat."
     NameColor=(B=0)
     bDrawMuzzleFlash=True
     MuzzleScale=0.800000
     FlashY=-0.060000
     FlashC=0.002000
     FlashLength=0.001000
     FlashS=64
     AutoSwitchPriority=38
     InventoryGroup=4
     PickupMessage="You stole the O.I.C.W.!"
     ItemName="OICW"
     PlayerViewOffset=(X=180.000000,Y=80.000000,Z=-95.000000)
     PlayerViewMesh=LodMesh'TOModels.OICW'
     PlayerViewScale=0.130000
     BobDamping=0.975000
     PickupViewMesh=LodMesh'TOModels.pOICW'
     ThirdPersonMesh=LodMesh'TOModels.wOICW'
     bMuzzleFlashParticles=True
     MuzzleFlashStyle=STY_Translucent
     MuzzleFlashMesh=LodMesh'Botpack.MuzzFlash3'
     MuzzleFlashScale=0.250000
     MuzzleFlashTexture=Texture'Botpack.Skins.Muzzy'
     PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
     Mesh=LodMesh'TOModels.pOICW'
     CollisionHeight=10.000000
}
