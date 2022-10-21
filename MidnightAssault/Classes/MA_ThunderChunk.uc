class MA_ThunderChunk extends Actor;

simulated function PostBeginPlay ()
{
	Super.PostBeginPlay();

	Velocity.Z=1300 * FRand();
	Velocity.Y=1000 * (FRand() - 0.50);
	Velocity.X=1000 * (FRand() - 0.50);

	if ( Region.Zone.bWaterZone )
	{
		Velocity *= 0.50;
	}
}

simulated function HitWall (Vector HitNormal, Actor Wall)
{
	Velocity=0.80 * (Velocity Dot HitNormal * HitNormal * (-1.80 + FRand() * 0.80) + Velocity);
	SetRotation(rotator(Velocity));
}

simulated event Tick (float Delta)
{
	AmbientGlow=127 * LifeSpan;
}

defaultproperties
{
    bAlwaysTick=True
    Physics=2
    LifeSpan=2.00
    DrawType=2
    Texture=Texture'Botpack.ChunkGlow.Chunk_a00'
    Mesh=LodMesh'UnrealI.Chnk1'
    DrawScale=0.40
    AmbientGlow=254
    bMeshEnviroMap=True
    bCollideWorld=True
    bBounce=True
}
