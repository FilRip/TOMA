class TO_BulletImpact extends Effects;

var Rotator RealRotation;
var TO_BulletDecal BDl;
var byte MaxChips;
var byte NumSparks;
var bool bPlaySound;
var bool bReduceEffects;

simulated function AnimEnd ()
{
}

auto state startup
{
	simulated function Tick (float DeltaTime)
	{
	}
}

simulated function SpawnEffects ()
{
}
