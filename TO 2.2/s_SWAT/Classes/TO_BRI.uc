//=============================================================================
// TO_BRI
//=============================================================================
//
// Tactical Ops
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen
//=============================================================================

class TO_BRI extends BotReplicationInfo;

var		bool		bEscaped, bHasBomb;

// IDLE manager
var		vector	IDOldLocation;
var		byte		IDWarnings;
 
///////////////////////////////////////
// replication 
///////////////////////////////////////

replication 
{
	// Server send to client 
	reliable if( Role==ROLE_Authority )
		bEscaped, bHasBomb;
}


///////////////////////////////////////
// defaultproperties 
///////////////////////////////////////

defaultproperties
{
}
