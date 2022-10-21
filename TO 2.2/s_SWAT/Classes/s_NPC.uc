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

class s_NPC expands s_BotBase
	abstract;

var		s_PRI				TOPRI;
var		TO_PZone		PZone;					// Zone checking

var float						LastWhatToDoNextCheck;

var float						WalkSpeed;			// The percentage of GroundSpeed that this pawn walks at.
var Class<Carcass>	CarcassType;		// The type of carcass to use for this pawn.
var bool						DropBackpack;		// True if this pawn should drop a backpack when it dies.

var bool						bNeedWeapon;

// Action information.

var int							HelmetCharge;
var int             VestCharge;
var int             LegsCharge;

var Vector					MoveDestination;	// The location this pawn is moving to.
var bool						WallAdjust;				// True if this pawn is avoiding a wall.
var int							EnemyTeam;					// 0 : t; 1 : ct; 255 : none;

var Pawn						Tortionary;				// Last player who shot this NPC
var bool						bCanUseWeapon;		// never pickup weapon if false
var float						NPCWAff;

var	vector					MoveAwayFrom;			// Actor that bumps into the NPC

// Zone check
//var		bool					bInBuyZone, bInHomeBase, bInEscapeZone, bInRescueZone, bInHostageHidingPlace, bInC4Zone;

/*
// Foot steps
enum EFloorMaterial
{
	FM_Stone,
	FM_metalstep,
	FM_snowstep,
	FM_stonestep,
	FM_woodstep,
	FM_woodwarmstep,
};
*/

var string s_Voice;		


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

		if ( TOPRI != None )
			TOPRI.Destroy();

		TOPRI = Spawn(class's_PRI', self);
	}

	if ( Role == Role_Authority )
	{
		// Zone Checking
		if ( PZone != None )
			PZone.Destroy();

		PZone = Spawn(class'TO_PZone', self);
		if ( PZone != None )
		{
			//PZone.Frequency = 2.0;
			PZone.Initialize();
		}
	}
}


///////////////////////////////////////
// Destroyed 
///////////////////////////////////////

simulated event Destroyed()
{
	Super.Destroyed();

	if ( Shadow != None )
		Shadow.Destroy();

	if ( TOPRI != None )
		TOPRI.Destroy();

	if ( PZone != None )
		PZone.Destroy();
}


///////////////////////////////////////
// SetSkinElement 
///////////////////////////////////////

static function bool SetSkinElement(Actor SkinActor, int SkinNo, string SkinName, string DefaultSkinName)
{
	local Texture NewSkin;
	local bool bProscribed, bNoCheck;
	local string ServerPackages, pkg, SkinItem, MeshName;
	local int i;

	NewSkin = Texture(DynamicLoadObject(SkinName, class'Texture'));
	if ( !bProscribed && (NewSkin != None) )
	{
		SkinActor.Multiskins[SkinNo] = NewSkin;
		return True;
	}
	else
	{
		log("Failed to load "$SkinName$" so load "$DefaultSkinName);
		if(DefaultSkinName != "")
		{
			NewSkin = Texture(DynamicLoadObject(DefaultSkinName, class'Texture'));
			SkinActor.Multiskins[SkinNo] = NewSkin;
		}
		return False;
	}
}


//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
// Startup functions
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////


///////////////////////////////////////
// InitPawn
///////////////////////////////////////

function InitPawn()
{
	SetMovementPhysics();
	GotoState('Waiting');
}


///////////////////////////////////////
// Startup
///////////////////////////////////////

auto state Startup
{
Begin:

	InitPawn();
}


//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
// Physics functions
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////



///////////////////////////////////////
// Carcass
///////////////////////////////////////

function Carcass SpawnCarcass()
{
	local carcass carc;

	carc = Spawn(CarcassType);
	if ( carc != None )
	{
		//PlayBodyDrop(carc);
		carc.Initfor(self);
	}
	else
		log("Carcass = none"$CarcassType);

	return carc;
}


///////////////////////////////////////
// SetMovementPhysics
///////////////////////////////////////

function SetMovementPhysics()
{
	SetPhysics(PHYS_Walking);
}


///////////////////////////////////////
// Falling
///////////////////////////////////////

function Falling()
{
	GotoState('FallingState');
}


//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
// AI Functions 
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////


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

	//log("bump - other: "$Other);

	P = Pawn(Other);
	if ( (P != None) /**/&& CheckBumpAttack(P)/**/ )
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
				/**/if ( Enemy != None )
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
						
						//GotoState('MoveAway');
						//MoveAway();
					}		
				}
				else/* if ( (Health > 0) && !IsInState('Wandering') || (Acceleration == vect(0,0,0)) ) */
				{
					//WanderDir = Normal(Location - P.Location);
					//GotoState('Wandering', 'Begin');
					MoveAway(P);
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
/**/	else if ( (Health > 0) && (Enemy == None) && (bCamping 
				|| ((Orders == 'Follow') && (MoveTarget != None) && (MoveTarget == OrderObject) && (MoveTarget.Acceleration == vect(0,0,0)))) )
		GotoState('Wandering', 'Begin'); /**/
	//Disable('Bump');
}


///////////////////////////////////////
// CanTossWeaponTo
///////////////////////////////////////

function bool CanTossWeaponTo( Pawn aPlayer )
{
	if (AttitudeTo(aPlayer) == ATTITUDE_Friendly || ( AttitudeTo(aPlayer) == ATTITUDE_Ignore && Frand()<0.35 ) ) 
		return true;
	return false;
}


///////////////////////////////////////
// AttitudeTo
///////////////////////////////////////

function eAttitude AttitudeTo(Pawn Other)
{
	local byte result;

	if ( Level.Game.IsA('s_SWATGame') )
	{
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
					return Attitude_Fear;
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
// FireWeapon
///////////////////////////////////////

function FireWeapon()
{
	if (Weapon == None)
		return;

	Super.FireWeapon();
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
// CanImpactJump
///////////////////////////////////////

function bool CanImpactJump()
{
	return false;
}


///////////////////////////////////////
// SetMultiSkin
///////////////////////////////////////

static function SetMultiSkin(Actor SkinActor, string SkinName, string FaceName, byte TeamNum)
{
 	if ( (TeamNum > 31) || (class'TOPModels.TO_ModelHandler'.default.ModelType[TeamNum] == MT_None) )
		return;

	if (class'TOPModels.TO_ModelHandler'.default.Skin0[TeamNum] != "")
		SetSkinElement(SkinActor, 0, class'TOPModels.TO_ModelHandler'.default.Skin0[TeamNum], "");

	SetSkinElement(SkinActor, 1, class'TOPModels.TO_ModelHandler'.default.Skin1[TeamNum], "");
	SetSkinElement(SkinActor, 2, class'TOPModels.TO_ModelHandler'.default.Skin2[TeamNum], "");
	SetSkinElement(SkinActor, 3, class'TOPModels.TO_ModelHandler'.default.Skin3[TeamNum], "");

	if (class'TOPModels.TO_ModelHandler'.default.Skin4[TeamNum] != "")
		SetSkinElement(SkinActor, 4, class'TOPModels.TO_ModelHandler'.default.Skin4[TeamNum], "");

	if (class'TOPModels.TO_ModelHandler'.default.Skin5[TeamNum] != "")
		SetSkinElement(SkinActor, 5, class'TOPModels.TO_ModelHandler'.default.Skin4[TeamNum], "");

}

/*
///////////////////////////////////////
// SetMultiSkin
///////////////////////////////////////

static function SetMultiSkin(Actor SkinActor, string SkinName, string FaceName, byte TeamNum)
{
	local string MeshName, FacePackage, SkinItem, FaceItem, SkinPackage;

	MeshName = SkinActor.GetItemName(string(SkinActor.Mesh));

	SkinItem = SkinActor.GetItemName(SkinName);
	FaceItem = SkinActor.GetItemName(FaceName);
	FacePackage = Left(FaceName, Len(FaceName) - Len(FaceItem));
	SkinPackage = Left(FaceName, Len(SkinName) - Len(SkinItem));

	if(SkinPackage == "")
	{
		SkinPackage=default.DefaultPackage;
		SkinName=SkinPackage$SkinName;
	}
	if(FacePackage == "")
	{
		FacePackage=default.DefaultPackage;
		FaceName=FacePackage$FaceName;
	}
	// Set the fixed skin element.  If it fails, go to default skin & no face.
	if(!SetSkinElement(SkinActor, default.FixedSkin, SkinName$string(default.FixedSkin+1), default.DefaultSkinName$string(default.FixedSkin+1)))
	{
		SkinName = default.DefaultSkinName;
		FaceName = "";
	}

	// Set the face - if it fails, set the default skin for that face element.
	SetSkinElement(SkinActor, default.FaceSkin, FacePackage$SkinItem$String(default.FaceSkin+1)$FaceItem, SkinName$String(default.FaceSkin+1));
	// Set the team elements
	if( TeamNum != 255 )
	{
		SetSkinElement(SkinActor, default.TeamSkin1, SkinName$string(default.TeamSkin1+1)$"T_"$String(TeamNum), SkinName$string(default.TeamSkin1+1));
		SetSkinElement(SkinActor, default.TeamSkin2, SkinName$string(default.TeamSkin2+1)$"T_"$String(TeamNum), SkinName$string(default.TeamSkin2+1));
	}
	else
	{
		SetSkinElement(SkinActor, default.TeamSkin1, SkinName$string(default.TeamSkin1+1), "");
		SetSkinElement(SkinActor, default.TeamSkin2, SkinName$string(default.TeamSkin2+1), "");
	}
	// Set the talktexture
	if(Pawn(SkinActor) != None)
	{
		if(FaceName != "")
			Pawn(SkinActor).PlayerReplicationInfo.TalkTexture = Texture(DynamicLoadObject(FacePackage$SkinItem$"5"$FaceItem, class'Texture'));
		else
			Pawn(SkinActor).PlayerReplicationInfo.TalkTexture = None;
	}
}
*/

//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
// States
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////


///////////////////////////////////////
// Waiting
///////////////////////////////////////

state Waiting
{
Begin:

	// Stop moving.

	Acceleration = Vect(0,0,0);
	Velocity = Vect(0,0,0);

	// Play the waiting animation.

	PlayWaiting();
	FinishAnim();

	// Think.
	// Don't call this to often
	if ( LastWhatToDoNextCheck < Level.TimeSeconds)
		WhatToDoNext('','');
}


//////////////////////////////////////////////////////////////////////////////
// Following
//////////////////////////////////////////////////////////////////////////////

state Following
{
	ignores EnemyNotVisible;

	function SetOrders(name NewOrders, Pawn OrderGiver, optional bool bNoAck)
	{
		Global.SetOrders(NewOrders, OrderGiver, bNoAck);
		if ( bCamping && ((Orders == 'Hold') || (Orders == 'Follow')) )
			GotoState('Following', 'PreBegin');
	}

	function HearPickup(Pawn Other)
	{
		if ( bNovice || (Skill < 4 * FRand() - 1) )
			return;
		if ( (Health > 70) && Weapon!=None && (Weapon.AiRating > 0.6) 
			&& (RelativeStrength(Other) < 0) )
			HearNoise(0.5, Other);
	}
				
	function ShootTarget(Actor NewTarget)
	{
		if (Weapon!=None)
		{
			Target = NewTarget;
			bFiringPaused = true;
			SpecialPause = 2.0;
			NextState = GetStateName();
			NextLabel = 'Begin';
			GotoState('RangedAttack');
		}
	}

	function MayFall()
	{
		//bCanJump = false;
		bCanJump = ( (MoveTarget != None) && ((MoveTarget.Physics != PHYS_Falling) || !MoveTarget.IsA('Inventory')) );
	}
	
	function HandleHelpMessageFrom(Pawn Other) {}

	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, name damageType)
	{
		Global.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
		if ( health <= 0 )
			return;
		if (NextState == 'TakeHit' && Weapon!=None)
		{
			NextState = 'Attacking'; 
			NextLabel = '';
			GotoState('TakeHit'); 
		}
		else if ( Weapon!=None && !bCanFire && (skill > 3 * FRand()) )
			GotoState('Attacking');
	}

	function FearThisSpot(Actor aSpot)
	{
		Destination = Location + 120 * Normal(Location - aSpot.Location); 
		GotoState('Wandering', 'Moving');
	}
	
	function Timer()
	{
		bReadyToAttack = True;
		Enable('Bump');
	}

	function SetFall()
	{ /*
		bWallAdjust = false;
		NextState = 'Following'; 
		NextLabel = 'Landed';
		NextAnim = AnimSequence;
		GotoState('FallingState'); 
		*/
		if (Enemy != None)
		{
			NextState = '';
			NextLabel = '';
			TweenToFalling();
			NextAnim = AnimSequence;
			GotoState('FallingState');
		}
	}

	function EnemyAcquired()
	{
		if (Weapon!=None)
			GotoState('Acquisition');
	}

	function HitWall(vector HitNormal, actor Wall)
	{
		if (Physics == PHYS_Falling)
			return;
		if ( Wall.IsA('Mover') && Mover(Wall).HandleDoor(self) )
		{
			if ( SpecialPause > 0 )
				Acceleration = vect(0,0,0);
			GotoState('Following', 'SpecialNavig');
			return;
		}
		Focus = Destination;
		if ( !bWallAdjust && PickWallAdjust() )
		{
			if ( Physics == PHYS_Falling )
				SetFall();
			else
				GotoState('Following', 'AdjustFromWall');
		}
		else
		{
			MoveTimer = -1.0;
			bWallAdjust = false;
		}
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

		if (Weapon!=None && !bCanUseWeapon)
			TossWeapon();

		if (Weapon!=None)
			bLockedAndLoaded = ( (Weapon.AIRating > 0.4) && (Health > 60) );

		if (  Orders == 'Follow' )
		{
			if ( Pawn(OrderObject) == None )
			{
				log("no order object");
				GoToState('Waiting');
			}
				//SetOrders('FreeLance', None);
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

		if ( ((Orders == 'Follow') && (bNearPoint || (Level.Game.IsA('TO_TeamGamePlus') && TO_TeamGamePlus(Level.Game).WaitForPoint(self))))
			|| ((Orders == 'Defend') && bLockedAndLoaded && LineOfSightTo(OrderObject)) )
		{
		/*	if ( FRand() < 0.35 )
				GotoState('Wandering');
			else
			{*/
				CampTime = 0.3;
				GotoState('Following', 'Camp');
		//	}
			return;
		}

		if ( (OrderObject != None) && !OrderObject.IsA('Ambushpoint') )
			bWantsToCamp = false;
		else if ( Weapon!=None && (Weapon.AIRating > 0.5) && (Health > 90) && !Region.Zone.bWaterZone )
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
					GotoState('Following', 'ShootDecoration');
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
			GotoState('Following', 'Camp');
		}

		// if roamed to ambush point, stay there maybe
		if ( (AmbushPoint(RoamTarget) != None)
			&& (VSize(Location - RoamTarget.Location) < 2 * CollisionRadius)
			&& (FRand() < 0.4) )
		{
			CampTime = 4.0;
			GotoState('Following', 'LongCamp');
			return;
		}

		// hunt player
		if (Weapon!=None)
		{
		if ( (!bNovice || (Level.Game.IsA('TO_DeathMatchPlus') && TO_DeathMatchPlus(Level.Game).OneOnOne()))
			&& (Weapon.AIRating > 0.5) && (Health > 60) )
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
	/*	if ( FRand() < 0.35 )
			GotoState('Wandering');
		else
		{*/
			GoalString = " Nothing cool, so camp ";
			CampTime = 3.5 + FRand() - skill;
			GotoState('Following', 'Camp');
		//}
	}

	function AnimEnd() 
	{
		if ( bCamping )
		{
			SetPeripheralVision();
			if ( FRand() < 0.2 )
			{
				PeripheralVision -= 0.5;
				PlayLookAround();
			}
			else
				PlayWaiting();
		}
		else
			PlayRunning();
	}

	function ShareWith(Pawn Other)
	{
		local bool bHaveItem, bIsHealth, bOtherHas, bIsWeapon;
		local Pawn P;

		if ( MoveTarget.IsA('Weapon') )
		{
			if ( (Weapon == None) || (Weapon.AIRating < 0.5) || Weapon(MoveTarget).bWeaponStay )
				return;
			bIsWeapon = true;
			bHaveItem = (FindInventoryType(MoveTarget.class) != None);
		}
		else if ( MoveTarget.IsA('Health') )
		{
			bIsHealth = true;
			if ( Health < 80 )
				return;
		}

		if ( (Other.Health <= 0) || Other.PlayerReplicationInfo.bIsSpectator || (VSize(Other.Location - Location) > 1250)
			|| !LineOfSightTo(Other) )
			return;

		//decide who needs it more
		CampTime = 2.0;
		if ( bIsHealth )
		{
			if ( Health > Other.Health + 10 )
			{
				GotoState('Following', 'GiveWay');
				return;
			}
		}
		else if ( bIsWeapon && (Other.Weapon != None) && (Other.Weapon.AIRating < 0.5) )
		{
			GotoState('Following', 'GiveWay');
			return;
		}
		else
		{
			bOtherHas = (Other.FindInventoryType(MoveTarget.class) != None);
			if ( bHaveItem && !bOtherHas )
			{
				GotoState('Following', 'GiveWay');
				return;
			}
		}
	}
						 
	function BeginState()
	{
		bNoShootDecor = false;
		bCanFire = false;
		bCamping = false;
		if ( bNoClearSpecial )
			bNoClearSpecial = false;
		else
		{
			bSpecialPausing = false;
			bSpecialGoal = false;
			SpecialGoal = None;
			SpecialPause = 0.0;
		}
	}

	function EndState()
	{
		SetPeripheralVision();
		if ( !bSniping && (AmbushSpot != None) )
		{
			AmbushSpot.taken = false;
			AmbushSpot = None;
		}
		bCamping = false;
		bWallAdjust = false;
		bCanTranslocate = false;
	}

LongCamp:
	bCamping = true;
	Acceleration = vect(0,0,0);
	TweenToWaiting(0.15);
	if (Ambushspot != None)
		TurnTo(Location + Ambushspot.lookdir);
	Sleep(CampTime);
	Goto('PreBegin');

GiveWay:	
	//log("sharing");	
	bCamping = true;
	Acceleration = vect(0,0,0);
	if ( GetAnimGroup(AnimSequence) != 'Waiting' )
		TweenToWaiting(0.15);
	if ( NearWall(200) )
	{
		PlayTurning();
		if (MoveTarget != None)
			TurnTo(MoveTarget.Location);
	}
	Sleep(CampTime);
	Goto('PreBegin');

Camp:
	bCamping = true;
	Acceleration = vect(0,0,0);
	TweenToWaiting(0.15);

ReCamp:
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
	if ( ((Orders != 'Follow') || (OrderObject != None && Pawn(OrderObject).Health > 0 && CloseToPointMan(Pawn(OrderObject)))) 
		&& (Weapon != None) && (Weapon.AIRating > 0.4) && (3 * FRand() > skill + 1) )
		Goto('ReCamp');

PreBegin:
	SetPeripheralVision();
	WaitForLanding();
	bCamping = false;
	PickDestination();
	TweenToRunning(0.1);
	bCanTranslocate = false;
	Goto('SpecialNavig');

Begin:
	SwitchToBestWeapon();
	bCamping = false;
	TweenToRunning(0.1);
	WaitForLanding();
	
RunAway:
	PickDestination();
	bCanTranslocate = false;

SpecialNavig:
	if (SpecialPause > 0.0)
	{
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
		Acceleration = vect(0,0,0);
		Sleep(0.0);
		Goto('RunAway');
	}
	if ( MoveTarget != None && MoveTarget.IsA('InventorySpot') )
	{
		if ( (!Level.Game.IsA('TO_TeamGamePlus') || (TO_TeamGamePlus(Level.Game).PriorityObjective(self) == 0))
			&& (InventorySpot(MoveTarget).markedItem != None)
			&& (InventorySpot(MoveTarget).markedItem.BotDesireability(self) > 0) 
			&& (!MoveTarget.IsA('Weapon')) )
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
	else if ( MoveTarget != None && MoveTarget.IsA('Inventory') && Level.Game.bTeamGame )
	{
		if ( Orders == 'Follow' )
			ShareWith(Pawn(OrderObject));
		else if ( SupportingPlayer != None )
			ShareWith(SupportingPlayer);
	}

	bCamping = false;
	MoveToward(MoveTarget);

	Goto('RunAway');

TakeHit:
	TweenToRunning(0.12);
	Goto('Moving');

Landed:
	if ( MoveTarget == None ) 
		GotoState('Waiting');
	Goto('Moving');

AdjustFromWall:
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
	TurnToward(Target);
	if ( Target != None && Weapon!=None)
	{
		FireWeapon();
		bAltFire = 0;
		bFire = 0;
	}
	Goto('RunAway');
}


//////////////////////////////////////////////////////////////////////////////
// Roaming
//////////////////////////////////////////////////////////////////////////////

state Roaming
{
	ignores EnemyNotVisible;

	function SetOrders(name NewOrders, Pawn OrderGiver, optional bool bNoAck)
	{
		Global.SetOrders(NewOrders, OrderGiver, bNoAck);
		if ( bCamping && ((Orders == 'Hold') || (Orders == 'Follow')) )
			GotoState('Roaming', 'PreBegin');
	}
				
	function ShootTarget(Actor NewTarget)
	{
		if (Weapon!=None)
		{
			Target = NewTarget;
			bFiringPaused = true;
			SpecialPause = 2.0;
			NextState = GetStateName();
			NextLabel = 'Begin';
			GotoState('RangedAttack');
		}
	}

	function HandleHelpMessageFrom(Pawn Other)
	{
		if ( (Health > 70) && Weapon!=None && (Weapon.AIRating > 0.5) && (Other.Enemy != None)
			&& ((Other.bIsPlayer && (Other.PlayerReplicationInfo.Team == PlayerReplicationInfo.Team)))
			//	|| (Other.IsA('StationaryPawn') && StationaryPawn(Other).SameTeamAs(PlayerReplicationInfo.Team)))
			&& (VSize(Other.Enemy.Location - Location) < 800) )
		{
			if ( Other.bIsPlayer )
				SendTeamMessage(Other.PlayerReplicationInfo, 'OTHER', 10, 10);
			SetEnemy(Other.Enemy);
			GotoState('Attacking');
		}
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


		if (Weapon!=None && !bCanUseWeapon)
			TossWeapon();

		bCanTranslocate = false;
		if ( Level.Game.IsA('TO_TeamGamePlus') )
		{
			if ( (Orders == 'FreeLance') && !bStayFreelance
				 &&	(Orders != BotReplicationInfo(PlayerReplicationInfo).RealOrders) ) 
				SetOrders(BotReplicationInfo(PlayerReplicationInfo).RealOrders, BotReplicationInfo(PlayerReplicationInfo).RealOrderGiver, true);
			if ( FRand() < 0.5 )
				bStayFreelance = false;
			LastAttractCheck = Level.TimeSeconds - 0.1;
			if ( TO_TeamGamePlus(Level.Game).FindSpecialAttractionFor(self) )
			{
				if ( IsInState('Roaming') )
				{
					TeamPriority = TeamGamePlus(Level.Game).PriorityObjective(self);
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
		if (Weapon != None)
			bLockedAndLoaded = ( (Weapon.AIRating > 0.4) && (Health > 60) );

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
		else if ( (Weapon != None) && (Weapon.AIRating > 0.5) && (Health > 90) && !Region.Zone.bWaterZone )
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
		if (Weapon != None)
		{
		if ( (!bNovice || (Level.Game.IsA('TO_DeathMatchPlus') && TO_DeathMatchPlus(Level.Game).OneOnOne()))
			&& (Weapon.AIRating > 0.5) && (Health > 60) )
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
			GotoState('Roaming', 'Camp');
		}
	}

	function ShareWith(Pawn Other)
	{
		local bool bHaveItem, bIsHealth, bOtherHas, bIsWeapon;
		local Pawn P;

		if ( MoveTarget.IsA('Weapon') )
		{
			if ( (Weapon == None) || (Weapon.AIRating < 0.5) || Weapon(MoveTarget).bWeaponStay )
				return;
			bIsWeapon = true;
			bHaveItem = (FindInventoryType(MoveTarget.class) != None);
		}
		else if ( MoveTarget.IsA('Health') )
		{
			bIsHealth = true;
			if ( Health < 80 )
				return;
		}

		if ( (Other.Health <= 0) || Other.PlayerReplicationInfo.bIsSpectator || (VSize(Other.Location - Location) > 1250)
			|| !LineOfSightTo(Other) )
			return;

		//decide who needs it more
		CampTime = 2.0;
		if ( bIsHealth )
		{
			if ( Health > Other.Health + 10 )
			{
				GotoState('Roaming', 'GiveWay');
				return;
			}
		}
		else if ( bIsWeapon && (Other.Weapon != None) && (Other.Weapon.AIRating < 0.5) )
		{
			GotoState('Roaming', 'GiveWay');
			return;
		}
		else
		{
			bOtherHas = (Other.FindInventoryType(MoveTarget.class) != None);
			if ( bHaveItem && !bOtherHas )
			{
				GotoState('Roaming', 'GiveWay');
				return;
			}
		}
	}

ReCamp:
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
	SetPeripheralVision();
	WaitForLanding();
	bCamping = false;
	PickDestination();
	TweenToRunning(0.1);
	bCanTranslocate = false;
	Goto('SpecialNavig');
Begin:
	SwitchToBestWeapon();
	bCamping = false;
	TweenToRunning(0.1);
	WaitForLanding();
	
RunAway:
	PickDestination();
	bCanTranslocate = false;
SpecialNavig:
	if (SpecialPause > 0.0)
	{
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
		Acceleration = vect(0,0,0);
		Sleep(0.0);
		Goto('RunAway');
	}
	if ( MoveTarget.IsA('InventorySpot') )
	{
		if ( (!Level.Game.IsA('TO_TeamGamePlus') || (TO_TeamGamePlus(Level.Game).PriorityObjective(self) == 0))
			&& (InventorySpot(MoveTarget).markedItem != None)
			&& (InventorySpot(MoveTarget).markedItem.BotDesireability(self) > 0)
			&& (!MoveTarget.IsA('Weapon')) )
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

	bCamping = false;
	MoveToward(MoveTarget);
	Goto('RunAway');

TakeHit:
	TweenToRunning(0.12);
	Goto('Moving');

Landed:
	if ( MoveTarget == None ) 
		Goto('RunAway');
	Goto('Moving');

AdjustFromWall:
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
	TurnToward(Target);
	if ( Target != None )
	{
		FireWeapon();
		bAltFire = 0;
		bFire = 0;
	}
	Goto('RunAway');
}


//////////////////////////////////////////////////////////////////////////////
// TacticalMove
//////////////////////////////////////////////////////////////////////////////

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
		if ( Weapon!=None && VSize(Enemy.Location - Location) 
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
	
	function GiveUpTactical(bool bNoCharge)
	{	
		if ( !bNoCharge && Weapon!=None && (Weapon.bMeleeWeapon || (2 * CombatStyle + 0.1 * Skill > FRand())) )
			GotoState('Charging');
		else if ( bReadyToAttack && Weapon!=None && !Weapon.bMeleeWeapon && !bNovice )
			GotoState('RangedAttack');
		else
			GotoState('Waiting');
	}		

	function PickDestination(bool bNoCharge)
	{
		local inventory Inv, BestInv, SecondInv;
		local float Bestweight, NewWeight, MaxDist, SecondWeight;

		// possibly pick nearby inventory
		// higher skill bots will always strafe, lower skill
		// both do this less, and strafe less

		if ( !bReadyToAttack && (TimerRate == 0.0) )
			SetTimer(0.7, false);
		if ( bNovice )
		{
			if ( Level.TimeSeconds - LastInvFind < 4 )
			{
				PickRegDestination(bNoCharge);
				return;
			}
		}
		else if ( Level.TimeSeconds - LastInvFind < 3 - 0.5 * skill )
		{
			PickRegDestination(bNoCharge);
			return;
		}

		LastInvFind = Level.TimeSeconds;
		bGathering = false;
		MaxDist = 700 + 70 * skill;
		BestWeight = 0.5/MaxDist;
		foreach visiblecollidingactors(class'Inventory', Inv, MaxDist,,true)
			if ( (Inv.IsInState('PickUp')) && (Inv.MaxDesireability/200 > BestWeight)
				&& (Inv.Location.Z < Location.Z + MaxStepHeight + CollisionHeight)
				&& (Inv.Location.Z > FMin(Location.Z, Enemy.Location.Z) - CollisionHeight) 
				&& (!Inv.IsA('Weapon')) )
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

		if ( BestInv == None )
		{
			PickRegDestination(bNoCharge);
			return;
		}

		if ( TryToward(BestInv, BestWeight) )
			return;

		if ( SecondInv == None )
		{
			PickRegDestination(bNoCharge);
			return;
		}

		if ( TryToward(SecondInv, SecondWeight) )
			return;

		PickRegDestination(bNoCharge);
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
		
		if( Weapon!=None && Weapon.bMeleeWeapon && !bNoCharge )
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
			if ( bJumpy || ( Weapon!=None && Weapon.bRecommendSplashDamage && !bNovice 
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

TacticalTick:
	Sleep(0.02);	
Begin:
	TweenToRunning(0.15);
	Enable('AnimEnd');
	if (Physics == PHYS_Falling && Enemy!=None)
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
	if (Physics == PHYS_Falling && Enemy!=None)
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

	if ( Weapon!=None && !Weapon.bMeleeWeapon && LineOfSightTo(Enemy) && CanFireAtEnemy() )
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
	if (Weapon!=None)
		GotoState('Attacking');
	else 
		GotoState('Waiting');
}


//////////////////////////////////////////////////////////////////////////////
// Attacking 
//////////////////////////////////////////////////////////////////////////////

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

		if (Weapon!=None && !bCanUseWeapon)
		{
			TossWeapon();
			WhatToDoNext('','');
		}

		bWillHunt = bMustHunt;
		bMustHunt = false;
		if ((Enemy == None) || (Enemy.Health <= 0))
		{
			WhatToDoNext('','');
			return;
		}
		if ( Weapon == None )
		{
			//log(self$" health "$health$" had no weapon");
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
		if (Weapon==None)
			GoToState('Waiting');

		if ( TimerRate <= 0.0 )
			SetTimer(TimeBetweenAttacks  * (1.0 + FRand()),false); 
		if (Physics == PHYS_None)
			SetMovementPhysics(); 
	}

Begin:
	//log(class$" choose Attack");
	ChooseAttackMode();
}


//////////////////////////////////////////////////////////////////////////////
// Retreating 
//////////////////////////////////////////////////////////////////////////////

state Retreating
{
ignores EnemyNotVisible;

	function PickDestination()
	{
	 	local inventory Inv, BestInv, SecondInv;
		local float Bestweight, NewWeight, invDist, MaxDist, SecondWeight;
		local actor BestPath;
		local bool bTriedFar;

		if ( !bReadyToAttack && (TimerRate == 0.0) )
			SetTimer(0.7, false);

		// do I still fear my enemy?
		if ( (Level.TimeSeconds - LastSeenTime > 12)
			|| (Level.Game.bTeamGame && (Level.TimeSeconds - LastSeenTime > 20)) )
			Enemy = None;
		if ( (Enemy == None) || (AttitudeTo(Enemy) > ATTITUDE_Fear) )
		{
			GotoState('Attacking');
			return;
		}

		bestweight = 0;

		//first look at nearby inventory < 500 dist
		MaxDist = 500 + 70 * skill;
		foreach visiblecollidingactors(class'Inventory', Inv, MaxDist,,true)
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
			 
		 // see if better long distance inventory 
		if ( BestWeight < 0.001 )
		{ 
			bTriedFar = true;
			BestPath = FindBestInventoryPath(BestWeight, false);
			if ( Level.Game.bTeamGame && (BestWeight < 0.0002) )
			{
				if ( !Enemy.IsA('TeamCannon') && (Enemy.Location.Z < Location.Z + 500) )
				{
					bKamikaze = true;
					if ( LineOfSightTo(Enemy) )
					{
						LastInvFind = Level.TimeSeconds;
						GotoState('TacticalMove', 'NoCharge');
						return;
					}
				}
				else if ( Level.Game.IsA('TO_TeamGamePlus') && TO_TeamGamePlus(Level.Game).SendBotToGoal(self) )
					return;
			}
			if ( BestPath != None )
			{
				//GoalString = string(1000 * BestWeight);
				MoveTarget = BestPath;
				return;
			}
		}

		if ( (BestInv != None) && ActorReachable(BestInv) )
		{
			MoveTarget = BestInv;
			return;
		}

		if ( (SecondInv != None) && ActorReachable(SecondInv) )
		{
			MoveTarget = SecondInv;
			return;
		}
		if ( !bTriedFar )
		{ 
			BestWeight = 0;
			BestPath = FindBestInventoryPath(BestWeight, false);
			if ( BestPath != None )
			{
				MoveTarget = BestPath;
				return;
			}
		}
		if ( bVerbose )
			log(self$" give up retreat");

		// if nothing, then tactical move
		if ( LineOfSightTo(Enemy) )
		{
			LastInvFind = Level.TimeSeconds;
			bKamikaze = true;
			GotoState('TacticalMove', 'NoCharge');
			return;
		}
		WhatToDoNext('','');
	}

	function BeginState()
	{
		//if ( Level.Game.bTeamGame && !Enemy.IsA('StationaryPawn') )
		//	CallForHelp();
		bSpecialPausing = false;
		bCanFire = false;
		SpecialGoal = None;
		SpecialPause = 0.0;
	}

Begin:
	if ( bReadyToAttack && (FRand() < 0.4 - 0.1 * Skill) )
		bReadyToAttack = false;
	if ( (TimerRate == 0.0) || !bReadyToAttack )
		SetTimer(TimeBetweenAttacks, false);

	TweenToRunning(0.1);
	WaitForLanding();
	
RunAway:
	PickDestination();
	bAdvancedTactics = ( !bNovice && (Level.TimeSeconds - LastSeenTime < 1.0) 
						&& (Skill > 2.5 * FRand() - 1)
						&& (!MoveTarget.IsA('NavigationPoint') || !NavigationPoint(MoveTarget).bNeverUseStrafing) );
SpecialNavig:
	if (SpecialPause > 0.0)
	{
		if ( LineOfSightTo(Enemy) && Weapon!=None)
		{
			if ( ((Base == None) || (Base == Level))
				&& (FRand() < 0.6) )
				GotoState('TacticalMove', 'NoCharge');
			Target = Enemy;
			bFiringPaused = true;
			NextState = 'Retreating';
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
	if ( MoveTarget.IsA('InventorySpot') && (InventorySpot(MoveTarget).markedItem != None) 
		&& (InventorySpot(MoveTarget).markedItem.GetStateName() == 'Pickup')
		&& (InventorySpot(MoveTarget).markedItem.BotDesireability(self) > 0) )
			MoveTarget = InventorySpot(MoveTarget).markedItem;
	if ( FaceDestination(2) )
	{
		HaltFiring();
		MoveToward(MoveTarget);
	}
	else
	{
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


//////////////////////////////////////////////////////////////////////////////
// RangedAttack 
//////////////////////////////////////////////////////////////////////////////

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
		if (Weapon==None)
			GoToState('Waiting');
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
	if ( Weapon!=None && Weapon.bMeleeWeapon )
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


//////////////////////////////////////////////////////////////////////////////
// Dying 
//////////////////////////////////////////////////////////////////////////////

state Dying
{
ignores SeePlayer, EnemyNotVisible, HearNoise, Died, Bump, Trigger, HitWall, HeadZoneChange, FootZoneChange, ZoneChange, Falling, WarnTarget, LongFall, SetFall, PainTimer;

	function ReStartPlayer()
	{
		if( bHidden && Level.Game.RestartPlayer(self) )
		{
			if ( bNovice )
				bDumbDown = ( FRand() < 0.5 );
			else
				bDumbDown = ( FRand() < 0.35 );
			Velocity = vect(0,0,0);
			Acceleration = vect(0,0,0);
			ViewRotation = Rotation;
			ReSetSkill();
			SetPhysics(PHYS_Falling);
			SetOrders(BotReplicationInfo(PlayerReplicationInfo).RealOrders, BotReplicationInfo(PlayerReplicationInfo).RealOrderGiver, true);
			GotoState('Roaming');
		}
		else if ( !IsInState('GameEnded') )
			GotoState('Dying', 'TryAgain');
	}
	
	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
							Vector momentum, name damageType)
	{
		if ( !bHidden )
			Super.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
	}
	
	function BeginState()
	{
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


//////////////////////////////////////////////////////////////////////////////
// StakeOut 
//////////////////////////////////////////////////////////////////////////////

state StakeOut
{
ignores EnemyNotVisible; 

	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
							Vector momentum, name damageType)
	{
		Global.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
		if ( health <= 0 )
			return;
		bFrustrated = true;
		LastSeenPos = Enemy.Location;
		if (NextState == 'TakeHit')
		{
			if (AttitudeTo(Enemy) == ATTITUDE_Fear)
			{
				NextState = 'Retreating';
				NextLabel = 'Begin';
			}
			else
			{
				NextState = 'Attacking';
				NextLabel = 'Begin';
			}
			GotoState('TakeHit'); 
		}
		else
			GotoState('Attacking');
	}

	singular function HearNoise(float Loudness, Actor NoiseMaker)
	{
		if ( SetEnemy(NoiseMaker.instigator) )
			LastSeenPos = Enemy.Location; 
	}

	function SetFall()
	{ /*
		NextState = 'StakeOut'; 
		NextLabel = 'Begin';
		NextAnim = AnimSequence;
		GotoState('FallingState');  */
		if (Enemy != None)
		{
			NextState = '';
			NextLabel = '';
			TweenToFalling();
			NextAnim = AnimSequence;
			GotoState('FallingState');
		}
	}

	function bool SetEnemy(Pawn NewEnemy)
	{
		if (Global.SetEnemy(NewEnemy))
		{
			bReadyToAttack = true;
			DesiredRotation = Rotator(Enemy.Location - Location);
			GotoState('Attacking');
			return true;
		}
		return false;
	} 
	
	function Timer()
	{
		bReadyToAttack = true;
		Enable('Bump');
		SetTimer(1.0, false);
	}

	function rotator AdjustAim(float projSpeed, vector projStart, int aimerror, bool leadTarget, bool warnTarget)
	{
		local vector FireSpot, X,Y,Z;
		local actor HitActor;
		local vector HitLocation, HitNormal;
				
		FireSpot = LastSeenPos;
			 
		HitActor = Trace(HitLocation, HitNormal, FireSpot, ProjStart, false);
		if( HitActor != None ) 
		{
			FireSpot += 2 * Enemy.CollisionHeight * HitNormal;
			bClearShot = FastTrace(FireSpot, ProjStart);
			if ( !bClearShot )
			{
				FireSpot = LastSeenPos;
				bFire = 0;
				bAltFire = 0;
			}
		}
		
		ViewRotation = Rotator(FireSpot - ProjStart);
		return ViewRotation;
	}
	
	function bool ClearShot()
	{
		if (Weapon==None)
			return false;

		if ( Weapon.bSplashDamage && (VSize(Location - LastSeenPos) < 300) )
			return false;

		if ( !FastTrace(LastSeenPos + vect(0,0,0.9) * Enemy.CollisionHeight, Location) )
		{
			bFire = 0;
			bAltFire = 0;
			return false;
		}
		return true;
	}
	
	function FindNewStakeOutDir()
	{
		local NavigationPoint N, Best;
		local vector Dir, EnemyDir;
		local float Dist, BestVal, Val;

		EnemyDir = Normal(Enemy.Location - Location);
		for ( N=Level.NavigationPointList; N!=None; N=N.NextNavigationPoint )
		{
			Dir = N.Location - Location;
			Dist = VSize(Dir);
			if ( (Dist < 800) && (Dist > 100) )
			{
				Val = (EnemyDir Dot Dir/Dist);
				if ( Level.Game.bTeamgame )
					Val += FRand();
				if ( (Val > BestVal) && LineOfSightTo(N) )
				{
					BestVal = Val;
					Best = N;
				}
			}
		}

		if ( Best != None )
			LastSeenPos = Best.Location + 0.5 * CollisionHeight * vect(0,0,1);			
	}
		
	function bool ContinueStakeOut()
	{
		local float relstr;

		relstr = RelativeStrength(Enemy);
		if ( (VSize(Enemy.Location - Location) > 300 + (FRand() * relstr - CombatStyle) * 350)
			 || (Level.TimeSeconds - LastSeenTime > 2.5 + FMax(-1, 3 * (FRand() + 2 * (relstr - CombatStyle))) ) || !ClearShot() )
			return false;
		else if ( CanStakeOut() )
			return true;
		else
			return false;
	}

	function BeginState()
	{

		Acceleration = vect(0,0,0);
		bClearShot = ClearShot();
		bCanJump = false;
		bReadyToAttack = true;
		SetAlertness(0.5);
		RealLastSeenPos = LastSeenPos;
		if ( !bClearShot || ((Level.TimeSeconds - LastSeenTime > 6) && (FRand() < 0.5)) )
			FindNewStakeOutDir();
	}

	function EndState()
	{
		LastSeenPos = RealLastSeenPos;
		if ( JumpZ > 0 )
			bCanJump = true;
	}

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



state ImpactJumping
{
	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
							Vector momentum, name damageType)
	{
		local name RealState, RealLabel;

		RealState = NextState;
		RealLabel = NextLabel;
		Global.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
		if ( health <= 0 )
			return;
		if ( (Enemy != None) && (Enemy == InstigatedBy) )
		{
			LastSeenPos = Enemy.Location;
			LastSeenTime = Level.TimeSeconds;
		}
		NextState = RealState;
		NextLabel = RealLabel;
		MoveTarget = None;
		bJumpOffPawn = true;
		bImpactJumping = true;
		GotoState('fallingstate');
	}

	function vector ImpactLook()
	{
		local vector result;
		
		result = 1000 * Normal(ImpactTarget.Location - Location);
		result.Z = Location.Z - 400;
		return Result;
	}
	
	function AnimEnd()
	{
		bFire = 1;
		PlayWaiting();
		bFire = 0;
	}
				
	function ChangeToHammer()
	{
		local Inventory MyHammer;

		MyHammer = FindInventoryType(class'ImpactHammer');
		if ( MyHammer == None )
		{
			GotoState('NextState', 'NextLabel');
			return;
		}
		PendingWeapon = Weapon(MyHammer);
		PendingWeapon.AmbientSound = ImpactHammer(MyHammer).TensionSound;
		PendingWeapon.SetLocation(Location);
		if ( Weapon == None )
			ChangedWeapon();
		else if ( Weapon != PendingWeapon )
			Weapon.PutDown();
	}

	function EndState()
	{
		local Inventory MyHammer;
		MyHammer = FindInventoryType(class'ImpactHammer');
		if ( MyHammer != None )
			MyHammer.AmbientSound = None;
	}


Begin:
	Acceleration = vect(0,0,0);
	if ( !Weapon.IsA('ImpactHammer') )
		ChangeToHammer();
	else
	{
		Weapon.SetLocation(Location);
		Weapon.AmbientSound = ImpactHammer(Weapon).TensionSound;
	}
	TweenToWaiting(0.2);
	TurnTo(ImpactLook());
	CampTime = Level.TimeSeconds;
	While ( !Weapon.IsA('ImpactHammer') && (Level.TimeSeconds - Camptime < 2.0) )
		Sleep(0.1);
	CampTime = 1.0;
	Sleep(0.5);
	MakeNoise(1.0);	
	if ( Physics != PHYS_Falling )
	{
		Velocity = ImpactTarget.Location - Location;
		Velocity.Z = 320;
		Velocity = Default.GroundSpeed * Normal(Velocity);
		TakeDamage(36.0, self, Location, 69000.0 * 1.5 * vect(0,0,1), Weapon.MyDamageType);
	}
	GotoState(NextState, NextLabel);
}


//////////////////////////////////////////////////////////////////////////////
// Escape
//////////////////////////////////////////////////////////////////////////////

state Escape
{
	ignores EnemyNotVisible;

	function SetOrders(name NewOrders, Pawn OrderGiver, optional bool bNoAck)
	{
		Global.SetOrders(NewOrders, OrderGiver, bNoAck);
		if ( bCamping && ((Orders == 'Hold') || (Orders == 'Follow')) )
			GotoState('Following', 'PreBegin');
	}

	function HearPickup(Pawn Other)
	{
		if ( bNovice || (Skill < 4 * FRand() - 1) )
			return;
		if ( (Health > 70) && Weapon!=None && (Weapon.AiRating > 0.6) 
			&& (RelativeStrength(Other) < 0) )
			HearNoise(0.5, Other);
	}
				
	function ShootTarget(Actor NewTarget)
	{
		if (Weapon!=None)
		{
			Target = NewTarget;
			bFiringPaused = true;
			SpecialPause = 2.0;
			NextState = GetStateName();
			NextLabel = 'Begin';
			GotoState('RangedAttack');
		}
	}

	function MayFall()
	{
		//bCanJump = false;
		bCanJump = ( (MoveTarget != None) 
					&& ((MoveTarget.Physics != PHYS_Falling) || !MoveTarget.IsA('Inventory')) );
	}
	
	function HandleHelpMessageFrom(Pawn Other){}

	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
							Vector momentum, name damageType)
	{
		Global.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
		if ( health <= 0 )
			return;
		if (NextState == 'TakeHit' && Weapon!=None)
		{
			NextState = 'Attacking'; 
			NextLabel = '';
			GotoState('TakeHit'); 
		}
		else if ( Weapon!=None && !bCanFire && (skill > 3 * FRand()) )
			GotoState('Attacking');
	}

	function FearThisSpot(Actor aSpot)
	{
		Destination = Location + 120 * Normal(Location - aSpot.Location); 
		GotoState('Wandering', 'Moving');
	}
	
	function Timer()
	{
		bReadyToAttack = True;
		Enable('Bump');
	}

	function SetFall()
	{ /*
		bWallAdjust = false;
		NextState = 'Escape'; 
		NextLabel = 'Landed';
		NextAnim = AnimSequence;
		GotoState('FallingState'); 
		*/
		if (Enemy != None)
		{	
			NextState = '';
			NextLabel = '';
			TweenToFalling();
			NextAnim = AnimSequence;
			GotoState('FallingState');
		}
	}

	function EnemyAcquired()
	{
		if (Weapon!=None)
			GotoState('Acquisition');
	}

	function HitWall(vector HitNormal, actor Wall)
	{
		if (Physics == PHYS_Falling)
			return;
		if ( Wall.IsA('Mover') && Mover(Wall).HandleDoor(self) )
		{
			if ( SpecialPause > 0 )
				Acceleration = vect(0,0,0);
			GotoState('Following', 'SpecialNavig');
			return;
		}
		Focus = Destination;
		if ( !bWallAdjust && PickWallAdjust() )
		{
			if ( Physics == PHYS_Falling )
				SetFall();
			else
				GotoState('Following', 'AdjustFromWall');
		}
		else
		{
			MoveTimer = -1.0;
			bWallAdjust = false;
		}
	}

	function PickDestination()
	{
		local NavigationPoint	BestPath, Path;
		local float						BestScore, Score;

		// Find the path that takes this pawn away from it's enemy the fastest.
		if (Enemy == None)
		{
			log("NPC has enemy == None");
			return;
		}

		BestScore = -1.0;

		for(Path = Level.NavigationPointList; Path != None; Path = Path.NextNavigationPoint)
		{
			if(VSize(Path.Location) < 64.0 || !ActorReachable(Path))
				continue;

			Score = Normal(Path.Location - Location) Dot Normal(Location - Enemy.Location);

			if(Enemy != None && !Enemy.LineOfSightTo(Path))
				Score += 1.0;

			if(Score >= BestScore || BestPath == None)
			{
				BestPath = Path;
				BestScore = Score;
			}
		}

		MoveTarget = BestPath;
	}

	function AnimEnd() 
	{
		if ( bCamping )
		{
			SetPeripheralVision();
			if ( FRand() < 0.2 )
			{
				PeripheralVision -= 0.5;
				PlayLookAround();
			}
			else
				PlayWaiting();
		}
		else
			PlayRunning();
	}

	function ShareWith(Pawn Other)
	{
		local bool bHaveItem, bIsHealth, bOtherHas, bIsWeapon;
		local Pawn P;

		if ( MoveTarget.IsA('Weapon') )
		{
			if ( (Weapon == None) || (Weapon.AIRating < 0.5) || Weapon(MoveTarget).bWeaponStay )
				return;
			bIsWeapon = true;
			bHaveItem = (FindInventoryType(MoveTarget.class) != None);
		}
		else if ( MoveTarget.IsA('Health') )
		{
			bIsHealth = true;
			if ( Health < 80 )
				return;
		}

		if ( (Other.Health <= 0) || Other.PlayerReplicationInfo.bIsSpectator || (VSize(Other.Location - Location) > 1250)
			|| !LineOfSightTo(Other) )
			return;

		//decide who needs it more
		CampTime = 2.0;
		if ( bIsHealth )
		{
			if ( Health > Other.Health + 10 )
			{
				GotoState('Following', 'GiveWay');
				return;
			}
		}
		else if ( bIsWeapon && (Other.Weapon != None) && (Other.Weapon.AIRating < 0.5) )
		{
			GotoState('Following', 'GiveWay');
			return;
		}
		else
		{
			bOtherHas = (Other.FindInventoryType(MoveTarget.class) != None);
			if ( bHaveItem && !bOtherHas )
			{
				GotoState('Following', 'GiveWay');
				return;
			}
		}
	}
						 
	function BeginState()
	{
		bNoShootDecor = false;
		bCanFire = false;
		bCamping = false;
		if ( bNoClearSpecial )
			bNoClearSpecial = false;
		else
		{
			bSpecialPausing = false;
			bSpecialGoal = false;
			SpecialGoal = None;
			SpecialPause = 0.0;
		}
	}

	function EndState()
	{
		SetPeripheralVision();
		if ( !bSniping && (AmbushSpot != None) )
		{
			AmbushSpot.taken = false;
			AmbushSpot = None;
		}
		bCamping = false;
		bWallAdjust = false;
		bCanTranslocate = false;
	}

LongCamp:
	Goto('PreBegin');

GiveWay:	
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
	bCamping = true;
	Acceleration = vect(0,0,0);
	TweenToWaiting(0.15);
ReCamp:
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
	SetPeripheralVision();
	WaitForLanding();
	bCamping = false;
	PickDestination();
	TweenToRunning(0.1);
	bCanTranslocate = false;
	Goto('SpecialNavig');
Begin:
	SwitchToBestWeapon();
	bCamping = false;
	TweenToRunning(0.1);
	WaitForLanding();
	
RunAway:
	PickDestination();
	bCanTranslocate = false;
SpecialNavig:
	if (SpecialPause > 0.0)
	{
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
		Acceleration = vect(0,0,0);
		Sleep(0.0);
		Goto('RunAway');
	}
	if ( MoveTarget.IsA('InventorySpot') )
	{
		if ( (!Level.Game.IsA('TO_TeamGamePlus') || (TO_TeamGamePlus(Level.Game).PriorityObjective(self) == 0))
			&& (InventorySpot(MoveTarget).markedItem != None)
			&& (InventorySpot(MoveTarget).markedItem.BotDesireability(self) > 0) 
			&& (!MoveTarget.IsA('Weapon')) )
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

	bCamping = false;
	MoveToward(MoveTarget);

	Goto('RunAway');

TakeHit:
	TweenToRunning(0.12);
	Goto('Moving');

Landed:
	if ( MoveTarget == None ) 
		GotoState('Waiting');
	Goto('Moving');

AdjustFromWall:
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
	TurnToward(Target);
	if ( Target != None && Weapon!=None)
	{
		FireWeapon();
		bAltFire = 0;
		bFire = 0;
	}
	Goto('RunAway');
}

//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
//s_Wandering
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

state s_Wandering
{
	ignores EnemyNotVisible;

	function SetOrders(name NewOrders, Pawn OrderGiver, optional bool bNoAck)
	{
		Global.SetOrders(NewOrders, OrderGiver, bNoAck);
		if ( bCamping && ((Orders == 'Hold') || (Orders == 'Follow')) )
			GotoState('Following', 'PreBegin');
	}

	function HearPickup(Pawn Other)
	{
		if ( bNovice || (Skill < 4 * FRand() - 1) )
			return;
		if ( (Health > 70) && Weapon!=None && (Weapon.AiRating > 0.6) 
			&& (RelativeStrength(Other) < 0) )
			HearNoise(0.5, Other);
	}
				
	function ShootTarget(Actor NewTarget)
	{
		if (Weapon!=None)
		{
			Target = NewTarget;
			bFiringPaused = true;
			SpecialPause = 2.0;
			NextState = GetStateName();
			NextLabel = 'Begin';
			GotoState('RangedAttack');
		}
	}

	function MayFall()
	{
		//bCanJump = false;
		bCanJump = ( (MoveTarget != None) 
					&& ((MoveTarget.Physics != PHYS_Falling) || !MoveTarget.IsA('Inventory')) );
	}
	
	function HandleHelpMessageFrom(Pawn Other){}

	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
							Vector momentum, name damageType)
	{
		Global.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
		if ( health <= 0 )
			return;
		if (NextState == 'TakeHit' && Weapon!=None)
		{
			NextState = 'Attacking'; 
			NextLabel = '';
			GotoState('TakeHit'); 
		}
		else if ( Weapon!=None && !bCanFire && (skill > 3 * FRand()) )
			GotoState('Attacking');
	}

	function FearThisSpot(Actor aSpot)
	{
		Destination = Location + 120 * Normal(Location - aSpot.Location); 
		GotoState('Wandering', 'Moving');
	}
	
	function Timer()
	{
		bReadyToAttack = True;
		Enable('Bump');
	}

	function SetFall()
	{ /*
		bWallAdjust = false;
		NextState = 's_Wandering'; 
		NextLabel = 'Landed';
		NextAnim = AnimSequence;
		GotoState('FallingState'); */
		if (Enemy != None)
		{
			NextState = '';
			NextLabel = '';
			TweenToFalling();
			NextAnim = AnimSequence;
			GotoState('FallingState');
		}
	}

	function EnemyAcquired()
	{
		if (Weapon!=None)
			GotoState('Acquisition');
	}

	function HitWall(vector HitNormal, actor Wall)
	{
		if (Physics == PHYS_Falling)
			return;
		if ( Wall.IsA('Mover') && Mover(Wall).HandleDoor(self) )
		{
			if ( SpecialPause > 0 )
				Acceleration = vect(0,0,0);
			GotoState('Following', 'SpecialNavig');
			return;
		}
		Focus = Destination;
		if ( !bWallAdjust && PickWallAdjust() )
		{
			if ( Physics == PHYS_Falling )
				SetFall();
			else
				GotoState('Following', 'AdjustFromWall');
		}
		else
		{
			MoveTimer = -1.0;
			bWallAdjust = false;
		}
	}

	function PickDestination()
	{
		local NavigationPoint	BestPath,
								Path;
		local float				BestScore,
								Score, Size;

		// Find the path that takes this pawn away from it's enemy the fastest.

		BestScore = -1.0;

		for(Path = Level.NavigationPointList;Path != None;Path = Path.NextNavigationPoint)
		{
			Size=VSize(Path.Location - Location);

			if(Size < 64.0 || !ActorReachable(Path))
				continue;
			if (Size < 2000.0)
				Score = Rand(1000);
			else
				Score = 0;
			if (Size > 350)
				Score+=200;

			if(Score >= BestScore || BestPath == None)
			{
				BestPath = Path;
				BestScore = Score;
			}
		}

	MoveTarget=BestPath;
	
	}

	function AnimEnd() 
	{
		if ( bCamping )
		{
			SetPeripheralVision();
			if ( FRand() < 0.2 )
			{
				PeripheralVision -= 0.5;
				PlayLookAround();
			}
			else
				PlayWaiting();
		}
		else
			PlayRunning();
	}

	function ShareWith(Pawn Other)
	{
		local bool bHaveItem, bIsHealth, bOtherHas, bIsWeapon;
		local Pawn P;

		if ( MoveTarget.IsA('Weapon') )
		{
			if ( (Weapon == None) || (Weapon.AIRating < 0.5) || Weapon(MoveTarget).bWeaponStay )
				return;
			bIsWeapon = true;
			bHaveItem = (FindInventoryType(MoveTarget.class) != None);
		}
		else if ( MoveTarget.IsA('Health') )
		{
			bIsHealth = true;
			if ( Health < 80 )
				return;
		}

		if ( (Other.Health <= 0) || Other.PlayerReplicationInfo.bIsSpectator || (VSize(Other.Location - Location) > 1250)
			|| !LineOfSightTo(Other) )
			return;

		//decide who needs it more
		CampTime = 2.0;
		if ( bIsHealth )
		{
			if ( Health > Other.Health + 10 )
			{
				GotoState('Following', 'GiveWay');
				return;
			}
		}
		else if ( bIsWeapon && (Other.Weapon != None) && (Other.Weapon.AIRating < 0.5) )
		{
			GotoState('Following', 'GiveWay');
			return;
		}
		else
		{
			bOtherHas = (Other.FindInventoryType(MoveTarget.class) != None);
			if ( bHaveItem && !bOtherHas )
			{
				GotoState('Following', 'GiveWay');
				return;
			}
		}
	}
						 
	function BeginState()
	{
		bNoShootDecor = false;
		bCanFire = false;
		bCamping = false;
		if ( bNoClearSpecial )
			bNoClearSpecial = false;
		else
		{
			bSpecialPausing = false;
			bSpecialGoal = false;
			SpecialGoal = None;
			SpecialPause = 0.0;
		}
	}

	function EndState()
	{
		SetPeripheralVision();
		if ( !bSniping && (AmbushSpot != None) )
		{
			AmbushSpot.taken = false;
			AmbushSpot = None;
		}
		bCamping = false;
		bWallAdjust = false;
		bCanTranslocate = false;
	}

LongCamp:
	Goto('PreBegin');

GiveWay:	
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
	bCamping = true;
	Acceleration = vect(0,0,0);
	TweenToWaiting(0.15);
ReCamp:
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
	SetPeripheralVision();
	WaitForLanding();
	bCamping = false;
	PickDestination();
	TweenToRunning(0.1);
	bCanTranslocate = false;
	Goto('SpecialNavig');
Begin:
	SwitchToBestWeapon();
	bCamping = false;
	TweenToRunning(0.1);
	WaitForLanding();
	
RunAway:
	PickDestination();
	bCanTranslocate = false;
SpecialNavig:
	if (SpecialPause > 0.0)
	{
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
		Acceleration = vect(0,0,0);
		Sleep(0.0);
		Goto('RunAway');
	}
	if ( MoveTarget.IsA('InventorySpot') )
	{
		if ( (!Level.Game.IsA('TO_TeamGamePlus') || (TO_TeamGamePlus(Level.Game).PriorityObjective(self) == 0))
			&& (InventorySpot(MoveTarget).markedItem != None)
			&& (InventorySpot(MoveTarget).markedItem.BotDesireability(self) > 0) 
			&& (!MoveTarget.IsA('Weapon')) )
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

	bCamping = false;
	MoveToward(MoveTarget);

	Goto('RunAway');

TakeHit:
	TweenToRunning(0.12);
	Goto('Moving');

Landed:
	if ( MoveTarget == None ) 
		GotoState('Waiting');
	Goto('Moving');

AdjustFromWall:
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
	TurnToward(Target);
	if ( Target != None && Weapon!=None)
	{
		FireWeapon();
		bAltFire = 0;
		bFire = 0;
	}
	Goto('RunAway');
}

/*
///////////////////////////////////////
// TakeFallingDamage
///////////////////////////////////////

function TakeFallingDamage()
{
	local float damage;

	if (Velocity.Z < -600)
	{
		MakeNoise(-0.5 * Velocity.Z/(FMax(JumpZ, 150.0)));
		if (Role == ROLE_Authority)
		{
			damage = (Velocity.Z + 600) * 0.20;
			//log("TakeFallingDamage - damage: "$damage$" - Velocity: "$Velocity.Z);

			if (damage < 0)
				damage = -damage;

			if (Damage > 1000)
				Damage = 1000;
			
			TakeDamage(damage, None, Location, -velocity, 'Fell');

			ShakeView(0.175 - 0.00007 * Velocity.Z, -0.85 * Velocity.Z, -0.002 * Velocity.Z);
		}
	}
	else if ( Velocity.Z > 0.5 * Default.JumpZ )
		MakeNoise(0.35);				
}
*/


///////////////////////////////////////
// MoveAway
///////////////////////////////////////

function MoveAway(Actor Other)
{
	if ( (Other.IsA('s_Player') && s_Player(Other).bNotPlaying)
		 || (Other.IsA('s_Bot') && s_Bot(Other).bNotPlaying) )
	{
		NextState = GetStateName();
		NextLabel = '';
		MoveAwayFrom = Other.Location;
		GotoState('smoveawayfrom');
	}
}


///////////////////////////////////////
// moveaway
///////////////////////////////////////

state smoveawayfrom
{
	ignores Bump;

Begin:
	PlayWalking();

  MoveAwayFrom.x += (FRand() - 0.5) * 48;     
  MoveAwayFrom.y += (FRand() - 0.5) * 48;    
 
  MoveTo(MoveAwayFrom);
  TurnTo(MoveAwayFrom);

	GotoState('following');
}

/*
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

	if (FootSound == Sound'TODatas.footsteps.FM_metalstep1' || 
		FootSound == Sound'TODatas.footsteps.FM_metalstep2')
		return FM_metalstep;

	if (FootSound == Sound'TODatas.footsteps.FM_snowstep1' || 
		FootSound == Sound'TODatas.footsteps.FM_snowstep2')
		return FM_snowstep;

	if (FootSound == Sound'TODatas.footsteps.FM_stonestep1' || 
		FootSound == Sound'TODatas.footsteps.FM_stonestep2')
		return FM_stonestep;

	if (FootSound == Sound'TODatas.footsteps.FM_woodstep1' || 
		FootSound == Sound'TODatas.footsteps.FM_woodstep2')
		return FM_woodstep;

	if (FootSound == Sound'TODatas.footsteps.FM_woodwarmstep1' || 
		FootSound == Sound'TODatas.footsteps.FM_woodwarmstep2')
		return FM_woodwarmstep;

	if (FootSound == Sound'TODatas.footsteps.FM_grass1' || 
		FootSound == Sound'TODatas.footsteps.FM_grass2' || 
		FootSound == Sound'TODatas.footsteps.FM_grass3')
		return FM_woodwarmstep;

	if (FootSound == Sound'TODatas.footsteps.FM_smallgravel1' || 
		FootSound == Sound'TODatas.footsteps.FM_smallgravel2' || 
		FootSound == Sound'TODatas.footsteps.FM_smallgravel3')
		return FM_woodwarmstep;

	return FM_Stone;
}


///////////////////////////////////////
// PlayFootStep
///////////////////////////////////////

simulated function PlayFootStep()
{
	local sound						step;
	local float						decision;
	local	EFloorMaterial	FM;
 
	if ( FootRegion.Zone.bWaterZone )
	{
		PlaySound(WaterStep, SLOT_Interact, 1, false, 1000.0, 1.0);
		return;
	}

	FM = GetFloorMaterial();
	decision = FRand();

	switch (FM)
	{
		case FM_metalstep :
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
			if ( decision < 0.33 )
				step = Sound'FM_grass1';
			else if ( decision < 0.66 )
				step = Sound'FM_grass2';
			else 
				step = Sound'FM_grass3';
			break;

		case FM_smallgravel :
			if ( decision < 0.33 )
				step = Sound'FM_smallgravel1';
			else if ( decision < 0.66 )
				step = Sound'FM_smallgravel2';
			else 
				step = Sound'FM_smallgravel3';
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

	if (bIsCrouching)
		PlaySound(step, SLOT_Interact, 0.2, false, 250.0, 1.0);
	else
		PlaySound(step, SLOT_Interact, 1.0, false, 1000.0, 1.0);
}
*/

///////////////////////////////////////
// CalculateWeight
///////////////////////////////////////

simulated function CalculateWeight()
{
	local	float			Weight;

	if (Weapon != None && Weapon.IsA('s_Weapon'))
		Weight += s_Weapon(Weapon).WeaponWeight;

	if (Weight > 180)
		Weight = 180;

	GroundSpeed = 260 - Weight;
	AirSpeed = 300 + Weight;
  AccelRate = 2048.000000 + Weight;
  AirControl = 0.300000 - Weight / 1000;
	JumpZ = 350 - Weight / 2;

}


/*
function s_PlayDynamicSound(string aSoundName)
{
	local Sound aSound;

	aSound = Sound(DynamicLoadObject(aSoundName, class'Sound'));
	if (aSound!=None)
	{
		PlaySound(aSound, SLOT_Interface, 16.0);
		PlaySound(aSound, SLOT_Misc, 16.0, false);
	}
}
*/
function SetVoice()
{
	local float f;

	if (f<0.33)
		s_Voice="TOHostage1.Talk.";
	else if (f<0.66)
		s_Voice="TOHostage2.Talk.";
	else
		s_Voice="TOHostage3.Talk.";

}



///////////////////////////////////////
// defaultproperties
///////////////////////////////////////

defaultproperties
{
     bCanUseWeapon=True
     NPCWAff=1.000000
     s_Voice="TOHostage1.Talk."
     bCanStrafe=False
     GroundSpeed=350.000000
     JumpZ=350.000000
}
