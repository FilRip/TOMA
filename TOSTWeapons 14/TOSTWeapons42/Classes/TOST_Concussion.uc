//================================================================================
// TOST_Concussion.
//================================================================================
class TOST_Concussion extends TOST_GrenadeAway;

simulated function Explosion (Vector HitLocation)
{
	local int i;
	local s_ConcussionChunk C;
	local TO_GrenadeExplosion expl;

	bHidden=True;
	for ( i=0; i<10; i++ )
	{
		C=Spawn(Class'TOST_ConcussionChunk',,,Location);
		C.DrawScale *= 0.75;
	}
	expl=Spawn(Class'TOST_ExplConc',,,HitLocation);
	Destroy();
}

defaultproperties
{
    Mesh=LodMesh'TOModels.wgrenadeconc'
}
