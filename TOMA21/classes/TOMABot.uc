class TOMABot extends s_BotMCounterTerrorist1;

var byte WBR;
var int NbSpecialNade;
var byte CptIAR;
var carcass carc;
var int Mana;

function YellAt(Pawn Moron)
{
}

function Killed(pawn Killer, pawn Other, name damageType)
{
	local Pawn aPawn;

	if ( Killer == self )
		Other.Health = FMin(Other.Health, -11); // don't let other do stagger death

	if ( Health <= 0 )
		return;

	if ( OldEnemy == Other )
		OldEnemy = None;

	if ( Enemy == Other )
	{
		bFire = 0;
		bAltFire = 0;
		bReadyToAttack = ( skill > 3 * FRand() );
		EnemyDropped = Enemy.Weapon;
		Enemy = None;
		if ( (Killer == self) && (OldEnemy == None) )
		{
			for ( aPawn=Level.PawnList; aPawn!=None; aPawn=aPawn.nextPawn )
				if ( aPawn.bIsPlayer && aPawn.bCollideActors
					&& (VSize(Location - aPawn.Location) < 1600)
					&& CanSee(aPawn) && SetEnemy(aPawn) )
				{
					GotoState('Attacking');
					return;
				}

			MaybeTaunt(Other);
		}
		else
			GotoState('Attacking');
	}
	else if ( Level.Game.bTeamGame && Other.bIsPlayer
			&& (Other.PlayerReplicationInfo.Team == PlayerReplicationInfo.Team) )
	{
		if ( Other == Self )
			return;
		else
		{
/*			if ( (VSize(Location - Other.Location) < 1400)
				&& LineOfSightTo(Other) )
				SendTeamMessage(None, 'OTHER', 5, 10); */
			if ( (Orders == 'follow') && (Other == OrderObject) )
				PointDied = Level.TimeSeconds;
		}
	}
}

function TakeDamage(int Damage,Pawn instigatedBy,Vector hitlocation,Vector momentum,name damageType)
{
	local int actualDamage;
	local bool bAlreadyDead;

    if (CptIAR>0) return;

	bAlreadyDead = (Health <= 0);

	if (Physics == PHYS_None)
		SetMovementPhysics();
	if (Physics == PHYS_Walking)
		momentum.Z = FMax(momentum.Z, 0.4 * VSize(momentum));
	if ( instigatedBy == self )
		momentum *= 0.6;
	momentum = momentum/Mass;

	actualDamage = s_SWATGame(Level.Game).SWATReduceDamage(Damage, DamageType, self, instigatedBy, HitLocation-Location);
	if ( bIsPlayer )
	{
		if (ReducedDamageType == 'All') //God mode
			actualDamage = 0;
		else if (Inventory != None) //then check if carrying armor
			actualDamage = Inventory.ReduceDamage(actualDamage, DamageType, HitLocation);
		else
			actualDamage = Damage;
	}
	else if ( (InstigatedBy != None) &&
				(InstigatedBy.IsA(Class.Name) || self.IsA(InstigatedBy.Class.Name)) )
		ActualDamage = ActualDamage * FMin(1 - ReducedDamagePct, 0.35);
	else if ( (ReducedDamageType == 'All') ||
		((ReducedDamageType != '') && (ReducedDamageType == damageType)) )
		actualDamage = float(actualDamage) * (1 - ReducedDamagePct);

	if ( Level.Game.DamageMutator != None )
		Level.Game.DamageMutator.MutatorTakeDamage( ActualDamage, Self, InstigatedBy, HitLocation, Momentum, DamageType );

	//New damagebased scoresystem
	if (instigatedBy != none)
	{
		if (instigatedBy.IsA('s_Player'))
		{
			if ( PlayerReplicationInfo.Team == instigatedBy.PlayerReplicationInfo.Team ) {
				if ( Health > ActualDamage)
					if (TOMAMod(Level.Game).FriendlyFireScale>0) TO_PRI(instigatedBy.PlayerReplicationInfo).InflictedDmg -= actualDamage;
				else
					if (TOMAMod(Level.Game).FriendlyFireScale>0) TO_PRI(instigatedBy.PlayerReplicationInfo).InflictedDmg -= Health;
			} else {
				if (Health > ActualDamage)
					TO_PRI(instigatedBy.PlayerReplicationInfo).InflictedDmg += actualDamage;
				else
					TO_PRI(instigatedBy.PlayerReplicationInfo).InflictedDmg += Health;
			}
		} else if (instigatedBy.IsA('s_Bot')) {
        	if ( PlayerReplicationInfo.Team == instigatedBy.PlayerReplicationInfo.Team ) {
				if (Health > ActualDamage)
					if (TOMAMod(Level.Game).FriendlyFireScale>0) TO_BRI(instigatedBy.PlayerReplicationInfo).InflictedDmg -= actualDamage;
				else
					if (TOMAMod(Level.Game).FriendlyFireScale>0) TO_BRI(instigatedBy.PlayerReplicationInfo).InflictedDmg -= Health;
			} else {
				if (Health > ActualDamage)
					TO_BRI(instigatedBy.PlayerReplicationInfo).InflictedDmg += actualDamage;
				else
					TO_BRI(instigatedBy.PlayerReplicationInfo).InflictedDmg += Health;
			}
        } else if (instigatedBy.IsA('TOMAScriptedPawn')) {
        	if (Health > ActualDamage)
					TOMAMonstersReplicationInfo(instigatedBy.PlayerReplicationInfo).InflictedDmg += actualDamage;
				else
					TOMAMonstersReplicationInfo(instigatedBy.PlayerReplicationInfo).InflictedDmg += Health;
			}
		//else log("s_Player::TakeDamage - Instigator is not a pawn");
	} //else log("s_Player::TakeDamage - Instigator == none");

	AddVelocity( momentum );
	Health -= actualDamage;
	if (CarriedDecoration != None)
		DropDecoration();
	if ( HitLocation == vect(0,0,0) )
		HitLocation = Location;
	if (Health > 0)
	{
		if ( (instigatedBy != None) && (instigatedBy != Self) )
			damageAttitudeTo(instigatedBy);
		PlayHit(actualDamage, hitLocation, damageType, Momentum);
	}
	else if ( !bAlreadyDead )
	{
		//log(self$" died");
		NextState = '';
		PlayDeathHit(actualDamage, hitLocation, damageType, Momentum);
		if ( actualDamage > mass )
			Health = -1 * actualDamage;
		if ( (instigatedBy != None) && (instigatedBy != Self) )
			damageAttitudeTo(instigatedBy);
		Died(instigatedBy, damageType, HitLocation);
	}
	else
	{
		//Warn(self$" took regular damage "$damagetype$" from "$instigator$" while already dead");
		// SpawnGibbedCarcass();
		if ( bIsPlayer )
		{
			HidePlayer();
			GotoState('Dying');
		}
		else
			Destroy();
	}
	MakeNoise(1.0);
}

function bool BotGetWeapon(byte WeaponClass)
{
	local	class<s_Weapon>	W;
	local	int	i;

    if (TOMAMod(Level.Game).EnableNewWeapons)
    {
	for (i=0; i <= class'TOMA21.TOMAWeaponsHandler'.default.NumWeapons; i++)
	{
		if (class'TOMA21.TOMAWeaponsHandler'.default.WeaponStr[i] != ""
			&& (class'TOMA21.TOMAWeaponsHandler'.static.IsTeamMatch(Self, i))
			&& (FRand() < class'TOMA21.TOMAWeaponsHandler'.default.BotDesirability[i]) )
		{
			W = class<s_Weapon>( DynamicLoadObject(class'TOMA21.TOMAWeaponsHandler'.default.WeaponStr[i], class'Class') );

			if ( (FindInventoryType(W) == None) && (W.default.WeaponClass == WeaponClass) && (Money > W.default.Price) )
			{
				// Bot can buy weapon!
				//log("s_Bot::BotGetWeapon - BuyingWeapon:"@class'TOModels.TO_WeaponsHandler'.default.WeaponStr[i]);
				s_SWATGame(Level.Game).GiveWeapon(Self, class'TOMA21.TOMAWeaponsHandler'.default.WeaponStr[i]);
				Money -= W.default.Price;
				MakeNoise(0.75);
				return true;
			}
		}
	}
    }
    else
    {
	//log("s_Bot::BotGetWeapon - WeaponClass:"@WeaponClass);
	for (i=0; i <= class'TOModels.TO_WeaponsHandler'.default.NumWeapons; i++)
	{
		if (class'TOModels.TO_WeaponsHandler'.default.WeaponStr[i] != ""
			&& (class'TOModels.TO_WeaponsHandler'.static.IsTeamMatch(Self, i))
			&& (FRand() < class'TOModels.TO_WeaponsHandler'.default.BotDesirability[i]) )
		{
			W = class<s_Weapon>( DynamicLoadObject(class'TOModels.TO_WeaponsHandler'.default.WeaponStr[i], class'Class') );

			if ( (FindInventoryType(W) == None) && (W.default.WeaponClass == WeaponClass) && (Money > W.default.Price) )
			{
				// Bot can buy weapon!
				//log("s_Bot::BotGetWeapon - BuyingWeapon:"@class'TOModels.TO_WeaponsHandler'.default.WeaponStr[i]);
				s_SWATGame(Level.Game).GiveWeapon(Self, class'TOModels.TO_WeaponsHandler'.default.WeaponStr[i]);
				Money -= W.default.Price;
				MakeNoise(0.75);
				return true;
			}
		}
	}
    }
	return false;
}

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
//				SendTeamMessage(None, 'OTHER', 9, 60);
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
			if ( !IsInState('Roaming') ) //Added by Shag
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
			if ( (OrderObject==None) || (Pawn(OrderObject) == None) )
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
//					SendTeamMessage(Pawn(OrderObject).PlayerReplicationInfo, 'OTHER', 3, 10);
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
//				SendTeamMessage(None, 'OTHER', 9, 10);
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
			if ( OrderObject != none && VSize(Location - OrderObject.Location) < 20 ) // Onion - accessed none fix ?
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
			CampTime = Max(3.5 + FRand() - skill, 1.0);
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
			CampTime = Max(3.5 + FRand() - skill, 1.0);
			//log("s_BotBase::Roaming::PickDestination -"@GetHumanName()@"has nothing to do!! camp.."@CampTime);
			GotoState('Roaming', 'Camp');
		}
	}


LongCamp:
	//log("s_BotBase::Roaming::LongCamp -"@GetHumanName() );
	bCamping = true;
	Acceleration = vect(0,0,0);
	TweenToWaiting(0.15);
	if ( Ambushspot != None )
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
		if ( MoveTarget != None )
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
	if ( ((Orders != 'Follow')
		|| ((OrderObject!=None) && (Pawn(OrderObject).Health > 0) && CloseToPointMan(Pawn(OrderObject))))
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

function FireWeapon()
{
	local bool			bCover;
	local Weapon		MyGlock;
	local s_Weapon		W;
	local float			dist;
	local s_bot			bots;
	local pawn			victim, P;
	local vector		HitLocation, HitNormal,X,Y,Z,EndTrace;
	local actor			Other;
	local TO_ProjSmokeGren Smok;
	//local TO_CoverPoint CP;
	local PathNode		PN;
	local int			i;

	if (CptIAR>0) return;
	GetAxes(Rotation,X,Y,Z);

	EndTrace = Location + 10000 * X;

	Other = Trace(HitLocation, HitNormal, Location, EndTrace, true);

	if ((Other!=None) && (Other.IsA('Pawn')))
		victim=pawn(Other);


/*	if ( (victim!=None) && (victim.PlayerReplicationInfo.Team == PlayerReplicationInfo.Team) )
	{
		bReadyToAttack = false;
		return;
	}*/


	if ((Enemy==None) && (bShootSpecial))
	{
		//fake use s_Glock
		MyGlock=Weapon(FindInventoryType(class's_Glock'));
		if ((MyGlock==None) && (target!=none))
			Spawn(class's_Projectile',,,Location,Rotator(Target.Location-Location));
		else
			MyGlock.TraceFire(0);

		return;
	}

	SwitchToBestWeaponEx();

	if ( Weapon == None )
		return;

	if ( (Enemy == None) && (Target != None) )
	{
		if ( Weapon.IsA('TO_Grenade') )
			SwitchToBestWeaponEx();

		if (Weapon!=None)
		{
			PlayFiring();
			Weapon.Fire(1.0);
		}
		return;
	}

	if ( !Weapon.IsA('TO_Grenade') && !bGrenadeAvail )
		bGrenadeAvail = true;


	if (Weapon!=None)
	{
/*
		if ( (Weapon.AmmoType != None) && (Weapon.AmmoType.AmmoAmount <= 0) )
		{
			bReadyToAttack = true;
			return;
		}
*/
		W = s_Weapon(Weapon);

 		if ( !bComboPaused && !bShootSpecial && (Enemy != None) )
 			Target = Enemy;

		if ( (Enemy!=None) && !LineofSightTo(Enemy) )
			return;

		ViewRotation=Rotation;

/*
		if (bUseAltMode)
		{
			bFire = 0;
			bAltFire = 1;
			Weapon.AltFire(1.0);
		}
		else
		{
*/
		/*
		if (BlindTime>0 && (FRand() > 0.5) )
		{
			bReadyToAttack = false;
			return;
		}
		*/
		/*
		if ( Enemy != None )
			foreach radiusactors(class'TO_ProjSmokeGren',Smok,VSize(Enemy.Location - Location))
				if ( LineofSightTo(Smok) && (FRand() > 0.5) )
				{
					bReadyToAttack = false;
					return;
				}
		*/
		bCover = false;

		if ( (W!=None) && (W.clipAmmo < 2) || bTakeCover )
			bCover = true;

		bFire = 1;
		bAltFire = 0;
		if ( (W!=None) && !W.IsA('TO_Grenade') )
		{
			PlayFiring();
			if ( BlindTime > 0 )
				Weapon.Fire(2.0);
			else
				Weapon.Fire(1.0);
		}
		else
		{
			//PlayFiring();
			TO_Grenade(Weapon).BotThrowGrenade();
			//PlayGrenadeThrow();

			if ( Enemy != None )
				for ( P=Level.PawnList; P!=None; P=P.nextPawn )
				{
					if ( P.IsA('s_bot') )
					{
						bots = s_bot(P);

						if ( (bots!=None) && (VSize(bots.Location - Location) < 700))
//							&& (bots.PlayerReplicationInfo.Team == PlayerReplicationInfo.Team) )
							{
								//bots.bReadyToAttack = false;
								bots.Destination = bots.Location + 700 * Normal(bots.Location - Enemy.Location);
								bots.GotoState('TacticalMove','DoMove');
							}
					}
				}

			//bReadyToAttack = false;
			Destination = Location + 700 * Normal(bots.Location - Location);
			GotoState('TacticalMove','DoMove');
		}

		if ( bCover && (Enemy!=None) )
		{
			// FIXME Optimize by creating a TO_CoverPoint linked list in TO_GameBasics
			/*
			foreach radiusactors(class'TO_CoverPoint', CP, 1000)
				if ( !CP.bUsed )
					if ( VSize(Enemy.Location - CP.Location) > VSize(Location - CP.Location) && !Enemy.LineOfSightTo(CP))
					{
						CP.bUsed = false;
						CP.BotUsing = Self;
						Focus = Enemy.Location;
						Destination = CP.Location;
						bTakeCover = false;
						bCover = false;
						bReadyToAttack = false;
						GotoState('Cover','Moving');
						return;
					}
			*/

			foreach radiusactors(class'PathNode', PN, 1000)
				if ( !Enemy.LineOfSightTo(PN) && (VSize(Enemy.Location - PN.Location) > VSize(Location - PN.Location)) )
					{
						i++;
						if (i>10)
							break;

						Focus = Enemy.Location;
						Destination = PN.Location;
						bTakeCover = false;
						bCover = false;
						bReadyToAttack = false;
						GotoState('Cover','Moving');
						break;
					}

		}

		//}
	}
	bCover = false;
	bShootSpecial = false;

}

function CallForHelp()
{
}

state TacticalMove
{
ignores SeePlayer, HearNoise;

	function Timer()
	{

		bReadyToAttack = True;
		Enable('Bump');
		Target = Enemy;
		if ( Enemy == None )
			return;
		if (VSize(Enemy.Location - Location)
				<= (MeleeRange + Enemy.CollisionRadius + CollisionRadius))
			GotoState('RangedAttack');
		else if ( Weapon!=None && !Weapon.bMeleeWeapon && ((Enemy.Weapon == None) || !Enemy.Weapon.bMeleeWeapon) )
		{
			if ( bNovice )
			{
				if ( FRand() > 0.4 + 0.18 * skill )
					GotoState('RangedAttack');
			}
			else if ( FRand() > 0.5 + 0.17 * skill )
				GotoState('RangedAttack');
		}
	}

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

	///////////
//RAVER
///////////

RecoverEnemy:
	//Acceleration = vect(0,0,0);
	Enable('AnimEnd');
	bReadyToAttack = true;
	HidingSpot = Location;
	bCanFire = false;
	if ( !LineOfSightTo(Enemy) )
	{
		Destination = LastSeeingPos + 4 * CollisionRadius * Normal(LastSeeingPos - Location);
		StrafeFacing(Destination, Enemy);
	}

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
			Goto('RecoverEnemy');
		}
	}

////////////
//RAVER - END
////////////
/*
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
*/
	GotoState('Attacking');
}

function bool SwitchToBestWeaponEx()
{
	local float					dist, currentmass;
	local byte					wepnr;
	local s_GrenadeAway Gren;
	local Pawn					P;
	local	Weapon				NewWeapon;
	local	s_Weapon			sW, CurrentsW;
	local	bool					bTeamMates;

	if ( Weapon!=None )
		currentmass = Weapon.mass;
	else
		currentmass = 15;


	if ( (Weapon==None) || (Enemy == None) )
	{
		for (TempInv=Inventory; TempInv!=None; TempInv=TempInv.Inventory)
		{
			if ( (TempInv!=None) && TempInv.IsA('s_weapon') && !TempInv.IsA('TO_Binocs'))
			{
				sW = s_Weapon(TempInv);
				if ( ((sW!=None) && (sW.WeaponID > WepNr) ) && CheckWeaponAmmo(sW) )
				{
					NewWeapon = sW;
					WepNr = sW.WeaponID;
				}
			}
		}
	}
	else
	{

		CurrentsW = s_Weapon(Weapon);

		WepNr = 0;

		if (Enemy!=None) Dist = VSize(Enemy.Location - Location);

		if ( s_weapon(weapon)!=none && s_weapon(Weapon).bUseAmmo && (s_weapon(Weapon).ClipAmmo>1) && ( (Dist>480) && (Dist<4800) ) && (s_weapon(Weapon).MaxRange>Dist) && FRand()<0.3 )
			return false;

		for (TempInv=Inventory; TempInv != None; TempInv = TempInv.Inventory)
		{
			if ( TempInv.IsA('s_weapon') && !TempInv.IsA('TO_Binocs'))
			{
				sW = s_Weapon(TempInv);
				if ( (sW!=None) && CheckWeaponAmmo(sW) )
				{
					//Bad Hack
					if ( Dist < 4800 )
					{

						if ( (sW.MaxRange > Dist) && !sW.IsA('TO_Grenade') && !sW.IsA('s_C4') && sW.ClipAmmo>1 && (!CheckWeaponAmmo(CurrentsW) || CurrentsW.MaxRange<Dist) )
						{
							bSniping = false;

							if ( (sW!=Weapon) && (sW.WeaponID > WepNr) )
							{
								NewWeapon = sW;
								WepNr = sW.WeaponID;
							}
							//break;
						}

						if ( sW.IsA('TO_Grenade') && bGrenadeAvail && (Dist>1000) && (FRand()<0.66) )
						{
							bTeamMates = false;
/*							if ( !sW.IsA('s_GrenadeFB') && !sW.IsA('TO_GrenadeSmoke') )
								for ( P=Level.PawnList; P!=None; P=P.nextPawn )
								{
									// Check if grenade can hurt team mates.
									if ( ((P.PlayerReplicationInfo!=None) && (P.PlayerReplicationInfo.Team==PlayerReplicationInfo.Team) || (P.PlayerReplicationInfo.Team==2)) && (Enemy!=None) && (VSize(Enemy.Location - P.Location) < 700) )
										bTeamMates = true;
								}
*/
							if ( !bTeamMates  )
							{
							//log("throwing grenade Dist:"@Dist);
								//TO_Grenade(sW).Power = Dist/100.0;
								bGrenadeAvail = false;

								if ( sW!=Weapon )
									NewWeapon = sW;
								break;
							}
						}
					}
					else
						if ( sW!=None && (sW.MaxRange > Dist) && !sW.IsA('TO_Grenade') && !sW.IsA('s_C4') && sW.ClipAmmo>1 && (!CheckWeaponAmmo(CurrentsW) || CurrentsW.MaxRange<Dist) )
						{
							bSniping = true;

							if ( (sW!=Weapon) && (sW.WeaponID > WepNr) )
							{
								NewWeapon = sW;
								WepNr = sW.WeaponID;
							}
							//break;
						}
				}
			}
		}
	}

	// Switch to new weapon
	if ( NewWeapon!=None )
	{
		// PlayWeaponSwitch if needed
		if ( NewWeapon.Mass != CurrentMass )
			PlayWeaponSwitch(NewWeapon);

		PendingWeapon = NewWeapon;

		if ( Weapon!=None && Weapon != PendingWeapon )
			Weapon.PutDown();
	}

	return true;
}

state RangedAttack
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
	if (Enemy!=None) DesiredRotation = Rotator(Enemy.Location - Location);
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
	if ( Target != None ) DesiredRotation = Rotator(Target.Location - Location);
	TweenToFighter(0.16 - 0.2 * Skill);

FaceTarget:
	Disable('AnimEnd');
	if ( Target!=None && NeedToTurn(Target.Location) )
	{
		PlayTurning();
		TurnToward(Target);
		TweenToFighter(0.1);
	}
	FinishAnim();

ReadyToAttack:
	if ( Target != None ) DesiredRotation = Rotator(Target.Location - Location);
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

function Carcass SpawnCarcass()
{

	//log("s_Player::SpawnCarcass - s:"@GetStateName());
	carc = Super.SpawnCarcass();

	// Hack to fix problem with dead players blocking
	//SetCollision(false, false, false);
	//SetCollisionSize(1.0, 1.0);
	HidePlayer();

	return carc;
}

function Escape()
{
}

defaultproperties
{
}

