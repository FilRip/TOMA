//=============================================================================
// s_Bot
//=============================================================================
//
// Tactical Ops
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen and Benoit "JAH" Delayen
//=============================================================================
 
class s_bot extends s_botbase
	abstract;

var		s_PRI			TOPRI;					// Tactical Ops PlayerReplicationInfo
var		TO_PZone	PZone;					// Zone checking

var		bool										bDead, bNotPlaying, bSpecialItem;
var   class<s_SpecialItem>		SpecialItemClass;

var   class<s_Evidence>				Evidence[10];		// Evidence player carries
var		byte										Eidx;

// Objectives
// see SWATLevelInfo class

var		byte							O_number, LastO_number;		// Objective number in TO_ScenarioInfo
var   name						  Objective,	LastObjective;
var		Actor							LastOrderObject;
var		byte							O_Count;		// Objectives assignments during the round.

// TO_COnsoleTimer
var		TO_ConsoleTimer		CurrentCT;
var		s_ExplosiveC4			CurrentC4;

var		bool	bDoNotDisturb;	// When bot is busy doing a vital action, do not reset its state!

//var		float							LastSetNextObjectiveCheck;

var		byte							PlayerModel;
var		byte							HelmetCharge, VestCharge, LegsCharge;

var		int								money;		// money carried by bot (money/10)

var		bool							bNeedAmmo; // Bots in need of Ammo ?

var		name							OldState;		// Saves the bots state while BotBuying
var		Inventory					TempInv;		// Temp Inventory for state BotBuying
var   int								MaxFallHeight;

// Hostage
//var		bool							bHostageFollowing;	// Hostage is following
var		byte							HostageFollowing;
var		byte							CountCheck;

// Ladder support 0 = none, 1 = bottom, 2 = top
var		byte	byteClimbDir;


//var		int				LastDistressCall;


/*
///////////////////////////////////////
// YellAt 
///////////////////////////////////////

function YellAt(Pawn Moron)
{
	local float Threshold;
	local byte s;

	if ( Enemy == None )
		Threshold = 0.4;
	else
		Threshold = 0.7;
	if ( FRand() < Threshold )
		return;

	if (Moron.IsA('s_Player'))
	{
		if (FRand()<0.5)
			s=27;
		else
			s=28;

		s_Player(Moron).s_PlayDynamicSound(27, GetVoiceType(),, PlayerReplicationInfo);
	}
}


///////////////////////////////////////
// GetVoiceType 
///////////////////////////////////////

function byte GetVoiceType()
{
	local byte s;

	if (PlayerReplicationInfo==None)
		return 0;

	if (PlayerReplicationInfo.Team==0)
		s=2*Rand(2)+1;
	else
		s=2*Rand(2);

	return s;
}


///////////////////////////////////////
// CallForHelp 
///////////////////////////////////////

function CallForHelp()
{
	local Pawn P;
	local byte s;

	if ((Level.TimeSeconds-LastDistressCall)<5)
		return;

	LastDistressCall=Level.TimeSeconds;
	
	s=23+Rand(3);

	s_SWATGame(Level.Game).s_PlayDynamicTeamSound(s, GetVoiceType(), PlayerReplicationInfo.Team,, PlayerReplicationInfo);
		
	for ( P=Level.PawnList; P!=None; P=P.NextPawn )
		if ( P.IsA('Bot') && (P.PlayerReplicationInfo.Team == PlayerReplicationInfo.Team) )
			P.HandleHelpMessageFrom(self);
}
*/


///////////////////////////////////////
// SendVoiceMessage 
///////////////////////////////////////

function SendVoiceMessage(PlayerReplicationInfo Sender, PlayerReplicationInfo Recipient, name messagetype, byte messageID, name broadcasttype)
{
	if ( Sender.bIsSpectator || (Sender != PlayerReplicationInfo) )
		return;
/*
	if (MessageID==3)
	{
		if (Recipient!=None && Recipient.Owner!=None && Recipient.Owner.IsA('s_Player'))
			s_Player(Recipient.Owner).s_PlayDynamicSound(29, GetVoiceType(),, PlayerReplicationInfo);
		return;
	}
	*/
	/*else if (MessageID==5)
		return;
	else if (MessageID==10)
		return;*/
	Super.SendVoiceMessage(Sender, Recipient, messagetype, messageID, broadcasttype);
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
/*		log("Failed to load "$SkinName$" so load "$DefaultSkinName);
		if(DefaultSkinName != "")
		{
			NewSkin = Texture(DynamicLoadObject(DefaultSkinName, class'Texture'));
			SkinActor.Multiskins[SkinNo] = NewSkin;
		}*/
		return False;
	}
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
			//PZone.Frequency = 1.5;
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
	local	s_SWATGame SG;
	
	SG = s_SWATGame(Level.Game);
	if ( SG == None )
	{
		Log("s_Bot::Escape - Unable to locate game !!!");
		return;
	}
	
	SG.Escape(self);
}


///////////////////////////////////////
// SeeNPC 
///////////////////////////////////////

function SeeNPC( Actor SeenPlayer )
{
	local	s_SWATGame	SG;
	local	s_NPCHostage	H;

	//log("s_Bot::SeeNPC -"@GetHumanName()@"sees"@SeenPlayer.GetHumanName());

	SG = s_SWATGame(Level.Game);
	if ( (SG == None) || (SG.GamePeriod != GP_RoundPlaying) )
		return;

	//log("s_Bot::SeeNPC - SG and PlayRound check passed");

	if ( SeenPlayer.IsA('s_NPCHostage') /*&& !SeenPlayer.IsA('Carcass')*/ )
	{

		H = s_NPCHostage(SeenPlayer);

		if ( (H.Health < 1) || (PlayerReplicationInfo.bIsSpectator == true) )
			return;

		if ( SG.BotHasEnemy(Self) )
		{
			//log("s_Bot::SeeNPC -"@GetHumanName()@"has enemy, return");
			return;
		} 
/*
		if ( !SG.bHasHostages )
		{
			log("s_Bot::SeeNPC -"@GetHumanName()@"- game has no hostages");
			return;
		}
*/
		//log("s_Bot::SeeNPC -"@GetHumanName()@"sees a hostage:"@SeenPlayer.GetHumanName());

		if ( (H.Followed != None) && (OrderObject == SeenPlayer) && (H.Followed != Self) && H.Followed.IsA('Pawn')
			&& (H.Followed.PlayerReplicationInfo.Team == PlayerReplicationInfo.Team) )
		{
			//log("s_Bot::SeeNPC -"@GetHumanName()@"- Hostage already taken care of by someone else. Resetting bot.");
			SG.ResetBotObjective(Self, 1.0);
			return;
		}

		// Hostage handling only if
		// * Hostage is alone
		// * Bot is taking care of that hostage
		// * Opposing team takes care of that hostage
		// Otherwise, leave him alone.
		if ( (PlayerReplicationInfo.Team == 1) 
			&& (H.Followed == None || H.Followed == Self || (H.Followed != None && H.Followed.PlayerReplicationInfo.Team == 0 )	)
				)
		{
			
			if ( (Vsize(SeenPlayer.Location - Location) < 128) && (H.Followed != Self) ) 
			{
				if (Objective != 'O_BringHostageHome')
				{
					//log("s_Bot::SeeNPC -"@GetHumanName()@"- SF asks hostage to follow him");

					if ( Orders != 'Freelance' )
						SG.ResetBotObjective(Self, 1.0);

					SG.RescueHostage(self, H);
					Objective = 'O_BringHostageHome';
					OrderObject = SG.FindRescuePoint(Self);
					O_number = 255;
					return;
				}
			}
			else if ( (Objective != 'O_GotoHostage') && (H.Followed != Self) )
			{
				//log("s_Bot::SeeNPC -"@GetHumanName()@"- SF sees hostage, and moves towards him");

				SG.ResetBotObjective(Self, 1.0);
				Objective = 'O_GotoHostage';
				OrderObject = SeenPlayer;
				O_number = 255;
				//MoveTarget = SeenPlayer;
				return;
			}
		}
		else if ( (PlayerReplicationInfo.Team == 0) && ( (H.Followed == None) || (H.Followed == Self) 
				|| ( (H.Followed != None) && (H.Followed.PlayerReplicationInfo.Team == 1) ) 
					)
				)
		{ // Recode well
			// Terr have to take hostages to hiding points
			if ( (H.bIsFree) ) //&& (s_NPCHostage(SeenPlayer).Followed == None) )
			{ // Free
				if (SG.IsCloseToHidingPoint(SeenPlayer))
				{ // Hostage is in Hiding point
					if (Vsize(SeenPlayer.Location - Location) < 128)
					{
						//log("s_Bot::SeeNPC -"@GetHumanName()@"- T locks hostage");

						SG.LockHostage(self, H);
						
						if (Objective == 'O_GotoHostage' || Objective == 'O_GotoHostageHidingPoint')
							SG.ResetBotObjective(Self, 1.0);
						
						return;
					}
					else if (Objective != 'O_GotoHostage' && H.Followed != Self)
					{
						//log("s_Bot::SeeNPC -"@GetHumanName()@"T moves towards hostage, to lock him");

						SG.ResetBotObjective(Self, 1.0);
						Objective = 'O_GotoHostage';
						OrderObject = SeenPlayer;
						O_number = 255;
						//MoveTarget = SeenPlayer;
						return;
					}
				}
				else
				{ // Needs to bring back hostage to hiding point
					if (Vsize(SeenPlayer.Location - Location) < 128)
					{
						if ( Objective != 'O_GotoHostageHidingPoint' && H.Followed != Self)
						{
							//log("s_Bot::SeeNPC -"@GetHumanName()@"- T escorts hostage to hiding spot");

							//s_NPCHostage(SeenPlayer).bIsFree = false;
							SG.ResetBotObjective(Self, 1.0);
							SG.TerrEscortHostage(self, H);
							Objective = 'O_GotoHostageHidingPoint';
							OrderObject = SG.FindHostages(Self);
							O_number = 255;
							return;
						}
					}
					else if (Objective != 'O_GotoHostage' && H.Followed != Self)
					{
						//log("s_Bot::SeeNPC -"@GetHumanName()@"- T moves towards hostage to escort him to hiding point");

						SG.ResetBotObjective(Self, 1.0);
						Objective = 'O_GotoHostage';
						OrderObject = SeenPlayer;
						O_number = 255;
						//MoveTarget = SeenPlayer;
						return;
					}
				}
			}
			else
			{  // Locked
				if (SG.IsCloseToHidingPoint(SeenPlayer))
				{
					//log("s_Bot::SeeNPC -"@GetHumanName()@"- T Hostage is locked. resetting.");

					if (Objective == 'O_GotoHostage' || Objective == 'O_GotoHostageHidingPoint')
						SG.ResetBotObjective(Self, 1.0);

					return;
				}
				else
				{
					if (Vsize(SeenPlayer.Location - Location) < 128)
					{
						if (Objective != 'O_GotoHostageHidingPoint' && H.Followed != Self)
						{
							//log("s_Bot::SeeNPC -"@GetHumanName()@"- T leads hostage to hiding point");

							//s_NPCHostage(SeenPlayer).bIsFree = false;
							if ( Orders != 'Freelance' )
								SG.ResetBotObjective(Self, 1.0);

							SG.TerrEscortHostage(self, H);
							Objective = 'O_GotoHostageHidingPoint';
							OrderObject = SG.FindHostages(Self);
							O_number = 255;
							return;
						}
					}
					else if (Objective != 'O_GotoHostage' && H.Followed != Self)
					{
						//log("s_Bot::SeeNPC -"@GetHumanName()@"- T moves toward hostage to lead him to hiding spot");

						if ( Orders != 'Freelance' )
							SG.ResetBotObjective(Self, 1.0);

						Objective = 'O_GotoHostage';
						OrderObject = SeenPlayer;
						O_number = 255;
						//MoveTarget = SeenPlayer;	
						return;
					}
				}
			}
		}
	}	
}

/*
///////////////////////////////////////
// SeePlayer 
///////////////////////////////////////

function SeePlayer(Actor SeenPlayer)
{
	local	s_SWATGame	SG;
	local	s_NPCHostage	H;


	else 
		SetEnemy(Pawn(SeenPlayer));
}
*/

///////////////////////////////////////
// SetEnemy
///////////////////////////////////////

function bool SetEnemy( Pawn NewEnemy )
{
	local bool result, bNotSeen;
	local eAttitude newAttitude, oldAttitude;
	local float newStrength;
	local Pawn Friend;

	if ( Enemy == NewEnemy )
		return true;

	//log("s_Bot::SetEnemy - "@GetHumanName()@"S:"@GetStateName()@"- SetEnemy"@NewEnemy.GetHumanName());

	// treat NPCs appart.
	if ( NewEnemy.IsA('s_NPC') )
	{
		SeeNPC( NewEnemy );
		return false;
	}

	if ( (NewEnemy == Self) || (NewEnemy == None) || (NewEnemy.Health <= 0) || NewEnemy.IsA('FlockPawn') )
		return false;

	result = false;
	newAttitude = AttitudeTo(NewEnemy);
	if ( newAttitude == ATTITUDE_Friendly )
	{
		Friend = NewEnemy;
		if ( Level.TimeSeconds - Friend.LastSeenTime > 5 )
			return false;
		NewEnemy = NewEnemy.Enemy;
		if ( (NewEnemy == None) || (NewEnemy == Self) || (NewEnemy.Health <= 0) || NewEnemy.IsA('FlockPawn') || NewEnemy.IsA('StationaryPawn') )
			return false;
		if (Enemy == NewEnemy)
			return true;

		bNotSeen = true;
		newAttitude = AttitudeTo(NewEnemy);
	}

	if ( newAttitude >= ATTITUDE_Ignore )
		return false;

	if ( Enemy != None )
	{
		if ( AssessThreat(NewEnemy) > AssessThreat(Enemy) )
		{
			OldEnemy = Enemy;
			Enemy = NewEnemy;
			result = true;
		}
		else if ( OldEnemy == None )
			OldEnemy = NewEnemy;
	}
	else
	{
		result = true;
		Enemy = NewEnemy;
	}

	if ( result )
	{
		if ( bNotSeen )
		{
			LastSeenTime = Friend.LastSeenTime;
			LastSeeingPos = Friend.LastSeeingPos;
			LastSeenPos = Friend.LastSeenPos;
		}
		else
		{
			LastSeenTime = Level.TimeSeconds;
			LastSeeingPos = Location;
			LastSeenPos = Enemy.Location;
		}
		
		// ATAK
		// Drop objective to attack
		if (Objective != 'O_AttackEnnemy' && Objective != 'O_DoNothing')
		{
//			log("s_Bot::SetEnemy - "@GetHumanName()@"dropped objective to attack"@Enemy.GetHumanName());

			LastObjective = Objective;
			LastOrderObject = OrderObject;
			LastO_number = O_number; 
			Objective = 'O_AttackEnemy';
			OrderObject = Enemy;
		}

		EnemyAcquired();
	}
				
	return result;
}


///////////////////////////////////////
// ShareWith
///////////////////////////////////////

	function ShareWith(Pawn Other)
	{
		local bool bHaveItem, bIsHealth, bOtherHas, bIsWeapon;
		local Pawn P;
/*
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
		} */
	}


///////////////////////////////////////
// PreRound
///////////////////////////////////////

state PreRound
{
//ignores SeePlayer;
ignores SeePlayer, AnimEnd, TakeDamage; 
	
	function BeginState()
	{
		SpecialGoal = None;
		SpecialPause = 0.0;
		SetAlertness(-0.3);

		// maybe remove
		LetsGetLoaded();
	}

	function EndState()
	{
		//LetsGetLoaded();
	}

Begin:
	
	Acceleration = vect(0,0,0);
	TweenToFighter(0.2);
	FinishAnim();
	PlayTurning();
	TurnToward(Target);
	DesiredRotation = rot(0,0,0);
	DesiredRotation.Yaw = Rotation.Yaw;
	setRotation(DesiredRotation);
	TweenToFighter(0.2);
	FinishAnim();

	//Log("BotBuying - Entered");
	//Disable('AnimEnd');
	PlayWaiting();
	Velocity *= 0.0;
	/*
	Objective = "";
	Enable('AnimEnd');
	GotoState('Roaming');*/
	
}


///////////////////////////////////////
// SetOrders
///////////////////////////////////////

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

	if ( NewOrders != BotReplicationInfo(PlayerReplicationInfo).RealOrders )
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
				if ( P.bIsPlayer && (P.PlayerReplicationInfo.Team == PlayerReplicationInfo.Team) )
				{
					B = Bot(P);
					if ( (B != None) && (B.OrderObject == self) && (BotReplicationInfo(B.PlayerReplicationInfo).RealOrders == 'Follow') )
					{
						bLeading = true;
						break;
					}
				}
	}	
				
	BotReplicationInfo(PlayerReplicationInfo).OrderObject = OrderObject;
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
// SetMultiSkin
///////////////////////////////////////

static function SetMultiSkin(Actor SkinActor, string SkinName, string FaceName, byte TeamNum)
{
//	local string MeshName, FacePackage, SkinItem, FaceItem, SkinPackage;

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
/*
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

	// Fix for the Terror player model
	if (MeshName == "TerrorMesh")
		SetSkinElement(SkinActor, default.TeamSkin1 + 4, SkinName$string(default.TeamSkin1+1), "");
	else
		SetSkinElement(SkinActor, default.TeamSkin1, SkinName$string(default.TeamSkin1+1), "");

	SetSkinElement(SkinActor, default.TeamSkin2, SkinName$string(default.TeamSkin2+1), "");
*/
/*
	// Set the talktexture
	if(Pawn(SkinActor) != None)
	{
		if(FaceName != "")
			Pawn(SkinActor).PlayerReplicationInfo.TalkTexture = Texture(DynamicLoadObject(FacePackage$SkinItem$"5"$FaceItem, class'Texture'));
		else
			Pawn(SkinActor).PlayerReplicationInfo.TalkTexture = None;
	}
*/
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
		/*if (ReducedDamageType == 'All') //God mode
			actualDamage = 0;
		else if (Inventory != None) //then check if carrying armor
			actualDamage = Inventory.ReduceDamage(actualDamage, DamageType, HitLocation);
		else
			actualDamage = Damage;*/
	}
	else if ( (InstigatedBy != None) &&
				(InstigatedBy.IsA(Class.Name) || self.IsA(InstigatedBy.Class.Name)) )
		ActualDamage = ActualDamage * FMin(1 - ReducedDamagePct, 0.35); 
	else if ( (ReducedDamageType == 'All') || 
		((ReducedDamageType != '') && (ReducedDamageType == damageType)) )
		actualDamage = float(actualDamage) * (1 - ReducedDamagePct);
	
	if ( Level.Game.DamageMutator != None )
		Level.Game.DamageMutator.MutatorTakeDamage( ActualDamage, Self, InstigatedBy, HitLocation, Momentum, DamageType );

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
			
			TakeDamage(damage, None, Location, -velocity , 'Fell');

			ShakeView(0.175 - 0.00007 * Velocity.Z, -0.85 * Velocity.Z, -0.002 * Velocity.Z);
		}
	}
	else if ( Velocity.Z > 0.5 * Default.JumpZ )
		MakeNoise(0.35);				
}
*/

/*
///////////////////////////////////////
// bCanFall
///////////////////////////////////////

function bool bCanFall()
{
	local actor Other;
	local Vector HitLocation, HitNormal, EndTrace, StartTrace, X, Y, Z;

	GetAxes(ViewRotation, X, Y, Z);

	StartTrace=Location+100*X;
	EndTrace=StartTrace;
	EndTrace.Z-=MaxFallHeight;

	Other = Trace(HitLocation, HitNormal, EndTrace, StartTrace, true);

	if (Other == None)
		return false;
	else
		return true;
}
*/




/*
///////////////////////////////////////
// PlayFootStep
///////////////////////////////////////

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
*/

///////////////////////////////////////
// CalculateWeight
///////////////////////////////////////

simulated function CalculateWeight()
{
	local	float			Weight;

	if (bNotPlaying)
		return;

	if (bSpecialItem)
		Weight += class's_SpecialItem'.default.Weight;

	if (HelmetCharge > 0)
		Weight += 5;

	if (VestCharge > 0)
		Weight += 10;

	if (LegsCharge > 0)
		Weight += 7;

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
// FireWeapon
///////////////////////////////////////

function FireWeapon()
{
	local bool			bUseAltMode;
	local Weapon		MyGlock;
	local	s_Weapon	W;

	if ( (Enemy == None) && bShootSpecial )
	{
		//fake use s_Glock
		MyGlock = Weapon(FindInventoryType(class's_Glock'));
		if ( MyGlock == None )
			Spawn(class's_Projectile',,, Location,Rotator(Target.Location - Location));
		else
			MyGlock.TraceFire(0);

		return;
	}

	bUseAltMode = SwitchToBestWeapon();

	if( Weapon != None )
	{
/*
		if ( (Weapon.AmmoType != None) && (Weapon.AmmoType.AmmoAmount <= 0) )
		{
			bReadyToAttack = true;
			return;
		}
*/
		W = s_Weapon(Weapon);
		if ( W != None && W.bUseClip && W.ClipAmmo < 1 )
		{
			bReadyToAttack = false;
			return;
		}

 		if ( !bComboPaused && !bShootSpecial && (Enemy != None) )
 			Target = Enemy;
		ViewRotation = Rotation;
		PlayFiring();
		if ( bUseAltMode )
		{
			bFire = 0;
			bAltFire = 1;
			Weapon.AltFire(1.0);
		}
		else
		{
			bFire = 1;
			bAltFire = 0;
			Weapon.Fire(1.0);
		}
	}
	bShootSpecial = false;
}


///////////////////////////////////////
// ResetLastObj
///////////////////////////////////////

function ResetLastObj()
{
	if ( LastObjective == '' )
		return;

//	log("s_Bot::ResetLastObj -"@GetHumanName()@"- Resetting bot to default objective");

  Objective = LastObjective;
	OrderObject = LastOrderObject;
	O_number = LastO_number;
	
	LastObjective = '';
}


///////////////////////////////////////
// LetsGetLoaded
///////////////////////////////////////

function LetsGetLoaded()
{
	OldState = GetStateName();
	NextState = '';
	NextLabel = '';
	GotoState('BotBuying');
}


///////////////////////////////////////
// BotBuying
///////////////////////////////////////

state BotBuying
{
//ignores SeePlayer;
ignores SeePlayer, AnimEnd; 

	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
							Vector momentum, name damageType)
	{
		Global.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
		if ( health <= 0 )
			return;
		SetEnemy(instigatedBy);
		if ( Enemy == None )
			return;
		if ( NextState == 'TakeHit' )
		{
			NextState = 'Attacking'; //default
			NextLabel = 'Begin';
			GotoState('TakeHit'); 
		}
		else if (health > 0)
			GotoState('Attacking');
	}

	function EnemyAcquired()
	{
		//GotoState('Acquisition');
	}
	
	function BeginState()
	{
		SpecialGoal = None;
		SpecialPause = 0.0;
		SetAlertness(-0.3);
	}

Begin:

	//Log("s_Bot::BotBuying - Begin -"@GetHumanName()@PlayerReplicationInfo.Team);
	Acceleration = vect(0,0,0);
	TweenToFighter(0.2);
	FinishAnim();
	PlayTurning();
	TurnToward(Target);
	DesiredRotation = rot(0,0,0);
	DesiredRotation.Yaw = Rotation.Yaw;
	setRotation(DesiredRotation);
	TweenToFighter(0.2);
	FinishAnim();
	//PlayVictoryDance();
	//FinishAnim(); 
	//WhatToDoNext('Waiting','TurnFromWall');

	//Log("BotBuying - Entered");
	Disable('AnimEnd');
	PlayWaiting();
	Velocity *= 0.0;

	// Armor
	if (VestCharge < 50 && Money > 400 && FRand()<0.5)
	{
		PlaySound(Sound'kevlar', SLOT_Misc);
		Money-=400;
		VestCharge=100;
		sleep(0.17);
		MakeNoise(0.5);
	}
	if (HelmetCharge < 50 && Money > 250 && FRand()<0.5)
	{
		PlaySound(Sound'kevlar', SLOT_Misc);
		Money-=250;
		HelmetCharge=100;
		sleep(0.17);
		MakeNoise(0.5);
	}
	if (LegsCharge < 50 && Money > 300 && FRand()<0.5)
	{
		PlaySound(Sound'kevlar', SLOT_Misc);
		Money-=300;
		LegsCharge=100;
		sleep(0.17);
		MakeNoise(0.5);
	}

	BotBuyWeapons();

	//finish();
	Objective = 'O_DoNothing';
	O_number = 255;
	OrderObject = None; 
	
	bNeedAmmo = false;
	CountCheck = 0;
	for (TempInv=Inventory; TempInv != None; TempInv = TempInv.Inventory)
	{
		CountCheck++;
		if (CountCheck > 100)
			break;

		if ( (s_Weapon(TempInv) != None) && (s_Weapon(TempInv).bUseAmmo) )
			While( BotBuyAmmo(s_Weapon(TempInv)) )
			{
				// pause
				sleep(0.17);
				MakeNoise(0.5);
			}
	}		

	Enable('AnimEnd');

	GotoState(OldState);
}


///////////////////////////////////////
// BotBuyWeapons
///////////////////////////////////////

function BotBuyWeapons()
{
	if ( CanBuyWeaponClass(3) )
		BotGetWeapon(3);

	if ( CanBuyWeaponClass(2) )
		BotGetWeapon(2);

	if ( CanBuyWeaponClass(1) )
		BotGetWeapon(1);

	// Items
	if ( CanBuyWeaponClass(5) )
		BotGetWeapon(5);
}


///////////////////////////////////////
// CanBuyWeaponClass
///////////////////////////////////////

function bool CanBuyWeaponClass(int classn)
{
	local	Inventory Inv;
	local	int				i;

	for ( Inv=Inventory; Inv!=None; Inv=Inv.Inventory )
	{	 
		i++;
		if ( i > 50 )
			break;

		if ( Inv.IsA('s_Weapon') && (s_Weapon(Inv).WeaponClass != 0) && (s_Weapon(Inv).WeaponClass == classn) )
			return false;									
	}

	return true;
}


///////////////////////////////////////
// BotGetWeapon
///////////////////////////////////////

function bool BotGetWeapon(byte WeaponClass)
{
	local	class<s_Weapon>	W;
	local	int	i;

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

	return false;
}


///////////////////////////////////////
// BotBuyAmmo
///////////////////////////////////////

function bool BotBuyAmmo(Weapon W)
{
	local	s_SWATGame SG;
	//local ammo	A;
	local int oldammo;

	if (W == None)
		return false;
	
	SG = s_SWATGame(Level.Game);
	if ( SG == None )
		return false;

	//A = Ammo(FindInventoryType(W.AmmoName));
	OldAmmo = s_Weapon(W).RemainingClip;
	SG.BuyAmmo(self, s_Weapon(W));
	
	if ( (s_Weapon(W).RemainingClip < s_Weapon(W).MaxClip) && (s_Weapon(W).RemainingClip > OldAmmo) )
		return true;

	return false;
}


///////////////////////////////////////
// UseConsoleTimer
///////////////////////////////////////

function UseConsoleTimer(TO_ConsoleTimer CT)
{
	// Can Bot activate the Console Timer?
	//log("s_Bot::UseConsoleTimer");
	if ( !CT.bActive || CT.bBeingActivated || !CT.IsRevelant(Self) )
		return;

	OldState = GetStateName();
	NextState = '';
	NextLabel = '';

	CurrentCT = CT;

	//log("s_Bot::UseConsoleTimer - calling BotActivateTO_ConsoleTimer state");
	GotoState('BotActivateTO_ConsoleTimer');
}


///////////////////////////////////////
// BotActivateTO_ConsoleTimer
///////////////////////////////////////

state BotActivateTO_ConsoleTimer
{
//ignores SeePlayer;
ignores SeePlayer, AnimEnd; 

	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
							Vector momentum, name damageType)
	{
		CurrentCT.CTFailed();

		Global.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);

		Objective = 'O_DoNothing';
		O_number = 255;
		OrderObject = None; 
		Enable('AnimEnd');

		if ( health <= 0 )
			return;

		SetEnemy(instigatedBy);

		if ( Enemy == None )
		{
			GotoState(OldState);
			return;
		}

		if ( NextState == 'TakeHit' )
		{
			NextState = 'Attacking'; //default
			NextLabel = 'Begin';
			GotoState('TakeHit'); 
		}
		else if (health > 0)
			GotoState('Attacking');
	}

	function EnemyAcquired()
	{
		//GotoState('Acquisition');
	}
	
	function RoundEnded()
	{
		CurrentCT.CTFailed();

		Objective = 'O_DoNothing';
		O_number = 255;
		OrderObject = None; 
		Enable('AnimEnd');

		//GotoState(OldState);
	}

	function BeginState()
	{
		SpecialGoal = None;
		SpecialPause = 0.0;
		SetAlertness(-0.3);
		bDoNotDisturb = true;
	}

	function EndState()
	{
		bDoNotDisturb = false;
	}

Begin:
	
	//log("s_Bot::BotActivateTO_ConsoleTimer::Begin");
	Acceleration = vect(0,0,0);
	TweenToFighter(0.2);
	FinishAnim();
	PlayTurning();
	TurnToward(CurrentCT);
	DesiredRotation = rot(0,0,0);
	DesiredRotation.Yaw = Rotation.Yaw;
	setRotation(DesiredRotation);
	TweenToFighter(0.2);
	FinishAnim();
	//PlayVictoryDance();
	//FinishAnim(); 
	//WhatToDoNext('Waiting','TurnFromWall');

	//Log("BotBuying - Entered");
	Disable('AnimEnd');
	PlayWaiting();
	Velocity *= 0.0;

	// Activate Console
	if ( CurrentCT.CTActivate(Self) )
	{
		if ( CurrentCT.bCanResumeProgress )
			sleep(CurrentCT.CTDuration - CurrentCT.Progress);
		else
			sleep(CurrentCT.CTDuration);
		CurrentCT.CTComplete();
	}

	//finish();
	Objective = 'O_DoNothing';
	O_number = 255;
	OrderObject = None; 

	Enable('AnimEnd');

	//log("s_Bot::BotActivateTO_ConsoleTimer::Begin - Finished!");
	GotoState(OldState);
}


///////////////////////////////////////
// PlantC4Bomb
///////////////////////////////////////

function PlantC4Bomb()
{
	local	s_C4	C4;

	// Make sure we change to C4 weapon
	if ( Weapon != None )
		Weapon = None;

	C4 = s_C4(FindInventoryType(class's_SWAT.s_C4'));	
	if ( C4 != None )
		C4.WeaponSet(Self);
	else
	{
		log("s_Bot::BPlantC4Bomb - Bot doesn't have C4!!");
		return;
	}

	OldState = GetStateName();
	NextState = '';
	NextLabel = '';

	bDoNotDisturb = true;
	//log("s_Bot::PlantC4Bomb - calling BotPlantingC4Bomb state");
	GotoState('BotPlantingC4Bomb');
}


///////////////////////////////////////
// BotPlantingC4Bomb
///////////////////////////////////////

state BotPlantingC4Bomb
{
//ignores SeePlayer;
ignores SeePlayer, AnimEnd; 

	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
							Vector momentum, name damageType)
	{
		Global.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);

		Objective = 'O_DoNothing';
		O_number = 255;
		OrderObject = None; 
		Enable('AnimEnd');

		if ( health <= 0 )
			return;

		SetEnemy(instigatedBy);

		if ( Enemy == None )
		{
			GotoState(OldState);
			return;
		}

		if ( NextState == 'TakeHit' )
		{
			NextState = 'Attacking'; //default
			NextLabel = 'Begin';
			GotoState('TakeHit'); 
		}
		else if (health > 0)
			GotoState('Attacking');
	}

	function EnemyAcquired()
	{
		//GotoState('Acquisition');
	}
	
	function RoundEnded()
	{
		Objective = 'O_DoNothing';
		O_number = 255;
		OrderObject = None; 
		Enable('AnimEnd');

		//GotoState(OldState);
	}

	function BeginState()
	{
		//log("s_Bot::BotPlantingC4Bomb::BeginState");
		//local	s_C4	C4;

		SpecialGoal = None;
		SpecialPause = 0.0;
		SetAlertness(-0.3);
/*
		// Make sure we change to C4 weapon
		if ( Weapon != None )
			Weapon = None;

		C4 = s_C4(FindInventoryType(class's_SWAT.s_C4'));	
		if ( C4 != None )
		{
			C4.WeaponSet(Self);
		}
		else
			log("s_Bot::BotPlantingC4Bomb::BeginState - Bot doesn't have C4!!");
*/
		bDoNotDisturb = true;
	}

	function EndState()
	{
		//log("s_Bot::BotPlantingC4Bomb::EndState");
		bDoNotDisturb = false;
	}

Begin:
	
	//log("s_Bot::BotPlantingC4Bomb::Begin");
	
	Acceleration = vect(0,0,0);
	TweenToFighter(0.2);
	FinishAnim();
	PlayTurning();
	TurnToward(Target);
	DesiredRotation = rot(0,0,0);
	DesiredRotation.Yaw = Rotation.Yaw;
	setRotation(DesiredRotation);
	TweenToFighter(0.2);
	FinishAnim();
	//PlayVictoryDance();
	//FinishAnim(); 
	//WhatToDoNext('Waiting','TurnFromWall');

	//Log("BotBuying - Entered");
	Disable('AnimEnd');
	PlayWaiting();
	Velocity *= 0.0;

	if ( s_C4(Weapon) != None )
	{
		//log("s_Bot::BotPlantingC4Bomb::Begin - planting C4!");

		PlaySound(Sound'TODatas.bomb_set_seq');
		Sleep(GetSoundDuration(Sound'TODatas.bomb_set_seq'));
		sleep(1.0);
		s_C4(Weapon).bNoDrop = true;
		s_C4(Weapon).PlaceC4();
	}
	else
		log("s_Bot::BotPlantingC4Bomb::Begin - Bot doesn't have C4!!");

	//finish();
	Objective = 'O_DoNothing';
	O_number = 255;
	OrderObject = None; 

	//PawnOwner.SwitchToBestWeapon();
	//PawnOwner.ChangedWeapon();

	Enable('AnimEnd');

	//log("s_Bot::BotPlantingC4Bomb::Begin - Finished!");
	GotoState(OldState);
}


///////////////////////////////////////
// DefuseC4
///////////////////////////////////////

function DefuseC4( s_ExplosiveC4 C4 )
{
	// Can Bot defuse the C4?
	//log("s_Bot::DefuseC4");
	if ( !C4.C4Activate( Self ) )
		return;

	OldState = GetStateName();
	NextState = '';
	NextLabel = '';

	CurrentC4 = C4;

	//log("s_Bot::UseConsoleTimer - calling BotActivateTO_ConsoleTimer state");
	GotoState('BotDefusingC4Explosive');
}


///////////////////////////////////////
// BotDefusingC4Explosive
///////////////////////////////////////

state BotDefusingC4Explosive
{
//ignores SeePlayer;
ignores SeePlayer, AnimEnd; 

	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
							Vector momentum, name damageType)
	{
		CurrentC4.C4Failed();
		PlayOwnedSound(Sound'TODatas.def_fail');

		Global.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);

		Objective = 'O_DoNothing';
		O_number = 255;
		OrderObject = None; 
		Enable('AnimEnd');

		if ( health <= 0 )
			return;

		SetEnemy(instigatedBy);

		if ( Enemy == None )
		{
			GotoState(OldState);
			return;
		}

		if ( NextState == 'TakeHit' )
		{
			NextState = 'Attacking'; //default
			NextLabel = 'Begin';
			GotoState('TakeHit'); 
		}
		else if (health > 0)
			GotoState('Attacking');
	}

	function EnemyAcquired()
	{
		//GotoState('Acquisition');
	}
	
	function RoundEnded()
	{
		CurrentC4.C4Failed();
		PlayOwnedSound(Sound'TODatas.def_fail');

		Objective = 'O_DoNothing';
		O_number = 255;
		OrderObject = None; 
		Enable('AnimEnd');
		//GotoState(OldState);
	}

	function BeginState()
	{
		SpecialGoal = None;
		SpecialPause = 0.0;
		SetAlertness(-0.3);		
		bDoNotDisturb = true;
	}

	function EndState()
	{
		bDoNotDisturb = false;
		AmbientSound = None;
	}

Begin:
	
	//log("s_Bot::BotActivateTO_ConsoleTimer::Begin");
	Acceleration = vect(0,0,0);
	TweenToFighter(0.2);
	FinishAnim();
	PlayTurning();
	TurnToward(CurrentC4);
	DesiredRotation = rot(0,0,0);
	DesiredRotation.Yaw = Rotation.Yaw;
	setRotation(DesiredRotation);
	TweenToFighter(0.2);
	FinishAnim();
	//PlayVictoryDance();
	//FinishAnim(); 
	//WhatToDoNext('Waiting','TurnFromWall');

	//Log("BotBuying - Entered");
	Disable('AnimEnd');
	PlayWaiting();
	Velocity *= 0.0;

	// Defuse C4
	PlayOwnedSound(Sound'TODatas.def_start', Slot_Interact);
	
	sleep(GetSoundDuration(Sound'TODatas.def_start'));
	AmbientSound = Sound'TODatas.def_progress';

	sleep(CurrentC4.C4Duration - GetSoundDuration(Sound'TODatas.def_start'));

	CurrentC4.C4Complete();
	AmbientSound = None;
	PlayOwnedSound(Sound'TODatas.def_success');

	//finish();
	Objective = 'O_DoNothing';
	O_number = 255;
	OrderObject = None; 

	Enable('AnimEnd');

	//log("s_Bot::BotActivateTO_ConsoleTimer::Begin - Finished!");
	GotoState(OldState);
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
     GroundSpeed=300.000000
     JumpZ=350.000000
     VoiceType=""
     PlayerReplicationInfoClass=Class's_SWAT.TO_BRI'
}
