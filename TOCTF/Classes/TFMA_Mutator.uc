class TFMA_Mutator extends Mutator config;

var int CurrentID;

var() config bool TimeOfDay;

var bool MA_LevelBrightness;
var bool MA_LightBrightness;
var bool MA_NightVision;
var bool MA_FlashLight;
var bool MA_GlowSticks;
var bool MA_Rain;
var bool MA_Thunder;
var bool MA_UseBattery;
var bool MA_ExtraBattery;

var float dThunder;
var MA_ThunderBolt MA_ThunderBolt;

struct Probability
{
	var byte StartingHour;
	var byte Probability_Enabled;
	var byte Probability_LevelBrightness;
	var byte Probability_LightBrightness;
	var byte Probability_NightVision;
	var byte Probability_FlashLight;
	var byte Probability_GlowSticks;
	var byte Probability_Rain;
	var byte Probability_Thunder;
	var byte Probability_UseBattery;
	var byte Probability_ExtraBattery;

	var byte Light_Intensity;
	var int Light_Hue;
	var int Light_Saturation;

	var byte Level_AmbientBrightness;

/*
	var() config byte StartingHour;
	var() config byte Probability_Enabled;
	var() config byte Probability_LevelBrightness;
	var() config byte Probability_LightBrightness;
	var() config byte Probability_NightVision;
	var() config byte Probability_FlashLight;
	var() config byte Probability_GlowSticks;
	var() config byte Probability_Rain;
	var() config byte Probability_Thunder;
	var() config byte Probability_UseBattery;
	var() config byte Probability_ExtraBattery;

	var() config byte Light_Intensity;
	var() config int Light_Hue;
	var() config int Light_Saturation;

	var() config byte Level_AmbientBrightness; */
};

var() config Probability Morning;
var() config Probability Day;
var() config Probability Evening;
var() config Probability Night;

var() config Probability Current;

function ModifyLogin (out Class<PlayerPawn> SpawnClass, out string Portal, out string Options)
{
	if ( SpawnClass == Class'TFPlayer' )
	{
		SpawnClass=Class'TFMA_Player';
	}
	if ( NextMutator != None )
	{
		NextMutator.ModifyLogin(SpawnClass,Portal,Options);
	}
}

function BeginPlay ()
{
	local ZoneInfo ZoneInfo;
	local byte Hour;
	local byte FixedHour;
	local byte i;
	local string Map;
	local Mutator Mutator;

	SaveConfig();

	Log("running.. Operation: Midnight Assault by karr and IVfluids");

	Hour=Level.Hour;

	while ( TimeOfDay )
	{
		if ( Hour == Morning.StartingHour )
		{
			Current=Morning;
			Goto Found;
		}
		if ( Hour == Day.StartingHour )
		{
			Current=Day;
			Goto Found;
		}
		if ( Hour == Evening.StartingHour )
		{
			Current=Evening;
			Goto Found;
		}
		if ( Hour == Night.StartingHour )
		{
			Current=Night;
			Goto Found;
		}
		Hour=Min(--Hour,23);

		if ( i++ > 30 )
		{
			Log("Could Not Find Valid Hour.. Using Night Mode");
			TimeOfDay=False;
			Goto Found;
		}
	}
Found:

	if ( !TimeOfDay )
	{
		Current=Night;
	}

	if ( Rand(100) >= Current.Probability_Enabled )
	{
		if ( NextMutator != None )
		{
			Mutator=Level.Game.BaseMutator;

			if ( Mutator == self )
			{
				Level.Game.BaseMutator=NextMutator;
			}
			else
			{
				while( Mutator.NextMutator != None )
				{
                                        if ( Mutator.NextMutator == self )
                                        {
                                                Mutator.NextMutator=Mutator.NextMutator.NextMutator;
                                        }

					Mutator = Mutator.NextMutator;
				}
			}
		}
		Destroy();
	}

	Map=Left(Level,instr(Level,"."));

	MA_LevelBrightness = Rand(100) < Current.Probability_LevelBrightness;
	MA_LightBrightness = Rand(100) < Current.Probability_LightBrightness;
	MA_NightVision = Rand(100) < Current.Probability_NightVision;
	MA_FlashLight = Rand(100) < Current.Probability_FlashLight;
	MA_GlowSticks = Rand(100) < Current.Probability_GlowSticks;
	MA_Rain = Rand(100) < Current.Probability_Rain && !(Map ~= "TO-Avalanche" || Map ~= "TO-GlasgowKiss" || Map ~= "TO-WinterRansom");
	MA_Thunder = Rand(100) < Current.Probability_Thunder && MA_Rain;
	MA_UseBattery = Rand(100) < Current.Probability_UseBattery;
	MA_ExtraBattery = Rand(100) < Current.Probability_ExtraBattery && MA_UseBattery;

	if ( MA_LevelBrightness )
	{
		foreach AllActors(CLass'ZoneInfo',ZoneInfo)
		{
			ZoneInfo.AmbientBrightness=Current.Level_AmbientBrightness;
			ZoneInfo.AmbientHue=Current.Light_Hue;
			ZoneInfo.AmbientSaturation=Current.Light_Saturation;
		}
	}
}

function Tick (float Delta)
{
	local Pawn Pawn;
	local TFMA_Player MA_Player;
	local TFMA_Player MA_ViewTarget;
	local bool bThunder;
	local int Count,Num;
	local Pawn ThunderVictim[32];
	local vector vThunder;

	Super.Tick(Delta);

	dThunder+=Delta;

	if ( MA_Thunder && dThunder > 15 )
	{
		bThunder=True;
		dThunder=RandRange(0,5);
		Num=Rand(5);
	}

	for( Pawn=Level.PawnList; Pawn!=None; Pawn=Pawn.NextPawn )
	{
		/*
		if( Level.Game.CurrentID > CurrentID )
		{
			if(Pawn.PlayerReplicationInfo.PlayerID == CurrentID)
			{
				NewPlayerLogin(Pawn);
				CurrentID++;
				log("OPMA debug:"@CurrentID);
			}
		}
		*/

		if ( TFMA_Player(Pawn) != None)
		{
			if (!TFMA_Player(Pawn).bMALoggedIn)
				NewPlayerLogin(Pawn);

			MA_Player=TFMA_Player(Pawn);

			if ( TFMA_Player(MA_Player.ViewTarget ) != None)
			{
				MA_ViewTarget=TFMA_Player(MA_Player.ViewTarget);
				MA_Player.bNVon=MA_ViewTarget.bNVon;
				MA_Player.BatLife=MA_ViewTarget.BatLife;
				MA_Player.bHasFL=MA_ViewTarget.FlashLight != None;
				MA_Player.GlowSticks=MA_ViewTarget.GlowSticksOwned;
				MA_Player.bHasEB=MA_ViewTarget.bOwnsEB;
				MA_Player.bOwnsNV=MA_ViewTarget.bHasNV;
			}
			else
			{
				MA_Player.bHasFL=MA_Player.FlashLight != None;
				MA_Player.bNVon=MA_Player.bNVon && MA_Player.bHasNV;
				MA_Player.GlowSticks=MA_Player.GlowSticksOwned;
				MA_Player.bHasEB=MA_Player.bOwnsEB;
				MA_Player.bOwnsNV=MA_Player.bHasNV;
			}
		}

		if ( bThunder )
		{
			if ( Count < 32 && Pawn.Health > 0 )
			{
				ThunderVictim[Count] = Pawn;
				Count++;
			}

			if ( TFMA_Player(Pawn) != None )
			{
				TFMA_Player(Pawn).MAplaySound(Num);
			}
		}
	}

	if ( bThunder && Count > 0 )
	{
		ThunderVictim[31]=ThunderVictim[Rand(Count)];
		vThunder=ThunderVictim[31].Location + 600*vect(0,0,1);

		vThunder.x+=RandRange(-300,300);
		vThunder.y+=RandRange(-300,300);

		MA_ThunderBolt=Spawn(Class'MA_ThunderBolt',self,,vThunder);

		if ( MA_ThunderBolt != None )
		{
			MA_ThunderBolt.Velocity.Z=-3000;
		}
	}
}

function NewPlayerLogin (Pawn Pawn)
{
	local TFMA_ReplicationInfo MA_ReplicationInfo;
	local TFMA_Player MA_Player;

	MA_Player=TFMA_Player(Pawn);

	if ( MA_Player == None )
	{
		return;
	}

	foreach AllActors(Class'TFMA_ReplicationInfo',MA_ReplicationInfo)
	{
		if ( MA_Player == MA_ReplicationInfo.Owner )
		{
			return;
		}
	}

	MA_ReplicationInfo=Spawn(Class'TFMA_ReplicationInfo',Pawn,,Pawn.Location);
	MA_ReplicationInfo.NoLight(Current.Level_AmbientBrightness,Current.Light_Intensity,Current.Light_Hue,Current.Light_Saturation,MA_LevelBrightness,MA_LightBrightness,MA_NightVision,MA_FlashLight,MA_GlowSticks,MA_Rain,MA_Thunder,MA_UseBattery,MA_ExtraBattery);
	MA_ReplicationInfo.SetTimer(1,true);
	MA_Player.MA_FlashLight=MA_FlashLight;
	MA_Player.MA_ExtraBattery=MA_ExtraBattery;
	MA_Player.MA_GlowSticks=MA_GlowSticks;
	MA_Player.MA_UseBattery=MA_UseBattery;
	MA_Player.MA_NightVision=MA_NightVision;

	MA_Player.bMALoggedIn= true;
}

defaultproperties
{
    Morning=(StartingHour=6, Probability_Enabled=100, Probability_LevelBrightness=100, Probability_LightBrightness=100, Probability_NightVision=0, Probability_FlashLight=100, Probability_GlowSticks=100, Probability_Rain=35, Probability_Thunder=35, Probability_UseBattery=100, Probability_ExtraBattery=0, Light_Intensity=100, Light_Hue=26, Light_Saturation=0, Level_AmbientBrightness=45)
    Day=(StartingHour=9, Probability_Enabled=0, Probability_LevelBrightness=0, Probability_LightBrightness=0, Probability_NightVision=0, Probability_FlashLight=0, Probability_GlowSticks=0, Probability_Rain=0, Probability_Thunder=0, Probability_UseBattery=0, Probability_ExtraBattery=100, Light_Intensity=0, Light_Hue=0, Light_Saturation=0, Level_AmbientBrightness=0)
    Evening=(StartingHour=19, Probability_Enabled=100, Probability_LevelBrightness=100, Probability_LightBrightness=100, Probability_NightVision=0, Probability_FlashLight=100, Probability_GlowSticks=100, Probability_Rain=35, Probability_Thunder=35, Probability_UseBattery=100, Probability_ExtraBattery=0, Light_Intensity=100, Light_Hue=26, Light_Saturation=0, Level_AmbientBrightness=45)
    Night=(StartingHour=22, Probability_Enabled=100, Probability_LevelBrightness=100, Probability_LightBrightness=100, Probability_NightVision=100, Probability_FlashLight=100, Probability_GlowSticks=100, Probability_Rain=50, Probability_Thunder=50, Probability_UseBattery=100, Probability_ExtraBattery=100, Light_Intensity=0, Light_Hue=0, Light_Saturation=0, Level_AmbientBrightness=0)
}

