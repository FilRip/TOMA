class TO_ProjectileSpawner extends Effects;

var() Class<Projectile> ProjectileType;
var() float ProjectileDamage;
var() float ProjectileMomentumTransfer;
var() float ProjectileSpeed;
var() bool bDeviate;
var() int Deviation;
var() Sound FireSound;
var() bool bInfiniteProjectiles;
var() int NumProjectiles;
var() bool bAutomaticFire;
var() int RateOfFire;
var int remainingProjectiles;

function BeginPlay ()
{
}

function Timer ()
{
}

function Trigger (Actor Other, Pawn EventInstigator)
{
}

function LaunchProjectile ()
{
}
