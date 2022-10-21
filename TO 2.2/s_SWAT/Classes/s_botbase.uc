//=============================================================================
// s_BotBase
//=============================================================================
//
// Tactical Ops
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen and Benoit "JAH" Delayen
//=============================================================================

class s_BotBase extends Bot
	abstract;


// Foot steps
enum EFloorMaterial
{
		FM_Stone,
		FM_stonestep,
		FM_rocky,
		FM_smallgravel,
		FM_pebbles,
		FM_metalstep,
		FM_snowstep,
		FM_snow,
		FM_woodstep,
		FM_woodwarmstep,
		FM_grass,
		FM_highgrass,
		FM_carpet,
		FM_mud,
		FM_sand,
		FM_sandwet,
		FM_water,
		FM_concrete,
		FM_glass,
		FM_rock,
		FM_stonechurch,
};

var		Sound	OldFootSound;
var		EFloorMaterial	OldFloorMaterial;

// Zone check
var	bool	bInBuyZone, bInHomeBase, bInEscapeZone, bInRescueZone, bInHostageHidingPlace, bInBombingZone;



///////////////////////////////////////
// Gibbed
///////////////////////////////////////

function bool Gibbed( name damageType )
{
		return false;
}


///////////////////////////////////////
// InitRating
///////////////////////////////////////
	
function InitRating() 
{
	if ( !Level.Game.IsA('TO_DeathMatchPlus') )
		return;
	
	Rating = 1000 + 400 * skill;
	if ( TO_DeathMatchPlus(Level.Game).bNoviceMode )
		Rating -= 500;
}


///////////////////////////////////////
// WhatToDoNext
///////////////////////////////////////

function WhatToDoNext(name LikelyState, name LikelyLabel)
{
	if ( bVerbose )
	{
		log(self$" what to do next");
		log("enemy "$Enemy);
		log("old enemy "$OldEnemy);
	}
	if ( (Level.NetMode != NM_Standalone) 
		&& Level.Game.IsA('TO_DeathMatchPlus')
		&& TO_DeathMatchPlus(Level.Game).TooManyBots() )
	{
		Destroy();
		return;
	}

	BlockedPath = None;
	bDevious = false;
	bFire = 0;
	bAltFire = 0;
	bKamikaze = false;
	SetOrders(BotReplicationInfo(PlayerReplicationInfo).RealOrders, BotReplicationInfo(PlayerReplicationInfo).RealOrderGiver, true);
	Enemy = OldEnemy;
	OldEnemy = None;
	bReadyToAttack = false;
	if ( Enemy != None )
	{
		bReadyToAttack = !bNovice;
		GotoState('Attacking');
	}
	else if ( (Orders == 'Hold') && (Weapon.AIRating > 0.4) && (Health > 70) )
			GotoState('Hold');
	else
	{
		GotoState('Roaming');
		if ( Skill > 2.7 )
			bReadyToAttack = true; 
	}
}


///////////////////////////////////////
// DeferTo 
///////////////////////////////////////

function bool DeferTo(Bot Other)
{
	if ( (Other.PlayerReplicationInfo.HasFlag != None) 
		|| ((Orders == 'Follow') && (Other == OrderObject)) )
	{
		if ( Level.Game.IsA('TO_TeamGamePlus') && TO_TeamGamePlus(Level.Game).HandleTieUp(self, Other) )
			return false;
		if ( (Enemy != None) && LineOfSightTo(Enemy) )
			GotoState('TacticalMove', 'NoCharge');
		else
		{
			Enemy = None;
			OldEnemy = None;
			if ( (Health > 0) && (Acceleration == vect(0,0,0)) )
			{
				WanderDir = Normal(Location - Other.Location);
				GotoState('Wandering', 'Begin');
			}
		}
		Other.SetTimer(FClamp(TimerRate, 0.001, 0.2), false);
		return true;
	}
	return false;
}


///////////////////////////////////////
// AttitudeTo 
///////////////////////////////////////

function eAttitude AttitudeTo(Pawn Other)
{
	local byte result;

	if ( Level.Game.IsA('TO_DeathMatchPlus') )
	{
		result = TO_DeathMatchPlus(Level.Game).AssessBotAttitude(self, Other);
		Switch (result)
		{
			case 0: return ATTITUDE_Fear;
			case 1: return ATTITUDE_Hate;
			case 2: return ATTITUDE_Ignore;
			case 3: return ATTITUDE_Friendly;
		}
	}

	if ( Level.Game.bTeamGame && (PlayerReplicationInfo.Team == Other.PlayerReplicationInfo.Team) )
		return ATTITUDE_Friendly; //teammate

	return ATTITUDE_Hate;
}


///////////////////////////////////////
// AssessThreat 
///////////////////////////////////////

function float AssessThreat( Pawn NewThreat )
{
	local float ThreatValue, NewStrength, Dist;
	local eAttitude NewAttitude;

	NewStrength = RelativeStrength(NewThreat);

	ThreatValue = FMax(0, NewStrength);
	if ( NewThreat.Health < 20 )
		ThreatValue += 0.3;

	Dist = VSize(NewThreat.Location - Location);
	if ( Dist < 800 )
		ThreatValue += 0.3;

	if ( (NewThreat != Enemy) && (Enemy != None) )
	{
		if ( Dist > 0.7 * VSize(Enemy.Location - Location) )
			ThreatValue -= 0.25;
		ThreatValue -= 0.2;

		if ( !LineOfSightTo(Enemy) )
		{
			if ( Dist < 1200 )
				ThreatValue += 0.2;
			if ( SpecialPause > 0 )
				ThreatValue += 5;
			if ( IsInState('Hunting') && (NewStrength < 0.2) 
				&& (Level.TimeSeconds - LastSeenTime < 3)
				&& (relativeStrength(Enemy) < FMin(0, NewStrength)) )
				ThreatValue -= 0.3;
		}
	}

	if ( NewThreat.IsA('PlayerPawn') )
	{
		if ( Level.Game.bTeamGame )
			ThreatValue -= 0.15;
		else
			ThreatValue += 0.15;
	}

	if ( Level.Game.IsA('TO_DeathMatchPlus') )
		ThreatValue += TO_DeathMatchPlus(Level.Game).GameThreatAdd(self, NewThreat);
	return ThreatValue;
}


///////////////////////////////////////
// ReSetSkill 
///////////////////////////////////////

function ReSetSkill()
{
	//log(self$" at skill "$Skill$" novice "$bNovice);
	bThreePlus = ( (Skill >= 3) && Level.Game.IsA('TO_DeathMatchPlus') 
		&& TO_DeathMatchPlus(Level.Game).bThreePlus );
	bLeadTarget = ( !bNovice || bThreePlus );
	if ( bNovice )
		ReFireRate = Default.ReFireRate;
	else
		ReFireRate = Default.ReFireRate * (1 - 0.25 * skill);

	PreSetMovement();
}


///////////////////////////////////////
// ReSetSkill 
///////////////////////////////////////

function PreSetMovement()
{
	if (JumpZ > 0)
		bCanJump = true;
	bCanWalk = true;
	bCanSwim = true;
	bCanFly = false;
	MinHitWall = -0.5;
	bCanOpenDoors = true;
	bCanDoSpecial = true;
	SetPeripheralVision();
	bCanDuck = true;
	if ( bNovice )
	{
		RotationRate.Yaw = 30000 + 3000 * skill;
//		bCanDuck = false;
		if ( bThreePlus )
			MaxDesiredSpeed = 1;
		else
		// Don't lower speed too much in Tactical Ops.
			MaxDesiredSpeed = 0.8 + 0.066 * skill;
//		bCanDuck = false;
	}
	else
	{
		MaxDesiredSpeed = 1;
		if ( Skill == 3 )
			RotationRate.Yaw = 100000;
		else
			RotationRate.Yaw = 40000 + 11000 * skill;
//		bCanDuck = ( skill > 1 );
	}
}


///////////////////////////////////////
// MaybeTaunt 
///////////////////////////////////////

function MaybeTaunt(Pawn Other)
{
	if ( (FRand() < 0.25) && (Orders != 'Attack')
		&& (!Level.Game.IsA('TO_TeamGamePlus') || (TO_TeamGamePlus(Level.Game).PriorityObjective(self) < 1)) )
	{
		Target = Other;
		GotoState('VictoryDance');
	}
	else
		GotoState('Attacking'); 
}


///////////////////////////////////////
// FindAmbushSpot 
///////////////////////////////////////

function bool FindAmbushSpot()
{
	local Pawn P;
	local	int	i;

	bSpecialAmbush = false;
	if ( (AmbushSpot == None) && Level.Game.IsA('TO_DeathMatchPlus') )
		TO_DeathMatchPlus(Level.Game).PickAmbushSpotFor(self);

	if ( bSpecialAmbush )
		return true;

	if ( (AmbushSpot == None) && (Ambushpoint(MoveTarget) != None)
		&& !AmbushPoint(MoveTarget).taken )
		AmbushSpot = Ambushpoint(MoveTarget);
					
	if ( Ambushspot != None )
	{
		GoalString = "Ambush"@Ambushspot;
		Ambushspot.taken = true;
		if ( VSize(Ambushspot.Location - Location) < 2 * CollisionRadius )
		{
			GoalString = GoalString$" there";	
			if ( !bInitLifeMessage && (Orders == 'Defend') )
			{
				bInitLifeMessage = true;	
				SendTeamMessage(None, 'OTHER', 9, 60);
			}
			if ( Level.Game.bTeamGame )
				for ( P=Level.PawnList; P!=None; P=P.NextPawn )
				{
					i++;
					if ( i > 100 )
						break;

					if ( P.bIsPlayer && (P.PlayerReplicationInfo != None)
						&& (P.PlayerReplicationInfo.Team == PlayerReplicationInfo.Team)
						&& P.IsA('Bot') && (P != self) 
						&& (Bot(P).Ambushspot == AmbushSpot) )
							Bot(P).AmbushSpot = None;
				}
			bSniping = ((Orders == 'Defend') && AmbushSpot.bSniping);
			CampTime = 10.0;
			SightRadius = AmbushSpot.SightRadius;
			GotoState('Roaming', 'LongCamp');
			return true;
		}
		if ( ActorReachable(Ambushspot) )
		{
			GoalString = GoalString$" reachable";	
			MoveTarget = Ambushspot;
			return true;
		}
		GoalString = GoalString$" path there";	
		MoveTarget = FindPathToward(Ambushspot);
		if ( MoveTarget != None )
			return true;
		Ambushspot.taken = false;
		GoalString = "No ambush";
		Ambushspot = None;
	}
	return false;
}	


///////////////////////////////////////
// Charging
///////////////////////////////////////

state Charging
{
ignores SeePlayer, HearNoise;

	/* MayFall() called by engine physics if walking and bCanJump, and
		is about to go off a ledge.  Pawn has opportunity (by setting 
		bCanJump to false) to avoid fall
	*/

	function MayFall()
	{
		//bCanJump = false;
		
		if ( MoveTarget != Enemy )
			return;

		bCanJump = ( ActorReachable(Enemy) );
		if ( !bCanJump )
				GotoState('TacticalMove', 'NoCharge');
		
	}
}


///////////////////////////////////////
// Wandering
///////////////////////////////////////

state Wandering
{
	ignores EnemyNotVisible;

	function bool TestDirection(vector dir, out vector pick)
	{	
		local vector HitLocation, HitNormal, dist;
		local float minDist;
		local actor HitActor;

		if (OrderObject == None)
			return false;

		minDist = FMin(150.0, 4*CollisionRadius);
		if ( (Orders == 'Follow') && (VSize(Location - OrderObject.Location) < 500) )
			pick = dir * (minDist + (200 + 6 * CollisionRadius) * FRand());
		else
			pick = dir * (minDist + (450 + 12 * CollisionRadius) * FRand());

		HitActor = Trace(HitLocation, HitNormal, Location + pick + 1.5 * CollisionRadius * dir , Location, false);
		if (HitActor != None)
		{
			pick = HitLocation + (HitNormal - dir) * 2 * CollisionRadius;
			if ( !FastTrace(pick, Location) )
				return false;
		}
		else
			pick = Location + pick;
		 
		dist = pick - Location;
		if (Physics == PHYS_Walking)
			dist.Z = 0;
		
		return (VSize(dist) > minDist); 
	}
}


///////////////////////////////////////
// Roaming
///////////////////////////////////////

state Roaming
{
	ignores EnemyNotVisible;

	function EnemyAcquired()
	{
		GotoState('Acquisition');
	}

	function PickDestination()
	{
		local inventory Inv, BestInv;
		local float Bestweight, NewWeight, DroppedDist;
		local actor BestPath;
		local decoration Dec;
		local NavigationPoint N;
		local int i;
		local bool bTriedToPick, bLockedAndLoaded, bNearPoint;
		local byte TeamPriority;
		local Pawn P;

		//log("s_BotBase::Roaming::PickDestination - enterring function for"@GetHumanName());
	
		if ( Level.Game.IsA('TO_TeamGamePlus') )
		{
			if ( (Orders == 'FreeLance') && !bStayFreelance &&	(BotReplicationInfo(PlayerReplicationInfo) != None) 
				&& (Orders != BotReplicationInfo(PlayerReplicationInfo).RealOrders) ) 
				SetOrders(BotReplicationInfo(PlayerReplicationInfo).RealOrders, BotReplicationInfo(PlayerReplicationInfo).RealOrderGiver, true);
			
			if ( FRand() < 0.5 )
				bStayFreelance = false;

			LastAttractCheck = Level.TimeSeconds - 0.1;
			if ( TO_TeamGamePlus(Level.Game).FindSpecialAttractionFor(self) )
			{
				if ( IsInState('Roaming') )
				{
					TeamPriority = TO_TeamGamePlus(Level.Game).PriorityObjective(self);
					if ( TeamPriority > 16 )
					{
						PickLocalInventory(160, 1.8);
						return;
					}
					else if ( TeamPriority > 1 )
					{
						PickLocalInventory(200, 1);
						return;
					}
					else if ( TeamPriority > 0 )
					{
						PickLocalInventory(280, 0.55);
						return;
					}
					PickLocalInventory(400, 0.5);
				}
				return;
			}
		}

		if ( Weapon != None )
			bLockedAndLoaded = ( (Weapon.AIRating > 0.4) && (Health > 60) );
		else
			bLockedAndLoaded = false;

		if (  Orders == 'Follow' )
		{
			if ( Pawn(OrderObject) == None )
				SetOrders('FreeLance', None);
			else if ( (Pawn(OrderObject).Health > 0) )
			{
				bNearPoint = CloseToPointMan(Pawn(OrderObject));
				if ( !bNearPoint )
				{
					if ( !bLockedAndLoaded )
					{
						bTriedToPick = true;
						if ( PickLocalInventory(600, 0) )
							return;

						if ( !OrderObject.IsA('PlayerPawn') )
						{
							BestWeight = 0;
							BestPath = FindBestInventoryPath(BestWeight, !bNovice && (skill >= 2));
							if ( BestPath != None )
							{
								MoveTarget = BestPath;
								return;
							}
						}
					}				
					if ( ActorReachable(OrderObject) )
						MoveTarget = OrderObject;
					else
						MoveTarget = FindPathToward(OrderObject);
					if ( (MoveTarget != None) && (VSize(Location - MoveTarget.Location) > 2 * CollisionRadius) )
						return;
					if ( (VSize(OrderObject.Location - Location) < 1600) && LineOfSightTo(OrderObject) )
						bNearPoint = true;
					if ( bVerbose )
						log(self$" found no path to "$OrderObject);
				}
				else if ( !bInitLifeMessage && (Pawn(OrderObject).Health > 0) 
							&& (VSize(Location - OrderObject.Location) < 500) )
				{
					bInitLifeMessage = true;
					SendTeamMessage(Pawn(OrderObject).PlayerReplicationInfo, 'OTHER', 3, 10);
				}
			}
		}

		if ( (Orders == 'Defend') && bLockedAndLoaded )
		{
			if ( PickLocalInventory(300, 0.55) )
				return;
			if ( FindAmbushSpot() ) 
				return;
			if ( !LineOfSightTo(OrderObject) )
			{
				MoveTarget = FindPathToward(OrderObject);
				if ( MoveTarget != None )
					return;
			}
			else if ( !bInitLifeMessage )
			{
				bInitLifeMessage = true;
				SendTeamMessage(None, 'OTHER', 9, 10);
			}
		}

		if ( (Orders == 'Hold') && bLockedAndLoaded && !LineOfSightTo(OrderObject) )
		{
			GotoState('Hold');
			return;
		}

		if ( !bTriedToPick && PickLocalInventory(600, 0) )
			return;

		if ( (Orders == 'Hold') && bLockedAndLoaded )
		{
			if ( VSize(Location - OrderObject.Location) < 20 )
				GotoState('Holding');
			else
				GotoState('Hold');
			return;
		}

		if ( ((Orders == 'Follow') && (bNearPoint || (Level.Game.IsA('TO_TeamGamePlus') && TO_TeamGamePlus(Level.Game).WaitForPoint(self))))
			|| ((Orders == 'Defend') && bLockedAndLoaded && LineOfSightTo(OrderObject)) )
		{
			if ( FRand() < 0.35 )
				GotoState('Wandering');
			else
			{
				CampTime = 0.8;
				GotoState('Roaming', 'Camp');
			}
			return;
		}

		if ( (OrderObject != None) && !OrderObject.IsA('Ambushpoint') )
			bWantsToCamp = false;
		else if ( (Weapon.AIRating > 0.5) && (Health > 90) && !Region.Zone.bWaterZone )
		{
			bWantsToCamp = ( bWantsToCamp || (FRand() < CampingRate * FMin(1.0, Level.TimeSeconds - LastCampCheck)) );
			LastCampCheck = Level.TimeSeconds;
		}
		else 
			bWantsToCamp = false;

		if ( bWantsToCamp && FindAmbushSpot() )
			return;

		// if none found, check for decorations with inventory
		if ( !bNoShootDecor )
			foreach visiblecollidingactors(class'Decoration', Dec, 500,,true)
				if ( Dec.Contents != None )
				{
					bNoShootDecor = true;
					Target = Dec;
					GotoState('Roaming', 'ShootDecoration');
					return;
				}

		bNoShootDecor = false;
		BestWeight = 0;

		// look for long distance inventory 
		BestPath = FindBestInventoryPath(BestWeight, !bNovice && (skill >= 2));
		//log("roam to"@BestPath);
		//log("---------------------------------");
		if ( BestPath != None )
		{
			MoveTarget = BestPath;
			return;
		}

		// nothing around - maybe just wait a little
		if ( (FRand() < 0.35) && bNovice 
			&& (!Level.Game.IsA('TO_DeathMatchPlus') || !TO_DeathMatchPlus(Level.Game).OneOnOne())  )
		{
			GoalString = " Nothing cool, so camp ";
			CampTime = 3.5 + FRand() - skill;
			GotoState('Roaming', 'Camp');
		}

		// if roamed to ambush point, stay there maybe
		if ( (AmbushPoint(RoamTarget) != None)
			&& (VSize(Location - RoamTarget.Location) < 2 * CollisionRadius)
			&& (FRand() < 0.4) )
		{
			CampTime = 4.0;
			GotoState('Roaming', 'LongCamp');
			return;
		}

		// hunt player
		if ( (!bNovice || (Level.Game.IsA('TO_DeathMatchPlus') && TO_DeathMatchPlus(Level.Game).OneOnOne()))
			&& (weapon != None) && (Weapon.AIRating > 0.5) && (Health > 60) )
		{
			if ( (PlayerPawn(RoamTarget) != None) && !LineOfSightTo(RoamTarget) )
			{
				BestPath = FindPathToward(RoamTarget);
				if ( BestPath != None )
				{
					MoveTarget = BestPath;
					return;
				}
			}
			else
			{
				// high skill bots go hunt player
				for ( P=Level.PawnList; P!=None; P=P.NextPawn )
					if ( P.bIsPlayer && P.IsA('PlayerPawn') 
						&& ((VSize(P.Location - Location) > 1500) || !LineOfSightTo(P)) )
					{
						BestPath = FindPathToward(P);
						if ( BestPath != None )
						{
							RoamTarget = P;
							MoveTarget = BestPath;
							return;
						}
					}
			}
			bWantsToCamp = true; // don't camp if couldn't go to player
		}
		
		// look for ambush spot if didn't already try
		if ( !bWantsToCamp && FindAmbushSpot() )
		{
			RoamTarget = AmbushSpot;
			return;
		}
		
		// find a roamtarget
		if ( RoamTarget == None )
		{
			i = 0;
			for ( N=Level.NavigationPointList; N!=None; N=N.NextNavigationPoint )
				if ( N.IsA('InventorySpot') )
				{
					i++;
					if ( (RoamTarget == None) || (Rand(i) == 0) )
						RoamTarget = N;
				}
		}	

		// roam around
		if ( RoamTarget != None )
		{
			if ( ActorReachable(RoamTarget) )
			{
				MoveTarget = RoamTarget;
				RoamTarget = None;
				if ( VSize(MoveTarget.Location - Location) > 2 * CollisionRadius )
					return;
			}
			else
			{
				BestPath = FindPathToward(RoamTarget);
				if ( BestPath != None )
				{
					MoveTarget = BestPath;
					return;
				}
				else
					RoamTarget = None;
			}
		}
												
		 // wander or camp
		if ( FRand() < 0.35 )
			GotoState('Wandering');
		else
		{
			GoalString = " Nothing cool, so camp ";
			CampTime = 3.5 + FRand() - skill;
			//log("s_BotBase::Roaming::PickDestination -"@GetHumanName()@"has nothing to do!! camp.."@CampTime);
			GotoState('Roaming', 'Camp');
		}
	}


LongCamp:
	//log("s_BotBase::Roaming::LongCamp -"@GetHumanName() );
	bCamping = true;
	Acceleration = vect(0,0,0);
	TweenToWaiting(0.15);
	TurnTo(Location + Ambushspot.lookdir);
	Sleep(CampTime);
	Goto('PreBegin');

GiveWay:	
	//log("s_BotBase::Roaming::GiveWay -"@GetHumanName() );
	//log("sharing");	
	bCamping = true;
	Acceleration = vect(0,0,0);
	if ( GetAnimGroup(AnimSequence) != 'Waiting' )
		TweenToWaiting(0.15);
	if ( NearWall(200) )
	{
		PlayTurning();
		TurnTo(MoveTarget.Location);
	}
	Sleep(CampTime);
	Goto('PreBegin');

Camp:
	//log("s_BotBase::Roaming::Camp -"@GetHumanName() );
	bCamping = true;
	Acceleration = vect(0,0,0);
	TweenToWaiting(0.15);

ReCamp:
	//log("s_BotBase::Roaming::ReCamp -"@GetHumanName() );
	if ( NearWall(200) )
	{
		PlayTurning();
		TurnTo(Focus);
	}
	Sleep(CampTime);
	if ( bLeading || bCampOnlyOnce )
	{
		bCampOnlyOnce = false;
		Goto('PreBegin');
	}
	if ( ((Orders != 'Follow') || ((Pawn(OrderObject).Health > 0) && CloseToPointMan(Pawn(OrderObject)))) 
		&& (Weapon != None) && (Weapon.AIRating > 0.4) && (3 * FRand() > skill + 1) )
		Goto('ReCamp');

PreBegin:
	//log("s_BotBase::Roaming::PreBegin -"@GetHumanName()@"calls PickDestination");
	SetPeripheralVision();
	WaitForLanding();
	bCamping = false;
	PickDestination();
	TweenToRunning(0.1);
	bCanTranslocate = false;
	Goto('SpecialNavig');

Begin:
	//log("s_BotBase::Roaming::Begin -"@GetHumanName());
	SwitchToBestWeapon();
	bCamping = false;

	// Avoid RunAway loops
//	sleep(3.5 + FRand() - Skill);

	TweenToRunning(0.1);
	WaitForLanding();
	
RunAway:
	//log("s_BotBase::Roaming::RunAway -"@GetHumanName()@"calls PickDestination");
	PickDestination();
	bCanTranslocate = false;

SpecialNavig:
	//log("s_BotBase::Roaming::SpecialNavig -"@GetHumanName() );
	if (SpecialPause > 0.0)
	{
		Disable('AnimEnd');
		Acceleration = vect(0,0,0);
		TweenToPatrolStop(0.3);
		Sleep(SpecialPause);
		SpecialPause = 0.0;
		Enable('AnimEnd');
		TweenToRunning(0.1);
		//log("s_BotBase::Roaming::SpecialNavig -"@GetHumanName()@" RunAway!");
		Goto('RunAway');
	}

Moving:
	//log("s_BotBase::Roaming::Moving -"@GetHumanName() );

	if ( !IsAnimating() )
		AnimEnd();
	if ( MoveTarget == None )
	{
		Acceleration = vect(0,0,0);
		Sleep(0.0);
		//log("s_BotBase::Roaming::Moving -"@GetHumanName()@"calls MoveTarget==None, RunAway!");
		Goto('RunAway');
	}
	if ( MoveTarget.IsA('InventorySpot') )
	{
		if ( (!Level.Game.IsA('TO_TeamGamePlus') || (TO_TeamGamePlus(Level.Game).PriorityObjective(self) == 0))
			&& (InventorySpot(MoveTarget).markedItem != None)
			&& (InventorySpot(MoveTarget).markedItem.BotDesireability(self) > 0) )
		{
			if ( InventorySpot(MoveTarget).markedItem.GetStateName() == 'Pickup' )
				MoveTarget = InventorySpot(MoveTarget).markedItem;
			else if (	(InventorySpot(MoveTarget).markedItem.LatentFloat < 5.0)
						&& (InventorySpot(MoveTarget).markedItem.GetStateName() == 'Sleeping')	
						&& (abs(Location.Z - MoveTarget.Location.Z) < CollisionHeight)
						&& (VSize(Location - MoveTarget.Location + vect(0,0,1) * (MoveTarget.Location.Z - Location.Z)) < CollisionRadius * CollisionRadius) )
			{
				CampTime = FMin(5, InventorySpot(MoveTarget).markedItem.LatentFloat + 0.5);
				bCampOnlyOnce = true;
				Goto('Camp');
			}
		}
		else if ( MoveTarget.IsA('TrapSpringer')
				&& (abs(Location.Z - MoveTarget.Location.Z) < CollisionHeight)
				&& (VSize(Location - MoveTarget.Location + vect(0,0,1) * (MoveTarget.Location.Z - Location.Z)) < CollisionRadius * CollisionRadius) )
		{
			PlayVictoryDance();	
			bCampOnlyOnce = true;		
			bCamping = true;
			CampTime = 1.2;
			Acceleration = vect(0,0,0);
			Goto('ReCamp');
		}
	}
	else if ( MoveTarget.IsA('Inventory') && Level.Game.bTeamGame )
	{
		if ( Orders == 'Follow' )
			ShareWith(Pawn(OrderObject));
		else if ( SupportingPlayer != None )
			ShareWith(SupportingPlayer);
	}

	//log("s_BotBase::Roaming::Moving -"@GetHumanName()@"MoveToward(MoveTarget), RunAway!");
	bCamping = false;
	MoveToward(MoveTarget);
	Goto('RunAway');

TakeHit:
	//log("s_BotBase::Roaming::TakeHit -"@GetHumanName() );
	TweenToRunning(0.12);
	Goto('Moving');

Landed:
	//log("s_BotBase::Roaming::Landed -"@GetHumanName() );
	if ( MoveTarget == None ) 
	{
		//log("s_BotBase::Roaming::Landed -"@GetHumanName()@"MoveToward==None, RunAway!");
		Goto('RunAway');
	}
	Goto('Moving');

AdjustFromWall:
	//log("s_BotBase::Roaming::AdjustFromWall -"@GetHumanName() );
	if ( !IsAnimating() )
		AnimEnd();
	bWallAdjust = true;
	bCamping = false;
	StrafeTo(Destination, Focus); 
	Destination = Focus; 
	MoveTo(Destination);
	bWallAdjust = false;
	Goto('Moving');

ShootDecoration:
	//log("s_BotBase::Roaming::ShootDecoration -"@GetHumanName() );
	TurnToward(Target);
	if ( Target != None )
	{
		FireWeapon();
		bAltFire = 0;
		bFire = 0;
	}
	//log("s_BotBase::Roaming::ShootDecoration -"@GetHumanName()@" RunAway!");
	Goto('RunAway');
}


///////////////////////////////////////
// Attacking
///////////////////////////////////////

state Attacking
{
ignores SeePlayer, HearNoise, Bump, HitWall;

	function ChooseAttackMode()
	{
		local eAttitude AttitudeToEnemy;
		local float Aggression;
		local pawn changeEn;
		local TO_TeamGamePlus TG;
		local bool bWillHunt;

		bWillHunt = bMustHunt;
		bMustHunt = false;
		if ((Enemy == None) || (Enemy.Health <= 0))
		{
			WhatToDoNext('','');
			return;
		}

		if ( Weapon == None )
		{
			// ugly hack
			if ( Health < 1 )
			{
				TakeDamage(5, None, Location, vect(0, 0, 0), 'Suicided');
				GotoState('GameEnded');
				//Destroy();
				return;
			}
			log(self$" health "$health$" had no weapon");
			SwitchToBestWeapon();
		}

		AttitudeToEnemy = AttitudeTo(Enemy);
		TG = TO_TeamGamePlus(Level.Game);
		if ( TG != None )
		{
			if ( (Level.TimeSeconds - LastAttractCheck > 0.5)
				|| (AttitudeToEnemy == ATTITUDE_Fear)
				|| (TG.PriorityObjective(self) > 1) ) 
			{
				goalstring = "attract check";
				if ( TG.FindSpecialAttractionFor(self) )
					return;
				if ( Enemy == None )
				{
					WhatToDoNext('','');
					return;
				}
			}
			else
			{
				goalstring = "no attract check";
			}
		}
			
		if (AttitudeToEnemy == ATTITUDE_Fear)
		{
			GotoState('Retreating');
			return;
		}
		else if (AttitudeToEnemy == ATTITUDE_Friendly)
		{
			WhatToDoNext('','');
			return;
		}
		else if ( !LineOfSightTo(Enemy) )
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
				goalstring = "attract check";
				if ( (TG != None) && TG.FindSpecialAttractionFor(self) )
					return;
				if ( Enemy == None )
				{
					WhatToDoNext('','');
					return;
				}
				if ( (Orders == 'Hold') && (Level.TimeSeconds - LastSeenTime > 5) )
				{
					NumHuntPaths = 0; 
					GotoState('StakeOut');
				}
				else if ( bWillHunt || (!bSniping && (VSize(Enemy.Location - Location) 
							> 600 + (FRand() * RelativeStrength(Enemy) - CombatStyle) * 600)) )
				{
					bDevious = ( !bNovice && !Level.Game.bTeamGame && Level.Game.IsA('TO_DeathMatchPlus') 
								&& (FRand() < 0.52 - 0.12 * TO_DeathMatchPlus(Level.Game).NumBots) );
					GotoState('Hunting');
				}
				else
				{
					NumHuntPaths = 0; 
					GotoState('StakeOut');
				}
				return;
			}
		}	
		
		if (bReadyToAttack)
		{
			////log("Attack!");
			Target = Enemy;
			SetTimer(TimeBetweenAttacks, False);
		}
			
		GotoState('TacticalMove');
	}
	
	//EnemyNotVisible implemented so engine will update LastSeenPos
	function EnemyNotVisible()
	{
		////log("enemy not visible");
	}

	function Timer()
	{
		bReadyToAttack = True;
	}

	function BeginState()
	{
		if ( TimerRate <= 0.0 )
			SetTimer(TimeBetweenAttacks  * (1.0 + FRand()),false); 
		if (Physics == PHYS_None)
			SetMovementPhysics(); 
	}

Begin:
	//log(class$" choose Attack");
	ChooseAttackMode();
}


///////////////////////////////////////
// Fallback
///////////////////////////////////////

state Fallback
{
ignores EnemyNotVisible;

	function PickDestination()
	{
		local byte TeamPriority;

		if ( Level.TimeSeconds - LastSeenTime > 9 )
			Enemy = None;
		if ( Enemy == None )
		{
			WhatToDoNext('','');
			return;
		}

		LastAttractCheck = Level.TimeSeconds - 0.1;

		if ( Level.Game.IsA('TO_TeamGamePlus')
			&& TO_TeamGamePlus(Level.Game).FindSpecialAttractionFor(self) )
		{
			if ( IsInState('Fallback') )
			{
				TeamPriority = TO_TeamGamePlus(Level.Game).PriorityObjective(self);
				if ( TeamPriority > 16 )
				{
					PickLocalInventory(160, 1.8);
					return;
				}
				else if ( TeamPriority > 1 )
				{
					PickLocalInventory(200, 1);
					return;
				}
				else if ( TeamPriority > 0 )
				{
					PickLocalInventory(200, 0.55);
					return;
				}
				PickLocalInventory(400, 0.5);
				if ( MoveTarget == None )
				{
					if ( bVerbose )
						log(self$" no destination in fallback!");
					Orders = 'Freelance';
					GotoState('Attacking');
				}
			}
			return;
		}
		else if ( (Orders == 'Attack') || (OrderObject == None) )
		{
			if ( bVerbose )
				log(self$" attack fallback turned to freelance");
			Orders = 'Freelance';
			GotoState('Attacking');
		}
		else if ( (VSize(Location - OrderObject.Location) < 20)
			|| ((VSize(Location - OrderObject.Location) < 600) && LineOfSightTo(OrderObject)) )
		{
			if ( Enemy.IsA('TeamCannon') || ((Level.TimeSeconds - LastSeenTime > 5) && (Orders == 'Hold')) )
			{
				Enemy = OldEnemy;
				OldEnemy = None;
			}
			GotoState('Attacking');
		}
		else if ( ActorReachable(OrderObject) )
			MoveTarget = OrderObject;
		else
		{
			MoveTarget = FindPathToward(OrderObject);
			if ( MoveTarget == None )
			{
				if ( bVerbose )
					log(self@"fallback turned to freelance (no path to"@OrderObject@")");
				Orders = 'Freelance';
				GotoState('Attacking');
			}
		}
	}


Begin:
	TweenToRunning(0.12);
	WaitForLanding();
	
RunAway:
	PickDestination();
	bAdvancedTactics = ( !bNovice && (Level.TimeSeconds - LastSeenTime < 1.0) 
						&& (Skill > 2.5 * FRand() - 1)
						&& (!MoveTarget.IsA('NavigationPoint') || !NavigationPoint(MoveTarget).bNeverUseStrafing) );
SpecialNavig:
	if (SpecialPause > 0.0)
	{
		if ( LineOfSightTo(Enemy) )
		{
			Target = Enemy;
			bFiringPaused = true;
			NextState = 'Fallback';
			NextLabel = 'RunAway';
			GotoState('RangedAttack');
		}
		Disable('AnimEnd');
		Acceleration = vect(0,0,0);
		TweenToPatrolStop(0.3);
		Sleep(SpecialPause);
		SpecialPause = 0.0;
		Enable('AnimEnd');
		TweenToRunning(0.1);
		Goto('RunAway');
	}
Moving:
	if ( !IsAnimating() )
		AnimEnd();

	if ( MoveTarget == None )
	{
		Sleep(0.0);
		Goto('RunAway');
	}
	if ( FaceDestination(1) )
	{
		HaltFiring();
		MoveToward(MoveTarget);
	}
	else
	{
		bReadyToAttack = True;
		bCanFire = true;
		StrafeFacing(MoveTarget.Location, Enemy);
	}
	Goto('RunAway');

Landed:
	if ( MoveTarget == None )
		Goto('RunAway');
	Goto('Moving');

TakeHit:
	TweenToRunning(0.12);
	Goto('Moving');

AdjustFromWall:
	if ( !IsAnimating() )
		AnimEnd();
	StrafeTo(Destination, Focus); 
	Destination = Focus; 
	MoveTo(Destination);
	Goto('Moving');
}


///////////////////////////////////////
// TacticalMove
///////////////////////////////////////

state TacticalMove
{
ignores SeePlayer, HearNoise;

	function PickRegDestination(bool bNoCharge)
	{
		local vector pickdir, enemydir, enemyPart, X,Y,Z, minDest;
		local actor HitActor;
		local vector HitLocation, HitNormal, collSpec;
		local float Aggression, enemydist, minDist, strafeSize, optDist;
		local bool success, bNoReach;
	
		if ( Orders == 'Hold' )
			bNoCharge = true;

		bChangeDir = false;
		if (Region.Zone.bWaterZone && !bCanSwim && bCanFly)
		{
			Destination = Location + 75 * (VRand() + vect(0,0,1));
			Destination.Z += 100;
			return;
		}
		if ( Enemy.Region.Zone.bWaterZone )
			bNoCharge = bNoCharge || !bCanSwim;
		else 
			bNoCharge = bNoCharge || (!bCanFly && !bCanWalk);
		
		if( Weapon.bMeleeWeapon && !bNoCharge )
		{
			GotoState('Charging');
			return;
		}
		enemyDist = VSize(Location - Enemy.Location);
		if ( (bNovice && (FRand() > 0.3 + 0.15 * skill)) || (FRand() > 0.7 + 0.15 * skill) 
			&& ((EnemyDist > 900) || (Enemy.Weapon == None) || !Enemy.Weapon.bMeleeWeapon) 
			&& (!Level.Game.IsA('TO_TeamGamePlus') || (TO_TeamGamePlus(Level.Game).PriorityObjective(self) == 0)) )
			GiveUpTactical(true);

		success = false;
		if ( (bSniping || (Orders == 'Hold'))  
			&& (!Level.Game.IsA('TO_TeamGamePlus') || (TO_TeamGamePlus(Level.Game).PriorityObjective(self) == 0)) )
			bNoCharge = true;
		if ( bSniping && Weapon.IsA('SniperRifle') )
		{
			bReadyToAttack = true;
			GotoState('RangedAttack');
			return;
		}
						
		Aggression = 2 * (CombatStyle + FRand()) - 1.1;
		if ( Enemy.bIsPlayer && (AttitudeTo(Enemy) == ATTITUDE_Fear) && (CombatStyle > 0) )
			Aggression = Aggression - 2 - 2 * CombatStyle;
		if ( Weapon != None )
			Aggression += 2 * Weapon.SuggestAttackStyle();
		if ( Enemy.Weapon != None )
			Aggression += 2 * Enemy.Weapon.SuggestDefenseStyle();

		if ( enemyDist > 1000 )
			Aggression += 1;
		if ( !bNoCharge )
			bNoCharge = ( Aggression < FRand() );

		if ( (Physics == PHYS_Walking) || (Physics == PHYS_Falling) )
		{
			if (Location.Z > Enemy.Location.Z + 150) //tactical height advantage
				Aggression = FMax(0.0, Aggression - 1.0 + CombatStyle);
			else if (Location.Z < Enemy.Location.Z - CollisionHeight) // below enemy
			{
				if ( !bNoCharge && (Aggression > 0) && (FRand() < 0.6) )
				{
					GotoState('Charging');
					return;
				}
				else if ( (enemyDist < 1.1 * (Enemy.Location.Z - Location.Z)) 
						&& !actorReachable(Enemy) ) 
				{
					bNoReach = true;
					aggression = -1.5 * FRand();
				}
			}
		}
	
		if (!bNoCharge && (Aggression > 2 * FRand()))
		{
			if ( bNoReach && (Physics != PHYS_Falling) )
			{
				TweenToRunning(0.1);
				GotoState('Charging', 'NoReach');
			}
			else
				GotoState('Charging');
			return;
		}

		if ( !bNovice && ((Weapon == None) || !Weapon.bRecommendSplashDamage) && (FRand() < 0.35) && (bJumpy || (FRand()*Skill > 0.4)) )
		{
			GetAxes(Rotation,X,Y,Z);

			if ( FRand() < 0.5 )
			{
				Y *= -1;
				TryToDuck(Y, true);
			}
			else
				TryToDuck(Y, false);
			if ( !IsInState('TacticalMove') )
				return;
		}
			
		if (enemyDist > FMax(VSize(OldLocation - Enemy.OldLocation), 240))
			Aggression += 0.4 * FRand();
			 
		enemydir = (Enemy.Location - Location)/enemyDist;
		if ( bJumpy )
			minDist = 160;
		else
			minDist = FMin(160.0, 3*CollisionRadius);
		optDist = 80 + FMin(EnemyDist, 250 * (FRand() + FRand()));  
		Y = (enemydir Cross vect(0,0,1));
		if ( Physics == PHYS_Walking )
		{
			Y.Z = 0;
			enemydir.Z = 0;
		}
		else 
			enemydir.Z = FMax(0,enemydir.Z);
			
		strafeSize = FMax(-0.7, FMin(0.85, (2 * Aggression * FRand() - 0.3)));
		enemyPart = enemydir * strafeSize;
		strafeSize = FMax(0.0, 1 - Abs(strafeSize));
		pickdir = strafeSize * Y;
		if ( bStrafeDir )
			pickdir *= -1;
		bStrafeDir = !bStrafeDir;
		collSpec.X = CollisionRadius;
		collSpec.Y = CollisionRadius;
		collSpec.Z = FMax(6, CollisionHeight - 18);
		
		minDest = Location + minDist * (pickdir + enemyPart);
		HitActor = Trace(HitLocation, HitNormal, minDest, Location, false, collSpec);
		if (HitActor == None)
		{
			success = (Physics != PHYS_Walking);
			if ( !success )
			{
				collSpec.X = FMin(14, 0.5 * CollisionRadius);
				collSpec.Y = collSpec.X;
				HitActor = Trace(HitLocation, HitNormal, minDest - (18 + MaxStepHeight) * vect(0,0,1), minDest, false, collSpec);
				success = (HitActor != None);
			}
			if (success)
				Destination = minDest + (pickdir + enemyPart) * optDist;
		}
	
		if ( !success )
		{					
			collSpec.X = CollisionRadius;
			collSpec.Y = CollisionRadius;
			minDest = Location + minDist * (enemyPart - pickdir); 
			HitActor = Trace(HitLocation, HitNormal, minDest, Location, false, collSpec);
			if (HitActor == None)
			{
				success = (Physics != PHYS_Walking);
				if ( !success )
				{
					collSpec.X = FMin(14, 0.5 * CollisionRadius);
					collSpec.Y = collSpec.X;
					HitActor = Trace(HitLocation, HitNormal, minDest - (18 + MaxStepHeight) * vect(0,0,1), minDest, false, collSpec);
					success = (HitActor != None);
				}
				if (success)
					Destination = minDest + (enemyPart - pickdir) * optDist;
			}
			else 
			{
				if ( (CombatStyle <= 0) || (Enemy.bIsPlayer && (AttitudeTo(Enemy) == ATTITUDE_Fear)) )
					enemypart = vect(0,0,0);
				else if ( (enemydir Dot enemyPart) < 0 )
					enemyPart = -1 * enemyPart;
				pickDir = Normal(enemyPart - pickdir + HitNormal);
				minDest = Location + minDist * pickDir;
				collSpec.X = CollisionRadius;
				collSpec.Y = CollisionRadius;
				HitActor = Trace(HitLocation, HitNormal, minDest, Location, false, collSpec);
				if (HitActor == None)
				{
					success = (Physics != PHYS_Walking);
					if ( !success )
					{
						collSpec.X = FMin(14, 0.5 * CollisionRadius);
						collSpec.Y = collSpec.X;
						HitActor = Trace(HitLocation, HitNormal, minDest - (18 + MaxStepHeight) * vect(0,0,1), minDest, false, collSpec);
						success = (HitActor != None);
					}
					if (success)
						Destination = minDest + pickDir * optDist;
				}
			}	
		}
					
		if ( !success )
			GiveUpTactical(bNoCharge);
		else 
		{
			if ( bJumpy || (Weapon.bRecommendSplashDamage && !bNovice 
				&& (FRand() < 0.2 + 0.2 * Skill)
				&& (Enemy.Location.Z - Enemy.CollisionHeight <= Location.Z + MaxStepHeight - CollisionHeight)) 
				&& !NeedToTurn(Enemy.Location) )
			{
				FireWeapon();
				if ( (bJumpy && (FRand() < 0.75)) || Weapon.SplashJump() )
				{
					// try jump move
					SetPhysics(PHYS_Falling);
					Acceleration = vect(0,0,0);
					Destination = minDest;
					NextState = 'Attacking'; 
					NextLabel = 'Begin';
					NextAnim = 'Fighter';
					GotoState('FallingState');
					return;
				}
			}
			pickDir = (Destination - Location);
			enemyDist = VSize(pickDir);
			if ( enemyDist > minDist + 2 * CollisionRadius )
			{
				pickDir = pickDir/enemyDist;
				HitActor = Trace(HitLocation, HitNormal, Destination + 2 * CollisionRadius * pickdir, Location, false);
				if ( (HitActor != None) && ((HitNormal Dot pickDir) < -0.6) )
					Destination = HitLocation - 2 * CollisionRadius * pickdir;
			}
		}
	}


	function BeginState()
	{
		if ( bNovice ) 
			// Don't lower speed too much in TO
			MaxDesiredSpeed = 0.6 + 0.13 * skill;
		MinHitWall += 0.15;
		bAvoidLedges = true;
		bStopAtLedges = true;
		bCanJump = false;
		bCanFire = false;
	}
	
	function EndState()
	{
		if ( bNovice ) 
			// Don't lower speed too much in TO
			MaxDesiredSpeed = 0.8 + 0.066 * skill;
		bAvoidLedges = false;
		bStopAtLedges = false;
		bQuickFire = false;
		MinHitWall -= 0.15;
		if (JumpZ > 0)
			bCanJump = true;
	}


TacticalTick:
	Sleep(0.02);	
Begin:
	TweenToRunning(0.15);
	Enable('AnimEnd');
	if (Physics == PHYS_Falling)
	{
		DesiredRotation = Rotator(Enemy.Location - Location);
		Focus = Enemy.Location;
		Destination = Enemy.Location;
		WaitForLanding();
	}
	PickDestination(false);

DoMove:
	if ( !bCanStrafe )
	{ 
DoDirectMove:
		Enable('AnimEnd');
		if ( GetAnimGroup(AnimSequence) == 'MovingAttack' )
		{
			AnimSequence = '';
			TweenToRunning(0.12);
		}
		HaltFiring();
		MoveTo(Destination);
	}
	else
	{
DoStrafeMove:
		Enable('AnimEnd');
		bCanFire = true;
		StrafeFacing(Destination, Enemy);	
	}

	if ( (Enemy != None) && !LineOfSightTo(Enemy) && FastTrace(Enemy.Location, LastSeeingPos) )
		Goto('RecoverEnemy');
	else
	{
		bReadyToAttack = true;
		GotoState('Attacking');
	}
	
NoCharge:
	TweenToRunning(0.1);
	Enable('AnimEnd');
	if (Physics == PHYS_Falling)
	{
		DesiredRotation = Rotator(Enemy.Location - Location);
		Focus = Enemy.Location;
		Destination = Enemy.Location;
		WaitForLanding();
	}
	PickDestination(true);
	Goto('DoMove');
	
AdjustFromWall:
	Enable('AnimEnd');
	StrafeTo(Destination, Focus); 
	Destination = Focus; 
	Goto('DoMove');

TakeHit:
	TweenToRunning(0.12);
	Goto('DoMove');

RecoverEnemy:
	Enable('AnimEnd');
	bReadyToAttack = true;
	HidingSpot = Location;
	bCanFire = false;
	Destination = LastSeeingPos + 4 * CollisionRadius * Normal(LastSeeingPos - Location);
	StrafeFacing(Destination, Enemy);

	if ( !Weapon.bMeleeWeapon && LineOfSightTo(Enemy) && CanFireAtEnemy() )
	{
		Disable('AnimEnd');
		DesiredRotation = Rotator(Enemy.Location - Location);
		bQuickFire = true;
		FireWeapon();
		bQuickFire = false;
		Acceleration = vect(0,0,0);
		if ( Weapon.bSplashDamage )
		{
			bFire = 0;
			bAltFire = 0;
			bReadyToAttack = true;
			Sleep(0.2);
		}
		else
			Sleep(0.35 + 0.3 * FRand());
		if ( (FRand() + 0.1 > CombatStyle) )
		{
			bFire = 0;
			bAltFire = 0;
			bReadyToAttack = true;
			Enable('EnemyNotVisible');
			Enable('AnimEnd');
			Destination = HidingSpot + 4 * CollisionRadius * Normal(HidingSpot - Location);
			Goto('DoMove');
		}
	}

	GotoState('Attacking');
}


///////////////////////////////////////
// Hunting
///////////////////////////////////////

state Hunting
{
ignores EnemyNotVisible; 

	function PickDestination()
	{
		local inventory Inv, BestInv, SecondInv;
		local float Bestweight, NewWeight, MaxDist, SecondWeight;
		local NavigationPoint path;
		local actor HitActor;
		local vector HitNormal, HitLocation, nextSpot, ViewSpot;
		local float posZ;
		local bool bCanSeeLastSeen;
		local int i;

		// If no enemy, or I should see him but don't, then give up		
		if ( Level.TimeSeconds - LastSeenTime > 26 - Level.Game.NumPlayers - TO_DeathMatchPlus(Level.Game).NumBots )
			Enemy = None;
		if ( (Enemy == None) || (Enemy.Health <= 0) )
		{
			WhatToDoNext('','');
			return;
		}
	
		bAvoidLedges = false;

		if ( JumpZ > 0 )
			bCanJump = true;
		
		if ( ActorReachable(Enemy) )
		{
			BlockedPath = None;
			if ( (numHuntPaths < 8 + Skill) || (Level.TimeSeconds - LastSeenTime < 15)
				|| ((Normal(Enemy.Location - Location) Dot vector(Rotation)) > -0.5) )
			{
				Destination = Enemy.Location;
				MoveTarget = None;
				numHuntPaths++;
			}
			else
				WhatToDoNext('','');
			return;
		}

		if ( Level.TimeSeconds - LastInvFind > 2.5 - 0.4 * skill )
		{
			LastInvFind = Level.TimeSeconds;
			MaxDist = 600 + 70 * skill;
			BestWeight = 0.6/MaxDist;
			foreach visiblecollidingactors(class'Inventory', Inv, MaxDist,, true)
				if ( (Inv.IsInState('PickUp')) && (Inv.MaxDesireability/200 > BestWeight)
					&& (Inv.Location.Z < Location.Z + MaxStepHeight + CollisionHeight)
					&& (Inv.Location.Z > FMin(Location.Z, Enemy.Location.Z) - CollisionHeight) )
				{
					NewWeight = inv.BotDesireability(self)/VSize(Inv.Location - Location);
					if ( NewWeight > BestWeight )
					{
						SecondWeight = BestWeight;
						BestWeight = NewWeight;
						SecondInv = BestInv;
						BestInv = Inv;
					}
				}

			if ( BestInv != None )
			{
				if ( TryToward(BestInv, BestWeight) )
					return;

				if ( (SecondInv != None) && TryToward(SecondInv, SecondWeight) )
					return;
			}
		}

		numHuntPaths++;

		ViewSpot = Location + BaseEyeHeight * vect(0,0,1);
		bCanSeeLastSeen = false;
		bCanSeeLastSeen = FastTrace(LastSeenPos, ViewSpot);
		if ( bCanSeeLastSeen )
			bHunting = !FastTrace(LastSeenPos, Enemy.Location);
		else
			bHunting = true;

		if ( bDevious )
		{
			if ( BlockedPath == None )
			{
				// block the first path visible to the enemy
				if ( FindPathToward(Enemy) != None )
				{
					for ( i=0; i<16; i++ )
					{
						if ( RouteCache[i] == None )
							break;
						else if ( Enemy.LineOfSightTo(RouteCache[i]) )
						{
							BlockedPath = RouteCache[i];
							break;
						}
					}
				}
				else if ( CanStakeOut() )
				{
					GotoState('StakeOut');
					return;
				}
				else
				{
					WhatToDoNext('', '');
					return;
				}
			}
			// control path weights
			ClearPaths();
			BlockedPath.Cost = 1500;
			if ( FindBestPathToward(Enemy, false) )
				return;
		}
		else if ( FindBestPathToward(Enemy, true) )
			return;

		MoveTarget = None;
		if ( bFromWall )
		{
			bFromWall = false;
			if ( !PickWallAdjust() )
			{
				if ( CanStakeOut() )
					GotoState('StakeOut');
				else
					WhatToDoNext('', '');
			}
			return;
		}
		
		if ( (NumHuntPaths > 60) && (bNovice || !Level.Game.IsA('TO_DeathMatchPlus') || !TO_DeathMatchPlus(Level.Game).OneOnOne()) )
		{
			WhatToDoNext('', '');
			return;
		}

		if ( LastSeeingPos != vect(1000000,0,0) )
		{
			Destination = LastSeeingPos;
			LastSeeingPos = vect(1000000,0,0);		
			if ( FastTrace(Enemy.Location, ViewSpot) )
			{
				If (VSize(Location - Destination) < 20)
				{
					SetEnemy(Enemy);
					return;
				}
				return;
			}
		}

		bAvoidLedges = (CollisionRadius > 42);
		posZ = LastSeenPos.Z + CollisionHeight - Enemy.CollisionHeight;
		nextSpot = LastSeenPos - Normal(Enemy.Location - Enemy.OldLocation) * CollisionRadius;
		nextSpot.Z = posZ;
		if ( FastTrace(nextSpot, ViewSpot) )
			Destination = nextSpot;
		else if ( bCanSeeLastSeen )
			Destination = LastSeenPos;
		else
		{
			Destination = LastSeenPos;
			if ( !FastTrace(LastSeenPos, ViewSpot) )
			{
				// check if could adjust and see it
				if ( PickWallAdjust() || FindViewSpot() )
				{
					if ( Physics == PHYS_Falling )
						SetFall();
					else
						GotoState('Hunting', 'AdjustFromWall');
				}
				else if ( VSize(Enemy.Location - Location) < 1200 )
				{
					GotoState('StakeOut');
					return;
				}
				else
				{
					WhatToDoNext('Waiting', 'TurnFromWall');
					return;
				}
			}
		}
		LastSeenPos = Enemy.Location;				
	}	

AdjustFromWall:
	Enable('AnimEnd');
	StrafeTo(Destination, Focus); 
	Destination = Focus; 
	if ( MoveTarget != None )
		Goto('SpecialNavig');
	else
		Goto('Follow');

Begin:
	numHuntPaths = 0;

AfterFall:
	TweenToRunning(0.1);
	bFromWall = false;

Follow:
	if ( Level.Game.IsA('TO_TeamGamePlus') )
		TO_TeamGamePlus(Level.Game).FindSpecialAttractionFor(self);
	if ( bSniping )
		GotoState('StakeOut');
	if ( (Orders == 'Hold') || (Orders == 'Follow') ) 
	{
		if ( !LineOfSightTo(OrderObject) )
			GotoState('Fallback');
	}
	else if ( Orders == 'Defend' )
	{
		if ( AmbushSpot != None )
		{
			if ( !LineOfSightTo(AmbushSpot) )
				GotoState('Fallback');
		}
		else if ( !LineOfSightTo(OrderObject) )
			GotoState('Fallback');
	}
	WaitForLanding();
	if ( CanSee(Enemy) )
		SetEnemy(Enemy);
	PickDestination();

SpecialNavig:
	if ( SpecialPause > 0.0 )
	{
		Disable('AnimEnd');
		Acceleration = vect(0,0,0);
		bFire = 0;
		bAltFire = 0;
		PlayChallenge();
		Sleep(SpecialPause);
		SpecialPause = 0.0;
		Enable('AnimEnd');
		Goto('AfterFall');
	}
	if (MoveTarget == None)
		MoveTo(Destination);
	else
		MoveToward(MoveTarget); 

	Goto('Follow');
}


///////////////////////////////////////
// StakeOut
///////////////////////////////////////

state StakeOut
{
ignores EnemyNotVisible; 


Begin:
	if ( AmbushSpot == None )
		bSniping = false;
	if ( (bSniping && (VSize(Location - AmbushSpot.Location) > 3 * CollisionRadius)) 
		|| (Level.Game.IsA('TO_DeathMatchPlus') && TO_DeathMatchPlus(Level.Game).NeverStakeOut(self)) )
	{
		Enemy = None;
		OldEnemy = None;
		WhatToDoNext('','');
	}
	Acceleration = vect(0,0,0);
	PlayChallenge();
	TurnTo(LastSeenPos);
	if ( Enemy == None )
		WhatToDoNext('','');
	if ( (Weapon != None) && !Weapon.bMeleeWeapon && (FRand() < 0.5) && (VSize(Enemy.Location - LastSeenPos) < 150) 
		 && ClearShot() && CanStakeOut() )
		PlayRangedAttack();
	else
	{
		bFire = 0;
		bAltFire = 0;
	}
	FinishAnim();
	if ( !bNovice || (FRand() < 0.65) )
		TweenToWaiting(0.17);
	else
		PlayChallenge();
	Sleep(1 + FRand());
	if ( Level.Game.IsA('TO_TeamGamePlus') )
		TO_TeamGamePlus(Level.Game).FindSpecialAttractionFor(self);
	if ( ContinueStakeOut() )
	{
		if ( bSniping && (AmbushSpot != None) )
			LastSeenPos = Location + Ambushspot.lookdir;
		else if ( (FRand() < 0.3) || !FastTrace(LastSeenPos + vect(0,0,0.9) * Enemy.CollisionHeight, Location + vect(0,0,0.8) * CollisionHeight) )
			FindNewStakeOutDir();
		Goto('Begin');
	}
	else
	{
		if ( bSniping )
			WhatToDoNext('','');
		BlockedPath = None;	
		bDevious = ( !bNovice && !Level.Game.bTeamGame && Level.Game.IsA('TO_DeathMatchPlus') 
					&& (FRand() < 0.75 - 0.15 * TO_DeathMatchPlus(Level.Game).NumBots) );
		GotoState('Hunting', 'AfterFall');
	}
}


///////////////////////////////////////
// Dying
///////////////////////////////////////

state Dying
{
ignores SeePlayer, EnemyNotVisible, HearNoise, Died, Bump, Trigger, HitWall, HeadZoneChange, FootZoneChange, ZoneChange, Falling, WarnTarget, LongFall, SetFall, PainTimer;
	
	function BeginState()
	{
		if ( (Level.NetMode != NM_Standalone) 
			&& Level.Game.IsA('TO_DeathMatchPlus')
			&& TO_DeathMatchPlus(Level.Game).TooManyBots() )
		{
			Destroy();
			return;
		}
		SetTimer(0, false);
		Enemy = None;
		if ( bSniping && (AmbushSpot != None) )
			AmbushSpot.taken = false;
		AmbushSpot = None;
		PointDied = -1000;
		bFire = 0;
		bAltFire = 0;
		bSniping = false;
		bKamikaze = false;
		bDevious = false;
		bDumbDown = false;
		BlockedPath = None;
		bInitLifeMessage = false;
		MyTranslocator = None;
	}


Begin:
	if ( Level.Game.bGameEnded )
		GotoState('GameEnded');
	Sleep(0.2);
	if ( !bHidden )
		SpawnCarcass();

TryAgain:
	if ( !bHidden )
		HidePlayer();
	Sleep(0.25 + TO_DeathMatchPlus(Level.Game).SpawnWait(self));
	ReStartPlayer();
	Goto('TryAgain');

WaitingForStart:
	bHidden = true;
}


///////////////////////////////////////
// GetFloorMaterial
///////////////////////////////////////

simulated function EFloorMaterial GetFloorMaterial()
{
	local	Sound		FootSound;

	if (Shadow == None || s_PlayerShadow(Shadow) == None)
		return FM_Stone;

	s_PlayerShadow(Shadow).ForceUpdate();
	if (s_PlayerShadow(Shadow).WalkTexture != None)
		FootSound = s_PlayerShadow(Shadow).WalkTexture.FootstepSound;
	else
		return FM_Stone;

	if ( FootSound == None )
		return FM_Stone;

	if ( FootSound == OldFootSound )
		return OldFloorMaterial;

	OldFootSound = FootSound;

	if (FootSound == Sound'TODatas.footsteps.FM_metalstep1' /*|| 
		FootSound == Sound'TODatas.footsteps.FM_metalstep2'*/)
		OldFloorMaterial = FM_metalstep;

	else if (FootSound == Sound'TODatas.footsteps.FM_snowstep1' /* || 
		FootSound == Sound'TODatas.footsteps.FM_snowstep2'*/)
		OldFloorMaterial = FM_snowstep;

	else if (FootSound == Sound'TODatas.footsteps.FM_stonestep1' /*|| 
		FootSound == Sound'TODatas.footsteps.FM_stonestep2'*/)
		OldFloorMaterial = FM_stonestep;

	else if (FootSound == Sound'TODatas.footsteps.FM_woodstep1' /*|| 
		FootSound == Sound'TODatas.footsteps.FM_woodstep2'*/)
		OldFloorMaterial = FM_woodstep;

	else if (FootSound == Sound'TODatas.footsteps.FM_woodwarmstep1'/* || 
		FootSound == Sound'TODatas.footsteps.FM_woodwarmstep2'*/)
		OldFloorMaterial = FM_woodwarmstep;

	else if (FootSound == Sound'TODatas.footsteps.FM_grass1' /*|| 
		FootSound == Sound'TODatas.footsteps.FM_grass2' || 
		FootSound == Sound'TODatas.footsteps.FM_grass3'*/)
		OldFloorMaterial = FM_grass;

	else if (FootSound == Sound'TODatas.footsteps.FM_water1'/* || 
		FootSound == Sound'TODatas.footsteps.FM_water2' || 
		FootSound == Sound'TODatas.footsteps.FM_water3'*/)
		OldFloorMaterial = FM_water;

	else if (FootSound == Sound'TODatas.footsteps.FM_smallgravel1' /* || 
		FootSound == Sound'TODatas.footsteps.FM_smallgravel2' || 
		FootSound == Sound'TODatas.footsteps.FM_smallgravel3'*/)
		OldFloorMaterial = FM_smallgravel;

	else if (FootSound == Sound'TODatas.footsteps.FM_carpet1' /*|| 
		FootSound == Sound'TODatas.footsteps.FM_carpet2' || 
		FootSound == Sound'TODatas.footsteps.FM_carpet3'*/)
		OldFloorMaterial = FM_carpet;

	else if (FootSound == Sound'TODatas.footsteps.FM_highgrass1'/* || 
		FootSound == Sound'TODatas.footsteps.FM_highgrass2' || 
		FootSound == Sound'TODatas.footsteps.FM_highgrass3'*/)
		OldFloorMaterial = FM_highgrass;

	else if (FootSound == Sound'TODatas.footsteps.FM_mud1'/* || 
		FootSound == Sound'TODatas.footsteps.FM_mud2' || 
		FootSound == Sound'TODatas.footsteps.FM_mud3'*/)
		OldFloorMaterial = FM_mud;

	else if (FootSound == Sound'TODatas.footsteps.FM_pebbles1'/* || 
		FootSound == Sound'TODatas.footsteps.FM_pebbles2' || 
		FootSound == Sound'TODatas.footsteps.FM_pebbles3'*/)
		OldFloorMaterial = FM_pebbles;

	else if (FootSound == Sound'TODatas.footsteps.FM_sand1' /*|| 
		FootSound == Sound'TODatas.footsteps.FM_sand2' || 
		FootSound == Sound'TODatas.footsteps.FM_sand3'*/)
		OldFloorMaterial = FM_sand;

	else if (FootSound == Sound'TODatas.footsteps.FM_sandwet1'/* || 
		FootSound == Sound'TODatas.footsteps.FM_sandwet2' || 
		FootSound == Sound'TODatas.footsteps.FM_sandwet3'*/)
		OldFloorMaterial = FM_sandwet;

	else if (FootSound == Sound'TODatas.footsteps.FM_snow1'/* || 
		FootSound == Sound'TODatas.footsteps.FM_snow2' || 
		FootSound == Sound'TODatas.footsteps.FM_snow3'*/)
		OldFloorMaterial = FM_snow;

	else if (FootSound == Sound'TODatas.footsteps.FM_rocky1'/* || 
		FootSound == Sound'TODatas.footsteps.FM_rocky2' || 
		FootSound == Sound'TODatas.footsteps.FM_rocky3'*/)
		OldFloorMaterial = FM_rocky;

	else if (FootSound == Sound'TODatas.footsteps.FM_concrete1'/* || 
		FootSound == Sound'TODatas.footsteps.FM_concrete2' || 
		FootSound == Sound'TODatas.footsteps.FM_concrete3'*/)
		OldFloorMaterial = FM_concrete;

	else if (FootSound == Sound'TODatas.footsteps.FM_glass1'/* || 
		FootSound == Sound'TODatas.footsteps.FM_glass2' || 
		FootSound == Sound'TODatas.footsteps.FM_glass3' || 
		FootSound == Sound'TODatas.footsteps.FM_glass4'*/)
		OldFloorMaterial = FM_glass;

	else if (FootSound == Sound'TODatas.footsteps.FM_rock1' /* || 
		FootSound == Sound'TODatas.footsteps.FM_rock2' || 
		FootSound == Sound'TODatas.footsteps.FM_rock3'*/)
		OldFloorMaterial = FM_rock;

	else if (FootSound == Sound'TODatas.footsteps.FM_stonechurch1' /*|| 
		FootSound == Sound'TODatas.footsteps.FM_stonechurch2' || 
		FootSound == Sound'TODatas.footsteps.FM_stonechurch3'*/)
		OldFloorMaterial = FM_stonechurch;

	else
		OldFloorMaterial = FM_Stone;

	return OldFloorMaterial;
}


///////////////////////////////////////
// PlayFootStep
///////////////////////////////////////

simulated function PlayFootStep()
{
	local sound						step;
	local float						decision, VolumeMultiplier;
	local	EFloorMaterial	FM;
 
	if ( FootRegion.Zone.bWaterZone )
	{
		if ( decision < 0.25 )
			step = WaterStep;
		else if ( decision < 0.50 )
			step = Sound'FM_water1';
		else if ( decision < 0.75 )
			step = Sound'FM_water2';
		else 
			step = Sound'FM_water3';

		MakeNoise(0.3);
		PlaySound(step, SLOT_Interact, 1, false, 1000.0, 1.0);
		return;
	}

	if ( !bNovice )
		MakeNoise( 0.2 );
	else 
		MakeNoise(0.1);

	FM = GetFloorMaterial();
	decision = FRand();
	VolumeMultiplier = 1.0;

	switch (FM)
	{
		case FM_metalstep :
			VolumeMultiplier = 0.20;
			if ( decision < 0.50 )
				step = Sound'FM_metalstep1';
			else 
				step = Sound'FM_metalstep2';
			break;

		case FM_snowstep :
			if ( decision < 0.50 )
				step = Sound'FM_snowstep1';
			else 
				step = Sound'FM_snowstep2';
			break;

		case FM_stonestep :
			if ( decision < 0.50 )
				step = Sound'FM_stonestep1';
			else 
				step = Sound'FM_stonestep2';
			break;

		case FM_woodstep :
			if ( decision < 0.50 )
				step = Sound'FM_woodstep1';
			else 
				step = Sound'FM_woodstep2';
			break;

		case FM_woodwarmstep :
			if ( decision < 0.50 )
				step = Sound'FM_woodwarmstep1';
			else 
				step = Sound'FM_woodwarmstep2';
			break;

		case FM_grass :
			VolumeMultiplier = 0.15;
			if ( decision < 0.33 )
				step = Sound'FM_grass1';
			else if ( decision < 0.66 )
				step = Sound'FM_grass2';
			else 
				step = Sound'FM_grass3';
			break;

		case FM_smallgravel :
			VolumeMultiplier = 0.25;
			if ( decision < 0.33 )
				step = Sound'FM_smallgravel1';
			else if ( decision < 0.66 )
				step = Sound'FM_smallgravel2';
			else 
				step = Sound'FM_smallgravel3';
			break;

		case FM_carpet :
			if ( decision < 0.33 )
				step = Sound'FM_carpet1';
			else if ( decision < 0.66 )
				step = Sound'FM_carpet2';
			else 
				step = Sound'FM_carpet3';
			break;

		case FM_highgrass :
			if ( decision < 0.33 )
				step = Sound'FM_highgrass1';
			else if ( decision < 0.66 )
				step = Sound'FM_highgrass2';
			else 
				step = Sound'FM_highgrass3';
			break;

		case FM_mud :
			if ( decision < 0.33 )
				step = Sound'FM_mud1';
			else if ( decision < 0.66 )
				step = Sound'FM_mud2';
			else 
				step = Sound'FM_mud3';
			break;

		case FM_pebbles :
			if ( decision < 0.33 )
				step = Sound'FM_pebbles1';
			else if ( decision < 0.66 )
				step = Sound'FM_pebbles2';
			else 
				step = Sound'FM_pebbles3';
			break;

		case FM_sand :
			if ( decision < 0.33 )
				step = Sound'FM_sand1';
			else if ( decision < 0.66 )
				step = Sound'FM_sand2';
			else 
				step = Sound'FM_sand3';
			break;

		case FM_sandwet :
			if ( decision < 0.33 )
				step = Sound'FM_sandwet1';
			else if ( decision < 0.66 )
				step = Sound'FM_sandwet2';
			else 
				step = Sound'FM_sandwet3';
			break;

		case FM_snow :
			if ( decision < 0.33 )
				step = Sound'FM_snow1';
			else if ( decision < 0.66 )
				step = Sound'FM_snow2';
			else 
				step = Sound'FM_snow3';
			break;

		case FM_rocky :
			if ( decision < 0.33 )
				step = Sound'FM_rocky1';
			else if ( decision < 0.66 )
				step = Sound'FM_rocky2';
			else 
				step = Sound'FM_rocky3';
			break;

		case FM_water :
			if ( decision < 0.33 )
				step = Sound'FM_water1';
			else if ( decision < 0.66 )
				step = Sound'FM_water2';
			else 
				step = Sound'FM_water3';
			break;

		case FM_rock :
			VolumeMultiplier = 0.20;
			if ( decision < 0.33 )
				step = Sound'FM_rock1';
			else if ( decision < 0.66 )
				step = Sound'FM_rock2';
			else 
				step = Sound'FM_rock3';
			break;

		case FM_concrete :
			if ( decision < 0.33 )
				step = Sound'FM_concrete1';
			else if ( decision < 0.66 )
				step = Sound'FM_concrete2';
			else 
				step = Sound'FM_concrete3';
			break;

		case FM_glass :
			if ( decision < 0.25 )
				step = Sound'FM_glass1';
			else if ( decision < 0.50 )
				step = Sound'FM_glass2';
			else if ( decision < 0.75 )
				step = Sound'FM_glass3';
			else 
				step = Sound'FM_glass4';
			break;

		case FM_stonechurch :
			VolumeMultiplier = 0.30;
			if ( decision < 0.33 )
				step = Sound'FM_stonechurch1';
			else if ( decision < 0.66 )
				step = Sound'FM_stonechurch2';
			else 
				step = Sound'FM_stonechurch3';
			break;

		case FM_Stone :
		default	:
			if ( decision < 0.34 )
				step = Sound'stone02';
			else if (decision < 0.67 )
				step = Sound'stone04';
			else
				step = Sound'stone05';
	}

	if ( bIsCrouching )
		PlaySound(step, SLOT_Interact, 0.20 * VolumeMultiplier, false, 250.0, 1.0);
	else
		PlaySound(step, SLOT_Interact, 1.5 * VolumeMultiplier, false, 1000.0, 1.0);
}


///////////////////////////////////////
// defaultproperties
///////////////////////////////////////
// bAlwaysRelevant=true

defaultproperties
{
     StatusDoll=None
     StatusBelt=None
     bAlwaysRelevant=True
}
