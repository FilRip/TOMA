class TO_20mmHE extends RocketMk2;

var bool bSmoke;

simulated function PostBeginPlay ()
{
}

simulated function Timer ()
{
}

singular simulated function Touch (Actor Other)
{
}

auto state Flying
{
	simulated function ProcessTouch (Actor Other, Vector HitLocation)
	{
	}
	
	simulated function Explode (Vector HitLocation, Vector HitNormal)
	{
	}
	
	function BeginState ()
	{
	}
	
}
