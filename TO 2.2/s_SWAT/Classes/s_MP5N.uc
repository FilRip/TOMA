//=============================================================================
// s_MP5N
//=============================================================================
//
// Tactical Ops 
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen
//=============================================================================

class s_MP5N expands s_Weapon;

var		float		SwitchSilencerDuration;
var() texture MuzzleFlashVariations;
var		bool		bSilencer;


///////////////////////////////////////
// replication 
///////////////////////////////////////

replication 
{
	// Server send to client 
	reliable if ( (Role == ROLE_Authority) )
		bSilencer;
}



///////////////////////////////////////
// RenderOverlays
///////////////////////////////////////

simulated event RenderOverlays( canvas Canvas )
{
	local rotator NewRot;
	local bool bPlayerOwner;
	local int Hand;
	local PlayerPawn PlayerOwner;
	local float Scale;

	if ( bHideWeapon || (Owner == None) )
		return;

	PlayerOwner = PlayerPawn(Owner);

	if ( PlayerOwner != None )
	{
		if ( PlayerOwner.DesiredFOV != PlayerOwner.DefaultFOV )
			return;
		bPlayerOwner = true;
		Hand = PlayerOwner.Handedness;

		if (  (Level.NetMode == NM_Client) && (Hand == 2) )
		{
			bHideWeapon = true;
			return;
		}
	}

	if ( !bPlayerOwner || (PlayerOwner.Player == None) )
		Pawn(Owner).WalkBob = vect(0,0,0);

	MFTexture = MuzzleFlashVariations;

	if ( (bMuzzleFlash > 0) && bDrawMuzzleFlash && Level.bHighDetailMode && (MFTexture != None) && !bSilencer )
	{
		if ( !bSetFlashTime )
		{
			bSetFlashTime = true;
			FlashTime = Level.TimeSeconds + FlashLength;
		}
		else if ( FlashTime < Level.TimeSeconds )
			bMuzzleFlash = 0;

		
		// New muzzle flash
		if ( (bMuzzleFlash > 0)  )
		{
			Scale = Canvas.ClipX / 1024;
			Canvas.SetPos( (MuzX - MuzRadius * MuzScale ) * Scale, (MuzY - MuzRadius*MuzScale) * Scale);
			Canvas.Style = 3;
			Canvas.DrawIcon(MFTexture, MuzScale * Scale);
			Canvas.Style = 1;
		}
	}
	else
		bSetFlashTime = false;

	SetLocation( Owner.Location + CalcDrawOffset() );
	NewRot = Pawn(Owner).ViewRotation;

	if ( Hand == 0 )
		newRot.Roll = -2 * Default.Rotation.Roll;
	else
		newRot.Roll = Default.Rotation.Roll * Hand;

	setRotation(newRot);
	Canvas.DrawActor(self, false);
}


///////////////////////////////////////
// AltFire
///////////////////////////////////////

function AltFire( float Value )
{
	ClientAltFire(Value);
	GotoState('sSwitchSilencer');
}


///////////////////////////////////////
// ClientAltFire
///////////////////////////////////////

simulated function bool ClientAltFire( float Value )
{
	PlaySwitchSilencer();
	
	if ( Level.NetMode == NM_Client )
		GotoState('cSwitchSilencer');

	return true;
}


///////////////////////////////////////
// PlaySwitchSilencer
///////////////////////////////////////

simulated function PlaySwitchSilencer()
{
	bMuzzleFlash = 0;

	if ( bSilencer )
	{
		PlayAnim('SOff', 0.4, 0.1);
		bSilencer = false;
		bShowWeaponLight = true;
		FireSound = Sound'TODatas.Weapons.MP5_Fire1';
//		Misc1Sound = Sound'TODatas.Weapons.MP5_FAmbient';
//		Misc2Sound = Sound'TODatas.Weapons.MP5_FEnd';
	}
	else
	{
		PlayAnim('SOn', 0.4, 0.1);
		bSilencer = true;
		bShowWeaponLight = false;
		FireSound = Sound'TODatas.Weapons.mp5silenced';
//		Misc1Sound = Sound'TODatas.Weapons.MP5S_FAmbient';
//		Misc2Sound = Sound'TODatas.Weapons.MP5S_FEnd';
	}
}

simulated function bool ClientFire( float Value ) 
{
	// We need to make sure the sound is right if we pickup the weapon on the floor
	if ( bSilencer )		
		FireSound = Sound'TODatas.Weapons.mp5silenced';
	else
		FireSound = Sound'TODatas.Weapons.MP5_Fire1';

	Super.ClientFire(value);
}

///////////////////////////////////////
// PlayFiring
///////////////////////////////////////

simulated function PlayFiring()
{
	Super.PlayFiring();

	if ( bSilencer )
		PlaySynchedAnim('FireS', rofmultiplier / RoundPerMin, 0.01);
	else
		PlaySynchedAnim('FireNS', rofmultiplier / RoundPerMin, 0.01);
}




///////////////////////////////////////
// PlayReloadWeapon
///////////////////////////////////////

simulated function PlayReloadWeapon()
{
	Super.PlayReloadWeapon();

	if ( bSilencer )
		PlayAnim('ReloadS', 0.4, 0.1);
	else
		PlayAnim('ReloadNS', 0.4, 0.1);
}


///////////////////////////////////////
// PlaySelect
///////////////////////////////////////

simulated function PlaySelect()
{
	bForceFire = false;
	bForceAltFire = false;
	bCanClientFire = false;
//	if ( !IsAnimating() )
//	{
		if ( bSilencer )
		{
			if ( AnimSequence != 'SelectFirstS' )
				PlayAnim('SelectFirstS', 0.3, 0.1);
		}
		else
		{
			if ( AnimSequence != 'SelectFirstNS' )
				PlayAnim('SelectFirstNS', 0.3, 0.1);
		}
//	}
	Owner.PlaySound(SelectSound, SLOT_None, Pawn(Owner).SoundDampening);	
}

state ForceIdle
{
	ignores all;

Begin:
	sleep(0.1);
	if ( bSilencer )
		AnimSequence = 'IdleS';
	else
		AnimSequence = 'IdleNS';

	Finish();
}


///////////////////////////////////////
// PlayIdleAnim
///////////////////////////////////////

simulated function PlayIdleAnim()
{
	if ( bSilencer )
		PlayAnim('IDLES', 1.0);
	else
		PlayAnim('IDLENS', 1.0);
}


///////////////////////////////////////
// ForceStillFrame
///////////////////////////////////////

simulated function ForceStillFrame()
{
	TweenToStill();

	if ( bSilencer )
		PlayAnim('fixS', 0.5, 0.1);
	else
		PlayAnim('fixNS', 0.5, 0.1);
}


///////////////////////////////////////
// TweenToStill
///////////////////////////////////////

simulated function TweenToStill()
{
	if ( bSilencer )
		PlayAnim('fixS', 0.1);
	else
		PlayAnim('fixNS', 0.1);
}


///////////////////////////////////////
// TweenDown
///////////////////////////////////////

simulated function TweenDown()
{
//	if ( IsAnimating() && (AnimSequence != '') && (GetAnimGroup(AnimSequence) == 'Select') )
//		TweenAnim( AnimSequence, AnimFrame * 0.4 );
//	else
//		PlayAnim('Down', 1.0, 0.05);
	if (bSilencer)
		PlayAnim('DownS', 0.6, 0.05);
	else
		PlayAnim('DownNS', 0.6, 0.05);
}


///////////////////////////////////////
// sSwitchSilencer
///////////////////////////////////////

state sSwitchSilencer
{
	ignores Fire, AltFire, s_ReloadW, ChangeFireMode;

	simulated function AnimEnd()
	{
		finish();
	}

Begin:

		Sleep(0.0);	
}


///////////////////////////////////////
// cSwitchSilencer
///////////////////////////////////////

state cSwitchSilencer
{
	ignores s_ReloadW, ChangeFireMode;

	simulated function bool ClientFire( float Value ) { return false; }
	simulated function bool ClientAltFire( float Value ) { return false; }
	
	simulated function ForceClientFire()
	{
		Global.ClientFire(0);
	}

	simulated function AnimEnd()
	{
		if ( (Pawn(Owner).bFire != 0) && bUseFireModes && (FireModes[CurrentFireMode] == FM_FullAuto) )
		{
			if ( bUseClip )
			{
				if ( ClipAmmo > 0 ) 
					ForceClientFire();
				else 
				{
					// No ammo left
					if ( EmptyClipSound != None )
						PlayOwnedSound(EmptyClipSound, SLOT_None, Pawn(Owner).SoundDampening);
				}
			}
			else
				ForceClientFire();
		}
		else
		{
			PlayIdleAnim();
			GotoState('');
		}
	}
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
// Draw1
///////////////////////////////////////

simulated function Draw1()
{
	//if ( Level.NetMode != NM_DedicatedServer )	
	//	PlaySound(Sound'TODatas.mp5draw1', SLOT_None, 4.0);
	PlayWeaponSound(Sound'mp5draw1');
}


///////////////////////////////////////
// Draw2
///////////////////////////////////////

simulated function Draw2()
{
	//if ( Level.NetMode != NM_DedicatedServer )	
	//	PlaySound(Sound'TODatas.mp5maglever', SLOT_None, 4.0);
	PlayWeaponSound(Sound'mp5maglever');
}


///////////////////////////////////////
// defaultproperties
///////////////////////////////////////
// PlayerViewOffset=(X=240.000000,Y=100.000000,Z=-60.000000)

/*
 		 Misc1Sound=Sound'TODatas.Weapons.MP5_FAmbient'
		 Misc2Sound=Sound'TODatas.Weapons.MP5_FEnd'
*/

defaultproperties
{
     SwitchSilencerDuration=2.000000
     MuzzleFlashVariations=Texture'TODatas.Muzzle.Muz2'
     MaxDamage=21.000000
     clipSize=30
     clipAmmo=30
     MaxClip=5
     RoundPerMin=800
     price=1500
     BotAimError=0.260000
     PlayerAimError=0.130000
     VRecoil=75.000000
     HRecoil=20.000000
     bHasMultiSkins=True
     ArmsNb=4
     WeaponID=20
     WeaponClass=2
     aReloadWeapon=(AnimSeq=Reload,AnimRate=0.400000)
     MaxWallPiercing=15.000000
     MaxRange=1920.000000
     ProjectileSpeed=15000.000000
     bHeavyWallHit=False
     FireModes(0)=FM_FullAuto
     FireModes(1)=FM_BurstFire
     FireModes(2)=FM_SingleFire
     bUseFireModes=True
     MuzScale=3.300000
     MuzX=630
     MuzY=489
     MuzRadius=64
     WeaponDescription="Classification: HK MP5 Navy"
     PickupAmmoCount=30
     bRapidFire=True
     FireOffset=(X=8.000000,Y=-5.000000)
     MyDamageType=shot
     shakemag=250.000000
     shaketime=0.300000
     shakevert=7.000000
     AIRating=0.600000
     RefireRate=0.990000
     AltRefireRate=0.990000
     FireSound=Sound'TODatas.Weapons.MP5_Fire1'
     DeathMessage="%k's %w turned %o into a leaky piece of meat."
     NameColor=(B=0)
     bDrawMuzzleFlash=True
     MuzzleScale=0.700000
     FlashY=-0.050000
     FlashC=0.002000
     FlashLength=0.001000
     FlashS=64
     AutoSwitchPriority=20
     InventoryGroup=3
     PickupMessage="You got the HK MP5 Navy S.M.G.!"
     ItemName="HK MP5 Navy"
     PlayerViewOffset=(X=225.000000,Y=120.000000,Z=-115.000000)
     PlayerViewMesh=LodMesh'TOModels.mp5N'
     PlayerViewScale=0.120000
     BobDamping=0.975000
     PickupViewMesh=LodMesh'TOModels.pmp5n'
     ThirdPersonMesh=LodMesh'TOModels.wmp5n'
     bMuzzleFlashParticles=True
     MuzzleFlashStyle=STY_Translucent
     MuzzleFlashMesh=LodMesh'Botpack.MuzzFlash3'
     MuzzleFlashScale=0.250000
     MuzzleFlashTexture=Texture'Botpack.Skins.Muzzy'
     PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
     Mesh=LodMesh'TOModels.pmp5n'
     CollisionRadius=25.000000
     CollisionHeight=10.000000
}
