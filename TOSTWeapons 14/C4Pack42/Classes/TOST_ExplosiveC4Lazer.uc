class TOST_ExplosiveC4Lazer extends TOST_ExplosiveC4;

var TOST_Lazer Lazer;
var int CheckTime;
var bool ReadyToExplode, placing, bSucceed;

simulated function BeginPlay()
{
	placing = true;
	bSucceed = true;
	super.BeginPlay();
}

simulated function PostBeginPlay()
{
	local Vector X;
	local Vector Y;
	local Vector Z;

	GetAxes(Rotation,X,Y,Z);
	Lazer = TOST_Lazer(ProjectileFire(Class'TOST_Lazer',Y,Z));
	if ( Lazer != none )
	{
		Lazer.Position=1;
		Lazer.checkLazer(X);
	}
	setTimer(0.1,true);
}

function Projectile ProjectileFire (Class<Projectile> ProjClass, vector Y, vector Z)
{
	return Spawn(ProjClass,self,,Location+(Y*1.9)+(Z*11.1),rotation+rot(16400,0,0));
}

simulated function Destroyed()
{
	Super.Destroyed();
	if ( Lazer != None )
	{
		Lazer.Destroy();
	}
}

function CantBePlanted()
{
	bSucceed = false;
	if ( Lazer != None )
	{
		Lazer.Destroy();
	}
}

simulated function C4GonnaExplode()
{
	if (IsInState('GonnaExplode'))
		return;
	if ( ReadyToExplode )
	{
		GotoState('GonnaExplode');
	}
}

function timer()
{
	if ( Role == 4 )
	{
		if ( bExploded )
		{
			Destroy();
			return;
		}
	}
	if ( Placing )
	{
		checkTime++;
		if ( checkTime >= 47 )
		{
			placing = false;
			ReadyToExplode=true;
			setTimer(13.0,false);
		}
		else
		{
			if ( (checkTime < 32) && (checkTime%4 == 0) )// ceci ne s entend pas et je ne c pas pq
				PlaySound(Sound'SpeechWindowClick',SLOT_Misc,1.00,,768.00 * 3.00,1.10);
			else if (checkTime == 36)
			{
				if ( bSucceed )
					PlaySound(Sound'def_fail',SLOT_Interact,4.00);
				else
					PlaySound(Sound'def_success',SLOT_Interact,4.00);
			}
	 		if ( lazer != none )
	 			lazer.flick();
		}
	}
	else
	{
		if ( ReadyToExplode )
		{
			ReadyToExplode = false;
			setTimer(2.0,false);
		}
		else
		{
			ReadyToExplode = true;
			setTimer(13.0,false);
		}
 		if ( lazer != none )
 			lazer.flick();
	}
}

state GonnaExplode
{
	simulated function timer()
	{
		C4Explode();
	}
	Begin:
		setTimer(1.0,false);
		if ( lazer != none )
			lazer.flick();
		PlaySound(Sound'def_fail',SLOT_Interact,4.00);
}

defaultproperties
{
	MultiSkins(0)=texture'TOSTC4WRed'
	Mesh=LodMesh'TOSTC4E'
	C4Class="C4Pack42.TOST_C4Lazer"
}
