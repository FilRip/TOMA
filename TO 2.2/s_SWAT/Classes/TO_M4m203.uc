//=============================================================================
// TO_M4m203
//=============================================================================
//
// Tactical Ops
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen
//=============================================================================

class TO_M4m203 expands s_Weapon;


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
//  RenderOverlays
///////////////////////////////////////

simulated event RenderOverlays( canvas Canvas )
{	
/*	MuzFrame++;
	
	if (MuzFrame > 11)
		MuzFrame = 0;

	if (!bAltMode)
		MFTexture = MuzzleFlashVariations[MuzFrame/2];
	else
		MFTexture = None;
*/
	if ( !bAltMode )
		MFTexture = MuzzleFlashVariations;
	else
		MFTexture = None;

//	MFTexture = MuzzleFlashVariations[0];
	Super.RenderOverlays(Canvas);
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

			if ( (SG != None) && SG.bEnableBallistics )
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
//	/*
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
			
		r = Spawn(class'TO_40mmProj',, '', StartLoc, AdjustedAim);
		//r.DrawScale *= 0.5;
//*/
/*
	local s_GrenadeAway g;
	local vector StartTrace, X, Y, Z;
	local Pawn PawnOwner;

	PawnOwner = Pawn(Owner);
	Owner.MakeNoise(PawnOwner.SoundDampening);
	GetAxes(PawnOwner.ViewRotation, X, Y, Z);
	
	StartTrace =  Owner.Location + CalcDrawOffset() + FireOffset.Y * Y + FireOffset.Z * Z;
	AdjustedAim = pawn(owner).AdjustAim(1000000, StartTrace, 2 * AimError, False, False);	
	g = Spawn(class's_Concussion',,, StartTrace, AdjustedAim);
	g.ExpTiming = 4.0 - 3 * 0.375;
	g.speed = 700 + 3 * 120;
	g.ThrowGrenade();
*/
}


///////////////////////////////////////
// PlayReloadWeapon
///////////////////////////////////////

simulated function PlayReloadWeapon()
{
	if ( !bAltMode )
		PlayAnim('Reload', 0.4, 0.05);
	else
		PlayAnim('RELOADGREN', 0.4, 0.05);
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
		FireSound=Sound'TODatas.M4_fire';

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
// defaultproperties
///////////////////////////////////////
// PlayerViewOffset=(X=180.000000,Y=80.000000,Z=-95.000000)
// MuzzleFlashVariations=Texture'TODatas.Muzzle.Muz3'
/*     MuzzleFlashVariations(1)=Texture'TODatas.Muzzle.MuzStd2'
     MuzzleFlashVariations(2)=Texture'TODatas.Muzzle.MuzStd3'
     MuzzleFlashVariations(3)=Texture'TODatas.Muzzle.MuzStd4'
     MuzzleFlashVariations(4)=Texture'TODatas.Muzzle.MuzStd5'
     MuzzleFlashVariations(5)=Texture'TODatas.Muzzle.MuzStd6'
		 */

defaultproperties
{
     BackupClip=1
     BackupAmmo=1
     BackupClipSize=1
     BackupMaxClip=4
     BackupClipPrice=300
     MuzzleFlashVariations=Texture'TODatas.Muzzle.Muz3'
     MaxDamage=37.000000
     clipSize=30
     clipAmmo=30
     MaxClip=6
     RoundPerMin=600
     bTracingBullets=True
     TraceFrequency=4
     price=11000
     BotAimError=0.700000
     PlayerAimError=0.350000
     VRecoil=80.000000
     HRecoil=5.000000
     bHasMultiSkins=True
     ArmsNb=4
     WeaponID=40
     WeaponClass=3
     WeaponWeight=25.000000
     aReloadWeapon=(AnimSeq=Reload)
     MaxWallPiercing=25.000000
     MaxRange=7200.000000
     ProjectileSpeed=15000.000000
     FireModes(0)=FM_FullAuto
     FireModes(1)=FM_SingleFire
     bUseFireModes=True
     MuzScale=3.000000
     MuzX=583
     MuzY=455
     MuzRadius=64
     ShellCaseType="s_SWAT.TO_556SC"
     WeaponDescription="Classification: M4A1m203"
     PickupAmmoCount=25
     bRapidFire=True
     FireOffset=(X=7.000000,Y=3.500000,Z=-7.000000)
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
     PickupMessage="You got a M4A1m203!"
     ItemName="M4m203"
     PlayerViewOffset=(X=220.000000,Y=120.000000,Z=-90.000000)
     PlayerViewMesh=LodMesh'TOModels.M4m203'
     PlayerViewScale=0.130000
     BobDamping=0.975000
     PickupViewMesh=LodMesh'TOModels.pM4m203'
     ThirdPersonMesh=LodMesh'TOModels.wM4m203'
     bMuzzleFlashParticles=True
     MuzzleFlashStyle=STY_Translucent
     MuzzleFlashMesh=LodMesh'Botpack.MuzzFlash3'
     MuzzleFlashScale=0.250000
     MuzzleFlashTexture=Texture'Botpack.Skins.Muzzy'
     PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
     Mesh=LodMesh'TOModels.pOICW'
     CollisionHeight=10.000000
}
