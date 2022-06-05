class TOMAC4ShockWave extends s_C4ShockWave;

var Pawn C4Instigator;

simulated function Timer()
{
	local actor Victims;
	local float damageScale, dist, MoScale;
	local vector dir;

	ShockSize=13*(Default.LifeSpan - LifeSpan) + 3.5/(LifeSpan/Default.LifeSpan+0.05);
	if (Level.NetMode!=NM_DedicatedServer)
	{
		if (ICount==4)
			spawn(class's_C4Explosion',,,Location);

		ICount++;

		if (Level.NetMode==NM_Client)
		{
			foreach VisibleCollidingActors(class 'Actor',Victims,ShockSize*29,Location)
				if ((Victims.Role==ROLE_Authority))
				{
					dir=Victims.Location-Location;
					dist=FMax(1,VSize(dir));
					dir=dir/dist +vect(0,0,0.3);
					if ((dist>OldShockDistance) || (dir dot Victims.Velocity <= 0))
					{
						MoScale = FMax(0, 1100 - 1.1 * Dist);

						if (Victims.bIsPawn)
							Victims.Velocity=Victims.Velocity+dir*(MoScale+20);

						Victims.TakeDamage(MoScale,C4Instigator,Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,	(2000 * dir),'Explosion');
					}
				}
			return;
		}
	}

	foreach VisibleCollidingActors( class 'Actor', Victims, ShockSize*29, Location )
	{
		dir = Victims.Location - Location;
		dist = FMax(1,VSize(dir));
		dir = dir/dist + vect(0,0,0.3);
		if (dist> OldShockDistance || (dir dot Victims.Velocity < 0))
		{
			MoScale = FMax(0, 1100 - 1.1 * Dist);
			if (Victims.bIsPawn )
				Pawn(Victims).AddVelocity(dir * (MoScale + 20));
			Victims.TakeDamage
			(MoScale,C4Instigator,Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,(2000 * dir),'Explosion');
		}
	}

	OldShockDistance=ShockSize*29;
}

defaultproperties
{
}

