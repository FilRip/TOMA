//=============================================================================
// Cow.
//=============================================================================
class TOMACow extends TOMAPupae;

var bool bForage;
var() bool bHasBaby;
var() bool bStayClose;
var() float WanderRadius;
var vector StartLocation;
var TOMABabyCow baby;
var Pawn ScaryGuy;
var(Sounds) sound shake;
var(Sounds) sound swish;
var(Sounds) sound footstep;
var float VoicePitch;

function eAttitude AttitudeWithFear()
{
	return ATTITUDE_Fear;
}

function JumpOffPawn()
{
	Super(TOMAScriptedPawn).JumpOffPawn();
}

function PostBeginPlay()
{
	VoicePitch = 0.9 + 0.2 * FRand();
	if ( TOMABabyCow(self) != None )
		VoicePitch *= 1.4;
	if (bHasBaby) //add baby
	{
		Destination = Location;
		baby = Spawn(class 'TOMABabyCow',,, Location + vector(Rotation) * 1.5 * CollisionRadius);
		baby.mom = self;
	}
	Super.PostBeginPlay();
}

function Step()
{
	PlaySound(Footstep, SLOT_Interact, 0.012 * Mass,, 1000);
}

function PlayWaiting()
	{
	local float decision;
	local float animspeed;
	animspeed = 0.4 + 0.4 * FRand();
	decision = FRand();
	if (!bool(NextAnim)) //pick first waiting animation
		NextAnim = 'Breath';

	if (decision < 0.3)
		NextAnim = 'Breath';
	else if (decision < 0.6)
	{
		animspeed *= 0.6;
		NextAnim = 'Chew';
	}
	else if (decision < 0.73)
	{
		NextAnim = 'Root';
	}
	else if (decision < 0.8)
	{
		PlaySound(Roam, SLOT_Talk, 0.02 * Mass,,,VoicePitch);
		NextAnim = 'Poop';
	}
	else if (decision < 0.9)
	{
		PlaySound(Shake, SLOT_Talk, 0.0083 * Mass);
		NextAnim = 'Shake';
	}
	else
	{
		PlaySound(Swish, SLOT_Talk, 0.0083 * Mass);
		NextAnim = 'Swish';
	}
	LoopAnim(NextAnim, animspeed);
	}

function PlayPatrolStop()
{
	PlayWaiting();
}

function PlayWaitingAmbush()
{
	PlayWaiting();
}

function TweenToFighter(float tweentime)
{
	TweenAnim('Breath', tweentime);
}

function TweenToRunning(float tweentime)
{
	if (AnimSequence != 'Run' || !bAnimLoop)
		TweenAnim('Run', tweentime);
}

function TweenToWalking(float tweentime)
{
	TweenAnim('Walk', tweentime);
}

function TweenToWaiting(float tweentime)
{
	TweenAnim('Breath', tweentime);
}

function TweenToPatrolStop(float tweentime)
{
	TweenAnim('Breath', tweentime);
}

function PlayRunning()
{
	LoopAnim('Run', -1.0/GroundSpeed,,0.3);
}

function PlayWalking()
{
	LoopAnim('Walk', -1.5/GroundSpeed,,0.3);
}

function PlayThreatening()
{
	local float decision;
	local float animspeed;
	animspeed = 0.4 + 0.6 * FRand();
	decision = FRand();

	if (decision < 0.3)
		NextAnim = 'Breath';
	else if (decision < 0.7)
	{
		PlaySound(Shake, SLOT_Talk, 0.0083 * Mass);
		NextAnim = 'Shake';
	}
	else
	{
		PlaySound(Swish, SLOT_Talk, 0.0083 * Mass);
		NextAnim = 'Swish';
	}
	LoopAnim(NextAnim, animspeed);
}

function PlayTurning()
{
	TweenAnim('Walk', 0.3);
}

function PlayDying(name DamageType, vector HitLocation)
{
	if ( FRand() < 0.6 )
		PlaySound(Die, SLOT_Talk, 0.025 * Mass,,,VoicePitch);
	else
		PlaySound(sound'DeathC2c', SLOT_Talk, 0.025 * Mass,,,VoicePitch);

	if ( (Velocity.Z > 200) && (FRand() < 0.75) )
		PlayAnim('Dead3', 0.7, 0.1);
	else if (FRand() < 0.5)
		PlayAnim('Dead', 0.7, 0.1);
	else
		PlayAnim('Dead2', 0.7, 0.1);
}

function TweenToFalling()
{
	TweenAnim('BigHit', 0.5);
}

function PlayInAir()
{
	TweenAnim('Run',0.5);
}

function PlayLanded(float impactVel)
{
	TweenAnim('Landed', 0.1);
}

function PlayTakeHit(float tweentime, vector HitLoc, int damage)
{
	if ( FRand() < 0.5 )
		PlaySound(HitSound1, SLOT_Interact, 0.02 * Mass,,,VoicePitch);
	else
		PlaySound(HitSound2, SLOT_Interact, 0.02 * Mass,,,VoicePitch);

	if (Velocity.Z > 200 + 100 * FRand())
		TweenAnim('BigHit', tweentime);
	else if ( FRand() < 0.5 )
		TweenAnim('TakeHit2', tweentime);
	else
		TweenAnim('TakeHit', tweentime);
}

function PlayChallenge()
{
	PlayAnim('Breath', 1.0, 0.12);
}

function PlayVictoryDance()
{
	PlayAnim('Breath', 1.0, 0.12);
}

function PlayRangedAttack()
{
	PlaySound(Roam, SLOT_Talk, 0.02 * Mass,,,VoicePitch);
	PlayAnim('Poop', 0.7);
}

/* Grazing - Cow version of wandering has longer pauses, and only starts when seeplayer
Also - special support for moms and babies
*/

function Help(TOMACow Other)
{
//only used when grazing
}

state Grazing
{
	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
						Vector momentum, name damageType)
	{
		Global.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
		if ( health <= 0 )
			return;
		if ( NextState == 'TakeHit' )
			{
			NextState = 'Attacking';
			NextLabel = 'Begin';
			GotoState('TakeHit');
			}
		else
			EnemyAcquired();
	}

	function Bump(actor Other)
	{
		if ( (Normal(Destination - Location) Dot Normal(Other.Location - Location)) > 0.8 )
			MoveTimer = -1.0;
		if ( (Pawn(Other) != None) && SetEnemy(Pawn(Other)) )
			EnemyAcquired();
		Disable('Bump');
	}

	function EnemyAcquired()
	{
		bReadyToAttack = True;
		PlayAcquisitionSound();
		GotoState('Attacking');
	}

	function Help(TOMACow Other)
	{
		if ( (Enemy != None) && (AttitudeTo(Enemy) < ATTITUDE_Ignore) )
			return;
		Enemy = Other.Enemy;
		if (Enemy.bIsPlayer)
			AttitudeToPlayer = ATTITUDE_Hate;
		else
			Hated = Enemy;
		Aggressiveness = 1.0;
		GotoState('Attacking');
	}

	function SetFall()
	{
		NextState = 'Grazing';
		NextLabel = 'ContinueWander';
		NextAnim = AnimSequence;
		GotoState('FallingState');
	}

	function bool TestDirection(vector dir, out vector pick, bool bAlongWall)
	{
		local vector HitLocation, HitNormal;
		local float minDist, Dist;
		local actor HitActor;

		dir.Z = 0;
		dir = Normal(dir);
		minDist = FMin(180.0, 6*CollisionRadius);
		pick = Location + dir * (minDist + FRand() * 900);

		HitActor = Trace(HitLocation, HitNormal, pick, Location, false);
		Dist = VSize(HitLocation - Location);
		if ( (Dist < minDist) && (HitNormal.Z < 0.7) )
		{
			if ( !bAlongWall )
				return false;
			pick = HitLocation - dir + (HitNormal Cross vect(0,0,1)) * 5 * CollisionRadius;
			HitActor = Trace(HitLocation, HitNormal, pick , Location, false);
			if (HitActor != None)
				return false;
		}
		else
			pick = HitLocation - 4 * CollisionRadius * dir;

		return true;
	}

	function PickDestination()
	{
		local vector pickdir;
		local bool success;
		local float XY, dist;

		if ( (Baby != None) && (VSize(Baby.Location - Location) > 400) )
		{
			Destination = Baby.Location;
			return;
		}

		// don't wander too far
		if ( bStayClose )
		{
			pickDir = StartLocation - Location;
			dist = VSize(pickDir);
			if ( dist > WanderRadius )
			{
				pickdir = pickDir/dist;
				if ( TestDirection(pickdir, Destination, true) )
				{
					if (Baby != None)
						Baby.FollowMom();
					return;
				}
			}
		}

		//Favor XY alignment
		pickdir.Z = 0;
		XY = FRand();
		if (XY < 0.3)
		{
			pickdir.X = 1;
			pickdir.Y = 0;
		}
		else if (XY < 0.6)
		{
			pickdir.X = 0;
			pickdir.Y = 1;
		}
		else
		{
			pickdir.X = 2 * FRand() - 1;
			pickdir.Y = 2 * FRand() - 1;
			pickdir = Normal(pickdir);
		}

		success = TestDirection(pickdir, Destination, false);
		if (!success)
			success = TestDirection(-1 * pickdir, Destination, true);

		if (success)
		{
			if (Baby != None)
				Baby.FollowMom();
		}
		else
		{
			Destination = Location;
			GotoState('Grazing', 'Turn');
		}
	}

	function AnimEnd()
	{
		PlayPatrolStop();
	}

	function SeePlayer(Actor SeenPlayer)
	{
		bForage = true;
		ScaryGuy = Pawn(SeenPlayer);
		if ( (Pawn(SeenPlayer).Health > 0) && SetEnemy(Pawn(SeenPlayer)) )
			LastSeenPos = SeenPlayer.Location;
		Disable('SeePlayer');
		Destination=SeenPlayer.Location;
		SetTimer(7.0, false);
	}

	function timer()
	{
		Enable('SeePlayer');
		bForage = false;
	}

	function SetTurn()
	{
		local float YawErr;

		if ( (Baby != None) && (FRand() < 0.35) )
			Destination = Baby.Location;
		else if ( (ScaryGuy != None) && (FRand() < 0.5) )
			Destination = ScaryGuy.Location;
		else
			Destination = Location + 20 * VRand();

		DesiredRotation = rotator(Destination - Location);
		DesiredRotation.Yaw = DesiredRotation.Yaw & 65535;
		YawErr = (DesiredRotation.Yaw - (Rotation.Yaw & 65535)) & 65535;
		if ( (YawErr > 16384) && (YawErr < 49151) )
		{
			if ( YawErr > 32768 )
				DesiredRotation.Yaw = DesiredRotation.Yaw + 16384;
			else
				DesiredRotation.Yaw = DesiredRotation.Yaw - 16384;
			Destination = Location + 20 * vector(DesiredRotation);
		}
	}

	function BeginState()
	{
		MinHitWall = -0.2;
		StartLocation = Location;
		Enemy = None;
		SetAlertness(0.0);
		bReadyToAttack = false;
		bAvoidLedges = true;
		Disable('AnimEnd');
		NextAnim = '';
		JumpZ = -1;
		if (Enemy == None)
		{
			bForage = false;
			Disable('EnemyNotVisible');
			Enable('SeePlayer');
		}
		else
		{
			bForage = true;
			Enable('EnemyNotVisible');
			Disable('SeePlayer');
		}
	}

	function EndState()
	{
		if ( Enemy.bIsPlayer )
			MakeNoise(1.0);
		JumpZ = Default.JumpZ;
		bAvoidLedges = false;
		MinHitWall = Default.MinHitWall;
	}

Begin:
	//log(class$" Grazing");

Wander:
	if (!bForage)
		Goto('Graze');
	WaitForLanding();
	PickDestination();
	TweenToWalking(0.2);
	FinishAnim();
	PlayWalking();

Moving:
	Enable('Bump');
	MoveTo(Destination, 0.4);
Graze:
	Acceleration = vect(0,0,0);
	TweenAnim('Breath', 0.3);
	if (FRand() < 0.5)
	{
		FinishAnim();
		PlayAnim('Root', 0.3 + 0.4*FRand());
	}
	Enable('AnimEnd');
	NextAnim = '';
	Sleep(6 + 10 * FRand());
	Disable('AnimEnd');
	FinishAnim();
	Goto('Wander');

ContinueWander:
	FinishAnim();
	PlayWalking();
	Goto('Wander');

Turn:
	Acceleration = vect(0,0,0);
	PlayTurning();
	SetTurn();
	TurnTo(Destination);
	Goto('Graze');
}

function PlayMeleeAttack()
{
	local float dist, decision;

	decision = FRand();
	dist = VSize(Target.Location - Location);
	if (dist > CollisionRadius + Target.CollisionRadius + 45)
		decision = 0.0;

	if (Physics == PHYS_Falling)
		decision = 1.0;
	if (Target == None)
		decision = 1.0;

	if (decision < 0.15)
	{
		Enable('Bump');
		Velocity = 450 * Normal(Target.Location + Target.CollisionHeight * vect(0,0,0.75) - Location);
		if (dist > CollisionRadius + Target.CollisionRadius + 35)
			Velocity.Z += 0.7 * dist;
		SetPhysics(PHYS_Falling);
	}
  	else
  	{
		MeleeRange = 50;
		MeleeDamageTarget(25, vect(0,10000,0));
		MeleeRange = Default.MeleeRange;
	}
}

state MeleeAttack
{
	singular function Bump(actor Other)
	{
		Disable('Bump');
		if (Other == Target)
			MeleeDamageTarget(25, vect(0,10000,0));
	}
}

defaultproperties
{
     bStayClose=True
     WanderRadius=0
     shake=Sound'UnrealShare.Cow.shakeC'
     Swish=Sound'UnrealShare.Cow.swishC'
     footstep=Sound'UnrealShare.Cow.walkC'
     CarcassType=Class'UnrealShare.CowCarcass'
     Orders=Roaming
     bIsWuss=True
     Acquire=Sound'UnrealShare.Cow.cMoo1c'
     Roam=Sound'UnrealShare.Cow.cMoo2c'
     Threaten=Sound'UnrealShare.Cow.cMoo2c'
     GroundSpeed=180
     WaterSpeed=100
     JumpZ=-1
     MaxStepHeight=17
     SightRadius=1500
     PeripheralVision=-10
     HearingThreshold=0.7
     Health=60
     UnderWaterTime=40
     AttitudeToPlayer=ATTITUDE_Fear
     HitSound1=Sound'UnrealShare.Cow.injurC1c'
     HitSound2=Sound'UnrealShare.Cow.injurC2c'
     Die=Sound'UnrealShare.Cow.DeathC1c'
     CombatStyle=1
     AmbientSound=Sound'UnrealShare.Cow.ambCow'
     DrawType=DT_Mesh
     Mesh=LodMesh'UnrealShare.NaliCow'
     CollisionRadius=48
     CollisionHeight=32
     Mass=120
     RotationRate=(Pitch=2048,Yaw=30000,Roll=0)
     NameOfMonster="Cow"
	MoneyDroped=50
	sshot1="TOMATex21.Sshot.Cow"
}
