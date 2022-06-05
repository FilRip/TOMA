class s_raindrop extends Projectile;

auto state FallingState
{
	simulated function Landed (Vector HitNormal)
	{
	}
	
	simulated function HitWall (Vector HitNormal, Actor Wall)
	{
	}
	
	simulated function ZoneChange (ZoneInfo NewZone)
	{
	}
	
	singular simulated function Touch (Actor Other)
	{
	}
	
	simulated function BeginState ()
	{
	}
	
}
