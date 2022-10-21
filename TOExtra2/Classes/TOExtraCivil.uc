class TOExtraCivil extends s_botbase;

var		bool										bDead, bNotPlaying, bSpecialItem;

var		byte							O_number, LastO_number;		// Objective number in TO_ScenarioInfo
var		Actor							LastOrderObject;
var		byte							O_Count;		// Objectives assignments during the round.

var		byte							PlayerModel;

var		name							OldState;		// Saves the bots state while BotBuying
var   int								MaxFallHeight;

///////////////////////////////////////
// YellAt
///////////////////////////////////////

function YellAt(Pawn Moron)
{
}

///////////////////////////////////////
// GetVoiceType
///////////////////////////////////////

function byte GetVoiceType()
{
	return 0;
}


///////////////////////////////////////
// CallForHelp
///////////////////////////////////////

function CallForHelp()
{
}


///////////////////////////////////////
// SendVoiceMessage
///////////////////////////////////////

function SendVoiceMessage(PlayerReplicationInfo Sender, PlayerReplicationInfo Recipient, name messagetype, byte messageID, name broadcasttype)
{
}


///////////////////////////////////////
// PostBeginPlay
///////////////////////////////////////

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	if ( Level.NetMode != NM_DedicatedServer )
	{
		// New Shadow
		if ( Shadow != None )
			Shadow.Destroy();

		Shadow = Spawn(class's_PlayerShadow', self);

	}
}


///////////////////////////////////////
// Destroyed
///////////////////////////////////////

simulated event Destroyed()
{
	Super.Destroyed();
	if (Shadow!=None)
		Shadow.Destroy();
}


///////////////////////////////////////
// RoundEnded
///////////////////////////////////////

function RoundEnded()
{
}


///////////////////////////////////////
// Escape
///////////////////////////////////////

function Escape()
{
}


///////////////////////////////////////
// SeeNPC
///////////////////////////////////////

function SeeNPC( Actor SeenPlayer )
{
}

///////////////////////////////////////
// SeePlayer
///////////////////////////////////////

function SeePlayer(Actor SeenPlayer)
{
}

///////////////////////////////////////
// SetEnemy
///////////////////////////////////////

function bool SetEnemy( Pawn NewEnemy )
{
	return false;
}

///////////////////////////////////////
// SetOrders
///////////////////////////////////////

function SetOrders(name NewOrders, Pawn OrderGiver, optional bool bNoAck)
{
	if (!IsInState('Roaming')) GotoState('Roaming');
}


///////////////////////////////////////
// CloseToPointMan
///////////////////////////////////////

function bool CloseToPointMan(Pawn Other)
{
	local float dist;

	if ( (Self != None) && (Self.health > 0) && (Other != None) && (Other.health > 0) )
	{
		if ( (Base != None) && (Other.Base != None) && (Other.Base != Base) )
				return false;

		dist = VSize(Location - Other.Location);
		if ( dist > 400 )
			return false;

		// check if point is moving away
		if ( (Region.Zone.bWaterZone || (dist > 200)) && (((Other.Location - Location) Dot Other.Velocity) > 0) )
			return false;

		return ( LineOfSightTo(Other) );
	}

	Return False;
}


///////////////////////////////////////
// TakeDamage
///////////////////////////////////////

function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
						Vector momentum, name damageType)
{
	local int actualDamage;
	local bool bAlreadyDead;

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
				if (Health > ActualDamage)
					TO_PRI(instigatedBy.PlayerReplicationInfo).InflictedDmg -= actualDamage;
				else
					TO_PRI(instigatedBy.PlayerReplicationInfo).InflictedDmg -= Health;
		} else if (instigatedBy.IsA('s_Bot')) {
				if (Health > ActualDamage)
					TO_BRI(instigatedBy.PlayerReplicationInfo).InflictedDmg -= actualDamage;
				else
					TO_BRI(instigatedBy.PlayerReplicationInfo).InflictedDmg -= Health;
		}
	}

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


///////////////////////////////////////
// Bump
///////////////////////////////////////

function Bump(actor Other)
{
	local vector VelDir, OtherDir;
	local float speed, dist;
	local Pawn P,M;
	local bool bDestinationObstructed, bAmLeader;
	local int num;

	P = Pawn(Other);
	if ( (P != None) && CheckBumpAttack(P) )
		return;
	if ( TimerRate <= 0 )
		setTimer(1.0, false);

	if ( Level.Game.bTeamGame && (P != None) && (MoveTarget != None) )
	{
		OtherDir = P.Location - MoveTarget.Location;
		if ( abs(OtherDir.Z) < P.CollisionHeight )
		{
			OtherDir.Z = 0;
			dist = VSize(OtherDir);
			bDestinationObstructed = ( VSize(OtherDir) < P.CollisionRadius );
			if ( P.IsA('Bot') )
				bAmLeader = ( Bot(P).DeferTo(self) || (PlayerReplicationInfo.HasFlag != None) );

			// check if someone else is on destination or within 3 * collisionradius
			for ( M=Level.PawnList; M!=None; M=M.NextPawn )
				if ( M != self )
				{
					dist = VSize(M.Location - MoveTarget.Location);
					if ( dist < M.CollisionRadius )
					{
						bDestinationObstructed = true;
						if ( M.IsA('Bot') )
							bAmLeader = Bot(M).DeferTo(self) || bAmLeader;
					}
					if ( dist < 3 * M.CollisionRadius )
					{
						num++;
						if ( num >= 2 )
						{
							bDestinationObstructed = true;
							if ( M.IsA('Bot') )
								bAmLeader = Bot(M).DeferTo(self) || bAmLeader;
						}
					}
				}

			if ( bDestinationObstructed && !bAmLeader )
			{
				// P is standing on my destination
				MoveTimer = -1;
				if ( Enemy != None )
				{
					if ( LineOfSightTo(Enemy) )
					{
						if ( !IsInState('TacticalMove') )
							GotoState('TacticalMove', 'NoCharge');
					}
					else if ( !IsInState('StakeOut') && (FRand() < 0.5) )
					{
						GotoState('StakeOut');
						LastSeenTime = 0;
						bClearShot = false;
					}
				}
				else if ( (Health > 0) && !IsInState('Wandering') || (Acceleration == vect(0,0,0)) )
				{
					WanderDir = Normal(Location - P.Location);
					GotoState('Wandering', 'Begin');
				}
			}
		}
	}
	speed = VSize(Velocity);
	if ( speed > 10 )
	{
		VelDir = Velocity/speed;
		VelDir.Z = 0;
		OtherDir = Other.Location - Location;
		OtherDir.Z = 0;
		OtherDir = Normal(OtherDir);
		if ( (VelDir Dot OtherDir) > 0.8 )
		{
			Velocity.X = VelDir.Y;
			Velocity.Y = -1 * VelDir.X;
			Velocity *= FMax(speed, 280);
		}
	}
	else if ( (Health > 0) && (Enemy == None) && (bCamping
				|| ((Orders == 'Follow') && (MoveTarget != None) && (MoveTarget == OrderObject) && (MoveTarget.Acceleration == vect(0,0,0)))) )
		GotoState('Wandering', 'Begin');
	Disable('Bump');
}

///////////////////////////////////////
// UpdateEyeHeight
///////////////////////////////////////

event UpdateEyeHeight(float DeltaTime)
{
	local Pawn ViewPawn;
	local bool bReallyViewed;

	if (CollisionHeight < Default.CollisionHeight)
	{
		// am crouched
		if (!MoveTarget.IsA('s_VentSpot'))
		{
			// try to stand up
			if (SetCollisionSize(Default.CollisionRadius, Default.CollisionHeight))
				PlayWalking();
			else // check if really have view target, and only fall through to main UpdateEyeHeight if so
			{
				for (ViewPawn = Level.PawnList; ViewPawn != None; ViewPawn = ViewPawn.NextPawn)
					if (ViewPawn.IsA('PlayerPawn') && (PlayerPawn(ViewPawn).ViewTarget == Self))
					{
						bReallyViewed = True;
						break;
					}

				if (!bReallyViewed)
					return;
			}
		}
	}

	Super.UpdateEyeHeight(DeltaTime);
}

///////////////////////////////////////
// Defending
///////////////////////////////////////

state Defending
{
ignores Bump, hearnoise, enemynotvisible;

	function SeePlayer(Actor SeenPlayer)
	{
		local s_player	P;
		local s_bot		B;

		if ( SeenPlayer.IsA('s_player') )
		{
			P = s_player(SeenPlayer);

			if ( P.PlayerReplicationInfo.Team != PlayerReplicationInfo.Team )
				Enemy = P;
		}

		if ( SeenPlayer.IsA('s_bot') )
		{
			B = s_bot(SeenPlayer);

			if ( B.PlayerReplicationInfo.Team != PlayerReplicationInfo.Team )
				Enemy = B;
		}

		GotoState('Defending','Attack');
	}

	function EndState()
	{
		if ( Health < 1 )
			return;

		if ( !DefensePoint.bLeaving )
		{
			PlayChallenge();

			NextState = 'Defending';
			NextLabel = 'Begin';
			GotoState('Defending','begin');
		}
		else
		{
			GotoState(OldState);
		}
	}

attack:

	if ( !LineOfSightTo(Enemy) || !bReadyToAttack)
		GotoState('Defending');

	TurnToward(Enemy);
	//DesiredRotation = Rotator(Enemy.Location - Location);
	//SetRotation(DesiredRotation);
	ViewRotation = Rotator(Enemy.Location - Location);
	bReadyToAttack = true;

	if ( !Weapon.bMeleeWeapon && CanFireAtEnemy() )
	{
		bQuickFire = true;
		FireWeapon();
		bQuickFire = false;
		if ( Weapon.bSplashDamage )
		{
			bFire = 0;
			bAltFire = 0;
			bReadyToAttack = true;
			Sleep(0.5);
		}
		else
			Sleep(0.7 + 0.3 * FRand());

		bFire = 0;
		bAltFire = 0;
	}

	Goto('attack');

begin:

	O_number = 255;
	OrderObject = None;

	if ( DefensePoint.Duck )
	{
		PlayDuck();
		bIsCrouching = True;
		FinishAnim();
	}
	ViewRotation = DesiredRotation;

finished:
	DesiredRotation = DefensePoint.Rotation;

}

function UseVent(bool Exit)
{
	if ( !Exit)
	{
		GroundSpeed = 80;
		SetCollisionSize(Default.CollisionRadius,29.000000);
	}
	else
	{
		GroundSpeed = Default.GroundSpeed;
		SetCollisionSize(Default.CollisionRadius,Default.CollisionHeight);
	}

	bShouldCrawl = !Exit;
}

///////////////////////////////////////
// Alarm
///////////////////////////////////////

state Alarm
{
	function SeePlayer(Actor SeenPlayer)
	{
		local s_player	P;
		local s_bot		B;

		if ( SeenPlayer.IsA('s_player') )
		{
			P = s_player(SeenPlayer);

			if ( P.PlayerReplicationInfo.Team != PlayerReplicationInfo.Team )
				Enemy = P;
		}

		if ( SeenPlayer.IsA('s_bot') )
		{
			B = s_bot(SeenPlayer);

			if ( B.PlayerReplicationInfo.Team != PlayerReplicationInfo.Team )
				Enemy = B;
		}

		GotoState('Alarm','Attack');
	}

attack:

	if ( !LineOfSightTo(Enemy) || !bReadyToAttack)
		Goto('end');

	TurnToward(Enemy);
	//DesiredRotation = Rotator(Enemy.Location - Location);
	//SetRotation(DesiredRotation);
	ViewRotation = Rotator(Enemy.Location - Location);
	bReadyToAttack = true;

	if ( !Weapon.bMeleeWeapon && CanFireAtEnemy() )
	{
		bQuickFire = true;
		FireWeapon();
		bQuickFire = false;
		if ( Weapon.bSplashDamage )
		{
			bFire = 0;
			bAltFire = 0;
			bReadyToAttack = true;
			Sleep(0.5);
		}
		else
			Sleep(0.7 + 0.3 * FRand());

		bFire = 0;
		bAltFire = 0;
	}

	Goto('attack');

moving:
	Orders = 'FreeLance';

	O_number = 255;
	OrderObject = Movetarget;

	GotoState('Hunting');

begin:
	Acceleration = Vect(0,0,0);

	PlayChallenge();

	if ( AlarmPoint.DuckTime > 0 )
	{
		PlayDuck();
		bIsCrouching = True;
		FinishAnim();
	}

//	PlayTurning();
	DesiredRotation = AlarmPoint.Rotation;
	//SetRotation(DesiredRotation);
	ViewRotation = DesiredRotation;

	for (i=0;i<8;i++)
	{
		if ( AlarmPoint.ShootTargetActor[i] != None )
		{
			if ( FRand() <= AlarmPoint.Priority )
			{
				ViewRotation =  Rotator( AlarmPoint.ShootTargetActor[i].Location - Location );
				TurnTo( AlarmPoint.ShootTargetActor[i].Location );
				Target = AlarmPoint.ShootTargetActor[i];
				Enemy = None;
				FireWeapon();
				Sleep(AlarmPoint.ShootDelay);
			}
		}
	}

end:

}

function eAttitude AttitudeTo(Pawn Other)
{
    return ATTITUDE_Ignore;
}

function InitPawn()
{
	SetMovementPhysics();
	GotoState('PlayerWalking');
}

state Roaming
{
	ignores EnemyNotVisible;

	function EnemyAcquired()
	{
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
//						PickLocalInventory(160, 1.8);
						return;
					}
					else if ( TeamPriority > 1 )
					{
//						PickLocalInventory(200, 1);
						return;
					}
					else if ( TeamPriority > 0 )
					{
//						PickLocalInventory(280, 0.55);
						return;
					}
//					PickLocalInventory(400, 0.5);
				} else GotoState('Roaming');
				return;
			}
		}

/*		if ( Weapon != None )
			bLockedAndLoaded = ( (Weapon.AIRating > 0.4) && (Health > 60) );
		else*/
			bLockedAndLoaded = false;

		if (  Orders == 'Follow' )
		{
			if ( (OrderObject==None) || (Pawn(OrderObject) == None) )
				SetOrders('FreeLance', None);
/*			else if ( (Pawn(OrderObject).Health > 0) )
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
			}*/
		}

		if ( (Orders == 'Defend') && bLockedAndLoaded )
		{
/*			if ( PickLocalInventory(300, 0.55) )
				return;*/
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

/*		if ( !bTriedToPick && PickLocalInventory(600, 0) )
			return;*/

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
/*		else if ( (Weapon.AIRating > 0.5) && (Health > 90) && !Region.Zone.bWaterZone )
		{
			bWantsToCamp = ( bWantsToCamp || (FRand() < CampingRate * FMin(1.0, Level.TimeSeconds - LastCampCheck)) );
			LastCampCheck = Level.TimeSeconds;
		}
		else*/
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
//					GotoState('Roaming', 'ShootDecoration');
					return;
				}

		bNoShootDecor = false;
		BestWeight = 0;

		// look for long distance inventory
//		BestPath = FindBestInventoryPath(BestWeight, !bNovice && (skill >= 2));
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
//		if ( FRand() < 0.35 )
			GotoState('Wandering');
/*		else
		{
			GoalString = " Nothing cool, so camp ";
			CampTime = Max(3.5 + FRand() - skill, 1.0);
			//log("s_BotBase::Roaming::PickDestination -"@GetHumanName()@"has nothing to do!! camp.."@CampTime);
			GotoState('Roaming', 'Camp');
		}*/
	}


LongCamp:
	PickDestination();
/*	//log("s_BotBase::Roaming::LongCamp -"@GetHumanName() );
	bCamping = true;
	Acceleration = vect(0,0,0);
	TweenToWaiting(0.15);
	if ( Ambushspot != None )
		TurnTo(Location + Ambushspot.lookdir);
	Sleep(CampTime);
	Goto('PreBegin');*/

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
	PickDestination();
/*	//log("s_BotBase::Roaming::Camp -"@GetHumanName() );
	bCamping = true;
	Acceleration = vect(0,0,0);
	TweenToWaiting(0.15);*/

ReCamp:
	//log("s_BotBase::Roaming::ReCamp -"@GetHumanName() );
	PickDestination();
/*	if ( NearWall(200) )
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
*/
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

function PlayTurning()
{
	BaseEyeHeight = Default.BaseEyeHeight;
	if ( (Weapon == None) || (Weapon.Mass < 20) )
		PlayAnim('TurnSM', 0.3, 0.3);
	else
		PlayAnim('TurnLG', 0.3, 0.3);
}


function PlayVictoryDance()
{
	if ( Physics == PHYS_Swimming )
		return;

	PlayAnim('Victory1', 0.7);
}


function PlayWaving()
{
	if ( Physics == PHYS_Swimming )
		return;

	PlayAnim('Wave', 0.7, 0.2);
}


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
	if ( (Weapon==None) || (Enemy==None) )
	{
		//if ( (Weapon!=None) && (Weapon.Mass>=20) )
		//	TweenAnim('WalkLg_noaim', tweentime);
		//else
			TweenAnim('Walk', tweentime);
	}
	else if ( Weapon.bPointing || (CarriedDecoration != None) )
	{
		if (Weapon.Mass < 11)
			TweenAnim('WalkKG', tweentime);
		else if (Weapon.Mass < 20)
			TweenAnim('WalkSMFR', tweentime);
		else
			TweenAnim('WalkLGFR', tweentime);
	}
	else
	{
		if (Weapon.Mass < 11)
			TweenAnim('WalkKG', tweentime);
		else if (Weapon.Mass < 20)
			TweenAnim('WalkSM', tweentime);
		else
			TweenAnim('WalkLG', tweentime);
	}
}


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
	if ( (Weapon == None) || (Enemy==None) )
	{
		//if ( (Weapon!=None) && (Weapon.Mass>=20) )
		//	LoopAnim('WalkLg_noaim');
		//else
			LoopAnim('Walk');
	}
	else if ( Weapon.bPointing )
	{
		if (Weapon.Mass < 11)
			LoopAnim('WalkKG');
		else if (Weapon.Mass < 20)
			LoopAnim('WalkSMFR');
		else
			LoopAnim('WalkLGFR');
	}
	else
	{
		if (Weapon.Mass < 11)
			LoopAnim('WalkKG');
		else if (Weapon.Mass < 20)
			LoopAnim('WalkSM');
		else
			LoopAnim('WalkLG');
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

	if ( Weapon == None )
		newAnim = 'Run';
	/*if ( (Weapon==None) || (Enemy==None) )
	{
		if ( (Weapon!=None) && (Weapon.Mass>=20) )
			newAnim = 'RunLg_noaim';
		else
			newAnim = 'Run';
	}*/
	else if ( Weapon.bPointing )
	{
		if ( Weapon.Mass < 6 )
			newAnim = 'RunKGSlash';
		if ( Weapon.Mass < 11 )
			newAnim = 'RunKGThrow';
		else if (Weapon.Mass < 20)
			newAnim = 'RunSMFR';
		else
			newAnim = 'RunLGFR';
	}
	else
	{
		if ( Weapon.Mass < 11 )
			newAnim = 'RunKG';
		else if (Weapon.Mass < 20)
			newAnim = 'RunSM';
		else
			newAnim = 'RunLG';
	}

	if ( (newAnim == AnimSequence) && (Acceleration != vect(0,0,0)) && IsAnimating() )
		return;
	TweenAnim(newAnim, tweentime);
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
			LoopAnim('StrafeSmL');
		else
			LoopAnim('StrafeSmR');
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
			{
					LoopAnim('BackRunS');
			}
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

	newAnim = 'Run';

	if ( (newAnim == AnimSequence) && IsAnimating() )
		return;

	LoopAnim(NewAnim);
}


function PlayRising()
{
	BaseEyeHeight = 0.4 * Default.BaseEyeHeight;
	TweenAnim('DuckWlkS', 0.7);
}


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


function PlayGutHit(float tweentime)
{
	if ( (AnimSequence == 'GutHit') || (AnimSequence == 'Dead2') )
	{
		if (FRand() < 0.5)
		{
				TweenAnim('LeftHitS', tweentime);
		}
		else
		{
				TweenAnim('RightHitS', tweentime);
		}
	}
	else if ( FRand() < 0.6 )
		TweenAnim('GutHit', tweentime);
	else
		TweenAnim('Dead8', tweentime);

}


function PlayHeadHit(float tweentime)
{
	if ( (AnimSequence == 'HeadHit') || (AnimSequence == 'HeadHitL') || (AnimSequence == 'Dead4') )
		TweenAnim('GutHit', tweentime);
	else if ( FRand() < 0.6 )
	{
			TweenAnim('HeadHit', tweentime);
	}
	else
		TweenAnim('Dead7', tweentime);
}


function PlayLeftHit(float tweentime)
{
	if ( (AnimSequence == 'LeftHitS') || (AnimSequence == 'LeftHitL') || (AnimSequence == 'Dead3') )
		TweenAnim('GutHit', tweentime);
	else if ( FRand() < 0.6 )
	{
			TweenAnim('LeftHitS', tweentime);
	}
	else
		TweenAnim('Dead9', tweentime);
}


function PlayRightHit(float tweentime)
{
	if ( (AnimSequence == 'RightHitS') || (AnimSequence == 'RightHitL') || (AnimSequence == 'Dead5') )
		TweenAnim('GutHit', tweentime);
	else if ( FRand() < 0.6 )
	{
			TweenAnim('RightHitS', tweentime);
	}
	else
		TweenAnim('Dead1', tweentime);
}


function PlayLanded(float impactVel)
{
	impactVel = impactVel/JumpZ;
	impactVel = 0.1 * impactVel * impactVel;
	BaseEyeHeight = Default.BaseEyeHeight;

	if ( impactVel > 0.40 )
		PlaySound(LandGrunt, SLOT_Talk, FMin(4, impactVel),false,1600,FRand()*0.4+0.8);
	if ( !FootRegion.Zone.bWaterZone && (impactVel > 0.01) )
		PlaySound(Land, SLOT_Interact, FClamp(4 * impactVel,0.2,4.5), false,1600, 1.0);

	if ( (impactVel > 0.06) || (GetAnimGroup(AnimSequence) == 'Jumping') )
	{
			TweenAnim('LandSMFR', 0.12);
	}
	else if ( !IsAnimating() )
	{
		if ( GetAnimGroup(AnimSequence) == 'TakeHit' )
			AnimEnd();
		else
		{
				TweenAnim('LandSMFR', 0.12);
		}
	}
}


function FastInAir()
{
	local float TweenTime;

	BaseEyeHeight =  0.7 * Default.BaseEyeHeight;
	if ( GetAnimGroup(AnimSequence) == 'Jumping' )
	{
			TweenAnim('DuckWlkS', 1);
		return;
	}
	else if ( GetAnimGroup(AnimSequence) == 'Ducking' )
		TweenTime = 1;
	else
		TweenTime = 0.3;

	TweenAnim('JumpSMFR', TweenTime);
}


function PlayInAir()
{
	local float TweenTime;

	BaseEyeHeight =  0.7 * Default.BaseEyeHeight;
	if ( GetAnimGroup(AnimSequence) == 'Jumping' )
	{
			TweenAnim('DuckWlkS', 2);
		return;
	}
	else if ( GetAnimGroup(AnimSequence) == 'Ducking' )
		TweenTime = 2;
	else
		TweenTime = 0.7;

		TweenAnim('JumpSMFR', TweenTime);
}


function PlayDodge(bool bDuckLeft)
{
	if ( bDuckLeft )
	{
			TweenAnim('DodgeLSm', 0.25);
	}
	else
	{
			TweenAnim('DodgeRSm', 0.25);
	}
}


function PlayDuck()
{
	local vector Dir;

	Dir = Normal(Acceleration);
	BaseEyeHeight = 0;

	if ( Dir == vect(0,0,0) )
	{
				TweenAnim('DuckIdleL', 0.25);
	}
	else
	{
				TweenAnim('DuckWlkS', 0.25);
	}
}


function PlayCrawling()
{
	local vector Dir;

	Dir = Normal(Acceleration);
	BaseEyeHeight = 0;

	if ( Dir == vect(0,0,0) )
	{
				LoopAnim('DuckIdleL');
	}
	else
	{
				LoopAnim('DuckWlkL');
	}
}


function TweenToWaiting(float tweentime)
{
	if ( Physics == PHYS_Swimming )
	{
		BaseEyeHeight = 0.7 * Default.BaseEyeHeight;
			TweenAnim('TreadSM', tweentime);
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
		if ( (ViewRotation.Pitch > RotationRate.Pitch)
			&& (ViewRotation.Pitch < 65536 - RotationRate.Pitch) )
		{
			if (ViewRotation.Pitch < 32768)
			{
					TweenAnim('AimUpLg', 0.3);
			}
			else
			{
					TweenAnim('AimDnLg', 0.3);
			}
		}
		else
			TweenAnim('StillLgFr', tweentime);
	}
}


function TweenToFighter(float tweentime)
{
	TweenToWaiting(tweentime);
}


function PlayChallenge()
{
	TweenToWaiting(0.17);
}

function PlayLookAround()
{
	PlayWaiting();
	//LoopAnim('Look', 0.3 + 0.7 * FRand(), 0.1);
}

function PlayWaiting()
{
	local name newAnim;

	if ( Physics == PHYS_Swimming )
	{
		BaseEyeHeight = 0.7 * Default.BaseEyeHeight;
			LoopAnim('TreadLG');
	}
	else
	{
		BaseEyeHeight = Default.BaseEyeHeight;
		if ( Level.Game.bTeamGame && ((FRand() < 0.04) || ((AnimSequence == 'Chat1') && (FRand() < 0.75))) )
		{
			newAnim = 'Chat2';
		}
		else
		{
              newAnim = 'Breath1KG';
		}
		if ( AnimSequence == newAnim )
			LoopAnim(newAnim, 0.4 + 0.4 * FRand());
		else
			PlayAnim(newAnim, 0.4 + 0.4 * FRand(), 0.25);
	}
}

function PlaySwimming()
{
	BaseEyeHeight = 0.7 * Default.BaseEyeHeight;
		LoopAnim('SwimLG');
}


function TweenToSwimming(float tweentime)
{
	BaseEyeHeight = 0.7 * Default.BaseEyeHeight;
		TweenAnim('SwimLG',tweentime);
}


State ImpactJumping
{
	function PlayWaiting()
	{
		TweenAnim('AimDnLg', 0.3);
	}
}

function ForceMeshToExist()
{
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

function PlayDecap()
{
	local carcass carc;

	PlayAnim('Dead4',, 0.1);
}

function InitPlayerReplicationInfo()
{
    super.initPlayerReplicationInfo();
    if (PlayerReplicationInfo!=None)
        PlayerReplicationInfo.Team=2;
}

function WhatToDoNext(name LikelyState, name LikelyLabel)
{
/*	if ( (Level.NetMode != NM_Standalone)
		&& Level.Game.IsA('TO_DeathMatchPlus')
		&& TO_DeathMatchPlus(Level.Game).TooManyBots() )
	{
		Destroy();
		return;
	}*/

	BlockedPath = None;
	bDevious = false;
	bFire = 0;
	bAltFire = 0;
	bKamikaze = false;
//	SetOrders(BotReplicationInfo(PlayerReplicationInfo).RealOrders, BotReplicationInfo(PlayerReplicationInfo).RealOrderGiver, true);
	Enemy = OldEnemy;
	OldEnemy = None;
	bReadyToAttack = false;
	if ( Enemy != None )
	{
		bReadyToAttack = !bNovice;
		GotoState('Attacking');
	}
/*	else if ( (Orders == 'Hold') && (Weapon.AIRating > 0.4) && (Health > 70) )
			GotoState('Hold');
	else
	{*/
		if ( !IsInState('Roaming') ) // Added by Shag
			GotoState('Roaming');
/*		if ( Skill > 2.7 )
			bReadyToAttack = true;
	}*/
}

function bool DeferTo(Bot Other)
{
/*	if ( (Other.PlayerReplicationInfo.HasFlag != None)
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
	}*/
				WanderDir = Normal(Location - Other.Location);
				GotoState('Wandering', 'Begin');
	return false;
}

state Wandering
{
	ignores EnemyNotVisible;

	function bool TestDirection(vector dir, out vector pick)
	{
		local vector HitLocation, HitNormal, dist;
		local float minDist;
		local actor HitActor;

/*		if (OrderObject == None)
			return false;*/

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

Begin:
	//log(class$" Wandering");

Wander:
	WaitForLanding();
	PickDestination();
	TweenToWalking(0.15);
	FinishAnim();
	PlayWalking();

Moving:
	Enable('HitWall');
	MoveTo(Destination, WalkingSpeed);
Pausing:
	if ( Level.Game.bTeamGame
		&& (bLeading || ((Orders == 'Follow') && !CloseToPointMan(Pawn(OrderObject)))) )
		GotoState('Roaming');
	Acceleration = vect(0,0,0);
	if ( NearWall(200) )
	{
		PlayTurning();
		TurnTo(Focus);
	}
	Enable('AnimEnd');
	NextAnim = '';
	TweenToPatrolStop(0.2);
	Sleep(1.0);
	Disable('AnimEnd');
	FinishAnim();
	GotoState('Roaming');

ContinueWander:
	FinishAnim();
	PlayWalking();
	if (FRand() < 0.2)
		Goto('Turn');
	Goto('Wander');

Turn:
	Acceleration = vect(0,0,0);
	PlayTurning();
	TurnTo(Location + 20 * VRand());
	Goto('Pausing');

AdjustFromWall:
	StrafeTo(Destination, Focus);
	Destination = Focus;
	Goto('Moving');
}

///////////////////////////////////////
// defaultproperties
///////////////////////////////////////
// VoiceType="TODatas.VoiceSF1"

defaultproperties
{
     MaxFallHeight=100
     bNeverSwitchOnPickup=True
     bCanStrafe=False
     GroundSpeed=280.000000
     JumpZ=350.000000
     VoiceType=""
    GroundSpeed=260;
	AirSpeed=300;
    AccelRate=2048.000000;
    AirControl=1;
	JumpZ=350/2;
     LandGrunt=Sound'TODatas.Player.fall1'
     bIsHuman=True
     BaseEyeHeight=35.000000
     EyeHeight=35.000000
     CollisionRadius=20.000000
     CollisionHeight=39.000000
     Buoyancy=99.000000
     CarcassType=Class's_swat.s_PlayerCarcass'
     FaceSkin=3
     FixedSkin=2
     TeamSkin2=1
     PlayerReplicationInfoClass=Class's_swat.TO_BRI'
     bIsPlayer=True
}

