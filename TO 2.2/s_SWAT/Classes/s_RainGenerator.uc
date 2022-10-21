//=============================================================================
// s_RainGenerator
//=============================================================================
//
// Tactical Ops
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Greg '[DM]Matryx' Sweetman
//=============================================================================
// Enhanced by Laurent 'Shag' Delayen
//=============================================================================

class s_RainGenerator extends TacticalOpsMapActors;


enum ERainType
{
	RT_Rain,
	RT_Snow,
};

var()		float		interval;								// Seconds between drips
var()		float		variance;								// % size delta of drips
var()		float		DropSpeed;						  // % of speed
var()		int			dropradius;							// Radius around generator to drip in
var()		int			NumberOfDrips;					// Number of Drips to be spawned at each interval
var()		ERainType	RainType;							// Rain, Snow, ..

// Rain Specific
var(Rain)		bool		bMeshRainDrop;			// Uses 3Dmodels instead of sprites (rain only)

// Snow specific
var(Snow)		bool		bJerky;					// irregular movements
var(Snow)		int			Jerkyness;			// value

// Internal
var		bool	bProcessing;


///////////////////////////////////////
// defaultproperties 
///////////////////////////////////////

defaultproperties
{
     interval=0.100000
     variance=0.500000
     DropSpeed=1.000000
     dropradius=15
     NumberOfDrips=1
     Jerkyness=100
     Style=STY_None
}
