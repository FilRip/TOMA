class AssaultMA_ReplicationInfo extends ReplicationInfo;

var int l;

replication
{
	reliable if (Role == Role_Authority)
		NoLight;
}

simulated function Timer()
{
	local Pawn Pawn;

	if( Role == ROLE_Authority )
	{
		if ( Owner != None )
		{
			AssaultMA_Player(Owner).SecondTimer();
		}
		else
		{
			Destroy();
		}
	}

	if ( Role == ROLE_SimulatedProxy || Level.NetMode == NM_StandAlone )
	{
		if ( l < 20 )
		{
			l++;
			if ( l % 5 == 0 )
			{
				PlayerPawn(Owner).ConsoleCommand("flush");
			}
		}

		foreach Owner.AllActors(CLass'Pawn',Pawn)
		{
			Pawn.AmbientGlow=0;
			Pawn.LightBrightness=0;
			Pawn.LightRadius=0;
		}
	}
}

simulated function NoLight (byte Level_AmbientBrightness, byte Light_Intensity, int Light_Hue, int Light_Saturation, bool MA_LevelBrightness, bool MA_LightBrightness, bool MA_NightVision, bool MA_FlashLight, bool MA_GlowSticks, bool MA_Rain, bool MA_Thunder, bool MA_UseBattery, bool MA_ExtraBattery)
{
	local Light Light;
	local ZoneInfo ZoneInfo;
	local int i;
	local AssaultMA_Player MA_Player;
	local float Intensity;
	local SkyZoneInfo SkyZoneInfo;

	// debug
	//log("OPMA debug:"@Level_AmbientBrightness@Light_Intensity@Light_Hue@Light_Saturation@MA_LevelBrightness@MA_LightBrightness@MA_NightVision@MA_FlashLight@MA_GlowSticks@MA_Rain@MA_Thunder@MA_UseBattery@MA_ExtraBattery);

	MA_Player=AssaultMA_Player(Owner);

	Intensity=float(Light_Intensity) * 0.01;

	foreach Owner.AllActors(CLass'ZoneInfo',ZoneInfo)
	{
		if ( MA_LevelBrightness )
		{
			ZoneInfo.AmbientBrightness=Level_AmbientBrightness;
			if ( Light_Hue > 0 )ZoneInfo.AmbientHue=Min(Light_Hue,255);
			if ( Light_Saturation > 0 )ZoneInfo.AmbientSaturation=Min(Light_Saturation,255);
		}

		if ( Zoneinfo.iSA('SkyZoneInfo') && (MA_LevelBrightness || MA_LightBrightness) )
		{
			Owner.Spawn(class'MA_SkyZone',Owner,,Zoneinfo.Location);

			SkyZoneInfo=SkyZoneInfo(ZoneInfo);

			ZoneInfo.AmbientBrightness=Min(2 * Level_AmbientBrightness,255);

			while ( i < 200 && Light_Intensity <= 25 )
			{
				Owner.Spawn(class'MA_Star',Owner,,RandRange(20,22.4) * VRand() + Zoneinfo.Location);
				i++;
			}
		}
	}

	if ( MA_LightBrightness )
	{
		foreach Owner.AllActors(Class'Light',Light)
		{
			Light.LightBrightness=float(Light.LightBrightness) * Intensity;
			if ( Light_Hue > 0 )Light.LightHue=Min(Light_Hue,255);
			if ( Light_Saturation > 0 )Light.LightSaturation=Min(Light_Saturation,255);

			if ( Light_Intensity == 0 || Light.Region.Zone == SkyZoneInfo )
			{
				Light.LightRadius=0;
				Light.bCorona=False;
				Light.LightType=LT_None;
			}
		}
	}

	l=3;
	MA_Player.ConsoleCommand("flush");

	MA_Player.MA_SoundBox=Owner.Spawn(Class'MA_SoundBox',Owner,,Owner.Location);

	if( MA_Rain )
	{
		MA_Player.MA_SoundBox.SetAmbientSound(0);
		MA_Player.MA_RainGen=Owner.Spawn(Class'MA_RainGen',Owner,,Owner.Location);
	}
	else if ( (MA_LevelBrightness || MA_LightBrightness) && Light_Intensity <= 25 )
	{
		MA_Player.MA_SoundBox.SetAmbientSound(1);
	}

	MA_Player.MA_NightVision = MA_NightVision;
	MA_Player.MA_FlashLight = MA_FlashLight;
	MA_Player.MA_GlowSticks = MA_GlowSticks;
	MA_Player.MA_UseBattery = MA_UseBattery;
	MA_Player.MA_ExtraBattery = MA_ExtraBattery;

	SetTimer(1,true);
}

defaultproperties
{
    bAlwaysRelevant=False
    RemoteRole=2
    NetPriority=3.00
}
