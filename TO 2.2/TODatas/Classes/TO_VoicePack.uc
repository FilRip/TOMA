//=============================================================================
// TO_VoicePack
//=============================================================================
//
// Tactical Ops
// - http://www.tactical-ops.to
//
// Source code rights:
// Copyright (C) 2000-2002 Laurent "SHAG" Delayen
//=============================================================================

class TO_VoicePack expands VoiceMaleTwo;


///////////////////////////////////////
// ClientInitialize
///////////////////////////////////////

function ClientInitialize(PlayerReplicationInfo Sender, PlayerReplicationInfo Recipient, name messagetype, byte messageIndex)
{
	if (!Sender.bIsSpectator)
		Super.ClientInitialize(Sender, Recipient, messagetype, messageIndex);
}


///////////////////////////////////////
// defaultproperties
///////////////////////////////////////

defaultproperties
{
     NameSound(0)=None
     NameSound(1)=None
     NameSound(2)=None
     NameSound(3)=None
     NameTime(0)=0.000000
     NameTime(1)=0.000000
     NameTime(2)=0.000000
     NameTime(3)=0.000000
     LeaderSign(0)="Leader"
     LeaderSign(1)="Leader"
     LeaderSign(2)="Leader"
     LeaderSign(3)="Leader"
}
