//=============================================================================
// TacticalOpsMapActors
//=============================================================================
//
// Tactical Ops
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen
//=============================================================================

class TacticalOpsMapActors extends Actor
	abstract;


enum ETeams
{
	ET_Terrorists,	
	ET_SpecialForces,	
	ET_Both,					
};


///////////////////////////////////////
// IsRoundPeriodPlaying
///////////////////////////////////////

final function bool IsRoundPeriodPlaying()
{
	local	s_SWATGame	SG;

	SG = s_SWATGame(Level.Game);
	if ( SG != None )
	{ 
		if ( SG.GamePeriod == GP_RoundPlaying )
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

}


///////////////////////////////////////
// defaultproperties 
///////////////////////////////////////

defaultproperties
{
     bStatic=True
     bHidden=True
     bStasis=True
     Texture=Texture'Engine.S_Keypoint'
}
