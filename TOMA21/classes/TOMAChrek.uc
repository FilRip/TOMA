class TOMAChrek extends TOMASkaarjTrooper;

#exec OBJ LOAD FILE=..\Sounds\TOMASounds21.uax PACKAGE=TOMASounds21

var(Sounds) sound 	drown;
var(Sounds) sound	breathagain;
var(Sounds) sound	Footstep1;
var(Sounds) sound	Footstep2;
var(Sounds) sound	Footstep3;
var(Sounds) sound	HitSound3;
var(Sounds) sound	HitSound4;
var(Sounds)	Sound	Deaths[6];
var(Sounds) sound	GaspSound;
var(Sounds) sound	UWHit1;
var(Sounds) sound	UWHit2;
var(Sounds) sound   LandGrunt;
var(Sounds) sound	JumpSound;
var		bool		bNoTact;
var     bool		bTacticalDir;		// used during movement between pathnodes
var		bool		bComboPaused;
var		bool		bNovice;

function ForceMeshToExist()
{
	Spawn(class'TOMAChrekP');
}

function PlayDeathHit(float Damage, vector HitLocation, name damageType, vector Momentum)
{
	local Bubble1 bub;
	local UT_BloodBurst b;
	local vector Mo;

	if ( Region.Zone.bDestructive && (Region.Zone.ExitActor != None) )
		Spawn(Region.Zone.ExitActor);
	if (HeadRegion.Zone.bWaterZone)
	{
		bub = spawn(class 'Bubble1',,, Location
			+ 0.3 * CollisionRadius * vector(Rotation) + 0.8 * BaseEyeHeight * vect(0,0,1));
		if (bub != None)
			bub.DrawScale = FRand()*0.08+0.03;
		bub = spawn(class 'Bubble1',,, Location
			+ 0.2 * CollisionRadius * VRand() + 0.7 * BaseEyeHeight * vect(0,0,1));
		if (bub != None)
			bub.DrawScale = FRand()*0.08+0.03;
		bub = spawn(class 'Bubble1',,, Location
			+ 0.3 * CollisionRadius * VRand() + 0.6 * BaseEyeHeight * vect(0,0,1));
		if (bub != None)
			bub.DrawScale = FRand()*0.08+0.03;
	}
	if ( !bGreenBlood && (DamageType == 'shot') || (DamageType == 'decapitated') )
	{
		Mo = Momentum;
		if ( Mo.Z > 0 )
			Mo.Z *= 0.5;
		spawn(class 'UT_BloodHit',self,,hitLocation, rotator(Mo));
	}
	else if ( (damageType != 'Burned') && (damageType != 'Corroded')
		 && (damageType != 'Drowned') && (damageType != 'Fell') )
	{
		b = spawn(class 'UT_BloodBurst',self,'', hitLocation);
		if ( bGreenBlood && (b != None) )
			b.GreenBlood();
	}
}

function PlayDyingSound()
{
	local int rnd;

	if ( HeadRegion.Zone.bWaterZone )
	{
		if ( FRand() < 0.5 )
			PlaySound(UWHit1, SLOT_Pain,16,,,Frand()*0.2+0.9);
		else
			PlaySound(UWHit2, SLOT_Pain,16,,,Frand()*0.2+0.9);
		return;
	}

	rnd = Rand(6);
	PlaySound(Deaths[rnd], SLOT_Talk, 16);
	PlaySound(Deaths[rnd], SLOT_Pain, 16);
}

function PlayDying(name DamageType, vector HitLoc)
{
	BaseEyeHeight = Default.BaseEyeHeight;
	PlayDyingSound();

	if ( DamageType == 'Suicided' )
	{
		PlayAnim('Dead8',, 0.1);
		return;
	}

	// check for head hit
	if ( (DamageType == 'Decapitated') && !class'GameInfo'.Default.bVeryLowGore )
	{
		PlayChrekDecap();
		return;
	}

	if ( FRand() < 0.15 )
	{
		PlayAnim('Dead2',,0.1);
		return;
	}

	// check for big hit
	if ( (Velocity.Z > 250) && (FRand() < 0.75) )
	{
		if ( FRand() < 0.5 )
			PlayAnim('Dead1',,0.1);
		else
			PlayAnim('Dead11',, 0.1);
		return;
	}

	// check for repeater death
	if ( (Health > -10) && ((DamageType == 'shot') || (DamageType == 'zapped')) )
	{
		PlayAnim('Dead9',, 0.1);
		return;
	}

	if ( (HitLoc.Z - Location.Z > 0.7 * CollisionHeight) && !class'GameInfo'.Default.bVeryLowGore )
	{
		if ( FRand() < 0.5 )
			PlayChrekDecap();
		else
			PlayAnim('Dead7',, 0.1);
		return;
	}

	if ( Region.Zone.bWaterZone || (FRand() < 0.5) ) //then hit in front or back
		PlayAnim('Dead3',, 0.1);
	else
		PlayAnim('Dead8',, 0.1);
}

function PlayChrekDecap()
{
	local carcass carc;

	PlayAnim('Dead4',, 0.1);
	if ( Level.NetMode != NM_Client )
	{
		carc = Spawn(class 'tomachrekhead',,, Location + CollisionHeight * vect(0,0,0.8), Rotation + rot(3000,0,16384) );
		if (carc != None)
		{
			carc.Initfor(self);
			carc.Velocity = Velocity + VSize(Velocity) * VRand();
			carc.Velocity.Z = FMax(carc.Velocity.Z, Velocity.Z);
		}
	}
}

function PlayPatrolStop()
{
	PlayWaiting();
}

function PlayWaiting()
{
	local name newAnim;

	if ( Physics == PHYS_Swimming )
	{
		BaseEyeHeight = 0.7 * Default.BaseEyeHeight;
		if ( (Weapon == None) || (Weapon.Mass < 20) )
			LoopAnim('TreadSM');
		else
			LoopAnim('TreadLG');
	}
	else
	{
		BaseEyeHeight = Default.BaseEyeHeight;
		if ( (Weapon != None) && Weapon.bPointing )
		{
			if ( Weapon.bRapidFire && ((bFire != 0) || (bAltFire != 0)) )
				LoopAnim('StillFRRP');
			else if ( Weapon.Mass < 20 )
				TweenAnim('StillSMFR', 0.3);
			else
				TweenAnim('StillFRRP', 0.3);
		}
		else
		{
			if ( Level.Game.bTeamGame
				&& ((FRand() < 0.04)
					|| ((AnimSequence == 'Chat1') && (FRand() < 0.75))) )
			{
				newAnim = 'Chat1';
			}
			else if ( FRand() < 0.1 )
			{
				if ( (Weapon == None) || (Weapon.Mass < 20) )
					PlayAnim('CockGun', 0.5 + 0.5 * FRand(), 0.3);
				else
					PlayAnim('CockGunL', 0.5 + 0.5 * FRand(), 0.3);
			}
			else
			{
				if ( (Weapon == None) || (Weapon.Mass < 20) )
				{
					if ( (FRand() < 0.75) && ((AnimSequence == 'Breath1') || (AnimSequence == 'Breath2')) )
						newAnim = AnimSequence;
					else if ( FRand() < 0.5 )
						newAnim = 'Breath1';
					else
						newAnim = 'Breath2';
				}
				else
				{
					if ( (FRand() < 0.75) && ((AnimSequence == 'Breath1L') || (AnimSequence == 'Breath2L')) )
						newAnim = AnimSequence;
					else if ( FRand() < 0.5 )
						newAnim = 'Breath1L';
					else
						newAnim = 'Breath2L';
				}

				if ( AnimSequence == newAnim )
					LoopAnim(newAnim, 0.4 + 0.4 * FRand());
				else
					PlayAnim(newAnim, 0.4 + 0.4 * FRand(), 0.25);
			}
		}
	}
}

function PlayLanded(float impactVel)
{
	impactVel = impactVel/JumpZ;
	impactVel = 0.1 * impactVel * impactVel;
	BaseEyeHeight = Default.BaseEyeHeight;

	if ( impactVel > 0.17 )
		PlaySound(LandGrunt, SLOT_Talk, FMin(4, 5 * impactVel),false,1600,FRand()*0.4+0.8);
	if ( !FootRegion.Zone.bWaterZone && (impactVel > 0.01) )
		PlaySound(Land, SLOT_Interact, FClamp(4 * impactVel,0.2,4.5), false,1600, 1.0);

	if ( (impactVel > 0.06) || (GetAnimGroup(AnimSequence) == 'Jumping') )
	{
		if ( (Weapon == None) || (Weapon.Mass < 20) )
			TweenAnim('LandSMFR', 0.12);
		else
			TweenAnim('LandLGFR', 0.12);
	}
	else if ( !IsAnimating() )
	{
		if ( GetAnimGroup(AnimSequence) == 'TakeHit' )
			AnimEnd();
		else
		{
			if ( (Weapon == None) || (Weapon.Mass < 20) )
				TweenAnim('LandSMFR', 0.12);
			else
				TweenAnim('LandLGFR', 0.12);
		}
	}
}

function TweenToRunning(float tweentime)
{
	local name newAnim;

	if ( Physics == PHYS_Swimming )
	{
		if ( (vector(Rotation) Dot Acceleration) > 0 )
			TweenToSwimming(tweentime);
		else
			TweenToWaiting(tweentime);
		return;
	}

	BaseEyeHeight = Default.BaseEyeHeight;

	if (Weapon == None)
		newAnim = 'RunSM';
	else if ( Weapon.bPointing )
	{
		if (Weapon.Mass < 20)
			newAnim = 'RunSMFR';
		else
			newAnim = 'RunLGFR';
	}
	else
	{
		if (Weapon.Mass < 20)
			newAnim = 'RunSM';
		else
			newAnim = 'RunLG';
	}

	if ( (newAnim == AnimSequence) && (Acceleration != vect(0,0,0)) && IsAnimating() )
		return;
	TweenAnim(newAnim, tweentime);
}

function TweenToPatrolStop(float tweentime)
{
	TweenToFighter(tweentime);
}

function TweenToFighter(float tweentime)
{
	TweenToWaiting(tweentime);
}

function TweenToFalling();

function PlayInAir()
{
	local float TweenTime;

	BaseEyeHeight =  0.7 * Default.BaseEyeHeight;
	if ( GetAnimGroup(AnimSequence) == 'Jumping' )
	{
		if ( (Weapon == None) || (Weapon.Mass < 20) )
			TweenAnim('DuckWlkS', 2);
		else
			TweenAnim('DuckWlkL', 2);
		return;
	}
	else if ( GetAnimGroup(AnimSequence) == 'Ducking' )
		TweenTime = 2;
	else
		TweenTime = 0.7;

	if ( (Weapon == None) || (Weapon.Mass < 20) )
		TweenAnim('JumpSMFR', TweenTime);
	else
		TweenAnim('JumpLGFR', TweenTime);
}

function TweenToWaiting(float tweentime)
{
	if ( Physics == PHYS_Swimming )
	{
		BaseEyeHeight = 0.7 * Default.BaseEyeHeight;
		if ( (Weapon == None) || (Weapon.Mass < 20) )
			TweenAnim('TreadSM', tweentime);
		else
			TweenAnim('TreadLG', tweentime);
	}
	else
	{
		BaseEyeHeight = Default.BaseEyeHeight;
		if ( Enemy != None )
			ViewRotation = Rotator(Enemy.Location - Location);
		else
		{
			if ( GetAnimGroup(AnimSequence) == 'Waiting' )
				return;
			ViewRotation.Pitch = 0;
		}
		ViewRotation.Pitch = ViewRotation.Pitch & 65535;
		If ( (ViewRotation.Pitch > RotationRate.Pitch)
			&& (ViewRotation.Pitch < 65536 - RotationRate.Pitch) )
		{
			If (ViewRotation.Pitch < 32768)
			{
				if ( (Weapon == None) || (Weapon.Mass < 20) )
					TweenAnim('AimUpSm', 0.3);
				else
					TweenAnim('AimUpLg', 0.3);
			}
			else
			{
				if ( (Weapon == None) || (Weapon.Mass < 20) )
					TweenAnim('AimDnSm', 0.3);
				else
					TweenAnim('AimDnLg', 0.3);
			}
		}
		else if ( (Weapon == None) || (Weapon.Mass < 20) )
			TweenAnim('StillSMFR', tweentime);
		else
			TweenAnim('StillFRRP', tweentime);
	}
}

function PlayRunning()
{
	local float strafeMag;
	local vector Focus2D, Loc2D, Dest2D;
	local vector lookDir, moveDir, Y;
	local name NewAnim;

	if ( Physics == PHYS_Swimming )
	{
		if ( (vector(Rotation) Dot Acceleration) > 0 )
			PlaySwimming();
		else
			PlayWaiting();
		return;
	}
	BaseEyeHeight = Default.BaseEyeHeight;

	if ( bAdvancedTactics && !bNoTact )
	{
		if ( bTacticalDir )
			LoopAnim('StrafeL');
		else
			LoopAnim('StrafeR');
		return;
	}
	else if ( Focus != Destination )
	{
		// check for strafe or backup
		Focus2D = Focus;
		Focus2D.Z = 0;
		Loc2D = Location;
		Loc2D.Z = 0;
		Dest2D = Destination;
		Dest2D.Z = 0;
		lookDir = Normal(Focus2D - Loc2D);
		moveDir = Normal(Dest2D - Loc2D);
		strafeMag = lookDir dot moveDir;
		if ( strafeMag < 0.75 )
		{
			if ( strafeMag < -0.75 )
				LoopAnim('BackRun');
			else
			{
				Y = (lookDir Cross vect(0,0,1));
				if ((Y Dot (Dest2D - Loc2D)) > 0)
					LoopAnim('StrafeL');
				else
					LoopAnim('StrafeR');
			}
			return;
		}
	}

	if (Weapon == None)
		newAnim = 'RunSM';
	else if ( Weapon.bPointing )
	{
		if (Weapon.Mass < 20)
			newAnim = 'RunSMFR';
		else
			newAnim = 'RunLGFR';
	}
	else
	{
		if (Weapon.Mass < 20)
			newAnim = 'RunSM';
		else
			newAnim = 'RunLG';
	}
	if ( (newAnim == AnimSequence) && IsAnimating() )
		return;

	LoopAnim(NewAnim);
}

function PlayFiring()
{
	// switch animation sequence mid-stream if needed
	if ( GetAnimGroup(AnimSequence) == 'MovingFire' )
		return;
	else if (AnimSequence == 'RunLG')
		AnimSequence = 'RunLGFR';
	else if (AnimSequence == 'RunSM')
		AnimSequence = 'RunSMFR';
	else if (AnimSequence == 'WalkLG')
		AnimSequence = 'WalkLGFR';
	else if (AnimSequence == 'WalkSM')
		AnimSequence = 'WalkSMFR';
	else if ( AnimSequence == 'JumpSMFR' )
		TweenAnim('JumpSMFR', 0.03);
	else if ( AnimSequence == 'JumpLGFR' )
		TweenAnim('JumpLGFR', 0.03);
	else if ( (GetAnimGroup(AnimSequence) == 'Waiting') || (GetAnimGroup(AnimSequence) == 'Gesture')
		&& (AnimSequence != 'TreadLG') && (AnimSequence != 'TreadSM') )
	{
		if ( Weapon.Mass < 20 )
			TweenAnim('StillSMFR', 0.02);
		else if ( !Weapon.bRapidFire || (AnimSequence != 'StillFRRP') )
			TweenAnim('StillFRRP', 0.02);
		else if ( !IsAnimating() )
			LoopAnim('StillFRRP');
	}
}

function PlayMovingAttack()
{
	PlayRunning();
	FireWeapon();
}

function PlayChallenge()
{
	TweenToWaiting(0.17);
}

function PlayRangedAttack()
{
	TweenToWaiting(0.11);
	FireWeapon();
}

function PlayMeleeAttack()
{
	//log("play melee attack");
	Acceleration = AccelRate * VRand();
	TweenToWaiting(0.15);
	FireWeapon();
}

state RangedAttack
{
ignores SeePlayer, HearNoise, Bump;

	function PlayRangedAttack()
	{
	   global.PlayRangedAttack();
	}

	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
						Vector momentum, name damageType)
	{
		Global.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
		if ( health <= 0 )
			return;
		if (NextState == 'TakeHit')
		{
			NextState = 'RangedAttack';
			NextLabel = 'Begin';
		}
	}

	function StopFiring()
	{
		Super.StopFiring();
		GotoState('Attacking');
	}

	function StopWaiting()
	{
		Timer();
	}

	function EnemyNotVisible()
	{
		////log("enemy not visible");
		//let attack animation complete
		if ( bComboPaused || bFiringPaused )
			return;
		if ( (Weapon == None) || Weapon.bMeleeWeapon
			|| (FRand() < 0.13) )
		{
			bReadyToAttack = true;
			GotoState('Attacking');
			return;
		}
	}

	function KeepAttacking()
	{
		local TranslocatorTarget T;
		local int BaseSkill;

		if ( bComboPaused || bFiringPaused )
		{
			if ( TimerRate <= 0.0 )
			{
				TweenToRunning(0.12);
				GotoState(NextState, NextLabel);
			}
			if ( bComboPaused )
				return;

			T = TranslocatorTarget(Target);
			if ( (T != None) && !T.Disrupted() && LineOfSightTo(T) )
				return;
			if ( (Enemy == None) || (Enemy.Health <= 0) || !LineOfSightTo(Enemy) )
			{
				bFire = 0;
				bAltFire = 0;
				TweenToRunning(0.12);
				GotoState(NextState, NextLabel);
			}
		}
		if ( (Enemy == None) || (Enemy.Health <= 0) || !LineOfSightTo(Enemy) )
		{
			bFire = 0;
			bAltFire = 0;
			GotoState('Attacking');
			return;
		}
		if ( (Weapon != None) && Weapon.bMeleeWeapon )
		{
			bReadyToAttack = true;
			GotoState('TacticalMove');
			return;
		}
		BaseSkill = Skill;
		if ( !bNovice )
			BaseSkill += 3;
		if ( (Enemy.Weapon != None) && Enemy.Weapon.bMeleeWeapon
			&& (VSize(Enemy.Location - Location) < 500) )
			BaseSkill += 3;
		if ( (BaseSkill > 3 * FRand() + 2)
			|| ((bFire == 0) && (bAltFire == 0) && (BaseSkill > 6 * FRand() - 1)) )
		{
			bReadyToAttack = true;
			GotoState('TacticalMove');
		}
	}

	function Timer()
	{
		if ( bComboPaused || bFiringPaused )
		{
			TweenToRunning(0.12);
			GotoState(NextState, NextLabel);
		}
	}

	function AnimEnd()
	{
		local float decision;

		if ( (Weapon == None) || Weapon.bMeleeWeapon
			|| ((bFire == 0) && (bAltFire == 0)) )
		{
			GotoState('Attacking');
			return;
		}
		decision = FRand() - 0.2 * skill;
		if ( !bNovice )
			decision -= 0.5;
		if ( decision < 0 )
			GotoState('RangedAttack', 'DoneFiring');
		else
		{
			PlayWaiting();
			FireWeapon();
		}
	}

	// ASMD combo move
	function SpecialFire()
	{
		if ( Enemy == None )
			return;
		bComboPaused = true;
		SetTimer(0.75 + VSize(Enemy.Location - Location)/Weapon.AltProjectileSpeed, false);
		SpecialPause = 0.0;
		NextState = 'Attacking';
		NextLabel = 'Begin';
	}

	function BeginState()
	{
		Disable('AnimEnd');
		if ( bComboPaused || bFiringPaused )
		{
			SetTimer(SpecialPause, false);
			SpecialPause = 0;
		}
		else
			Target = Enemy;
	}

	function EndState()
	{
		bFiringPaused = false;
		bComboPaused = false;
	}

Challenge:
	Disable('AnimEnd');
	Acceleration = vect(0,0,0); //stop
	DesiredRotation = Rotator(Enemy.Location - Location);
	PlayChallenge();
	FinishAnim();
	TweenToFighter(0.1);
	Goto('FaceTarget');

Begin:
	if ( Target == None )
	{
		Target = Enemy;
		if ( Target == None )
			GotoState('Attacking');
	}
	Acceleration = vect(0,0,0); //stop
	DesiredRotation = Rotator(Target.Location - Location);
	TweenToFighter(0.16 - 0.2 * Skill);

FaceTarget:
	Disable('AnimEnd');
	if ( NeedToTurn(Target.Location) )
	{
		PlayTurning();
		TurnToward(Target);
		TweenToFighter(0.1);
	}
	FinishAnim();

ReadyToAttack:
	DesiredRotation = Rotator(Target.Location - Location);
	PlayRangedAttack();
	if ( Weapon.bMeleeWeapon )
		GotoState('Attacking');
	Enable('AnimEnd');
Firing:
	if ( Target == None )
		GotoState('Attacking');
	TurnToward(Target);
	Goto('Firing');
DoneFiring:
	Disable('AnimEnd');
	KeepAttacking();
	Goto('FaceTarget');
}

function PlayVictoryDance()
{
	PlayAnim('Victory1', 0.6, 0.1);
}

simulated function PlayFootStep()
{
	local sound step;
	local float decision;

	if ( FootRegion.Zone.bWaterZone )
	{
		PlaySound(sound 'LSplash', SLOT_Interact, 1, false, 1500.0, 1.0);
		return;
	}

	decision = FRand();
	if ( decision < 0.34 )
		step = Footstep1;
	else if (decision < 0.67 )
		step = Footstep2;
	else
		step = Footstep3;

	PlaySound(step, SLOT_Interact, 2.2, false, 1000.0, 1.0);
}

function RunStep()
{
	if (FRand() < 0.6)
		PlaySound(FootStep1, SLOT_Interact,0.8,,900);
	else
		PlaySound(FootStep2, SLOT_Interact,0.8,,900);
}

function WalkStep()
{
	if (FRand() < 0.6)
		PlaySound(FootStep1, SLOT_Interact,0.2,,500);
	else
		PlaySound(FootStep2, SLOT_Interact,0.2,,500);
}

function PlayBigDeath(name DamageType)
{
	if ( FRand() < 0.35 )
		PlayAnim('Death',0.7,0.1);
	else
		PlayAnim('Death2',0.7,0.1);
	PlaySound(Die, SLOT_Talk, 4.5 * TransientSoundVolume);
}

defaultproperties
{
    CarcassType=Class'TOMAChrekCarcass'
    drown=sound'TOMASounds21.Monsters.chkdrown'
    breathagain=sound'TOMASounds21.Monsters.chkgasp2'
    Footstep1=sound'TOMASounds21.Monsters.chkstep1'
    Footstep2=sound'TOMASounds21.Monsters.chkstep2'
    Footstep3=sound'TOMASounds21.Monsters.chkstep3'
    HitSound3=sound'TOMASounds21.Monsters.chkinjur3'
    HitSound4=sound'TOMASounds21.Monsters.chkinjur4'
    Deaths(0)=sound'TOMASounds21.Monsters.chkdeath1'
    Deaths(1)=sound'TOMASounds21.Monsters.chkdeath2'
    Deaths(2)=sound'TOMASounds21.Monsters.chkdeath3'
    Deaths(3)=sound'TOMASounds21.Monsters.chkdeath4'
    Deaths(4)=sound'TOMASounds21.Monsters.chkdeath5'
    Deaths(5)=sound'TOMASounds21.Monsters.chkdeath6'
    GaspSound=sound'TOMASounds21.Monsters.chkgasp'
    UWHit1=sound'TOMASounds21.Monsters.chkUWhit1'
    UWHit2=sound'TOMASounds21.Monsters.chkUWhit2'
    LandGrunt=sound'TOMASounds21.Monsters.chklandgrunt'
    JumpSound=sound'TOMASounds21.Monsters.chkjump'
    SpecialMesh="Botpack.TrophyMale2"
    HitSound1=sound'TOMASounds21.Monsters.chkinjur1'
    HitSound2=sound'TOMASounds21.Monsters.chkinjur2'
    Land=sound'TOMASounds21.Monsters.chkland'
    Die=Sound'TOMASounds21.Monsters.chkdeath1'
    Mesh=LodMesh'TOMAModels21.Chrek'
    PlayerReplicationInfoClass=Class'TOMA21.TOMAMonstersReplicationInfo'
    DrawType=DT_Mesh
    NameOfMonster="Chrek"
	ScoreForKill=2
	MoneyDroped=200
	sshot1="TOMATex21.Sshot.Chrek"
	sshot2=""
}

