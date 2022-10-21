class TFMA_Player extends TFPlayer;

#exec obj load file=..\Textures\MATex.utx package=MATex

var bool MA_NightVision;
var bool MA_FlashLight;
var bool MA_GlowSticks;
var bool MA_UseBattery;
var bool MA_ExtraBattery;

var bool bMALoggedIn;

var bool bNVon;
var bool bHasFL;
var int BatLife;
var int BatConsumption;
var int GlowSticks;
var int GlowSticksOwned;
var bool bHasEB;
var bool bOwnsEB;
var bool bOwnsNV;

var bool bMABuymenu;
var TFMA_Light MA_Light;
var MA_RainGen MA_RainGen;
var MA_SoundBox MA_SoundBox;
var bool bDrawnLogo;
var() config bool bBatAlwaysVisible;

replication
{
	unreliable if (Role < ROLE_Authority)
		MAThrowStick;

	reliable if (Role < ROLE_Authority)
		BuyGlowsticks,BuyExtraBattery,MANightVision;

	unreliable if (bNetOwner && Role == ROLE_Authority)
		BatLife,Glowsticks;

	reliable if (bNetOwner && Role == ROLE_Authority)
		bHasFL,ForceOFF,MAplaySound,bHasEB,bNVon,bOwnsNV;
}

function PostBeginPlay()
{
	local TFMA_Mutator MA_Mutator;

	Super.PostBeginPlay();
	/*
	if ( Level.NetMode == NM_StandAlone )
	{
		foreach AllActors(Class'TFMA_Mutator',MA_Mutator)
		{
			MA_Mutator.NewPlayerLogin(self);
		}
	}*/
}

function BuyExtraBattery (bool eBattery)
{
	if ( bOwnsEB && !eBattery )
	{
		bOwnsEB=False;
		Batlife=Max(BatLife-75,0);
		AddMoney(300);
	}
	else if ( MA_ExtraBattery && !bOwnsEB && eBattery )
	{
		bOwnsEB=True;
		Batlife+=75;
		AddMoney(-300);
	}
}

function BuyGlowSticks (byte nGlowsticks)
{
	if ( MA_GlowSticks )
	{
		if ( nGlowSticks > 25 )
		{
			nGlowSticks=25;
		}
		AddMoney((GlowSticksOwned - nGlowSticks) * 25);
		GlowSticksOwned=nGlowSticks;
	}
}

function MAplaySound (byte Num)
{
	if ( MA_SoundBox != None )
	{
		MA_SoundBox.MAplaySound(Num);
	}
}

function SecondTimer()
{
	local int MaxBatLife;

	MaxBatLife=175;

	if ( MA_UseBattery )
	{
		if ( bHasEB )
		{
			MaxBatLife+=75;
		}

		if ( s_GameReplicationInfo(Level.Game.GameReplicationInfo).bPreRound )
		{
			BatLife=MaxBatLife;
		}
		else if ( !bNotPlaying )
		{
			MACalcBatConsumption();

			BatLife+=BatConsumption;

			if ( BatLife >= MaxBatLife )
			{
				BatLife=MaxBatLife;
				BatConsumption=0;
			}
		}

		if ( BatLife <= 0 && (Flashlight != None || bNVon) )
		{
			ForceOFF();
			bNVon=False;

			if ( Flashlight != None )
			{
				FlashLight.Destroy();
				FlashLight=None;
			}
		}
	}
	else
	{
		BatLife = 175;
	}
}

function MACalcBatConsumption()
{
	BatConsumption=0;

	if ( bOwnsNV && bNVon )
	{
		BatConsumption-=4;
	}
	if ( bHasFL )
	{
		BatConsumption-=3;
	}
	if ( !bNVon && !bHasFL )
	{
		BatConsumption=6;
	}
}

function ForceOFF()
{
	ClientMessage("Battery Depleted");

	if ( bNVon )
	{
		ClientPlaySound(Sound'NV_off',,True);
	}

	if ( bHasFL )
	{
		ClientPlaySound(Sound'LightSwitch',,True);
	}
}

function Died (Pawn Killer, name DamageType, Vector HitLocation)
{
	GlowSticksOwned=5;
	BatLife=175;
	bOwnsEB=False;
	Super.Died(Killer,DamageType,HitLocation);
}

exec function ToggleRain ()
{
	if ( MA_RainGen != None )
	{
		MA_RainGen.bNoRain=!MA_RainGen.bNoRain;
	}
}

exec function MABattery ()
{
	bBatAlwaysVisible=!bBatAlwaysVisible;
}

exec function GlowStick()
{
	if ( !MA_GlowSticks )
	{
		ClientMessage("Glowsticks are Disabled");
	}
	else
	{
		if ( Glowsticks == 0 )
		{
			ClientMessage("You need to buy more GlowSticks");
		}
		else
		{
			MAThrowStick();
		}
	}
}

function MAThrowStick()
{
	local MA_stick MA_stick;

	if ( MA_GlowSticks && !bNotPlaying && GlowsticksOwned > 0 && !s_GameReplicationInfo(Level.Game.GameReplicationInfo).bPreRound )
	{
		GlowsticksOwned--;
		MA_stick=Spawn(Class'MA_Stick',self,,Location + BaseEyeHeight * vect(0,0,1));
		MA_stick.Velocity=vector(ViewRotation) * 1500 + Velocity;

		if (PlayerReplicationInfo.Team == 0)
		{
			MA_stick.LightHue=255;
			MA_stick.Texture=Texture'AmmoCountJunk';
		}
	}
}

exec function s_kNightVision ()
{
	if ( !MA_NightVision )
	{
		ClientMessage("NightVision is Disabled");
	}
	else if ( !bNVon && BatLife < 40 )
	{
		ClientMessage("Not enough battery life");
	}
	else
	{
		MANightVision ();
	}
}

function MANightVision ()
{
	if ( bNVon )
	{
		bNVon=False;
		ClientPlaySound(Sound'NV_off',,True);
	}
	else if ( MA_NightVision && bHasNV && !bNVon && BatLife >= 40 )
	{
		bNVon=True;
		ClientPlaySound(Sound'NV_off',,True);
	}
}

exec function s_kFlashlight ()
{
	if ( !MA_FlashLight )
	{
		ClientMessage("Flashlight is Disabled");
	}
	else if ( !bHasFL && BatLife <= 30 )
	{
		ClientMessage("Not enough battery life");
	}
	else
	{
		Super.s_kFlashlight();
	}
}

function s_Flashlight ()
{
	if ( MA_FlashLight )
	{
		Super.s_FlashLight();
	}
}

function PostRender (Canvas Canvas)
{
	if ( !bDrawnLogo )
	{
		MA_DrawLogo(Canvas);
	}

	if ( s_HUD(myHUD) != None && s_HUD(myHUD).bToggleBuymenu )
	{
		if ( !bMABuymenu )
		{
			s_HUD(MyHud).UserInterface.TOUI_Tool_AddTab(137,Class'TFMA_BuyMenu');
			bMABuymenu=True;
		}

		s_HUD(myHUD).bToggleBuymenu=False;
		s_HUD(myHud).UserInterface.ToggleTab(137);
	}

	MA_DrawNightVision(Canvas);

	Super.PostRender(Canvas);

	MA_DrawIcons(Canvas);
}

function MA_DrawLogo (Canvas Canvas)
{
	local byte Color;
	local float Grad;

	Color=255;

	if ( Level.TimeSeconds >= 15 )
	{
		Grad=(Level.TimeSeconds - 15) * 30;
		Color-=Min(255,Grad);

		if ( Color == 0 )
		{
			bDrawnLogo=True;
		}
	}

	Canvas.Style=3;
	SetDrawColor(Canvas,Color,Color,Color);
	Canvas.SetPos(Canvas.ClipX * 0.85 - 25,140);

	Canvas.DrawTile(Texture'MALogo',Canvas.ClipX * 0.15,Canvas.ClipX * 0.075,0,0,256,128);

	Canvas.SetPos(Canvas.ClipX * 0.85 - 25,143 + Canvas.ClipX * 0.075);

	if ( s_HUD(myHUD) != None )
	{
		Canvas.Font=s_Hud(myHUD).MyFonts.GetSmallFont(Canvas.ClipX);
		Canvas.DrawText("by karr and IVfluids");
	}
}

function MA_DrawNightVision (Canvas Canvas)
{
	if ( MA_NightVision && bOwnsNV && bNVon )
	{
		Canvas.Style=3;

		SetDrawColor(Canvas,8,8,8);
		Canvas.SetPos(0.00,0.00);

		Canvas.DrawIcon(Texture'Static_A00',FMax(Canvas.ClipX,Canvas.ClipY) / 256.00);

		Canvas.Style=4;

		SetDrawColor(Canvas,255,255,255);
		Canvas.SetPos(0.00,0.00);

		Canvas.DrawPattern(Texture'MAHex',Canvas.ClipX,Canvas.ClipY,1);

		Weapon.AmbientGlow=24;
		Weapon.ScaleGlow=2.00;

		if ( MA_Light == None )
		{
			MA_Light=Spawn(Class'TFMA_Light',self,,Location);
		}
	}
	else if ( MA_Light != None )
	{
		MA_Light.Destroy();
		MA_Light=None;
	}
	else if ( Weapon != None )
	{
		Weapon.AmbientGlow=0;
		Weapon.ScaleGlow=1.00;
	}
}

function MA_DrawIcons (Canvas Canvas)
{
	local int MaxBatLife;
	local int DrawPos;
	local bool bViewing;

	if ( bHasEB )
	{
		MaxBatLife=250;
	}
	else
	{
		MaxBatLife=175;
	}

	DrawPos=186 + 45 * MaxBatLife/175;;

	bViewing=ViewTarget != self && MA_Player(ViewTarget) != None;

	if ( MA_UseBattery && (bViewing || Health > 0) && ((bNVon && bOwnsNV) || bBatAlwaysVisible || BatLife < MaxBatLife || bHasFL) )
	{
		Canvas.Style=3;

		SetDrawColor(Canvas,255,255,255);

		Canvas.SetPos(Canvas.ClipX - 55,Canvas.ClipY - 139 - (25 + 45 * MaxBatLife/175) * BatLife/MaxBatLife);
		Canvas.DrawTile(Texture'MAPowerMeter',16,(25 + 45 * MaxBatLife/175) * BatLife/MaxBatLife,127 * BatLife/MaxBatLife,0,1,1);

		Canvas.SetPos(Canvas.ClipX - 57,Canvas.ClipY -168 - 45 * MaxBatLife/175);
		Canvas.DrawTile(Texture'MABattery',20,4,0,0,20,4);
		Canvas.SetPos(Canvas.ClipX - 57,Canvas.ClipY -164 - 45 * MaxBatLife/175);
		Canvas.DrawTile(Texture'MABattery',20,45 * MaxBatLife/175,0,4,20,1);
		Canvas.SetPos(Canvas.ClipX - 57,Canvas.ClipY - 164);
		Canvas.DrawTile(Texture'MABattery',20,27,0,5,20,27);
	}

	if ( Health > 0 || bViewing )
	{
		Canvas.Style=2;

		if ( MA_GlowSticks )
		{
			Drawpos-=20;
			Canvas.Setpos(Canvas.ClipX - 31,Canvas.ClipY - DrawPos);

			if ( GlowSticks > 0 )
			{
				SetTeamColor(Canvas);
			}
			else
			{
				SetDrawColor(Canvas,255,255,255);
			}

			Canvas.DrawIcon(Texture'MAGlowStickIcon',1);
			Canvas.Setpos(Canvas.ClipX - 31,Canvas.ClipY - DrawPos - 3);
			Canvas.Font=Font(DynamicLoadObject("LadderFonts.UTLadder8",Class'Font'));

			Canvas.DrawText(string(GlowSticks));
		}

		if ( MA_FlashLight )
		{
			Drawpos-=20;
			Canvas.Setpos(Canvas.ClipX - 31,Canvas.ClipY - DrawPos);

			if ( bHasFL )
			{
				SetTeamColor(Canvas);
			}
			else
			{
				SetDrawColor(Canvas,255,255,255);
			}
			Canvas.DrawIcon(Texture'MAFlashLightIcon',1);
		}

		if ( MA_NightVision && bOwnsNV )
		{
			Drawpos-=20;
			Canvas.Setpos(Canvas.ClipX - 31,Canvas.ClipY - DrawPos);

			if ( bNVon )
			{
				SetTeamColor(Canvas);
			}
			else
			{
				SetDrawColor(Canvas,255,255,255);
			}
			Canvas.DrawIcon(Texture'MANVIcon',1);
		}
	}
}

function SetTeamColor (Canvas Canvas)
{
	if ( PlayerReplicationInfo.Team == 0 )
	{
		SetDrawColor(Canvas,255,0,0);
	}
	else if ( PlayerReplicationInfo.Team == 1 )
	{
		SetDrawColor(Canvas,40,80,200);
	}
}

function SetDrawColor (Canvas Canvas, byte R, byte G, byte B)
{
	Canvas.DrawColor.R=R;
	Canvas.DrawColor.G=G;
	Canvas.DrawColor.B=B;
}

function RoundEnded()
{
	GlowSticksOwned=Max(5,GlowSticksOwned);
	NewRound();

	Super.RoundEnded();
}

simulated function ClientRoundEnded ()
{
	NewRound();
	Super.ClientRoundEnded();
}

function NewRound ()
{
	local MA_stick MA_stick;

	foreach AllActors(Class'MA_Stick',MA_Stick)
	{
		MA_stick.Destroy();
	}
}

defaultproperties
{
    BatLife=175
    GlowSticksOwned=5
}

