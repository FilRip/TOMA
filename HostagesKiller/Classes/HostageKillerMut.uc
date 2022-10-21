class HostageKillerMut extends Mutator;

var() config string killedBefore;
var() config string killedAfter;

function PostBeginPlay ()
{
	Level.Game.RegisterDamageMutator(self);
}

function SendToAllPlayers(Pawn TheKiller)
{
    local Pawn P;

    if (TheKiller==None) return;

    if ((TheKiller.IsA('s_Player')) || (TheKiller.IsA('s_Bot')))
    	for (P=Level.PawnList;P!=None;P=P.nextPawn)
            if (P.IsA('PlayerPawn'))
            {
                PlayerPawn(P).ClearProgressMessages();
                PlayerPawn(P).SetProgressTime(3);
                PlayerPawn(P).SetProgressMessage(killedBefore$" "$TheKiller.PlayerReplicationInfo.PlayerName$" "$killedAfter,0);
            }
}

function MutatorTakeDamage(out int actualDamage,Pawn Victim,Pawn instigatedBy,out Vector HitLocation,out Vector Momentum,name DamageType)
{
	if (Victim!=None)
		if (Victim.IsA('s_NPCHostage'))
            if (Victim.Health-actualDamage<=0)
    			SendToAllPlayers(InstigatedBy);
	if (NextDamageMutator!=None)
		NextDamageMutator.MutatorTakeDamage(actualDamage,Victim,instigatedBy,HitLocation,Momentum,DamageType);
}

defaultproperties
{
    killedBefore=" "
    KilledAfter=" killed a hostage"
}
