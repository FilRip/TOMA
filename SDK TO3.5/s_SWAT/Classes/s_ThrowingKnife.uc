class s_ThrowingKnife extends Engine.Projectile;

var bool bCanHitOwner;
var bool bHitWater;
var Actor LastHit;
var Pawn Owner;
var int hitCount;

simulated function Touch (Actor Other)
{
}

function PostBeginPlay ()
{
}

simulated function ZoneChange (ZoneInfo NewZone)
{
}

simulated function Landed (Vector HitNormal)
{
}

function ProcessTouch (Actor Other, Vector HitLocation)
{
}

function HitWall (Vector HitNormal, Actor Wall)
{
}

simulated function Timer ()
{
}


defaultproperties
{
}

