class TOST_ExplosiveC4Timer extends TOST_ExplosiveC4;

var float rebour;

replication
{
	reliable if ( Role == 4 )
		rebour;
}

simulated function BeginPlay()
{
	if ( Level.NetMode == 1 )
		rebour = 10+(tost_c4(owner).nademode*5);

	CDSpeed = 1.0;
	SetTimer(CDSpeed,False);
	super.BeginPlay();
}

simulated function PostBeginPlay ()
{
}

simulated function Tick (float DeltaTime)
{
	rebour -= DeltaTime;
}

simulated function Timer ()
{
	if ( Role == 4 )
	{
		if ( bExploded )
		{
			Destroy();
			return;
		}
	}
	if ( Level.NetMode != 1 )
	{
		if ( rebour < 4.00 )
			PlaySound(Sound'SpeechWindowClick',SLOT_Misc,1.00,,768.00 * 3.00,1.25);
		else
			PlaySound(Sound'SpeechWindowClick',SLOT_Misc,1.00,,768.00 * 3.00,1.10);
	}
	if ( rebour < 8.0 )
	{
		if ( rebour < 0 )
			C4Explode();
		else
			CDSpeed = 0.5;
	}
	SetTimer(CDSpeed,False);
}

defaultproperties
{
	MultiSkins(0)=texture'TOSTC4WBlue'
	Mesh=LodMesh'TOSTC4E'
	C4Class="C4Pack42.TOST_C4Timer"
}
