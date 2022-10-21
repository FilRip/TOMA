//=============================================================================
// s_hksr9
//=============================================================================
//
// Tactical Ops
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen
//=============================================================================

class s_hksr9 expands s_Weapon;


var() texture			MuzzleFlashVariations;
var		s_LaserDot	LaserDot;


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

	if (LaserDot != None)
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
// PlayAltFiring 
///////////////////////////////////////

simulated function PlayAltFiring()
{
}


///////////////////////////////////////
// AltFire
///////////////////////////////////////

function AltFire( float Value )
{
	if ( LaserDot == None )
		LaserDot = Spawn(class's_SWAT.s_LaserDotChild', Self, , Location, Rotation);
	else
		KillLaserDot();

	Pawn(Owner).bAltFire = 0;
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
// BecomePickup 
///////////////////////////////////////

function BecomePickup()
{
	if ( LaserDot != None )
		KillLaserDot();

	Super.BecomePickup();
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
// SetAimError
///////////////////////////////////////

simulated function SetAimError()
{
	Super.SetAimError();

	if ( LaserDot != None )
		AimError /= 1.66;
}


///////////////////////////////////////
// ClipIn
///////////////////////////////////////

simulated function ClipIn()
{
	//if ( Level.NetMode != NM_DedicatedServer )	
	//	PlaySound(Sound'TODatas.OICWClipin1', SLOT_None, 4.0);
	PlayWeaponSound(Sound'TODatas.OICWClipin1');
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

defaultproperties
{
     MuzzleFlashVariations=Texture'TODatas.Muzzle.Muz3'
     MaxDamage=60.000000
     clipSize=20
     clipAmmo=20
     MaxClip=4
     RoundPerMin=240
     bTracingBullets=True
     TraceFrequency=4
     price=3850
     PlayerAimError=0.500000
     VRecoil=280.000000
     HRecoil=2.000000
     bHasMultiSkins=True
     ArmsNb=6
     WeaponID=34
     WeaponClass=3
     WeaponWeight=20.000000
     aReloadWeapon=(AnimSeq=Reload,AnimRate=0.400000)
     MaxWallPiercing=30.000000
     MaxRange=14400.000000
     ProjectileSpeed=15000.000000
     MuzScale=3.000000
     MuzX=620
     MuzY=437
     MuzRadius=64
     ShellCaseType="s_SWAT.s_762ShellCase"
     WeaponDescription="Classification: HK SR9"
     PickupAmmoCount=20
     bRapidFire=True
     FireOffset=(X=8.000000,Y=-5.000000)
     MyDamageType=shot
     shakemag=250.000000
     shaketime=0.300000
     shakevert=9.000000
     AIRating=0.650000
     RefireRate=0.990000
     AltRefireRate=0.990000
     FireSound=Sound'TODatas.Weapons.SR9_fire'
     SelectSound=Sound'Botpack.enforcer.Cocking'
     DeathMessage="%k's %w turned %o into a leaky piece of meat."
     NameColor=(B=0)
     bDrawMuzzleFlash=True
     MuzzleScale=0.800000
     FlashY=-0.060000
     FlashC=0.002000
     FlashLength=0.001000
     FlashS=64
     AutoSwitchPriority=34
     InventoryGroup=4
     PickupMessage="You got the HK SR9!"
     ItemName="HKSR9"
     PlayerViewOffset=(X=255.000000,Y=120.000000,Z=-75.000000)
     PlayerViewMesh=LodMesh'TOModels.hksr9'
     PlayerViewScale=0.125000
     BobDamping=0.975000
     PickupViewMesh=LodMesh'TOModels.phksr9'
     ThirdPersonMesh=LodMesh'TOModels.whksr9'
     bMuzzleFlashParticles=True
     MuzzleFlashStyle=STY_Translucent
     MuzzleFlashMesh=LodMesh'Botpack.MuzzFlash3'
     MuzzleFlashScale=0.250000
     MuzzleFlashTexture=Texture'Botpack.Skins.Muzzy'
     PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
     Mesh=LodMesh'TOModels.phksr9'
     CollisionHeight=10.000000
}
