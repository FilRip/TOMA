//=============================================================================
// Bloblet.
// Must tag with same tag as a Blob
//=============================================================================
class TOMABloblet extends TOMAFlockPawn;

var TOMAParentBlob parentBlob;
var vector	Orientation;
var float	LastParentTime;

function PostBeginPlay()
{
	Super.PostBeginPlay();
	DrawScale = 0.8 + 0.4 * FRand();
}

function Died(pawn Killer, name damageType, vector HitLocation)
{
	PlaySound(Die);
	SetCollision(false,false, false);
	parentBlob.shrink(self);
	GotoState('DiedState');
}

function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, name damageType)
{
	local rotator newRotation;
	local GreenSmokePuff f;

	if (damageType == 'corroded')
		return;
	PlaySound(HitSound1);
	f = spawn(class'GreenSmokePuff',,,Location - Normal(Momentum)*12); 
	f.DrawScale = FClamp(0.1 * Damage, 1.0, 4.0);
	SetPhysics(PHYS_Falling);
	newRotation = Rotation;
	newRotation.Roll = 0;
	setRotation(newRotation);
	Super.TakeDamage(Damage,instigatedBy,hitLocation,momentum,damageType);	
}

function BaseChange()
{
}

function wakeup()
{
	GotoState('Active');
}

function PreSetMovement()
{
	bCanWalk = true;
	bCanSwim = true;
	bCanFly = false;
	MinHitWall = -0.7;
}


function Timer()
{
	local int i;
	local bool bHasEnemy;

	bHasEnemy = ((parentBlob != None) && (parentBlob.Enemy != None));
	if ( bHasEnemy && (VSize(Location - parentBlob.Enemy.Location) < parentBlob.Enemy.CollisionHeight + CollisionRadius) )
	{
		parentBlob.Enemy.TakeDamage(18 * FRand(), parentBlob, location, vect(0,0,0), 'corroded');
		PlaySound(sound'BlobHit');
	}
	
	if ( Physics == PHYS_Spider )
	{
		if ( FRand() < 0.33 )
			PlaySound(sound'BlobGoop1');
		else if ( FRand() < 0.5 )
			PlaySound(sound'BlobGoop2');
		else
			PlaySound(sound'BlobGoop3');
	}
	if ( bHasEnemy )
		SetTimer(0.5 + 0.5 * FRand(), false);
	else
		SetTimer(1 + FRand(), false);	
}
	 
function PlayGlob(float rate)
{
	if (FRand() < 0.75)
		LoopAnim('Glob1', rate * 0.7 * FRand());
	else
		LoopAnim('Glob3', rate * (0.5 + 0.5 * FRand()));
}

auto state asleep
{
	function Landed(vector HitNormal)
	{
		if ( !FootRegion.Zone.bWaterZone )
			PlaySound(Land);
		PlayAnim('Splat');
		SetPhysics(PHYS_None);
	}	
	
Begin:
	SetTimer(2 * FRand(), false);
	if (Physics != PHYS_Falling)
		SetPhysics(PHYS_None);
	PlayGlob(0.3);
}

state active
{
	function AnimEnd()
	{
		playGlob(1);
	}

	function Landed(vector HitNormal)
	{
		SetRotation(Rot(0,0,0));
		if ( Velocity.Z > 200 )
		{
			PlayAnim('Splat');
			PlaySound(Land);
		}
		SetPhysics(PHYS_Spider);
	}

begin:
	SetTimer(FRand(), false);
	SetPhysics(PHYS_Spider);
	PlayGlob(1);
	LastParentTime = Level.TimeSeconds;

wander:
	if (parentBlob == None)
		GotoState('DiedState');
	if ( VSize(Location - parentBlob.Location) > 120 )
	{
		if ( LastParentTime - Level.TimeSeconds > 20 )
			GotoState('DiedState');
		else	
			MoveToward(parentBlob);
	}
	else 
	{
		LastParentTime = Level.TimeSeconds;
		MoveTo(ParentBlob.Location);
	}
	Sleep(0.1);
	Goto('Wander');
}


state fired
{
	function HitWall(vector HitNormal, actor Wall)
	{
		PlaySound(Land);
		GotoState('Active');
	}

	function Landed(vector HitNormal)
	{
		if ( !FootRegion.Zone.bWaterZone )
			PlaySound(Land);
		GotoState('Active');
	}
}

state DiedState
{
	ignores TakeDamage;

	function Landed(vector HitNormal)
	{
		if ( !FootRegion.Zone.bWaterZone )
			PlaySound(Land);
		SetRotation(Rot(0,0,0));
		PlayAnim('Splat');
		SetPhysics(PHYS_None);
	}	

	function Tick(float DeltaTime)
	{
		DrawScale = DrawScale - 0.06 * DeltaTime;
		if (DrawScale < 0.1)
			Destroy();
	}

Begin:
	SetPhysics(PHYS_Falling);
	PlayAnim('Splat');
	FinishAnim();
	TweenAnim('Flat', 0.2);
}	

	

defaultproperties
{
     GroundSpeed=450
     AccelRate=1200
     JumpZ=-1
     SightRadius=3000
     Health=120
     ReducedDamageType=exploded
     ReducedDamagePct=0.250000
     HitSound1=Sound'UnrealI.Blob.BlobInjur'
     Land=Sound'UnrealShare.BioRifle.GelHit'
     Die=Sound'UnrealI.Blob.BlobDeath'
     Tag=blob1
     DrawType=DT_Mesh
     Texture=Texture'UnrealI.Skins.JBlob1'
     Mesh=LodMesh'UnrealI.MiniBlob'
     bMeshEnviroMap=True
     CollisionRadius=6
     CollisionHeight=6
     bBlockActors=False
     bBlockPlayers=False
     Mass=40
     RotationRate=(Pitch=0,Yaw=0,Roll=0)
	MoneyDroped=0
}
