//=============================================================================
// Brute.
//=============================================================================
class TOMABrute extends TOMAScriptedPawn;

//-----------------------------------------------------------------------------
// Brute variables.

// Attack damage.
var() byte WhipDamage;		// Basic damage done by pistol-whip.
var bool   bBerserk;
var bool   bLongBerserk;
var() bool bTurret;			// Doesn't move

// Sounds
var(Sounds) sound Footstep;
var(Sounds) sound Footstep2;
var(Sounds) sound PistolWhip;
var(Sounds) sound GutShot;
var(Sounds) sound PistolHit;
var(Sounds) sound Die2;

function PostBeginPlay()
{
	Super.PostBeginPlay();
	if (Skill > 1)
		bLeadTarget = true;
	if ( Skill == 0 )
		ProjectileSpeed *= 0.85;
	else if ( Skill > 2 )
		ProjectileSpeed *= 1.1;
}

function GoBerserk()
{
	bLongBerserk = false;
	if ( (bBerserk || ((Health < 0.75 * Default.Health) && (FRand() < 0.65)))
		&& (VSize(Location - Enemy.Location) < 500) )
		bBerserk = true;
	else
		bBerserk = false;
	if ( bBerserk )
	{
		AccelRate = 4 * AccelRate;
		GroundSpeed = 2.5 * Default.GroundSpeed;
	}
}

function PlayWaiting()
{
	local float decision;
	local float animspeed;

	bReadyToAttack = true;
	animspeed = 0.3 + 0.5 * FRand(); //fixme - add to all creatures

	decision = FRand();
	if ( AnimSequence == 'Sleep' )
	{
		if ( decision < 0.07 )
		{
			SetAlertness(0.0);
			PlayAnim('Breath2',animspeed, 0.4);
			return;
		}
		else
		{
			SetAlertness(-0.3);
			PlayAnim('Sleep', 0.3 + 0.3 * FRand());
			return;
		}
	}
	else if ( AnimSequence == 'Breath2' )
	{
		if ( decision < 0.2 )
		{
			SetAlertness(-0.3);
			PlayAnim('Sleep',animspeed,0.4);
			return;
		}
		else if ( decision < 0.37 )
			PlayAnim('StillLook', animspeed);
		else if ( decision < 0.55 )
			PlayAnim('CockGun', animspeed);
		else
			PlayAnim('Breath2', 0.3 + 0.3 * FRand(), 0.4);
	}
	else if ( decision < 0.1 )
		PlayAnim('StillLook', animspeed, 0.4);
	else
		PlayAnim('Breath2', 0.3 + 0.3 * FRand(), 0.4);

	if ( AnimSequence == 'StillLook' )
	{
		SetAlertness(0.7);
		if ( !bQuiet && (FRand() < 0.7) )
			PlayRoamingSound();
	}
	else
		SetAlertness(0.0);
}

function PlayThreatening()
{
	local float decision;

	decision = FRand();

	if ( decision < 0.7 )
		PlayAnim('Breath2', 0.4, 0.3);
	else if ( decision < 0.8 )
		LoopAnim('PreCharg', 0.4, 0.25);
	else
	{
		PlayThreateningSound();
		TweenAnim('Fighter', 0.3);
	}
}

function PlayPatrolStop()
{
	local float decision;
	local float animspeed;
	animspeed = 0.5 + 0.4 * FRand(); //fixme - add to all creatures

	decision = FRand();
	if ( AnimSequence == 'Breath2' )
	{
		if ( decision < 0.4 )
			PlayAnim('StillLook', animspeed);
		else if (decision < 0.6 )
			PlayAnim('CockGun', animspeed);
		else
			PlayAnim('Breath2', animspeed);
	}
	else if ( decision < 0.2 )
		PlayAnim('StillLook', animspeed);
	else
		PlayAnim('Breath2', animspeed);

	if ( AnimSequence == 'StillLook' )
	{
		SetAlertness(0.7);
		if ( !bQuiet && (FRand() < 0.7) )
			PlayRoamingSound();
	}
	else
		SetAlertness(0.0);
}

function PlayWaitingAmbush()
{
	bQuiet = true;
	PlayPatrolStop();
}

function PlayChallenge()
{
	PlayAnim('PreCharg', 0.7, 0.2);
}

function TweenToFighter(float tweentime)
{
	TweenAnim('Fighter', tweentime);
}

function TweenToRunning(float tweentime)
{
	if ( bBerserk )
		TweenAnim('Charge', tweentime);
	if ( IsAnimating() && (AnimSequence == 'WalkFire') )
		return;
	if (AnimSequence != 'Walk' || !bAnimLoop)
		TweenAnim('Walk', tweentime);
}

function TweenToWalking(float tweentime)
{
	TweenAnim('Walk', tweentime);
}

function TweenToWaiting(float tweentime)
{
	TweenAnim('Breath2', tweentime);
}

function TweenToPatrolStop(float tweentime)
{
	TweenAnim('Breath2', tweentime);
}

function PlayRunning()
{
	if (Focus == Destination)
	{
		LoopAnim('Walk', -1.1/GroundSpeed,,0.4);
		return;
	}

	LoopAnim('Walk', StrafeAdjust(),,0.3);
}

function PlayWalking()
{
	LoopAnim('Walk', -1.1/GroundSpeed,,0.4);
}

function PlayTurning()
{
	TweenAnim('Walk', 0.3);
}

function PlayBigDeath(name DamageType)
{
	PlaySound(Die2, SLOT_Talk, 4 * TransientSoundVolume);
	PlayAnim('Dead2',0.7,0.1);
}

function PlayHeadDeath(name DamageType)
{
	PlayAnim('Dead4',0.7,0.1);
	PlaySound(Die, SLOT_Talk, 4 * TransientSoundVolume);
}

function PlayLeftDeath(name DamageType)
{
	PlayAnim('Dead2',0.7,0.1);
	PlaySound(Die,SLOT_Talk, 4 * TransientSoundVolume);
}

function PlayRightDeath(name DamageType)
{
	PlayAnim('Dead3',0.7,0.1);
	PlaySound(Die,SLOT_Talk, 4 * TransientSoundVolume);
}

function PlayGutDeath(name DamageType)
{
	PlayAnim('Dead1',0.7,0.1);
	PlaySound(Die,SLOT_Talk, 4 * TransientSoundVolume);
}

function PlayMovingAttack()
{
	PlayAnim('WalkFire', 1.1);
}

function PlayVictoryDance()
{
	PlayAnim('PreCharg', 0.7, 0.3);
}

function bool CanFireAtEnemy()
{
	local vector HitLocation, HitNormal,X,Y,Z, projStart, EnemyDir, EnemyUp;
	local actor HitActor1, HitActor2;
	local float EnemyDist;

	EnemyDir = Enemy.Location - Location;
	EnemyDist = VSize(EnemyDir);
	EnemyUp = Enemy.CollisionHeight * vect(0,0,0.9);
	if ( EnemyDist > 300 )
	{
		EnemyDir = 300 * EnemyDir/EnemyDist;
		EnemyUp = 300 * EnemyUp/EnemyDist;
	}

	GetAxes(Rotation,X,Y,Z);
	projStart = Location + 0.5 * CollisionRadius * X + 0.8 * CollisionRadius * Y + 0.4 * CollisionRadius * Z;
	HitActor1 = Trace(HitLocation, HitNormal, projStart + EnemyDir + EnemyUp, projStart, true);
	if ( (HitActor1 != Enemy) && (Pawn(HitActor1) != None)
		&& (AttitudeTo(Pawn(HitActor1)) > ATTITUDE_Ignore) )
		return false;

	projStart = Location + 0.5 * CollisionRadius * X - 0.8 * CollisionRadius * Y + 0.4 * CollisionRadius * Z;
	HitActor2 = Trace(HitLocation, HitNormal, projStart + EnemyDir + EnemyUp, projStart, true);

	if ( (HitActor2 == None) || (HitActor2 == Enemy)
		|| ((Pawn(HitActor2) != None) && (AttitudeTo(Pawn(HitActor2)) <= ATTITUDE_Ignore)) )
		return true;

	HitActor2 = Trace(HitLocation, HitNormal, projStart + EnemyDir, projStart , true);

	return ( (HitActor2 == None) || (HitActor2 == Enemy)
			|| ((Pawn(HitActor2) != None) && (AttitudeTo(Pawn(HitActor2)) <= ATTITUDE_Ignore)) );
}

function SpawnLeftShot()
{
	FireProjectile( vect(1.2,0.7,0.4), 750);
}

function SpawnRightShot()
{
	FireProjectile( vect(1.2,-0.7,0.4), 750);
}

function WhipDamageTarget()
{
	if ( MeleeDamageTarget(WhipDamage, (WhipDamage * 1000.0 * Normal(Target.Location - Location))) )
		PlaySound(PistolWhip, SLOT_Interact);
}

function Step()
{
	if (FRand() < 0.6)
		PlaySound(FootStep, SLOT_Interact,,,2000);
	else
		PlaySound(FootStep2, SLOT_Interact,,,2000);
}

function GutShotTarget()
{
	FireProjectile( vect(1.2,-0.55,0.0), 800);
}

function PlayMeleeAttack()
{
	local float decision;

	decision = FRand();
	If ( decision < 0.6 )
 	{
 		PlaySound(PistolWhip, SLOT_Interact);
  		PlayAnim('PistolWhip');
  	}
 	else
 	{
		PlaySound(PistolWhip, SLOT_Interact);
 		PlayAnim('Punch');
 	}
}

function PlayRangedAttack()
{
	//FIXME - if going to ranged attack need to
	//	TweenAnim('StillFire', 0.2);
	//What I need is a tween into time for the PlayAnim()

	if ( (AnimSequence == 'T8') || (VSize(Target.Location - Location) > 230) )
	{
		SpawnRightShot();
		PlayAnim('StillFire');
	}
  	else
 		PlayAnim('GutShot');
}

state Attacking
{
ignores SeePlayer, HearNoise, Bump, HitWall;

	function ChooseAttackMode()
	{
		local eAttitude AttitudeToEnemy;
		local float Aggression;
		local pawn changeEn;

		if ( !bTurret )
		{
			Super.ChooseAttackMode();
			return;
		}

		if ((Enemy == None) || (Enemy.Health <= 0))
		{
			if (Orders == 'Attacking')
				Orders = '';
			GotoState('Waiting', 'TurnFromWall');
			return;
		}

		if (AttitudeToEnemy == ATTITUDE_Threaten)
		{
			GotoState('Threatening');
			return;
		}
		else if (!LineOfSightTo(Enemy))
		{
			if ( (OldEnemy != None)
				&& (AttitudeTo(OldEnemy) == ATTITUDE_Hate) && LineOfSightTo(OldEnemy) )
			{
				changeEn = enemy;
				enemy = oldenemy;
				oldenemy = changeEn;
			}
			else
			{
				GotoState('StakeOut');
				return;
			}
		}

		if (bReadyToAttack)
		{
			Target = Enemy;
			If (VSize(Enemy.Location - Location) <= (MeleeRange + Enemy.CollisionRadius + CollisionRadius))
				GotoState('MeleeAttack');
			else
				GotoState('RangedAttack');
			return;
		}

		GotoState('RangedAttack', 'Challenge');
	}
}

state Charging
{
ignores SeePlayer, HearNoise;

	function AnimEnd()
	{
		If ( bBerserk )
			LoopAnim('Charge', -1.1/GroundSpeed,,0.5);
		else
			PlayCombatMove();
	}

	function Timer()
	{
		if ( bBerserk && bLongBerserk && (FRand() < 0.3) )
		{
			AccelRate = Default.AccelRate;
			GroundSpeed = Default.GroundSpeed;
			bBerserk = false;
		}
		bLongBerserk = bBerserk;

		Super.Timer();
	}

	function BeginState()
	{
		GoBerserk();
		Super.BeginState();
	}

	function EndState()
	{
		if ( bBerserk )
		{
			GroundSpeed = Default.GroundSpeed;
			AccelRate = Default.AccelRate;
		}
		Super.EndState();
	}
}


state RangedAttack
{
ignores SeePlayer, HearNoise, Bump;

	function TweenToFighter(float TweenTime)
	{
		if ( AnimSequence == 'T8' )
			return;
		if ( (GetAnimGroup(AnimSequence) == 'Hit') || (Skill > 3 * FRand()) || (VSize(Location - Target.Location) < 320)  )
			TweenAnim('Fighter', tweentime);
		else
			PlayAnim('T8', 1.0, 0.15);
	}
}


defaultproperties
{
     WhipDamage=20
     footstep=Sound'UnrealShare.Brute.walk1br'
     Footstep2=Sound'UnrealShare.Brute.walk2br'
     PistolWhip=Sound'UnrealShare.Brute.pwhip1br'
     PistolHit=Sound'UnrealShare.Brute.pstlhit1br'
     Die2=Sound'UnrealShare.Brute.death2br'
     CarcassType=Class'UnrealShare.BruteCarcass'
     Aggressiveness=1
     RefireRate=0.3
     WalkingSpeed=0.6
     bHasRangedAttack=True
     bMovingRangedAttack=True
     bLeadTarget=False
     RangedProjectile=Class'TOMA21.TOMABruteProjectile'
     ProjectileSpeed=700
     Acquire=Sound'UnrealShare.Brute.yell1br'
     Fear=Sound'UnrealShare.Brute.injur2br'
     Roam=Sound'UnrealShare.Brute.nearby2br'
     Threaten=Sound'UnrealShare.Brute.yell2br'
     bCanStrafe=True
     MeleeRange=70
     GroundSpeed=140
     WaterSpeed=100
     JumpZ=-1
     Visibility=150
     SightRadius=1500
     Health=340
     ReducedDamageType=exploded
     ReducedDamagePct=0.3
     UnderWaterTime=60
     HitSound1=Sound'UnrealShare.Brute.injur1br'
     HitSound2=Sound'UnrealShare.Brute.injur2br'
     Land=None
     Die=Sound'UnrealShare.Brute.death1br'
     WaterStep=None
     CombatStyle=0.8
     AmbientSound=Sound'UnrealShare.Brute.amb1br'
     DrawType=DT_Mesh
     Mesh=LodMesh'UnrealShare.Brute1'
     TransientSoundVolume=3
     CollisionRadius=52
     CollisionHeight=52
     Mass=400
     Buoyancy=390
     RotationRate=(Pitch=3072,Yaw=45000,Roll=0)
     NameOfMonster="Brute"
	MoneyDroped=400
	sshot1="TOMATex21.Sshot.Brute_01"
	sshot2="TOMATex21.Sshot.Brute_02"
}
