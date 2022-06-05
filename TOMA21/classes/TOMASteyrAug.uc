class TOMASteyrAug extends TO_SteyrAug;
// Original code from Laurent "Shag" Delayen

#exec OBJ LOAD FILE=..\Textures\TOMATex21.utx PACKAGE=TOMATex

var() texture MuzzleFlashVariations[6];

simulated function PostRender(canvas Canvas)
{
	local s_BPlayer P;
	local float XO,YO,Scale,Scale128,Scale64;

	super(s_Weapon).PostRender(Canvas);
	P=s_BPlayer(Owner);
	if (P==None)
		return;

	if (P.bSZoom)
	{
		if (((zoom_mode==0) || (zoom_mode==1)) && (P.SZoomVal!=0.50))
			P.SZoomVal=0.50;
		else if ((zoom_mode==2) && (P.SZoomVal!=0.85))
			P.SZoomVal=0.85;

		P.Bob=0.10;
		VRecoil=150.000000;
		HRecoil=0.400000;

		bOwnsCrosshair=true;
		bMuzzleFlash=0;
		Canvas.SetPos(0,0);

		if (P.bHUDModFix)
		{
			Canvas.Style=ERenderStyle.STY_Normal;
			Canvas.DrawTile(Texture'TODatas.Sniper4fix',Canvas.ClipX,Canvas.ClipY,0,0,256,256);
		}
		else
		{
			Canvas.Style=ERenderStyle.STY_Modulated;
			Canvas.DrawColor.R=255;
			Canvas.DrawColor.G=255;
			Canvas.DrawColor.B=255;

			Canvas.DrawTile(texture'TOMATex21.Weapons.Sniper5',Canvas.ClipX,Canvas.ClipY,0,0,256,256);

			Canvas.Style=ERenderStyle.STY_Translucent;
			XO=Canvas.ClipX/2;
			YO=Canvas.ClipY/2;
			Scale=Canvas.ClipX/1024;
			Scale128=Scale*512;
			Scale64=Scale*64;
			Canvas.DrawColor.R=192;
			Canvas.DrawColor.G=192;
			Canvas.DrawColor.B=192;

			Canvas.SetPos(XO-Scale128/2,YO-Scale128/2);
			Canvas.DrawTile(texture'TOMATex21.Weapons.Steyr2',Scale128,Scale128,0,0,128,128);

			Canvas.DrawColor.R=255;
			Canvas.DrawColor.G=0;
			Canvas.DrawColor.B=0;

			Canvas.SetPos(XO-Scale64/2,YO-Scale64/2);
			Canvas.DrawTile(Texture'TOMATex21.Weapons.Steyr1',Scale64,Scale64,0,0,32,32);
		}
	}
	else
	{
		if (P.SZoomVal!=0)
			P.SZoomVal=0;
		if (zoom_mode>0)
			zoom_mode=0;

		P.Bob=P.OriginalBob;
		VRecoil=200.000000;
		HRecoil=0.650000;

		if (P.bHideCrosshairs)
			bOwnsCrosshair=true;
		else
			bOwnsCrosshair=false;
	}
}

simulated event RenderOverlays( canvas Canvas )
{
	MFTexture=MuzzleFlashVariations[0];

	Super.RenderOverlays(Canvas);
}

function AltFire( float Value )
{
	ClientAltFire(Value);
}

simulated function bool ClientAltFire( float Value )
{
	local s_BPlayer	P;

	if (Level.NetMode==NM_DedicatedServer)
		return false;

	PlaySound(Sound'scopezoom',SLOT_None);
	P=s_BPlayer(Owner);
	if (P!=None)
	{
		P.bSZoomStraight=true;

		zoom_mode++;
		if (zoom_mode>1)
			zoom_mode=0;
		if ((P.bSZoom==false) && (zoom_mode>0))
			P.ToggleSZoom();
		else if ((P.bSZoom==true) && (zoom_mode==0))
			P.ToggleSZoom();
	}
	return true;
}

simulated function PlayIdleAnim()
{
	if (Mesh==PickupViewMesh)
		return;
	if ((FRand()>0.98) && (AnimSequence!='idle1'))
		PlayAnim('idle1',0.15);
	else
		LoopAnim('idle',0.1);
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
    MuzzleFlashVariations=Texture'TODatas.Muzzle.Muz10'
    MaxDamage=38.000000
    clipSize=30
    clipAmmo=30
    MaxClip=5
    RoundPerMin=650
    bTracingBullets=True
    TraceFrequency=4
    price=4700
    BotAimError=0.800000
    PlayerAimError=0.400000
    VRecoil=90.000000
    HRecoil=6.000000
    bHasMultiSkins=True
    ArmsNb=4
    WeaponID=37
    WeaponClass=3
    WeaponWeight=25.000000
    aReloadWeapon=(AnimSeq=Reload,AnimRate=0.500000)
    MaxWallPiercing=25.000000
    MaxRange=9600.000000
    ProjectileSpeed=15000.000000
    FireModes(0)=FM_FullAuto
    FireModes(1)=FM_SingleFire
    bUseFireModes=True
    MuzScale=2.000000
    MuzX=620
    MuzY=442
    MuzRadius=64
    ShellCaseType="s_SWAT.TO_556SC"
    WeaponDescription="Classification: Steyr Aug"
    PickupAmmoCount=30
    bRapidFire=True
    FireOffset=(X=8,Y=-5,Z=0)
    MyDamageType=shot
    shakemag=250.000000
    shaketime=0.300000
    shakevert=6.000000
    AIRating=0.730000
    RefireRate=0.990000
    AltRefireRate=0.990000
    FireSound=Sound'TODatas.Weapons.augfire'
    SelectSound=Sound'Botpack.enforcer.Cocking'
    DeathMessage="%k's %w turned %o into a leaky piece of meat."
    NameColor=(R=255,G=255,B=0,A=0)
    bDrawMuzzleFlash=True
    MuzzleScale=0.800000
    FlashY=-0.060000
    FlashC=0.002000
    FlashLength=0.001000
    FlashS=64
    AutoSwitchPriority=37
    InventoryGroup=4
    PickupMessage="You got the Steyr Aug!"
    ItemName="Steyr Aug"
    PlayerViewOffset=(X=300.000000,Y=100.000000,Z=-210.000000)
    PlayerViewMesh=LodMesh'TOMAModels21.SteyrAug'
    PlayerViewScale=0.120000
    BobDamping=0.980000
    PickupViewMesh=LodMesh'TOMAModels21.pAug'
    ThirdPersonMesh=LodMesh'TOMAModels21.wAug'
    MuzzleFlashStyle=3
    MuzzleFlashMesh=LodMesh'TOModels.TO3rdMuzzleSA'
    MuzzleFlashScale=0.250000
    PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
    Mesh=LodMesh'TOMAModels21.pAug'
    CollisionHeight=10.000000
}
