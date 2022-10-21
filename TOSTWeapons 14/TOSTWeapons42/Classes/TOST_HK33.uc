//----------------------------------------------------------------------------
// Project : TOST
// File    : TOST_HK33.uc
// Version : 0.5
// Author  : BugBunny/Shag
//----------------------------------------------------------------------------
// Version	Changes
// 0.5		+ first release
//----------------------------------------------------------------------------

class TOST_HK33 expands TOSTWeaponNoRecoilBug;

var() texture 	MuzzleFlashVariations;
var	float		Scale, OldScale;
var	int			XO, YO, XOffset, RealXO, RealYO;

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
		VRecoil = AltVRecoil;
		HRecoil = AltHRecoil;
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
			RealYO = YO - scale;//+ 4.0*Scale;
		}

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

			// Scope details
			Canvas.Style = ERenderStyle.STY_Translucent;
			Canvas.DrawColor.R = 192;
			Canvas.DrawColor.G = 192;
			Canvas.DrawColor.B = 192;

			Canvas.SetPos(RealXO - 250*Scale, RealYO - 9*Scale);
			Canvas.DrawTile(Texture'SnipeDetails2', 120*Scale , 18*Scale, 1, 1, 60, 9);

			Canvas.SetPos(RealXO + 130*Scale, RealYO - 9*Scale);
			Canvas.DrawTile(Texture'SnipeDetails2', 120*Scale , 18*Scale, 61, 1, -60, 9);

			Canvas.SetPos(RealXO - 9*Scale, RealYO - 250*Scale);
			Canvas.DrawTile(Texture'SnipeDetails2', 18*Scale , 120*Scale, 1, 11, 9, 60);

			Canvas.SetPos(RealXO - 9*Scale, RealYO + 130*Scale);
			Canvas.DrawTile(Texture'SnipeDetails2', 18*Scale , 120*Scale, 1, 71, 9, -60);

			Canvas.DrawColor.R = 255;
			Canvas.DrawColor.G = 0;
			Canvas.DrawColor.B = 0;

			Canvas.SetPos(RealXO - 31*Scale, RealYO - 31*Scale);
			Canvas.DrawTile(Texture'SnipeDetails2', 64*Scale , 64*Scale, 1, 154, 49, 49);
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

simulated event RenderOverlays(canvas Canvas)
{
	MFTexture = MuzzleFlashVariations;

	Super.RenderOverlays(Canvas);
}

function AltFire( float Value )
{
	ClientAltFire(Value);
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
		if (zoom_mode > 1)
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
	}
	return true;
}

simulated function PlayIdleAnim()
{
	if ( Mesh == PickupViewMesh )
		return;

	if ( (FRand() > 0.98) && (AnimSequence != 'idle1') )
		PlayAnim('idle1', 0.15);
	else
		LoopAnim('idle',0.2, 0.3);
}

simulated function ClipIn()
{
	PlayWeaponSound(Sound'HK33Clipout');
}

simulated function ClipOut()
{
	PlayWeaponSound(Sound'HK33ClipIn');
}

simulated function ClipLever()
{
	PlayWeaponSound(Sound'OICWClipout2');
}

defaultproperties
{
	AmmoName="5.56mm"
	BackupAmmoName=""

	MaxDamage=33.0
	clipSize=30
	clipAmmo=30
	MaxClip=4
	RoundPerMin=600
	bTracingBullets=true
	FireModes(0)=FM_FullAuto
	bUseFireModes=true
	TraceFrequency=4
	Price=4400
	ClipPrice=50
	BotAimError=0.70
	PlayerAimError=0.35
	VRecoil=200.0
	HRecoil=0.65
	RecoilMultiplier=0.015000
	WeaponID=39
	WeaponClass=3
	AutoSwitchPriority=39
	InventoryGroup=4
	WeaponWeight=25.0
	aReloadWeapon=(AnimSeq=Reload,AnimRate=0.46)
	MaxWallPiercing=20.000000
	MaxRange=10800.0
	ProjectileSpeed=15000.000000

	MuzScale=3.5
	MuzX=621
	MuzY=471
	MuzzleFlashVariations=Texture'TODatas.Muzzle.Muz3'
	MuzRadius=64
	XSurroundCorrection=1.18
	YSurroundCorrection=0.9

	WeaponDescription="Classification: H&K 33 A3 SG1 5.56mm w/ Scope"
	PickupAmmoCount=30
	bRapidFire=True
	Mass=25.000000
	MyDamageType=shot
	shakemag=280.000000
	shaketime=0.400000
	shakevert=9.000000
	AIRating=0.730000
	RefireRate=0.990000
	AltRefireRate=0.990000
	FireSound=Sound'TODatas.Weapons.hk33fire'
	SelectSound=Sound'TODatas.Weapons.Pistol_select'
	DeathMessage="%k's %w turned %o into a leaky piece of meat."
	NameColor=(B=0)
	bDrawMuzzleFlash=True
	MuzzleScale=0.700000
	FlashY=-0.060000
	FlashC=0.002000
	FlashLength=0.001000
	FlashS=64
	PickupMessage="You picked up the HK 33 !"
	ItemName="HK 33"
	PlayerViewOffset=(X=350.000000,Y=180.000000,Z=-230.000000)
	PlayerViewMesh=SkeletalMesh'TOModels.hk33Mesh'
	PlayerViewScale=0.12
	BobDamping=0.975000
	PickupViewMesh=LodMesh'TOModels.phk33'
	ThirdPersonMesh=LodMesh'TOModels.whk33'
	Mesh=LodMesh'TOModels.phk33'
	bMuzzleFlashParticles=false
	MuzzleFlashStyle=STY_Translucent
	MuzzleFlashMesh=LodMesh'TOModels.TO3rdMuzzleHK33'
	MuzzleFlashScale=0.1
	MuzzleFlashTexture=Texture'TOModels.3rdmuzzle5'
	PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
	bNoSmooth=False
	CollisionRadius=30.000000
	CollisionHeight=10.000000
	bHasMultiSkins=true
	ArmsNb=4

	ShellCaseType="s_SWAT.TO_556SC"

	AltVRecoil=150.0
	AltHRecoil=0.4

	SolidTex=texture'TOST4TexSolid.HUD.HK33'
	TransTex=texture'TOST4TexTrans.HUD.HK33'
}
