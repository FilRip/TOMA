//=============================================================================
// TO_MessageDisplay
//=============================================================================
//
// Tactical Ops
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen
//=============================================================================
  
class TO_MessageDisplay extends TacticalOpsMapActors;


enum ESendTo
{
	EST_Terrorists,	
	EST_SpecialForces,	
	EST_Both,					
};

var()	ESendTo	SendMessageTo;
var()	string	Message;


///////////////////////////////////////
// Trigger 
///////////////////////////////////////

function Trigger( actor Other, pawn EventInstigator )
{
	local	Pawn	P;
	local	PlayerPawn	PP;

	for ( P=Level.PawnList; P!=None; P=P.nextPawn )
	{
		PP = PlayerPawn(P);
		if (PP == None)
			continue;

		if ( (SendMessageTo == EST_Both) || 
			( (PP.PlayerReplicationInfo != None) && (PP.PlayerReplicationInfo.Team == SendMessageTo) ) )
			PP.ReceiveLocalizedMessage(class'TO_MessageCustom', 0, None, None, Self);
	}
}


///////////////////////////////////////
// defaultproperties 
///////////////////////////////////////

defaultproperties
{
     SendMessageTo=EST_Both
     Message="hello hello"
}
