//=============================================================================
// Nali.
//=============================================================================
class TOMANali extends TOMAScriptedPawn config(TOMA);

//====================================================================
// Nali Variables

var() bool bNeverBow;
var bool bCringing;
var bool bGesture;
var bool bFading;
var bool bHasWandered;
var(Sounds) sound syllable1;
var(Sounds) sound syllable2;
var(Sounds) sound syllable3;
var(Sounds) sound syllable4;
var(Sounds) sound syllable5;
var(Sounds) sound syllable6;
var(Sounds) sound urgefollow;
var(Sounds) sound cringe;
var(Sounds) sound cough;
var(Sounds) sound sweat;
var(Sounds) sound bowing;
var(Sounds) sound backup;
var(Sounds) sound pray;
var(Sounds) sound breath;
var() Weapon Tool;
var int cptbe;
var() int TimeToShockWave;

function PostBeginPlay()
{
	Super.PostBeginPlay();
	bCanSpeak = true;
	if ( Orders == 'Ambushing' )
		AnimSequence = 'Levitate';
}

function bool SetEnemy(Pawn NewEnemy)
{
}

function SpeakPrayer()
{
	PlaySound(Pray);
}


function PlayFearSound()
{
	if ( (Threaten != None) && (FRand() < 0.4) )
	{
		PlaySound(Threaten, SLOT_Talk,, true);
		return;
	}
	if (Fear != None)
		PlaySound(Fear, SLOT_Talk,, true);
}

function bool AdjustHitLocation(out vector HitLocation, vector TraceDir)
{
	local float adjZ, maxZ;

	TraceDir = Normal(TraceDir);
	HitLocation = HitLocation + 0.5 * CollisionRadius * TraceDir;

	if ( (GetAnimGroup(AnimSequence) == 'Ducking') && (AnimFrame > -0.03) )
	{
		if ( AnimSequence == 'Bowing' )
			maxZ = Location.Z - 0.2 * CollisionHeight;
		else
			maxZ = Location.Z + 0.25 * CollisionHeight;
		if ( HitLocation.Z > maxZ )
		{
			if ( TraceDir.Z >= 0 )
				return false;
			adjZ = (maxZ - HitLocation.Z)/TraceDir.Z;
			HitLocation.Z = maxZ;
			HitLocation.X = HitLocation.X + TraceDir.X * adjZ;
			HitLocation.Y = HitLocation.Y + TraceDir.Y * adjZ;
			if ( VSize(HitLocation - Location) > CollisionRadius )
				return false;
		}
	}
	return true;
}

function Killed(pawn Killer, pawn Other, name damageType)
{
	if (Other!=None)
		if (TOMANali(Other)!=None)
			if (Killer!=None)
				if (Killer.bIsPlayer)
					AttitudeToPlayer = ATTITUDE_Fear;
	Super.Killed(Killer, Other, damageType);
}

function eAttitude AttitudeWithFear()
{
	return ATTITUDE_Ignore;
}

function damageAttitudeTo(pawn Other)
{
	local eAttitude OldAttitude;

	if ( (Other == Self) || (Other == None) || (FlockPawn(Other) != None) )
		return;
}

function Step()
{
	PlaySound(sound'WalkC', SLOT_Interact,0.5,,500);
}

function PlayWaiting()
{
	local float decision;
	local float animspeed;

	if (Region.Zone.bWaterZone)
	{
		PlaySwimming();
		return;
	}

	animspeed = 0.4 + 0.6 * FRand();
	decision = FRand();
	if ( AnimSequence == 'Breath' )
	{
		if (!bQuiet && (decision < 0.12) )
		{
			PlaySound(Cough,Slot_Talk,1.0,,800);
			LoopAnim('Cough', 0.85);
			return;
		}
		else if (decision < 0.24)
		{
			PlaySound(Sweat,Slot_Talk,0.3,,300);
			LoopAnim('Sweat', animspeed);
			return;
		}
		else if (!bQuiet && (decision < 0.34) )
		{
			PlayAnim('Pray', animspeed, 0.3);
			return;
		}
	}
	else if ( AnimSequence == 'Pray' )
	{
		if (decision < 0.3)
			PlayAnim('Breath', animspeed, 0.3);
		else
		{
			SpeakPrayer();
			PlayAnim('Pray', animspeed);
		}
		return;
	}

	PlaySound(Breath,SLOT_Talk,0.5,true,500,animspeed * 1.5);
 	LoopAnim('Breath', animspeed);
}

function PlayPatrolStop()
{
	PlayWaiting();
}

function PlayWaitingAmbush()
{
	if (Region.Zone.bWaterZone)
	{
		PlaySwimming();
		return;
	}

	LoopAnim('Levitate', 0.4 + 0.3 * FRand());
}

function PlayDive()
{
	TweenToSwimming(0.2);
}

function TweenToFighter(float tweentime)
{
	if (Region.Zone.bWaterZone)
		TweenToSwimming(tweentime);
	else if (AnimSequence == 'Bowing')
		PlayAnim('GetUp', 0.4, 0.15);
	else
		TweenAnim('Fighter', tweentime);
}

function TweenToRunning(float tweentime)
{
	if (Region.Zone.bWaterZone)
		TweenToSwimming(tweentime);
	else if ( ((AnimSequence != 'Run') && (AnimSequence != 'RunFire')) || !bAnimLoop)
	{
		if (AnimSequence == 'Bowing')
			PlayAnim('GetUp', 0.4, 0.15);
		else
			TweenAnim('Run', tweentime);
	}
}

function TweenToWalking(float tweentime)
{
	if (Region.Zone.bWaterZone)
		TweenToSwimming(tweentime);
	else if (AnimSequence == 'Bowing')
		PlayAnim('GetUp', 0.4, 0.15);
	else if ( Weapon != None )
		TweenAnim('WalkTool', tweentime);
	else
		TweenAnim('Walk', tweentime);
}

function TweenToWaiting(float tweentime)
{
	if (Region.Zone.bWaterZone)
		TweenToSwimming(tweentime);
	else if (AnimSequence == 'Bowing')
		PlayAnim('GetUp', 0.4, 0.15);
	else
		TweenAnim('Breath', tweentime);
}

function TweenToPatrolStop(float tweentime)
{
	if (Region.Zone.bWaterZone)
		TweenToSwimming(tweentime);
	else if (AnimSequence == 'Bowing')
		PlayAnim('GetUp', 0.4, 0.15);
	else if ( IsInState('Guarding'))
		TweenAnim('Pray', tweentime);
	else
		TweenAnim('Breath', tweentime);
}

function PlayRunning()
{
	if (Region.Zone.bWaterZone)
	{
		PlaySwimming();
		return;
	}
	LoopAnim('Run', -1.0/GroundSpeed,,0.4);
}

function PlayCombatMove()
{
	if (Region.Zone.bWaterZone)
	{
		PlaySwimming();
		return;
	}
	LoopAnim('Walk', -1.3/GroundSpeed,,0.4);
}

function PlayWalking()
{
	if (Region.Zone.bWaterZone)
	{
		PlaySwimming();
		return;
	}
	if ( Weapon != None )
		LoopAnim('WalkTool', -3/GroundSpeed,,0.4);
	else
		LoopAnim('Walk', -3/GroundSpeed,,0.4);
}

function PlayThreatening()
{
	if (Region.Zone.bWaterZone)
	{
		PlaySwimming();
		return;
	}
	Acceleration = vect(0,0,0);
	if (AnimSequence == 'Backup')
	{
		PlaySound(Cringe, SLOT_Talk);
		LoopAnim('Cringe', 0.4 + 0.7 * FRand(), 0.4);
	}
	else if (AnimSequence == 'Cringe')
	{
		if ( FRand() < 0.6 )
			PlaySound(Cringe, SLOT_Talk);
		LoopAnim('Cringe', 0.4 + 0.7 * FRand());
	}
	else if (AnimSequence == 'Bowing')
	{
		PlaySound(Bowing, SLOT_Talk);
		LoopAnim('Bowing', 0.4 + 0.7 * FRand());
	}
	else if (FRand() < 0.4)
		LoopAnim('Bowing', 0.4 + 0.7 * FRand(), 0.5);
}

function PlayRetreating()
{
	if (Region.Zone.bWaterZone)
	{
		PlaySwimming();
		return;
	}
	bAvoidLedges = true;
	PlaySound(Backup, SLOT_Talk);
	DesiredRotation = Rotator(Enemy.Location - Location);
	DesiredSpeed = WalkingSpeed;
	Acceleration = AccelRate * Normal(Location - Enemy.Location);
	LoopAnim('Backup');
}

function PlayTurning()
{
	TweenAnim('Walk', 0.3);
}

function PlayDying(name DamageType, vector HitLoc)
{
	//first check for head hit
	if ( ((DamageType == 'Decapitated') || (HitLoc.Z - Location.Z > 0.5 * CollisionHeight))
		 && !Level.Game.bVeryLowGore )
	{
		PlayHeadDeath(DamageType);
		return;
	}
	Super.PlayDying(DamageType, HitLoc);
}

function PlayHeadDeath(name DamageType)
{
	local carcass carc;

	carc = Spawn(class 'CreatureChunks',,, Location + CollisionHeight * vect(0,0,0.8), Rotation + rot(3000,0,16384) );
	if (carc != None)
	{
		carc.Mesh = mesh'NaliHead';
		carc.Initfor(self);
		carc.Velocity = Velocity + VSize(Velocity) * VRand();
		carc.Velocity.Z = FMax(carc.Velocity.Z, Velocity.Z);
	}
	PlaySound(sound'Death2n', SLOT_Talk, 4 * TransientSoundVolume);
	PlayAnim('Dead3',0.5, 0.1);
}

function PlayBigDeath(name DamageType)
{
	PlaySound(Die, SLOT_Talk, 4 * TransientSoundVolume);
	PlayAnim('Dead4',0.7, 0.1);
}

function PlayLeftDeath(name DamageType)
{
	PlaySound(sound'Death2n', SLOT_Talk, 4 * TransientSoundVolume);
	PlayAnim('Dead',0.7, 0.1);
}

function PlayRightDeath(name DamageType)
{
	PlaySound(Die, SLOT_Talk, 4 * TransientSoundVolume);
	PlayAnim('Dead2',0.7, 0.1);
}

function PlayGutDeath(name DamageType)
{
	PlaySound(Die, SLOT_Talk, 4 * TransientSoundVolume);
	if ( FRand() < 0.5 )
		PlayAnim('Dead2',0.7, 0.1);
	else
		PlayAnim('Dead',0.7, 0.1);
}

function PlayLanded(float impactVel)
{
	TweenAnim('Landed', 0.1);
}

function PlayVictoryDance()
{
	PlaySound(Sweat, SLOT_Talk);
	PlayAnim('Sweat', 1.0, 0.1);
}

function PlayMeleeAttack()
{
	if (Region.Zone.bWaterZone)
	{
		PlaySwimming();
		return;
	}
	PlayThreatening();
}

function PlayRangedAttack()
{
	if (Region.Zone.bWaterZone)
	{
		PlaySwimming();
		return;
	}
	PlayThreatening();
}

function PlaySwimming()
{
	Acceleration = WaterSpeed * VRand();
	Velocity = Acceleration;
	SetPhysics(PHYS_Falling);
	LoopAnim('Drowning', 0.5 + 0.9 * FRand());
}

function TweenToSwimming(float TweenTime)
{
	TweenAnim('Drowning', TweenTime);
}

state TriggerAlarm
{
	ignores HearNoise, SeePlayer;

	function Bump(actor Other)
	{
		Super.Bump(Other);
	}
}

state AlarmPaused
{
	ignores HearNoise, Bump;

	function PlayWaiting()
	{
		if ( !bGesture || (FRand() < 0.3) ) //pick first waiting animation
		{
			bGesture = true;
			PlaySound(UrgeFollow, SLOT_Talk);
			NextAnim = 'Follow';
 			LoopAnim(NextAnim, 0.4 + 0.6 * FRand());
		}
		else
			Global.PlayWaiting();
	}

	function PlayWaitAround()
	{
		if ( (AnimSequence == 'Bowing') || (AnimSequence == 'GetDown') )
			PlayAnim('Bowing', 0.75, 0.1);
		else
			PlayAnim('GetDown', 0.7, 0.25);
	}

	function BeginState()
	{
		bGesture = false;
		Super.BeginState();
	}
}

state Guarding
{
	function PlayPatrolStop()
	{
		local float decision;
		local float animspeed;
		animspeed = 0.2 + 0.6 * FRand();
		decision = FRand();

		if ( AnimSequence == 'Breath' )
		{
			if (!bQuiet && (decision < 0.12) )
			{
				PlaySound(Cough,Slot_Talk,1.0,,800);
				LoopAnim('Cough', 0.85);
				return;
			}
			else if (decision < 0.24)
			{
				PlaySound(Sweat,Slot_Talk,0.3,,300);
				LoopAnim('Sweat', animspeed);
				return;
			}
			else if (!bQuiet && (decision < 0.65) )
			{
				PlayAnim('Pray', animspeed, 0.3);
				return;
			}
			else if ( decision < 0.8 )
			{
				PlayAnim('GetDown', 0.4, 0.1);
				return;
			}
		}
		else if ( AnimSequence == 'Pray' )
		{
			if (decision < 0.2)
				PlayAnim('Breath', animspeed, 0.3);
			else if ( decision < 0.35 )
				PlayAnim('GetDown', 0.4, 0.1);
			else
			{
				SpeakPrayer();
				PlayAnim('Pray', animspeed);
			}
			return;
		}
		else if ( AnimSequence == 'GetDown')
		{
			PlaySound(Bowing, SLOT_Talk);
			LoopAnim('Bowing', animspeed, 0.1);
			return;
		}
		else if ( AnimSequence == 'GetUp' )
			PlayAnim('Pray', animspeed, 0.1);
		else if ( AnimSequence == 'Bowing' )
		{
			if ( decision < 0.15 )
				PlayAnim('GetUp', 0.4);
			else
			{
				PlaySound(Bowing, SLOT_Talk);
				LoopAnim('Bowing', animspeed);
			}
			return;
		}
		PlaySound(Breath,SLOT_Talk,0.5,true,500,animspeed * 1.5);
 		LoopAnim('Breath', animspeed);
	}
}

state FadeOut
{
	ignores HitWall, EnemyNotVisible, HearNoise, SeePlayer;

	function TakeDamage(int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, name damageType)
	{
		Global.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
		if (health<=0)
			return;
		if (NextState=='TakeHit')
		{
			NextState='Attacking';
			NextLabel='Begin';
			GotoState('TakeHit');
		}
		else if (Enemy!=None)
			GotoState('Attacking');
	}

	function Tick(float DeltaTime)
	{
	}

	function BeginState()
	{
		bFading = false;
		Disable('Tick');
	}

	function EndState()
	{
		bUnlit = false;
		Style = STY_Normal;
		ScaleGlow = 1.0;
		fatness = Default.fatness;
	}

	function Timer()
	{
		cptbe++;
		if (cptbe>=TimeToShockWave)
		{
			Spawn(class'TOMAShockWave',,,self.location);
			cptbe=0;
		}
		GotoState('Roaming');
	}
Begin:
	Acceleration = Vect(0,0,0);
	if ( NearWall(100) )
	{
		PlayTurning();
		TurnTo(Focus);
	}
	Enable('Tick');
	PlayAnim('Levitate', 0.3, 1.0);
	FinishAnim();
	PlayAnim('Levitate', 0.3);
	FinishAnim();
	LoopAnim('Levitate', 0.3);
	SetTimer(1,true);
}

state Roaming
{
	ignores EnemyNotVisible;

	function PickDestination()
	{
		if ( bHasWandered && (FRand() < 0.1) )
			GotoState('FadeOut');
		else
			Super.PickDestination();
		bHasWandered = true;
	}
}

state Wandering
{
	ignores EnemyNotVisible;

	function PickDestination()
	{
		if ( bHasWandered && (FRand() < 0.1) )
			GotoState('FadeOut');
		else
			Super.PickDestination();
		bHasWandered = true;
	}
}

defaultproperties
{
     syllable1=Sound'UnrealShare.Nali.syl1n'
     syllable2=Sound'UnrealShare.Nali.syl2n'
     syllable3=Sound'UnrealShare.Nali.syl3n'
     syllable4=Sound'UnrealShare.Nali.syl4n'
     syllable5=Sound'UnrealShare.Nali.syl5n'
     syllable6=Sound'UnrealShare.Nali.syl6n'
     urgefollow=Sound'UnrealShare.Nali.follow1n'
     Cringe=Sound'UnrealShare.Nali.cringe2n'
     Cough=Sound'UnrealShare.Nali.cough1n'
     Sweat=Sound'UnrealShare.Nali.sweat1n'
     Bowing=Sound'UnrealShare.Nali.bowing1n'
     Backup=Sound'UnrealShare.Nali.backup2n'
     pray=Sound'UnrealShare.Nali.pray1n'
     Breath=Sound'UnrealShare.Nali.breath1n'
     CarcassType=Class'UnrealShare.NaliCarcass'
     TimeBetweenAttacks=0.5
     Aggressiveness=-10
     RefireRate=0.5
     bHasRangedAttack=True
     bIsWuss=True
     Acquire=Sound'UnrealShare.Nali.contct1n'
     Fear=Sound'UnrealShare.Nali.fear1n'
     Roam=Sound'UnrealShare.Nali.breath1n'
     Threaten=Sound'UnrealShare.Nali.contct3n'
     MeleeRange=40
     GroundSpeed=300
     WaterSpeed=100
     AccelRate=900
     JumpZ=-1
     SightRadius=1500
     Health=40
     UnderWaterTime=6
     AttitudeToPlayer=ATTITUDE_Friendly
     HitSound1=Sound'UnrealShare.Nali.injur1n'
     HitSound2=Sound'UnrealShare.Nali.injur2n'
     Die=Sound'UnrealShare.Nali.death1n'
     DrawType=DT_Mesh
     Mesh=LodMesh'UnrealShare.Nali1'
     CollisionRadius=24
     CollisionHeight=48
     Buoyancy=95
     RotationRate=(Pitch=2048,Yaw=40000,Roll=0)
     NameOfMonster="Nali"
	TimeToShockWave=1
	MoneyDroped=50
	sshot1="TOMATex21.Sshot.Nali"
}
