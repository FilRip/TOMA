class TO_GlassMoverInternal extends Actor;

var float Width;
var float Height;
var Texture GlassTexture;
var float FragmentArea;
var Vector lastHitLocation;
var Vector lastMomentum;
var Rotator RealRotation;
var Sound BreakingSound;

auto state startup
{
	simulated event Tick (float DeltaTime)
	{
	}
}

simulated function DoSpawning ()
{
}
