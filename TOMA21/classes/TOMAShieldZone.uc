class TOMAShieldZone extends Actor;

var int TimeDurating;
var int currentcount;

function PreBeginPlay()
{
	Super.PreBeginPlay();
	currentcount=0;
	SetTimer(1,True);
}

function Timer()
{
	currentcount++;
	if (currentcount==TimeDurating-4)
	{
		DrawScale=4;
		SetCollisionSize(205,205);
	}
	if (currentcount==TimeDurating-3)
	{
		DrawScale=3;
		SetCollisionSize(154,154);
	}
	if (currentcount==TimeDurating-2)
	{
		DrawScale=2;
		SetCollisionSize(103,103);
	}
	if (currentcount==TimeDurating-1)
	{
		DrawScale=1;
		SetCollisionSize(52,52);
	}
	if (currentcount>=TimeDurating)
		Self.Destroy();
}

function Touch(Actor Other)
{
	If (Other.IsA('Projectile'))
		if (!Other.IsA('s_Projectile'))
            Other.Destroy();
        else
        {
            if (s_Projectile(Other).WeaponOwner!=None)
                if (s_Projectile(Other).WeaponOwner.Owner!=None)
                {
                    if (s_Projectile(Other).WeaponOwner.Owner.IsA('TOMAScriptedPawn')) Other.Destroy();
                } else Other.Destroy();
        }
	Super.Touch(Other);
}

function UnTouch(Actor Other)
{
	If (Other.IsA('Projectile'))
		if (!Other.IsA('s_Projectile')) Other.Destroy();
	Super.UnTouch(Other);
}

defaultproperties
{
	CollisionHeight=256
	CollisionRadius=256
	bCollideActors=True
	bBlockActors=True
	bBlockPlayers=False
	Mesh=LodMesh'TOMAModels21.EnergyShieldM'
	DrawType=DT_Mesh
	bHidden=false
	TimeDurating=25
	DrawScale=5
	bProjTarget=false
	Style=STY_Translucent
	Physics=PHYS_Rotating
	bStatic=False
	bFixedRotationDir=True
	RotationRate=(Roll=1500)
	DesiredRotation=(Roll=500)
}

