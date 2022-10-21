class s_Projectile extends Engine.Projectile;

var float MaxWallPiercing;
var float MaxDamage;
var float MaxRange;
var S_Weapon WeaponOwner;
var float SmokeDS;
var float HP;
var Actor LastHitActor;
var Vector OriginalLocation;
var float OldMaxWall;
var bool bReduceSFX;
var TO_BulletImpact BulletImpactClass;
var Vector AgeLocation;
var float ProjectileAge;

native(7748) latent event delegate noexport PostBeginPlay ()
{
}

simulated function Touch (Actor Other)
{
}

state Flying
{
	simulated function ZoneChange (ZoneInfo NewZone)
	{
	}

	function ProcessTouch (Actor Other, Vector HitLocation)
	{
	}

	simulated function HitWall (Vector HitNormal, Actor Wall)
	{
	}

}

simulated function Explode (Vector HitLocation, Vector HitNormal)
{
}

simulated event Destroyed ()
{
}


defaultproperties
{
}

