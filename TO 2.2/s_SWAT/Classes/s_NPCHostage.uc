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

class s_NPCHostage expands s_NPC;


var			Pawn								Followed;										// Player to follow
var			bool								bCloseEnough;
var			TournamentWeapon 	  FoundWeapon;
var			bool								bIsFree;
var			int			LastDistressCall;


///////////////////////////////////////
// WhatToDoNext
///////////////////////////////////////

function WhatToDoNext(name LikelyState, name LikelyLabel)
{	
	if ( Health < 1 )
		Destroy();

	LastWhatToDoNextCheck = Level.TimeSeconds;

	/*if ( bVerbose )
	{
		log(self$" what to do next");
		log("enemy "$Enemy);
		log("old enemy "$OldEnemy);
	}
	if ( (Level.NetMode != NM_Standalone) 
		&& Level.Game.IsA('DeathMatchPlus')
		&& DeathMatchPlus(Level.Game).TooManyBots() )
	{
		Destroy();
		return;
	}*/

	UpdateStatus();

	BlockedPath = None;
	bDevious = false;
	bFire = 0;
	bAltFire = 0;
	bKamikaze = false;
	//SetOrders(BotReplicationInfo(PlayerReplicationInfo).RealOrders, BotReplicationInfo(PlayerReplicationInfo).RealOrderGiver, true);
	Enemy = OldEnemy;
	OldEnemy = None;
	bReadyToAttack = false;

	if (Weapon!=None && !bCanUseWeapon)
		TossWeapon();

	if ( Enemy != None && Weapon != None )
	{
		bReadyToAttack = !bNovice;
		GotoState('Attacking');
	}
/*	else if ( (Orders == 'Hold') && (Weapon.AIRating > 0.4) && (Health > 70) )
			GotoState('Hold');
	else
	{
		GotoState('Roaming');
		if ( Skill > 2.7 )
			bReadyToAttack = true; 
	}*/
	if (!bIsFree)
	{
		if (Weapon != None)
		{
			bIsFree=true;
			GoToState('Roaming');
		}
		else
		{
			GoToState('Waiting');
			if (Frand()<0.2)
				PlayComplainSound();
		}
	}
	else
	{
		if (Followed == None)
			GoToState('s_Wandering');
		else
		{
			/*if (Enemy != None)
				GotoState('Following','RunAway');
			else */
				GotoState('Following');
		}
	}

/*	if (!bIsFree && Weapon!=None)
	{
		bIsFree=true;
		GoToState('Roaming');
	}
	else if ( Followed == None )
		GotoState('Waiting');
	else if ( bIsFree && Followed!=None && Enemy!=None && Weapon==none )
		GotoState('Following','RunAway');
	else 
		GotoState('Following');*/
}


///////////////////////////////////////
// UpdateStatus
///////////////////////////////////////

function UpdateStatus()
{
	local float sHealth;

	sHealth=(Default.Health - Health)/Default.Health;

	if (Tortionary != None)
		sHealth += 0.3;

	if (!bCanUseWeapon && ( (NPCWAff + sHealth/2 + FRand()) > 1.7 ) )
		bCanUseWeapon=true;

	if (Followed != None)
	{
		if (Followed.IsA('s_Bot') && s_Bot(Followed).bNotPlaying)
		{
			bIsFree = false;
			Followed = None;
			OrderObject = None;
			GotoState('Waiting');
		}
		else if (Followed.IsA('s_Player') && s_Player(Followed).bNotPlaying)
		{
			bIsFree = false;
			Followed = None;
			OrderObject = None;
			GotoState('Waiting');
		}
	}
 
	if (Enemy != None)
	{
		if (Enemy.IsA('s_Bot') && s_Bot(Enemy).bNotPlaying)
			Enemy = None;
		else if (Enemy.IsA('s_Player') && s_Player(Enemy).bNotPlaying)
			Enemy = None;
	}

	// Escape
	if (!bIsFree && Followed !=None && Enemy != None && Followed.PlayerReplicationInfo.Team != EnemyTeam)
		bIsFree=true;
}


///////////////////////////////////////
// TakeDamage
///////////////////////////////////////

function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, name damageType)
{
	local int actualDamage;
	local bool bAlreadyDead;

		///////////////////////////////////////////////////////////////////////////////////////

	// Added

	PlayScream();
	if (InstigatedBy == Followed)
		Followed=None;
	if (InstigatedBy != None && (InstigatedBy.IsA('s_Player') || InstigatedBy.IsA('s_Bot')) )
	{
		if (InstigatedBy.PlayerReplicationInfo.Team == EnemyTeam)
		{
			Tortionary=InstigatedBy;
			OldEnemy=Enemy;
			Enemy=InstigatedBy;
			GotoState('Escape');
		}
		else if (FRand() > 0.5)
		{
			Tortionary=InstigatedBy;
			OldEnemy=InstigatedBy;
			Enemy=InstigatedBy;
			GotoState('Escape');
		}		
	}
	////////////////////////////////////////////////////////////////////////////////

	bAlreadyDead = (Health <= 0);

	if (Physics == PHYS_None)
		SetMovementPhysics();
	if (Physics == PHYS_Walking)
		momentum.Z = FMax(momentum.Z, 0.4 * VSize(momentum));
	if ( instigatedBy == self )
		momentum *= 0.6;
	momentum = momentum/Mass;

	actualDamage = s_SWATGame(Level.Game).SWATReduceDamage(Damage, DamageType, self, instigatedBy, HitLocation-Location);
/*	if ( bIsPlayer )
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
*/
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
// AttitudeTo
///////////////////////////////////////

function eAttitude AttitudeTo(Pawn Other)
{
	local byte result;

	if ( Level.Game.IsA('s_SWATGame') )
	{
		/*result = DeathMatchPlus(Level.Game).AssessBotAttitude(self, Other);
		Switch (result)
		{
			case 0: return ATTITUDE_Fear;
			case 1: return ATTITUDE_Hate;
			case 2: return ATTITUDE_Ignore;
			case 3: return ATTITUDE_Friendly;
		}*/
//		if (Weapon!=None && !bCanUseWeapon)
//			TossWeapon();
		if (Other==Followed && Other!=None)
			return ATTITUDE_Friendly;

		if (Weapon == None)
		{
			if (Other == Tortionary)
				return ATTITUDE_Fear;

			if (Other == Enemy)
				return ATTITUDE_Fear;
			if (Other.IsA('s_NPCHostage'))
				return ATTITUDE_Friendly;
			else if (Other.IsA('s_Player') || Other.IsA('s_Bot'))
			{
				if (Other.PlayerReplicationInfo.team == EnemyTeam)
				{
					if (Followed!=None)
						return Attitude_Fear;
					else
						return Attitude_Ignore;
				}
				else
					return Attitude_Friendly;
			}
		}
		else
		{
			if (Other == Tortionary)
				return Attitude_Hate;

			if (Other.IsA('s_NPCHostage'))
				return ATTITUDE_Friendly;
			else if (Other.IsA('s_Player') || Other.IsA('s_Bot'))
			{
				if (Other.PlayerReplicationInfo.team == EnemyTeam)
					return Attitude_Hate;
				else
					return Attitude_Friendly;
			}
		}
	}
	return ATTITUDE_Ignore;
}


///////////////////////////////////////
// SetOrders
///////////////////////////////////////

function SetOrders(name NewOrders, Pawn OrderGiver, optional bool bNoAck)
{
	local Pawn P;
	local Bot B;

	/*if ( NewOrders != BotReplicationInfo(PlayerReplicationInfo).RealOrders )
	{ 
		if ( (IsInState('Roaming') && bCamping) || IsInState('Wandering') )
			GotoState('Roaming', 'PreBegin');
		else if ( !IsInState('Dying') )
			GotoState('Attacking');
	}*/

	bLeading = false;
	/*if ( NewOrders == 'Point' )
	{
		NewOrders = 'Attack';
		SupportingPlayer = PlayerPawn(OrderGiver);
	}
	else
		SupportingPlayer = None;*/

	if ( bSniping && (NewOrders != 'Defend') )
		bSniping = false;
	bStayFreelance = false;
	//if ( !bNoAck && (OrderGiver != None) )
	//	SendTeamMessage(OrderGiver.PlayerReplicationInfo, 'ACK', Rand(class<ChallengeVoicePack>(PlayerReplicationInfo.VoiceType).Default.NumAcks), 5);

	BotReplicationInfo(PlayerReplicationInfo).SetRealOrderGiver(OrderGiver);
	BotReplicationInfo(PlayerReplicationInfo).RealOrders = NewOrders;

	Aggressiveness = BaseAggressiveness;
	if ( Orders == 'Follow' )
		Aggressiveness -= 1;
	Orders = NewOrders;
	if ( !bNoAck && (HoldSpot(OrderObject) != None) )
	{
		OrderObject.Destroy();
		OrderObject = None;
	}
	if ( Orders == 'Hold' )
	{
		Aggressiveness += 1;
//		if ( !bNoAck )
//			OrderObject = OrderGiver.Spawn(class'HoldSpot');
	}
	else if ( Orders == 'Follow' )
	{
		Aggressiveness += 1;
		OrderObject = OrderGiver;
	}
/*	else if ( Orders == 'Defend' )
	{
		if ( Level.Game.IsA('TeamGamePlus') )
			OrderObject = TeamGamePlus(Level.Game).SetDefenseFor(self);
		else
			OrderObject = None;
		if ( OrderObject == None )
		{
			Orders = 'Freelance';
			if ( bVerbose )
				log(self$" defender couldn't find defense object");
		}
		else
			CampingRate = 1.0;
	}*/
/*	else if ( Orders == 'Attack' )
	{
		CampingRate = 0.0;*/
		// set bLeading if have supporters
		/*if ( Level.Game.bTeamGame )
			for ( P=Level.PawnList; P!=None; P=P.NextPawn )
				if ( P.bIsPlayer && (P.PlayerReplicationInfo.Team == PlayerReplicationInfo.Team) )
				{
					B = Bot(P);
					if ( (B != None) && (B.OrderObject == self) && (BotReplicationInfo(B.PlayerReplicationInfo).RealOrders == 'Follow') )
					{
						bLeading = true;
						break;
					}
				}*/
	//}	
				
	BotReplicationInfo(PlayerReplicationInfo).OrderObject = OrderObject;
}


///////////////////////////////////////
// PickLocalInventory
///////////////////////////////////////

function bool PickLocalInventory(float MaxDist, float MinDistraction)
{
	local inventory Inv, BestInv, KnowPath;
	local float NewWeight, DroppedDist, BestWeight;
	local actor BestPath;
	local bool bCanReach;
	local NavigationPoint N;

	if ( (EnemyDropped != None) && !EnemyDropped.bDeleteMe 
		&& (EnemyDropped.Owner == None) )
	{
		DroppedDist = VSize(EnemyDropped.Location - Location);
		NewWeight = EnemyDropped.BotDesireability(self);
		if ( (DroppedDist < MaxDist) 
			&& ((NewWeight > MinDistraction) || (DroppedDist < 0.5 * MaxDist))
			&& ((EnemyDropped.Physics != PHYS_Falling) || (Region.Zone.ZoneGravity.Z == Region.Zone.Default.ZoneGravity.Z))
			&& ActorReachable(EnemyDropped)
			&& !EnemyDropped.IsA('Weapon') )
		{
			BestWeight = NewWeight; 		
			if ( BestWeight > 0.4  )
			{
				MoveTarget = EnemyDropped;
				EnemyDropped = None;
				return true; 
			}
			BestInv = EnemyDropped;
			BestWeight = BestWeight/DroppedDist;
			KnowPath = BestInv;
		}	
	}	

	EnemyDropped = None;
								
	//first look at nearby inventory < MaxDist
	foreach visiblecollidingactors(class'Inventory', Inv, MaxDist,,true)
		if ( (Inv.IsInState('PickUp')) && (Inv.MaxDesireability/60 > BestWeight)
			&& (Inv.Physics != PHYS_Falling)
			&& (Inv.Location.Z < Location.Z + MaxStepHeight + CollisionHeight) )
		{
			NewWeight = inv.BotDesireability(self);
			if ( (NewWeight > MinDistraction) 
				 || (Inv.bHeldItem && Inv.IsA('Weapon') && (VSize(Inv.Location - Location) < 0.6 * MaxDist)) )
			{
				NewWeight = NewWeight/VSize(Inv.Location - Location);
				if ( NewWeight > BestWeight && !Inv.IsA('Weapon') )
				{
					BestWeight = NewWeight;
					BestInv = Inv;
				}
			}
		}

	if ( BestInv != None )
	{
		bCanJump = ( bCanTranslocate || (BestInv.Location.Z > Location.Z - CollisionHeight - MaxStepHeight) );
		bCanReach = ActorReachable(BestInv);
	}
	else
		bCanReach = false;
	bCanJump = true;
	if ( bCanReach )
	{
		//GoalString = "local"@BestInv;
		MoveTarget = BestInv;
		return true;
	}
	else if ( KnowPath != None )
	{
		//GoalString = "local"@KnowPath;
		MoveTarget = KnowPath;
		return true;
	}
	//GoalString="No local";
	return false;
}


///////////////////////////////////////
// PlayRescueLock
///////////////////////////////////////

function PlayRescueLock()
{
	PlaySound(Sound'hos_fol',SLOT_Talk, 20.0, False, 1024);
}


///////////////////////////////////////
// PlayRescueEscort
///////////////////////////////////////

function PlayRescueEscort()
{	
	local	float	r;

	r = FRand();

	if ( r < 0.5 )
		PlaySound(Sound'hos_sffol',SLOT_Talk, 20.0, False, 1024);
	else
		PlaySound(Sound'hos_fol',SLOT_Talk, 20.0, False, 1024);
}


///////////////////////////////////////
// PlayThreatLock
///////////////////////////////////////

function PlayThreatLock()
{
	local	float	r;

	r = FRand();

	if ( r < 0.5 )
		PlaySound(Sound'hos_tfol',SLOT_Talk, 20.0, False, 1024);
	else
		PlaySound(Sound'hos_fol',SLOT_Talk, 20.0, False, 1024);
}


///////////////////////////////////////
// PlayThreatEscort
///////////////////////////////////////

function PlayThreatEscort()
{
	local	float	r;

	r = FRand();

	if ( r < 0.5 )
		PlaySound(Sound'hos_tfol',SLOT_Talk, 20.0, False, 1024);
	else
		PlaySound(Sound'hos_fol',SLOT_Talk, 20.0, False, 1024);
}


///////////////////////////////////////
// PlayScream
///////////////////////////////////////

function PlayScream()
{
	local		float		rnd;

	rnd = FRand();

	if ( rnd < 0.15 )
		PlaySound(Sound'Hos_Hit1',SLOT_Talk, 20.0, False);
	else if ( rnd < 0.3 )
		PlaySound(Sound'Hos_Hit2',SLOT_Misc, 20.0, False);
	else if ( rnd < 0.45 )
		PlaySound(Sound'Hos_Hit3',SLOT_Misc, 20.0, False);
	else if ( rnd < 0.60 )
		PlaySound(Sound'Hos_Hit4',SLOT_Misc, 20.0, False);
	else if ( rnd < 0.75 )
		PlaySound(Sound'Hos_Hit5',SLOT_Misc, 20.0, False);
	else 
		PlaySound(Sound'Hos_Hit6',SLOT_Misc, 20.0, False);
}


///////////////////////////////////////
// PlayComplainSound
///////////////////////////////////////

function PlayComplainSound()
{
	local		float		rnd;

	rnd = FRand();

	if (rnd < 0.25)
		PlaySound(Sound'Hos_complain1',SLOT_Talk, 20.0, False, 1024);
	else if (rnd < 0.50)
		PlaySound(Sound'Hos_complain2',SLOT_Misc, 20.0, False, 1024);
	else if (rnd < 0.75)
		PlaySound(Sound'Hos_complain3',SLOT_Misc, 20.0, False, 1024);
	else 
		PlaySound(Sound'Hos_complain4',SLOT_Misc, 20.0, False, 1024);
}


///////////////////////////////////////
// SwitchToBestWeapon
///////////////////////////////////////

function bool SwitchToBestWeapon()
{
	local float rating;
	local int usealt, favalt;
	local inventory MyFav;

	if (Weapon==None && !bCanUseWeapon)
		return false;

	if ( Inventory == None )
		return false;

	PendingWeapon = Inventory.RecommendWeapon(rating, usealt);
	if ( PendingWeapon == None )
		return false;

	if ( (FavoriteWeapon != None) && (PendingWeapon.class != FavoriteWeapon) )
	{
		MyFav = FindInventoryType(FavoriteWeapon);
		if ( (MyFav != None) && (Weapon(MyFav).RateSelf(favalt) + 0.22 > PendingWeapon.RateSelf(usealt)) )
		{
			usealt = favalt;
			PendingWeapon = Weapon(MyFav);
		}
	}
	if ( Weapon == None )
		ChangedWeapon();
	else if ( Weapon != PendingWeapon )
		Weapon.PutDown();

	return (usealt > 0);
}


///////////////////////////////////////
// Rescued
///////////////////////////////////////

function Rescued()
{
	local	s_SWATGame SG;
	
	SG = s_SWATGame(Level.Game);
	if ( SG == None )
	{
		Log("s_NPCHostage::Rescued - Unable to locate game !!!");
		return;
	}
	
	SG.Rescued(self);	
}


///////////////////////////////////////
// SetFall
///////////////////////////////////////

function SetFall()
{
	if (Enemy != None)
	{
		NextState = 'Idle';
		NextLabel = 'Begin';
		TweenToFalling();
		NextAnim = AnimSequence;
		GotoState('FallingState');
	}
}

/*
function SeePlayer(Actor SeenPlayer)
{
	if (!bIsFree && SeenPlayer.IsA('Pawn') && Pawn(SeenPlayer).PlayerReplicationInfo!=None && Pawn(SeenPlayer).PlayerReplicationInfo.Team!=EnemyTeam && FRand()<0.5)
		PlayHelpSound();

	Super.SeePlayer(SeenPlayer);
}

function PlayHelpSound()
{
	local float rnd;

	if (Level.TimeSeconds-LastDistressCall<7)
		return;

	LastDistressCall=Level.TimeSeconds;


	rnd=FRand();

	if (rnd<0.25)
		s_PlayDynamicSound(s_Voice$"Hosta013-just_take_me_away");
	else if (rnd<0.5)
		s_PlayDynamicSound(s_Voice$"Hosta016-what_took_you_so_long");
	else if (rnd<0.75)
		s_PlayDynamicSound(s_Voice$"Hosta019-its_about_time");
	else
		s_PlayDynamicSound(s_Voice$"Hosta014-thank_god_youre_here");

	GotoState('Waving');
	
}

State Waving
{
	ignores SeePlayer;

Begin:
	LoopAnim('Wave');
	Sleep(2.5);
	WhatToDoNext('', '');
} 
*/

///////////////////////////////////////
// defaultproperties
///////////////////////////////////////
/*
   SelectionMesh="Botpack.SelectionFemale2"
     MenuName="Female Soldier"
     VoiceType="BotPack.VoiceFemaleTwo"
     Mesh=LodMesh'Botpack.SGirl'
*/

defaultproperties
{
     bCanUseWeapon=False
     NPCWAff=0.800000
     FaceSkin=3
     FixedSkin=2
     TeamSkin2=1
     DefaultSkinName="SGirlSkins.army"
     DefaultPackage="SGirlSkins."
     bIsHuman=True
     GroundSpeed=500.000000
     BaseEyeHeight=27.000000
     EyeHeight=27.000000
     CollisionRadius=17.000000
     CollisionHeight=39.000000
     Buoyancy=99.000000
}
