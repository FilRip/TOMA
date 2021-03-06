//=============================================================================
// Slith.
//=============================================================================
class TOMASlith extends TOMAScriptedPawn;

//FIXME - not using Charge1sl
//-----------------------------------------------------------------------------
// Slith variables.

// Attack damage.
var() byte ClawDamage;	// Basic damage done by Claw/punch.
var bool bFirstAttack;

var(Sounds) sound die2;
var(Sounds) sound slick;
var(Sounds) sound slash;
var(Sounds) sound slice;
var(Sounds) sound slither;
var(Sounds) sound swim;
var(Sounds) sound dive;
var(Sounds) sound surface;
var(Sounds) sound scratch;
var(Sounds) sound charge;

//-----------------------------------------------------------------------------
// Slith functions.

/* PreSetMovement()
default for walking creature.  Re-implement in subclass
for swimming/flying capability
*/
function PreSetMovement()
{
	MaxDesiredSpeed = 0.79 + 0.07 * skill;
	bCanJump = true;
	bCanWalk = true;
	bCanSwim = true;
	bCanFly = false;
	MinHitWall = -0.6;
	if (Intelligence > BRAINS_Reptile)
		bCanOpenDoors = true;
	if (Intelligence == BRAINS_Human)
		bCanDoSpecial = true;
}

function JumpOutOfWater(vector jumpDir)
{
	Falling();
	Velocity = jumpDir * WaterSpeed;
	Acceleration = jumpDir * AccelRate;
	velocity.Z = 460; //set here so physics uses this for remainder of tick
	PlayOutOfWater();
	bUpAndOut = true;
}

function SetFall()
	{
		if (Enemy != None)
		{
			NextState = 'Attacking'; //default
			NextLabel = 'Begin';
			NextAnim = 'LFighter';
			GotoState('FallingState');
		}
	}

function PlayAcquisitionSound()
{
	if ( FRand() < 0.5 )
		PlaySound(Acquire, SLOT_Talk);
	else
		PlaySound(sound'yell3sl', SLOT_Talk);
}

function PlayWaiting()
{
	local float decision;

	if (Region.Zone.bWaterZone)
	{
		LoopAnim('Swim', 0.2  + 0.3 * FRand());
		return;
	}

	decision = FRand();

	if (decision < 0.8)
		LoopAnim('Breath', 0.2 + 0.6 * FRand());
	else if (decision < 0.9)
	{
		PlaySound(Slick, SLOT_Interact);
		LoopAnim('Slick', 0.4 + 0.6 * FRand());
	}
	else
	{
		PlaySound(Scratch, SLOT_Interact);
		LoopAnim('Scratch', 0.4 + 0.6 * FRand());
	}
}

function PlayPatrolStop()
{
	PlayWaiting();
}

function PlayWaitingAmbush()
{
	PlayWaiting();
}

function PlayChallenge()
{
	TweenToFighter(0.1);
}

function TweenToFighter(float tweentime)
{
	if (Region.Zone.bWaterZone)
		TweenAnim('WFighter', tweentime);
	else
		TweenAnim('LFighter', tweentime);
}

function TweenToRunning(float tweentime)
{
	if (Region.Zone.bWaterZone)
	{
		if ( (AnimSequence == 'Shoot2') && IsAnimating() )
			return;
		if ( (AnimSequence != 'Swim') || !bAnimLoop )
			TweenAnim('Swim', tweentime);
	}
	else
	{
		if ( (AnimSequence == 'Shoot1') && IsAnimating() )
			return;
		if ( (AnimSequence != 'Slither') || !bAnimLoop )
			TweenAnim('Slither', tweentime);
	}
}

function TweenToWalking(float tweentime)
{
	if (Region.Zone.bWaterZone)
	{
		if ( (AnimSequence != 'Swim') || !bAnimLoop )
			TweenAnim('Swim', tweentime);
	}
	else
	{
		if ( (AnimSequence != 'Slither') || !bAnimLoop )
			TweenAnim('Slither', tweentime);
	}
}

function TweenToWaiting(float tweentime)
{
	if (Region.Zone.bWaterZone)
		TweenAnim('Swim', tweentime);
	else
		TweenAnim('Breath', tweentime);
}

function TweenToPatrolStop(float tweentime)
{
	TweenToWaiting(tweentime);
}

function PlayRunning()
{
	if (Region.Zone.bWaterZone)
	{
		PlaySound(Swim, SLOT_Interact);
		LoopAnim('Swim', -1.0/WaterSpeed,, 0.4);
	}
	else
	{
		PlaySound(Slither, SLOT_Interact);
		LoopAnim('Slither', -1.1/GroundSpeed,, 0.4);
	}
}

function PlayWalking()
{
	if (Region.Zone.bWaterZone)
	{
		PlaySound(Swim, SLOT_Interact);
		LoopAnim('Swim', -1.0/WaterSpeed,, 0.4);
	}
	else
	{
		PlaySound(Slither, SLOT_Interact);
		LoopAnim('Slither', -1.3/GroundSpeed,, 0.4);
	}
}

function PlayThreatening()
{
	local float decision;
	decision = FRand();

	if (decision < 0.8)
	{
		PlayWaiting();
		return;
	}
	NextAnim = '';

	if (Region.Zone.bWaterZone)
		TweenAnim('WFighter', 0.25);
	else
		TweenAnim('LFighter', 0.25);
}

function PlayTurning()
{
	if (Region.Zone.bWaterZone)
		TweenAnim('Swim', 0.35);
	else
		TweenAnim('Slither', 0.35);
}

function PlayDying(name DamageType, vector HitLocation)
{
	if (Region.Zone.bWaterZone)
	{
		PlaySound(Die2, SLOT_Talk, 4 * TransientSoundVolume);
		PlayAnim('Dead2', 0.7, 0.1);
	}
	else
	{
		PlaySound(Die, SLOT_Talk, 4 * TransientSoundVolume);
		PlayAnim('Dead1', 0.7, 0.1);
	}
}

function PlayTakeHit(float tweentime, vector HitLoc, int Damage)
{
	if (Region.Zone.bWaterZone)
		TweenAnim('WTakeHit', tweentime);
	else
		TweenAnim('LTakeHit', tweentime);
}

function PlayOutOfWater()
{
	PlayAnim('Surface',,0.1);
}

function PlayDive()
{
	PlayAnim('Dive',,0.1);
}

function TweenToFalling()
{
	TweenAnim('Falling', 0.4);
}

function PlayInAir()
{
	TweenAnim('Falling', 0.4);
}

function PlayLanded(float impactVel)
{
	TweenAnim('Slither', 0.25);
}


function PlayVictoryDance()
{
	PlayAnim('ChargeUp', 0.3, 0.1);
	PlaySound(Charge, SLOT_Interact);
}

function ClawDamageTarget()
{
	MeleeDamageTarget(ClawDamage, (ClawDamage * 1000.0 * Normal(Target.Location - Location)));
}

function PlayMeleeAttack()
{
	local float decision;

	decision = FRand();
	Acceleration = AccelRate * Normal(Target.Location - Location);
	if ( Region.Zone.bWaterZone )
	{
		if (AnimSequence == 'Claw1')
			decision += 0.17;
		else if (AnimSequence == 'Claw2')
			decision -= 0.17;

		if (decision < 0.5)
			PlayAnim('Claw1');
		else
			PlayAnim('Claw2');
	}
	else
	{
		if (AnimSequence == 'Punch')
			decision += 0.17;
		else if (AnimSequence == 'Slash')
			decision -= 0.17;
		if (decision < 0.5)
		{
			PlayAnim('Punch');
 		}
		else
		{
	 		PlayAnim('Slash');
	 	}
 	}
 }


function bool CanFireAtEnemy()
{
	local vector HitLocation, HitNormal, EnemyDir, projStart;
	local actor HitActor;
	local float EnemyDist;

	EnemyDir = Enemy.Location - Location + Enemy.CollisionHeight * vect(0,0,0.8);
	EnemyDist = VSize(EnemyDir);
	if (EnemyDist > 750) //FIXME - what is right number?
		return false;

	EnemyDir = EnemyDir/EnemyDist;
	projStart = Location + 0.8 * CollisionRadius * EnemyDir + 0.8 * CollisionHeight * vect(0,0,1);
	HitActor = Trace(HitLocation, HitNormal,
				projStart + (MeleeRange + Enemy.CollisionRadius) * EnemyDir,
				projStart, false, vect(6,6,4) );

	return (HitActor == None);
}

function ShootTarget()
{
	FireProjectile( vect(1, 0, 0.8), 900);
}

function PlayRangedAttack()
{
	if (Region.Zone.bWaterZone)
		PlayAnim('Shoot2');
	else
		PlayAnim('Shoot1');
}

function PlayMovingAttack()
{
	PlayRangedAttack();
}

state MeleeAttack
{
ignores SeePlayer, HearNoise, Bump;

	function PlayMeleeAttack()
	{
		if ( Region.Zone.bWaterZone && !bFirstAttack && (FRand() > 0.4 + 0.17 * skill) )
		{
			PlayAnim('Swim');
			Acceleration = AccelRate * Normal(Location - Enemy.Location + 0.9 * VRand());
		}
		else
			Global.PlayMeleeAttack();
		bFirstAttack = false;
	}

	function BeginState()
	{
		Super.BeginState();
		bCanStrafe = True;
		bFirstAttack = True;
	}

	function EndState()
	{
		Super.EndState();
		bCanStrafe = false;
	}
}

defaultproperties
{
     ClawDamage=25
     Die2=Sound'UnrealShare.Slith.deathWsl'
     SLASH=Sound'UnrealShare.Slith.yell4sl'
     SLITHER=Sound'UnrealShare.Slith.slithr1sl'
     Swim=Sound'UnrealShare.Slith.swim1sl'
     DIVE=Sound'UnrealShare.Slith.dive2sl'
     Surface=Sound'UnrealShare.Slith.surf1sl'
     SCRATCH=Sound'UnrealShare.Slith.scratch1sl'
     CarcassType=Class'UnrealShare.SlithCarcass'
     TimeBetweenAttacks=1.2
     Aggressiveness=0.7
     RefireRate=0.4
     WalkingSpeed=0.3
     bHasRangedAttack=True
     bMovingRangedAttack=True
     RangedProjectile=Class'UnrealShare.SlithProjectile'
     ProjectileSpeed=750
     Acquire=Sound'UnrealShare.Slith.yell1sl'
     Fear=Sound'UnrealShare.Slith.yell3sl'
     Roam=Sound'UnrealShare.Slith.roam1sl'
     Threaten=Sound'UnrealShare.Slith.yell2sl'
     MeleeRange=50
     GroundSpeed=250
     WaterSpeed=280
     AccelRate=850
     JumpZ=120
     Visibility=150
     SightRadius=2000
     Health=210
     ReducedDamageType=Corroded
     ReducedDamagePct=1
     UnderWaterTime=-1
     HitSound1=Sound'UnrealShare.Slith.injur1sl'
     HitSound2=Sound'UnrealShare.Slith.injur2sl'
     Die=Sound'UnrealShare.Slith.deathLsl'
     CombatStyle=0.85
     AmbientSound=Sound'UnrealShare.Slith.amb1sl'
     DrawType=DT_Mesh
     Mesh=LodMesh'UnrealShare.Slith1'
     CollisionRadius=48
     CollisionHeight=44
     Mass=200
     Buoyancy=200
     RotationRate=(Pitch=3072,Yaw=40000,Roll=6000)
     NameOfMonster="Slith"
	MoneyDroped=300
	sshot1="TOMATex21.Sshot.Slith"
}
