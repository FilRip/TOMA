class TO_ExplosionChain extends ExplosionChain;

var() int RespawnTime;

state Exploding
{
	ignores  TakeDamage;
	
	function Timer ()
	{
	}
	
	function BeginState ()
	{
	}
}

state Waiting
{
	ignores  TakeDamage;
	
	function Timer ()
	{
	}
	
	function BeginState ()
	{
	}
	
}
