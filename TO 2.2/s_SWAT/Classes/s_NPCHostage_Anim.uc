//=============================================================================
// s_NPC
//=============================================================================
//
// Tactical Ops -- an Unreal Tournament modification
// -- http://www.planetunreal.com/tacticalops
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen and Benoit "JAH" Delayen
//=============================================================================

class s_NPCHostage_Anim extends s_NPCHostage;


function ForceMeshToExist()
{
}


///////////////////////////////////////
// PlayTurning
///////////////////////////////////////

function PlayTurning()
{
	BaseEyeHeight = Default.BaseEyeHeight;
	if (Weapon == None)
		PlayAnim(GetStillAnim(), 0.3, 0.3);
	else if (Weapon.Mass < 20)
		PlayAnim('TurnSM', 0.3, 0.3);
	else
		PlayAnim('TurnLG', 0.3, 0.3);
}


///////////////////////////////////////
// PlayWaving
///////////////////////////////////////

function PlayWaving()
{
	//PlayAnim('Wave', 0.7, 0.2);
}


///////////////////////////////////////
// TweenToWalking
///////////////////////////////////////

function TweenToWalking(float tweentime)
	{
		if ( Physics == PHYS_Swimming )
		{
			if ( (vector(Rotation) Dot Acceleration) > 0 )
				TweenToSwimming(tweentime);
			else
				TweenToWaiting(tweentime);
		}
		
		BaseEyeHeight = Default.BaseEyeHeight;

		if (Weapon == None)
			TweenAnim('HostageWalk', tweentime);
		else if ( Weapon.bPointing ) 
		{
			if (Weapon.Mass < 20)
				TweenAnim('WalkSMFR', tweentime);
			else
				TweenAnim('WalkLGFR', tweentime);
		}
		else
		{
			if (Weapon.Mass < 20)
				TweenAnim('WalkSM', tweentime);
			else
				TweenAnim('WalkLG', tweentime);
		} 
	}


///////////////////////////////////////
// TweenToRunning
///////////////////////////////////////

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
		newAnim = 'HostageRun';
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


///////////////////////////////////////
// PlayWalking
///////////////////////////////////////

function PlayWalking()
{
	if ( Physics == PHYS_Swimming )
	{
		if ( (vector(Rotation) Dot Acceleration) > 0 )
			PlaySwimming();
		else
			PlayWaiting();
		return;
	}

	BaseEyeHeight = Default.BaseEyeHeight;
	if (Weapon == None)
		LoopAnim('HostageWalk');
	else if ( Weapon.bPointing ) 
	{
		if (Weapon.Mass < 20)
			LoopAnim('WalkSMFR');
		else
			LoopAnim('WalkLGFR');
	}
	else
	{
		if (Weapon.Mass < 20)
			LoopAnim('WalkSM');
		else
			LoopAnim('WalkLG');
	}
}


///////////////////////////////////////
// PlayRunning
///////////////////////////////////////

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
		newAnim = 'HostageRun';
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


///////////////////////////////////////
// PlayRising
///////////////////////////////////////

function PlayRising()
{
	BaseEyeHeight = 0.4 * Default.BaseEyeHeight;
	TweenAnim('DuckWlkS', 0.7);
}


///////////////////////////////////////
// PlayFeignDeath
///////////////////////////////////////

function PlayFeignDeath()
{
	local float decision;

	BaseEyeHeight = 0;
	if ( decision < 0.33 )
		TweenAnim('DeathEnd', 0.5);
	else if ( decision < 0.67 )
		TweenAnim('DeathEnd2', 0.5);
	else 
		TweenAnim('DeathEnd3', 0.5);
}


///////////////////////////////////////
// PlayLanded
///////////////////////////////////////

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


///////////////////////////////////////
// FastInAir
///////////////////////////////////////

function FastInAir()
{
	local float TweenTime;

	BaseEyeHeight =  0.7 * Default.BaseEyeHeight;
	if ( GetAnimGroup(AnimSequence) == 'Jumping' )
	{
		if ( (Weapon == None) || (Weapon.Mass < 20) )
			TweenAnim('DuckWlkS', 1);
		else
			TweenAnim('DuckWlkL', 1);
		return;
	}
	else if ( GetAnimGroup(AnimSequence) == 'Ducking' )
		TweenTime = 1;
	else 
		TweenTime = 0.3;

	if ( (Weapon == None) || (Weapon.Mass < 20) )
		TweenAnim('JumpSMFR', TweenTime);
	else
		TweenAnim('JumpLGFR', TweenTime); 
}
	

///////////////////////////////////////
// PlayInAir
///////////////////////////////////////

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


///////////////////////////////////////
// PlayDodge
///////////////////////////////////////

function PlayDodge(bool bDuckLeft)
{
	if ( bDuckLeft )
		TweenAnim('DodgeL', 0.25);
	else
		TweenAnim('DodgeR', 0.25);
}


///////////////////////////////////////
// PlayDuck
///////////////////////////////////////

function PlayDuck()
{
	BaseEyeHeight = 0;
	if ( (Weapon == None) || (Weapon.Mass < 20) )
		TweenAnim('DuckWlkS', 0.25);
	else
		TweenAnim('DuckWlkL', 0.25);
}


///////////////////////////////////////
// PlayCrawling
///////////////////////////////////////

function PlayCrawling()
{
	//log("Play duck");
	BaseEyeHeight = 0;
	if ( (Weapon == None) || (Weapon.Mass < 20) )
		LoopAnim('DuckWlkS');
	else
		LoopAnim('DuckWlkL');
}


///////////////////////////////////////
// TweenToWaiting
///////////////////////////////////////

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
		/*if ( Enemy != None )
			ViewRotation = Rotator(Enemy.Location - Location);
		else
		{
			if ( GetAnimGroup(AnimSequence) == 'Waiting' )
				return;
			ViewRotation.Pitch = 0;
		}*/
		ViewRotation.Pitch = ViewRotation.Pitch & 65535;
/*		If ( (ViewRotation.Pitch > RotationRate.Pitch) 
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
		else*/ 
		if ( GetAnimGroup(AnimSequence) == 'Waiting' )
				return;

		if (Weapon == None)
			TweenAnim(GetStillAnim(), tweentime);
		else if ( Weapon.Mass < 20 )
			TweenAnim('StillSMFR', tweentime);
		else
			TweenAnim('StillFRRP', tweentime);
	}
}


///////////////////////////////////////
// TweenToFighter
///////////////////////////////////////

function TweenToFighter(float tweentime)
{
	TweenToWaiting(tweentime);
}
	

///////////////////////////////////////
// PlayChallenge
///////////////////////////////////////

function PlayChallenge()
{
	TweenToWaiting(0.17);
}	


///////////////////////////////////////
// PlayLookAround
///////////////////////////////////////

function PlayLookAround()
{
	//LoopAnim('HostageStandBreath', 0.3 + 0.7 * FRand(), 0.1);
}
	

///////////////////////////////////////
// PlayWaiting
///////////////////////////////////////

function PlayWaiting()
{
	local name newAnim;

/*	if ( Physics == PHYS_Swimming )
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
		{*/
/*			if ( Level.Game.bTeamGame
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
				{*/

	/*
					if ( (FRand() < 0.75) && ((AnimSequence == 'Breath1') || (AnimSequence == 'Breath2')) )
						newAnim = AnimSequence;
					else if ( FRand() < 0.5 )
						newAnim = 'HostageNealBreath';
					else
						newAnim = 'HostageNealBreath';

	*/
		newAnim = GetStillAnim();
			//	}
								
				if ( AnimSequence == newAnim )
					LoopAnim(newAnim, 0.4 + 0.4 * FRand());
				else
					PlayAnim(newAnim, 0.4 + 0.4 * FRand(), 0.25);
	//		}
	//	}
	//}
}	


///////////////////////////////////////
// GetStillAnim
///////////////////////////////////////

function name GetStillAnim()
{
	if ( bIsFree )
		return 'HostageStandBreath';
	else
		return 'HostageNealBreath';
}


///////////////////////////////////////
// PlayRecoil
///////////////////////////////////////

function PlayRecoil(float Rate)
{
	if ( Weapon.bRapidFire )
	{
		if ( (Weapon.AmmoType != None) && (Weapon.AmmoType.AmmoAmount < 2) )
			TweenAnim('StillFRRP', 0.1);
		else if ( !IsAnimating() && (Physics == PHYS_Walking) )
			LoopAnim('StillFRRP', 0.02);
	}
	else if ( AnimSequence == 'StillSmFr' )
		PlayAnim('StillSmFr', Rate, 0.02);
	else if ( (AnimSequence == 'StillLgFr') || (AnimSequence == 'StillFrRp') )	
		PlayAnim('StillLgFr', Rate, 0.02);
}
	

///////////////////////////////////////
// PlayFiring
///////////////////////////////////////

function PlayFiring()
{
	// switch animation sequence mid-stream if needed
/*	if ( GetAnimGroup(AnimSequence) == 'MovingFire' )
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
	}*/
}


///////////////////////////////////////
// PlayWeaponSwitch
///////////////////////////////////////

function PlayWeaponSwitch(Weapon NewWeapon)
{
/*	if ( (Weapon == None) || (Weapon.Mass < 20) )
	{
		if ( (NewWeapon != None) && (NewWeapon.Mass > 20) )
		{
			if ( (AnimSequence == 'RunSM') || (AnimSequence == 'RunSMFR') )
				AnimSequence = 'RunLG';
			else if ( (AnimSequence == 'WalkSM') || (AnimSequence == 'WalkSMFR') )
				AnimSequence = 'WalkLG';	
		 	else if ( AnimSequence == 'JumpSMFR' )
		 		AnimSequence = 'JumpLGFR';
			else if ( AnimSequence == 'DuckWlkL' )
				AnimSequence = 'DuckWlkS';
		 	else if ( AnimSequence == 'StillSMFR' )
		 		AnimSequence = 'StillFRRP';
			else if ( AnimSequence == 'AimDnSm' )
				AnimSequence = 'AimDnLg';
			else if ( AnimSequence == 'AimUpSm' )
				AnimSequence = 'AimUpLg';
		 }	
	}
	else if ( (NewWeapon == None) || (NewWeapon.Mass < 20) )
	{		
		if ( (AnimSequence == 'RunLG') || (AnimSequence == 'RunLGFR') )
			AnimSequence = 'RunSM';
		else if ( (AnimSequence == 'WalkLG') || (AnimSequence == 'WalkLGFR') )
			AnimSequence = 'WalkSM';
	 	else if ( AnimSequence == 'JumpLGFR' )
	 		AnimSequence = 'JumpSMFR';
		else if ( AnimSequence == 'DuckWlkS' )
			AnimSequence = 'DuckWlkL';
	 	else if (AnimSequence == 'StillFRRP')
	 		AnimSequence = 'StillSMFR';
		else if ( AnimSequence == 'AimDnLg' )
			AnimSequence = 'AimDnSm';
		else if ( AnimSequence == 'AimUpLg' )
			AnimSequence = 'AimUpSm';
	}*/
}


///////////////////////////////////////
// PlaySwimming
///////////////////////////////////////

function PlaySwimming()
{
	BaseEyeHeight = 0.7 * Default.BaseEyeHeight;
	if ((Weapon == None) || (Weapon.Mass < 20) )
		LoopAnim('SwimSM');
	else
		LoopAnim('SwimLG');
}


///////////////////////////////////////
// TweenToSwimming
///////////////////////////////////////

function TweenToSwimming(float tweentime)
{
	BaseEyeHeight = 0.7 * Default.BaseEyeHeight;
	if ((Weapon == None) || (Weapon.Mass < 20) )
		TweenAnim('SwimSM',tweentime);
	else
		TweenAnim('SwimLG',tweentime);
}


///////////////////////////////////////
// ImpactJumping
///////////////////////////////////////

State ImpactJumping
{
	function PlayWaiting()
	{
		//TweenAnim('AimDnLg', 0.3);
	}
}


///////////////////////////////////////
// PlayVictoryDance
///////////////////////////////////////

function PlayVictoryDance()
{
	/*
	local float decision;

	decision = FRand();

	if ( decision < 0.4 )
		PlayAnim('Victory1',0.7, 0.2);
	else if ( decision < 0.7 )
		PlayAnim('Thrust',0.7, 0.2);
	else
		PlayAnim('Taunt1',0.7, 0.2);
	*/
}


///////////////////////////////////////
// PlayDying
///////////////////////////////////////

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
	if ( (DamageType == 'Decapitated') && !Level.Game.bVeryLowGore )
	{
		PlayDecap();
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
		
	if ( (HitLoc.Z - Location.Z > 0.7 * CollisionHeight) && !Level.Game.bVeryLowGore )
	{
		if ( FRand() < 0.5 )
			PlayDecap();
		else
			PlayAnim('Dead7',, 0.1);
		return;
	}
	
	if ( Region.Zone.bWaterZone || (FRand() < 0.5) ) //then hit in front or back
		PlayAnim('Dead3',, 0.1);
	else
		PlayAnim('Dead8',, 0.1);
}


///////////////////////////////////////
// PlayDecap
///////////////////////////////////////

function PlayDecap()
{
	local carcass carc;

	PlayAnim('Dead4',, 0.1);
	if ( Level.NetMode != NM_Client )
	{
		carc = Spawn(class 'UT_HeadMale',,, Location + CollisionHeight * vect(0,0,0.8), Rotation + rot(3000,0,16384) );
		if (carc != None)
		{
			carc.Initfor(self);
			carc.Velocity = Velocity + VSize(Velocity) * VRand();
			carc.Velocity.Z = FMax(carc.Velocity.Z, Velocity.Z);
		}
	}
}


///////////////////////////////////////
// PlayGutHit
///////////////////////////////////////

function PlayGutHit(float tweentime)
{
	if ( (AnimSequence == 'GutHit') || (AnimSequence == 'Dead2') )
	{
		if (FRand() < 0.5)
			TweenAnim('LeftHit', tweentime);
		else
			TweenAnim('RightHit', tweentime);
	}
	else if ( FRand() < 0.6 )
		TweenAnim('GutHit', tweentime);
	else
		TweenAnim('Dead8', tweentime);

}


///////////////////////////////////////
// PlayHeadHit
///////////////////////////////////////

function PlayHeadHit(float tweentime)
{
	if ( (AnimSequence == 'HeadHit') || (AnimSequence == 'Dead7') )
		TweenAnim('GutHit', tweentime);
	else if ( FRand() < 0.6 )
		TweenAnim('HeadHit', tweentime);
	else
		TweenAnim('Dead7', tweentime);
}


///////////////////////////////////////
// PlayLeftHit
///////////////////////////////////////

function PlayLeftHit(float tweentime)
{
	if ( (AnimSequence == 'LeftHit') || (AnimSequence == 'Dead9') )
		TweenAnim('GutHit', tweentime);
	else if ( FRand() < 0.6 )
		TweenAnim('LeftHit', tweentime);
	else 
		TweenAnim('Dead9', tweentime);
}


///////////////////////////////////////
// PlayRightHit
///////////////////////////////////////

function PlayRightHit(float tweentime)
{
	if ( (AnimSequence == 'RightHit') || (AnimSequence == 'Dead1') )
		TweenAnim('GutHit', tweentime);
	else if ( FRand() < 0.6 )
		TweenAnim('RightHit', tweentime);
	else
		TweenAnim('Dead1', tweentime);
}

defaultproperties
{
}
