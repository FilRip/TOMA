class TFBot extends s_BotMCounterTerrorist1;

var byte CptIAR;
var Carcass carc;

simulated function PostBeginPlay()
{
	super(s_botbase).PostBeginPlay();

	if (Level.NetMode!=NM_DedicatedServer)
	{
		if (Shadow!=None)
			Shadow.Destroy();

		Shadow=Spawn(class's_PlayerShadow',self);

		if (TOPRI!=None)
			TOPRI.Destroy();

		TOPRI=Spawn(class's_PRI',self);
	}

	if (Role==Role_Authority)
	{
		if (PZone!=None)
			PZone.Destroy();

		PZone=Spawn(class'TFPBotZone',self);
		if (PZone!=None)
			PZone.Initialize();
	}
}

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
	Sleep(0.05);
	SpawnCarcass();
	Sleep(1);
	bNotPlaying=false;
	TFMod(Level.Game).RestartPlayer(self);
	GotoState('BotBuying');
/*
	if ( Level.Game.bGameEnded )
		GotoState('GameEnded');
	Sleep(0.1);
	if ( !bHidden )
		SpawnCarcass();

TryAgain:
	if ( !bHidden )
		HidePlayer();
	Sleep(0.1 + TO_DeathMatchPlus(Level.Game).SpawnWait(self));
	ReStartPlayer();
	Goto('TryAgain');

WaitingForStart:
	bHidden = true;
*/
}

function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, name damageType)
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
       		if ((instigatedBy.IsA('s_Player')) && (instigatedBy.PlayerReplicationInfo!=none))
		{
			if ( PlayerReplicationInfo.Team == instigatedBy.PlayerReplicationInfo.Team ) {
				if (Health > ActualDamage)
					TO_PRI(instigatedBy.PlayerReplicationInfo).InflictedDmg -= actualDamage;
				else
					TO_PRI(instigatedBy.PlayerReplicationInfo).InflictedDmg -= Health;
			} else {
				if (Health > ActualDamage)
					TO_PRI(instigatedBy.PlayerReplicationInfo).InflictedDmg += actualDamage;
				else
					TO_PRI(instigatedBy.PlayerReplicationInfo).InflictedDmg += Health;
			}
		} else if ((instigatedBy.IsA('s_Bot')) && (instigatedby.PlayerReplicationInfo!=none)) {
        	if ( PlayerReplicationInfo.Team == instigatedBy.PlayerReplicationInfo.Team ) {
				if (Health > ActualDamage)
					TO_BRI(instigatedBy.PlayerReplicationInfo).InflictedDmg -= actualDamage;
				else
					TO_BRI(instigatedBy.PlayerReplicationInfo).InflictedDmg -= Health;
			} else {
				if (Health > ActualDamage)
					TO_BRI(instigatedBy.PlayerReplicationInfo).InflictedDmg += actualDamage;
				else
					TO_BRI(instigatedBy.PlayerReplicationInfo).InflictedDmg += Health;
			}
		} //else log("s_Bot::TakeDamage - Instigator is not a pawn");
	} //else log("s_Bot::TakeDamage - Instigator == none");

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

function WhatToDoNext(name LikelyState,name LikelyLabel)
{
	if (bVerbose)
	{
		log(self$" what to do next");
		log("enemy "$Enemy);
		log("old enemy "$OldEnemy);
	}
	if ((Level.NetMode!=NM_Standalone) && Level.Game.IsA('TO_DeathMatchPlus') && TO_DeathMatchPlus(Level.Game).TooManyBots())
	{
		Destroy();
		return;
	}

	BlockedPath=None;
	bDevious=false;
	bFire=0;
	bAltFire=0;
	bKamikaze=false;
	if (BotReplicationInfo(PlayerReplicationInfo)!=None) SetOrders(BotReplicationInfo(PlayerReplicationInfo).RealOrders,BotReplicationInfo(PlayerReplicationInfo).RealOrderGiver,true);
	Enemy=OldEnemy;
	OldEnemy=None;
	bReadyToAttack=false;
	if (Enemy!=None)
	{
		bReadyToAttack=!bNovice;
		GotoState('Attacking');
	}
	else if ((Orders=='Hold') && (Weapon!=None) && (Weapon.AIRating>0.4) && (Health>70))
			GotoState('Hold');
	else
	{
		if (!IsInState('Roaming')) // Added by Shag
			GotoState('Roaming');
		if (Skill>2.7)
			bReadyToAttack=true;
	}
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

	if ( (Other!=None) && Other.IsA('Pawn') )
		victim = pawn(Other);


	if ( (victim!=None) && (victim.PlayerReplicationInfo.Team == PlayerReplicationInfo.Team) )
	{
		bReadyToAttack = false;
		return;
	}


	if ( (Enemy == None) && bShootSpecial )
	{
		//fake use s_Glock
		MyGlock = Weapon(FindInventoryType(class's_Glock'));
		if ( (MyGlock==None) && (target!=none) )
			Spawn(class's_Projectile',,, Location,Rotator(Target.Location - Location));
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


	if ( Weapon != None )
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

		ViewRotation = Rotation;

/*
		if ( bUseAltMode )
		{
			bFire = 0;
			bAltFire = 1;
			Weapon.AltFire(1.0);
		}
		else
		{
*/
		/*
		if ( BlindTime > 0 && (FRand() > 0.5) )
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

						if ( (bots!=None) && (VSize(bots.Location - Location) < 700)
							&& (bots.PlayerReplicationInfo.Team == PlayerReplicationInfo.Team) )
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

function SetOrders(name NewOrders, Pawn OrderGiver, optional bool bNoAck)
{
	local Pawn P;
	local Bot B;

	if ( NewOrders == '' )
		NewOrders = 'Freelance';

	if ( Orders == '' )
		Orders = 'Freelance';

	if ( Orders == NewOrders )
		return;

	if ( BotReplicationInfo(PlayerReplicationInfo)!=None && NewOrders != BotReplicationInfo(PlayerReplicationInfo).RealOrders )
	{
		if ( (IsInState('Roaming') && bCamping) || IsInState('Wandering') )
			GotoState('Roaming', 'PreBegin');
		else if ( !IsInState('Dying') )
			GotoState('Attacking');
	}

	bLeading = false;
	if ( NewOrders == 'Point' )
	{
		NewOrders = 'Attack';
		SupportingPlayer = PlayerPawn(OrderGiver);
	}
	else
		SupportingPlayer = None;

	if ( bSniping && (NewOrders != 'Defend') )
		bSniping = false;
	bStayFreelance = false;
	if ( !bNoAck && (OrderGiver != None) )
		SendTeamMessage(OrderGiver.PlayerReplicationInfo, 'ACK', Rand(class<ChallengeVoicePack>(PlayerReplicationInfo.VoiceType).Default.NumAcks), 5);

	if (BotReplicationInfo(PlayerReplicationInfo)!=None)
	{
        BotReplicationInfo(PlayerReplicationInfo).SetRealOrderGiver(OrderGiver);
	   BotReplicationInfo(PlayerReplicationInfo).RealOrders = NewOrders;
	}

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
		if ( !bNoAck )
			OrderObject = OrderGiver.Spawn(class'HoldSpot');
	}
	else if ( Orders == 'Follow' )
	{
		Aggressiveness += 1;
		OrderObject = OrderGiver;
	}
	else if ( Orders == 'Defend' )
	{
		if ( Level.Game.IsA('TO_TeamGamePlus') )
			OrderObject = TO_TeamGamePlus(Level.Game).SetDefenseFor(self);
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
	}
	else if ( Orders == 'Attack' )
	{
		CampingRate = 0.0;
		// set bLeading if have supporters
		if ( Level.Game.bTeamGame )
			for ( P=Level.PawnList; P!=None; P=P.NextPawn )
				if ( P.bIsPlayer && P.PlayerReplicationInfo!=None && (P.PlayerReplicationInfo.Team == PlayerReplicationInfo.Team) )
				{
					B = Bot(P);
					if ( (B != None) && (B.OrderObject == self) && (BotReplicationInfo(B.PlayerReplicationInfo)!=none) && (BotReplicationInfo(B.PlayerReplicationInfo).RealOrders == 'Follow') )
					{
						bLeading = true;
						break;
					}
				}
	}

	if (BotReplicationInfo(PlayerReplicationInfo)!=None) BotReplicationInfo(PlayerReplicationInfo).OrderObject = OrderObject;
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
     PlayerReplicationInfoClass=Class'TOCTF.TFBRI'
}

