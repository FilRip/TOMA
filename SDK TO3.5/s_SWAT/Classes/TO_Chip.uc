class TO_Chip extends Engine.Effects;

var bool bHasBounced;

state Flying
{
	simulated function ZoneChange (ZoneInfo NewZone)
	{
	}

	function HitWall (Vector HitNormal, Actor Wall)
	{
	}

	simulated function Landed (Vector HitNormal)
	{
	}

	final latent simulated exec function BeginState ()
	{
	}

}


defaultproperties
{
}

