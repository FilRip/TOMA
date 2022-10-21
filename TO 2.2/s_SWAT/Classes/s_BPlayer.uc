//=============================================================================
// s_BPlayer
//=============================================================================
//
// Tactical Ops
// - http://www.planetunreal.com/tacticalops
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen and Benoit "JAH" Delayen
//=============================================================================
//
// Base class for Players (UT and Tactical Ops)
//
 
class s_BPlayer extends TO_SysPlayer
	abstract;


var		bool	bSZoomStraight;	// Instantaneous Zoom or not..
var		bool	bSZoom;					// Are we zooming ?
var		float	SZoomVal;				// Zoom amount
var		bool	bDoRecoil;

var(Movement) globalconfig float OriginalBob; // alternate WalkBob value.


var	config	bool	bAutomaticReload, bHideCrosshairs, bHUDModFix;
var	config	bool	bHideDeathMsg, bHideWidescreen;

//var		TO_Flashlight myFlashlight;
var		TO_FLight	FlashLight;

var		string	s_Voice;


///////////////////////////////////////
// replication 
///////////////////////////////////////

replication 
{
  // Client->Server replication
  reliable if( Role < ROLE_Authority )
  	s_ChangeFireMode, PKick, PKickBan, PTempKickBan, s_kReload, s_Flashlight,
		ServerSetbSZoom, ServerSetAutoReload, ServerSetHideDeathMsg, LogWeapon; 

	// Server->Client replication
	reliable if( Role==ROLE_Authority )
		ClientReloadW;
}


///////////////////////////////////////
// Destroyed 
///////////////////////////////////////

simulated event Destroyed()
{
	//Bob = OriginalBob;
	//SaveConfig();

	Super.Destroyed();

	if ( Flashlight != None )
		Flashlight.Destroy();
}


// called after PostBeginPlay on net client
simulated event PostNetBeginPlay()
{
	if ( Role != ROLE_SimulatedProxy )
		return;
	/*
	if ( bIsMultiSkinned )
	{
		if ( MultiSkins[1] == None )
		{
			if ( bIsPlayer )
				SetMultiSkin(self, "","", PlayerReplicationInfo.team);
			else
				SetMultiSkin(self, "","", 0);
		}
	}
	else if ( Skin == None )
		Skin = Default.Skin;
	*/
	if ( (PlayerReplicationInfo != None) && (PlayerReplicationInfo.Owner == None) )
		PlayerReplicationInfo.SetOwner(self);
}


///////////////////////////////////////
// DumpToLog
///////////////////////////////////////
// Dump custom message to log file. Useful for debugging.

exec	function DumpToLog( string message )
{
	log("DumpToLog:"@message);
}

exec function LogWeapon()
{
	local	String Msg;

	if ( Weapon != None )
		Msg = "WS:"@Weapon.GetStateName();

	ClientMessage(Msg, 'Event', true);
}

// To test player models animations
exec function TestAnimMode()
{
	if( !bCheatsEnabled )
		return;

	if ( !bAdmin && (Level.Netmode != NM_Standalone) )
		return;

	GotoState('TestingAnim');
}

// To test player models animations
exec function TestAnim(name SeqName, optional float Rate, optional float TweenTime)
{
	if( !bCheatsEnabled )
		return;

	if ( !bAdmin && (Level.Netmode != NM_Standalone) )
		return;

	if ( Rate <= 0.0 )
		Rate = 1.0;
	PlayAnim(SeqName, Rate, TweenTime);
}

// To test player models animations
exec function TestAnimFreeze(bool val)
{
	if( !bCheatsEnabled )
		return;

	if ( !bAdmin && (Level.Netmode != NM_Standalone) )
		return;

	bFrozen = val;
}

// To test player models animations
state TestingAnim
{	
	ignores SeePlayer, HearNoise, Bump;

	function PlayChatting() { }
/*
	function ServerMove(float TimeStamp, vector Accel, vector ClientLoc, bool NewbRun, bool NewbDuck,	bool NewbJumpStatus, 
		bool bFired, bool bAltFired, bool bForceFire, bool bForceAltFire,	eDodgeDir DodgeMove, byte ClientRoll, int View, 
		optional byte OldTimeDelta, optional int OldAccel)
	{
		Global.ServerMove(TimeStamp, Accel, ClientLoc, false, false, false,	false, false,	false, false,	DodgeMove, 
			ClientRoll, View);
	}
*/
	function ZoneChange( ZoneInfo NewZone )
	{
		if ( bFrozen )
			return;

		if (NewZone.bWaterZone)
		{
			setPhysics(PHYS_Swimming);
			GotoState('PlayerSwimming');
		}
	}

	function AnimEnd()
	{
		local name MyAnimGroup;

		if ( bFrozen )
			return;

		bAnimTransition = false;
		if (Physics == PHYS_Walking)
		{
			if (bIsCrouching)
			{
				if ( !bIsTurning && ((Velocity.X * Velocity.X + Velocity.Y * Velocity.Y) < 1000) )
					PlayDuck();	
				else
					PlayCrawling();
			}
			else
			{
				MyAnimGroup = GetAnimGroup(AnimSequence);
				if ((Velocity.X * Velocity.X + Velocity.Y * Velocity.Y) < 1000)
				{
					if ( MyAnimGroup == 'Waiting' )
						PlayWaiting();
					else
					{
						bAnimTransition = true;
						TweenToWaiting(0.2);
					}
				}	
				else if (bIsWalking)
				{
					if ( (MyAnimGroup == 'Waiting') || (MyAnimGroup == 'Landing') || (MyAnimGroup == 'Gesture') || (MyAnimGroup == 'TakeHit')  )
					{
						TweenToWalking(0.1);
						bAnimTransition = true;
					}
					else 
						PlayWalking();
				}
				else
				{
					if ( (MyAnimGroup == 'Waiting') || (MyAnimGroup == 'Landing') || (MyAnimGroup == 'Gesture') || (MyAnimGroup == 'TakeHit')  )
					{
						bAnimTransition = true;
						TweenToRunning(0.1);
					}
					else
						PlayRunning();
				}
			}
		}
		else
			PlayInAir();
	}

	function PlayerCalcView(out actor ViewActor, out vector CameraLocation, out rotator CameraRotation )
	{
		local vector View,HitLocation,HitNormal, FirstHit, spot;
		local float DesiredDist, ViewDist, WallOutDist;
		local actor HitActor;
		local Pawn PTarget;

		if ( ViewTarget != None )
		{
			ViewActor = ViewTarget;
			CameraLocation = ViewTarget.Location;
			CameraRotation = ViewTarget.Rotation;
			PTarget = Pawn(ViewTarget);
			if ( PTarget != None )
			{
				if ( Level.NetMode == NM_Client )
				{
					if ( PTarget.bIsPlayer )
						PTarget.ViewRotation = TargetViewRotation;
					PTarget.EyeHeight = TargetEyeHeight;
					if ( PTarget.Weapon != None )
						PTarget.Weapon.PlayerViewOffset = TargetWeaponViewOffset;
				}
				if ( PTarget.bIsPlayer )
					CameraRotation = PTarget.ViewRotation;
				CameraLocation.Z += PTarget.EyeHeight;
			}

			if ( bBehindView )
				CalcBehindView(CameraLocation, CameraRotation, 140);

			return;
		}

		// View rotation.
		CameraRotation = ViewRotation;
		DesiredFOV = DefaultFOV;		
		ViewActor = self;
		if( bBehindView ) //up and behind (for death scene)
			CalcBehindView(CameraLocation, CameraRotation, 140);
		else
		{
			// First-person view.
			CameraLocation = Location;
			CameraLocation.Z += Default.BaseEyeHeight;
		}
	}

	event PlayerTick( float DeltaTime )
	{
		ViewShake(DeltaTime);
		ViewFlash(DeltaTime);

		if ( bUpdatePosition )
			ClientUpdatePosition();
		
		PlayerMove(DeltaTime);
	}

	function PlayerMove(float DeltaTime)
	{
		local vector X,Y,Z, NewAccel;
		local EDodgeDir OldDodge;
		local eDodgeDir DodgeMove;
		local rotator OldRotation;
		local float Speed2D;
		local bool	bSaveJump;
		local name AnimGroupName;

		GetAxes(Rotation,X,Y,Z);

		aForward *= 0.4;
		aStrafe  *= 0.4;
		aLookup  *= 0.24;
		aTurn    *= 0.24;

		// Update acceleration.
		NewAccel = aForward*X + aStrafe*Y; 
		NewAccel.Z = 0;
		//AnimGroupName = GetAnimGroup(AnimSequence);		

		// Update rotation.
		//OldRotation = Rotation;
		//UpdateRotation(DeltaTime, 1);

		if ( bPressedJump && (AnimGroupName == 'Dodge') )
		{
			bSaveJump = true;
			bPressedJump = false;
		}
		else
			bSaveJump = false;

		GetAxes(ViewRotation,X,Y,Z);
		// Update view rotation.
		aLookup  *= 0.24;
		aTurn    *= 0.24;
		ViewRotation.Yaw += 32.0 * DeltaTime * aTurn;
		ViewRotation.Pitch += 32.0 * DeltaTime * aLookUp;
		ViewRotation.Pitch = ViewRotation.Pitch & 65535;
		if ((ViewRotation.Pitch > 18000) && (ViewRotation.Pitch < 49152))
		{
			if (aLookUp > 0) 
				ViewRotation.Pitch = 18000;
			else
				ViewRotation.Pitch = 49152;
		}
		if ( Role < ROLE_Authority ) // then save this move and replicate it
			ReplicateMove(DeltaTime, NewAccel, DODGE_None, rot(0,0,0));
		else
			ProcessMove(DeltaTime, NewAccel, DODGE_None, rot(0,0,0));
		bPressedJump = bSaveJump;
	}

	function ProcessMove(float DeltaTime, vector NewAccel, eDodgeDir DodgeMove, rotator DeltaRot)	
	{
		local vector OldAccel;
		
		OldAccel = Acceleration;
		Acceleration = NewAccel;

		if ( bFrozen )
			return;

		bIsTurning = ( Abs(DeltaRot.Yaw/DeltaTime) > 5000 );

		if ( bPressedJump )
			DoJump();
		if ( (Physics == PHYS_Walking) && (GetAnimGroup(AnimSequence) != 'Dodge') )
		{
			if (!bIsCrouching)
			{
				if (bDuck != 0)
				{
					bIsCrouching = true;
					PlayDuck();
				}
			}
			else if (bDuck == 0)
			{
				OldAccel = vect(0,0,0);
				bIsCrouching = false;
				TweenToRunning(0.1);
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

	function FindGoodView()
	{
		local vector cameraLoc;
		local rotator cameraRot;
		local int tries, besttry;
		local float bestdist, newdist;
		local int startYaw;
		local actor ViewActor;
		
		ViewRotation.Pitch = 56000;
		tries = 0;
		besttry = 0;
		bestdist = 0.0;
		startYaw = ViewRotation.Yaw;
		
		for (tries=0; tries<16; tries++)
		{
			cameraLoc = Location;
			PlayerCalcView(ViewActor, cameraLoc, cameraRot);
			newdist = VSize(cameraLoc - Location);
			if (newdist > bestdist)
			{
				bestdist = newdist;	
				besttry = tries;
			}
			ViewRotation.Yaw += 4096;
		}
			
		ViewRotation.Yaw = startYaw + besttry * 4096;
	}
	
/*	
	function Timer()
	{
		bFrozen = false;
		bShowScores = true;
		bPressedJump = false;
	}
*/	
	function BeginState()
	{
		BaseEyeheight = Default.BaseEyeHeight;
		EyeHeight = BaseEyeHeight;
		//if ( Carcass(ViewTarget) == None )
		bBehindView = true;
		//bFrozen = true;
		bPressedJump = false;
		bJustFired = false;
		bJustAltFired = false;
		FindGoodView();
		//if ( (Role == ROLE_Authority) && !bHidden )
		//	Super.Timer(); 
		//SetTimer(1.0, false);

		// clean out saved moves
		while ( SavedMoves != None )
		{
			SavedMoves.Destroy();
			SavedMoves = SavedMoves.NextMove;
		}
		if ( PendingMove != None )
		{
			PendingMove.Destroy();
			PendingMove = None;
		}

		//bFrozen = false;
		//PlayerReplicationInfo.bWaitingPlayer = true;
		//SetTimer(3.0, false);
	}
	
	function EndState()
	{
		// clean out saved moves
		while ( SavedMoves != None )
		{
			SavedMoves.Destroy();
			SavedMoves = SavedMoves.NextMove;
		}
		if ( PendingMove != None )
		{
			PendingMove.Destroy();
			PendingMove = None;
		}
		Velocity = vect(0,0,0);
		Acceleration = vect(0,0,0);
		bBehindView = false;
		bShowScores = false;
		bJustFired = false;
		bJustAltFired = false;
		bPressedJump = false;
		bFrozen = false;
		if ( Carcass(ViewTarget) != None )
			ViewTarget = None;
		//PlayerReplicationInfo.bWaitingPlayer = false;
		//bBehindView = false;
		//Log(self$" exiting dying with remote role "$RemoteRole$" and role "$Role);
	}
}


///////////////////////////////////////
// KillAll
///////////////////////////////////////

exec function KillAll(class<actor> aClass)
{
	//log("s_BPlayer::KillAll"@aClass);

	if ( !bAdmin && (Level.Netmode != NM_Standalone) )
		return;

	if ( Level.Game.IsA('TO_DeathMatchPlus') && ((aClass == class'Bot') || (aClass == class'Pawn')) )
		TO_DeathMatchPlus(Level.Game).MinPlayers = 0;

	Super.KillAll(aClass);
}


exec function Summon( string ClassName )
{
	Super.Summon(ClassName);
	Level.Game.BroadcastMessage(PlayerReplicationInfo.PlayerName@"summons:"@ClassName);
}


///////////////////////////////////////
// SendVoiceMessage
///////////////////////////////////////

function SendVoiceMessage(PlayerReplicationInfo Sender, PlayerReplicationInfo Recipient, name messagetype, byte messageID, name broadcasttype)
{
	// Fix for the SendVoiceMessage hack.
	if ( !Sender.bIsSpectator || (Sender == PlayerReplicationInfo) )
		Super.SendVoiceMessage(Sender, Recipient, messagetype, messageID, broadcasttype);
}


///////////////////////////////////////
// PKick
///////////////////////////////////////

exec function PKick( int pid ) 
{
	local Pawn aPawn;

	if ( !bAdmin )
		return;

	for ( aPawn=Level.PawnList; aPawn!=None; aPawn=aPawn.NextPawn )
		if
		(	aPawn.bIsPlayer
			&&	aPawn.PlayerReplicationInfo.PlayerID == pid 
			&&	(PlayerPawn(aPawn)==None || NetConnection(PlayerPawn(aPawn).Player)!=None ) )
		{
			Level.Game.BroadcastMessage(GetHumanName()@"kicked"@aPawn.GetHumanName());
			aPawn.Destroy();
			return;
		}
}


///////////////////////////////////////
// PKickBan
///////////////////////////////////////

exec function PKickBan( int pid ) 
{
	local Pawn aPawn;
	local string IP;
	local int j;

	if( !bAdmin || (s_SWATGame(Level.Game) == None) )
		return;

	for( aPawn=Level.PawnList; aPawn!=None; aPawn=aPawn.NextPawn )
		if
		(	aPawn.bIsPlayer
			&&	aPawn.PlayerReplicationInfo.PlayerID == pid
			&&	(PlayerPawn(aPawn)==None || NetConnection(PlayerPawn(aPawn).Player)!=None ) )
		{
			IP = PlayerPawn(aPawn).GetPlayerNetworkAddress();
			if ( Level.Game.CheckIPPolicy(IP) )
			{
				s_SWATGame(Level.Game).KickBan(PlayerPawn(aPawn), "Banned by Admin:"@GetHumanName());
				Level.Game.BroadcastMessage(GetHumanName()@"kick banned"@aPawn.GetHumanName());
			}
			return;
		}
}


///////////////////////////////////////
// PTempKickBan
///////////////////////////////////////

exec function PTempKickBan( int pid ) 
{
	local Pawn aPawn;
	local string IP;
	local int j;

	if( !bAdmin || (s_SWATGame(Level.Game) == None) )
		return;

	for( aPawn=Level.PawnList; aPawn!=None; aPawn=aPawn.NextPawn )
		if
		(	aPawn.bIsPlayer
			&&	aPawn.PlayerReplicationInfo.PlayerID == pid
			&&	(PlayerPawn(aPawn)==None || NetConnection(PlayerPawn(aPawn).Player)!=None ) )
		{
			IP = PlayerPawn(aPawn).GetPlayerNetworkAddress();
			if ( !s_SWATGame(Level.Game).IsTempBanned(IP) )
			{
				s_SWATGame(Level.Game).TempKickBan(PlayerPawn(aPawn), "TempBanned by Admin:"@GetHumanName());
				Level.Game.BroadcastMessage(GetHumanName()@"temp kick banned"@aPawn.GetHumanName());
			}
			return;
		}
}

// Used by TO_Protect, server only
function ForceTempKickBan( String Reason ) 
{
	local Pawn aPawn;
	local string IP;
	local int j;

	if ( Role != Role_Authority )
		return;

	if ( s_SWATGame(Level.Game) == None )
		return;

	s_SWATGame(Level.Game).TempKickBan(PlayerPawn(aPawn), Reason);
	Level.Game.BroadcastMessage(GetHumanName()@"was temp. KickBanned - Reason:"@Reason);
}


///////////////////////////////////////
// Ignore
///////////////////////////////////////

exec function Ignore( int pid ) 
{
	//log("s_BPlayer::Ignore");
	if ( TO_PRI(PlayerReplicationInfo) != None )
		TO_PRI(PlayerReplicationInfo).ToggleIgnored( pid );
}


///////////////////////////////////////
// TeamMessage
///////////////////////////////////////

event TeamMessage( PlayerReplicationInfo PRI, coerce string S, name Type, optional bool bBeep  )
{
	//log("s_BPlayer::TeamMessage");
	if ( (TO_PRI(PlayerReplicationInfo) != None) && TO_PRI(PlayerReplicationInfo).IsIgnored( PRI ) )
		return;

	Super.TeamMessage(PRI, S, Type, bBeep);
}


///////////////////////////////////////
// TeamMessage
///////////////////////////////////////

function ClientVoiceMessage(PlayerReplicationInfo Sender, PlayerReplicationInfo Recipient, name messagetype, byte messageID)
{
	//log("s_BPlayer::ClientVoiceMessage");
	if ( (TO_PRI(PlayerReplicationInfo) != None) && TO_PRI(PlayerReplicationInfo).IsIgnored( Sender ) )
		return;

	Super.ClientVoiceMessage(Sender, Recipient, messagetype, messageID);
}


// Updated to avoid affecting the bob value directly (since we change it when zooming)
function UpdateBob(float F)
{
	OriginalBob = FClamp(F,0,0.032);
	if ( !bSZoom )
		Bob = OriginalBob;
}


///////////////////////////////////////
// ServerSetAutoReload
///////////////////////////////////////

function ServerSetAutoReload(bool bval)
{
	bAutomaticReload = bval;
}


///////////////////////////////////////
// ServerSetHideDeathMsg
///////////////////////////////////////

function ServerSetHideDeathMsg(bool bval)
{
	bHideDeathMsg = bval;
}


///////////////////////////////////////
// Possess
///////////////////////////////////////

simulated event Possess()
{
	Super.Possess();

	// send default values to server
	if ( Role < Role_Authority )
	{
		ServerSetHideDeathMsg(bHideDeathMsg);
		ServerSetAutoReload(bAutomaticReload);
	}

	// Default Bob value
	Bob = OriginalBob;
}


///////////////////////////////////////
// UpdateEyeHeight
///////////////////////////////////////

event UpdateEyeHeight(float DeltaTime)
{
	local float smooth, bound;
	
	// smooth up/down stairs
	If( (Physics==PHYS_Walking) && !bJustLanded )
	{
		smooth = FMin(1.0, 10.0 * DeltaTime/Level.TimeDilation);
		EyeHeight = (EyeHeight - Location.Z + OldLocation.Z) * (1 - smooth) + ( ShakeVert + BaseEyeHeight) * smooth;
		bound = -0.5 * CollisionHeight;
		if (EyeHeight < bound)
			EyeHeight = bound;
		else
		{
			bound = CollisionHeight + FClamp((OldLocation.Z - Location.Z), 0.0, MaxStepHeight); 
			if ( EyeHeight > bound )
				EyeHeight = bound;
		}
	}
	else
	{
		smooth = FClamp(10.0 * DeltaTime/Level.TimeDilation, 0.35,1.0);
		bJustLanded = false;
		EyeHeight = EyeHeight * ( 1 - smooth) + (BaseEyeHeight + ShakeVert) * smooth;
	}


	// adjust FOV for weapon zooming
	if ( bZooming )
	{	
		ZoomLevel += DeltaTime * 1.0;
		if (ZoomLevel > 0.9)
			ZoomLevel = 0.9;
		DesiredFOV = FClamp(90.0 - (ZoomLevel * 88.0), 1, 170);
	}


	if ( bSZoom )
	{
		DesiredFOV = FClamp(90.0 - (SZoomVal * 88.0), 1, 170);
		if ( DefaultFOV != 90.0000 )
			DefaultFOV = 90.0000;
	}
	else
	{
		// Enlarging default field of view.
		DesiredFOV = 90.0000;
		FOVAngle = DesiredFOV;
		DefaultFOV = DesiredFOV;
	}

	// teleporters affect your FOV, so adjust it back down
	if ( FOVAngle != DesiredFOV )
	{
		if ( !bSZoomStraight )
		{
			if ( FOVAngle > DesiredFOV )
				FOVAngle = FOVAngle - FMax(7, 0.9 * DeltaTime * (FOVAngle - DesiredFOV)); 
			else 
				FOVAngle = FOVAngle - FMin(-7, 0.9 * DeltaTime * (FOVAngle - DesiredFOV)); 
			if ( Abs(FOVAngle - DesiredFOV) <= 10 )
				FOVAngle = DesiredFOV;
		}
		else
		{
			FOVAngle = DesiredFOV;
		}
	}
}


///////////////////////////////////////
// ToggleSZoom
///////////////////////////////////////

simulated function ToggleSZoom()
{
	//ClientPlaySound(Sound'scopezoom',, true);

	if ( bSZoom )
		EndSZoom();
	else
		StartSZoom();

//	ClientPlaySound(Sound'NV_on',, true);
}


///////////////////////////////////////
// StartSZoom
///////////////////////////////////////

simulated function StartSZoom()
{
	bSZoom = true;
	ServerSetbSZoom(true);
}


///////////////////////////////////////
// EndSZoom
///////////////////////////////////////

simulated function EndSZoom()
{
	if ( bSZoomStraight )
		FOVAngle = DefaultFOV;

	DesiredFOV = DefaultFOV;
	SZoomVal = 0.0;
	bSZoomStraight = false;
	bSZoom = false;
	Bob = OriginalBob;
	//Bob = 0.02;
	ServerSetbSZoom(false);
}


///////////////////////////////////////
// ServerSetbSZoom
///////////////////////////////////////

function ServerSetbSZoom( bool bVal )
{
	bSZoom = bVal;
}


///////////////////////////////////////
// SwitchToBestWeapon
///////////////////////////////////////

function ClientReStart()
{
	if ( bSZoom )
		ToggleSZoom();

	Super.ClientReStart();
}


///////////////////////////////////////
// SwitchToBestWeapon
///////////////////////////////////////

exec function bool SwitchToBestWeapon()
{
	local float rating;
	local int usealt;

	if ( Inventory == None )
		return false;

	if ( (Self != None) && bSZoom )
			ToggleSZoom();

	PendingWeapon = Inventory.RecommendWeapon(rating, usealt);
	if ( PendingWeapon == Weapon )
		PendingWeapon = None;
	if ( PendingWeapon == None )
		return false;

	if ( Weapon == None )
		ChangedWeapon();
	if ( Weapon != PendingWeapon )
		Weapon.PutDown();

	return (usealt > 0);
}


///////////////////////////////////////
// SwitchWeapon
///////////////////////////////////////

exec function SwitchWeapon (byte F )
{
	local weapon newWeapon;

	if ( (Self != None) && bSZoom )
		ToggleSZoom();

	if ( bShowMenu || Level.Pauser!="" )
	{
		if ( myHud != None )
			myHud.InputNumber(F);
		return;
	}
	if ( Inventory == None )
		return;
	if ( (Weapon != None) && (Weapon.Inventory != None) )
		newWeapon = Weapon.Inventory.WeaponChange(F);
	else
		newWeapon = None;	
	if ( newWeapon == None )
		newWeapon = Inventory.WeaponChange(F);
	if ( newWeapon == None )
		return;

	if ( Weapon == None )
	{
		PendingWeapon = newWeapon;
		ChangedWeapon();
	}
	else if ( Weapon != newWeapon )
	{
		PendingWeapon = newWeapon;
		if ( !Weapon.PutDown() )
			PendingWeapon = None;
	}
}


///////////////////////////////////////
// ChangedWeapon
///////////////////////////////////////

function ChangedWeapon()
{
	Super.ChangedWeapon();
	//if ( (Self != None) && bSZoom )
	//	ToggleSZoom();
}


///////////////////////////////////////
// s_kReload
///////////////////////////////////////

exec function s_kReload()
{
	// Cannot reload?
	if ( ( Weapon == None ) || !Weapon.IsA('s_Weapon') || !s_Weapon(Weapon).bUseClip 
		|| (s_Weapon(Weapon).ClipAmmo == s_Weapon(Weapon).ClipSize) || (s_Weapon(Weapon).RemainingClip < 1) )
		return;

	//log("s_BPlayer::s_kReload");
/*
	// Server call
	if ( Level.NetMode == NM_Client )
	{
		//log("s_BPlayer::s_kReload - Server call");
		s_ReloadW();
	}
*/
	//log("s_BPlayer::s_kReload - client call");
	s_Weapon(Weapon).s_ReloadW();
}


///////////////////////////////////////
// ClientReloadW
///////////////////////////////////////

simulated function ClientReloadW()
{
	if ( Role == Role_Authority )
		return;

	//log("s_BPlayer::ClientReloadW");

/*	if ( ( Weapon != None ) && (Weapon.IsA('s_Weapon')) 
			&& s_Weapon(Weapon).bUseClip
			&& (s_Weapon(Weapon).ClipAmmo != s_Weapon(Weapon).ClipSize ) 
			&& !s_Weapon(Weapon).IsInState('ReloadWeapon') )

		{*/
	

	//if ( Level.NetMode == NM_Client )
	s_Weapon(Weapon).s_ReloadW();
//		}
}


///////////////////////////////////////
// s_kChangeFireMode
///////////////////////////////////////

exec function s_kChangeFireMode()
{
	// Cannot change fire mode?
	if ( ( Weapon == None ) || !Weapon.IsA('s_Weapon') || !s_Weapon(Weapon).bUseFireModes )
		return;

	//log("s_BPlayer::s_kChangeFireMode");
	//log("W:"@Weapon@"S:"@Weapon.GetStateName());

	// Server call
	if ( Role < Role_Authority )
		s_ChangeFireMode();

//	 /*&& !s_Weapon(Weapon).IsInState('ChangeFireMode')*/ )
	//log("calling ChangeFireMode");
	s_Weapon(Weapon).ChangeFireMode();
	//log("ChangeFireMode called");
}


///////////////////////////////////////
// s_ChangeFireMode
///////////////////////////////////////

function s_ChangeFireMode()
{
	//log("s_BPlayer::s_ChangeFireMode");
//	if ( ( Weapon != None ) && Weapon.IsA('s_Weapon') /*&& !s_Weapon(Weapon).IsInState('ChangeFireMode')*/ )
	s_Weapon(Weapon).ChangeFireMode();
}


///////////////////////////////////////
// s_kFlashlight 
///////////////////////////////////////

exec function s_kFlashlight()
{
	s_Flashlight();
}


///////////////////////////////////////
// s_Flashlight 
///////////////////////////////////////

function s_Flashlight()
{
	if ( Role < Role_Authority )
		return;

	if ( FlashLight == None )
	{
		FlashLight = Spawn(class's_SWAT.TO_FLightChild', Self, , Location, Rotation);
		PlaySound(Sound'UnrealShare.Pickups.FSHLITE1');
	}
	else
	{
		PlaySound(Sound'UnrealShare.Pickups.FSHLITE2');
		FlashLight.destroy();
		FlashLight = None;
	}
}


///////////////////////////////////////
// PlayerInput
///////////////////////////////////////

event PlayerInput( float DeltaTime )
{
	// Disable dodging
	DodgeDir = DODGE_Done;
	DodgeClickTimer = 0.0;

	Super.PlayerInput(DeltaTime);
}


///////////////////////////////////////
// PreCacheReferences
///////////////////////////////////////

function PreCacheReferences()
{
	//never called - here to force precaching of meshes
	spawn(class's_Player_T');
	spawn(class's_BotMCounterTerrorist1');

	spawn(class's_Knife');

	spawn(class's_Glock');
	spawn(class's_deagle');
	spawn(class'TO_Berreta');

	spawn(class's_MAC10');
	spawn(class's_MP5N');
	spawn(class'TO_MP5kPDW');
	spawn(class's_MossBerg');
	spawn(class's_m3');
	spawn(class'TO_Saiga');

	spawn(class's_Ak47');
	spawn(class'TO_hk33');
	spawn(class's_FAMAS');
	spawn(class's_hksr9');
	spawn(class's_Psg1');
	spawn(class'TO_SteyrAug');
	spawn(class's_p85');
	spawn(class's_OICW');
	spawn(class'TO_M4m203');
		
	spawn(class'TO_Grenade');
}


///////////////////////////////////////
// PlayerWalking
///////////////////////////////////////

state PlayerWalking
{
ignores SeePlayer, HearNoise, Bump;

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
	}

}


///////////////////////////////////////
// PlayerSwimming
///////////////////////////////////////

state PlayerSwimming
{
ignores SeePlayer, HearNoise, Bump;

	event PlayerTick( float DeltaTime )
	{
		if ( bDoRecoil )
		{
			bDoRecoil = false;
			if ( (Weapon != None) && (s_Weapon(Weapon) != None) )
				s_Weapon(Weapon).Recoil();
		}

		// CenterView cheat hack
		bCenterView = false;

		Super.PlayerTick( DeltaTime );
	}

	event UpdateEyeHeight(float DeltaTime)
	{
		local float smooth, bound;
		
		// smooth up/down stairs
		if( !bJustLanded )
		{
			smooth = FMin(1.0, 10.0 * DeltaTime/Level.TimeDilation);
			EyeHeight = (EyeHeight - Location.Z + OldLocation.Z) * (1 - smooth) + ( ShakeVert + BaseEyeHeight) * smooth;
			bound = -0.5 * CollisionHeight;
			if (EyeHeight < bound)
				EyeHeight = bound;
			else
			{
				bound = CollisionHeight + FClamp((OldLocation.Z - Location.Z), 0.0, MaxStepHeight); 
				 if ( EyeHeight > bound )
					EyeHeight = bound;
			}
		}
		else
		{
			smooth = FClamp(10.0 * DeltaTime/Level.TimeDilation, 0.35, 1.0);
			bJustLanded = false;
			EyeHeight = EyeHeight * ( 1 - smooth) + (BaseEyeHeight + ShakeVert) * smooth;
		}

		// adjust FOV for weapon zooming
		if ( bZooming )
		{	
			ZoomLevel += DeltaTime * 1.0;
			if (ZoomLevel > 0.9)
				ZoomLevel = 0.9;
			DesiredFOV = FClamp(90.0 - (ZoomLevel * 88.0), 1, 170);
		} 

		if ( bSZoom )
		{
			DesiredFOV = FClamp(90.0 - (SZoomVal * 88.0), 1, 170);
			if (DefaultFOV != 90.0000)
				DefaultFOV = 90.0000;
		}
		else if ( DesiredFOV != 90.0000 )
		{
			// Enlarging default field of view.
			DesiredFOV = 90.0000;
			FOVAngle = DesiredFOV;
			DefaultFOV = DesiredFOV;
		}

		// teleporters affect your FOV, so adjust it back down
		if ( FOVAngle != DesiredFOV )
		{
			if ( !bSZoomStraight )
			{
				if ( FOVAngle > DesiredFOV )
					FOVAngle = FOVAngle - FMax(7, 0.9 * DeltaTime * (FOVAngle - DesiredFOV)); 
				else 
					FOVAngle = FOVAngle - FMin(-7, 0.9 * DeltaTime * (FOVAngle - DesiredFOV)); 
				if ( Abs(FOVAngle - DesiredFOV) <= 10 )
					FOVAngle = DesiredFOV;
			}
			else
			{
				FOVAngle = DesiredFOV;
			}
		}
	}
}

/*
///////////////////////////////////////
// BaseChange
///////////////////////////////////////

singular event BaseChange()
{
	local float decorMass;

	if ( (base == None) && (Physics == PHYS_None) )
		SetPhysics(PHYS_Falling);
	// Don't give damage to other players
	else if (Pawn(Base) != None)
	{
		Base.TakeDamage( (1-Velocity.Z/400)* Mass/Base.Mass, Self,Location,0.5 * Velocity , 'stomped');
		JumpOffPawn();
	}
	else if ( (Decoration(Base) != None) && (Velocity.Z < -400) )
	{
		decorMass = FMax(Decoration(Base).Mass, 1);
		Base.TakeDamage((-2* Mass/decorMass * Velocity.Z/400), Self, Location, 0.5 * Velocity, 'stomped');
	}
}
*/

///////////////////////////////////////
// defaultproperties
///////////////////////////////////////
// bAlwaysRelevant=true

defaultproperties
{
     OriginalBob=0.020000
}
