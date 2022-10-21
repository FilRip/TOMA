//----------------------------------------------------------------------------
// Project : TOST
// File    : TOSTXSpectator.uc
// Version : 0.5
// Author  : BugBunny
//----------------------------------------------------------------------------
// Version	Changes
// 0.5		+ First Release
//----------------------------------------------------------------------------

class TOSTXSpectator extends MessagingSpectator;

var	TOSTXServerLink		SrvLink;

function AddMessage(PlayerReplicationInfo PRI, String S, name Type)
{
	if (SrvLink != none)
	{
		SrvLink.AnnounceMessage(FormatMessage(PRI, S, Type));
	}
}

function String FormatMessage(PlayerReplicationInfo PRI, String Text, name Type)
{
	local String Message;

	// format Say and TeamSay messages
	if (PRI != None) {
		if (Type == 'Say')
			Message = PRI.PlayerName$": "$Text;
		else if (Type == 'TeamSay')
			Message = "["$PRI.PlayerName$"]: "$Text;
		else
			Message = "("$Type$") "$Text;
	}
	else if (Type == 'Console')
		Message = Text;
	else
		Message = "("$Type$") "$Text;

	return Message;
}

function ClientMessage( coerce string S, optional name Type, optional bool bBeep )
{
	AddMessage(None, S, Type);
}

function TeamMessage( PlayerReplicationInfo PRI, coerce string S, name Type, optional bool bBeep )
{
	AddMessage(PRI, S, Type);
}

function ClientVoiceMessage(PlayerReplicationInfo Sender, PlayerReplicationInfo Recipient, name messagetype, byte messageID)
{
	// do nothing?
}

function ReceiveLocalizedMessage( class<LocalMessage> Message, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject )
{
	// do nothing?
}

defaultproperties
{
}
