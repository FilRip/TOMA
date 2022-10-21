class s_raindrop extends Engine.Projectile;


state FallingState
{
	simulated function Touch (Actor Other)
	{
	}

	simulated function ZoneChange (ZoneInfo NewZone)
	{
	}

	simulated function HitWall (Vector HitNormal, Actor Wall)
	{
	}

	simulated function Landed (Vector HitNormal)
	{
	}

	simulated function BeginState ()
	{
	}

}


defaultproperties
{
}

