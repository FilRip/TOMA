//=============================================================================
// Manta.
//=============================================================================
class TOMAManta extends TOMAScriptedPawn;

//-----------------------------------------------------------------------------
// Manta variables.

// Attack damage.
var() byte
	StingDamage,	// Basic damage done by Sting.
	WhipDamage;		// Basic damage done by whip.
var bool bAttackBump;
var bool bAvoidHit;
var(Sounds) sound whip;
var(Sounds) sound wingBeat;
var(Sounds) sound sting;

//-----------------------------------------------------------------------------
// Manta functions.

/* PreSetMovement()
default for walking creature.  Re-implement in subclass
for swimming/flying capability
*/

function PreBeginPlay()
{
	Super.PreBeginPlay();
	if ( skill <= 1 )
		Health = 0.6 * Health;
	if ( skill == 0 )
		AttitudeToPlayer = ATTITUDE_Ignore;
}

function PreSetMovement()
{
	MaxDesiredSpeed = 0.6 + 0.13 * skill;
	bCanJump = true;
	bCanWalk = true;
	bCanSwim = true;
	bCanFly = true;
	MinHitWall = -0.6;
	if (Intelligence > BRAINS_Reptile)
		bCanOpenDoors = true;
	if (Intelligence == BRAINS_Human)
		bCanDoSpecial = true;
}

function SetMovementPhysics()
{
	if (Region.Zone.bWaterZone)
		SetPhysics(PHYS_Swimming);
	else
		SetPhysics(PHYS_Flying);
}

function PlayWaiting()
{
	LoopAnim('Waiting', 0.1 + 0.5 * FRand());
}

function PlayPatrolStop()
{
	PlaySound(WingBeat, SLOT_Interact);
	LoopAnim('Fly', 0.4);
}

function PlayWaitingAmbush()
{
	PlayWaiting();
}

function PlayChallenge()
{
	PlayAnim('Fly', 0.4, 0.1);
}

function TweenToFighter(float tweentime)
{
	TweenAnim('Fly', tweentime);
}

function TweenToRunning(float tweentime)
{
	if ( (AnimSequence != 'Fly') || !bAnimLoop )
		TweenAnim('Fly', tweentime);
}

function TweenToWalking(float tweentime)
{
	if ( (AnimSequence != 'Fly') || !bAnimLoop )
		TweenAnim('Fly', tweentime);
}

function TweenToWaiting(float tweentime)
{
	PlayAnim('Landing', 0.2 + 0.8 * FRand());
	SetPhysics(PHYS_Falling);
}

function TweenToPatrolStop(float tweentime)
{
	TweenAnim('Fly', tweentime);
}

function PlayRunning()
{
	PlaySound(WingBeat, SLOT_Interact);
	LoopAnim('Fly', -1.0/AirSpeed,, 0.4);
}

function PlayWalking()
{
	PlaySound(WingBeat, SLOT_Interact);
	LoopAnim('Fly', -1.0/AirSpeed,, 0.4);
}

function PlayThreatening()
{
	if ( FRand() < 0.8 )
	{
		PlaySound(WingBeat, SLOT_Interact);
		PlayAnim('Fly', 0.4);
	}
	else
		LoopAnim('ThreatSting', 0.4);
}

function PlayTurning()
{
	if (FRand() < 0.5)
		TweenAnim('Fighter', 0.2);
	else
	{
		PlaySound(WingBeat, SLOT_Interact);
		LoopAnim('Fly', -1.0/AirSpeed,, 0.4);
	}
}

function PlayDying(name DamageType, vector HitLocation)
{
	PlaySound(Die, SLOT_Talk, 4 * TransientSoundVolume);
	PlayAnim('Death', 0.7, 0.1);
}

function PlayTakeHit(float tweentime, vector HitLoc, int Damage)
{
	TweenAnim('TakeHit', tweentime);
}

function TweenToFalling()
{
	TweenAnim('Fly', 0.2);
}

function PlayInAir()
{
	LoopAnim('Fly');
}

function PlayLanded(float impactVel)
{
	PlayAnim('Landing');
}


function PlayVictoryDance()
{
	PlayAnim('Whip', 0.6, 0.1);
	PlaySound(Threaten, SLOT_Talk);
}

function PlayMeleeAttack()
{
	local vector adjust;
	adjust = vect(0,0,0.8) * Target.CollisionHeight;
	Acceleration = AccelRate * Normal(Target.Location - Location + adjust);
	Enable('Bump');
	bAttackBump = false;
	if (FRand() < 0.5)
		{
		PlayAnim('Sting');
		PlaySound(Sting, SLOT_Interact);
 		}
	else
	{
 		PlayAnim('Whip');
 		PlaySound(Whip, SLOT_Interact);
 	}
 }

state MeleeAttack
{
ignores SeePlayer, HearNoise;

	singular function Bump(actor Other)
	{
		Disable('Bump');
		if (AnimSequence == 'Whip')
			MeleeDamageTarget(WhipDamage, (WhipDamage * 1000.0 * Normal(Target.Location - Location)));
		else if (AnimSequence == 'Sting')
			MeleeDamageTarget(StingDamage, (StingDamage * 1000.0 * Normal(Target.Location - Location)));
		bAttackBump = true;
		Velocity *= -0.5;
		Acceleration *= -1;
		if (Acceleration.Z < 0)
			Acceleration.Z *= -1;
	}

	function KeepAttacking()
	{
		if (Target == None)
			GotoState('Attacking');
		else if ( (Pawn(Target) != None) && (Pawn(Target).Health == 0) )
			GotoState('Attacking');
		else if (bAttackBump)
		{
			SetTimer(TimeBetweenAttacks, false);
			GotoState('TacticalMove', 'NoCharge');
		}
	}
}

state Charging
{
ignores SeePlayer, HearNoise;

	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
							Vector momentum, name damageType)
	{
		Global.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
		if ( health <= 0 )
			return;
		if (NextState == 'TakeHit')
		{
			if (AttitudeTo(Enemy) == ATTITUDE_Fear)
			{
				NextState = 'Retreating';
				NextLabel = 'Begin';
			}
			else if ( (FRand() < 3 * Damage/Default.Health) && ((Damage > 0.5 * Health) || (VSize(Location - Enemy.Location) > 150)) )
			{
				bAvoidHit = true;
				NextState = 'TacticalMove';
				NextLabel = 'NoCharge';
			}
			else
			{
				NextState = 'Charging';
				NextLabel = 'TakeHit';
			}
			GotoState('TakeHit');
		}
	}
}

state TacticalMove
{
ignores SeePlayer, HearNoise;

	function PickDestination(bool bNoCharge)
	{
		local vector pick, pickdir, enemydir,Y, minDest;
		local actor HitActor;
		local vector HitLocation, HitNormal, collSpec;
		local float Aggression, enemydist, minDist, strafeSize, MaxMove;

		if ( bAvoidHit && (FRand() < 0.7) )
			MaxMove = 300;
		else
			MaxMove = 600;

		bAvoidHit = false;
		enemyDist = VSize(Location - Enemy.Location);
		Aggression = 2 * FRand() - 1.0;

		if (enemyDist < CollisionRadius + Enemy.CollisionRadius + 2 * MeleeRange)
			Aggression = FMin(0.0, Aggression);
		else if (enemyDist > FMax(VSize(OldLocation - Enemy.OldLocation), 240))
			Aggression = FMax(0.0, Aggression);

		enemydir = (Enemy.Location - Location)/enemyDist;
		minDist = FMin(160.0, 5*CollisionRadius);
		Y = (enemydir Cross vect(0,0,1));
		strafeSize = FMin(0.8, (2 * Abs(Aggression) * FRand() - 0.2));
		if (Aggression <= 0)
			strafeSize *= -1;
		enemydir = enemydir * strafeSize;
		if (FRand() < 0.8)
			enemydir.Z = 1.5;
		else
			enemydir.Z = FMax(0,enemydir.Z);

		strafeSize = FMax(0.0, 1 - Abs(strafeSize));
		pickdir = strafeSize * Y;
		pick = Location + (pickdir + enemydir) * (minDist + MaxMove * FRand());
		pick.Z = Location.Z + 60 + 0.65 * MaxMove * FRand();
		minDest = Location + minDist * Normal(pick - location);
		collSpec.X = CollisionRadius;
		collSpec.Y = CollisionRadius;
		collSpec.Z = CollisionHeight;

		HitActor = Trace(HitLocation, HitNormal, minDest, Location, false, collSpec);
		if ( HitActor == None )
		{
			Destination = pick;
			return;
		}
		pick = Location + (enemydir - pickdir) * (minDist + MaxMove * FRand());
		pick.Z = Location.Z + 60 + 0.5 * MaxMove * FRand();
		minDest = Location + minDist * Normal(pick - location);
		HitActor = Trace(HitLocation, HitNormal, minDest, Location, false, collSpec);
		if ( HitActor == None )
		{
			Destination = pick;
			return;
		}

		pick = Location - enemydir * (minDist + MaxMove * FRand());
		pick.Z = Location.Z + 0.5 * MaxMove * FRand();
		minDest = Location + Normal(pick - Location) * minDist;
		HitActor = Trace(HitLocation, HitNormal, minDest, Location, false, collSpec);
		if ( HitActor == None )
		{
			Destination = pick;
			return;
		}

		if ( !bNoCharge && (enemyDist > 120) )
			GotoState('Charging');

		pick = MaxMove * FRand() * VRand();
		pick.Z = FMin(Location.Z, pick.Z);
		Destination = pick;
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
     StingDamage=20
     WhipDamage=20
     Whip=Sound'UnrealShare.Manta.whip1m'
     wingBeat=Sound'UnrealShare.Manta.fly1m'
     Sting=Sound'UnrealShare.Manta.sting1m'
     CarcassType=Class'UnrealShare.MantaCarcass'
     Aggressiveness=0.2
     RefireRate=0.5
     WalkingSpeed=0.6
     bIsWuss=True
     Acquire=Sound'UnrealShare.Manta.call1m'
     Fear=Sound'UnrealShare.Manta.injur2m'
     Roam=Sound'UnrealShare.Manta.call2m'
     Threaten=Sound'UnrealShare.Manta.call2m'
     MeleeRange=120
     WaterSpeed=300
     AirSpeed=400
     AccelRate=800
     JumpZ=10
     SightRadius=1500
     Health=78
     UnderWaterTime=-1
     HitSound1=Sound'UnrealShare.Manta.injur1m'
     HitSound2=Sound'UnrealShare.Manta.injur2m'
     Land=Sound'UnrealShare.Manta.land1mt'
     Die=Sound'UnrealShare.Manta.death2m'
     WaterStep=None
     CombatStyle=-0.3
     DrawType=DT_Mesh
     Mesh=LodMesh'UnrealShare.Manta1'
     CollisionRadius=27
     CollisionHeight=12
     Mass=80
     Buoyancy=80
     RotationRate=(Pitch=16384,Yaw=55000,Roll=15000)
     NameOfMonster="Manta"
	sshot1="TOMATex21.Sshot.Manta"
}
