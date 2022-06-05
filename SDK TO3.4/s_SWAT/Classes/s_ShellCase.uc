class s_ShellCase extends Projectile;

var bool bHasBounced;
var int numBounces;
var Sound HitSound;

simulated function PostBeginPlay ()
{
}

simulated function HitWall (Vector HitNormal, Actor Wall)
{
}

simulated function Landed (Vector HitNormal)
{
}

final function Eject (Vector Vel)
{
}
