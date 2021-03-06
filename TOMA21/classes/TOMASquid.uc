//=============================================================================
// Squid.
//=============================================================================
class TOMASquid extends TOMAScriptedPawn;

//-----------------------------------------------------------------------------
// Squid variables.

// Attack damage.
var() byte
	ThrustDamage,		// Basic damage done by bite.
	SlapDamage;

var(Sounds) sound thrust;
var(Sounds) sound slapgrabhit;
var(Sounds) sound thrusthit;
var(Sounds) sound slap;
var(Sounds) sound turn;
var(Sounds) sound grab;
var(Sounds) sound spin;
var(Sounds) sound flop;

//-----------------------------------------------------------------------------
// Squid functions.

function ZoneChange(ZoneInfo newZone)
{
	local vector start, checkpoint, HitNormal, HitLocation;
	local actor HitActor;

	if ( newZone.bWaterZone )
	{
		if (Physics != PHYS_Swimming)
			setPhysics(PHYS_Swimming);
	}
	else if (Physics == PHYS_Swimming)
	{
		SetPhysics(PHYS_Falling);
		MoveTimer = -1.0;
		GotoState('Flopping');
	}
}

function PreSetMovement()
{
	bCanJump = true;
	bCanWalk = false;
	bCanSwim = true;
	bCanFly = false;
	MinHitWall = -0.6;
	bCanOpenDoors = false;
	bCanDoSpecial = false;
}

function SetMovementPhysics()
{
	if (Region.Zone.bWaterZone)
		SetPhysics(PHYS_Swimming);
	else
	{
		SetPhysics(PHYS_Falling);
		MoveTimer = -1.0;
		GotoState('Flopping');
	}
}

function PlayWaiting()
	{
	LoopAnim('Fighter', 0.1 + 0.3 * FRand());
	}

function PlayPatrolStop()
	{
	LoopAnim('Fighter', 0.1 + 0.3 * FRand());
	}

function PlayWaitingAmbush()
	{
	LoopAnim('Fighter', 0.1 + 0.3 * FRand());
	}

function PlayChallenge()
{
	PlayAnim('Fighter', 0.4, 0.2);
}

function TweenToFighter(float tweentime)
{
	TweenAnim('Fighter', tweentime);
}

function TweenToRunning(float tweentime)
{
	if ( (AnimSequence != 'Swim') || !bAnimLoop )
		TweenAnim('Swim', tweentime);
}

function TweenToWalking(float tweentime)
{
	if ( (AnimSequence != 'Swim') || !bAnimLoop )
		TweenAnim('Swim', tweentime);
}

function TweenToWaiting(float tweentime)
{
	PlayAnim('Fighter', 0.2 + 0.8 * FRand(), 0.3);
}

function TweenToPatrolStop(float tweentime)
{
	TweenAnim('Fighter', tweentime);
}

function PlayRunning()
{
	if ( ((AnimSequence == 'Spin') && (FRand() < 0.8)) || (FRand() < 0.06) )
		LoopAnim('Spin');
	else
		LoopAnim('Swim', -0.8/WaterSpeed,, 0.4);
}

function PlayWalking()
{
	LoopAnim('Swim', -0.8/WaterSpeed,, 0.4);
}

function PlayThreatening()
{
	if ( FRand() < 0.6 )
		PlayAnim('Swim', 0.4);
	else
	{
		PlaySound(Spin, SLOT_Interact);
		PlayAnim('Spin', 0.4);
	}
}

function PlayTurning()
{
	PlaySound(turn, SLOT_Interact);
	LoopAnim('Turn', 0.4);
}

function PlayDying(name DamageType, vector HitLocation)
{
	PlaySound(Die, SLOT_Talk, 4 * TransientSoundVolume);
	PlayAnim('Dead1', 0.7, 0.1);
}

function PlayTakeHit(float tweentime, vector HitLoc, int damage)
{
	TweenAnim('TakeHit', tweentime);
}

function TweenToFalling()
{
	DesiredRotation = Rotation;
	DesiredRotation.Pitch = 0;
	TweenAnim('Spin', 0.2);
}

function PlayInAir()
{
	LoopAnim('Fighter', 0.7);
}

function PlayLanded(float impactVel)
{
	TweenAnim('Spin', 0.2);
}

function PlayVictoryDance()
{
	PlayAnim('grab', 0.6, 0.1);
	PlaySound(Grab, SLOT_Interact);
}


function GrabTarget()
{
	if ( MeleeDamageTarget(SlapDamage, (SlapDamage * 1500.0 * Normal(Location - Target.Location))) )
		PlaySound(SlapGrabHit, SLOT_Interact);
}

function SlapTarget()
{
	if ( MeleeDamageTarget(SlapDamage, (SlapDamage * 1500.0 * Normal(Target.Location - Location))) )
		PlaySound(SlapGrabHit, SLOT_Interact);
}

function ThrustTarget()
{
	if ( MeleeDamageTarget(ThrustDamage, (ThrustDamage * 1500.0 * Normal(Target.Location - Location))) )
		PlaySound(ThrustHit, SLOT_Interact);
}

//FIXME - hold (turn off client's physics???
function PlayMeleeAttack()
{
	local float decision;
	decision = FRand();
	if (decision < 0.35)
	{
		PlaySound(Thrust, SLOT_Interact);
		PlayAnim('Thrust', 0.8);
	}
	if (decision < 0.7)
	{
		PlaySound(Slap, SLOT_Interact);
		PlayAnim('Slap', 0.8);
	}
	else
	{
		PlaySound(Grab, SLOT_Interact);
		PlayAnim('Grab');
 	}
}


function bool MeleeDamageTarget(int hitdamage, vector pushdir)
	{
	local vector HitLocation, HitNormal, TargetPoint;
	local float TargetDist;
	local actor HitActor;
	local bool result;

	result = false;
	TargetDist = VSize(Target.Location - Location);
	Acceleration = AccelRate * (Target.Location - Location)/TargetDist;
	If (TargetDist <= (MeleeRange * 1.4 + Target.CollisionRadius + CollisionRadius)) //still in melee range
		{
		TargetPoint = Location - TargetDist * vector(Rotation);
		TargetPoint.Z = FMin(TargetPoint.Z, Target.Location.Z + Target.CollisionHeight);
		TargetPoint.Z = FMax(TargetPoint.Z, Target.Location.Z - Target.CollisionHeight);
		HitActor = Trace(HitLocation, HitNormal, TargetPoint, Location, true);
		If (HitActor == Target)
			{
			Target.TakeDamage(hitdamage, Self,HitLocation, pushdir, 'hacked');
			result = true;
			}
		}
	return result;
	}


state Flopping
{
ignores seeplayer, hearnoise, enemynotvisible, hitwall;
	function Timer()
	{
		SetPhysics(PHYS_Falling);
		Velocity = 200 * VRand();
		Velocity.Z = 170 + 200 * FRand();
		DesiredRotation.Pitch = Rand(8192) - 4096;
		DesiredRotation.Yaw = Rand(65535);
	}

	function ZoneChange( ZoneInfo NewZone )
	{
		local Rotator newRotation;
		if (NewZone.bWaterZone)
		{
			newRotation = Rotation;
			newRotation.Roll = 0;
			SetRotation(newRotation);
			SetPhysics(PHYS_Swimming);
			GotoState('Attacking');
		}
		else if (Physics != PHYS_Falling)
			SetPhysics(PHYS_Falling);
	}

	function Landed(vector HitNormal)
	{
		SetPhysics(PHYS_None);
		DesiredRotation.Pitch = 0;
		SetTimer(0.3 + FRand(), false);
	}

	function AnimEnd()
	{
		PlayAnim('Spin', 0.7);
	}

Begin:
	SetTimer(0.3 + FRand(), false);
	TweenAnim('Slap', 0.7);
}

state TacticalMove
{
ignores SeePlayer, HearNoise;

	function Timer()
	{
		Spawn(class'BigBlackSmoke');
	}

	function BeginState()
	{
		SetTimer(0.2, true);
		Super.BeginState();
	}
}

//squid has own melee attack because he faces away from his target when attacking
state MeleeAttack
{
ignores SeePlayer, HearNoise, Bump;
	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
							Vector momentum, name damageType)
	{
		Global.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
		if ( health <= 0 )
			return;
		if (NextState == 'TakeHit')
		{
			NextState = 'MeleeAttack';
			NextLabel = 'Begin';
		}
	}

	function KeepAttacking()
	{
		bReadyToAttack = true;
		if ( (Target == None)
			|| ((Pawn(Target) != None) && (Pawn(Target).Health == 0)) )
			GotoState('Attacking');
		else if (VSize(Target.Location - Location) > (0.9 * MeleeRange + Target.CollisionRadius + CollisionRadius))
			GotoState('TacticalMove', 'NoCharge');
	}

	function EnemyNotVisible()
	{
		GotoState('Attacking');
	}

	function AnimEnd()
	{
		GotoState('MeleeAttack', 'DoneAttacking');
	}

	function BeginState()
	{
		Disable('AnimEnd');
		bCanStrafe = true; //so he can turn in place
	}

	function EndState()
	{
		bCanStrafe = false;
	}

Begin:
	if (Target == None)
		Target = Enemy;

FaceTarget:
	Acceleration = Vect(0,0,0);
	if (NeedToTurn(2 * Location - Target.Location))
	{
		PlayTurning();
		TurnTo(2 * Location - Target.Location);
		TweenToFighter(0.15);
	}
	else if ( (5 - Skill) * FRand() > 3 )
	{
		DesiredRotation = Rotator(Location - Target.Location);
		PlayChallenge();
	}

	FinishAnim();

	if (VSize(Location - Target.Location) > MeleeRange + CollisionRadius + Target.CollisionRadius)
		GotoState('Attacking');

ReadyToAttack:
	DesiredRotation = Rotator(Location - Target.Location);
	PlayMeleeAttack();
	Enable('AnimEnd');
Attacking:
	TurnTo(2 * Location - Target.Location);
	Goto('Attacking');
DoneAttacking:
	Disable('AnimEnd');
	KeepAttacking();
	Goto('FaceTarget');
}



defaultproperties
{
     ThrustDamage=35
     SlapDamage=30
     Thrust=Sound'UnrealI.Squid.thrust1sq'
     slapgrabhit=Sound'UnrealI.Squid.hit1sq'
     thrusthit=Sound'UnrealI.Squid.hit1sq'
     Slap=Sound'UnrealI.Squid.slap1sq'
     Turn=Sound'UnrealI.Squid.turn1sq'
     Grab=Sound'UnrealI.Squid.grab1sq'
     Aggressiveness=0.800000
     MeleeRange=70.000000
     GroundSpeed=0.000000
     WaterSpeed=260.000000
     AirSpeed=0.000000
     SightRadius=2000.000000
     PeripheralVision=-0.500000
     Health=260
     HitSound1=Sound'UnrealI.Squid.injur1sq'
     HitSound2=Sound'UnrealI.Squid.injur2sq'
     Die=Sound'UnrealI.Squid.death1sq'
     AmbientSound=Sound'UnrealI.Squid.amb1sq'
     DrawType=DT_Mesh
     Mesh=LodMesh'UnrealI.Squid1'
     CollisionRadius=40.000000
     CollisionHeight=60.000000
     Mass=200.000000
     Buoyancy=200.000000
     RotationRate=(Pitch=13000,Roll=13000)
     NameOfMonster="Squid"
	sshot1="TOMATex21.Sshot.Squid"
}
