//=============================================================================
// s_Mossberg
//=============================================================================
//
// Tactical Ops
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen
//=============================================================================

class s_Mossberg extends s_Weapon;

var()	texture		MuzzleFlashVariations;

var	float		DamageRadius;
var	int			NumPellets;
var	int			BackRemainingClip, BackClipAmmo; // For client management

enum EShotReloadPhase
{
	SRP_PreReload,
	SRP_Reloading,
	SRP_PostReload,
};

var	EShotReloadPhase	ReloadPhase;

/*
///////////////////////////////////////
// replication 
///////////////////////////////////////

replication
{
	// Functions server can call on clients
	reliable if ( Role == ROLE_Authority)
		PlayReloadEnd, PlayInsertShell, PlayReloadWeaponShell;
}
*/

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
		FiringEffects();
		DR = DamageRadius / 2.0;

		for (i=0; i<NumPellets; i++)
		{
			if ( SG != None && SG.bEnableBallistics )
				TraceFireBallistics(AimError * (FRand() * DamageRadius - DR) );
			else
				TraceFire(AimError * (FRand() * DamageRadius - DR) );
		}

	}
}


///////////////////////////////////////
// AltFire
///////////////////////////////////////

function AltFire( float Value )
{

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

	if ( (FRand() > 0.98) && (AnimSequence != 'idle1') ) 
		PlayAnim('idle1', 0.15);
	else 
		LoopAnim('idle',0.2, 0.3);
}


///////////////////////////////////////
// PlayReloadWeapon
///////////////////////////////////////

simulated function PlayReloadWeapon()
{
	ReloadPhase = SRP_PreReload;

	if ( ClipAmmo == 0 )
		PlayAnim('RELOAD', 0.5, 0.1);
	else
		PlayReloadWeaponShell();
}


///////////////////////////////////////
// PlayReloadWeaponShell
///////////////////////////////////////

simulated function PlayReloadWeaponShell()
{
	PlayAnim('RELOAD1', 0.6, 0.1);
}


///////////////////////////////////////
// PlayInsertShell
///////////////////////////////////////

simulated function PlayInsertShell()
{
	PlayAnim('INSERTSHELL', 0.6, 0.1);
}


///////////////////////////////////////
// PlayReloadEnd
///////////////////////////////////////

simulated function PlayReloadEnd()
{
	PlayAnim('RELOADEND', 0.9, 0.1);
}


///////////////////////////////////////
// PlayPump
///////////////////////////////////////

simulated function PlayPump()
{
	//PlayOwnedSound(sound'MossPump', SLOT_None, Pawn(Owner).SoundDampening);
	PlayWeaponSound(sound'MossPump');
}


///////////////////////////////////////
// PlayInsertShellSound
///////////////////////////////////////

simulated function PlayInsertShellSound()
{
	//PlayOwnedSound(sound'Moss_insert', SLOT_None, Pawn(Owner).SoundDampening);
	PlayWeaponSound(Sound'Moss_insert');
}


///////////////////////////////////////
// EjectShell
///////////////////////////////////////

simulated function EjectShell()
{
	local vector X, Y, Z;

	if ( (Role != Role_Authority) || (Pawn(Owner) == None) )
		return;

	GetAxes(Pawn(Owner).ViewRotation, X, Y, Z);

	SpawnShellCase(X, Y, Z);
}


///////////////////////////////////////
// ServerReloadWeapon
///////////////////////////////////////

state ServerReloadWeapon
{
	ignores s_ReloadW, ChangeFireMode;

	function Fire(float F) {}
	function AltFire(float F) {}

	function BeginState()
	{
		//log("s_Weapon::ServerReloadWeapon::BeginState");
		bReloadingWeapon = true;
	}

	function EndState()
	{
		bReloadingWeapon = false;
	}

	function AnimEnd()
	{
		if ( ReloadPhase == SRP_PostReload )
		{
			bReloadingWeapon = false;
			bCanClientFire = true;
			finish();
		}
		else 
		{
			if ( (ReloadPhase != SRP_PreReload) || ( ClipAmmo == 0 ) )
			{
				ClipAmmo++;
				RemainingClip--;
			}

			if ( (ClipAmmo < ClipSize) && (RemainingClip > 0) && (Pawn(Owner).bFire == 0) )
			{
				ReloadPhase = SRP_Reloading;
				PlayInsertShell();
				PlayOwnedSound(sound'Moss_insert', SLOT_None, Pawn(Owner).SoundDampening);
			}
			else
			{
				ReloadPhase = SRP_PostReload;
				PlayReloadEnd();
			}
		}
	}

Begin:
	sleep(0.0);
}


///////////////////////////////////////
// ClientReloadWeapon
///////////////////////////////////////

state ClientReloadWeapon
{
	ignores s_ReloadW, ChangeFireMode;

	simulated function bool ClientFire( float Value ) { return false; }
	simulated function bool ClientAltFire( float Value ) { return false; }

	simulated function BeginState()
	{
		bReloadingWeapon = true;
		BackRemainingClip = RemainingClip;
		BackClipAmmo = ClipAmmo;
	}

	simulated function EndState()
	{
		bReloadingWeapon = false;
	}

	simulated function AnimEnd()
	{
		if ( (ReloadPhase != SRP_PreReload) || ( BackClipAmmo == 0 ) )
		{
			BackClipAmmo++;
			BackRemainingClip--;
		}

		if ( ReloadPhase == SRP_PostReload )
		{
			// Here to make sure Lag does not disable client firing animations
			bCanClientFire = true;

			bReloadingWeapon = false;
			PlayIdleAnim();
			GotoState('');
		}
		else 
		{
			if ( (BackClipAmmo < ClipSize) && (BackRemainingClip > 0) && (Pawn(Owner).bFire == 0) )
			{
				ReloadPhase = SRP_Reloading;
				PlayInsertShell();
				PlayOwnedSound(sound'Moss_insert', SLOT_None, Pawn(Owner).SoundDampening);
			}
			else
			{
				ReloadPhase = SRP_PostReload;
				PlayReloadEnd();
			}
		}
	}
}


///////////////////////////////////////
// defaultproperties 
///////////////////////////////////////

defaultproperties
{
     MuzzleFlashVariations=Texture'TODatas.Muzzle.Muz7'
     DamageRadius=1.200000
     NumPellets=10
     MaxDamage=16.000000
     clipSize=8
     clipAmmo=8
     MaxClip=48
     ClipInc=8
     RoundPerMin=80
     price=1500
     ClipPrice=40
     BotAimError=0.250000
     PlayerAimError=0.250000
     VRecoil=1000.000000
     HRecoil=1.000000
     bStaticAimError=True
     bHasMultiSkins=True
     ArmsNb=3
     WeaponID=22
     WeaponClass=2
     WeaponWeight=15.000000
     aReloadWeapon=(AnimSeq=Reload)
     MaxWallPiercing=8.000000
     MaxRange=1200.000000
     FireModes(0)=FM_SingleFire
     bUseFireModes=True
     MuzScale=4.000000
     MuzX=597
     MuzY=451
     MuzRadius=64
     bUseShellCase=False
     ShellCaseType="s_SWAT.s_12gaShellcase"
     WeaponDescription="Classification: Mossberg Shotgun"
     InstFlash=-0.200000
     InstFog=(X=375.000000,Y=225.000000,Z=70.000000)
     PickupAmmoCount=30
     FiringSpeed=1.500000
     FireOffset=(X=8.000000,Y=-5.000000)
     MyDamageType=shot
     shaketime=0.300000
     shakevert=10.000000
     AIRating=0.550000
     RefireRate=0.800000
     AltRefireRate=0.870000
     FireSound=Sound'TODatas.Weapons.MossShoot'
     SelectSound=Sound'Botpack.enforcer.Cocking'
     DeathMessage="%k riddled %o full of holes with the %w."
     NameColor=(R=200,G=200)
     bDrawMuzzleFlash=True
     MuzzleScale=1.000000
     FlashY=0.100000
     FlashO=0.008000
     FlashC=0.035000
     FlashLength=0.010000
     FlashS=128
     AutoSwitchPriority=22
     InventoryGroup=3
     PickupMessage="You picked up the Mossberg Shotgun!"
     ItemName="MossBerg"
     PlayerViewOffset=(X=200.000000,Y=120.000000,Z=-90.000000)
     PlayerViewMesh=LodMesh'TOModels.mossberg'
     PlayerViewScale=0.130000
     PickupViewMesh=LodMesh'TOModels.pmossberg'
     ThirdPersonMesh=LodMesh'TOModels.wmossberg'
     bMuzzleFlashParticles=True
     MuzzleFlashStyle=STY_Translucent
     MuzzleFlashMesh=LodMesh'Botpack.muzzEF3'
     MuzzleFlashScale=0.080000
     MuzzleFlashTexture=Texture'Botpack.Skins.Muzzy2'
     PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
     bHidden=True
     Mesh=LodMesh'TOModels.pmossberg'
     CollisionRadius=24.000000
     CollisionHeight=12.000000
     Mass=20.000000
}
