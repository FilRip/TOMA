class TO_ExplosionChain extends UnrealShare.ExplosionChain;

var int RespawnTime;

function FixedHurtRadius (float DamageAmount, float DamageRadius, name DamageName, float Momentum, Vector HitLocation)
{
}

state Exploding
{
	function TakeDamage (int NDamage, Pawn instigatedBy, Vector HitLocation, Vector Momentum, name DamageType)
	{
	}

	function Timer ()
	{
	}

	function BeginState ()
	{
	}

}

function bool CanHitTarget (Actor A, Vector Start)
{
}

state Waiting
{
	function TakeDamage (int NDamage, Pawn instigatedBy, Vector HitLocation, Vector Momentum, name DamageType)
	{
	}

	function Timer ()
	{
	}

	function BeginState ()
	{
	}

}


defaultproperties
{
}

