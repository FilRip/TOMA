//=============================================================================
// TO_SysPlayer
//=============================================================================
//
// Tactical Ops
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen
//=============================================================================

class TO_SysPlayer extends TournamentPlayer
	abstract;


// implement view rotation here

var		TO_TeamSelect			StartMenu;
var		bool	bUseKey;				// Use Key pressed?

var byte	zzbFire;				// Retain last fire value
var byte	zzbAltFire;			// Retain last Alt Fire Value
var bool	zzbValidFire;		// Tells when Fire() is valid


simulated function s_ChangeTeam(int num, int team, bool bDie) {}


///////////////////////////////////////
// replication 
///////////////////////////////////////

replication 
{
	// Client->Server replication
  reliable if( Role < ROLE_Authority)
  	s_ChangeTeam;
}


///////////////////////////////////////
// UsePress
///////////////////////////////////////

simulated function UsePress()
{
	bUseKey = true;
}


///////////////////////////////////////
// UseRelease
///////////////////////////////////////

simulated function UseRelease()
{
	bUseKey = false;
}


///////////////////////////////////////
// ForceTempKickBan
///////////////////////////////////////

function ForceTempKickBan( String Reason ) {}


///////////////////////////////////////
// Possess
///////////////////////////////////////

event Possess()
{
	if ( Level.Netmode == NM_Client )
	{
		// replicate client weapon preferences to server
		ServerNeverSwitchOnPickup(bNeverAutoSwitch);
		ServerSetHandedness(Handedness);
		UpdateWeaponPriorities();
	}

	ServerUpdateWeapons();
	bIsPlayer = true;
	DodgeClickTime = FMin(0.3, DodgeClickTime);
	EyeHeight = BaseEyeHeight;
	NetPriority = 3;

	if ( (Level.Game != None) && !Level.Game.IsA('s_SWATGame') )
	{
		StartWalk();

		if ( Handedness == 1 )
			LoadLeftHand();
	}
	else if ( (Role == Role_Authority) && (Level.NetMode != NM_StandAlone) )
		Spawn(class'TOPModels.TO_Protect', Self);

	if ( Level.Netmode == NM_Client )
	{
		ServerSetTaunt(bAutoTaunt);
		if ( (Level.Game != None) && !Level.Game.IsA('s_SWATGame') )
			ServerSetInstantRocket(bInstantRocket);
	}

	//log("TO_SysPlayer::EndPossess");
}


///////////////////////////////////////
// Fire
///////////////////////////////////////
// The player wants to fire.
exec function Fire( optional float F )
{
	//log("s_Player::Fire");
	if ( (Role < ROLE_Authority) && !zzbValidFire )
		return;

	bJustFired = true;
	if ( bShowMenu || (Level.Pauser != "") || (Role < ROLE_Authority) )
	{
		if ( (Role < ROLE_Authority) && (Weapon != None) )
		{
			//log("s_Player::Fire - ClientFire");
			bJustFired = Weapon.ClientFire(F);	
		}

		if ( !bShowMenu && (Level.Pauser == PlayerReplicationInfo.PlayerName)  )
			SetPause(false);

		return;
	}

	if ( Weapon != None )
	{
		Weapon.bPointing = true;
		//log("s_Player - Fire - Calling Weapon.Fire");
		PlayFiring();
		Weapon.Fire(F);
	}
}


///////////////////////////////////////
// AltFire
///////////////////////////////////////
// The player wants to alternate-fire.
exec function AltFire( optional float F )
{
	if ( (Role < ROLE_Authority) && !zzbValidFire )
		return;

	bJustAltFired = true;
	if ( bShowMenu || (Level.Pauser!="") || (Role < ROLE_Authority) )
	{
		if ( (Role < ROLE_Authority) && (Weapon!=None) )
			bJustAltFired = Weapon.ClientAltFire(F);
		if ( !bShowMenu && (Level.Pauser == PlayerReplicationInfo.PlayerName) )
			SetPause(False);
		return;
	}

	if ( Weapon != None )
	{
		Weapon.bPointing = true;
		//PlayFiring();
		Weapon.AltFire(F);
	}
}


////////////////////////////
// Tracebot stopper: By DB
////////////////////////////

function xxStopTracebot()
{
	if ( !zzbValidFire )
	{
		zzbValidFire = true;
		bFire = zzbFire;
		bAltFire = zzbAltFire;
		bJustFired = false;
		bJustAltFired = false;
	}
}


//
// Replicate this client's desired movement to the server.
//
function ReplicateMove
(
	float DeltaTime, 
	vector NewAccel, 
	eDodgeDir DodgeMove, 
	rotator DeltaRot
)
{
	local SavedMove NewMove, OldMove, LastMove;
	local byte ClientRoll;
	local int i;
	local float OldTimeDelta, TotalTime, NetMoveDelta;
	local int OldAccel;
	local vector BuildAccel, AccelNorm;

	local float AdjPCol;
	local pawn P;
	local vector Dir;

	// Get a SavedMove actor to store the movement in.
	if ( PendingMove != None )
	{
		//add this move to the pending move
		PendingMove.TimeStamp = Level.TimeSeconds; 
		if ( VSize(NewAccel) > 3072 )
			NewAccel = 3072 * Normal(NewAccel);
		TotalTime = PendingMove.Delta + DeltaTime;
		PendingMove.Acceleration = (DeltaTime * NewAccel + PendingMove.Delta * PendingMove.Acceleration)/TotalTime;

		// Set this move's data.
		if ( PendingMove.DodgeMove == DODGE_None )
			PendingMove.DodgeMove = DodgeMove;
		PendingMove.bRun = (bRun > 0);
		PendingMove.bDuck = (bDuck > 0);
		PendingMove.bPressedJump = bPressedJump || PendingMove.bPressedJump;
		PendingMove.bFire = PendingMove.bFire || bJustFired || (bFire != 0);
		PendingMove.bForceFire = PendingMove.bForceFire || bJustFired;
		PendingMove.bAltFire = PendingMove.bAltFire || bJustAltFired || (bAltFire != 0);
		PendingMove.bForceAltFire = PendingMove.bForceAltFire || bJustFired;
		PendingMove.Delta = TotalTime;
	}
	if ( SavedMoves != None )
	{
		NewMove = SavedMoves;
		AccelNorm = Normal(NewAccel);
		while ( NewMove.NextMove != None )
		{
			// find most recent interesting move to send redundantly
			if ( NewMove.bPressedJump || ((NewMove.DodgeMove != Dodge_NONE) && (NewMove.DodgeMove < 5))
				|| ((NewMove.Acceleration != NewAccel) && ((normal(NewMove.Acceleration) Dot AccelNorm) < 0.95)) )
				OldMove = NewMove;
			NewMove = NewMove.NextMove;
		}
		if ( NewMove.bPressedJump || ((NewMove.DodgeMove != Dodge_NONE) && (NewMove.DodgeMove < 5))
			|| ((NewMove.Acceleration != NewAccel) && ((normal(NewMove.Acceleration) Dot AccelNorm) < 0.95)) )
			OldMove = NewMove;
	}

	LastMove = NewMove;
	NewMove = GetFreeMove();
	NewMove.Delta = DeltaTime;
	if ( VSize(NewAccel) > 3072 )
		NewAccel = 3072 * Normal(NewAccel);
	NewMove.Acceleration = NewAccel;

	// Set this move's data.
	NewMove.DodgeMove = DodgeMove;
	NewMove.TimeStamp = Level.TimeSeconds;
	NewMove.bRun = (bRun > 0);
	NewMove.bDuck = (bDuck > 0);
	NewMove.bPressedJump = bPressedJump;
	NewMove.bFire = (bJustFired || (bFire != 0));
	NewMove.bForceFire = bJustFired;
	NewMove.bAltFire = (bJustAltFired || (bAltFire != 0));
	NewMove.bForceAltFire = bJustAltFired;
	if ( Weapon != None ) // approximate pointing so don't have to replicate
		Weapon.bPointing = ((bFire != 0) || (bAltFire != 0));
	bJustFired = false;
	bJustAltFired = false;
	
	// adjust radius of nearby players with uncertain location
	ForEach AllActors(class'Pawn', P)
		if ( (P != self) && (P.Velocity != vect(0,0,0)) && P.bBlockPlayers )
		{
			Dir = Normal(P.Location - Location);
			if ( (Velocity Dot Dir > 0) && (P.Velocity Dot Dir > 0) )
			{
				// if other pawn moving away from player, push it away if its close
				// since the client-side position is behind the server side position
				if ( VSize(P.Location - Location) < P.CollisionRadius + CollisionRadius + NewMove.Delta * GroundSpeed )
					// SHAG: fixing EPIC bug!
					//P.MoveSmooth(P.Velocity * 0.5 * PlayerReplicationInfo.Ping);
					P.MoveSmooth(P.Velocity * (PlayerReplicationInfo.Ping/1000));
			}
		} 

	// Simulate the movement locally.
	ProcessMove(NewMove.Delta, NewMove.Acceleration, NewMove.DodgeMove, DeltaRot);
	AutonomousPhysics(NewMove.Delta);

	if ( Role < ROLE_Authority )
	{
		zzbValidFire = false;
		zzbFire = bFire;
		zzbAltFire = bAltFire;
	}

	//log("Role "$Role$" repmove at "$Level.TimeSeconds$" Move time "$100 * DeltaTime$" ("$Level.TimeDilation$")");

	// Decide whether to hold off on move
	// send if dodge, jump, or fire unless really too soon, or if newmove.delta big enough
	// on client side, save extra buffered time in LastUpdateTime
	if ( PendingMove == None )
		PendingMove = NewMove;
	else
	{
		NewMove.NextMove = FreeMoves;
		FreeMoves = NewMove;
		FreeMoves.Clear();
		NewMove = PendingMove;
	}
	NetMoveDelta = FMax(64.0/Player.CurrentNetSpeed, 0.011);
	
	if ( !PendingMove.bForceFire && !PendingMove.bForceAltFire && !PendingMove.bPressedJump
		&& (PendingMove.Delta < NetMoveDelta - ClientUpdateTime) )
	{
		// save as pending move
		return;
	}
	else if ( (ClientUpdateTime < 0) && (PendingMove.Delta < NetMoveDelta - ClientUpdateTime) )
		return;
	else
	{
		ClientUpdateTime = PendingMove.Delta - NetMoveDelta;
		if ( SavedMoves == None )
			SavedMoves = PendingMove;
		else
			LastMove.NextMove = PendingMove;
		PendingMove = None;
	}

	// check if need to redundantly send previous move
	if ( OldMove != None )
	{
		// log("Redundant send timestamp "$OldMove.TimeStamp$" accel "$OldMove.Acceleration$" at "$Level.Timeseconds$" New accel "$NewAccel);
		// old move important to replicate redundantly
		OldTimeDelta = FMin(255, (Level.TimeSeconds - OldMove.TimeStamp) * 500);
		BuildAccel = 0.05 * OldMove.Acceleration + vect(0.5, 0.5, 0.5);
		OldAccel = (CompressAccel(BuildAccel.X) << 23) 
					+ (CompressAccel(BuildAccel.Y) << 15) 
					+ (CompressAccel(BuildAccel.Z) << 7);
		if ( OldMove.bRun )
			OldAccel += 64;
		if ( OldMove.bDuck )
			OldAccel += 32;
		if ( OldMove.bPressedJump )
			OldAccel += 16;
		OldAccel += OldMove.DodgeMove;
	}
	//else
	//	log("No redundant timestamp at "$Level.TimeSeconds$" with accel "$NewAccel);

	// Send to the server
	ClientRoll = (Rotation.Roll >> 8) & 255;
	if ( NewMove.bPressedJump )
		bJumpStatus = !bJumpStatus;
	ServerMove
	(
		NewMove.TimeStamp, 
		NewMove.Acceleration * 10, 
		Location, 
		NewMove.bRun,
		NewMove.bDuck,
		bJumpStatus, 
		NewMove.bFire,
		NewMove.bAltFire,
		NewMove.bForceFire,
		NewMove.bForceAltFire,
		NewMove.DodgeMove, 
		ClientRoll,
		(32767 & (ViewRotation.Pitch/2)) * 32768 + (32767 & (ViewRotation.Yaw/2)),
		OldTimeDelta,
		OldAccel 
	);
	//log("Replicated "$self$" stamp "$NewMove.TimeStamp$" location "$Location$" dodge "$NewMove.DodgeMove$" to "$DodgeDir);
}

defaultproperties
{
}
