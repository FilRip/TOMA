Class TOMAConcussion extends s_Concussion;

var int nbChunk;

simulated function Explosion(vector HitLocation)
{
	local int i;
	local s_ConcussionChunk C;
	local TO_GrenadeExplosion expl;

	bHidden=true;
	for (i=0;i<nbChunk;i++)
	{
		C=Spawn(class'TOMAConcussionChunk',,,Location,);
		C.DrawScale*=0.75;
	}
	expl=spawn(class'TO_ExplConc',,,HitLocation);
	Destroy();
}

defaultproperties
{
	nbChunk=40
}
