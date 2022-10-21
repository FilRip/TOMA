//----------------------------------------------------------------------------
// Project : TOST
// File    : TOSTFAMAS.uc
// Version : 0.5
// Author  : BugBunny/Shag/H-Lotti
// Note	   : Original code by Shag
//----------------------------------------------------------------------------
// Version	Changes
// 0.5		+ first release
//----------------------------------------------------------------------------

class TOSTSteyrAug extends TOSTWeapon;

#exec texture IMPORT NAME=SteyrTrans	FILE=TEXTURES\Trans\Steyr.pcx	LODSET=2 MIPS=OFF FLAGS=2
#exec texture IMPORT NAME=SteyrSolid	FILE=TEXTURES\Solid\Steyr.pcx	LODSET=2 MIPS=OFF FLAGS=2

var() texture MuzzleFlashVariations[6];

simulated function PostRender( canvas Canvas )
{
	local s_BPlayer P;
	local	float	Scale, OldScale;
	local	int		XO, YO, XOffset, RealXO, RealYO;

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

		P.Bob = 0.10;
		VRecoil = AltVRecoil;
		HRecoil = AltHRecoil;

		// Find if resolution changed (based on 1.33 aspect ratio)
		Scale = min(Canvas.ClipX, Canvas.ClipY/0.75) / 1024.0;
		if ( Scale != OldScale )
		{
			OldScale = Scale;
			XO = min(Canvas.ClipX, Canvas.ClipY/0.75) / 2;
			YO = Canvas.ClipY / 2;
			XOffset = Canvas.ClipX/2 - XO;
			RealXO = XOffset + XO + 4.0*Scale;
			RealYO = YO + 4.0*Scale;
		}

		bOwnsCrosshair = true;
		bMuzzleFlash = 0;
		Canvas.SetPos(0,0);

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

			Canvas.SetPos(RealXO-47*Scale, RealYO-47*Scale);
			Canvas.DrawTile(Texture'SnipeDetails2', 96*Scale , 96*Scale, 101, 206, 49, 49);

			Canvas.SetPos(RealXO-32*Scale, RealYO-32*Scale);
			Canvas.DrawTile(Texture'SnipeDetails2', 64*Scale , 64*Scale, 160, 1, 95, 95);

			Canvas.SetPos(128*Scale, RealYO-2*Scale);
			Canvas.DrawTile(Texture'SnipeDetails2', 152*Scale , 6*Scale, 12, 12, 76, 3);

			Canvas.SetPos(Canvas.ClipX-XOffset-(152+128)*Scale, RealYO-2*Scale);
			Canvas.DrawTile(Texture'SnipeDetails2', 152*Scale , 6*Scale, 88, 12, -76, 3);

			Canvas.SetPos(RealXO-2*Scale, 0);
			Canvas.DrawTile(Texture'SnipeDetails2', 6*Scale , 152*Scale, 12, 16, 3, 76);

			Canvas.SetPos(RealXO-2*Scale, Canvas.ClipY-152*Scale);
			Canvas.DrawTile(Texture'SnipeDetails2', 6*Scale , 152*Scale, 12, 92, 3, -76);
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

		if ( P.bHideCrosshairs )
			bOwnsCrosshair = true;
		else
			bOwnsCrosshair = false;
	}
}

simulated event RenderOverlays( canvas Canvas )
{
	MFTexture = MuzzleFlashVariations[0];
	Super.RenderOverlays(Canvas);
}

function AltFire( float Value )
{
	ClientAltFire(Value);
}

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
		LoopAnim('idle', 0.1);
}

simulated function ClipIn()
{
	PlayWeaponSound(Sound'SAClipin');
}

simulated function ClipOut()
{
	PlayWeaponSound(Sound'SAClipout');
}

simulated function ClipLever()
{
	PlayWeaponSound(Sound'SAClipLever');
}

defaultproperties
{
	AmmoName="5.56mm"
	BackupAmmoName=""

    MaxDamage=38.00
    clipSize=30
    clipAmmo=30
    MaxClip=5
    RoundPerMin=650
    bTracingBullets=True
    TraceFrequency=4
    price=4700
	ClipPrice=60
    BotAimError=0.80
    PlayerAimError=0.40
    VRecoil=90.00
    HRecoil=6.00
    WeaponWeight=25.00
    aReloadWeapon=(AnimSeq=Reload,AnimRate=0.5)
    MaxWallPiercing=25.00
    MaxRange=9600.00
    ProjectileSpeed=15000.00
	FireModes(0)=FM_FullAuto
	FireModes(1)=FM_SingleFire
	bUseFireModes=true

//    MuzzleFlashVariations=Texture'TODatas.Muzzle.Muz10'
	MuzzleFlashVariations(0)=Texture'TODatas.Muzzle.Muz3'
    MuzRadius=64
    MuzScale=2.00
    MuzX=620
    MuzY=442
	XSurroundCorrection=1.15
	YSurroundCorrection=0.9

    WeaponDescription="Classification: Steyr Aug"
    PickupAmmoCount=30
    bRapidFire=True
	Mass=25.000000
    MyDamageType=shot
    shakemag=250.00
    shaketime=0.30
    shakevert=6.00
    AIRating=0.73
    RefireRate=0.99
    AltRefireRate=0.99
    FireSound=Sound'SAFire'
    SelectSound=Sound'Botpack.enforcer.Cocking'
    DeathMessage="%k's %w turned %o into a leaky piece of meat."
    NameColor=(B=0)
    bDrawMuzzleFlash=True
    MuzzleScale=0.80
    FlashY=-0.06
    FlashC=0.002
    FlashLength=0.001
    FlashS=64
    WeaponID=80
    WeaponClass=3
    AutoSwitchPriority=100
    InventoryGroup=4
    PickupMessage="You got the Steyr Aug!"
    ItemName="Steyr Aug"


    PlayerViewOffset=(X=300.00,Y=100.00,Z=-210.00)
    PlayerViewMesh=LodMesh'SteyrAug'
    PlayerViewScale=0.12
    BobDamping=0.98
    PickupViewMesh=LodMesh'pAug'
    ThirdPersonMesh=LodMesh'wAug'
    Mesh=LodMesh'pAug'
	bMuzzleFlashParticles=false
	MuzzleFlashStyle=STY_Translucent
    MuzzleFlashMesh=LodMesh'TO3rdMuzzleSA'
    MuzzleFlashScale=0.25
	MuzzleFlashTexture=Texture'TOModels.3rdmuzzle5'
    PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
	bNoSmooth=False

    CollisionRadius=30.00
    CollisionHeight=10.00

    bHasMultiSkins=True
    ArmsNb=4

    ShellCaseType="s_SWAT.TO_556SC"

	AltVRecoil=150.0
	AltHRecoil=0.4

	SolidTex=texture'SteyrSolid'
	TransTex=texture'SteyrTrans'
}
