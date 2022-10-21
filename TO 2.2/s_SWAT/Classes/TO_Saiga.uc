//=============================================================================
// TO_Saiga
//=============================================================================
//
// Tactical Ops
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen
//=============================================================================

class TO_Saiga expands s_Weapon;

var() texture MuzzleFlashVariations;


var	float	DamageRadius;
var	int		NumPellets;


///////////////////////////////////////
// RenderOverlays 
///////////////////////////////////////

simulated event RenderOverlays(canvas Canvas)
{
	MFTexture = MuzzleFlashVariations;

	Super.RenderOverlays(Canvas);
}


///////////////////////////////////////
// GenerateBullet
///////////////////////////////////////

function GenerateBullet()
{
	local	s_SWATGame	SG;
	local	int					i;
	local	float				DR;

  LightType = LT_Steady;
	
	SG = s_SWATGame(Level.Game);
	//if (SG == None)
	//	log("GenerateBullet - SG == None");

	/*
	if (Owner.IsA('s_BPlayer'))
		AimError = 1.0;
	else
		AimError = 1.25;
	*/
	if ( UseAmmo(1) ) 
	{
		DR = DamageRadius / 2.0;
		FiringEffects();

		for (i=0; i<NumPellets; i++)
		{
			if ( SG != None && SG.bEnableBallistics )
				TraceFireBallistics(AimError * (FRand() * DamageRadius - DR) );
			else
				TraceFire(AimError * (FRand() * DamageRadius - DR) );
		}

		SpawnSC();
	}
}


///////////////////////////////////////
// SpawnSC
///////////////////////////////////////

function SpawnSC()
{
	local vector X, Y, Z;

	if ( Pawn(Owner) == None )
		return;

	GetAxes(Pawn(Owner).ViewRotation, X, Y, Z);

	SpawnShellCase(X, Y, Z);
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

defaultproperties
{
     MuzzleFlashVariations=Texture'TODatas.Muzzle.Muz1'
     DamageRadius=1.000000
     NumPellets=8
     MaxDamage=18.000000
     clipSize=7
     clipAmmo=7
     MaxClip=4
     RoundPerMin=140
     price=2800
     ClipPrice=40
     BotAimError=0.250000
     PlayerAimError=0.250000
     VRecoil=500.000000
     HRecoil=10.000000
     RecoilMultiplier=0.020000
     bStaticAimError=True
     bHasMultiSkins=True
     ArmsNb=3
     WeaponID=24
     WeaponClass=2
     WeaponWeight=15.000000
     aReloadWeapon=(AnimSeq=Reload,AnimRate=0.350000)
     MaxWallPiercing=20.000000
     MaxRange=1440.000000
     ProjectileSpeed=15000.000000
     FireModes(0)=FM_FullAuto
     bUseFireModes=True
     MuzScale=2.800000
     MuzX=601
     MuzY=445
     MuzRadius=64
     bUseShellCase=False
     ShellCaseType="s_SWAT.s_12gaShellcase"
     WeaponDescription="Classification: Saiga-12 automatic shotgun"
     PickupAmmoCount=30
     bRapidFire=True
     FireOffset=(X=8.000000,Y=-5.000000)
     MyDamageType=shot
     shaketime=0.500000
     shakevert=10.000000
     AIRating=0.600000
     RefireRate=0.990000
     AltRefireRate=0.990000
     FireSound=Sound'TODatas.Weapons.MossShoot'
     SelectSound=Sound'Botpack.enforcer.Cocking'
     DeathMessage="%k's %w turned %o into a leaky piece of meat."
     NameColor=(B=0)
     bDrawMuzzleFlash=True
     MuzzleScale=0.700000
     FlashY=-0.060000
     FlashC=0.002000
     FlashLength=0.001000
     FlashS=64
     AutoSwitchPriority=24
     InventoryGroup=3
     PickupMessage="You got the Saiga-12 Auto Shotgun!"
     ItemName="Saiga-12"
     PlayerViewOffset=(X=230.000000,Y=120.000000,Z=-100.000000)
     PlayerViewMesh=LodMesh'TOModels.Saiga'
     PlayerViewScale=0.120000
     BobDamping=0.975000
     PickupViewMesh=LodMesh'TOModels.psaiga'
     ThirdPersonMesh=LodMesh'TOModels.wsaiga'
     bMuzzleFlashParticles=True
     MuzzleFlashStyle=STY_Translucent
     MuzzleFlashMesh=LodMesh'Botpack.MuzzFlash3'
     MuzzleFlashScale=0.250000
     MuzzleFlashTexture=Texture'Botpack.Skins.Muzzy'
     PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
     Mesh=LodMesh'TOModels.psaiga'
     CollisionHeight=15.000000
}
