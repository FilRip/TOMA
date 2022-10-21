class MA_ThunderExplosion extends TO_ExplFlash;

simulated function PostBeginPlay ()
{
	local int i;

	HurtRadius(200,200,'Thunder',20000,Location);

	while ( i < 45 )
	{
		Spawn(Class'MA_ThunderChunk',,,Location);
		i++;
	}

	Super.PostBeginPlay();
}

defaultproperties
{
    ExplSound=None
}
