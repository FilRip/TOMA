//=============================================================================
// TO_PRI
//=============================================================================
//
// Tactical Ops
// - http://www.planetunreal.com/tacticalops
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen and Benoit "JAH" Delayen
//=============================================================================

class TO_PRI extends PlayerReplicationInfo;

// Gameplay
var		bool		bEscaped;
var		bool		bHasBomb;

// IDLE manager
var		vector	IDOldLocation;
var		byte		IDWarnings;
var		byte		IDDeaths;

// AdminLogin security
var		byte		AdminLoginTries;

// Vote
var		PlayerReplicationInfo		VoteFrom[48];

var		int		Ignored[48];

 
///////////////////////////////////////
// replication 
///////////////////////////////////////

replication 
{
	// Server send to client 
	reliable if( Role == ROLE_Authority )
		bEscaped, bHasBomb;
}


///////////////////////////////////////
// ClearVotes 
///////////////////////////////////////

final function	ClearVotes()
{
	local	byte	i;

	for (i=0; i<48; i++)
		VoteFrom[i] = None;
}


///////////////////////////////////////
// ClearIgnoreList 
///////////////////////////////////////

final simulated function	ClearIgnoreList()
{
	local	byte	i;

	for (i=0; i<48; i++)
		Ignored[i] = 0;
}


///////////////////////////////////////
// ToggleIgnored 
///////////////////////////////////////

final simulated function ToggleIgnored( int pid )
{
	local	int i, EmptySlot;
	local	TO_PRI	PRI, Found;
	local	Pawn	aPawn;

	//log("TO_PRI::ToggleIgnored");

	foreach allactors(class'TO_PRI', Found)
		if ( Found.PlayerID == pid )
		{
			//log("TO_PRI::ToggleIgnored - Found PRI"@Found.PlayerName@Found.PlayerID);
			PRI = Found;
			break;
		}

	// pid = 0 exists and it means an empty entry in our tab
	pid++;
	if ( PRI != None )
	{
		EmptySlot = 255;
		while ( i < 48 )
		{
			if ( Ignored[i] == pid )
			{
				//log("TO_PRI::ToggleIgnored - Listening to"@PRI.PlayerName);
				Ignored[i] = 0;
				Pawn(Owner).ClientMessage("Listening to"@PRI.PlayerName , 'Event', true);
				return;
			}

			if ( (EmptySlot == 255) && (Ignored[i] == 0) )
				EmptySlot = i;
			i++;
		}

		if ( EmptySlot != 255 )
		{
			//log("TO_PRI::ToggleIgnored - Ignoring"@PRI.PlayerName@EmptySlot@PRI);
			Ignored[EmptySlot] = pid;
			Pawn(Owner).ClientMessage("Ignoring"@PRI.PlayerName , 'Event', true);
		}
		else
			log("TO_PRI::ToggleIgnored - no empty slots left");
	}
//	else
//		log("TO_PRI::ToggleIgnored - PRI == None");
}


///////////////////////////////////////
// IsIgnored 
///////////////////////////////////////

final simulated function bool IsIgnored( PlayerReplicationInfo PRI )
{
	local	int i, pid;

	pid = PRI.PlayerID + 1;
	//log("TO_PRI::IsIgnored"@PRI@PRI.PlayerName@PRI.PlayerID);
	while ( i < 48 )
	{
		if ( Ignored[i] == pid )
		{
			//log("TO_PRI::IsIgnored - PRI found");
			return true;
		}
		i++;
	}

	//log("TO_PRI::IsIgnored - PRI not found");
	return false;
}


///////////////////////////////////////
// defaultproperties 
///////////////////////////////////////

defaultproperties
{
     NetUpdateFrequency=1.000000
}
