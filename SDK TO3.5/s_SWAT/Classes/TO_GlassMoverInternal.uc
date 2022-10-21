class TO_GlassMoverInternal extends Engine.Actor;

var float Width;
var float Height;
var float FragmentArea;
var Sound BreakingSound;
var Rotator RealRotation;
var Vector lastMomentum;
var Vector lastHitLocation;
var Texture GlassTexture;

state startup
{
	simulated event Tick (float DeltaTime)
	{
	}

}

function DoSpawning ()
{
}


defaultproperties
{
}

