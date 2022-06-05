class TOMAProjSmokeGren extends TO_ProjSmokeGren config(TOMA);

var bool bExploded;
var() float RayOfAction;
var() float TimeDurating;
var int currentcount;

simulated function BeginPlay ()
{
	SetTimer(1,False);
	Super.BeginPlay();
}

simulated event Destroyed ()
{
	local TOMAScriptedPawn m;

	foreach AllActors(class'TOMAScriptedPawn',m)
		if (m.CenterAttraction==self) m.CenterAttraction=None;
	Super.Destroyed();
	bHidden=True;
	AmbientSound=None;
}

simulated function Explosion (Vector HitLocation)
{
	bNoSmoke=True;
	bExploded=True;
	SoundVolume=128;
	SetTimer(1,False);
}

simulated function Timer ()
{
	local TOMAScriptedPawn Monstre;
	local float dist;

	currentcount++;
	if (currentcount<TimeDurating)
	{
		foreach AllActors(class'TOMAScriptedPawn',Monstre)
		{
			dist=VSize(Monstre.Location-Location);
			if (dist<RayOfAction)
			{
				Monstre.bIsAttired=True;
				Monstre.CenterAttraction=self;
				Monstre.GotoState('AttractBySmoke');
			}
		}
	} else self.Destroyed();
	Super.Timer();
}

simulated function Tick (float DeltaTime)
{
	local UT_SpriteSmokePuff B;

	if ( (Level.NetMode == NM_DedicatedServer) || bNoSmoke || bHitWater || Level.bDropDetail )
	{
		Disable('Tick');
		return;
	}

	Count += DeltaTime;
	if ( Count > FRand() * SmokeRate + SmokeRate )
	{
		B=Spawn(Class'TO_SmokeLight');
		B.RemoteRole=ROLE_None;
		Count=0;
	}
}

defaultproperties
{
	SmokeRate=1
	bNoSmoke=False
	bServerTiming=False
	ImpactPitch=0.50
	LifeSpan=34
	AmbientSound=Sound'TODatas.Weapons.SmokeGrenSound'
	Mesh=LodMesh'TOModels.wgrenadesmoke'
	SoundRadius=64
	SoundVolume=48
	RayOfAction=512
	TimeDurating=10
}
