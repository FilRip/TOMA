//----------------------------------------------------------------------------
// Project : TOST
// File    : TOST_P85.uc
// Version : 0.5
// Author  : BugBunny/Shag
//----------------------------------------------------------------------------
// Version	Changes
// 0.5		+ first release
//----------------------------------------------------------------------------

class TOST_P85 extends TOST_PSG1;

simulated function PostRender( canvas Canvas )
{
	local s_BPlayer P;

	Super(s_Weapon).PostRender(Canvas);
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
			RealXO = XOffset + XO - scale;// + 4.0*Scale;
			RealYO = YO - scale;// + 4.0*Scale;
		}

		if ( P.bHUDModFix )
		{
			Canvas.Style = ERenderStyle.STY_Normal;
			Canvas.DrawTile(Texture'TODatas.Sniper1fix', Canvas.ClipX, Canvas.ClipY, 0, 0, 256, 256);
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

			Canvas.SetPos(RealXO-60*Scale, RealYO-60*Scale);
			Canvas.DrawTile(Texture'SnipeDetails2', 120*Scale , 120*Scale, 160, 110, 95, 95);

			Canvas.SetPos(RealXO-32*Scale, RealYO-32*Scale);
			Canvas.DrawTile(Texture'SnipeDetails2', 64*Scale , 64*Scale, 160, 110, 95, 95);

			Canvas.SetPos(RealXO-47*Scale, RealYO-47*Scale);
			Canvas.DrawTile(Texture'SnipeDetails2', 96*Scale , 96*Scale, 101, 206, 49, 49);

			Canvas.SetPos(RealXO-60*Scale, RealYO-60*Scale);
			Canvas.DrawTile(Texture'SnipeDetails2', 120*Scale , 120*Scale, 160, 1, 95, 95);

			Canvas.SetPos(RealXO-32*Scale, RealYO-32*Scale);
			Canvas.DrawTile(Texture'SnipeDetails2', 64*Scale , 64*Scale, 160, 1, 95, 95);

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
		if ( P.SZoomVal != 0.0 )
			P.SZoomVal = 0.0;
		if ( zoom_mode > 0 )
			zoom_mode = 0;

		P.Bob = P.OriginalBob;
		bOwnsCrosshair = true;
	}
}

simulated function ZoomOut()
{
	if ( (Owner==None) || (PlayerPawn(Owner) == None) || (PlayerPawn(Owner).Player==None))
		return;

	if ( PlayerPawn(Owner).Player.IsA('ViewPort') && (s_BPlayer(Owner) != None) && s_BPlayer(Owner).bSZoom )
		s_BPlayer(Owner).ToggleSZoom();
}


simulated function PlayP85Reload()
{
	local vector X,Y,Z;

	PlayWeaponSound(Sound'p85reload');
	if ( (Role == Role_Authority) && (Owner != None) )
	{
		GetAxes(Pawn(Owner).ViewRotation, X, Y, Z);

		SpawnShellCase(X, Y, Z);
	}
}

simulated function ClipIn()
{
	PlayWeaponSound(Sound'OICWClipin1');
}

simulated function ClipOut()
{
	PlayWeaponSound(Sound'OICWClipout1');
}

simulated function ClipSet()
{
	PlayWeaponSound(Sound'TODatas.BerClipOut');
}

defaultproperties
{
	AmmoName="7.62mm"
	BackupAmmoName=""

	shakevert=15.000000
	WeaponWeight=35.0

	FireSound=Sound'TODatas.Weapons.p85fire'
	bUseShellCase=false

	MuzX=563
	MuzY=416
	XSurroundCorrection=1.12
	YSurroundCorrection=0.95

	BotAimError=0.500000
	PlayerAimError=3.5000000

	VRecoil=600.0
	HRecoil=60.0

	MaxDamage=210.0
	clipSize=10
	clipAmmo=10
	RoundPerMin=35
	Price=8600
	ClipPrice=80
	BotAimError=0.600000
	PlayerAimError=15.0
	WeaponID=36
	MaxWallPiercing=45.000000
	MaxRange=57600.0
	ProjectileSpeed=18000.000000
	WeaponDescription="Classification: Parker Hale 85 Bolt-Action Rifle"
	PickupMessage="You picked up the Parker-Hale 85 !"
	ItemName="Parker-Hale 85"
	AutoSwitchPriority=36
	PlayerViewOffset=(X=145.000000,Y=170.000000,Z=-250.000000)
	PlayerViewMesh=SkeletalMesh'TOModels.parkerMesh'
	PlayerViewScale=0.120
	PickupViewMesh=LodMesh'TOModels.pp85'
	ThirdPersonMesh=LodMesh'TOModels.wp85'
	Mesh=LodMesh'TOModels.pp85'
	aReloadWeapon=(AnimSeq=Reload,AnimRate=0.5)
	bHasMultiSkins=true
	ArmsNb=3

	SolidTex=texture'TOST4TexSolid.HUD.PH85'
	TransTex=texture'TOST4TexTrans.HUD.PH85'
}

