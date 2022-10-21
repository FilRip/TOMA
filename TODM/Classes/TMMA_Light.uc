class TMMA_Light extends Light;

var float Light;

simulated event Tick(float Delta)
{
	local Vector HitLocation;
	local TMMA_Player MA_Player;

	MA_Player=TMMA_Player(Owner);

	if ( MA_Player.ViewTarget == None )
	{
		HitLocation=MA_Player.Location;
	}
	else
	{
		HitLocation=MA_Player.ViewTarget.Location;
	}

	HitLocation.Z+=MA_Player.BaseEyeHeight;
	SetLocation(HitLocation);

	MA_Player.MACalcBatConsumption();

	if ( MA_Player.BatLife <= 3 * abs(MA_Player.BatConsumption) && MA_Player.BatConsumption < 0 )
	{
		Light-=73 * Delta;
		LightBrightness=Max(0,Light);
	}
	else if ( MA_Player.BatConsumption >= 0 || MA_Player.BatLife > 3 * abs(MA_Player.BatConsumption) )
	{
		Light=220;
		LightBrightness=220;
	}
}

defaultproperties
{
    Light=220.00
    bStatic=False
    bNoDelete=False
    bOnlyOwnerSee=True
    bMovable=True
    LightBrightness=220
    LightHue=32
    LightSaturation=142
    LightRadius=70
    LightPeriod=0
}
