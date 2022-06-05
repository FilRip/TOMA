class s_Projectile extends Projectile;

var float MaxDamage;
var float MaxWallPiercing;
var float OldMaxWall;
var float MaxRange;
var float HP;
var float SmokeDS;
var Vector OriginalLocation;
var float ProjectileAge;
var Vector AgeLocation;
var Actor LastHitActor;
var bool bReduceSFX;
var Class<TO_BulletImpact> BulletImpactClass;
var S_Weapon WeaponOwner;

simulated function PostBeginPlay ()
{
}

singular simulated function Touch (Actor Other)
{
}

auto state Flying
{
	simulated function ZoneChange (ZoneInfo NewZone)
	{
	}
	
	simulated function ProcessTouch (Actor Other, Vector HitLocation)
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
