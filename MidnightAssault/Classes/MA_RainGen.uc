class MA_RainGen extends Actor;

var bool bNoRain;

simulated event Spawned ()
{	
	SetTimer(0.04,True);
}

simulated function Timer ()
{
	local int i;

	if ( !bNoRain )
	{
		if (PlayerPawn(Owner).ViewTarget == None )
		{
			SetLocation(Owner.Location);
		}
		else SetLocation(PlayerPawn(Owner).ViewTarget.Location);
	
		while ( i < 20 )
		{
			SpawnRain();
			i++;
		}
	}
}

simulated function SpawnRain ()
{
	local s_raindrop D;
	local Vector Start;

	Start=Location + 600 * vect(0,0,1);
	Start.X += (FRand() - 0.50) * 4000;
	Start.Y += (FRand() - 0.50) * 4000;

	D=Spawn(Class's_raindropSprite',,,Start);

	if ( D != None )
	{
		D.Speed=6000;
		D.Velocity.Z=-600;
		D.DrawScale=(1.00 + FRand()) * 0.25;
	}
}

defaultproperties
{
    bHidden=True
}
