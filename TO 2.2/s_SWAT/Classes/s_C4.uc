//=============================================================================
// s_C4
//=============================================================================
//
// Tactical Ops 
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen
//=============================================================================

class s_C4 extends s_Weapon;

var	bool	bPlanted;
var	bool	bCanPlant;


///////////////////////////////////////
// replication 
///////////////////////////////////////

replication 
{
	// Functions server calls on clients
	reliable if( Role == ROLE_Authority)
		ForceClientFinish;
}


///////////////////////////////////////
// RateSelf
///////////////////////////////////////

function float RateSelf( out int bUseAltMode )
{
	return -10.0;
}


///////////////////////////////////////
// SwitchPriority
///////////////////////////////////////

function float SwitchPriority()
{
	return -10.0;
}


///////////////////////////////////////
// BotDesireability 
///////////////////////////////////////
// Only Terrorists can pick up the C4

event float BotDesireability(Pawn Bot)
{
	if ( Bot.IsA('s_Bot') && (Bot.PlayerReplicationInfo.Team != 0) )
			return 0.0;
	else
		return Super.BotDesireability(Bot);
}


///////////////////////////////////////
// DropBomb
///////////////////////////////////////

function DropBomb( bool bmessage )
{
	Local Pawn P;
	local	TO_PRI								TOPRI;
	local	TO_BRI								TOBRI;
	local	s_SWATGame						SG;
	local	PlayerReplicationInfo	PRI;

	SG = s_SWATGame(Level.game);
	P = Pawn(Owner);

	//log("s_C4 - DropBomb");

	if ( (P != None) && (P.PlayerReplicationInfo != None) )
	{
		TOPRI = TO_PRI(P.PlayerReplicationInfo);
		TOBRI = TO_BRI(P.PlayerReplicationInfo);

		if ( TOPRI != None )
		{
			TOPRI.bHasBomb = false;
			PRI = TOPRI;
		}
		else if ( TOBRI != None )
		{
			TOBRI.bHasBomb = false;
			PRI = TOBRI;
		}
	}	

	if ( SG.IsRoundPeriodPlaying() )
	{
		if ( bMessage )
		{
			if (SG != None )
				SG.BroadcastLocalizedMessage(class's_MessageRoundWinner', 11, PRI);

			// Tell Ts to pickup C4
			SG.SendGlobalBotObjective( Self, 1.0, 0, 'O_GotoLocation', false);
			SG.bBombDropped = true;
		}
	}
}


///////////////////////////////////////
// Destroyed
///////////////////////////////////////

event Destroyed()
{
//	if ( !bPlanted )
		DropBomb( false );

	AmbientSound = None;

	Super.Destroyed();
}


///////////////////////////////////////
// DropFrom
///////////////////////////////////////

function DropFrom(vector StartLocation)
{
	if ( !bPlanted && !bNoDrop )
		DropBomb( true );

	Super.DropFrom(StartLocation);
}


///////////////////////////////////////
// GiveTo
///////////////////////////////////////

function GiveTo( Pawn Other )
{
	Local Pawn P;
	local	TO_PRI				TOPRI;
	local	TO_BRI				TOBRI;
	local	s_SWATGame		SG;

	SG = s_SWATGame(Level.game);

	Super.GiveTo( Other );

	//log("s_C4 - GiveTo - P:"@Other);

	P = Other;
	if ( (P != None) && (P.PlayerReplicationInfo != None) )
	{
		TOPRI = TO_PRI(P.PlayerReplicationInfo);
		TOBRI = TO_BRI(P.PlayerReplicationInfo);

		if ( TOPRI != None )
			TOPRI.bHasBomb = true;
		else if ( TOBRI != None )
			TOBRI.bHasBomb = true;
	}

	SG.bBombDropped = false;
}


///////////////////////////////////////
// Fire
///////////////////////////////////////

function Fire(float Value)
{
	if ( !IsInBombingSpot() )
		return;

	PlayFiring();
	GotoState('ServerArmingBomb');
	bCanPlant = true;
	ClientForceFire();
}


/*
///////////////////////////////////////
// ClientFire
///////////////////////////////////////

simulated function bool ClientFire( float Value )
{
	if ( !IsInBombingSpot() )
		return false;

	log("s_C4 - ClientFire");

	PlayFiring();
	if ( Level.NetMode == NM_Client )
		GotoState('ClientArmingBomb');

	return true;
}
*/

simulated function bool ClientFire( float Value ) { return false; }

// Called from playerpawn, client side.
simulated function ForceClientFire()
{
	//log("s_C4::ForceClientFire");
	if ( Level.NetMode == NM_Client )
	{
		PlayFiring();
		GotoState('ClientArmingBomb');
	}
}



///////////////////////////////////////
// ClientForceFire
///////////////////////////////////////

function ClientForceFire()
{
	// Check to avoid being called from state Active
	if ( bCanPlant )
	{
		bCanPlant = false;
		TournamentPlayer(Owner).SendFire(self);
	}
	/*
	//log("s_C4::ClientForceFire");
	PlayFiring();

	if ( Level.NetMode == NM_Client )
		GotoState('ClientArmingBomb');
	*/
}



///////////////////////////////////////
// PlayFiring
///////////////////////////////////////

simulated function PlayFiring()
{
	PlayAnim('Fire', 0.5);
}


///////////////////////////////////////
// PlayC4Arming
///////////////////////////////////////

simulated function PlayC4Arming()
{
	AmbientSound = Sound'TODatas.bomb_set_seq';
}


///////////////////////////////////////
// ClientArmingBomb
///////////////////////////////////////

state ClientArmingBomb
{
	ignores ChangeFireMode, s_ReloadW;

	simulated function bool ClientFire( float Value ) { return false; }

	simulated function Tick( float DeltaTime )
	{
		Super.Tick( DeltaTime );

		// Arming sequence aborted
		if ( (Pawn(Owner) == None) || (Pawn(Owner).bFire == 0) )
		{
			AmbientSound = None;
			PlayIdleAnim();
			GotoState('');
		}
	}
/*
	function EndState()
	{
		//log("ArmingBomb - EndState");
		AmbientSound = None;
		PlayIdleAnim();
		GotoState('');
	}
*/
	simulated function AnimEnd()
	{
		//log("s_C4::ClientArmingBomb::AnimEnd");
		//PlayIdleAnim();
		AmbientSound = None;
		PlayIdleAnim();
		GotoState('');
	}

	simulated function EndState()
	{
		AmbientSound = None;
	}

}


///////////////////////////////////////
// ServerArmingBomb
///////////////////////////////////////

state ServerArmingBomb
{
	ignores ChangeFireMode, s_ReloadW;

	function Fire(float F) {}

	simulated function Tick( float DeltaTime )
	{
		Super.Tick( DeltaTime );

		// Arming sequence aborted
		if ( (Pawn(Owner) == None) || (Pawn(Owner).bFire == 0) )
		{
			AmbientSound = None;
			//bNeedFix = true;
			Finish();
		}

		// Outside of C4 zone
		if ( !IsInBombingSpot() )
		{
			AmbientSound = None;
			ForceClientFinish();
			Finish();
		}
	}

	simulated function AnimEnd()
	{
		AmbientSound = None;
		bNoDrop = true;
		PlaceC4();
	}

	simulated function EndState()
	{
		AmbientSound = None;
	}

Begin:

		//log("ServerArmingBomb - Begin");
		Sleep(0.0);
}


///////////////////////////////////////
// ForceClientFinish 
///////////////////////////////////////

simulated function ForceClientFinish()
{
	AmbientSound = None;
	PlayIdleAnim();
	GotoState('');
}


///////////////////////////////////////
// PlayIdleAnim 
///////////////////////////////////////

simulated function PlayIdleAnim()
{
	if ( Mesh == PickupViewMesh )
		return;

	if ( (FRand() > 0.98) && (AnimSequence != 'idle1') ) 
		PlayAnim('idle1', 0.15);
	else 
		LoopAnim('idle',0.2, 0.3);
}


///////////////////////////////////////
// PlayPostSelect
///////////////////////////////////////

simulated function PlayPostSelect()
{
	Super.PlayPostSelect();
	//bNeedFix = true;
}


///////////////////////////////////////
// IsInBombingSpot
///////////////////////////////////////

function bool IsInBombingSpot()
{
	local Pawn	PawnOwner;
	
	PawnOwner = Pawn(Owner);

	// Hack to test
	//return true;

	if ( PawnOwner.IsA('s_Player') && s_Player(PawnOwner).bInBombingZone )
		return true;
	else if ( PawnOwner.IsA('s_Bot') )
		return true;

	return false;
}


///////////////////////////////////////
// PlaceC4
///////////////////////////////////////

function PlaceC4()
{
	local Pawn					PawnOwner;
	local	s_ExplosiveC4	C4;
	local	s_SWATGame		SG;
	local	TO_PRI				TOPRI;
	local	TO_BRI				TOBRI;
	local	PlayerReplicationInfo	PRI;
	local	bool					bInBombingSpot;

	SG = s_SWATGame(Level.Game);

	if ( (SG != None)  && !SG.IsRoundPeriodPlaying() )
		return;

	bPlanted = true;
	PawnOwner = Pawn(Owner);
	bInBombingSpot = IsInBombingSpot();

	PawnOwner.SwitchToBestWeapon();
	PawnOwner.ChangedWeapon();

//	PawnOwner.ClientPutDown(self, PawnOwner.PendingWeapon);

	C4 = Spawn(class's_ExplosiveC4',,, Owner.Location, Owner.Rotation);
	C4.bPlantedInBombingSpot = bInBombingSpot;
	C4.PlaySound(Sound'TODatas.bomb_plant', SLOT_None);

	// Tell SFs to defuse C4
	SG.SendGlobalBotObjective( C4, 1.0, 1, 'O_DefuseC4', false);

	if ( ( SG != None ) && (PawnOwner != None) )
	{
		if ( PawnOwner.PlayerReplicationInfo != None )
		{
			TOPRI = TO_PRI(PawnOwner.PlayerReplicationInfo);
			TOBRI = TO_BRI(PawnOwner.PlayerReplicationInfo);

			if ( TOPRI != None )
			{
				TOPRI.bHasBomb = false;
				PRI = TOPRI;
			}
			else if ( TOBRI != None )
			{
				TOBRI.bHasBomb = false;
				PRI = TOBRI;
			}
		}

		// Not to finish round if all terrorists are dead. SF must defuse the bomb first.
		if ( bInBombingSpot )
			SG.bBombPlanted = true;

		SG.BroadcastLocalizedMessage(class's_MessageRoundWinner', 12, PRI);
	}

	Destroy();
}


///////////////////////////////////////
// defaultproperties 
///////////////////////////////////////

defaultproperties
{
     MaxDamage=60.000000
     bUseClip=False
     MaxClip=0
     ClipInc=0
     RoundPerMin=100
     price=800
     ClipPrice=0
     BotAimError=0.800000
     PlayerAimError=500.000000
     bHasMultiSkins=True
     ArmsNb=2
     WeaponID=5
     WeaponClass=10
     WeaponWeight=2.000000
     aReloadWeapon=(AnimSeq=Reload)
     MaxRange=120.000000
     WeaponDescription="Classification: C4 bomb"
     InstFlash=-0.200000
     InstFog=(X=325.000000,Y=225.000000,Z=95.000000)
     PickupAmmoCount=30
     bMeleeWeapon=True
     FiringSpeed=1.500000
     MyDamageType=shot
     shakemag=200.000000
     shakevert=4.000000
     AIRating=0.250000
     RefireRate=0.800000
     AltRefireRate=0.870000
     SelectSound=Sound'TODatas.Weapons.couteausorti'
     DeathMessage="%k riddled %o full of holes with the %w."
     NameColor=(R=200,G=200)
     FlashY=0.100000
     FlashO=0.008000
     FlashC=0.035000
     FlashLength=0.010000
     FlashS=128
     AutoSwitchPriority=10
     InventoryGroup=10
     PickupMessage="You picked up a C4 bomb!"
     ItemName="C4 Bomb"
     PlayerViewOffset=(X=100.000000,Y=-10.000000,Z=-150.000000)
     PlayerViewMesh=LodMesh'TOModels.C4'
     PlayerViewScale=0.100000
     PickupViewMesh=LodMesh'TOModels.pC4'
     ThirdPersonMesh=LodMesh'TOModels.wC4'
     MaxDesireability=3.000000
     PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
     Icon=None
     bHidden=True
     Mesh=LodMesh'TOModels.pC4'
     CollisionRadius=20.000000
     CollisionHeight=3.000000
     Mass=15.000000
}
