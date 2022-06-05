class TO_Chip extends Effects;

var bool bHasBounced;

auto state Flying
{
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
