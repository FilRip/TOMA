//----------------------------------------------------------------------------
// Project : TOST
// File    : TOST_SteyrAug.uc
// Version : 0.5
// Author  : BugBunny/Shag
//----------------------------------------------------------------------------
// Version	Changes
// 0.5		+ first release
//----------------------------------------------------------------------------

class TOST_SteyrAug expands TOSTWeaponNoRecoilBug;

var() texture	MuzzleFlashVariations[6];
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
		P.Bob = 0.10;
		VRecoil = default.AltVRecoil;
		HRecoil = default.AltHRecoil;

		// Find if resolution changed (based on 1.33 aspect ratio)
		Scale = min(Canvas.ClipX, Canvas.ClipY/0.75) / 1024.0;
		if ( Scale != OldScale )
		{
			OldScale = Scale;
			XO = min(Canvas.ClipX, Canvas.ClipY/0.75) / 2;
			YO = Canvas.ClipY / 2;
			XOffset = Canvas.ClipX/2 - XO;
			RealXO = XOffset + XO - scale;// + 4.0*Scale;
			RealYO = YO - scale;// + 4.0*Scale;
		}

		bOwnsCrosshair = true;
		bMuzzleFlash = 0;
		Canvas.SetPos(0,0);

		if ( P.bHUDModFix )
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
		VRecoil = default.VRecoil;
		HRecoil = default.HRecoil;

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
		LoopAnim('idle', 0.1);
}

simulated function ClipIn()
{
	PlayWeaponSound(Sound'OICWClipin1');
}

simulated function ClipOut()
{
	PlayWeaponSound(Sound'OICWClipout1');
}

simulated function ClipLever()
{
	PlayWeaponSound(Sound'OICWClipout2');
}

defaultproperties
{
	AmmoName="5.56mm"
	BackupAmmoName=""

	MaxDamage=36.0
	clipSize=30
	clipAmmo=30
	MaxClip=4
	RoundPerMin=550
	bTracingBullets=True
	TraceFrequency=4
	Price=4600
	ClipPrice=60
	BotAimError=0.72
	PlayerAimError=0.36
	VRecoil=200.0
	HRecoil=0.65
	WeaponWeight=28.0
	aReloadWeapon=(AnimSeq=Reload,AnimRate=0.5)
	MaxWallPiercing=25.0
	MaxRange=12000.0
	ProjectileSpeed=15000.0
	FireModes(0)=FM_FullAuto
	FireModes(1)=FM_SingleFire
	bUseFireModes=true

	MuzzleFlashVariations(0)=Texture'TODatas.Muzzle.Muz3'
	MuzRadius=64
	MuzScale=3.0
	MuzX=618
	MuzY=465
	XSurroundCorrection=1.15
	YSurroundCorrection=0.9

	WeaponDescription="Classification: Sig 551 Commando Automatic Rifle"
	PickupAmmoCount=30
	bRapidFire=True
	Mass=25.000000
	MyDamageType=shot
	shakemag=250.000000
	shaketime=0.300000
	shakevert=6.000000
	AIRating=0.730000
	RefireRate=0.990000
	AltRefireRate=0.990000
	FireSound=Sound'TODatas.Weapons.augfire'
	SelectSound=Sound'TODatas.Weapons.Pistol_select'
	DeathMessage="%k's %w turned %o into a leaky piece of meat."
	NameColor=(B=0)
	bDrawMuzzleFlash=True
	MuzzleScale=0.800000
	FlashY=-0.060000
	FlashC=0.002000
	FlashLength=0.001000
	FlashS=64
	WeaponID=37
	WeaponClass=3
	AutoSwitchPriority=37
	InventoryGroup=4
	PickupMessage="You picked up the Sig 551 !"
	ItemName="Sig 551"

	PlayerViewOffset=(X=230.000000,Y=160.000000,Z=-250.000000)
	PlayerViewMesh=SkeletalMesh'TOModels.sg551Mesh'
	PlayerViewScale=0.125
	BobDamping=0.975000
	PickupViewMesh=LodMesh'TOModels.pSIG552'
	ThirdPersonMesh=LodMesh'TOModels.wSIG552'
	Mesh=LodMesh'TOModels.paug'
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

	AltVRecoil=150
	AltHRecoil=0.4

	SolidTex=texture'TOST4TexSolid.HUD.Sig551'
	TransTex=texture'TOST4TexTrans.HUD.Sig551'
}
