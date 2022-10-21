class MA_Stick extends Actor;

var float TimeToLive;
var Rotator rRot;

replication
{
	reliable if (Role == ROLE_Authority)
		TimeToLive;
}

simulated function Tick (float Delta)
{
	TimeToLive-=Delta;

	if ( vsize(Velocity) > 8 && !Region.Zone.bWaterZone )
	{
		rRot.Pitch+=98304*Delta;
		rRot.Yaw-=49152*Delta;
	}
	else
	{
		rRot.Pitch=16384;
	}

	SetRotation(rRot);

	if ( TimeToLive < 30 )
	{
		LightBrightness=255 * TimeToLive/30 ;
	}
	
	if ( TimeToLive < 0 )Destroy();
}

simulated function HitWall (Vector HitNormal, Actor HitWall)
{
	Velocity=0.13 * MirrorVectorByNormal(Velocity,HitNormal);
}

defaultproperties
{
    TimeToLive=90.00
    bNetTemporary=True
    Physics=2
    RemoteRole=2
    DrawType=2
    Texture=Texture'Botpack.Icons.I_BlueBox'
    Mesh=LodMesh'Botpack.tubelight2M'
    DrawScale=0.05
    AmbientGlow=255
    bUnlit=True
    bMeshEnviroMap=True
    CollisionRadius=1.00
    CollisionHeight=5.10
    bCollideWorld=True
    LightType=1
    LightEffect=3
    LightBrightness=255
    LightHue=170
    LightSaturation=127
    LightRadius=10
    bBounce=True
}
