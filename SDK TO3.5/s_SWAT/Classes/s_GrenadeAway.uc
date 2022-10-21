class s_GrenadeAway extends Engine.Actor;

var float speed;
var float ExpTiming;
var bool bHitWater;
var Vector RepliLocation;
var Vector RepliVelocity;
var float SmokeRate;
var bool bCanHitOwner;
var bool bNoSmoke;
var float Count;
var float ImpactPitch;
var Sound ImpactSound;
var bool OwnerChangedTeam;
var bool bNoTick;
var Vector SOldLocation;
var Vector OldVelocity;
var float TimePassed;
var float ColTiming;
var bool bServerTiming;
var bool bBlowWhenTouch;
var float MaxSpeed;
var bool bGrenadeWarning;
var int NumExtraGrenades;
var float Damage;
var int MomentumTransfer;
var name MyDamageType;
var Sound SpawnSound;
var Sound MiscSound;
var float ExploWallOut;
var Decal ExplosionDecal;

final simulated function ThrowGrenade ()
{
}

simulated function Explosion (Vector HitLocation)
{
}

simulated function Timer ()
{
}

native(19200) function RandSpin (float spinRate)
{
}

simulated function Touch (Actor Other)
{
}

simulated function ZoneChange (ZoneInfo NewZone)
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

function HitWall (Vector HitNormal, Actor Wall)
{
}


defaultproperties
{
}

