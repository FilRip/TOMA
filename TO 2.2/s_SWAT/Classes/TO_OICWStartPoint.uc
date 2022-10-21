//=============================================================================
// TO_OICWStartPoint
//=============================================================================
//
// Tactical Ops
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen
//=============================================================================

class  TO_OICWStartPoint extends TacticalOpsMapActors;

var()	ETeams	CanPickupOICW;


///////////////////////////////////////
// PostBeginPlay 
///////////////////////////////////////

function PostBeginPlay()
{
	Super.PostBeginPlay();

	OICWSetup();
}


///////////////////////////////////////
// Touch 
///////////////////////////////////////

simulated event Touch( Actor Other )
{
	local	Actor A;
	local	s_SWATGame SG;

	if ( (Role == Role_Authority) && IsRoundPeriodPlaying() && IsRevelant(Other) )
	{
		SG = s_SWATGame(Level.Game);

		if ( SG != None )
		{
			OICWPickedUp();

			SG.GiveWeapon(Pawn(Other), "s_SWAT.s_OICW");

			// Broadcast the Trigger message to all matching actors.
			if ( Event != '' )
				foreach AllActors(class'Actor', A, Event)
					A.Trigger(Self, Pawn(Other) );
		}

		else
			log("TO_OICWStartPoint::Touch - SG == None!");
	}
}


///////////////////////////////////////
// IsRevelant 
///////////////////////////////////////

function bool	IsRevelant(Actor Other)
{
	local	byte team;

	if ( Other.IsA('Pawn') )
	{
		team = CanPickupOICW;
		if ( (team == 2) || (Pawn(Other).PlayerReplicationInfo.Team == team) )
			return true;
	}

	return false;
}


///////////////////////////////////////
// RoundReset 
///////////////////////////////////////
// Reset actor every round.

function	RoundReset()
{
	OICWSetup();
}


///////////////////////////////////////
// OICWPickedUp 
///////////////////////////////////////

function	OICWPickedUp()
{
	bHidden = true;
	SetCollision(false, false, false);
}


///////////////////////////////////////
// OICWSetup 
///////////////////////////////////////

function OICWSetup()
{
	if ( !bHidden )
		return;

	bHidden = false;
	SetCollision(true, false, false);
}


///////////////////////////////////////
// defaultproperties 
///////////////////////////////////////

defaultproperties
{
     bStatic=False
     bStasis=False
     Physics=PHYS_Falling
     RemoteRole=ROLE_SimulatedProxy
     DrawType=DT_Mesh
     Mesh=LodMesh'TOModels.pOICW'
     AmbientGlow=255
     CollisionRadius=30.000000
     CollisionHeight=10.000000
     bCollideActors=True
     bCollideWorld=True
     NetPriority=2.700000
}
