class TOMAScriptedPawn extends ScriptedPawn;

var bool bIsFreezed;
var bool bIsAttired;
var int cptFreezed;
var bool alreadyinit;
var int oldone;
var Actor CenterAttraction;
var() int TimeOfFreeze;
var Actor shieldloc;
var string NameOfMonster;
var() bool FallingDownWhenFreeze;
var() int ScoreForKill;
var() int MoneyDroped;
var string sshot1,sshot2;
var int GiveMana;

function PreBeginPlay()
{
	AddPawn();
	Super(Actor).PreBeginPlay();
	if (bDeleteMe)
		return;

	// Set instigator to self.
	Instigator = Self;
	DesiredRotation = Rotation;
	SightCounter = 0.2 * FRand();  //offset randomly
	if ( Level.Game != None )
		Skill += Level.Game.Difficulty;
	Skill = FClamp(Skill, 0, 3);
	PreSetMovement();

	if ( DrawScale != Default.Drawscale )
	{
		SetCollisionSize(CollisionRadius*DrawScale/Default.DrawScale, CollisionHeight*DrawScale/Default.DrawScale);
		Health = Health * DrawScale/Default.DrawScale;
	}

	if (!self.IsA('TOMABloblet'))
	{
		if (PlayerReplicationInfoClass != None)
			PlayerReplicationInfo = Spawn(PlayerReplicationInfoClass, Self,,vect(0,0,0),rot(0,0,0));
		else
			PlayerReplicationInfo = Spawn(class'PlayerReplicationInfo', Self,,vect(0,0,0),rot(0,0,0));
		InitPlayerReplicationInfo();
	}

	if (!bIsPlayer)
	{
		if ( BaseEyeHeight == 0 )
			BaseEyeHeight = 0.8 * CollisionHeight;
		EyeHeight = BaseEyeHeight;
		if (Fatness == 0) //vary monster fatness slightly if at default
			Fatness = 120 + Rand(8) + Rand(8);
	}

	if ( menuname == "" )
		menuname = GetItemName(string(class));

	if (SelectionMesh == "")
		SelectionMesh = string(Mesh);

	if (Level.Game.bVeryLowGore)
		bGreenBlood=true;

	if (Skill>2)
		bLeadTarget=true;
	else if ((Skill==0) && (Health<500))
	{
		bLeadTarget=false;
		ReFireRate=0.75*ReFireRate;
	}

	if (bIsBoss)
		Health=Health+0.15*Skill*Health;

	bInitialFear=(AttitudeToPlayer==ATTITUDE_Fear);

	if ((TOMAMod(Level.Game).MonstersCanClimbWall) && (Physics!=PHYS_Flying)) SetPhysics(PHYS_Spider);

	self.PlayerReplicationInfo.PlayerName=NameOfMonster;
}

function Carcass SpawnCarcass()
{
	return None;
}

state PreRound
{
}

function eAttitude AttitudeToCreature(Pawn Other)
{
    if ((Other!=None) && (Other.PlayerReplicationInfo!=None))
    {
        if (Other.PlayerReplicationInfo.Team==self.PlayerReplicationInfo.Team) return ATTITUDE_Friendly;
        else
        {
            if ((Other.IsA('s_Bot')) || (Other.IsA('TOMAPlayer')))
                return ATTITUDE_Hate;
            else
                if (Other.IsA('TOMAScriptedPawn'))
                    return ATTITUDE_Friendly;
                else
                    return ATTITUDE_Hate;
        }
    }
}

state Freezed
{
	function tick(float delta)
	{
		if ((bIsFreezed) && (!alreadyinit))
		{
			alreadyinit=true;
			SetTimer(1,true);
		}
		if (Health<1) Destroy();
	}

	function Timer()
	{
		if (bIsFreezed)
		{
			cptfreezed++;
		}
		if (cptfreezed>=TimeOfFreeze)
		{
			ambientglow=oldone;
			cptfreezed=0;
			bIsFreezed=false;
			alreadyinit=false;
			Orders='Roaming';
			PreSetMovement();
			Style=STY_Normal;
			StartRoaming();
		}
	}
Begin:
	oldone=ambientglow;
	Destination=self.location;
	MoveTo(Destination);
	if (FallingDownWhenFreeze) SetPhysics(PHYS_FALLING);
	ambientglow=255;
	bIsFreezed=true;
	Orders='Defend';
	bCanFire=false;
	bCanJump=false;
	bCanWalk=false;
	bCanSwim=false;
	bCanFly=false;
	bCanOpenDoors=false;
	bCanDoSpecial=false;
	bCanDuck=false;
	Enemy=None;
	OldEnemy=None;
	Style=STY_Translucent;
	Enable('Tick');
}

function InitPlayerReplicationInfo()
{
}

state AttractBySmoke
{

	function Timer()
	{
		if (CenterAttraction==None)
		{
			Enable('Tick');
			Style=STY_Normal;
			StartRoaming();
		}
		if (Health<1) Destroy();
	}
Begin:
	Enemy=None;
	OldEnemy=None;
	MoveToward(CenterAttraction,WalkingSpeed*2);
	SetTimer(0.5,True);
	Style=STY_Translucent;
	Disable('Tick');
}

function bool SetEnemy(Pawn NewEnemy)
{
	local bool result;
	local eAttitude newAttitude, oldAttitude;
	local bool noOldEnemy;
	local float newStrength;

	if (NewEnemy==None)
		return false;
	if (NewEnemy.PlayerReplicationInfo==None) return false;
	if ((!NewEnemy.IsA('TOMABot')) && (!NewEnemy.IsA('TOMAPlayer')))
		return false;
	if ((NewEnemy==Self) || (NewEnemy.Health<=0))
		return false;
	if (NewEnemy.IsInState('PlayerWaiting')) return false;
	if (NewEnemy.PlayerReplicationInfo.Team==self.PlayerReplicationInfo.Team) return false;
	if ( !bCanWalk && !bCanFly && !NewEnemy.FootRegion.Zone.bWaterZone )
		return false;

    if ((TOMABot(NewEnemy)!=None) && (TOMABot(NewEnemy).CptIAR>0)) return false;
    if ((TOMAPlayer(NewEnemy)!=None) && (TOMAPlayer(NewEnemy).CptIAR>0)) return false;

	noOldEnemy=(Enemy==None);
	result=false;
	newAttitude=AttitudeTo(NewEnemy);
	if (!noOldEnemy)
	{
		if (Enemy!=None && Enemy==NewEnemy)
			return true;
		else if (NewEnemy.bIsPlayer && (AlarmTag!='') )
		{
			OldEnemy=Enemy;
			Enemy=NewEnemy;
			result=true;
		}
		else if (newAttitude==ATTITUDE_Friendly)
		{
			if (bIgnoreFriends)
				return false;
			if ((NewEnemy.Enemy!=None) && (NewEnemy.Enemy.Health>0))
			{
				if (NewEnemy.Enemy.bIsPlayer && (NewEnemy.AttitudeToPlayer<AttitudeToPlayer))
					AttitudeToPlayer=NewEnemy.AttitudeToPlayer;
				if (AttitudeTo(NewEnemy.Enemy)<AttitudeTo(Enemy))
				{
					OldEnemy=Enemy;
					Enemy=NewEnemy.Enemy;
					result=true;
				}
			}
		}
		else
		{
			oldAttitude=AttitudeTo(Enemy);
			if ((newAttitude<oldAttitude) ||
				( (newAttitude==oldAttitude) && (Enemy!=None)
					&& ((VSize(NewEnemy.Location-Location) < VSize(Enemy.Location-Location))
						|| !LineOfSightTo(Enemy))))
			{
				if ((bIsPlayer) && (Enemy!=None) && (Enemy.IsA('PlayerPawn')) && !(NewEnemy.IsA('PlayerPawn')))
				{
					newStrength=relativeStrength(NewEnemy);
					if ((newStrength<0.2) && (Enemy!=None) && (relativeStrength(Enemy)<FMin(0,newStrength))
						&& (IsInState('Hunting')) && (Level.TimeSeconds-HuntStartTime<5))
						result=false;
					else
					{
						result=true;
						OldEnemy=Enemy;
						Enemy=NewEnemy;
					}
				}
				else
				{
					result=true;
					OldEnemy=Enemy;
					Enemy=NewEnemy;
				}
			}
		}
	}
	else if (newAttitude<ATTITUDE_Ignore)
	{
		result=true;
		Enemy=NewEnemy;
	}
	else if (newAttitude==ATTITUDE_Friendly) //your enemy is my enemy
	{
		if ((NewEnemy.bIsPlayer) && (AlarmTag!=''))
		{
			Enemy=NewEnemy;
			result=true;
		}
		if (bIgnoreFriends)
			return false;

		if ((NewEnemy.Enemy!=None) && (NewEnemy.Enemy.Health>0))
		{
			result=true;
			Enemy=NewEnemy.Enemy;
			if ((Enemy!=None) && (Enemy.bIsPlayer))
				AttitudeToPlayer=ScriptedPawn(NewEnemy).AttitudeToPlayer;
			else if ((ScriptedPawn(NewEnemy)!=None) && (ScriptedPawn(NewEnemy).Hated==Enemy))
				Hated=Enemy;
		}
	}

	if (result)
	{
		LastSeenPos=Enemy.Location;
		LastSeeingPos=Location;
		EnemyAcquired();
		if ((!bFirstHatePlayer) && (Enemy!=None) && (Enemy.bIsPlayer) && (FirstHatePlayerEvent!=''))
			TriggerFirstHate();
	}
	else if ((NewEnemy.bIsPlayer) && (NewAttitude<ATTITUDE_Threaten))
		OldEnemy=NewEnemy;

	return result;
}

function StartRoaming()
{
	GotoState('Roaming');
}

auto state StartUp
{
	function InitAmbushLoc()
	{
		local Ambushpoint newspot;
		local float i;
		local rotator newRot;

		i = 1.0;
		foreach AllActors( class 'Ambushpoint', newspot, tag )
		{
			if ( !newspot.taken )
			{
				i = i + 1;
				if (FRand() < 1.0/i)
					OrderObject = newspot;
			}
		}
		if (OrderObject != None)
			Ambushpoint(OrderObject).Accept(self,None);
	}

	function InitPatrolLoc()
	{
	}

	function SetHome()
	{
		local NavigationPoint aNode;

		aNode = Level.NavigationPointList;

		while ( aNode != None )
		{
			if ( aNode.IsA('HomeBase') && (aNode.tag == tag) )
			{
				home = HomeBase(aNode);
				return;
			}
			aNode = aNode.nextNavigationPoint;
		}
	}

	function SetTeam()
	{
		local Pawn aPawn;
		local bool bFoundTeam;
		if (bTeamLeader)
		{
			TeamLeader = self;
			return;
		}
		TeamID = 1;
		aPawn = Level.PawnList;
		while ( aPawn != None )
		{
			if ( (ScriptedPawn(aPawn) != None) && (aPawn != self) && (ScriptedPawn(aPawn).TeamTag == TeamTag) )
			{
				if ( ScriptedPawn(aPawn).bTeamLeader )
				{
					bFoundTeam = true;
					TeamLeader = ScriptedPawn(aPawn);
				}
				if ( ScriptedPawn(aPawn).TeamID >= TeamID )
					TeamID = ScriptedPawn(aPawn).TeamID + 1;
			}
			aPawn = aPawn.nextPawn;
		}
		if ( !bFoundTeam )
			TeamTag = ''; //didn't find a team leader, so no team
	}

	function SetAlarm()
	{
		local Pawn aPawn, currentWinner;
		local float i;

		currentWinner = self;
		i = 1.0;

		aPawn = Level.PawnList;
		while ( aPawn != None )
		{
			if ( aPawn.IsA('ScriptedPawn') && (ScriptedPawn(aPawn).SharedAlarmTag == SharedAlarmTag) )
			{
				ScriptedPawn(aPawn).SharedAlarmTag = '';
				i += 1;
				if (FRand() < 1.0/i)
					currentWinner = aPawn;
			}
			aPawn = aPawn.nextPawn;
		}

		ScriptedPawn(currentWinner).AlarmTag = SharedAlarmTag;
		SharedAlarmTag = '';
	}

	function BeginState()
	{
		SetMovementPhysics();
		if (Physics == PHYS_Walking)
			SetPhysics(PHYS_Falling);
	}

Begin:
	SetHome();
	if (SharedAlarmTag != '')
		SetAlarm();
	if (TeamTag != '')
		SetTeam();
	StartRoaming();
}

function SetMovementPhysics()
{
	if (Physics==PHYS_Falling)
		return;

	if ( Region.Zone.bWaterZone )
		SetPhysics(PHYS_Swimming);
	else if (Physics != PHYS_Walking)
		SetPhysics(PHYS_Walking);

	if ((TOMAMod(Level.Game).MonstersCanClimbWall) && (Physics==PHYS_Walking)) SetPhysics(PHYS_Spider);
}

/*function bool EncroachingOn(actor Other)
{
	if ((Other.Brush!=None) || (Brush(Other)!=None))
		return true;
	return false;
}*/

function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, name damageType)
{
    local int realh,newmana,coef;
    local float coef;

    if ((InstigatedBy!=None) && (InstigatedBy.IsA('TOMAScriptedPawn')) && (TOMAMod(Level.Game).FriendlyFireScale==0.000000)) return;

    super.TakeDamage(Damage,instigatedBy,hitlocation,momentum,damageType);

	if (instigatedBy!=None)
	{
       	if ((instigatedBy.IsA('TOMAPlayer')) && (instigatedBy.PlayerReplicationInfo!=None))
		{
            if (Health>Damage)
				TO_PRI(instigatedBy.PlayerReplicationInfo).InflictedDmg+=abs(Damage);
			else
				TO_PRI(instigatedBy.PlayerReplicationInfo).InflictedDmg+=abs(Health);
		}
        else
       	if ((instigatedBy.IsA('TOMABot')) && (instigatedBy.PlayerReplicationInfo!=None))
		{
            if (Health>Damage)
				TO_BRI(instigatedBy.PlayerReplicationInfo).InflictedDmg+=Damage;
			else
				TO_BRI(instigatedBy.PlayerReplicationInfo).InflictedDmg+=Health;
		}
        else
       	if ((instigatedBy.IsA('TOMAScriptedPawn')) && (instigatedBy.PlayerReplicationInfo!=None))
		{
            if (Health>Damage)
				if (TOMAMod(Level.Game).FriendlyFireScale>0) TOMAMonstersReplicationInfo(instigatedBy.PlayerReplicationInfo).InflictedDmg-=Damage;
			else
				if (TOMAMod(Level.Game).FriendlyFireScale>0) TOMAMonstersReplicationInfo(instigatedBy.PlayerReplicationInfo).InflictedDmg-=Health;
		}
		if (GiveMana>0)
		{
		  if ( (InstigatedBy.IsA('TOMAPlayer')) || (InstigatedBy.IsA('TOMABot')) )
		  {
		      realh=Damage/TOMAMod(Level.Game).HealthMult;
		      coef=default.Health/default.Mana;
		      newmana=coef*damage;
		      if (InstigatedBy.IsA('TOMAPlayer')) TOMAPlayer(InstigatedBy).Mana+=newmana;
		      else TOMABot(InstigatedBy).Mana+=newmana;
		  }
		}
    }
}

state TacticalMove
{
ignores SeePlayer, HearNoise;

	function SetFall()
	{
		Acceleration = vect(0,0,0);
		Destination = Location;
		NextState = 'Attacking';
		NextLabel = 'Begin';
		NextAnim = 'Fighter';
		GotoState('FallingState');
	}

	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
						Vector momentum, name damageType)
	{
		Global.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
		if ( health <= 0 )
			return;
		if ( NextState == 'TakeHit' )
		{
			NextState = 'TacticalMove';
			NextLabel = 'TakeHit';
			GotoState('TakeHit');
		}
	}

	function HitWall(vector HitNormal, actor Wall)
	{
		if (Physics == PHYS_Falling)
			return;
		Focus = Destination;
		//if (PickWallAdjust())
		//	GotoState('TacticalMove', 'AdjustFromWall');
		if ( bChangeDir || (FRand() < 0.5)
			|| (((Enemy.Location - Location) Dot HitNormal) < 0) )
		{
			DesiredRotation = Rotator(Enemy.Location - location);
			GiveUpTactical(false);
		}
		else
		{
			bChangeDir = true;
			Destination = Location - HitNormal * FRand() * 500;
		}
	}

	function FearThisSpot(Actor aSpot)
	{
		Destination = Location + 120 * Normal(Location - aSpot.Location);
	}

	function AnimEnd()
	{
		PlayCombatMove();
	}

	function Timer()
	{
		bReadyToAttack = True;
		Enable('Bump');
		if (Enemy!=None) Target = Enemy;
		if ( Enemy!=None && VSize(Enemy.Location - Location)
				<= (MeleeRange + Enemy.CollisionRadius + CollisionRadius))
			GotoState('MeleeAttack');
		else if ( bHasRangedAttack && ((!bMovingRangedAttack && (FRand() < 0.8)) || (FRand() > 0.5 + 0.17 * skill)) )
			GotoState('RangedAttack');
	}

	function EnemyNotVisible()
	{
		if ( aggressiveness > relativestrength(enemy) )
		{
			if (ValidRecovery())
				GotoState('TacticalMove','RecoverEnemy');
			else
				GotoState('Attacking');
		}
		Disable('EnemyNotVisible');
	}

	function bool ValidRecovery()
	{
		local actor HitActor;
		local vector HitLocation, HitNormal;

		HitActor = Trace(HitLocation, HitNormal, Enemy.Location, LastSeeingPos, false);
		return (HitActor == None);
	}

	function GiveUpTactical(bool bNoCharge)
	{
		if ( !bNoCharge && (2 * CombatStyle > (3 - Skill) * FRand()) )
			GotoState('Charging');
		else if ( bReadyToAttack && (skill > 3 * FRand() - 1) )
			GotoState('RangedAttack');
		else
			GotoState('RangedAttack', 'Challenge');
	}

/* PickDestination()
Choose a destination for the tactical move, based on aggressiveness and the tactical
situation. Make sure destination is reachable
*/
	function PickDestination(bool bNoCharge)
	{
		local vector pickdir, enemydir, enemyPart, Y, minDest;
		local actor HitActor;
		local vector HitLocation, HitNormal, collSpec;
		local float Aggression, enemydist, minDist, strafeSize, optDist;
		local bool success, bNoReach;

		bChangeDir = false;
		if (Region.Zone.bWaterZone && !bCanSwim && bCanFly)
		{
			Destination = Location + 75 * (VRand() + vect(0,0,1));
			Destination.Z += 100;
			return;
		}
		if ((Enemy!=None) && ( Enemy.Region.Zone.bWaterZone ))
			bNoCharge = bNoCharge || !bCanSwim;
		else
			bNoCharge = bNoCharge || (!bCanFly && !bCanWalk);

		success = false;
		if (Enemy!=None) enemyDist = VSize(Location - Enemy.Location);
		Aggression = 2 * (CombatStyle + FRand()) - 1.1;
		if ( intelligence == BRAINS_Human )
		{
			if ( (Enemy!=None) && Enemy.bIsPlayer && (AttitudeToPlayer == ATTITUDE_Fear) && (CombatStyle > 0) )
				Aggression = Aggression - 2 - 2 * CombatStyle;
			if ( Weapon != None )
				Aggression += 2 * Weapon.SuggestAttackStyle();
			if ( Enemy.Weapon != None )
				Aggression += 2 * Enemy.Weapon.SuggestDefenseStyle();
		}

		if ( enemyDist > 1000 )
			Aggression += 1;
		if ( bIsPlayer && !bNoCharge )
			bNoCharge = ( Aggression < FRand() );

		if ( (Physics == PHYS_Walking) || (Physics == PHYS_Falling) )
		{
			if (Location.Z > Enemy.Location.Z + 140) //tactical height advantage
				Aggression = FMax(0.0, Aggression - 1.0 + CombatStyle);
			else if (Location.Z < Enemy.Location.Z - CollisionHeight) // below enemy
			{
				if ( !bNoCharge && (Intelligence > BRAINS_Reptile)
					&& (Aggression > 0) && (FRand() < 0.6) )
				{
					GotoState('Charging');
					return;
				}
				else if ( (enemyDist < 1.1 * (Enemy.Location.Z - Location.Z))
						&& !actorReachable(Enemy) )
				{
					bNoReach = (Intelligence > BRAINS_None);
					aggression = -1.5 * FRand();
				}
			}
		}

		if (!bNoCharge && (Aggression > 2 * FRand()))
		{
			if ( bNoReach && (Physics != PHYS_Falling) )
			{
				TweenToRunning(0.15);
				GotoState('Charging', 'NoReach');
			}
			else
				GotoState('Charging');
			return;
		}

		if ( enemy!=none && enemyDist > FMax(VSize(OldLocation - Enemy.OldLocation), 240))
			Aggression += 0.4 * FRand();

		if (Enemy!=none) enemydir = (Enemy.Location - Location)/enemyDist;
		minDist = FMin(160.0, 3*CollisionRadius);
		if ( bIsPlayer )
			optDist = 80 + FMin(EnemyDist, 250 * (FRand() + FRand()));
		else
			optDist = 50 + FMin(EnemyDist, 500 * FRand());
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
				if ( (CombatStyle <= 0) || (Enemy.bIsPlayer && (AttitudeToPlayer == ATTITUDE_Fear)) )
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
		MinHitWall += 0.15;
		bAvoidLedges = ( !bCanJump && (CollisionRadius > 40) );
		bCanJump = false;
		bCanFire = false;
	}

	function EndState()
	{
		bAvoidLedges = false;
		MinHitWall -= 0.15;
		if (JumpZ > 0)
			bCanJump = true;
	}

//FIXME - what if bReadyToAttack at start
TacticalTick:
	Sleep(0.02);
Begin:
	TweenToRunning(0.15);
	Enable('AnimEnd');
	if (Physics == PHYS_Falling)
	{
        if (Enemy!=None)
        {
		DesiredRotation = Rotator(Enemy.Location - Location);
		Focus = Enemy.Location;
		Destination = Enemy.Location;
		}
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
		bCanFire = false;
		MoveTo(Destination);
	}
	else
	{
DoStrafeMove:
		Enable('AnimEnd');
		bCanFire = true;
		StrafeFacing(Destination, Enemy);
	}
	if (FRand() < 0.5)
		PlayThreateningSound();

	if ( (Enemy != None) && !LineOfSightTo(Enemy) && ValidRecovery() )
		Goto('RecoverEnemy');
	else
	{
		bReadyToAttack = true;
		GotoState('Attacking');
	}

NoCharge:
	TweenToRunning(0.15);
	Enable('AnimEnd');
	if (Physics == PHYS_Falling)
	{
        if (Enemy!=None)
        {
		DesiredRotation = Rotator(Enemy.Location - Location);
		Focus = Enemy.Location;
		Destination = Enemy.Location;
		}
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
	Destination = LastSeeingPos + 3 * CollisionRadius * Normal(LastSeeingPos - Location);
	if ( bCanStrafe || (VSize(LastSeeingPos - Location) < 3 * CollisionRadius) )
		StrafeFacing(Destination, Enemy);
	else
		MoveTo(Destination);
	if ( Weapon == None )
		Acceleration = vect(0,0,0);
	if ( Enemy!=None && NeedToTurn(Enemy.Location) )
	{
		PlayTurning();
		if (Enemy!=None) TurnToward(Enemy);
	}
	if ( bHasRangedAttack && CanFireAtEnemy() )
	{
		Disable('AnimEnd');
		if (Enemy!=None) DesiredRotation = Rotator(Enemy.Location - Location);
		if ( Weapon == None )
		{
			PlayRangedAttack();
			FinishAnim();
			TweenToRunning(0.1);
			bReadyToAttack = false;
			SetTimer(TimeBetweenAttacks, false);
		}
		else
		{
			FireWeapon();
			if ( Weapon.bSplashDamage )
			{
				bFire = 0;
				bAltFire = 0;
			}
		}

		if ( bCanStrafe && (FRand() + 0.1 > CombatStyle) )
		{
			Enable('EnemyNotVisible');
			Enable('AnimEnd');
			Destination = HidingSpot + 4 * CollisionRadius * Normal(HidingSpot - Location);
			Goto('DoMove');
		}
	}
	if ( !bMovingRangedAttack )
		bReadyToAttack = false;

	GotoState('Attacking');
}

function bool MeleeDamageTarget(int hitdamage, vector pushdir)
{
	local vector HitLocation, HitNormal, TargetPoint;
	local actor HitActor;

	// check if still in melee range
	If ( (Target!=None) && (Enemy!=None) && (VSize(Target.Location - Location) <= MeleeRange * 1.4 + Target.CollisionRadius + CollisionRadius)
		&& ((Physics == PHYS_Flying) || (Physics == PHYS_Swimming) || (Abs(Location.Z - Enemy.Location.Z)
			<= FMax(CollisionHeight, Enemy.CollisionHeight) + 0.5 * FMin(CollisionHeight, Enemy.CollisionHeight))) )
	{
		if (Enemy!=None) HitActor = Trace(HitLocation, HitNormal, Enemy.Location, Location, false);
		if ( HitActor != None )
			return false;
		if (Target!=None) Target.TakeDamage(hitdamage, Self,HitLocation, pushdir, 'hacked');
		return true;
	}
	return false;
}

defaultproperties
{
	TimeOfFreeze=13
	bFixedStart=false
	Orders='Roaming'
	PlayerReplicationInfoClass=Class'TOMA21.TOMAMonstersReplicationInfo'
	Team=-1
	Intelligence=BRAINS_HUMAN
	Orders='Roaming'
	FallingDownWhenFreeze=True
	ScoreForKill=0
	MoneyDroped=100
	sshot1=""
	sshot2=""
	GiveMana=0
}
