//=============================================================================
// s_p85
//=============================================================================
//
// Tactical Ops
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen
//=============================================================================

class s_p85 extends s_PSG1;


//////////////////////////////////////
// PostRender
///////////////////////////////////////

simulated function PostRender( canvas Canvas )
{
	local s_BPlayer P;

	Super(s_Weapon).PostRender(Canvas);
	P = s_BPlayer(Owner);
	if (P == None)
		return;

	if ( P.bSZoom ) 
	{
		if ((zoom_mode == 0 || zoom_mode == 1) && P.SZoomVal != 0.50)
			P.SZoomVal = 0.50;
		else if (zoom_mode == 2 && P.SZoomVal != 0.85)
			P.SZoomVal = 0.85;

		P.Bob = 0.1;
		bOwnsCrosshair = true;
		bMuzzleFlash = 0;
		Canvas.SetPos(0,0);

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
		
			Canvas.DrawTile(Texture'TODatas.Sniper1', Canvas.ClipX, Canvas.ClipY, 0, 0, 256, 256);
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
		//if (P.bHideCrosshairs)
			bOwnsCrosshair = true;
		//else
		//	bOwnsCrosshair = false;
	}
}


///////////////////////////////////////
// ZoomOut
///////////////////////////////////////

simulated function ZoomOut()
{
	if ( (Level.NetMode != NM_DedicatedServer) && (s_BPlayer(Owner) != None) && s_BPlayer(Owner).bSZoom )
		s_BPlayer(Owner).ToggleSZoom();
//		TurnSZoomOff();
}


///////////////////////////////////////
// PlayP85Reload
///////////////////////////////////////

simulated function PlayP85Reload()
{
	local vector X,Y,Z;

	//PlayOwnedSound(Sound'TODatas.p85reload', SLOT_None, Pawn(Owner).SoundDampening,,, 1.25);
	PlayWeaponSound(Sound'p85reload');
	if ( (Role == Role_Authority) && (Owner != None) )
	{
		GetAxes(Pawn(Owner).ViewRotation, X, Y, Z);

		SpawnShellCase(X, Y, Z);
	}
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
// defaultproperties 
///////////////////////////////////////
// Modes(1)=(Type=2)

defaultproperties
{
     MaxDamage=200.000000
     clipSize=10
     clipAmmo=10
     RoundPerMin=45
     price=8500
     PlayerAimError=1.600000
     VRecoil=400.000000
     HRecoil=40.000000
     ArmsNb=6
     WeaponID=36
     MaxWallPiercing=45.000000
     MaxRange=16800.000000
     ProjectileSpeed=18000.000000
     MuzX=572
     MuzY=433
     bUseShellCase=False
     WeaponDescription="Classification: Parker Hale 85 Sniper Rifle"
     FireSound=Sound'TODatas.Weapons.p85fire'
     AutoSwitchPriority=36
     PickupMessage="You got the Parker Hale 85 Sniper Rifle!"
     ItemName="Parker Hale 85"
     PlayerViewOffset=(X=255.000000,Y=75.000000,Z=-35.000000)
     PlayerViewMesh=LodMesh'TOModels.P85'
     PickupViewMesh=LodMesh'TOModels.pp85'
     ThirdPersonMesh=LodMesh'TOModels.wp85'
     Mesh=LodMesh'TOModels.pp85'
}
