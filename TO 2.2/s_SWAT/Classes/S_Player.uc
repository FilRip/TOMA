//=============================================================================
// s_Player
//=============================================================================
//
// Tactical Ops
// - http://www.planetunreal.com/tacticalops
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen and Benoit "JAH" Delayen
// - AutoAmmoAliases - Addendum July 2000, Michael "IvanTT" Sanders
//=============================================================================

class s_Player extends s_BPlayer
			abstract;

var		s_PRI			TOPRI;					// Tactical Ops PlayerReplicationInfo
var		TO_PZone	PZone;					// Zone checking

var		bool										bDead, bNotPlaying, bSpecialItem;
var   class<s_SpecialItem>		SpecialItemClass;

var   class<s_Evidence>				Evidence[10];		// Evidence player carries
var		byte										Eidx;

var		int		money;					// Current money player is carrying (money/10)
var		bool	bNightVision;		// is in night vision mode ?
var		bool	bHasNV;						// Does player have night vision ?

var		bool	bAlreadyChangedTeam;	// only 1 team change per round.
var		bool	bActionWindow;				// Is ActionWindow showing ?

/*
var		float	BehindViewDistFactor;
var		float	BehindViewDist;
var		float	BehindViewHeight;
*/
var		bool	bBackupBehindView;

var		bool	bCantStandUp;			// While crouching, can't stand up
var		float	CrouchHeight;

var		byte	PlayerModel;

var		byte	HelmetCharge;		// Armor
var		byte  VestCharge;
var		byte  LegsCharge;
 
var		bool	bShowDebug;			// Show debug info

var   float OldLadderZ;

// Console Timers
var		bool						bUsingCT;
var		float						CTUseTime, CTEndTime;
var		TO_ConsoleTimer	CurrentCT;

// C4
var		s_ExplosiveC4		CurrentC4;

var		TO_ScenarioInfo						SI;
var		s_RainGeneratorInternal		RG;

var		float	BlindTime;	
var		float	CurrentSoundDuration;

// Zone control - client side
var		bool	bInBuyZone, bInHomeBase, bInEscapeZone, bInRescueZone, bInBombingZone;

var		bool	bBuyingWeapon; // to avoid weapon buying screw up

var		SpeechWindow				SpeechOld;

//var	float	LastGarbageCollect;


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



///////////////////////////////////////
// replication 
///////////////////////////////////////

replication 
{
	// Server send to client 
	reliable if( Role==ROLE_Authority && bNetOwner )
		Money, bHasNV, bSpecialItem, Eidx, CurrentCT/*, CurrentC4*/, PlayerModel;

	unreliable if( Role==ROLE_Authority && bNetOwner )
		HelmetCharge, VestCharge, LegsCharge;
  
/*	unreliable if( Role==ROLE_Authority && bNetOwner && bNotPlaying)
		BehindViewDist, BehindViewDistFactor; */

//	reliable if( Role==ROLE_Authority )
//		bDead/*, bNotPlaying*/;

	// Client send to server
	//reliable if( bNetOwner && Role<ROLE_Authority )
	//	bHideDeathMsg;

	// Functions server can call on clients
	reliable if( bNetOwner && Role==ROLE_Authority )
		SetBlindTime, HUD_Add_Money_Message, ClientUseConsoleTimer, ClientUseC4, ClientRoundEnded, ResetTime;

	reliable if( Role==ROLE_Authority )
		EndPreRound, HUD_Add_Death_Message, NV_off /*, s_PlayDynamicSound*/;


  // Functions clients can call (for Extra-Keys)
  reliable if( Role < ROLE_Authority)
  	AdminSet, AdminReset, ServerEndRound, BuyWeapon, BuyKnives, ServerVote, 
		s_BuyItem, BuyAmmo, ServerUsePress, UseReleaseServer, KillMe, RescueHostage;

	//reliable if (bNetOwner && Role < ROLE_Authority)
	//	ServerSetHideDeathMsg ;
}

/*
exec function dumpzones()
{
	local	int	i;

	for (i=0; i<4; i++)
		log("s_Player::dumpzones - Touching"@i@Touching[i]);
	log("bInBuyZone"@bInBuyZone@"bInHomeBase"@bInHomeBase@"bInEscapeZone"@bInEscapeZone@"bInRescueZone"@bInRescueZone@"bInBombingZone"@bInBombingZone);
}
*/


// Overridden functions
exec function Loaded() {}
function LoadLeftHand() {}
function ChangeTeam( int N ) {}

//function ServerSetHandedness( float hand) {}
//exec function SetHand( string S ) {}
//function ChangeSetHand( string S ) {}
simulated function bool AdjustHitLocation(out vector HitLocation, vector TraceDir) { return true; }
/*
exec function FeignDeath() {}
function ServerFeignDeath() {}
function PlayFeignDeath();
function PlayRising();
*/
// Disable CenterView cheat
function ChangeSnapView( bool B ) {	bSnapToLevel = false; }
function bool Gibbed( name damageType ) { return false; }



///////////////////////////////////////
// PostBeginPlay
///////////////////////////////////////

simulated function PostBeginPlay()
{
	//log("s_Player::PostBeginPlay");

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
}


///////////////////////////////////////
// Possess
///////////////////////////////////////

simulated event Possess()
{
	local	s_SWATLevelInfo					SWLI;
	local	TO_ScenarioInfoInternal SIint;
	local TournamentConsole				C;
	local	UWindowRootWindow				Root;
	local string									message;

	//log("s_Player::Possess");

	Super.Possess();

	if ( (Level!=None) && (Level.Game!=None) && !Level.Game.IsA('s_SWATGame') )
		return;
/*
	if ( Role ==  Role_Authority )
	{
		Destroy();
		return;
	}
*/
	if ( Level.NetMode != NM_DedicatedServer )
	{
		message = "s_Player::Possess - "$class'TOSystem.TO_MenuBar'.default.TOVersionText;
		log(message);

		// activate rain generator if any
		if ( RG != None )
			RG.Destroy();

		if ( Level.bHighDetailMode )
			toggleraingen();
	}

	// Zone Checking
	if ( PZone != None )
		PZone.Destroy();

	PZone = Spawn(class'TO_PZone', self);

	if ( PZone != None )
		PZone.Initialize();

		// SWAT LevelInfo
	if ( SI == None )
		ForEach AllActors(class'TO_ScenarioInfo', SI)
			break;

	if ( Role < Role_Authority )
	{
		// Dupe Client-side TO_ScenarioInfo - Only if if it has to be converted from an old s_SWATLevelInfo
		if ( SI == None )
		{
			ForEach AllActors(class's_SWATLevelInfo', SWLI)
				break;
			
			//log("s_Player::PostBeginPlay - Dupe SWLI."@GetHumanName());

			if ( SWLI != None )
			{
				SIint = Spawn(class's_SWAT.TO_ScenarioInfoInternal', Self,, Location);

				if ( SIint != None )
				{
					SIint.ConvertActor(SWLI);
					SI = SIint;
					//SWLI.Destroy();
				}
				else
					log("s_Player - PostBeginPlay - ConvertSWLI - SI == None");
			}
			else
				log("s_Player - PostBeginPlay - SWLI == None");
		}
	}

	// Console != None only when there is a viewport attached to the player
	if ( (Player.Console == None) && (Role == Role_Authority) )
		return;

	if ( StartMenu != None )
	{
		StartMenu.Close();
		StartMenu = None;
	}

	C = TournamentConsole(Player.Console);

	if ( C.bShowSpeech )
		C.HideSpeech();

	if ( C.Root == None )
	{
		log("s_Player::Possess - C.Root == None - creating Root");
		C.CreateRootWindow(None);
	}
	else
	{
		C.bQuickKeyEnable = true;
		C.LaunchUWindow();
		StartMenu = TO_TeamSelect(C.Root.CreateWindow(class'TOPModels.TO_TeamSelect', 0, 0, C.Root.WinWidth, C.Root.WinHeight));
	}

	if (Player != None
		&& Player.Console != None
		&& TO_Console(Player.Console) != None
		&& (TO_Console(Player.Console).Speechwindow == None
		|| !TO_Console(Player.Console).Speechwindow.IsA('s_SWATWindow')) )
	{

		Root = WindowConsole(Player.Console).Root;

		TO_Console(Player.Console).Speechwindow = SpeechWindow(Root.CreateWindow(Class's_SWATWindow', 100, 100, 200, 200));

		if (TO_Console(Player.Console).Speechwindow == None)
		{
			log("s_Player::Possess - Speechwindow == None");
			return;
		}

		TO_Console(Player.Console).SpeechWindow.bLeaveOnScreen = true;

		if(TO_Console(Player.Console).bShowSpeech)
		{
			Root.SetMousePos(0, 132.0/768 * Root.WinWidth);
			TO_Console(Player.Console).SpeechWindow.SlideInWindow();
		} 
		else
			TO_Console(Player.Console).SpeechWindow.HideWindow();
	}
	else
		log("s_Player::Possess - cannot replace speechwindow");

	if ( StartMenu == None )
		log("s_Player::Possess - StartMenu == None");

	GotoState('PlayerWaiting');

	//log("s_Player::EndPossess");
}


///////////////////////////////////////
// Destroyed 
///////////////////////////////////////

simulated event Destroyed()
{
	local	TO_ScenarioInfoInternal SIint;

	//log("s_Player::Destroyed");
	// Destroy spawned scenarioinfo class
	// Only spawned if we need to convert an old TO 1.6 class to the new 2.0 standard
	// In that case it's a TO_ScenarioInfoInternal, subclass of TO_ScenarioInfo
	if ( (SI != None) && SI.IsA('TO_ScenarioInfoInternal') )
		SI.Destroy();
	//ForEach AllActors(class'TO_ScenarioInfoInternal', SIint)
	//	SIint.Destroy();

	// This is to make sure the weapons are dropped before leaving to avoid breaking gameplay (C4, OICW, ..)
	if ( (Role == Role_Authority) && (Level!=None) && (Level.Game!=None) && (s_SWATGame(Level.Game)!=None) )
		s_SWATGame(Level.Game).DropInventory(Self, false);
	//else
	//	spawn(class's_Remover', self);	

	// To avoid the speechwindow interferring with the Team Selectionscreen when a new map loads.
	if ( (Player != None) && (Player.Console != None) && (TO_Console(Player.Console) != None)
		&& TO_Console(Player.Console).bShowSpeech )
		TO_Console(Player.Console).HideSpeech();

	// Destroy team selection screen if not already done.
	if ( StartMenu != None )
	{
		StartMenu.Close();
		StartMenu = None;
	}

	// Destroy bloodtrails attached actor
	if ( TOPRI != None )
		TOPRI.Destroy();
	
	// destroy zone checking actor
	if ( PZone != None )
		PZone.Destroy();

	// destroy client side rain generator
	if ( RG != None )
		RG.Destroy();

	Super.Destroyed();
}


///////////////////////////////////////
// toggleraingen 
///////////////////////////////////////
// Toggles rain generator on/off

exec simulated function toggleraingen()
{
	local	s_RainGenerator	tRG;

	//log("s_Player::toggleraingen");

	if ( RG != None )
		RG.Destroy();
	else
	{
		// Dupe Client-side RainGenerator
		ForEach AllActors(class's_RainGenerator', tRG)
			break;

		if ( tRG != None )
		{
			//log("s_Player::toggleraingen - tRG found");
			RG = Spawn(class's_RainGeneratorInternal', self,, tRG.Location);
			if (RG != None)
			{
				//log("s_Player::toggleraingen - RainGenerator activated");
				RG.Interval = tRG.Interval;
				RG.variance = tRG.variance;
				RG.DropSpeed = tRG.DropSpeed;
				RG.dropradius = tRG.dropradius;
				RG.NumberOfDrips = tRG.NumberOfDrips;
				RG.RainType = tRG.RainType;
				RG.bMeshRainDrop = tRG.bMeshRainDrop;	
				RG.bJerky = tRG.bJerky;
				RG.Jerkyness = tRG.Jerkyness;	

				RG.Init();
				//RG.SetTimer(RG.Interval, false);
			}
		}
	}
}


///////////////////////////////////////
// s_Flashlight 
///////////////////////////////////////

function s_Flashlight()
{
	if ( bNotPlaying )
		return;

	Super.s_Flashlight();
}


///////////////////////////////////////
// Touch 
///////////////////////////////////////

simulated event Touch( Actor Other )
{
	if ( (Role < Role_Authority) || bNotPlaying )
		return;

	//log("s_Player::Touch - Actor:"@Other);
	// Only check for zones or ladders
	if ( Other.IsA('s_Ladder') || Other.IsA('TO_Ladder') )
	{
		//CheckTouchList();
		if ( GetStateName() != 'Climbing' )
		{
			GotoState('Climbing');
			CalculateWeight();
		}
	}
}


///////////////////////////////////////
// UnTouch 
///////////////////////////////////////

simulated event UnTouch( Actor Other )
{
	if ( (Role < Role_Authority) || bNotPlaying )
		return;

	//log("s_Player::UnTouch - Actor:"@Other);
	//CheckTouchList();
	
	// Only check for zones or ladders
	if ( Other.IsA('s_Ladder') || Other.IsA('TO_Ladder') )
	{	
		//CheckTouchList();
		if ( Region.Zone.bWaterZone )
		{
			SetPhysics(PHYS_Swimming);
			GotoState('PlayerSwimming');
		}
		else
			GotoState('PlayerWalking');

		CalculateWeight();
	}
}

/*
///////////////////////////////////////
// CheckTouchList 
///////////////////////////////////////
// Handles player collisions with zones and ladders

simulated function CheckTouchList()
{
	local	int									i;
	local	s_ZoneControlPoint	Zone;
	local	bool								bLadder;

	// Server
	if ( Role == Role_Authority )
	{
		bLadder = false;

		for ( i=0; i<4; i++ )
			if ( Touching[i] != None )
			{
				log("s_Player::CheckTouchList["$i$"]"@Touching[i]);
				if ( Touching[i].IsA('s_Ladder') || Touching[i].IsA('TO_Ladder') )
					bLadder = true;
			}

		// Enter ladder
		if ( bLadder && (GetStateName() != 'Climbing') )
		{
			log("s_Player::CheckTouchList - EnterLadder");
			GotoState('Climbing');
			CalculateWeight();
		}

		// Exit ladder
		else if ( !bLadder && (GetStateName() == 'Climbing') )
		{
			log("s_Player::CheckTouchList - ExitLadder");
			if ( Region.Zone.bWaterZone )
			{
				SetPhysics(PHYS_Swimming);
				GotoState('PlayerSwimming');
			}
			else
				GotoState('PlayerWalking');

			CalculateWeight();
		}
	}
}
*/

///////////////////////////////////////
// RoundEnded
///////////////////////////////////////

function RoundEnded()
{
	ClientRoundEnded();
}


///////////////////////////////////////
// ClientRoundEnded
///////////////////////////////////////

simulated function ClientRoundEnded()
{
	if ( Level.NetMode != NM_DedicatedServer )
	{
		if ( bSZoom )
			ToggleSZoom();

		if ( Role < Role_Authority )
			spawn(class's_Remover', self);
/*
		// Garbage collection
		// Done when loading a new map, but here we force it to happen when a round begins.
		// But at least 2mins between 2 garbage collects
		if ( LastGarbageCollect < Level.TimeSeconds )
		{
			LastGarbageCollect = Level.TimeSeconds + 120;
			ConsoleCommand("obj garbage");
		}
*/
	}
}


///////////////////////////////////////
// PreClientTravel 
///////////////////////////////////////

event PreClientTravel()
{
//	if (UTConsole(Player.Console).bShowSpeech)
//		UTConsole(Player.Console).HideSpeech();

	//Super.PreClientTravel();

	if ( (Player!=None) && (Player.Console!=None) && (TO_Console(Player.Console)!=None) 
		&& TO_Console(Player.Console).bShowSpeech )
		TO_Console(Player.Console).HideSpeech();

	if ( StartMenu != None )
	{
		StartMenu.Close();
		StartMenu = None;
	}
}


///////////////////////////////////////
// ClientShake 
///////////////////////////////////////

function ClientShake(vector shake)
{
	if ( bIsCrouching )
		shake = shake / 1.5;

	Super.ClientShake(shake);
}


///////////////////////////////////////
// KilledBy 
///////////////////////////////////////

function KilledBy( pawn EventInstigator )
{
	local	s_SWATGame	SG;

	SG = s_SWATGame(Level.Game);
	if ( (SG != None) && (SG.GamePeriod != GP_RoundPlaying) )
		return;

	Super.KilledBy(EventInstigator);
}


///////////////////////////////////////
// Died 
///////////////////////////////////////

function Died(pawn Killer, name damageType, vector HitLocation)
{
	local	s_SWATGame	SG;

	SG = s_SWATGame(Level.Game);
	if ( (SG != None) && (SG.GamePeriod != GP_RoundPlaying) )
		return;

	Super.Died(Killer, damageType, HitLocation);	
}


///////////////////////////////////////
// s_kFlashlight 
///////////////////////////////////////

exec function s_kFlashlight()
{
	if ( bNotPlaying )
		return;

	Super.s_kFlashlight();
}


///////////////////////////////////////
// SwitchWeapon 
///////////////////////////////////////
// The player wants to switch to weapon group numer I.
// Fix weapon selection problem when escaped

exec function SwitchWeapon(byte F )
{
	if ( bNotPlaying ) return;
	Super.SwitchWeapon(F);
}

exec function PrevWeapon()
{
	local int prevGroup;
	local Inventory inv;
	local Weapon /*realWeapon,*/ w, Prev;
	local bool bFoundWeapon;

	if( bNotPlaying || bShowMenu || Level.Pauser!="" )
		return;

	if ( Weapon == None )
	{
		SwitchToBestWeapon();
		return;
	}

	prevGroup = 0;
	//realWeapon = Weapon;
	//if ( PendingWeapon != None )
	//	Weapon = PendingWeapon;
	PendingWeapon = None;
	
	for (inv=Inventory; inv!=None; inv=inv.Inventory)
	{
		w = Weapon(inv);
		if ( w != None )
		{
			if ( w.InventoryGroup == Weapon.InventoryGroup )
			{
				if ( w == Weapon )
				{
					bFoundWeapon = true;
					if ( Prev != None )
					{
						PendingWeapon = Prev;
						break;
					}
				}
				else if ( !bFoundWeapon )
					Prev = W;
			}
			else if ( (w.InventoryGroup < Weapon.InventoryGroup) && (w.InventoryGroup >= prevGroup) )
			{
				prevGroup = w.InventoryGroup;
				PendingWeapon = w;
			}
		}
	}
	bFoundWeapon = false;
	prevGroup = Weapon.InventoryGroup;
	if ( PendingWeapon == None )
		for (inv=Inventory; inv!=None; inv=inv.Inventory)
		{
			w = Weapon(inv);
			if ( w != None )
			{
				if ( w.InventoryGroup == Weapon.InventoryGroup )
				{
					if ( w == Weapon )
						bFoundWeapon = true;
					else if ( bFoundWeapon && (PendingWeapon == None) )
						PendingWeapon = W;
				}
				else if ( w.InventoryGroup > PrevGroup ) 
				{
					prevGroup = w.InventoryGroup;
					PendingWeapon = w;
				}
			}
		}

	//Weapon = realWeapon;
	if ( PendingWeapon == None )
		return;

	if ( !Weapon.PutDown() )
		PendingWeapon = None;
}


exec function NextWeapon()
{
	local int nextGroup;
	local Inventory inv;
	local Weapon /*realWeapon, */w, Prev;
	local bool bFoundWeapon;

	if( bNotPlaying || bShowMenu || (Level.Pauser!="") )
		return;

	if ( Weapon == None )
	{
		SwitchToBestWeapon();
		return;
	}

	nextGroup = 100;
	//realWeapon = Weapon;
	//if ( PendingWeapon != None )
	//	Weapon = PendingWeapon;
	PendingWeapon = None;

	for (inv=Inventory; inv!=None; inv=inv.Inventory)
	{
		w = Weapon(inv);
		if ( w != None )
		{
			if ( w.InventoryGroup == Weapon.InventoryGroup )
			{
				if ( w == Weapon )
					bFoundWeapon = true;
				else if ( bFoundWeapon )
				{
					PendingWeapon = W;
					break;
				}
			}
			else if ( (w.InventoryGroup > Weapon.InventoryGroup) && (w.InventoryGroup < nextGroup) )
			{
				nextGroup = w.InventoryGroup;
				PendingWeapon = w;
			}
		}
	}

	bFoundWeapon = false;
	nextGroup = Weapon.InventoryGroup;
	if ( PendingWeapon == None )
		for (inv=Inventory; inv!=None; inv=inv.Inventory)
		{
			w = Weapon(Inv);
			if ( w != None )
			{
				if ( w.InventoryGroup == Weapon.InventoryGroup )
				{
					if ( w == Weapon )
					{
						bFoundWeapon = true;
						if ( Prev != None )
							PendingWeapon = Prev;
					}
					else if ( !bFoundWeapon && (PendingWeapon == None) )
						Prev = W;
				}
				else if ( w.InventoryGroup < nextGroup ) 
				{
					nextGroup = w.InventoryGroup;
					PendingWeapon = w;
				}
			}
		}

	//Weapon = realWeapon;
	if ( PendingWeapon == None )
		return;

	if ( !Weapon.PutDown() )
		PendingWeapon = None;
}


///////////////////////////////////////
// vote
///////////////////////////////////////

exec function vote(byte	PlayerID)
{
	//log("vote - PlayerID: "$PlayerID);
	ServerVote(PlayerID);
}	


///////////////////////////////////////
// ServerVote
///////////////////////////////////////

function ServerVote(Byte PlayerID)
{
	local	Pawn			PawnLink;
	local	s_Player	P;
	local	byte			i;

	for ( PawnLink=Level.PawnList; PawnLink!=None; PawnLink=PawnLink.nextPawn )
	{
		i++;
		if (i > 100)
			break;

		if (PawnLink.PlayerReplicationInfo.PlayerID == PlayerID )
		{
			P = s_Player(PawnLink);
			break;
		}
	}

	if (P != None && P != Self)
	//if (P != None)
	{
		//log("ServerVote - found player: "$P.PlayerReplicationInfo.PlayerName);
		s_SwatGame(Level.Game).VotePlayerOut(Self, P);
	}

	
}


///////////////////////////////////////
// SetBlindTime
///////////////////////////////////////

simulated function SetBlindTime(float Time)
{
	if ( Level.NetMode != NM_DedicatedServer )
		BlindTime = Time;
}


/*
///////////////////////////////////////
// nextdecal
///////////////////////////////////////

exec function nextdecal() 							// Cycle to the next decal
{
	local DecalGenerator DecalGen;

	foreach AllActors(class'DecalGenerator',DecalGen)
		if ( DecalGen != None && (PlayerPawn(DecalGen.Owner) == Self))
		{
			DecalGen.DecalSelected ++;
			if (DecalGen.DecalSelected > 16)
				DecalGen.DecalSelected = 0;
			break;
		}
}


///////////////////////////////////////
// previousdecal
///////////////////////////////////////

exec function previousdecal() 						// Cycle to the previous decal
{
	local DecalGenerator DecalGen;

	foreach AllActors(class'DecalGenerator',DecalGen)
		if ( DecalGen != None && (PlayerPawn(DecalGen.Owner) == Self))
		{
			DecalGen.DecalSelected --;
			if (DecalGen.DecalSelected < 0)
				DecalGen.DecalSelected = 16;
			break;
		}
}
*/

///////////////////////////////////////
// spraydecal
///////////////////////////////////////

/*exec function s_kSprayPaint() 							// Spray That Decal!
{
	local DecalGenerator DecalGen;

	//log("spray");
	foreach AllActors(class'DecalGenerator',DecalGen)
		if ( DecalGen != None && (PlayerPawn(DecalGen.Owner) == Self))
		{
				//log("spray found");
				PlaySound(Sound'SprayPaint', SLOT_Misc);
		    DecalGen.MakeSplat();
		    break;
		}
}*/

/*
///////////////////////////////////////
// s_kUse
///////////////////////////////////////

exec function s_kUse()
{
	Local		s_NPCHostage		Hostage;

	if (bNotPlaying)
		return;

	// Checking for Triggers
	CheckTrigger();

	// Rescue hostages
	ForEach VisibleActors(class's_NPCHostage', Hostage)
		if ( VSize(Hostage.Location - Location) < 128.0 )
			RescueHostage(Hostage);

}
*/

///////////////////////////////////////
// TraceTarget
///////////////////////////////////////

simulated function bool TraceTarget(out Actor HitTarget, out float Distance)
{
	local vector	HitLocation, HitNormal, StartTrace, EndTrace, extent, lookdir;
	local	float		MaxRange;

	if ( (Weapon != None) && Weapon.IsA('s_Weapon') )
	{
		MaxRange = s_Weapon(Weapon).MaxRange;
		if ( MaxRange < 1000 )
			MaxRange = 1000.0;
	}
	else
		MaxRange = 1000.0;

	StartTrace = Location;
	StartTrace.Z += BaseEyeHeight;
	EndTrace = StartTrace + vector(ViewRotation) * MaxRange;
	HitTarget = Trace(HitLocation, HitNormal, EndTrace, StartTrace, true);

	if ( (HitTarget == None) || (HitTarget == Level) )
	{
		lookDir = vector(Rotation);
		lookDir.Z = 0;
		StartTrace = Location + CollisionRadius * 1.2 * LookDir;
		StartTrace.Z += BaseEyeHeight;
		EndTrace = StartTrace + vector(ViewRotation) * MaxRange;
		extent = Vect(4,4,4); // to make it easier to aim
		HitTarget = Trace(HitLocation, HitNormal, EndTrace, StartTrace, true, extent);

		if ( (HitTarget == None) || (HitTarget == Level) )
			return false;
	}

	Distance = VSize(StartTrace - HitLocation);
	return true;
}


///////////////////////////////////////
// UsePress
///////////////////////////////////////

simulated function UsePress()
{
	Local	s_NPCHostage	Hostage;

	//log("s_Player::UsePress");

	if ( bNotPlaying )
		return;

	Super.UsePress();

	ServerUsePress();
}


///////////////////////////////////////
// ServerUsePress
///////////////////////////////////////

function ServerUsePress()
{
	local	Actor					HitActor;
	local	float					Distance;

	//log("s_Player::ServerUsePress");
	if ( bNotPlaying )
		return;

	if ( TraceTarget(HitActor, Distance) ) 
	{
		//log("s_Player::ServerUsePress - HitActor:"@HitActor@"Distance:"@Distance);

		if ( HitActor.IsA('s_NPCHostage') && (Distance < 128.0) )
		{
			RescueHostage( s_NPCHostage(HitActor) );
			return;
		}
		else if ( HitActor.IsA('TO_ConsoleTimer') )
		{
			//log("s_Player::ServerUsePress - HitActor.IsA('TO_ConsoleTimer')");
			if ( Distance < TO_ConsoleTimer(HitActor).CTRadiusRange )
				ActivateConsoleTimer( TO_ConsoleTimer(HitActor) );
		}
		else if ( HitActor.IsA('s_ExplosiveC4') )
		{
			//log("s_Player::ServerUsePress - HitActor.IsA('s_ExplosiveC4')");
			if ( Distance < s_ExplosiveC4(HitActor).C4RadiusRange )
				ActivateC4( s_ExplosiveC4(HitActor) );
		}
	}

	// Checking for ConsoleTimer
//	if ( CheckConsoleTimer() )
//		return;

	// Checking for Triggers
	if ( CheckTrigger() )
		return;

/*
	// Rescue hostages
	ForEach VisibleActors(class's_NPCHostage', Hostage)
		if ( VSize(Hostage.Location - Location) < 128.0 )
			RescueHostage(Hostage);
*/
}


///////////////////////////////////////
// UseRelease
///////////////////////////////////////

simulated function UseRelease()
{
	//log("s_Player::UseRelease");

	Super.UseRelease();
}


///////////////////////////////////////
// UseReleaseServer
///////////////////////////////////////

function UseReleaseServer(bool Succeed, bool bCheck)
{
}


///////////////////////////////////////
// ActivateConsoleTimer
///////////////////////////////////////

function ActivateConsoleTimer( TO_ConsoleTimer CT )
{
	//log("s_Player::ActivateConsoleTimer - CT:"@CT);

	if ( CT.CTActivate(Self) )
	{	
		CurrentCT = CT;
		//log("s_Player::ActivateConsoleTimer - Calling ClientUseConsoleTimer - CT:"@CT@"CurrentCT:"@CurrentCT);
		ClientUseConsoleTimer( CT.Progress, CT.CTDuration, CT );

		NextState = GetStateName();
		NextLabel = '';
		GotoState('UsingConsoleTimer');
	}
}


///////////////////////////////////////
// ClientUseConsoleTimer
///////////////////////////////////////

simulated function ClientUseConsoleTimer( float BeginActivate, float	duration, TO_ConsoleTimer CT )
{
	//log("s_Player::ClientUseConsoleTimer - CT:"@CurrentCT@"SentCT:"@CT);

	CTUseTime = BeginActivate;
	CTEndTime = duration;
	bUsingCT = true;

	if ( Level.NetMode == NM_Client )
	{
		NextState = GetStateName();
		NextLabel = '';
		GotoState('UsingConsoleTimer');
	}
}


///////////////////////////////////////
// ActivateC4
///////////////////////////////////////

function ActivateC4( s_ExplosiveC4 C4 )
{
	//log("s_Player::ActivateC4");

	if ( C4.C4Activate(Self) )
	{
		CurrentC4 = C4;
		PlayOwnedSound(Sound'TODatas.def_start', Slot_Interact);
		CurrentSoundDuration = GetSoundDuration(Sound'TODatas.def_start');

		ClientUseC4( C4.C4Duration );
		
//		if ( Level.NetMode != NM_StandAlone)
//		{
			NextState = GetStateName();
			NextLabel = '';
			GotoState('UsingC4');
//		}
	}
}


///////////////////////////////////////
// ClientUseC4
///////////////////////////////////////

simulated function ClientUseC4( float	duration )
{
	//log("s_Player::ClientUseC4");

	PlayOwnedSound(Sound'TODatas.def_start', Slot_Interact);
	CurrentSoundDuration = GetSoundDuration(Sound'TODatas.def_start');
	CTUseTime = 0.0;
	CTEndTime = duration;
	bUsingCT = true;

	if ( Level.NetMode == NM_Client )
	{
		NextState = GetStateName();
		NextLabel = '';
		GotoState('UsingC4');
	}
}


///////////////////////////////////////
// CheckTrigger
///////////////////////////////////////

function bool CheckTrigger()
{
	local	s_SWATGame	SG;
	Local	s_Trigger		T;
	local	int					i;

	SG = s_SWATGame(Level.Game);
	if ( SG == None )
		log("s_Player::CheckTriggers - SWATGame not found");
	else if (SG.s_Trigger != None)
	{
		for (T=SG.s_Trigger; T!=None; T=T.NextTrigger)
		{
			//netloop check
			i++;
			if (i > 200)
				break;

			if (T.bUseRadius)
			{
				if ( VSize(Location - T.Location) < T.Radius )
				{
					T.Use(Self);
					//T.PlaySound(Sound'LightSwitch', SLOT_None);
					return true;
				}
			}
			else
			{
				log("s_Player::CheckTriggers - No radius, not supported yet");
			}
		}
	}
	
	return false;
}


///////////////////////////////////////
// s_kNightVision
///////////////////////////////////////

exec function s_kNightVision()
{
	if ( bNotPlaying )
		bNightVision = false;
	else if ( bHasNV && bNightVision )
	{
		ClientPlaySound(Sound'NV_off',, true);
		bNightVision = false;
	}
	else if ( bHasNV )
	{
		ClientPlaySound(Sound'NV_on',, true);
		bNightVision = true;
	}
}


///////////////////////////////////////
// NV_off
///////////////////////////////////////

simulated function NV_off()
{
	//if ( bHasNV && bNightVision )
	//	ClientPlaySound(Sound'NV_off',, true);

	bHasNV = false;
	bNightVision = false;
}


///////////////////////////////////////
// s_kammo
///////////////////////////////////////

exec function s_kammo()
{
	if ( bNotPlaying || (Weapon == None) || !bInBuyZone )
			return;

	BuyAmmo(s_Weapon(Weapon));
}

/*
///////////////////////////////////////
// s_kReload
///////////////////////////////////////

exec function s_kReload()
{
	if ( bNotPlaying || (Weapon == None) )
			return;

	s_ReloadW();
}
*/


///////////////////////////////////////
// TeamRadio
///////////////////////////////////////

function TeamRadio(Sound Radio)
{
/*
	local		s_Player		P;
	local		int					TeamNum;

	TeamNum=PlayerReplicationInfo.Team;

	ForEach AllActors(class's_Player', P)
		if (P.PlayerReplicationInfo.Team==TeamNum)
			P.ClientPlaySound(Radio,, true);
*/
}


///////////////////////////////////////
// s_ChangeTeam
///////////////////////////////////////

simulated function s_ChangeTeam(int num, int team, bool bDie)
{
	local	s_SWATGame SG;
	
	if ( Role == Role_Authority )
	{
		SG = s_SWATGame(Level.Game);
		if ( SG == None )
		{
			Log("s_Player::s_ChangeTeam - Unable to locate game !!!");
			return;
		}

		SG.ChangePModel(self, num, team, bDie);
		SG.ForceSkinUpdate(self);
		
		if ( PlayerReplicationInfo.bWaitingPlayer )
			SG.PlayerJoined(Self);
	}

}

/*
///////////////////////////////////////
// s_ChangeTeamMenu
///////////////////////////////////////

function s_ChangeTeamMenu(int team)
{
	local	s_SWATGame SG;
	
	SG = s_SWATGame(Level.Game);
	if ( SG == None )
	{
		Log("Unable to locate game !!!");
		return;
	}
	
	SG.ChangeTeam(self, team);
}
*/

///////////////////////////////////////
// Escape
///////////////////////////////////////

function Escape()
{
	local	s_SWATGame SG;
	
	SG = s_SWATGame(Level.Game);
	if ( SG == None )
	{
		Log("s_Player::Escape - Unable to locate game !!!");
		return;
	}
	
	SG.Escape(self);
}


///////////////////////////////////////
// EndRound
///////////////////////////////////////

exec function EndRound()
{	
/*	if( !bAdmin || Level.NetMode == NM_Client)
		return;
*/
	ServerEndRound();
}


///////////////////////////////////////
// ServerEndRound
///////////////////////////////////////

function ServerEndRound()
{
	local	s_SWATGame SG;

	if ( !bAdmin && (Level.Netmode != NM_Standalone) )
		return;

	SG = s_SWATGame(Level.Game);
	if ( SG == None )
		return;

	SG.RoundEnded();
	SG.RestartRound();
}


///////////////////////////////////////
// AddMoney
///////////////////////////////////////

function AddMoney( int Amount )
{
	local	s_SWATGame SG;
	
	SG = s_SWATGame(Level.Game);
	if ( SG == None )
		return;

	SG.AddMoney(self, Amount);
}


///////////////////////////////////////
// HUD_Add_Death_Message
///////////////////////////////////////

simulated function	HUD_Add_Death_Message(PlayerReplicationInfo KillerPRI, 
																					PlayerReplicationInfo VictimPRI)
{
	if ( s_HUD(myHUD) != None )
		s_HUD(myHUD).Add_Death_Message(KillerPRI, VictimPRI);
}


///////////////////////////////////////
// HUD_Add_Money_Message
///////////////////////////////////////

simulated function HUD_Add_Money_Message(int Amount)
{
	if ( s_HUD(myHUD) != None )
		s_HUD(Self.myHUD).Add_Money_Message(Amount);
}


///////////////////////////////////////
// BuyWeapon
///////////////////////////////////////

function BuyWeapon(int weaponnum)
{
	local	s_SWATGame SG;

	SG = s_SWATGame(Level.Game);
	if ( SG == None )
		return;

	//log("s_Player::BuyWeapon - Buying weapon:"@class'TOModels.TO_WeaponsHandler'.default.WeaponStr[weaponnum]);
	SG.BuyWeapon(self, weaponnum);
}


///////////////////////////////////////
// BuyAmmo
///////////////////////////////////////

function BuyAmmo(s_Weapon W )
{
	local	s_SWATGame SG;
	
	SG = s_SWATGame(Level.Game);
	if ( SG == None )
		return;

	SG.BuyAmmo(self, W);
}


///////////////////////////////////////
// BuyKnives
///////////////////////////////////////

function BuyKnives()
{
	local	s_SWATGame SG;
	
	SG = s_SWATGame(Level.Game);
	if ( SG == None )
		return;

	SG.BuyKnives(self);
}


///////////////////////////////////////
// HaveMoney
///////////////////////////////////////

function bool HaveMoney(int Amount)
{
	if ( Money < Amount )
		Return false;
	else
		Return true;

}


///////////////////////////////////////
// s_BuyItem
///////////////////////////////////////

function s_BuyItem(byte num)
{
	local	int price;

	PlaySound(Sound'kevlar', SLOT_Misc);

	//if ( !IsInBuyZone() )
	//	return;

	if ( (num == 1) && HaveMoney(350) && (VestCharge < 100) )
	{ // Kevlar
		AddMoney(-350);
		VestCharge = 100;
		CalculateWeight();
	}
	else if ( (num == 2) && HaveMoney(250) && (HelmetCharge < 100))
	{ // Helmet
		AddMoney(-250);
		HelmetCharge = 100;
		CalculateWeight();
	}
	else if ( (num == 3) && HaveMoney(300) && (LegsCharge < 100))
	{ // Legs
		AddMoney(-300);
		LegsCharge = 100;
		CalculateWeight();
	}
	else if ( (num == 4) && HaveMoney(900) && ((VestCharge < 100) || (HelmetCharge < 100) || (LegsCharge < 100)) )
	{ // All
		price=0;
		if ( VestCharge < 100 ) {	price += 350;  VestCharge = 100; }
		if ( HelmetCharge < 100 ) {	price += 250;  HelmetCharge = 100; }
		if ( LegsCharge < 100 ) {	price += 300;  LegsCharge = 100; }
		AddMoney(-price);
		CalculateWeight();
	}
	else if ( (num == 5) && HaveMoney(800) && !bHasNV)
	{ // nightvision
		ClientPlaySound(Sound'Equip_nvg',, true);
		AddMoney(-800);
		bHasNV = true;
	}
}


///////////////////////////////////////
// s_GiveArmor
///////////////////////////////////////

function s_GiveArmor(byte num)
{
	PlaySound(Sound'kevlar', SLOT_Misc);

	if (num==1)
		VestCharge=100;
	else if (num==2)
		HelmetCharge=100;
	else if (num==3)
		LegsCharge=100;
	else if (num==4)
	{
		VestCharge=100;
		HelmetCharge=100;
		LegsCharge=100;
	}
}


///////////////////////////////////////
// TakeDamage
///////////////////////////////////////

function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, name damageType)
{
	local int actualDamage;
	local bool bAlreadyDead;
/*
	if ( instigatedBy != None )
		log("s_Player::TakeDamage - D:"@Damage@"i:"@instigatedBy.GetHumanName()@"DT:"@damagetype);
	else
		log("s_Player::TakeDamage - D:"@Damage@"i: None"@"DT:"@damagetype);
*/
	bAlreadyDead = (Health <= 0);

	if ( s_SWATGame(Level.Game).GamePeriod != GP_RoundPlaying )
		return;

	/*
	if ( !bAlreadyDead && bIsCrouching )
		TOStandUp(false);
	*/

	actualDamage = s_SWATGame(Level.Game).SWATReduceDamage(Damage, DamageType, self, instigatedBy, HitLocation-Location);

	if ( Physics == PHYS_None )
		SetMovementPhysics();

	if ( Physics == PHYS_Walking )
		momentum.Z = FMax(momentum.Z, 0.4 * VSize(momentum));

	if ( instigatedBy == self )
		momentum *= 0.6;
	momentum = momentum/Mass;

	if ( bIsPlayer )
	{
	}
	else if ( (InstigatedBy != None) && (InstigatedBy.IsA(Class.Name) || self.IsA(InstigatedBy.Class.Name)) )
		ActualDamage = ActualDamage * FMin(1 - ReducedDamagePct, 0.35); 
	else if ( (ReducedDamageType == 'All') || ((ReducedDamageType != '') && (ReducedDamageType == damageType)) )
		actualDamage = float(actualDamage) * (1 - ReducedDamagePct);
	
	//if ( Level.Game.DamageMutator != None )
	//	Level.Game.DamageMutator.MutatorTakeDamage( ActualDamage, Self, InstigatedBy, HitLocation, Momentum, DamageType );

	AddVelocity( momentum ); 
	Health -= actualDamage;
	if ( CarriedDecoration != None )
		DropDecoration();

	if ( HitLocation == vect(0,0,0) )
		HitLocation = Location;

	if ( Health > 0 )
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


exec function ViewPlayerNum(optional int num)
{
	local Pawn P;

	if ( !bNotPlaying && !bAdmin )
		return;

	if ( num != -1 )
		num = -1;

	Super.ViewPlayerNum(num);
}


exec function ViewPlayer( string S )
{
	local pawn P;

	if ( !bNotPlaying && !bAdmin )
		return;

	for ( P=Level.pawnList; P!=None; P= P.NextPawn )
		if ( P.bIsPlayer && (P.PlayerReplicationInfo.PlayerName ~= S) )
			break;

	// Disable freecam
	if (!s_GameReplicationInfo(GameReplicationInfo).bAllowGhostCam && (P == Self))
		return;

	if ( (P != None) && Level.Game.CanSpectate(self, P) )
	{
		ClientMessage(ViewingFrom@P.PlayerReplicationInfo.PlayerName, 'Event', true);
		if ( P == self)
			ViewTarget = None;
		else
			ViewTarget = P;
	}
	else
		ClientMessage(FailedView);

	bBehindView = ( ViewTarget != None );
	if ( bBehindView )
		ViewTarget.BecomeViewTarget();
}


exec function ViewSelf()
{
	if ( !s_GameReplicationInfo(GameReplicationInfo).bAllowGhostCam && !bAdmin)
		return;
	//if ( (Level.NetMode != NM_StandAlone) || (bAdmin != true) )
	//	return;

	bBehindView = false;
	Viewtarget = None;
	ClientMessage(ViewingFrom@OwnCamera, 'Event', true);
}


exec function ViewClass( class<actor> aClass, optional bool bQuiet )
{
	local actor other, first, backup;
	local bool bFound;

	if ( !bNotPlaying && !bAdmin )
		return;

	if ( (Level.Game != None) && !Level.Game.bCanViewOthers )
		return;

	first = None;
	backup = None;

	ForEach AllActors( aClass, other )
	{
		if ( (first == None) && (other != self)
			 && ( (bAdmin && Level.Game==None) || Level.Game.CanSpectate(self, other) ) )
		{
			if ( backup == None )
				backup = Other;
			first = other;
			bFound = true;
		}
		if ( other == ViewTarget ) 
			first = None;
	}  

	if ( (First == None) && !s_SWATGame(Level.Game).bAllowGhostCam && bNotPlaying)
		First = backup;

	if ( first != None )
	{
		if ( !bQuiet )
		{
			if ( first.IsA('Pawn') && Pawn(first).bIsPlayer && (Pawn(first).PlayerReplicationInfo.PlayerName != "") )
				ClientMessage(ViewingFrom@Pawn(first).PlayerReplicationInfo.PlayerName, 'Event', true);
			else
				ClientMessage(ViewingFrom@first, 'Event', true);
		}
		ViewTarget = first;
	}
	else
	{
		if ( !bQuiet )
		{
			if ( bFound )
				ClientMessage(ViewingFrom@OwnCamera, 'Event', true);
			else
				ClientMessage(FailedView, 'Event', true);
		}
		ViewTarget = None;
	}

	bBehindView = ( ViewTarget != None );
	if ( bBehindView )
		ViewTarget.BecomeViewTarget();
}


exec function BehindView( Bool B )
{
	if ( !bNotPlaying && !bAdmin )
		return;

	bBehindView = B;
}

/*
simulated event ClientHearSound ( 
	actor Actor, 
	int Id, 
	sound S, 
	vector SoundLocation, 
	vector Parameters 
)
{
	log("s_Player::ClientHearSound - Actor:"@Actor@"Id:"@Id@"Sound:"@S@"SL:"@SoundLocation@"Volume:"@Parameters.x@"Radius:"@Parameters.y@"Pitch:"@Parameters.z);
	Super.ClientHearSound(Actor, Id, S, SoundLocation, Parameters);
}
*/

///////////////////////////////////////
// AdminSet
///////////////////////////////////////

exec function	AdminSet(int val, string S)
{
	local	bool									bVal;
	local s_SWATGame						SG;
	local	s_GameReplicationInfo	GRI;

	if ( Level.NetMode != NM_StandAlone && !bAdmin )
		return;

	SG = s_SWATGame(Level.Game);
	GRI = s_GameReplicationInfo(SG.GameReplicationInfo);
	bVal = bool(val);

	if ( S ~= "allowghostcam" )
	{
		SG.bAllowGhostCam = bVal;
		SG.SaveConfig();
		GRI.bAllowGhostCam = bVal;
		ClientMessage("AllowGhostCam"@bVal, 'Event', true);
	}
	else if ( S ~= "mirrordamage" )
	{
		SG.bMirrorDamage = bVal;
		SG.SaveConfig();
		GRI.bMirrorDamage = bVal;
		ClientMessage("MirrorDamage"@bVal, 'Event', true);
	}
	else if ( S ~= "enableballistics" )
	{
		SG.bEnableBallistics = bVal;
		SG.SaveConfig();
		GRI.bEnableBallistics = bVal;
		ClientMessage("EnableBallistics"@bVal, 'Event', true);
	}
	else if ( S ~= "friendlyfirescale" )
	{
		SG.friendlyfirescale = float(val) / 100.0;
		SG.SaveConfig();
		GRI.friendlyfirescale = val;
		ClientMessage("FriendlyFireScale"@Val, 'Event', true);
	}
	else if ( S ~= "minallowedscore" )
	{
		SG.MinAllowedScore = Max(val, 0);
		SG.SaveConfig();
		ClientMessage("MinAllowedScore"@SG.MinAllowedScore, 'Event', true);
	}
	else
	{
		ClientMessage("- AdminSet", 'Event', true);
		ClientMessage("AllowGhostCam    "@GRI.bAllowGhostCam, 'Event', true);
		ClientMessage("MirrorDamage     "@GRI.bMirrorDamage, 'Event', true);
		ClientMessage("EnableBallistics "@GRI.bEnableBallistics, 'Event', true);
		ClientMessage("FriendlyFireScale"@GRI.FriendlyFireScale, 'Event', true);
		ClientMessage("MinAllowedScore  "@SG.MinAllowedScore, 'Event', true);
	}
}


///////////////////////////////////////
// AdminReset
///////////////////////////////////////

exec function	AdminReset()
{
	if ( Level.NetMode != NM_StandAlone && !bAdmin )
		return;

	s_SWATGame(Level.Game).TOResetGame();
}

simulated function ResetTime(float nrt)
{
	local	s_GameReplicationInfo	GRI;

	//log("s_Player::ResetTime");
	GRI = s_GameReplicationInfo(GameReplicationInfo);
	if ( GRI != None )
	{
		GRI.RemainingTime = nrt;
		GRI.RemainingMinute = 0;
		GRI.ElapsedTime = 0;
	}
}

///////////////////////////////////////
// PlayerSpectating
///////////////////////////////////////

state PlayerSpectating
{
	ignores SeePlayer, HearNoise, Bump, TakeDamage, Died, ZoneChange, FootZoneChange;

	function ChangeTeam( int N ) { }

	exec function Fire( optional float F )
	{
		local	bool	b1;

		if ( Role == ROLE_Authority )
		{
			ViewPlayerNum(-1);
			if ( (ViewTarget != None) && (Pawn(ViewTarget) != None) )
			{
				bBehindView = bBackupBehindView;
			}
			else
				bBehindView = false;
		}
	} 


	exec function AltFire( optional float F )
	{
		if ( (ViewTarget != None) && (Pawn(ViewTarget) != None) )
			bBackupBehindView = !bBackupBehindView;
		else
			bBackupBehindView = false;

		bBehindView = bBackupBehindView;
	}


	function PlayerMove(float DeltaTime)
	{
		local rotator newRotation;
		local vector X,Y,Z;

		GetAxes(ViewRotation,X,Y,Z);

		aForward *= 0.08;
		aStrafe  *= 0.08;
		aLookup  *= 0.12;
		aTurn    *= 0.12;
		aUp		 *= 0.025;
	
		Acceleration = aForward*X + aStrafe*Y + aUp*vect(0,0,1);  

		UpdateRotation(DeltaTime, 1);

		if ( Role < ROLE_Authority ) // then save this move and replicate it
			ReplicateMove(DeltaTime, Acceleration, DODGE_None, rot(0,0,0));
		else
			ProcessMove(DeltaTime, Acceleration, DODGE_None, rot(0,0,0));
	}

	exec function Say(string Msg)
	{
		local Pawn P;

		if ( bAdmin && (left(Msg,1) == "#") )
		{
			Msg = right(Msg,len(Msg)-1);
			for( P=Level.PawnList; P!=None; P=P.nextPawn )
				if( P.IsA('PlayerPawn') )
				{
					PlayerPawn(P).ClearProgressMessages();
					PlayerPawn(P).SetProgressTime(6);
					PlayerPawn(P).SetProgressMessage(Msg,0);
				}
			return;
		}

		if ( Level.Game.AllowsBroadcast(self, Len(Msg)) )
		{
			for( P=Level.PawnList; P!=None; P=P.nextPawn )
			{
				if ( P.bIsPlayer && P.PlayerReplicationInfo.bIsSpectator )
				{
					//log("s_player::spectating::say - spect:"@P.PlayerReplicationInfo.bIsSpectator@"-admin:"@bAdmin);
					if ( Level.Game.MessageMutator != None )
					{
						if ( Level.Game.MessageMutator.MutatorTeamMessage(Self, P, PlayerReplicationInfo, Msg, 'Say', true) )
							P.TeamMessage( PlayerReplicationInfo, Msg, 'Say', true );
					} 
					else
						P.TeamMessage( PlayerReplicationInfo, Msg, 'Say', true );
				}
			}	
		}
	}


	exec function TeamSay( string Msg )
	{
		local Pawn P;

		if ( !Level.Game.bTeamGame )
		{
			Say(Msg);
			return;
		}

		if ( Msg ~= "Help" )
		{
			CallForHelp();
			return;
		}
			
		if ( Level.Game.AllowsBroadcast(self, Len(Msg)) )
			for ( P=Level.PawnList; P!=None; P=P.nextPawn )
				if ( P.bIsPlayer && (P.PlayerReplicationInfo.Team == PlayerReplicationInfo.Team) )
				{
					if ( bAdmin || P.PlayerReplicationInfo.bIsSpectator )
					{
						if ( Level.Game.MessageMutator != None )
						{
							if ( Level.Game.MessageMutator.MutatorTeamMessage(Self, P, PlayerReplicationInfo, Msg, 'Say', true) )
								P.TeamMessage( PlayerReplicationInfo, Msg, 'TeamSay', true );
						} 
						else
							P.TeamMessage( PlayerReplicationInfo, Msg, 'TeamSay', true );
					}
				}
	}


	function EndState()
	{
		//log("s_Player::PlayerSpectating::EndState");
		PlayerReplicationInfo.bIsSpectator = false;
		PlayerReplicationInfo.bWaitingPlayer = false;
		SetMesh();
		SetCollision(true,true,true);
		SetCollisionSize(Default.CollisionRadius, Default.CollisionHeight);
		bNotPlaying = false;
		EyeHeight = Default.BaseEyeHeight;
		BaseEyeHeight = Default.BaseEyeHeight;

		if ( Role == Role_Authority )
		{
			bAlwaysRelevant = true;
			AirSpeed = 400.0;
			bBehindView = false;
			Viewtarget = None;			
			if ( bAdmin )
				ViewSelf();
		}
	}

	function BeginState()
	{
		//log("s_Player::PlayerSpectating::BeginState");
		if ( Level.NetMode != NM_DedicatedServer )
		{
			if ( bSZoom )
				ToggleSZoom();
		}

		PlayerReplicationInfo.bIsSpectator = true;
		PlayerReplicationInfo.bWaitingPlayer = false;
		bNotPlaying = true;
		Mesh = None;
		SetCollisionSize(4, 4);
		SetCollision(false,false,false);
		EyeHeight = 0;
		BaseEyeHeight = 0;
		SetPhysics(PHYS_None);

		if ( Role == Role_Authority )
		{
			bAlwaysRelevant = false;
			bFire = 0;
			AirSpeed = 200.0;

			if ( !s_GameReplicationInfo(GameReplicationInfo).bAllowGhostCam )
				ViewPlayerNum(-1);

			if ( (ViewTarget != None) && (Pawn(ViewTarget) != None) )
				bBehindView = true;
			else
				bBehindView = false;
			bBackupBehindView = true;
		}
	}
}


///////////////////////////////////////
// PlayerWaiting
///////////////////////////////////////

state PlayerWaiting
{
ignores SeePlayer, HearNoise, Bump, TakeDamage, Died, ZoneChange, FootZoneChange;

	function ChangeTeam( int N ) { }

	exec function Jump( optional float F )	{	}

	exec function Suicide() {	}

	exec function Fire(optional float F) {	}
	
	exec function AltFire(optional float F) {	}

	function ProcessMove(float DeltaTime, vector NewAccel, eDodgeDir DodgeMove, rotator DeltaRot)	
	{
		Acceleration = Normal(NewAccel);
		Velocity = Normal(NewAccel) * 100;
		AutonomousPhysics(DeltaTime);
	}

	function PlayWaiting() {}

	event PlayerTick( float DeltaTime )
	{
		if ( bUpdatePosition )
			ClientUpdatePosition();

		PlayerMove(DeltaTime);
	}

	function PlayerMove(float DeltaTime)
	{
		local rotator newRotation;
		local vector X,Y,Z;

		GetAxes(ViewRotation,X,Y,Z);

		aForward *= 0.1;
		aStrafe  *= 0.1;
		aLookup  *= 0.24;
		aTurn    *= 0.24;
		aUp		 *= 0.1;
	
		Acceleration = aForward*X + aStrafe*Y + aUp*vect(0,0,1);  

		UpdateRotation(DeltaTime, 1);

		if ( Role < ROLE_Authority ) // then save this move and replicate it
			ReplicateMove(DeltaTime, Acceleration, DODGE_None, rot(0,0,0));
		else
			ProcessMove(DeltaTime, Acceleration, DODGE_None, rot(0,0,0));
	}

	function EndState()
	{
		//log("s_Player::PlayerWaiting::EndState");

		bAlwaysRelevant = true;

		SetMesh();
		PlayerReplicationInfo.bIsSpectator = false;
		PlayerReplicationInfo.bWaitingPlayer = false;
		bNotPlaying = false;
		SetCollision(true,true,true);
	}

	function BeginState()
	{
		//log("s_Player::PlayerWaiting::BeginState");

		bAlwaysRelevant = false;

		Mesh = None;
		if ( PlayerReplicationInfo != None )
		{
			PlayerReplicationInfo.bIsSpectator = false;
			PlayerReplicationInfo.bWaitingPlayer = true;
		}

		bNotPlaying = true;
		SetCollision(false,false,false);
		EyeHeight = BaseEyeHeight;
		SetPhysics(PHYS_None);
	}
}


simulated function SetMesh()
{
	//mesh = default.mesh;
	Mesh = class'TOPModels.TO_ModelHandler'.default.ModelMesh[PlayerModel];
}

function ServerChangeSkin( coerce string SkinName, coerce string FaceName, byte TeamNum )
{
}


///////////////////////////////////////
// SetMultiSkin
///////////////////////////////////////

static function SetMultiSkin(Actor SkinActor, string SkinName, string FaceName, byte TeamNum)
{
/*	local string MeshName, FacePackage, SkinItem, FaceItem, SkinPackage;

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


///////////////////////////////////////
// SetSkinElement 
///////////////////////////////////////
// Disable Skin cheat since UT 425+
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
		return true;
	}
	else
	{
/*		log("Failed to load "$SkinName$" so load "$DefaultSkinName);
		if(DefaultSkinName != "")
		{
			NewSkin = Texture(DynamicLoadObject(DefaultSkinName, class'Texture'));
			SkinActor.Multiskins[SkinNo] = NewSkin;
		}*/
		return false;
	}
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
	if ( (DamageType == 'Decapitated') && !class'GameInfo'.Default.bVeryLowGore )
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
		
	if ( (HitLoc.Z - Location.Z > 0.7 * CollisionHeight) && !class'GameInfo'.Default.bVeryLowGore )
	{
		if ( FRand() < 0.5 )
			PlayDecap();
		else
			PlayAnim('Dead4',, 0.1);
		return;
	}
	
	if ( Region.Zone.bWaterZone || (FRand() < 0.5) ) //then hit in front or back
		PlayAnim('Dead3',, 0.1);
	else
		PlayAnim('Dead8',, 0.1);
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


///////////////////////////////////////
// CalcBehindView
///////////////////////////////////////

function CalcBehindView(out vector CameraLocation, out rotator CameraRotation, float Dist)
{
	local vector View,HitLocation,HitNormal;
	local float ViewDist;

	Dist = FMax(0.0, Dist/* - BehindViewDist*/);

	CameraRotation = ViewRotation;
	View = vect(1,0,0) >> CameraRotation;
	if( Trace( HitLocation, HitNormal, CameraLocation - (Dist + 30) * vector(CameraRotation), CameraLocation ) != None )
		ViewDist = FMin( (CameraLocation - HitLocation) Dot View, Dist );
	else
		ViewDist = Dist;
//	if (bDuck != 0)
		CameraLocation -= (ViewDist - 30) * View /*+ Vect(0, 0, 1) * BehindViewHeight*/; 
//	else
//		CameraLocation -= (ViewDist - 30) * View; 
}


///////////////////////////////////////
// RescueHostage
///////////////////////////////////////

function RescueHostage(s_NPCHostage Hostage)
{
	if ( (VSize(Hostage.location - Location) > 256.0) || (Hostage.Health < 1) )
		return;

	if (Hostage.bIsFree)
	{
		Hostage.bIsFree = false;
		Hostage.Followed = None;
		Hostage.OrderObject = None;
		Hostage.GotoState('Waiting');
	}
	else
	{
		Hostage.bIsFree = true;
		Hostage.Followed = self;
		Hostage.SetOrders('follow', self);
		Hostage.GotoState('Roaming');
	}

	if (PlayerReplicationInfo.Team == 1)
	{
		if (Hostage.bIsFree == true)
		{
			Hostage.PlayRescueEscort();
			ReceiveLocalizedMessage(class's_SpecialMessages', 1);
		}
		else
		{
			Hostage.PlayRescueLock();
			ReceiveLocalizedMessage(class's_SpecialMessages', 2);
		}
	}
	else
	{
		if (Hostage.bIsFree == true)
		{
			Hostage.PlayThreatEscort();
			ReceiveLocalizedMessage(class's_SpecialMessages', 4);
		}
		else
		{
			Hostage.PlayThreatLock();
			ReceiveLocalizedMessage(class's_SpecialMessages', 3);
		}
	}

}


///////////////////////////////////////
// HandleWalking
///////////////////////////////////////

function HandleWalking()
{
	local rotator carried;

	// FIX crouch bug !!
	//bIsWalking = ((bRun != 0) || (bDuck != 0)) && !Region.Zone.IsA('WarpZoneInfo'); 
	bIsWalking = ((bRun != 0)) && !Region.Zone.IsA('WarpZoneInfo'); 
	if ( CarriedDecoration != None )
	{
		if ( (Role == ROLE_Authority) && (standingcount == 0) ) 
			CarriedDecoration = None;
		if ( CarriedDecoration != None ) //verify its still in front
		{
			bIsWalking = true;
			if ( Role == ROLE_Authority )
			{
				carried = Rotator(CarriedDecoration.Location - Location);
				carried.Yaw = ((carried.Yaw & 65535) - (Rotation.Yaw & 65535)) & 65535;
				if ( (carried.Yaw > 3072) && (carried.Yaw < 62463) )
					DropDecoration();
			}
		}
	}
}


///////////////////////////////////////
// TOCrouch
///////////////////////////////////////

function TOCrouch()
{
	bIsCrouching = true;
	SetCollisionSize(CollisionRadius, CrouchHeight);
	//CrouchZ = Default.CollisionHeight - CrouchHeight;
	// ?!
	//temp = vect(0, 0, 1) * CrouchZ;
	//SetLocation(location + temp);
	
	PlayDuck();
	CalculateWeight();
}

///////////////////////////////////////
// TOStandUp
///////////////////////////////////////

function bool TOStandUp( bool bForce )
{
	local	vector	OldLocation, temp;
	local	float		CrouchZ;

	// Checking if Player can stand up
	OldLocation = Location;
	SetCollisionSize(CollisionRadius, Default.CollisionHeight);
			
	CrouchZ = Default.CollisionHeight - CrouchHeight;
	temp = vect(0, 0, 1) * CrouchZ;
			
	// Test if we can standup
	if ( SetLocation(location + temp) )
	{
		// Can stand up
		SetCollisionSize(CollisionRadius, Default.CollisionHeight);
		SetLocation(Oldlocation);
		bCantStandUp = false;
		bDuck = 0;
		bIsCrouching = false;

		// player dead?
		if ( health > 0 )
		{
			TweenToRunning(0.1);
			CalculateWeight();
		}
		return true;
	}
	else if ( !bForce )
	{
		// Can't stand up
		SetCollisionSize(CollisionRadius, CrouchHeight);
		//CrouchZ = Default.CollisionHeight - CrouchHeight;
		//temp = vect(0, 0, 1) * CrouchZ;
		//SetLocation(location + temp);
		SetLocation(OldLocation);
		bDuck = 1;
		bCantStandUp = true;
		return false;
	}
}


///////////////////////////////////////
// PlayerWalking
///////////////////////////////////////

state PlayerWalking
{
ignores SeePlayer, HearNoise, Bump;

	exec function FeignDeath() {}

	function ProcessMove(float DeltaTime, vector NewAccel, eDodgeDir DodgeMove, rotator DeltaRot)	
	{
		local vector	OldAccel;
		//local vector	OldLocation, temp;
		//local	int			CrouchZ;

		OldAccel = Acceleration;
		Acceleration = NewAccel;
		bIsTurning = ( Abs(DeltaRot.Yaw/DeltaTime) > 5000 );

		if ( (DodgeMove == DODGE_Active) && (Physics == PHYS_Falling) )
			DodgeDir = DODGE_Active;	
		else if ( (DodgeMove != DODGE_None) && (DodgeMove < DODGE_Active) )
			Dodge(DodgeMove);

		if ( bPressedJump )
			DoJump();

		if ( (Physics == PHYS_Walking) && (GetAnimGroup(AnimSequence) != 'Dodge') )
		{
			if ( !bIsCrouching )
			{
				if ( bDuck != 0 )
					TOCrouch();
			}
			else if ( (bDuck == 0) || (bCantStandUp) )
			{
				if ( TOStandUp(false) )
					OldAccel = vect(0,0,0);
				/*
				// Checking if Player can stand up
				Oldlocation = location;
				SetCollisionSize(CollisionRadius, Default.CollisionHeight);
				
				CrouchZ = Default.CollisionHeight - CrouchHeight;
				temp = vect(0, 0, 1) * CrouchZ;
				
				//if ( SetLocation(location + vect(0,0,3 )) )
				if ( SetLocation(location + temp) )
				{
					// Can stand up
					SetCollisionSize(CollisionRadius, Default.CollisionHeight);
					SetLocation(Oldlocation);
					bCantStandUp = false;
					bDuck = 0;
					OldAccel = vect(0,0,0);
					bIsCrouching = false;
					TweenToRunning(0.1);
					CalculateWeight();
				}
				else
				{
					// Can't stand up
					SetCollisionSize(CollisionRadius, CrouchHeight);
					CrouchZ = Default.CollisionHeight - CrouchHeight;
					temp = vect(0, 0, 1) * CrouchZ;
					SetLocation(location + temp);
					//SetLocation(Oldlocation);
					bDuck = 1;
					bCantStandUp = true;
				}
				*/
			}

			if ( !bIsCrouching )
			{
				if ( (!bAnimTransition || (AnimFrame > 0)) && (GetAnimGroup(AnimSequence) != 'Landing') )
				{
					if ( Acceleration != vect(0,0,0) )
					{
						if ( (GetAnimGroup(AnimSequence) == 'Waiting') || (GetAnimGroup(AnimSequence) == 'Gesture') || (GetAnimGroup(AnimSequence) == 'TakeHit') )
						{
							bAnimTransition = true;
							TweenToRunning(0.1);
						}
					}
			 		else if ( (Velocity.X * Velocity.X + Velocity.Y * Velocity.Y < 1000) 
						&& (GetAnimGroup(AnimSequence) != 'Gesture') ) 
			 		{
			 			if ( GetAnimGroup(AnimSequence) == 'Waiting' )
			 			{
							if ( bIsTurning && (AnimFrame >= 0) ) 
							{
								bAnimTransition = true;
								PlayTurning();
							}
						}
			 			else if ( !bIsTurning ) 
						{
							bAnimTransition = true;
							TweenToWaiting(0.2);
						}
					}
				}
			}
			else
			{
				if ( (OldAccel == vect(0,0,0)) && (Acceleration != vect(0,0,0)) )
					PlayCrawling();
			 	else if ( !bIsTurning && (Acceleration == vect(0,0,0)) && (AnimFrame > 0.1) )
					PlayDuck();
			}
		}
	}

	function BeginState()
	{
		if ( Mesh == None )
			SetMesh();

		WalkBob = vect(0,0,0);
		DodgeDir = DODGE_None;
		bIsCrouching = false;
		CalculateWeight();
		bIsTurning = false;
		bPressedJump = false;

		if ( Physics != PHYS_Falling ) 
			SetPhysics(PHYS_Falling);

		if ( !IsAnimating() )
			PlayWaiting();
	}

	function EndState()
	{
		TOStandUp(true);
		WalkBob = vect(0,0,0);
		bIsCrouching = false;
	}
}


///////////////////////////////////////
// PlayerSwimming
///////////////////////////////////////

state PlayerSwimming
{
ignores SeePlayer, HearNoise, Bump;

	function BeginState()
	{
		Disable('Timer');
		if ( !IsAnimating() )
			TweenToWaiting(0.3);
		
		if ( bIsCrouching )
			TOStandUp(true);
		//bIsCrouching = false;
		CalculateWeight();
		//log("player swimming");
	}
}


///////////////////////////////////////
// Dying
///////////////////////////////////////

state Dying
{
	ignores SeePlayer, HearNoise, KilledBy, Bump, HitWall, HeadZoneChange, FootZoneChange, ZoneChange, SwitchWeapon, Falling, PainTimer;

	event PlayerTick( float DeltaTime )
	{
		ViewShake(DeltaTime);
		ViewFlash(DeltaTime);
		Super.PlayerTick(DeltaTime);
	}

	function Timer()
	{
		bFrozen = false;
		bPressedJump = false;
		GotoState('PlayerSpectating');
	}

	exec function Say(string Msg)
	{
		local Pawn P;

		if ( bAdmin && (left(Msg,1) == "#") )
		{
			Msg = right(Msg,len(Msg)-1);
			for( P=Level.PawnList; P!=None; P=P.nextPawn )
				if( P.IsA('PlayerPawn') )
				{
					PlayerPawn(P).ClearProgressMessages();
					PlayerPawn(P).SetProgressTime(6);
					PlayerPawn(P).SetProgressMessage(Msg,0);
				}
			return;
		}

		if ( Level.Game.AllowsBroadcast(self, Len(Msg)) )
		{
			for( P=Level.PawnList; P!=None; P=P.nextPawn )
			{
				if ( P.bIsPlayer && P.PlayerReplicationInfo.bIsSpectator )
				{
					//log("s_player::spectating::say - spect:"@P.PlayerReplicationInfo.bIsSpectator@"-admin:"@bAdmin);
					if ( Level.Game.MessageMutator != None )
					{
						if ( Level.Game.MessageMutator.MutatorTeamMessage(Self, P, PlayerReplicationInfo, Msg, 'Say', true) )
							P.TeamMessage( PlayerReplicationInfo, Msg, 'Say', true );
					} 
					else
						P.TeamMessage( PlayerReplicationInfo, Msg, 'Say', true );
				}
			}	
		}
	}


	exec function TeamSay( string Msg )
	{
		local Pawn P;

		if ( !Level.Game.bTeamGame )
		{
			Say(Msg);
			return;
		}

		if ( Msg ~= "Help" )
		{
			CallForHelp();
			return;
		}
			
		if ( Level.Game.AllowsBroadcast(self, Len(Msg)) )
			for ( P=Level.PawnList; P!=None; P=P.nextPawn )
				if ( P.bIsPlayer && (P.PlayerReplicationInfo.Team == PlayerReplicationInfo.Team) )
				{
					if ( bAdmin || P.PlayerReplicationInfo.bIsSpectator )
					{
						if ( Level.Game.MessageMutator != None )
						{
							if ( Level.Game.MessageMutator.MutatorTeamMessage(Self, P, PlayerReplicationInfo, Msg, 'Say', true) )
								P.TeamMessage( PlayerReplicationInfo, Msg, 'TeamSay', true );
						} 
						else
							P.TeamMessage( PlayerReplicationInfo, Msg, 'TeamSay', true );
					}
				}
	}

	exec function Fire( optional float F ) { }
	
	exec function AltFire( optional float F )	{	}

	function BeginState()
	{
		Super.BeginState();
		bFrozen = false;
		bAlwaysRelevant = false;
		bNotPlaying = true;
		PlayerReplicationInfo.bIsSpectator = true;
		SetTimer(3.0, false);
	}

	function EndState()
	{
		Super.EndState();
		bAlwaysRelevant = true;
		bNotPlaying = false;
		//PlayerReplicationInfo.bIsSpectator = false;
		bBehindView = false;
	}
}


///////////////////////////////////////
// Climbing
///////////////////////////////////////

state Climbing
{
ignores SeePlayer, HearNoise, Bump;
		
	function AnimEnd()
	{
		local name MyAnimGroup;
		/*
		//PlayWalking();
		if ( VSize(Velocity) != 0 )
			PlayWalking();
		else
			PlayWaiting();
		*/			
		bAnimTransition = false;
		MyAnimGroup = GetAnimGroup(AnimSequence);
		if ( VSize(Velocity) == 0 )
		{
			if ( MyAnimGroup == 'Waiting' )
				PlayWaiting();
			else
			{
				bAnimTransition = true;
				TweenToWaiting(0.2);
			}
		}	
		else
		{
			if ( (MyAnimGroup == 'Waiting') || (MyAnimGroup == 'Gesture') || (MyAnimGroup == 'TakeHit')  )
			{
				TweenToWalking(0.1);
				bAnimTransition = true;
			}
			else 
				PlayWalking();
		}
	}

	function ProcessMove(float DeltaTime, vector NewAccel, eDodgeDir DodgeMove, rotator DeltaRot)	
	{
		Acceleration = Normal(NewAccel);
		Velocity = Normal(NewAccel) * 100;
		AutonomousPhysics(DeltaTime);

		//Acceleration = NewAccel;
		//MoveSmooth(Acceleration * DeltaTime);
		//AutonomousPhysics(DeltaTime);
	}

	event PlayerTick( float DeltaTime )
	{
		if ( bDoRecoil )
		{
			bDoRecoil = false;
			if ( (Weapon != None) && (s_Weapon(Weapon) != None) )
				s_Weapon(Weapon).Recoil();
		}

		if ( bUpdatePosition )
				ClientUpdatePosition();

		// CenterView cheat hack
		bCenterView = false;

		PlayerMove(DeltaTime);

		if ( (VSize(Acceleration) == 0) && (GetAnimGroup(AnimSequence) != 'Waiting') )
			PlayWaiting();
	}

	function PlayerMove(float DeltaTime)
	{
		local rotator newRotation;
		local vector X,Y,Z;

		if ( Abs(OldLadderZ - Location.Z) > 72 )
		{
			PlayLadderSound();
			OldLadderZ = Location.Z;
		}

		GetAxes(ViewRotation,X,Y,Z);

		aForward *= 0.01;
		aStrafe  *= 0.01;
		aLookup  *= 0.24;
		aTurn    *= 0.24;
		aUp			 *= 0.01;
	
		Acceleration = aForward*X + aStrafe*Y + aUp*vect(0,0,1);  

		UpdateRotation(DeltaTime, 1);

		if ( Role < ROLE_Authority ) // then save this move and replicate it
			ReplicateMove(DeltaTime, Acceleration, DODGE_None, rot(0,0,0));
		else
			ProcessMove(DeltaTime, Acceleration, DODGE_None, rot(0,0,0));
	}
	
	function BeginState()
	{
		if ( bIsCrouching )
			TOStandUp(true);
		EyeHeight = BaseEyeHeight;
		OldLadderZ = Location.Z;
		SetPhysics(PHYS_Flying);
		if  ( !IsAnimating() ) 
			PlayWalking();
		bCanFly = true;
	}

	function EndState()
	{
		if ( bIsCrouching )
			TOStandUp(true);
		bCanFly = false;
		if ( Region.Zone.bWaterZone )
		{
			SetPhysics(PHYS_Swimming);
			GotoState('PlayerSwimming');
		}
		else
			SetPhysics(PHYS_falling);
	}
}


///////////////////////////////////////
// PreRound
///////////////////////////////////////

state PreRound
{
//ignores SeePlayer;
ignores SeePlayer, AnimEnd, TakeDamage; 

	exec function AltFire( optional float F )	{ bAltFire = 0; }

	exec function Fire( optional float F )	{ bFire = 0; } 

	event PlayerTick( float DeltaTime )
	{
		ViewShake(DeltaTime);
		ViewFlash(DeltaTime);

		if ( bUpdatePosition )
			ClientUpdatePosition();

		PlayerMove(DeltaTime);
	}

	function PlayerMove( float DeltaTime )
	{
		if ( Role < ROLE_Authority ) // then save this move and replicate it
			ReplicateMove(DeltaTime, vect(0,0,0), Dodge_None, rot(0,0,0));
	}

	function ReplicateMove(float DeltaTime, vector NewAccel, eDodgeDir DodgeMove, rotator DeltaRot)
	{
		NewAccel = vect(0,0,0);
		DodgeMove = Dodge_None;
		DeltaRot = rot(0,0,0);
		Global.ReplicateMove(DeltaTime, NewAccel, DodgeMove, DeltaRot);
	}

	simulated function BeginState()
	{
		PlayWaiting();

		//s_GameReplicationInfo(GameReplicationInfo).bPreRound = true;
		if ( bSZoom )
			ToggleSZoom();
		
		bBehindView = false;
		Viewtarget = None;		

		//bSZoom = false;
		//DesiredFOV = 90.0000;
		//FOVAngle = DesiredFOV;
		//DefaultFOV = DesiredFOV;

		if ( Role == Role_Authority )
		{
			SetPhysics(Phys_Falling);
			Acceleration = vect(0,0,0);
			bFire = 0;
			bAltFire = 0;
		}

		// Reset weapon
		if ( (Weapon != None) && Weapon.IsA('s_Weapon') && !s_Weapon(Weapon).bReloadingWeapon )
		{
			if ( Role == Role_Authority )
			{
				if ( Weapon.GetStateName() != 'idle' )
					Weapon.finish();
			}
			else if ( Weapon.GetStateName() != '' )
			{
				Weapon.PlayIdleAnim();
				Weapon.GotoState('');
			}
		}
		else if ( (Role == Role_Authority) && (Weapon == None) )
			SwitchToBestWeapon();

		//if (PZone != None)
		//	PZone.PostBeginPlay();
		//ClientPreRound();
	}

	simulated function EndState()
	{
		//s_GameReplicationInfo(GameReplicationInfo).bPreRound = false;
		if ( Role == Role_Authority )
			SetPhysics(Phys_Walking);

		bBehindView = false;
		Viewtarget = None;		
		//bSZoom = false;
		//DesiredFOV = 90.0000;
		//FOVAngle = DesiredFOV;
		//DefaultFOV = DesiredFOV;
	}

Begin:
	if ( Role == Role_Authority )
	{
		//bBehindView = false;
		//ViewTarget = None;
		bFire = 0;
		bAltFire = 0;
	//	if (Weapon != None && !s_Weapon(Weapon).IsInState('ReloadWeapon') )
	//		Weapon.finish();
		SetPhysics(Phys_Falling);
		Acceleration = vect(0,0,0);
	/*	TweenToFighter(0.2);
		FinishAnim();
		PlayTurning();
		TurnToward(Target);
		DesiredRotation = rot(0,0,0);
		DesiredRotation.Yaw = Rotation.Yaw;
		setRotation(DesiredRotation);
		TweenToFighter(0.2);
		FinishAnim();
	*/
		//Log("BotBuying - Entered");
		Disable('AnimEnd');
		Velocity *= 0.0;
		/*
		Objective = "";
		Enable('AnimEnd');
		GotoState('Roaming');*/
	}	
	PlayWaiting();
}


///////////////////////////////////////
// UsingConsoleTimer
///////////////////////////////////////

state UsingConsoleTimer
{
ignores SeePlayer, AnimEnd; 

	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, name damageType)
	{
		//log("s_Player::UsingConsoleTimer::TakeDamage");

		Global.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);

		ClientRoundEnded();
		UseReleaseServer(false, false);
		bUsingCT = false;
//		GotoState('PlayerWalking');
	}

	function RoundEnded()
	{
		//log("s_Player::UsingConsoleTimer::RoundEnded");

		if ( bUsingCT )
		{
			bUsingCT = false;
			UseReleaseServer(false, false);
		}

		Global.RoundEnded();
	}

	simulated function ClientRoundEnded()
	{
		//log("s_Player::UsingConsoleTimer::ClientRoundEnded");
		s_HUD(myHUD).DrawConsoleTimerHUD( true, false, 0.0 );
		bUsingCT = false;

//		if ( Level.NetMode != NM_StandAlone )
		if ( Role < Role_Authority )
		{
			if ( NextState == 'PlayerSwimming' )
				setPhysics(PHYS_Swimming);
			GotoState(NextState);
		}

		Global.ClientRoundEnded();
	}

	exec function AltFire( optional float F )	{ bAltFire = 0; }

	exec function Fire( optional float F )	{ bFire = 0; } 

	event PlayerTick( float DeltaTime )
	{
		ViewShake(DeltaTime);
		ViewFlash(DeltaTime);

		if ( bUpdatePosition )
			ClientUpdatePosition();

		PlayerMove(DeltaTime);

		if ( !bUsingCT )
			return;

		CTUseTime += DeltaTime;

		if ( CTUseTime > CTEndTime )
		{
			ClientRoundEnded();
			UseReleaseServer(true, true);
		}
		else
			s_HUD(myHUD).DrawConsoleTimerHUD( true, true, CTUseTime / CTEndTime );
	}

	function PlayerMove( float DeltaTime )
	{
		if ( Role < ROLE_Authority ) // then save this move and replicate it
			ReplicateMove(DeltaTime, vect(0,0,0), Dodge_None, rot(0,0,0));
	}

	simulated function UseRelease()
	{
		//log("s_Player::UsingConsoleTimer::UseRelease");

		Super.UseRelease();
		
		ClientRoundEnded();
		UseReleaseServer(false, true);
	}

	function UseReleaseServer(bool bSucceed, bool bCheck)
	{
		//log("s_Player::UsingConsoleTimer::UseReleaseServer");

		if ( CurrentCT != None )
		{
			if ( bSucceed )
				CurrentCT.CTComplete();
			else
				CurrentCT.CTFailed();
		}
		else
			log("s_Player::UsingConsoleTimer::UseReleaseServer - CurrentCT == None");

		if ( bCheck )
		{
			//log("s_Player::UsingConsoleTimer::UseReleaseServer - Resetting player state and physics");
			if ( NextState == 'PlayerSwimming' )
				setPhysics(PHYS_Swimming);
			GotoState(NextState);
		}
	}

	function BeginState()
	{
		//log("s_Player::UsingConsoleTimer::BeginState");

		SetPhysics(Phys_None);
		Acceleration = vect(0,0,0);
		bFire = 0;
		bAltFire = 0;
		if ( (Role == Role_Authority) && (s_Weapon(Weapon) != None) && !s_Weapon(Weapon).bReloadingWeapon )
			Weapon.GotoState('idle');	
	}

	function EndState()
	{
		//log("s_Player::UsingConsoleTimer::Endstate");

		// If exit state anormally (ie end of round)
		if ( Level.NetMode != NM_DedicatedServer )
		{
			if ( bUsingCT )
			{
				s_HUD(myHUD).DrawConsoleTimerHUD( true, false, 0.0 );
				bUsingCT = false;
				if ( Health > 0 )
				{
					if ( NextState == 'PlayerSwimming' )
						setPhysics(PHYS_Swimming);
					GotoState(NextState);
				}
			}
		}

		if ( Role == Role_Authority )
		{
			if ( CurrentCT != None && CurrentCT.bBeingActivated )
			{
				CurrentCT.CTFailed();
				if ( Health > 0 )
				{
					if ( NextState == 'PlayerSwimming' )
						setPhysics(PHYS_Swimming);
					GotoState(NextState);
				}
			}
		}
	}

Begin:

	//log("s_Player::UsingConsoleTimer::Begin");

	bFire = 0;
	bAltFire = 0;
	if (Weapon != None && !s_Weapon(Weapon).IsInState('ReloadWeapon') )
		Weapon.finish();
	SetPhysics(Phys_None);
	Acceleration = vect(0,0,0);
	TweenToFighter(0.2);
	FinishAnim();
//	PlayTurning();
//	TurnToward(Target);
//	DesiredRotation = rot(0,0,0);
//	DesiredRotation.Yaw = Rotation.Yaw;
//	setRotation(DesiredRotation);
//	TweenToFighter(0.2);
//	FinishAnim();

	Disable('AnimEnd');
	PlayWaiting();
	Velocity *= 0.0;
}


///////////////////////////////////////
// UsingC4
///////////////////////////////////////

state UsingC4
{
ignores SeePlayer, AnimEnd; 

	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, name damageType)
	{
		//log("s_Player::UsingC4::TakeDamage");

		Global.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);

		ClientRoundEnded();
		UseReleaseServer(false, false);
		bUsingCT = false;
	}

	function RoundEnded()
	{
		//log("s_Player::UsingC4::RoundEnded");

		AmbientSound = None;

		if ( bUsingCT )
		{
			bUsingCT = false;
			UseReleaseServer(false, false);
		}
		
		Global.RoundEnded();
	}

	simulated function ClientRoundEnded()
	{
		//log("s_Player::UsingC4::ClientRoundEnded");
		s_HUD(myHUD).DrawConsoleTimerHUD( false, false, 0.0 );
		bUsingCT = false;
		AmbientSound = None;

		if ( Role < Role_Authority )
		{
			if ( NextState == 'PlayerSwimming' )
				setPhysics(PHYS_Swimming);
			GotoState(NextState);
		}

		Global.ClientRoundEnded();
	}

	exec function AltFire( optional float F )	{ }

	exec function Fire( optional float F )	{ } 

	event PlayerTick( float DeltaTime )
	{
		local	s_ExplosiveC4	bimbo;

//		if ( (Level.NetMode != NM_Standalone) && (Level.NetMode != NM_Client) )
//			return;

		ViewShake(DeltaTime);
		ViewFlash(DeltaTime);

		if ( bUpdatePosition )
			ClientUpdatePosition();

		PlayerMove(DeltaTime);

		if ( !bUsingCT )
			return;

		CTUseTime += DeltaTime;

		if ( (CurrentSoundDuration != 0.0) && (CTUseTime > CurrentSoundDuration) )
		{
			// Playing looping defusing sound
			AmbientSound = Sound'TODatas.def_progress';
			CurrentSoundDuration = 0.0;
		}

		if (CTUseTime > CTEndTime)
		{
			// Kill clientside C4
			if ( Level.NetMode != NM_DedicatedServer )
			{
				foreach AllActors(class's_ExplosiveC4', bimbo)
					bimbo.Destroy();
			}

			//log("s_player::UsingC4::PlayerTick - CTUseTime > CTEndTime");
			ClientRoundEnded();
			PlayOwnedSound(Sound'TODatas.def_success', Slot_Interact);
			UseReleaseServer(true, true);
		}
		else
			s_HUD(myHUD).DrawConsoleTimerHUD( false, true, CTUseTime / CTEndTime );
	}

	function PlayerMove( float DeltaTime )
	{
		if ( Role < ROLE_Authority ) // then save this move and replicate it
			ReplicateMove(DeltaTime, vect(0,0,0), Dodge_None, rot(0,0,0));
	}


	simulated function UseRelease()
	{
		//log("s_Player::UsingC4::UseRelease");

		Super.UseRelease();
		
		ClientRoundEnded();
		PlayOwnedSound(Sound'TODatas.def_fail', Slot_Interact);
		UseReleaseServer(false, true);
	}

	function UseReleaseServer(bool bSucceed, bool bCheck)
	{
		//log("s_Player::UsingC4::UseReleaseServer");

		AmbientSound = None;
		if ( CurrentC4 != None )
		{
			if ( bSucceed )
			{
				PlayOwnedSound(Sound'TODatas.def_success', Slot_Interact);
				CurrentC4.C4Complete();
			}
			else
			{
				PlayOwnedSound(Sound'TODatas.def_fail', Slot_Interact);
				CurrentC4.C4Failed();
			}
		}
//		else
//			log("UsingConsoleTimer - UseReleaseServer - CurrentCT == None");

		if ( bCheck )
		{
			if ( NextState == 'PlayerSwimming' )
				setPhysics(PHYS_Swimming);
			GotoState(NextState);
		}
	}

	function BeginState()
	{
//		log("s_Player::UsingC4::BeginState");

		SetPhysics(Phys_None);
		Acceleration = vect(0,0,0);
		bFire = 0;
		bAltFire = 0;
		if ( (Role == Role_Authority) && (s_Weapon(Weapon) != None) && !s_Weapon(Weapon).bReloadingWeapon )
			Weapon.GotoState('idle');	
	}

	function EndState()
	{
//		log("s_Player::UsingC4::Endstate");

		AmbientSound = None;

		// If exits state anormally (ie end of round)
		if ( Level.NetMode != NM_DedicatedServer )
		{
			if ( bUsingCT )
			{
				s_HUD(myHUD).DrawConsoleTimerHUD( false, false, 0.0 );
				bUsingCT = false;
				PlayOwnedSound(Sound'TODatas.def_fail', Slot_Interact);
				if (Health > 0)
				{
					if ( NextState == 'PlayerSwimming' )
						setPhysics(PHYS_Swimming);
					GotoState(NextState);
				}
			}
		}
		
		if ( Role == Role_Authority )
		{
			if ( CurrentC4 != None && CurrentC4.bBeingActivated )
			{
				PlayOwnedSound(Sound'TODatas.def_fail', Slot_Interact);
				CurrentC4.C4Failed();
				if (Health > 0)
				{
					if ( NextState == 'PlayerSwimming' )
						setPhysics(PHYS_Swimming);
					GotoState(NextState);
				}
			}
		}
	}

Begin:

//	log("s_Player::UsingC4::Begin");

	bFire = 0;
	bAltFire = 0;
	if (Weapon != None && !s_Weapon(Weapon).IsInState('ReloadWeapon') )
		Weapon.finish();
	SetPhysics(Phys_None);
	Acceleration = vect(0,0,0);

	Disable('AnimEnd');

	Velocity *= 0.0;
}


///////////////////////////////////////
// GetNearbyHostages
///////////////////////////////////////

simulated function GetNearByHostage(out string HostageName[30], out s_NPCHostage Hostage[30], out int NumHostage)
{
	local	s_NPCHostage	H;
	local	int	i;

	NumHostage = 0;

	//for ( H=GetPlayerOwner().Level.PawnList; H!=None; H=H.NextPawn)
	foreach AllActors(class's_NPCHostage', H)
	{
		i++;
		if (i > 100)
			break;
		if ( (H != None) && (H.Health > 0) && (VSize(H.location - location) < 256.0) )
		{
			//Log("SW -- Hostage Found **********************"$H);
			NumHostage++;
			if ( H.PlayerReplicationInfo != None )
				HostageName[NumHostage] = H.PlayerReplicationInfo.PlayerName;
			Hostage[NumHostage] = H;
			
		}
	}

	Hostage[NumHostage+1] = None;
}


///////////////////////////////////////
// DebugInfo
///////////////////////////////////////

exec function debug()
{
	if ( bShowDebug )
		bShowDebug = false;
	else
		bShowDebug = true;
}


///////////////////////////////////////
// IsInBuyZone
///////////////////////////////////////

simulated function bool IsInBuyZone()
{
	return bInBuyZone;
}


///////////////////////////////////////
// PlayLadderSound
///////////////////////////////////////

function PlayLadderSound()
{
	local float t;

	t = FRand();
	if ( t < 0.25 )
		PlaySound(Sound'Stairs1', SLOT_Misc);
	else if ( t < 0.50 )
		PlaySound(Sound'Stairs2', SLOT_Misc);
	else if ( t < 0.75)
		PlaySound(Sound'Stairs3', SLOT_Misc);
	else 
		PlaySound(Sound'Stairs5', SLOT_Misc);
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
		carc = Spawn(class 's_PlayerHead',,, Location + CollisionHeight * vect(0,0,0.8), Rotation + rot(3000,0,16384) );
		if (carc != None)
		{
			carc.Initfor(self);
			carc.Velocity = Velocity + VSize(Velocity) * VRand();
			carc.Velocity.Z = FMax(carc.Velocity.Z, Velocity.Z);
		}
	}
}


///////////////////////////////////////
// EndPreRound
///////////////////////////////////////

simulated function	EndPreRound()
{
	SetPhysics(PHYS_Falling);
	GoToState('PlayerWalking');
}



///////////////////////////////////////
// ClientPlayTakeHit
///////////////////////////////////////

function ClientPlayTakeHit(vector HitLoc, byte Damage, bool bServerGuessWeapon)
{
	local ChallengeHUD CHUD;

	//log("ClientPlayTakeHit !");
	s_HUD(MyHUD).SetDamage(HitLoc, damage);

	HitLoc += Location;
	if ( bServerGuessWeapon && ((GetAnimGroup(AnimSequence) == 'Dodge') || ((Weapon != None) && Weapon.bPointing)) )
		return;

	Enable('AnimEnd');
	bAnimTransition = true;
	BaseEyeHeight = Default.BaseEyeHeight;

	PlayTakeHit(0.1, HitLoc, Damage);
	CalculateWeight();
}	


///////////////////////////////////////
// TakeFallingDamage
///////////////////////////////////////
/*
function TakeFallingDamage()
{
	local float damage, fallingvelocity;

	if ( Velocity.Z < -600 )
	{
		MakeNoise(-0.5 * Velocity.Z/(FMax(JumpZ, 150.0)));
		if ( Role == ROLE_Authority )
		{
			fallingvelocity = -Velocity.Z;
			//if ( fallingvelocity < 0 )
			//	fallingvelocity = -fallingvelocity;

			damage = (fallingvelocity - 600) * 0.20;
			//log("TakeFallingDamage -damage:"@damage@"-Velocity:"@Velocity.Z@"-fallingvelocity:"@fallingvelocity);
			
			if ( damage < 15 )
				damage = 0;
			else if ( Damage > 500 )
				Damage = 10000;
			else if ( Damage > 100 )
				Damage = 200;

			if ( damage > 0 )
				TakeDamage(damage, None, Location, -velocity / 2.0, 'Fell');

			ShakeView(0.175 - 0.00007 * Velocity.Z, -0.85 * Velocity.Z, -0.002 * Velocity.Z);
		}
	}
	else if ( Velocity.Z > 0.5 * Default.JumpZ )
		MakeNoise(0.35);				
}
*/
function TakeFallingDamage()
{
	local float damage;

	if (Velocity.Z < -700)
	{
		MakeNoise(-0.5 * Velocity.Z/(FMax(JumpZ, 150.0)));
		if (Role == ROLE_Authority)
		{
			damage = (Velocity.Z + 700) * 0.15;
			//log("TakeFallingDamage - damage: "$damage$" - Velocity: "$Velocity.Z);

			if (damage < 0)
				damage = -damage;

			if (damage < 25)
				damage = 0;

			if (Damage > 500)
				Damage = 10000;
			else if (Damage > 100)
				Damage = 200;

			if (damage > 0)
				TakeDamage(damage, None, Location, -velocity, 'Fell');

			ShakeView(0.175 - 0.00007 * Velocity.Z, -0.85 * Velocity.Z, -0.002 * Velocity.Z);
		}
	}
	else if ( Velocity.Z > 0.5 * Default.JumpZ )
		MakeNoise(0.35);				
}

///////////////////////////////////////
// KillMe
///////////////////////////////////////

function KillMe()
{
	local	s_SWATGame	SG;

	SG = s_SWATGame(Level.game);

	if ( (SG != None) && (Level.NetMode != NM_StandAlone) )
	{
		SG.BroadcastLocalizedMessage(class's_MessageVote', 9, PlayerReplicationInfo);
		log("Hacked console detected!"@PlayerReplicationInfo.PlayerName@"kicked from the server!");
		Destroy();
	}
	else
		log("KillMe - SG == None");
}


///////////////////////////////////////
// s_kammoAuto
///////////////////////////////////////
// Addendum July 2000, Michael "IvanTT" Sanders
// Enhanced by Shag
exec function s_kammoAuto(int QuikBuyNum)
{
	local	int	WeaponNum;

	if ( !bInBuyZone )
		return;

	WeaponNum = QuikBuyNum - 101;

	// Buy weapon
  if ( (QuikBuyNum > 100) && (QuikBuyNum < 200) 
		&& (WeaponNum <= class'TOModels.TO_WeaponsHandler'.default.NumWeapons)
		&& (class'TOModels.TO_WeaponsHandler'.static.IsTeamMatch( Self, WeaponNum )) )
  {
    BuyWeapon(WeaponNum);
  }
	else if ( (QuikBuyNum > 300) && (QuikBuyNum < 305) )
	{ // Buy separate armor
		s_BuyItem(QuikBuyNum - 300);
	}
  else if (QuikBuyNum == 333)         // Buy All Needed Armor
  {
    if ( (VestCharge < 50) && (Money > 400) )
      s_BuyItem(1);

    if ( (HelmetCharge < 50) && (Money > 250) )
			s_BuyItem(2);

    if ( (LegsCharge < 50) && (Money > 300) )
			s_BuyItem(3);
  }
  else if (QuikBuyNum == 401)         // Buy Night Vision
  {
    if ( !bHasNV && (Money > 800) )
			s_BuyItem(5);
  }
  else if ( (QuikBuyNum == 999) && (weapon != None) )         //Buy ammo for current weapon
    BuyAmmo(s_Weapon(Weapon));

}


///////////////////////////////////////
// CalculateWeight
///////////////////////////////////////
// - add support for UT gametypes bots

simulated function CalculateWeight()
{
	local	float			Weight;

	if ( bNotPlaying )
		return;

	if ( bSpecialItem )
		Weight += class's_SpecialItem'.default.Weight;

	if ( HelmetCharge > 0 )
		Weight += 5;

	if ( VestCharge > 0 )
		Weight += 10;

	if ( LegsCharge > 0 )
		Weight += 10;

	if ( (Weapon != None) && Weapon.IsA('s_Weapon') )
		Weight += s_Weapon(Weapon).WeaponWeight;

	// Crouching check
	if ( bIsCrouching )
	{
		PrePivot.Z = Default.CollisionHeight - CrouchHeight - 2.0;
		Weight += 200;
	}
	else 
		PrePivot.Z = -2.0;

	if ( Weight > 220 )
		Weight = 220;

	GroundSpeed = 280 - Weight;
	AirSpeed = 300 + Weight;
  AccelRate = 2048.000000 + Weight;
  AirControl = 0.300000 - Weight / 1000;
//	JumpZ = 350 - Weight / 2;

}





///////////////////////////////////////
// HeadZoneChange
///////////////////////////////////////

event HeadZoneChange(ZoneInfo newHeadZone)
{
	Super.HeadZoneChange(newHeadZone);

	CalculateWeight();
}


///////////////////////////////////////
// ThrowWeapon
///////////////////////////////////////

exec function ThrowWeapon()
{
	Super.ThrowWeapon();
	CalculateWeight();
}


///////////////////////////////////////
// ViewFlash
///////////////////////////////////////

function ViewFlash(float DeltaTime)
{
	local s_GameReplicationInfo		GRI;
	
	GRI = s_GameReplicationInfo(GameReplicationInfo);

	if ( (GRI != None) && GRI.bPreRound ) 
	{
		FlashScale = Vect(1, 1, 1);
		FlashFog = vect(0, 0, 0);
		return;
	}

	Super.ViewFlash(DeltaTime);
}

/*
event WalkTexture( texture Texture, vector StepLocation, vector StepNormal )
{
	log("WalkTexture -T:"@Level.TimeSeconds@"-Tx:"@Texture);
}
*/

///////////////////////////////////////
// GetFloorMaterial
///////////////////////////////////////

simulated function EFloorMaterial GetFloorMaterial()
{
	local	Sound		FootSound;

	if ( (Shadow == None) || (s_PlayerShadow(Shadow) == None) )
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
	//log("PlayFootStep -"@Level.TimeSeconds);

	if ( (Level.NetMode != NM_Client) )
	{
		if ( !TO_DeathMatchPlus(Level.Game).bNoviceMode )
			MakeNoise( 0.2 );
		else
			MakeNoise(0.1);
	}

	if ( bBehindView || (Role == ROLE_SimulatedProxy) )	
		FootStepping();
}


///////////////////////////////////////
// FootStepping
///////////////////////////////////////

simulated function FootStepping()
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

		PlaySound(step, SLOT_Interact, 1, false, 1000.0, 1.0);
		return;
	}

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
			VolumeMultiplier = 0.11;
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
			VolumeMultiplier = 0.20;
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
			VolumeMultiplier = 0.17;
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
		PlaySound(step, SLOT_Interact, 2.0 * VolumeMultiplier, false, 1000.0, 1.0);
}

/*
///////////////////////////////////////
// CallPlayDynamicTeamSound 
///////////////////////////////////////

function CallPlayDynamicTeamSound(byte MessageIndex, byte VoiceIndex, optional bool bOverride)
{
	if (Level.Game!=None)
		s_SWATGame(Level.Game).s_PlayDynamicTeamSound(MessageIndex, VoiceIndex, PlayerReplicationInfo.Team, bOverride, PlayerReplicationInfo);
}


///////////////////////////////////////
// s_PlayDynamicSound 
///////////////////////////////////////

simulated function s_PlayDynamicSound(byte messageIndex, byte VoiceIndex, optional bool bOverride, optional PlayerReplicationInfo SenderPRI)
{
	local s_Voices V;
		
	V = Spawn(class's_Voices', self);
	if ( V != None )
		V.ClientInitialize(messageIndex, VoiceIndex, bOverride, SenderPRI);
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
*/

 
//
// Fix for new gametypes
//


///////////////////////////////////////
// AddBotNamed
///////////////////////////////////////

exec function AddBotNamed(string BotName)
{
	if ( Level.NetMode == NM_Client )
	{
		ClientMessage("Can't add named bots from client.");
		return;
	}

	if ( TO_DeathMatchPlus(Level.Game) != None )	
		TO_DeathMatchPlus(Level.Game).BotConfig.DesiredName = BotName;
	Level.Game.ForceAddBot();
}


///////////////////////////////////////
// EncroachingOn
///////////////////////////////////////
// Encroachment

event bool EncroachingOn( actor Other )
{
	if ( (GameReplicationInfo != None) && GameReplicationInfo.bTeamGame && Other.bIsPawn 
		&& (Pawn(Other).PlayerReplicationInfo != None)
		&& (Pawn(Other).PlayerReplicationInfo.Team == PlayerReplicationInfo.Team) )
	{
		if ( (Role == ROLE_Authority) && Level.Game.IsA('TO_DeathMatchPlus')
			&& TO_DeathMatchPlus(Level.Game).bStartMatch )
			return Super.EncroachingOn(Other);
		else
			return true;
	}

	return Super(PlayerPawn).EncroachingOn(Other);
}


/*
///////////////////////////////////////
// KillAll
///////////////////////////////////////
// KillAll disabled
exec function KillAll(class<actor> aClass)
{
	if ( aClass == class'Bot' )
		Super(TournamentPlayer).KillAll(aClass);
}
*/

///////////////////////////////////////
// ToggleHUDDisplay
///////////////////////////////////////

exec function ToggleHUDDisplay()
{
	if ( s_HUD(myHUD) != None )
		s_HUD(myHUD).bHideHUD = !s_HUD(myHUD).bHideHUD;
}


///////////////////////////////////////
// Advance
///////////////////////////////////////
// Skip any map.

exec function Advance()
{
	if( !bCheatsEnabled )
		return;

	if ( !bAdmin && (Level.Netmode != NM_Standalone) )
		return;

	if (Level.Game.IsA('TO_DeathMatchPlus'))
		TO_DeathMatchPlus(Level.Game).Skip();
}


///////////////////////////////////////
// AdvanceAll
///////////////////////////////////////
// Skip all maps.

exec function AdvanceAll()
{
	if( !bCheatsEnabled )
		return;
	if ( !bAdmin && (Level.Netmode != NM_Standalone) )
		return;

	if (Level.Game.IsA('TO_DeathMatchPlus'))
		TO_DeathMatchPlus(Level.Game).SkipAll();
}


///////////////////////////////////////
// defaultproperties
///////////////////////////////////////
// VoiceType
/*
var(Sounds) sound	Footstep1;
var(Sounds) sound	Footstep2;
var(Sounds) sound	Footstep3;
var(Sounds) sound	HitSound3;
var(Sounds) sound	HitSound4;
var(Sounds) sound	Die2;
var(Sounds) sound	Die3;
var(Sounds) sound	Die4;
var(Sounds) sound	GaspSound;
var(Sounds) sound	UWHit1;
var(Sounds) sound	UWHit2;
var(Sounds) sound	LandGrunt;
*/

defaultproperties
{
     CrouchHeight=29.000000
     LandGrunt=Sound'TODatas.Player.fall1'
     StatusDoll=None
     StatusBelt=None
     VoicePackMetaClass="BotPack.VoiceMale"
     HUDType=Class's_SWAT.s_HUD'
     CarcassType=Class's_SWAT.s_PlayerCarcass'
     bCheatsEnabled=False
     GroundSpeed=300.000000
     JumpZ=350.000000
     BaseEyeHeight=35.000000
     EyeHeight=35.000000
     VoiceType=""
     PlayerReplicationInfoClass=Class's_SWAT.TO_PRI'
     CollisionRadius=20.000000
}
