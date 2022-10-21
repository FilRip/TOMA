//=============================================================================
// TO_RoundWinning
//=============================================================================
//
// Tactical Ops
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen
//=============================================================================
// Actor which can be triggered to end the round
// Add reward support

class TO_RoundWinning extends TacticalOpsMapActors;

var()	ETeams	Winner;
var()	string	WinningMessage;
var()	int			WinAmount;


///////////////////////////////////////
// Trigger 
///////////////////////////////////////

function Trigger( actor Other, pawn EventInstigator )
{
	local	s_SWATGame		SG;
	local	byte					winteam;
	local	Actor					A;

	SG = s_SWATGame(Level.Game);

	if ( SG == None )
	{
		log("TO_RoundWinning - Trigger - SG == None");
		return;
	}
	
	if ( !IsRoundPeriodPlaying() )
		return;

	// Broadcast the Trigger message to all matching actors.
	if ( Event != '' )
		foreach AllActors( class 'Actor', A, Event )
			A.Trigger( Other, EventInstigator );

	if ( Winner != ET_Both )
	{
		winteam = Winner;
		SG.WinAmount += WinAmount;
		SG.SetWinner(winteam);
	}
	else
		SG.SetWinner(2);

	SG.BroadcastLocalizedMessage(class'TO_MessageCustom', 0, None, None, Self);
	SG.EndGame(WinningMessage);
	//SG.BroadcastLocalizedMessage(class's_MessageRoundWinner', 1);

}


///////////////////////////////////////
// defaultproperties 
///////////////////////////////////////

defaultproperties
{
     WinningMessage="Terrorists won the round!"
     WinAmount=1000
}
