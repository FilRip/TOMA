class MA_ThunderBolt extends Decoration;

simulated event tick (float Delta)
{
	if ( Velocity.z > -300 )
	{
		explode();
	}	
}

simulated event spawned ()
{
	SetRotation(rot(16384,0,0));
}

event landed (Vector HitNormal)
{
	explode();
}

function explode ()
{
	Spawn(Class'MA_ThunderExplosion',,,Location);
	Destroy();
}

function ZoneChange (ZoneInfo NewZone)
{
	local Pawn Pawn;

	if ( NewZone.bWaterZone )
	{
		for( Pawn=Owner.Level.PawnList; Pawn!=None; Pawn=Pawn.NextPawn )
		{
			if ( Pawn.FootRegion.Zone == NewZone )
			{
				Pawn.TakeDamage(35,None,Pawn.Location,Pawn.Location,'');
			}
		}
		explode();
	}
}

defaultproperties
{
    bStatic=False
    bAlwaysTick=True
    Physics=2
    RemoteRole=2
    DrawType=2
    Mesh=LodMesh'Botpack.MiniTrace'
    DrawScale=2.00
    bUnlit=True
    bCollideWorld=True
    NetPriority=2.00
    NetUpdateFrequency=3.00
}
