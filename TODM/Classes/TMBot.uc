class TMBot extends s_BotMCounterTerrorist1;

var byte CptIAR;
var Carcass carc;

function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, name damageType)
{
    if (CptIAR>0) return; else OldTakeDamage(Damage,instigatedBy,hitlocation,momentum,damageType);
}

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

		PZone=Spawn(class'TMPBotZone',self);
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
	TMMod(Level.Game).RestartPlayer(self);
	GotoState('BotBuying');
/*	if ( !bHidden )
		HidePlayer();
	PlayerReplicationInfo.bIsSpectator = true;
	GotoState('GameEnded');*/
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

function eAttitude AttitudeTo(Pawn Other)
{
	local byte result;

    return ATTITUDE_Hate;
	result=TO_DeathMatchPlus(Level.Game).AssessBotAttitude(self,Other);
	Switch (result)
	{
		case 0:return ATTITUDE_Fear;
		case 1:return ATTITUDE_Hate;
		case 2:return ATTITUDE_Hate;
		case 3:return ATTITUDE_Hate;
	}
}

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

function OldTakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
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
			/*if ( PlayerReplicationInfo.Team == instigatedBy.PlayerReplicationInfo.Team ) {
				if (Health > ActualDamage)
					TO_PRI(instigatedBy.PlayerReplicationInfo).InflictedDmg -= actualDamage;
				else
					TO_PRI(instigatedBy.PlayerReplicationInfo).InflictedDmg -= Health;
			} else { */
				if (Health > ActualDamage)
					TO_PRI(instigatedBy.PlayerReplicationInfo).InflictedDmg += actualDamage;
				else
					TO_PRI(instigatedBy.PlayerReplicationInfo).InflictedDmg += Health;
			//}
		} else if (instigatedBy.IsA('s_Bot')) {
        	/*if ( PlayerReplicationInfo.Team == instigatedBy.PlayerReplicationInfo.Team ) {
				if (Health > ActualDamage)
					TO_BRI(instigatedBy.PlayerReplicationInfo).InflictedDmg -= actualDamage;
				else
					TO_BRI(instigatedBy.PlayerReplicationInfo).InflictedDmg -= Health;
			} else {*/
				if (Health > ActualDamage)
					TO_BRI(instigatedBy.PlayerReplicationInfo).InflictedDmg += actualDamage;
				else
					TO_BRI(instigatedBy.PlayerReplicationInfo).InflictedDmg += Health;
			//}
		/*
		if (instigatedBy.IsA('s_Player'))
		{
			if ( PlayerReplicationInfo.Team == instigatedBy.PlayerReplicationInfo.Team )
				TO_PRI(instigatedBy.PlayerReplicationInfo).InflictedDmg -= actualDamage;
			else
				TO_PRI(instigatedBy.PlayerReplicationInfo).InflictedDmg += actualDamage;
		} else if (instigatedBy.IsA('s_Bot')) {
			if ( PlayerReplicationInfo.Team == instigatedBy.PlayerReplicationInfo.Team )
 				TO_BRI(instigatedBy.PlayerReplicationInfo).InflictedDmg -= actualDamage;
			else
				TO_BRI(instigatedBy.PlayerReplicationInfo).InflictedDmg += actualDamage;*/
		} else log("s_Bot::TakeDamage - Instigator is not a pawn");
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

function SendVoiceMessage(PlayerReplicationInfo Sender, PlayerReplicationInfo Recipient, name messagetype, byte messageID, name broadcasttype)
{
}

function Escape()
{
}

defaultproperties
{
    PlayerReplicationInfoClass=class'TODM.TMBRI'
}

