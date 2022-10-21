//=============================================================================
// TO_ConsoleTimerPN
//=============================================================================
//
// Tactical Ops
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen
//=============================================================================

class TO_ConsoleTimerPN extends NavigationPoint;

var()	name							ConsoleTimer;
var		TO_ConsoleTimer		CTActor;
var		TO_ConsoleTimerPN	NextCTLink;


///////////////////////////////////////
// PreBeginPlay 
///////////////////////////////////////

function PreBeginPlay()
{
	local	TO_ConsoleTimer	A;

	if ( ConsoleTimer != '' )
	{
		foreach AllActors(class'TO_ConsoleTimer', A)
			if ( A.Tag == ConsoleTimer )
			{
				CTActor = A;
				break;
			}
	}
	
	Super.PreBeginPlay();
}


///////////////////////////////////////
// PostBeginPlay 
///////////////////////////////////////

function PostBeginPlay()
{
	local TO_ConsoleTimerPN		CT;
	local	s_SWATGame				SW;
	local	int								i;

	Super.PostBeginPlay();

	SW = s_SWATGame(Level.Game);

	// Register TO_ConsoleTimer in s_SWATGame
	if (SW == None)
		log("TO_ConsoleTimerPN - s_SWATGame(Level.Game) == None "$Level.Game);
	else 
	{
		if (SW.CTLink == None)
		{
			SW.CTLink = Self;
			return;
		}

		for ( CT=SW.CTLink; CT!=None; CT=CT.NextCTLink)
		{
			if ( CT.NextCTLink == None )
			{
				CT.NextCTLink = Self;
				return;
			}
			i++;
			if (i>100)
				break;
		}

		log("TO_ConsoleTimer - Couldn't register class");
	}
}

defaultproperties
{
}
