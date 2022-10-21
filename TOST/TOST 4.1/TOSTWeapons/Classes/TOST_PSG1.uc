//----------------------------------------------------------------------------
// Project : TOST
// File    : TOST_PSG1.uc
// Version : 0.5
// Author  : BugBunny/Shag
//----------------------------------------------------------------------------
// Version	Changes
// 0.5		+ first release
//----------------------------------------------------------------------------


class TOST_PSG1 extends TOSTWeapon;

var	float	Scale, OldScale;
var	int		XO, YO, XOffset, RealXO, RealYO;

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

		bOwnsCrosshair = true;
		bMuzzleFlash = 0;
		Canvas.SetPos(0,0);

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

			Canvas.SetPos(RealXO-48*Scale, RealYO-48*Scale);
			Canvas.DrawTile(Texture'SnipeDetails2', 96*Scale , 96*Scale, 160, 110, 95, 95);

			Canvas.SetPos(RealXO-48*Scale, RealYO-48*Scale);
			Canvas.DrawTile(Texture'SnipeDetails2', 96*Scale , 96*Scale, 160, 1, 95, 95);

			Canvas.SetPos(128*Scale, RealYO-2*Scale);
			Canvas.DrawTile(Texture'SnipeDetails2', 152*Scale , 6*Scale, 12, 12, 76, 3);

			Canvas.SetPos(Canvas.ClipX-XOffset-(152+128)*Scale, RealYO-2*Scale);
			Canvas.DrawTile(Texture'SnipeDetails2', 152*Scale , 6*Scale, 88, 12, -76, 3);

			Canvas.SetPos(RealXO-2*Scale, 0);
			Canvas.DrawTile(Texture'SnipeDetails2', 6*Scale , 152*Scale, 12, 16, 3, 76);

			Canvas.SetPos(RealXO-2*Scale, Canvas.ClipY-152*Scale);
			Canvas.DrawTile(Texture'SnipeDetails2', 6*Scale , 152*Scale, 12, 92, 3, -76);

			// Scope details
			Canvas.Style = ERenderStyle.STY_Normal;
			Canvas.SetPos(0,RealYO);
			Canvas.DrawTile(Texture'TODatas.SnipeDetails', Canvas.ClipX, 2.0*Scale, 1, 1, 8, 1);

			Canvas.SetPos(RealXO,0);
			Canvas.DrawTile(Texture'TODatas.SnipeDetails', 2.0*Scale, Canvas.ClipY, 10, 1, 1, 8);
		}
	}
	else
	{
		if ( P.SZoomVal != 0.0 )
			P.SZoomVal = 0.0;
		if ( zoom_mode > 0 )
			zoom_mode = 0;

		P.Bob = P.OriginalBob;
		bOwnsCrosshair = true;
	}
}

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

function AltFire( float Value )
{
	if ( PlayerPawn(Owner).Player.IsA('ViewPort') )
		ClientAltFire(Value);
}

simulated function bool ClientAltFire( float Value )
{
	local	s_Player	P;

	if ( !PlayerPawn(Owner).Player.IsA('ViewPort') )
		return false;

	P = s_Player(Owner);

	If (P.zzbNightVision) // don't zoom with NV
		return false;

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

function GenerateBullet()
{
	local	float	BackupFOV;
	local Pawn PawnOwner;

	PawnOwner = Pawn(Owner);
	BackupFOV = PawnOwner.FOVAngle;
	PawnOwner.FOVAngle = 90.0;

	Super.GenerateBullet();

	PawnOwner.FOVAngle = BackupFOV;
}

simulated function PlayIdleAnim()
{
	if ( Mesh != PickupViewMesh )
		PlayAnim('idle',1.0, 0.05);
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
	AmmoName="7.62mm"
	BackupAmmoName=""

	bZeroAccuracy=true
	FireModes(0)=FM_SingleFire
	MaxDamage=130.0
	clipSize=5
	clipAmmo=5
	MaxClip=4
	RoundPerMin=90
	Price=4300
	ClipPrice=40
	BotAimError=0.6
	PlayerAimError=12.0
	VRecoil=750.0
	HRecoil=150.0
	WeaponID=35
	WeaponClass=3
	WeaponWeight=30.0
	aReloadWeapon=(AnimSeq=Reload,AnimRate=0.5)
	MaxWallPiercing=35.0
	MaxRange=43200.0
	ProjectileSpeed=16000.0

	MuzX=590
	MuzY=434
	XSurroundCorrection=1.05
	YSurroundCorrection=0.9

	WeaponDescription="Classification: SR 90 Sniper rifle."
	PickupAmmoCount=5
	FiringSpeed=1.8
	MyDamageType=shot
	shakemag=300.0
	shaketime=0.3
	shakevert=15.0
	AIRating=0.54
	RefireRate=0.6
	AltRefireRate=0.3
	FireSound=Sound'TODatas.Weapons.PSG1fire'
	SelectSound=Sound'TODatas.Weapons.Pistol_select'
	bDrawMuzzleFlash=true
	MuzzleScale=1.0
	FlashY=0.1
	FlashO=0.025
	FlashC=0.031
	FlashLength=0.006
	FlashS=256
	MFTexture=Texture'Botpack.Rifle.MuzzleFlash2'
	AutoSwitchPriority=35
	InventoryGroup=4
	PickupMessage="You got the SR 90 Sniper rifle!"
	ItemName="SR90"
	PlayerViewOffset=(X=290.0,Y=170.0,Z=-260.0)
	PlayerViewMesh=SkeletalMesh'TOModels.msg90Mesh'
	PlayerViewScale=0.12
	BobDamping=0.975
	PickupViewMesh=LodMesh'TOModels.pMSG90'
	ThirdPersonMesh=LodMesh'TOModels.wMSG90'
	Mesh=LodMesh'TOModels.pPSG1'
	bMuzzleFlashParticles=false
	MuzzleFlashStyle=STY_Translucent
	MuzzleFlashMesh=LodMesh'TOModels.TO3rdMuzzleSnipers'
	MuzzleFlashScale=0.1
	MuzzleFlashTexture=Texture'TOModels.3rdmuzzle6'
	PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
	bNoSmooth=false
	CollisionRadius=32.0
	CollisionHeight=10.0
	bHasMultiSkins=true
	ArmsNb=3
	Mass=25.0
	ShellCaseType="s_SWAT.s_762ShellCase"

	SolidTex=texture'TOST4TexSolid.HUD.MSG90'
	TransTex=texture'TOST4TexTrans.HUD.MSG90'
}
