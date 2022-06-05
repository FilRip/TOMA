class s_GrenadeAway extends Actor;

var bool bCanHitOwner;
var bool bHitWater;
var bool bBlowWhenTouch;
var bool bNoSmoke;
var bool bServerTiming;
var float Count;
var float SmokeRate;
var int NumExtraGrenades;
var float ExpTiming;
var float ImpactPitch;
var float ColTiming;
var() float speed;
var() float MaxSpeed;
var() float Damage;
var() int MomentumTransfer;
var() name MyDamageType;
var() Sound SpawnSound;
var() Sound ImpactSound;
var() Sound MiscSound;
var() float ExploWallOut;
var() Class<Decal> ExplosionDecal;
var bool bGrenadeWarning;
var float TimePassed;

final simulated function RandSpin (float spinRate)
{
}

singular simulated function Touch (Actor Other)
{
}

final simulated function ThrowGrenade ()
{
}

simulated function ZoneChange (ZoneInfo NewZone)
{
}

simulated function Timer ()
{
}

simulated function Tick (float DeltaTime)
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

simulated function Explosion (Vector HitLocation)
{
}
