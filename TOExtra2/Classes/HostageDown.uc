class HostageDown extends Mutator;

var sound HostageDownSound;

function PostBeginPlay ()
{
	Level.Game.RegisterDamageMutator(self);
}

function PlaySoundToAll(sound s)
{
	local s_Player_T aPlayer;

	foreach allactors(class's_Player_T',aPlayer)
		if (aPlayer!=None)
			aPlayer.ClientPlaySound(s,,true);
}

function MutatorTakeDamage(out int actualDamage,Pawn Victim,Pawn instigatedBy,out Vector HitLocation,out Vector Momentum,name DamageType)
{
	if (Victim!=None)
		if (Victim.IsA('s_NPCHostage'))
            if (Victim.Health-actualDamage<=0)
    			PlaySoundToAll(HostageDownSound);
	if (NextDamageMutator!=None)
		NextDamageMutator.MutatorTakeDamage(actualDamage,Victim,instigatedBy,HitLocation,Momentum,DamageType);
}

defaultproperties
{
	HostageDownSound=Sound'TOExtraModels.HostageDown'
}
