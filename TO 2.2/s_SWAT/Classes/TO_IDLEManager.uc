//=============================================================================
// TO_IDLEManager
//=============================================================================
//
// Tactical Ops
// - http://www.planetunreal.com/tacticalops
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen and Benoit "JAH" Delayen
//=============================================================================

class TO_IDLEManager expands Actor;

var		bool		bCheckType;


///////////////////////////////////////
// PostBeginPlay
///////////////////////////////////////

function	PostBeginPlay()
{
	SetTimer(2.5, true);
}


///////////////////////////////////////
// Timer
///////////////////////////////////////

function Timer()
{
	if ( s_SWATGame(Level.Game).GamePeriod != GP_RoundPlaying )
		return;

	if ( bCheckType )
		CheckPlayers();
	else
		CheckBots();

	bCheckType = !bCheckType;
}


///////////////////////////////////////
// CheckPlayers
///////////////////////////////////////

final function CheckPlayers()
{
	local	TO_PRI		TOPRI;
	local	s_Player	P;

	if ( Level.NetMode == NM_Standalone )
		return;

	foreach	AllActors(class's_Player', P)
	{
		if ( P.bNotPlaying )
			return;

		TOPRI = TO_PRI(P.PlayerReplicationInfo);
		if ( TOPRI != None )
		{
			if ( P.Location == TOPRI.IDOldLocation )
				TOPRI.IDWarnings++;
			else 
			{
				TOPRI.IDWarnings = 0;
				//TOPRI.IDDeaths = 0;
				continue;
			}

			TOPRI.IDOldLocation = P.Location;

			if ( TOPRI.IDWarnings == 4 )
			{
				if ( TOPRI.IDDeaths < 2 )
					P.ReceiveLocalizedMessage(class's_MessageVote', 2);
				else
					P.ReceiveLocalizedMessage(class's_MessageVote', 3);
			}
			else if ( TOPRI.IDWarnings == 5 )
			{
				if ( TOPRI.IDDeaths < 2 )
					P.ReceiveLocalizedMessage(class's_MessageVote', 4);
				else
					P.ReceiveLocalizedMessage(class's_MessageVote', 5);
			}
			else if ( TOPRI.IDWarnings == 6 )
			{
				if ( TOPRI.IDDeaths < 2 )
				{
					P.Died( None, 'Suicided', P.Location );
					TOPRI.IDWarnings = 0;
				}
				else
					P.Destroy();
			}
		}
	}
}


///////////////////////////////////////
// CheckBots
///////////////////////////////////////

final function CheckBots()
{
	// Check for bots stuck in the level
	// maybe check with animsequence and location.
	//ResetBotObjective(B, 0.0);
}


///////////////////////////////////////
// defaultproperties 
///////////////////////////////////////

defaultproperties
{
     bHidden=True
     DrawType=DT_None
     Texture=None
}
