class TOST_Lazer extends Projectile;

var TOST_Lazer Lazer;
var int Position;
var Vector FireOffset;
var float LazerSize;

simulated function Destroyed ()
{
	Super.Destroyed();
	if ( Lazer != None )
	{
		Lazer.Destroy();
	}
}

simulated function flick()
{
	if ( lazer != none )
		lazer.flick();
    if ( DrawType == DT_Mesh )
    {
	    DrawType = DT_None;
	    AmbientSound = none;
	}
    else
	{
		DrawType = DT_Mesh;
		AmbientSound = Sound'UnrealShare.flies.flybuzz';
	}
}

simulated function untouch(Actor toucher)
{
	if ( tost_explosivec4lazer(owner).ReadyToExplode )
		tost_explosivec4lazer(owner).C4GonnaExplode();
}

simulated function CheckLazer (Vector X)
{
	local Actor HitActor;
	local Vector HitLocation, HitNormal;

	if ( position >= 18 )
	{
		TOST_ExplosiveC4Lazer(owner).CantBePlanted();
		return;
	}

	HitActor=Trace(HitLocation,HitNormal,Location + LazerSize * X,Location,True);

	if ( Lazer == None && HitActor != Level)
	{
		Lazer=Spawn(Class'TOST_Lazer',owner,,Location + LazerSize * X);
		if ( lazer != none )
		{
			Lazer.Position=Position + 1;
			Lazer.checkLazer(X);
		}
	}
}

defaultproperties
{
    FireOffset=(X=0.00, Y=0.00, Z=0.00)
    LazerSize=39
    MaxSpeed=0.00
    MomentumTransfer=8500
    bNetTemporary=False
    Physics=0
    RemoteRole=0
    DrawType=DT_Mesh
    Mesh=LodMesh'Lazer'
    DrawScale=0.2
    MultiSkins(1)=Texture'C4Pack42.Pack.Beam'
    Style=STY_Translucent
	CollisionRadius=0.1
	CollisionHeight=0.1
	AmbientSound=Sound'UnrealShare.flies.flybuzz'
	soundvolume=30
	Soundpitch=45
	soundradius=16
}

