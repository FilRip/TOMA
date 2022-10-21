//=============================================================================
// TO_MessageMutator
//=============================================================================
//
// Tactical Ops
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen
// Based on CSHP code.
//=============================================================================

class TO_MessageMutator expands Mutator;


// ==================================================================================
// MutatorBroadcastMessage - Stop Message Hacks
// ==================================================================================

function bool MutatorBroadcastMessage( Actor Sender,Pawn Receiver, out coerce string Msg, optional bool bBeep, out optional name Type )
{
	local Actor A;
	local bool legalspec;
	A = Sender;
	/*
	// Hack ... for AdminLogout() going in PHYS_Walking while state is 'PlayerWaiting'
	If (A.IsA('GameInfo') && Receiver != None && Receiver.PlayerReplicationInfo != None
			&& (Receiver.PlayerReplicationInfo.PlayerName@"gave up administrator abilities.") == Msg
			&& (Receiver.GetStateName() == 'PlayerWaiting' || Receiver.PlayerReplicationInfo.bIsSpectator))			

	{
		Receiver.GotoState('');
		Receiver.GotoState('PlayerWaiting');
	} 
	*/
	while (!A.isa('Pawn') && A.Owner != None)
		A=A.Owner;

	if (A.isa('spectator'))
		legalspec=((left(msg,len(spectator(A).playerreplicationinfo.playername)+1))==(spectator(A).playerreplicationinfo.playername$":") || A.IsA('MessagingSpectator'));		

	if (legalspec)
		 legalspec=(type=='Event');                
		 
	if (A.isa('Pawn') && !legalspec)
		return false;
                        
	return Super.MutatorBroadcastMessage( Sender,Receiver, Msg, bBeep );
}


// ==================================================================================
// MutatorBroadcastLocalizedMessage - Stop Message Hacks
// ==================================================================================
function bool MutatorBroadcastLocalizedMessage( Actor Sender, Pawn Receiver, out class<LocalMessage> Message, out optional int Switch, out optional PlayerReplicationInfo RelatedPRI_1, out optional PlayerReplicationInfo RelatedPRI_2, out optional Object OptionalObject )
{
	local Actor A;
	A = Sender;
	while (!A.isa('Pawn') && A.Owner != None) 
	  A=A.Owner;

	if (A.isa('Pawn'))
		return false;
	
	return Super.MutatorBroadcastLocalizedMessage( Sender, Receiver, Message, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject );

} // MutatorBroadcastLocalizedMessage

defaultproperties
{
}
