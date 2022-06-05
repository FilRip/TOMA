class s_ThrowingKnife extends Projectile;

var bool bCanHitOwner;
var bool bHitWater;
var Actor LastHit;
var Pawn Owner;
var int hitCount;

simulated function Touch (Actor Other)
{
}

simulated function PostBeginPlay ()
{
}

simulated function ZoneChange (ZoneInfo NewZone)
{
}

simulated function Landed (Vector HitNormal)
{
}

simulated function ProcessTouch (Actor Other, Vector HitLocation)
{
}

simulated function HitWall (Vector HitNormal, Actor Wall)
{
}

simulated function Timer ()
{
}
