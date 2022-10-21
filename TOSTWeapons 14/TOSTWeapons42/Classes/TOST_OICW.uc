//----------------------------------------------------------------------------
// Project : TOST
// File    : TOST_OICW.uc
// Version : 0.5
// Author  : BugBunny/Shag/H-Lotti
//----------------------------------------------------------------------------
// Version	Changes
// 0.5		+ first release
//----------------------------------------------------------------------------

class TOST_OICW expands TOSTWeaponNoRecoilBug;

var() 	texture 	MuzzleFlashVariations;
var		float		Scale, OldScale;
var		int			XO, YO, XOffset, RealXO, RealYO;

replication
{
	// Functions server calls on clients
	reliable if ( Role == ROLE_Authority )
		ClientChangeFireMode;
}

simulated function PostRender( canvas Canvas )
{
	local s_BPlayer P;

	Super.PostRender(Canvas);
	P = s_BPlayer(Owner);
	if (P == None)
		return;

	if ( P.bSZoom )
	{
		P.Bob = 0.1;
		bOwnsCrosshair = true;
		bMuzzleFlash = 0;
		VRecoil = default.AltVRecoil;
		HRecoil = default.AltHRecoil;

		Canvas.SetPos(0,0);

		// Find if resolution changed (based on 1.33 aspect ratio)
		Scale = min(Canvas.ClipX, Canvas.ClipY/0.75) / 1024.0;
		if ( Scale != OldScale )
		{
			OldScale = Scale;
			XO = min(Canvas.ClipX, Canvas.ClipY/0.75) / 2;
			YO = Canvas.ClipY / 2;
			XOffset = Canvas.ClipX/2 - XO;
			RealXO = XOffset + XO - scale;//+ 4.0*Scale;
			RealYO = YO - scale;// + 4.0*Scale;
		}

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

			// Scope border
			Canvas.SetPos(XOffset+XO,YO);
			Canvas.DrawTile(Texture'SnipeBorder', XO, YO+1, 255, 255, -255, -255);
			Canvas.SetPos(XOffset,YO);
			Canvas.DrawTile(Texture'SnipeBorder', XO, YO+1, 0, 255, 255, -255);
			Canvas.SetPos(XOffset+XO,0);
			Canvas.DrawTile(Texture'SnipeBorder', XO, YO, 255, 0, -255, 255);
			Canvas.SetPos(XOffset,0);
			Canvas.DrawTile(Texture'SnipeBorder', XO, YO, 0, 0, 255, 255);

			// Non 1.33 aspect ratio borders
			if ( XOffset > 0 )
			{
				Canvas.SetPos(0,0);
				Canvas.DrawTile(Texture'Tile_Black', XOffset, Canvas.ClipY, 0, 0, 16, 16);
				Canvas.SetPos(XOffset+XO*2,0);
				Canvas.DrawTile(Texture'Tile_Black', XOffset+1, Canvas.ClipY, 0, 0, 16, 16);
			}

			// Brighten circle
			Canvas.SetPos(RealXO-60*Scale, RealYO-60*Scale);
			Canvas.DrawTile(Texture'SnipeDetails2', 120*Scale , 120*Scale, 160, 110, 95, 95);

			Canvas.Style = ERenderStyle.STY_Translucent;
			Canvas.DrawColor.R = 255;
			Canvas.DrawColor.G = 0;
			Canvas.DrawColor.B = 0;

			// Red cross
			Canvas.SetPos(RealXO - 31*Scale, RealYO - 31*Scale);
			Canvas.DrawTile(Texture'SnipeDetails2', 64*Scale , 64*Scale, 1, 154, 49, 49);

			Canvas.Style = ERenderStyle.STY_Modulated;
			Canvas.DrawColor.R = 255;
			Canvas.DrawColor.G = 255;
			Canvas.DrawColor.B = 255;

			// Black cross
			Canvas.SetPos(RealXO-47*Scale, RealYO-47*Scale);
			Canvas.DrawTile(Texture'SnipeDetails2', 96*Scale , 96*Scale, 51, 206, 49, 49);

			// Black circle
			Canvas.SetPos(RealXO-60*Scale, RealYO-60*Scale);
			Canvas.DrawTile(Texture'SnipeDetails2', 120*Scale , 120*Scale, 160, 1, 95, 95);

			// Scope details
			Canvas.Style = ERenderStyle.STY_Normal;
			Canvas.SetPos(0, RealYO);
			Canvas.DrawTile(Texture'TODatas.SnipeDetails', RealXO-60*Scale, 2.0*Scale, 2, 1, 6, 1);
			Canvas.SetPos(RealXO+60*Scale, RealYO);
			Canvas.DrawTile(Texture'TODatas.SnipeDetails', RealXO-60*Scale, 2.0*Scale, 2, 1, 6, 1);

			Canvas.SetPos(RealXO, 0);
			Canvas.DrawTile(Texture'TODatas.SnipeDetails', 2.0*Scale, RealYO-60*Scale, 10, 1, 1, 8);
			Canvas.SetPos(RealXO, RealYO+60*Scale);
			Canvas.DrawTile(Texture'TODatas.SnipeDetails', 2.0*Scale, RealYO-60*Scale, 10, 1, 1, 8);
		}
	}
	else
	{
		if (P.SZoomVal != 0.0)
			P.SZoomVal = 0.0;
		if (zoom_mode > 0)
			zoom_mode = 0;

		P.Bob = P.OriginalBob;
		VRecoil = default.VRecoil;
		HRecoil = default.HRecoil;
		if (P.bHideCrosshairs)
			bOwnsCrosshair = true;
		else
			bOwnsCrosshair = false;
	}
}

simulated event RenderOverlays( canvas Canvas )
{
	if ( !bAltMode )
		MFTexture = MuzzleFlashVariations;
	else
		MFTexture = None;

	Super.RenderOverlays(Canvas);
}

function float RateSelf( out int bUseAltMode )
{
	local float dist;

	if ( ClipAmmo <=0 )
		return -2;

	bUseAltMode = 0;

	return AIRating;
}

function GenerateBullet()
{
	local	s_SWATGame	SG;

	// Enhance to support UT GameTypes
	SG = s_SWATGame(Level.Game);

	if ( UseAmmo(1) )
	{
		if ( bAltMode )
			GenerateRocket();
		else
		{
			// If playing a singleplayer game, keep track of the player's shots
			if ( Owner.IsA('PlayerPawn') && (s_SWATGame(Level.Game) != None)
				&& (s_SWATGame(Level.Game).bSinglePlayer && s_Player(Owner) != None) )
				s_SWATGame(Level.Game).IncrementPlayerShotsFired(Pawn(Owner));

			FiringEffects();

			if ( SG != None && SG.bEnableBallistics )
				TraceFireBallistics(AimError);
			else
				TraceFire(AimError);
		}
	}
}

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

		PlayerOwner = PlayerPawn(Owner);

		GetAxes(PawnOwner.ViewRotation,X,Y,Z);
		StartLoc = Owner.Location + TOCalcDrawOffset() + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z;

		AdjustedAim = PawnOwner.AdjustToss(AltProjectileSpeed, StartLoc, AimError, True, bAltWarnTarget);

		if ( PlayerOwner != None )
			AdjustedAim = PawnOwner.ViewRotation;

		FireLocation = StartLoc;

		r = Spawn(class'TO_20mmHE',, '', StartLoc, AdjustedAim);
		r.DrawScale *= 0.5;
}

simulated function bool ClientAltFire( float Value )
{
	local	s_Player	P;

	if ( Level.NetMode == NM_DedicatedServer )
		return false;

	P = s_Player(Owner);

	If (P.zzbNightVision) // don't zoom with NV
		return false;

	PlaySound(Sound'scopezoom', SLOT_None);

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

		if ( zoom_mode == 1)
		{
			P.SZoomVal = 0.50;
			P.StartSZoom();
		}
		else if ( zoom_mode == 2)
		{
			P.SZoomVal = 0.85;
			P.StartSZoom();
		}
	}
	return true;
}

function AltFire( float Value )
{
	ClientAltFire(Value);
}

simulated function PlayReloadWeapon()
{
	Super.PlayReloadWeapon();

	if ( !bAltMode )
		PlayAnim('Reload1', 0.35, 0.05);
	else
		PlayAnim('Reload2', 0.4, 0.05);
}

simulated function PlayIdleAnim()
{
	if ( Mesh == PickupViewMesh )
		return;
	if ( (FRand() > 0.98) && (AnimSequence != 'idle1') )
		PlayAnim('idle1', 0.45);
	else
		LoopAnim('idle',0.2, 0.3);
}

simulated function bool DoChangeFireMode()
{
	local	byte	msg;

	// Force server to be da king for fire mode changing
	if ( Role < Role_Authority )
		return true;

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

simulated function ClientChangeFireMode( bool DesiredbAltMode )
{
	if ( Role == Role_Authority )
		return;

	ChangeFireModeSpecs( DesiredbAltMode );
}

simulated function ChangeFireModeSpecs( bool DesiredbAltMode )
{
	local		int			BClip, BAmmo, BClipSize, BMaxClip, BClipPrice;
	local		string	BAmmoName;

	bAltMode = DesiredbAltMode;
	bMuzzleFlash = 0;

	// Switching Ammo
	BClip = BackupClip;
	BAmmo = BackupAmmo;
	BClipSize = BackupClipSize;
	BMaxClip = BackupMaxClip;
	BClipPrice = BackupClipPrice;
	BAmmoName = BackupAmmoName;

	BackupClip = RemainingClip;
	BackupAmmo = ClipAmmo;
	BackupClipSize = ClipSize;
	BackupMaxClip = MaxClip;
	BackupClipPrice = ClipPrice;
	BackupAmmoName = AmmoName;

	RemainingClip = BClip;
	ClipAmmo = BAmmo;
	ClipSize = BClipSize;
	MaxClip = BMaxClip;
	ClipPrice = BClipPrice;
	AmmoName = BAmmoName;

	if ( bAltMode )
	{
		CurrentFireMode = 1;
		RoundPerMin = default.AltRoundPerMin;
	}
	else
	{
		CurrentFireMode = 0;
		RoundPerMin = Default.RoundPerMin;
	}
}

simulated function PlayFiring()
{
	if ( bAltMode )
		FireSound=Sound'TODatas.OICWGrenFire';
	else
		FireSound=Sound'TODatas.OICWNormFire';

	Super.PlayFiring();
}

simulated function ClipIn()
{
	PlayWeaponSound(Sound'OICWClipin1');
}

simulated function ClipOut()
{
	PlayWeaponSound(Sound'OICWClipout1');
}

defaultproperties
{
	// Backup Ammo
	BackupClip=0
	BackupAmmo=4
	BackupClipSize=4
	BackupMaxClip=2
	BackupClipPrice=1000
	BackupAmmoName="20mm HE"

	//Ammo
	clipSize=25
	clipAmmo=25
	RemainingClip=0
	MaxClip=6
	ClipPrice=100
	AmmoName="5.56mm"
	ShellCaseType="s_SWAT.TO_556SC"

	MaxDamage=35.0
	RoundPerMin=650
	bTracingBullets=true
	TraceFrequency=4
	Price=16000
	BotAimError=0.4
	PlayerAimError=0.2
	VRecoil=200.0
	HRecoil=0.6
	WeaponID=38
	WeaponClass=3
	AutoSwitchPriority=38
	InventoryGroup=4
	WeaponWeight=40.0
	aReloadWeapon=(AnimSeq=Reload)
	MaxWallPiercing=25.0
	MaxRange=12000.0
	ProjectileSpeed=15000.0
	FireModes(0)=FM_FullAuto
	FireModes(1)=FM_SingleFire
	bUseFireModes=true

	MuzzleFlashVariations=Texture'TODatas.Muzzle.Muz4'
	MuzRadius=64
	MuzScale=3.0
	MuzX=634
	MuzY=464
	XSurroundCorrection=1.1
	YSurroundCorrection=0.9

	WeaponDescription="Classification: Objective Individual Combat Weapon"
	PickupAmmoCount=25
	bRapidFire=true
	Mass=25.0
	MyDamageType=shot
	shakemag=250.0
	shaketime=0.3
	AIRating=0.73
	RefireRate=0.99
	AltRefireRate=0.99
	FireSound=None
	SelectSound=Sound'TODatas.Weapons.Pistol_select'
	bDrawMuzzleFlash=true
	MuzzleScale=0.8
	FlashY=-0.06
	FlashC=0.002
	FlashLength=0.001
	FlashS=64
	PickupMessage="You picked up the OICW !"
	ItemName="OICW"
	PlayerViewOffset=(X=240.0,Y=180.0,Z=-230.0)
	PlayerViewMesh=SkeletalMesh'TOModels.oicwMesh'
	PlayerViewScale=0.122
	BobDamping=0.975
	PickupViewMesh=LodMesh'TOModels.OICWp'
	ThirdPersonMesh=LodMesh'TOModels.OICWw'
	Mesh=LodMesh'TOModels.OICWp'
	bMuzzleFlashParticles=false
	MuzzleFlashStyle=STY_Translucent
	MuzzleFlashMesh=LodMesh'TOModels.TO3rdMuzzleHK33'
	MuzzleFlashScale=0.1
	MuzzleFlashTexture=Texture'TOModels.3rdmuzzle5'
	PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
	bNoSmooth=false

	CollisionRadius=30.0
	CollisionHeight=10.0

	bHasMultiSkins=true
	ArmsNb=3

	AltVRecoil=150
	AltHRecoil=0.4
	AltRoundPerMin=45

	SolidTex=texture'TOST4TexSolid.HUD.OICW'
	TransTex=texture'TOST4TexTrans.HUD.OICW'
}
