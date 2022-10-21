//=============================================================================
// s_PSG1
//=============================================================================
//
// Tactical Ops
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen
//=============================================================================

class s_PSG1 extends s_Weapon;

var vector dlyStartTrace, dlyEndTrace, dlyAimDir;


///////////////////////////////////////
// PostRender
///////////////////////////////////////

simulated function PostRender( canvas Canvas )
{
	local s_BPlayer P;

	Super.PostRender(Canvas);
	P = s_BPlayer(Owner);
	if ( P == None )
		return;

	if ( P.bSZoom ) 
	{
		P.Bob = 0.1;
		if ((zoom_mode == 0 || zoom_mode == 1) && P.SZoomVal != 0.50)
			P.SZoomVal = 0.50;
		else if (zoom_mode == 2 && P.SZoomVal != 0.85)
			P.SZoomVal = 0.85;

		bOwnsCrosshair = true;
		bMuzzleFlash = 0;
		Canvas.SetPos(0,0);

		if ( P.bHUDModFix )
		{
			Canvas.Style = ERenderStyle.STY_Normal;
			Canvas.DrawTile(Texture'TODatas.Sniper2fix', Canvas.ClipX, Canvas.ClipY, 0, 0, 256, 256);
		}
		else
		{
			Canvas.Style = ERenderStyle.STY_Modulated;
			Canvas.DrawColor.R = 255;
			Canvas.DrawColor.G = 255;
			Canvas.DrawColor.B = 255;
		
			Canvas.DrawTile(Texture'TODatas.Sniper2', Canvas.ClipX, Canvas.ClipY, 0, 0, 256, 256);
		}
	}
	else
	{
		if ( P.SZoomVal != 0.0 )
			P.SZoomVal = 0.0;
		if ( zoom_mode > 0 )
			zoom_mode = 0;
		P.Bob = P.OriginalBob;
		// No crosshairs when not zooming
		//if ( P.bHideCrosshairs )
			bOwnsCrosshair = true;
		//else
		//	bOwnsCrosshair = false;
	}
}


///////////////////////////////////////
// RateSelf
///////////////////////////////////////

function float RateSelf( out int bUseAltMode )
{
	local float dist;

	bUseAltMode = 0;
	if ( (Bot(Owner) != None) && Bot(Owner).bSniping )
		return AIRating + 1.15;

	if (  Pawn(Owner).Enemy != None )
	{
		dist = VSize(Pawn(Owner).Enemy.Location - Owner.Location);
		if ( dist > 1200 )
		{
			if ( dist > 2000 )
				return (AIRating + 0.75);
			return (AIRating + FMin(0.0001 * dist, 0.45)); 
		}
	}
	return AIRating;
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

	P = s_BPlayer(Owner);
	PlaySound(Sound'scopezoom', SLOT_None);
	if ( P != None )
	{
		P.bSZoomStraight = true;
		
		zoom_mode++;
		if ( zoom_mode > 2 )
			zoom_mode = 0;
		if ( (P.bSZoom == false) && (zoom_mode > 0) )
			P.ToggleSZoom();
		else if ( (P.bSZoom == true) && (zoom_mode == 0) )
			P.ToggleSZoom();
		//PlaySound(Sound'NV_on', SLOT_None);
	}
	//GotoState('Zooming');
	return true;
}


///////////////////////////////////////
// TraceFire
///////////////////////////////////////
// Implementing delayed fire
// To simulate distance and bullet speed

function TraceFire( float Accuracy )
{
  local vector /*StartTrace, EndTrace,*/ X,Y,Z /*, AimDir*/;
	local Pawn PawnOwner;

	if ( Level.NetMode != NM_StandAlone )
	{
		Super.TraceFire(Accuracy);
		return;
	}

	Accuracy = AimError;

	//log("s_Weapon::TraceFire - Accuracy:"@Accuracy);
	PawnOwner = Pawn(Owner);

	GetAxes(PawnOwner.ViewRotation, X, Y, Z);

	if ( Owner.IsA('s_BPlayer') )
	{
		dlyStartTrace = Owner.Location + CalcDrawOffset() /*+ Instigator.Eyeheight * Z + X*/;
		AdjustedAim = PawnOwner.AdjustAim(1000000, dlyStartTrace, AimError, False, False);	
		dlyEndTrace = dlyStartTrace + Accuracy * (FRand() - 0.5 ) * Y * 1000 + Accuracy * (FRand() - 0.5 ) * Z * 1000;
		X = vector(AdjustedAim) / VSize(vector(AdjustedAim));
		dlyEndTrace += (MaxRange * X);
		dlyAimDir = X;
		//log("s_Weapon::TraceFire - StartTrace:"@StartTrace@"- EndTrace:"@EndTrace);

		FireBulletDelayedHit();
	}
	else
	{
		dlyStartTrace = Owner.Location + CalcDrawOffset() + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z; 
		AdjustedAim = PawnOwner.AdjustAim(1000000, dlyStartTrace, AimError, False, False);	
		dlyEndTrace = dlyStartTrace + Accuracy * (FRand() - 0.5 )* Y * 1000 + Accuracy * (FRand() - 0.5 ) * Z * 1000;
		X = vector(AdjustedAim) / VSize(vector(AdjustedAim));
		dlyEndTrace += (MaxRange * X); 
		dlyAimDir = (dlyEndTrace - dlyStartTrace) / VSize(dlyEndTrace - dlyStartTrace);

		FireBulletDelayedHit();
	}

}


///////////////////////////////////////
// FireBulletDelayedHit
///////////////////////////////////////

function FireBulletDelayedHit()
{
	local vector	HitLocation, HitNormal, X,Y,Z, OldLocation, TempLocation;
	local actor		Other;
	local Pawn		PawnOwner;
	local float		SmokeDS, Range, Damage, length;
	local	int			i;
	local	bool		bReduceSFX;
	local ut_SpriteSmokePuff s;

	SmokeDS = 0.6 + MaxWallPiercing / 24.0;
	Damage = MaxDamage;
	Range = MaxRange;

	PawnOwner = Pawn(Owner);

	GetAxes(PawnOwner.ViewRotation, X, Y, Z);

	Other = Trace(HitLocation, HitNormal, dlyEndTrace, dlyStartTrace, true);
	length = VSize(HitLocation - dlyStartTrace);
	
	SetTimer(length/ProjectileSpeed, false);
}


function Timer()
{
	FireBulletInstantHit(dlyStartTrace, dlyEndTrace, dlyAimDir);
}

/*
///////////////////////////////////////
// s_PlayFiring
///////////////////////////////////////

simulated function s_PlayFiring()
{
	Super.s_PlayFiring();

	if ( (PlayerPawn(Owner) != None) 
		&& (PlayerPawn(Owner).DesiredFOV == PlayerPawn(Owner).DefaultFOV) )
		bMuzzleFlash++;
}
*/
/*
///////////////////////////////////////
// PlayFiring
///////////////////////////////////////

simulated function PlayFiring()
{
	//log("s_PSG1::PlayFiring");

	Super.PlayFiring();

//	if ( (PlayerPawn(Owner) != None) 
//		&& (PlayerPawn(Owner).DesiredFOV == PlayerPawn(Owner).DefaultFOV) )
//		bMuzzleFlash++;

	PlaySynchedAnim('Fire', 60.0 / RoundPerMin, 0.1);
}
*/

///////////////////////////////////////
// PlayIdleAnim
///////////////////////////////////////

simulated function PlayIdleAnim()
{
	if ( Mesh != PickupViewMesh )
		PlayAnim('idle',1.0, 0.05);
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
// Modes(1)=(Type=2)

defaultproperties
{
     MaxDamage=125.000000
     clipSize=5
     clipAmmo=5
     MaxClip=4
     RoundPerMin=90
     price=4350
     ClipPrice=15
     BotAimError=0.600000
     PlayerAimError=1.700000
     VRecoil=750.000000
     HRecoil=20.000000
     bZeroAccuracy=True
     bHasMultiSkins=True
     ArmsNb=5
     WeaponID=35
     WeaponClass=3
     WeaponWeight=25.000000
     aReloadWeapon=(AnimSeq=Reload,AnimRate=0.500000)
     MaxWallPiercing=35.000000
     MaxRange=14400.000000
     ProjectileSpeed=16000.000000
     FireModes(0)=FM_SingleFire
     MuzX=578
     MuzY=434
     ShellCaseType="s_SWAT.s_762ShellCase"
     WeaponDescription="Classification: HK PSG1"
     PickupAmmoCount=5
     FiringSpeed=1.800000
     FireOffset=(Y=-5.000000,Z=5.000000)
     MyDamageType=shot
     AltDamageType=Decapitated
     shaketime=0.300000
     shakevert=15.000000
     AIRating=0.540000
     RefireRate=0.600000
     AltRefireRate=0.300000
     FireSound=Sound'TODatas.Weapons.PSG1fire'
     SelectSound=Sound'Botpack.enforcer.Cocking'
     DeathMessage="%k put a bullet through %o's head."
     NameColor=(R=0,G=0)
     bDrawMuzzleFlash=True
     MuzzleScale=1.000000
     FlashY=0.100000
     FlashO=0.025000
     FlashC=0.031000
     FlashLength=0.006000
     FlashS=256
     MFTexture=Texture'Botpack.Rifle.MuzzleFlash2'
     AutoSwitchPriority=35
     InventoryGroup=4
     PickupMessage="You got the HK PSG1 Sniper Rifle!"
     ItemName="HK PSG1"
     PlayerViewOffset=(X=260.000000,Y=100.000000,Z=-75.000000)
     PlayerViewMesh=LodMesh'TOModels.PSG1'
     PlayerViewScale=0.115000
     BobDamping=0.975000
     PickupViewMesh=LodMesh'TOModels.pPSG1'
     ThirdPersonMesh=LodMesh'TOModels.wPSG1'
     bMuzzleFlashParticles=True
     MuzzleFlashStyle=STY_Translucent
     MuzzleFlashMesh=LodMesh'Botpack.muzzsr3'
     MuzzleFlashScale=0.100000
     MuzzleFlashTexture=Texture'Botpack.Skins.Muzzy3'
     PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
     Rotation=(Roll=-1536)
     Mesh=LodMesh'TOModels.pPSG1'
     CollisionRadius=32.000000
     CollisionHeight=10.000000
}
