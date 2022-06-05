//=============================================================================
// Tentacle.
//=============================================================================
class TOMATentacle extends TOMAScriptedPawn;

//-----------------------------------------------------------------------------
// Tentacle variables.

// Attack damage.
var() int WhipDamage; // Damage done by whipping.

var(Sounds) sound mebax;
var(Sounds)  sound whip;
var(Sounds) sound Smack;

//-----------------------------------------------------------------------------
// Tentacle functions.

function PostBeginPlay()
{
	Super.PostBeginPlay();
	bLeadTarget = bLeadTarget && (FRand() > 0.5);
}

function WhatToDoNext(name LikelyState, name LikelyLabel)
{
	bQuiet = false;
	GotoState('Roaming');
}

simulated function AddVelocity( vector NewVelocity )
{
	Velocity += NewVelocity;
}

function PreSetMovement()
{
	bCanJump=true;
	bCanWalk=true;
	bCanSwim=true;
	bCanFly=True;
	MinHitWall=-0.6;
	bCanOpenDoors=false;
	bCanDoSpecial=false;
}

function bool CanFireAtEnemy()
{
	local vector HitLocation, HitNormal, EnemyDir, projStart, EnemyUp;
	local actor HitActor;
	local float EnemyDist;

	EnemyDir = Enemy.Location - Location;
	EnemyDist = VSize(EnemyDir);
	EnemyUp = Enemy.CollisionHeight * vect(0,0,0.9);
	if ( EnemyDist > 300 )
	{
		EnemyDir = 300 * EnemyDir/EnemyDist;
		EnemyUp = 300 * EnemyUp/EnemyDist;
	}

	projStart = Location + CollisionHeight * vect(0,0,-1.2);

	HitActor = Trace(HitLocation, HitNormal, projStart + EnemyDir + EnemyUp, projStart, true);

	if ( (HitActor == None) || (HitActor == Enemy)
		|| ((Pawn(HitActor) != None) && (AttitudeTo(Pawn(HitActor)) <= ATTITUDE_Ignore)) )
		return true;

	HitActor = Trace(HitLocation, HitNormal, projStart + EnemyDir, projStart, true);

	return ( (HitActor == None) || (HitActor == Enemy)
			|| ((Pawn(HitActor) != None) && (AttitudeTo(Pawn(HitActor)) <= ATTITUDE_Ignore)) );
}

function SetMovementPhysics()
{
	if (Region.Zone.bWaterZone)
		SetPhysics(PHYS_Swimming);
	else
		SetPhysics(PHYS_FLYING);
}

function Drop()
{
}

singular function Falling()
{
	SetMovementPhysics();
}

function PlayWaiting()
{
	TweenAnim('Hide', 5.0);
}

function PlayPatrolStop()
{
	TweenAnim('Hide', 5.0);
}

function PlayWaitingAmbush()
{
	TweenAnim('Hide', 5.0);
}

function PlayChallenge()
{
	if ( GetAnimGroup(AnimSequence) == 'Hiding')
	{
		PlaySound(Mebax, SLOT_Interact);
		PlayAnim('Uncurl', 0.6, 0.2);
	}
	else
		PlayAnim('Waver', 1.0, 0.1);
}

function TweenToFighter(float tweentime)
{
	if ( GetAnimGroup(AnimSequence) == 'Hiding')
	{
		PlaySound(Mebax, SLOT_Interact);
		PlayAnim('Uncurl', 0.6, 0.2);
	}
	else
		TweenAnim('Waver', tweentime);
}

function TweenToRunning(float tweentime)
{
	if ( GetAnimGroup(AnimSequence) == 'Hiding')
	{
		PlaySound(Mebax, SLOT_Interact);
		PlayAnim('Uncurl', 0.6, 0.2);
	}
	else if ( (AnimSequence != 'Move2') || !bAnimLoop )
		TweenAnim('Move2', tweentime);
}

function TweenToWalking(float tweentime)
{
	if ( GetAnimGroup(AnimSequence) == 'Hiding')
	{
		PlaySound(Mebax, SLOT_Interact);
		PlayAnim('Uncurl', 0.6, 0.2);
	}
	else if ( (AnimSequence != 'Move1') || !bAnimLoop )
		TweenAnim('Move1', tweentime);
}

function TweenToWaiting(float tweentime)
{
	if ( GetAnimGroup(AnimSequence) != 'Hiding')
	{
		PlaySound(Mebax, SLOT_Interact);
		PlayAnim('Curl', 0.6, 0.2);
	}
}

function TweenToPatrolStop(float tweentime)
{
	if ( GetAnimGroup(AnimSequence) == 'Hiding')
	{
		PlaySound(Mebax, SLOT_Interact);
		PlayAnim('Uncurl', 0.6, 0.2);
	}
	else TweenAnim('Waver', tweentime);
}

function PlayRunning()
{
	LoopAnim('Move2', 1.0,, 0.4);
}

function PlayWalking()
{
	LoopAnim('Move1', 1.0,, 0.4);
}

function PlayThreatening()
{
	if ( FRand() < 0.8 )
		PlayAnim('Waver', 0.4);
	else
		PlayAnim('Smack', 0.4);
}

function PlayTurning()
{
	if ( GetAnimGroup(AnimSequence) == 'Hiding')
	{
		PlaySound(Mebax, SLOT_Interact);
		PlayAnim('Uncurl', 0.6, 0.2);
	}
	else
		LoopAnim('Waver');
}

function PlayDying(name DamageType, vector HitLocation)
{
	PlaySound(Die, SLOT_Talk, 3 * TransientSoundVolume);
	if ( Velocity.Z > 200 )
		PlayAnim('Dead2', 0.7, 0.1);
	else
	{
		PlayAnim('Dead1', 0.7, 0.1);
		SetPhysics(PHYS_None);
	}
}

function PlayTakeHit(float tweentime, vector HitLoc, int Damage)
{
	TweenAnim('TakeHit', tweentime);
}

function TweenToFalling()
{
	TweenAnim('Waver', 0.2);
}

function PlayInAir()
{
	LoopAnim('Waver');
}

function PlayLanded(float impactVel)
{
	PlayAnim('Waver');
}


function PlayVictoryDance()
{
	PlaySound(whip, SLOT_Interact);
	PlayAnim('Smack', 0.6, 0.1);
}

function PlayMeleeAttack()
{
	PlaySound(whip, SLOT_Interact);
	PlayAnim('Smack');
}

function SmackTarget()
{
	if ( MeleeDamageTarget(WhipDamage, (WhipDamage * 1000 * Normal(Target.Location - Location))) )
		PlaySound(Smack, SLOT_Interact);
}

function PlayRangedAttack()
{
	local vector projStart;

	MakeNoise(1.0);
	projStart = Location + CollisionHeight * vect(0,0,-1.2);
	spawn(RangedProjectile ,self,'',projStart,AdjustAim(ProjectileSpeed, projStart, 900, bLeadTarget, bWarnTarget));
	PlayAnim('Shoot');
}


state Attacking
{
ignores SeePlayer, HearNoise, Bump, HitWall;

	function ChooseAttackMode()
	{
		if (Physics == PHYS_Swimming)
		{
			Super.ChooseAttackMode();
			return;
		}

		if ((Enemy == None) || (Enemy.Health <= 0))
		{
			 GotoState('Roaming');
			 return;
		}

		if (!LineOfSightTo(Enemy))
			GotoState('StakeOut');
		else
			GotoState('RangedAttack');
	}
}

state StakeOut
{
ignores EnemyNotVisible;

	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
							Vector momentum, name damageType)
	{
		Global.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
		if ( health <= 0 )
			return;
		if (NextState == 'TakeHit')
		{
			NextState = 'Attacking';
			NextLabel = 'Begin';
			GotoState('TakeHit');
		}
	}

Begin:
	PlayChallenge();
	TurnTo(LastSeenPos);
HangOut:
	if ( bHasRangedAttack && bClearShot && (FRand() < 0.5) && (VSize(Enemy.Location - LastSeenPos) < 100) && CanStakeOut() )
		PlayRangedAttack();
	FinishAnim();
	PlayChallenge();
	Sleep(1 + FRand());
	if ( FRand() < 0.8 )
		GotoState('Roaming');
	else
		LoopAnim('Waver');
	Goto('HangOut');
}

state Acquisition
{

PlayOut:
	FinishAnim();

Begin:
	PlayTurning();
	FinishAnim();
	GotoState('Attacking');
}

function bool SetEnemy( Pawn NewEnemy )
{
	local bool result;

	bCanWalk=true;
	result=SetEnemyNewOne(NewEnemy);
	bCanWalk=false;
	return result;
}

function bool SetEnemyNewOne(Pawn NewEnemy)
{
	local bool result;
	local eAttitude newAttitude, oldAttitude;
	local bool noOldEnemy;
	local float newStrength;

	if (NewEnemy==None)
		return false;
	if (NewEnemy.PlayerReplicationInfo==None) return false;
	if ((!NewEnemy.IsA('TOMABot')) && (!NewEnemy.IsA('TOMAPlayer')))
		return false;
	if ((NewEnemy==Self) || (NewEnemy.Health<=0))
		return false;
	if (NewEnemy.IsInState('PlayerWaiting')) return false;
	if (NewEnemy.PlayerReplicationInfo.Team==self.PlayerReplicationInfo.Team) return false;
	if ( !bCanWalk && !bCanFly && !NewEnemy.FootRegion.Zone.bWaterZone )
		return false;

    if ((TOMABot(NewEnemy)!=None) && (TOMABot(NewEnemy).CptIAR>0)) return false;
    if ((TOMAPlayer(NewEnemy)!=None) && (TOMAPlayer(NewEnemy).CptIAR>0)) return false;

	noOldEnemy=(Enemy==None);
	result=false;
	newAttitude=AttitudeTo(NewEnemy);
	if (!noOldEnemy)
	{
		if (Enemy==NewEnemy)
			return true;
		else if ( NewEnemy.bIsPlayer && (AlarmTag != '') )
		{
			OldEnemy = Enemy;
			Enemy = NewEnemy;
			result = true;
		}
		else if ( newAttitude == ATTITUDE_Friendly )
		{
			if ( bIgnoreFriends )
				return false;
			if ( (NewEnemy.Enemy != None) && (NewEnemy.Enemy.Health > 0) )
			{
				if ( NewEnemy.Enemy.bIsPlayer && (NewEnemy.AttitudeToPlayer < AttitudeToPlayer) )
					AttitudeToPlayer = NewEnemy.AttitudeToPlayer;
				if ( AttitudeTo(NewEnemy.Enemy) < AttitudeTo(Enemy) )
				{
					OldEnemy = Enemy;
					Enemy = NewEnemy.Enemy;
					result = true;
				}
			}
		}
		else
		{
			oldAttitude = AttitudeTo(Enemy);
			if ( (newAttitude < oldAttitude) ||
				( (newAttitude == oldAttitude)
					&& ((VSize(NewEnemy.Location - Location) < VSize(Enemy.Location - Location))
						|| !LineOfSightTo(Enemy)) ) )
			{
				if ( bIsPlayer && Enemy.IsA('PlayerPawn') && !NewEnemy.IsA('PlayerPawn') )
				{
					newStrength = relativeStrength(NewEnemy);
					if ( (newStrength < 0.2) && (relativeStrength(Enemy) < FMin(0, newStrength))
						&& (IsInState('Hunting')) && (Level.TimeSeconds - HuntStartTime < 5) )
						result = false;
					else
					{
						result = true;
						OldEnemy = Enemy;
						Enemy = NewEnemy;
					}
				}
				else
				{
					result = true;
					OldEnemy = Enemy;
					Enemy = NewEnemy;
				}
			}
		}
	}
	else if ( newAttitude < ATTITUDE_Ignore )
	{
		result = true;
		Enemy = NewEnemy;
	}
	else if ( newAttitude == ATTITUDE_Friendly ) //your enemy is my enemy
	{
		if ( NewEnemy.bIsPlayer && (AlarmTag != '') )
		{
			Enemy = NewEnemy;
			result = true;
		}
		if (bIgnoreFriends)
			return false;

		if ( (NewEnemy.Enemy != None) && (NewEnemy.Enemy.Health > 0) )
		{
			result = true;
			Enemy = NewEnemy.Enemy;
			if (Enemy.bIsPlayer)
				AttitudeToPlayer = ScriptedPawn(NewEnemy).AttitudeToPlayer;
			else if ( (ScriptedPawn(NewEnemy) != None) && (ScriptedPawn(NewEnemy).Hated == Enemy) )
				Hated = Enemy;
		}
	}

	if ( result )
	{
		LastSeenPos = Enemy.Location;
		LastSeeingPos = Location;
		EnemyAcquired();
		if ( !bFirstHatePlayer && Enemy.bIsPlayer && (FirstHatePlayerEvent != '') )
			TriggerFirstHate();
	}
	else if ( NewEnemy.bIsPlayer && (NewAttitude < ATTITUDE_Threaten) )
		OldEnemy = NewEnemy;

	return result;
}

defaultproperties
{
     mebax=Sound'UnrealShare.Tentacle.curltn'
     Whip=Sound'UnrealShare.Tentacle.strike2tn'
     Smack=Sound'UnrealShare.Tentacle.splat2tn'
     CarcassType=Class'UnrealShare.TentacleCarcass'
     Aggressiveness=1
     RefireRate=0.1
     bHasRangedAttack=True
     bMovingRangedAttack=True
     bLeadTarget=False
     RangedProjectile=Class'UnrealShare.TentacleProjectile'
     Acquire=Sound'UnrealShare.Tentacle.yell1tn'
     Fear=Sound'UnrealShare.Tentacle.injured2tn'
     Roam=Sound'UnrealShare.Tentacle.waver1tn'
     Threaten=Sound'UnrealShare.Tentacle.yell2tn'
     MeleeRange=70
     WaterSpeed=100
     AccelRate=100
     JumpZ=10
     SightRadius=1000
     PeripheralVision=-2
     HearingThreshold=10
     Health=100
     UnderWaterTime=-1
     HitSound1=Sound'UnrealShare.Tentacle.injured1tn'
     HitSound2=Sound'UnrealShare.Tentacle.injured2tn'
     Land=Sound'UnrealShare.Tentacle.splat2tn'
     Die=Sound'UnrealShare.Tentacle.death2tn'
     DrawType=DT_Mesh
     Mesh=LodMesh'UnrealShare.Tentacle1'
     CollisionRadius=28
     CollisionHeight=36
     Mass=200
     Buoyancy=400
     RotationRate=(Pitch=0,Yaw=30000,Roll=0)
     NameOfMonster="Tentacle"
     bCanStrafe=True
	sshot1="TOMATex21.Sshot.Tentacle"
}
