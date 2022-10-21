class TO_MessageMutator extends TO_Mutator;


function bool MutatorBroadcastLocalizedMessage (Actor Sender, Pawn Receiver, out Class<LocalMessage> Message, optional out int Switch, optional out PlayerReplicationInfo RelatedPRI_1, optional out PlayerReplicationInfo RelatedPRI_2, optional out Object OptionalObject)
{
}

function bool MutatorBroadcastMessage (Actor Sender, Pawn Receiver, out coerce string Msg, optional bool bBeep, optional out name Type)
{
}

function bool MutatorTeamMessage (Actor Sender, Pawn Receiver, PlayerReplicationInfo PRI, coerce string S, name Type, optional bool bBeep)
{
}


defaultproperties
{
}

