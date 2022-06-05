//=============================================================================
// DevilFish.
//=============================================================================
class TOMADevilFish extends TOMAScriptedPawn;

//-----------------------------------------------------------------------------
// RazorFish variables.

// Attack damage.
var() byte
	BiteDamage,		// Basic damage done by bite.
	RipDamage;
var bool bAttackBump;
var(Sounds) sound bite;
var(Sounds) sound rip;
var float	AirTime;

//-----------------------------------------------------------------------------
// RazorFish functions.

function WhatToDoNext(name LikelyState, name LikelyLabel)
{
	bStasis = true;
	Super.WhatToDoNext(LikelyState, LikelyLabel);
}

function ZoneChange(ZoneInfo newZone)
{
	local vector start, checkpoint, HitNormal, HitLocation;
	local actor HitActor;

	if ( newZone.bWaterZone )
	{
		AirTime = 0;
		setPhysics(PHYS_Swimming);
	}
	else
	{
		SetPhysics(PHYS_Falling);
		MoveTimer = -1.0;
	}
}

function Landed(vector HitNormal)
{
	GotoState('Flopping');
	Landed(HitNormal);
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
	LoopAnim('Swimming', 0.1 + 0.3 * FRand());
}

function PlayPatrolStop()
{
	LoopAnim('Swimming', 0.1 + 0.3 * FRand());
}

function PlayWaitingAmbush()
{
	LoopAnim('Swimming', 0.1 + 0.3 * FRand());
}

function TweenToFighter(float tweentime)
{
	TweenAnim('Fighter', tweentime);
}

function TweenToRunning(float tweentime)
{
	if ( (AnimSequence != 'Swimming') || !bAnimLoop )
		TweenAnim('Swimming', tweentime);
}

function TweenToWalking(float tweentime)
{
	if ( (AnimSequence != 'Swimming') || !bAnimLoop )
		TweenAnim('Swimming', tweentime);
}

function TweenToWaiting(float tweentime)
{
	PlayAnim('Swimming', 0.2 + 0.8 * FRand());
}

function TweenToPatrolStop(float tweentime)
{
	TweenAnim('Swimming', tweentime);
}

function PlayRunning()
{
	LoopAnim('Swimming', -0.8/WaterSpeed,, 0.4);
}

function PlayWalking()
{
	LoopAnim('Swimming', -0.8/WaterSpeed,, 0.4);
}

function PlayThreatening()
{
	if ( FRand() < 0.5 )
		PlayAnim('Swimming', 0.4);
	else
		PlayAnim('Fighter', 0.4);
}

function PlayTurning()
{
	LoopAnim('Swimming', 0.8);
}

function PlayDying(name DamageType, vector HitLocation)
{
	if ( Region.Zone.bWaterZone )
	{
		PlaySound(Die, SLOT_Talk, 4 * TransientSoundVolume);
		PlayAnim('Dead1', 0.7, 0.1);
	}
	else
		TweenAnim('Breathing', 0.35);
}

function PlayTakeHit(float tweentime, vector HitLoc, int damage)
{
	TweenAnim('TakeHit', tweentime);
}

function TweenToFalling()
{
	TweenAnim('Flopping', 0.2);
}

function PlayInAir()
{
	LoopAnim('Flopping', 0.7);
}

function PlayLanded(float impactVel)
{
	TweenAnim('breathing', 0.2);
}


function PlayVictoryDance()
{
	PlayAnim('ripper', 0.6, 0.1);
}

function PlayMeleeAttack()
{
	local vector adjust;
	local float decision;
	adjust = vect(0,0,0.5) * FRand() * Target.CollisionHeight;
	Acceleration = AccelRate * Normal(Target.Location - Location + adjust);
	bAttackBump = false;
	if (AnimSequence == 'Grab1')
	{
		PlayAnim('ripper', 0.5 + 0.5 * FRand());
		PlaySound(rip,SLOT_Interact,,,500);
		MeleeDamageTarget(RipDamage, vect(0,0,0));
		Disable('Bump');
		return;
	}
	decision = FRand();
	PlaySound(bite,SLOT_Interact,,,500);
	if (decision < 0.3)
	{
		Disable('Bump');
		PlayAnim('Grab1', 0.3);
		return;
	}

	Enable('Bump');
	if (decision < 0.55)
	{
		PlayAnim('Bite1', 0.3);
	}
	else if (decision < 0.8)
	{
 		PlayAnim('Bite2', 0.3);
 	}
 	else
 	{
 		PlayAnim('Bite3', 0.3);
 	}
}

state Waiting
{
	function Landed(vector HitNormal)
	{
		GotoState('Flopping');
		Landed(HitNormal);
	}
}

state TakeHit
{
ignores seeplayer, hearnoise, bump, hitwall;

	function Landed(vector HitNormal)
	{
		GotoState('Flopping');
		Landed(HitNormal);
	}
}

state FallingState
{
ignores Bump, Hitwall, HearNoise, WarnTarget;

	function Landed(vector HitNormal)
	{
		GotoState('Flopping');
		Landed(HitNormal);
	}
}

state Ambushing
{
	function Landed(vector HitNormal)
	{
		GotoState('Flopping');
		Landed(HitNormal);
	}
}

state MeleeAttack
{
ignores SeePlayer, HearNoise;

	singular function Bump(actor Other)
	{
		Disable('Bump');
		if ( (AnimSequence == 'Bite1') || (AnimSequence == 'Bite2') || (AnimSequence == 'Bite3') )
			MeleeDamageTarget(BiteDamage, (BiteDamage * 1000.0 * Normal(Target.Location - Location)));
		else
			return;
		bAttackBump = true;
		Velocity *= -0.5;
		Acceleration *= -1;
		if (Acceleration.Z < 0)
			Acceleration.Z *= -1;
	}

	function KeepAttacking()
	{
		if ( (Target == None) ||
			((Pawn(Target) != None) && (Pawn(Target).Health == 0)) )
			GotoState('Attacking');
		else if ( bAttackBump && (FRand() < 0.5) )
		{
			SetTimer(TimeBetweenAttacks, false);
			GotoState('TacticalMove', 'NoCharge');
		}
	}
}


State Flopping
{
ignores seeplayer, hearnoise, enemynotvisible, hitwall;

	function Timer()
	{
		AirTime += 1;
		if ( AirTime > 25 + 15 * FRand() )
		{
			Health = -1;
			Died(None, 'suffocated', Location);
			return;
		}
		SetPhysics(PHYS_Falling);
		Velocity = 200 * VRand();
		Velocity.Z = 170 + 200 * FRand();
		DesiredRotation.Pitch = Rand(8192) - 4096;
		DesiredRotation.Yaw = Rand(65535);
		TweenAnim('Flopping', 0.1);
	}

	function ZoneChange( ZoneInfo NewZone )
	{
		local rotator newRotation;
		if (NewZone.bWaterZone)
		{
			newRotation = Rotation;
			newRotation.Roll = 0;
			SetRotation(newRotation);
			SetPhysics(PHYS_Swimming);
			AirTime = 0;
			GotoState('Attacking');
		}
		else
			SetPhysics(PHYS_Falling);
	}

	function Landed(vector HitNormal)
	{
		local rotator newRotation;
		SetPhysics(PHYS_None);
		SetTimer(0.3 + 0.3 * AirTime * FRand(), false);
		newRotation = Rotation;
		newRotation.Pitch = 0;
		newRotation.Roll = Rand(16384) - 8192;
		DesiredRotation.Pitch = 0;
		SetRotation(newRotation);
		PlaySound(land,SLOT_Interact,,,400);
		TweenAnim('Breathing', 0.3);
	}

	function AnimEnd()
	{
		if (Physics == PHYS_None)
		{
			if (AnimSequence == 'Breathing')
			{
				PlaySound(sound'breath1fs',SLOT_Interact,,,300);
				PlayAnim('Breathing');
			}
			else
				TweenAnim('Breathing', 0.2);
		}
		else
			PlayAnim('Flopping', 0.7);
	}
}


state TacticalMove
{
	function PickDestination(bool bNoCharge)
	{
		local vector pick, pickdir, enemydir,Y, minDest;
		local float Aggression, enemydist, minDist, strafeSize;
		local bool success;

		success = false;
		enemyDist = VSize(Location - Enemy.Location);
		Aggression = 2 * (CombatStyle + FRand()) - 1.0;

		if (enemyDist < CollisionRadius + Enemy.CollisionRadius + MeleeRange)
			Aggression -= 1;
		else if (enemyDist > FMax(VSize(OldLocation - Enemy.OldLocation), 240))
			Aggression += 0.4 * FRand();

		enemydir = (Enemy.Location - Location)/enemyDist;
		if ( !enemy.Region.Zone.bWaterZone )
			enemydir.Z *= 0.5;
		minDist = FMin(160.0, 3*CollisionRadius);

		Y = (enemydir Cross vect(0,0,1));

		strafeSize = FMin(1.0, (2 * Abs(Aggression) * FRand() - 0.2));
		if (Aggression < 0)
			strafeSize *= -1;
		enemydir = enemydir * strafeSize;
		enemydir.Z = FMax(0,enemydir.Z);
		strafeSize = FMax(0.0, 1 - Abs(strafeSize));
		pickdir = strafeSize * Y;
		pick = Location + (pickdir + enemydir) * (minDist + 500 * FRand());
		minDest = Location + minDist * (pickdir + enemydir);
		if (pointReachable(minDest))
		{
			success = true;
			Destination = pick;
		}

		if (!success)
		{
			pick = Location + (enemydir - pickdir) * (minDist + 500 * FRand());
			pick.Z = Location.Z;
			minDest = Location + minDist * (enemydir - pickdir);
			if (pointReachable(minDest))
			{
				success = true;
				Destination = pick;
			}
		}

		if (!success)
		{
			pick = Location - enemydir * (minDist + 500 * FRand());
			pick.Z = Location.Z + 200 * FRand() - 100;
		}
	}


	function Bump(Actor Other)
	{
		Disable('Bump');
		if (bAttackBump == true)
			bAttackBump = false;
		else if (Other == Enemy)
		{
			bReadyToAttack = true;
			Target = Enemy;
			GotoState('MeleeAttack');
		}
		else if (Enemy.Health <= 0)
			GotoState('Attacking');
	}
}

defaultproperties
{
     BiteDamage=15
     RipDamage=25
     rip=Sound'UnrealShare.Razorfish.tear1fs'
     CarcassType=Class'UnrealShare.DevilfishCarcass'
     TimeBetweenAttacks=0.5
     Aggressiveness=1
     MeleeRange=40
     WaterSpeed=250
     Visibility=120
     SightRadius=1250
     Health=170
     UnderWaterTime=-1
     HitSound1=Sound'UnrealShare.Razorfish.chomp1fs'
     HitSound2=Sound'UnrealShare.Razorfish.miss1fs'
     Land=Sound'UnrealShare.Razorfish.flop1fs'
     Die=Sound'UnrealShare.Razorfish.death1fs'
     CombatStyle=1
     AmbientSound=Sound'UnrealShare.Razorfish.ambfs'
     DrawType=DT_Mesh
     Mesh=LodMesh'UnrealShare.fish'
     CollisionRadius=35
     CollisionHeight=20
     Mass=60
     Buoyancy=60
     RotationRate=(Pitch=8192,Roll=8192)
     NameOfMonster="DevilFish"
	MoneyDroped=50
	sshot1="TOMATex21.Sshot.DevilFish"
}
