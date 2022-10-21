//=============================================================================
// s_DEagle
//=============================================================================
//
// Tactical Ops
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen
//=============================================================================

class s_DEagle extends s_Weapon;

var()								texture			MuzzleFlashVariations;
var									s_LaserDot	LaserDot;


///////////////////////////////////////
// replication 
///////////////////////////////////////

replication
{
	reliable if ( bNetOwner && (Role == ROLE_Authority) )		
		LaserDot;
}


///////////////////////////////////////
// PostRender
///////////////////////////////////////

simulated function PostRender( canvas Canvas )
{
	Super.PostRender(Canvas);

	bOwnsCrosshair = true;
	if ( (LaserDot == None) && (s_BPlayer(Owner) != None) && !s_BPlayer(Owner).bHideCrosshairs )
			bOwnsCrosshair = false;
}


///////////////////////////////////////
// Destroyed
///////////////////////////////////////

event Destroyed()
{
	Super.Destroyed();

	if ( LaserDot != None )
		KillLaserDot(); 
}


simulated function KillLaserDot()
{
	LaserDot.Destroy();
	LaserDot = None;
}


///////////////////////////////////////
// Tick 
///////////////////////////////////////

simulated function Tick(float deltatime)
{
	Super.Tick(deltatime);

	if ( LaserDot != None )
	{
		if ( (Owner != None) && (Pawn(Owner) != None) )
		{
			if ( Pawn(Owner).PlayerReplicationInfo.bIsSpectator || (Pawn(Owner).Weapon != Self) )
			{
				KillLaserDot();
				return;
			}
		}
	}
}


///////////////////////////////////////
// AltFire
///////////////////////////////////////

function AltFire( float Value )
{
	if ( LaserDot == None )
		LaserDot = Spawn(class's_SWAT.s_LaserDotChild', Self);
	else
		KillLaserDot();

	//Pawn(Owner).bAltFire = 0;
}


///////////////////////////////////////
// DownWeapon 
///////////////////////////////////////

State DownWeapon
{
ignores Fire, AltFire, Animend;

	function BeginState()
	{
		if ( LaserDot != None )
			KillLaserDot();

		Super.BeginState();
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
// BecomePickup 
///////////////////////////////////////

function BecomePickup()
{
	if ( LaserDot != None )
		KillLaserDot();

	Super.BecomePickup();
} 


///////////////////////////////////////
// PlayClipOut 
///////////////////////////////////////

simulated function PlayClipOut()
{
	//if ( Level.NetMode != NM_DedicatedServer )	
	//	PlaySound(Sound'TODatas.BerClipIn', SLOT_None, 4.0);
	PlayWeaponSound(Sound'TODatas.BerClipIn');
}


///////////////////////////////////////
// PlayClipIn 
///////////////////////////////////////

simulated function PlayClipIn()
{
	//if ( Level.NetMode != NM_DedicatedServer )	
	//	PlaySound(Sound'TODatas.BerClipOut', SLOT_None, 4.0);
	PlayWeaponSound(Sound'TODatas.BerClipOut');
}


///////////////////////////////////////
// PlayClipReload 
///////////////////////////////////////

simulated function PlayClipReload()
{
	//if ( Level.NetMode != NM_DedicatedServer )	
	//	PlaySound(Sound'TODatas.BerReload', SLOT_None, 4.0);
	PlayWeaponSound(Sound'TODatas.BerReload');
}


///////////////////////////////////////
// SetAimError
///////////////////////////////////////

simulated function SetAimError()
{
	Super.SetAimError();

	if ( LaserDot != None )
		AimError /= 1.66;
}


///////////////////////////////////////
// defaultproperties 
///////////////////////////////////////
//PlayerViewOffset=(X=275.000000,Y=100.000000,Z=-50.000000)
// MuzzleFlashVariations=Texture'Botpack.Skins.Flakmuz'

defaultproperties
{
     MuzzleFlashVariations=Texture'TODatas.Muzzle.Muz1'
     MaxDamage=68.000000
     clipSize=7
     clipAmmo=7
     MaxClip=7
     RoundPerMin=200
     price=700
     ClipPrice=25
     BotAimError=0.240000
     PlayerAimError=0.120000
     VRecoil=450.000000
     HRecoil=2.000000
     bHasMultiSkins=True
     ArmsNb=3
     WeaponID=11
     WeaponClass=1
     WeaponWeight=5.000000
     aReloadWeapon=(AnimSeq=Reload,AnimRate=0.500000)
     MaxWallPiercing=8.000000
     MaxRange=1920.000000
     FireModes(0)=FM_SingleFire
     bUseFireModes=True
     MuzScale=2.700000
     MuzX=620
     MuzY=483
     MuzRadius=64
     ShellCaseType="s_SWAT.s_50bmgShellCase"
     WeaponDescription="Classification: Desert Eagle"
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
     FireSound=Sound'TODatas.Weapons.deagle_Fire1'
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
     AutoSwitchPriority=11
     InventoryGroup=2
     PickupMessage="You picked up a Desert Eagle!"
     ItemName="Desert Eagle"
     PlayerViewOffset=(X=250.000000,Y=80.000000,Z=-110.000000)
     PlayerViewMesh=LodMesh'TOModels.deagle'
     PlayerViewScale=0.125000
     PickupViewMesh=LodMesh'TOModels.pdeagle'
     ThirdPersonMesh=LodMesh'TOModels.wdeagle'
     bMuzzleFlashParticles=True
     MuzzleFlashStyle=STY_Translucent
     MuzzleFlashMesh=LodMesh'Botpack.muzzEF3'
     MuzzleFlashScale=0.080000
     MuzzleFlashTexture=Texture'Botpack.Skins.Muzzy2'
     PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
     bHidden=True
     Mesh=LodMesh'TOModels.pdeagle'
     CollisionRadius=20.000000
     CollisionHeight=10.000000
     Mass=15.000000
}
