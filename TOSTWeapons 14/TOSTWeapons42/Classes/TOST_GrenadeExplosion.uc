//================================================================================
// TOST_GrenadeExplosion.
//================================================================================
class TOST_GrenadeExplosion extends TO_GrenadeExplosion;

simulated function ServerExplosion ()
{
	local actor Victims;
	local float damageScale, dist;
	local vector dir;

	foreach VisibleCollidingActors( class 'Actor', Victims, 600.00 * Scale, Location )
	{
		if( Victims == self )
			continue;
		if ( (!s_SWATGame(level.game).bExplosionFF) && (Pawn(Victims) != none) && (Pawn(Victims).PlayerReplicationInfo != none)  && (instigator.PlayerReplicationInfo != none) &&(Pawn(Victims).PlayerReplicationInfo.Team == instigator.PlayerReplicationInfo.Team) )
			continue;
		dir = Victims.Location - Location;
		dist = FMax(1,VSize(dir));
		dir = dir/dist;
		damageScale = 1 - FMax(0,(dist - Victims.CollisionRadius)/(600.00 * scale));
		Victims.TakeDamage(damageScale * 250.00 * Scale,Instigator, Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,(damageScale * 80000.00 * scale * dir),MyDamageType);
		if ( dist > 500 * scale )
				continue;
		if ( Victims.isa('TOST_ExplosiveC4') )
		{
			TOST_ExplosiveC4(Victims).InstantExplode(instigator);
		}
		if ( Victims.isa('TOST_C4') )
		{
			TOST_C4(Victims).InstantExplode(instigator);
		}
	}

}

defaultproperties
{
    Scale=1.00
}

