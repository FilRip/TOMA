Class TOMAShockWave extends ShockWave;

var() int filmaxdamage;

function SpawnEffects()
{
}

simulated function Timer()
{

	local TOMAPlayer Victims;
	local float damageScale, dist, MoScale;
	local vector dir;

	ShockSize =  13 * (Default.LifeSpan - LifeSpan) + 3.5/(LifeSpan/Default.LifeSpan+0.05);
	if ( Level.NetMode != NM_DedicatedServer )
	{
		ICount++;

		if ( Level.NetMode == NM_Client )
		{
			foreach VisibleCollidingActors( class 'TOMAPlayer', Victims, ShockSize*29, Location )
				if ( Victims.Role == ROLE_Authority )
				{
					dir = Victims.Location - Location;
					dist = FMax(1,VSize(dir));
					dir = dir/dist +vect(0,0,0.3); 
					if ( (dist> OldShockDistance) || (dir dot Victims.Velocity <= 0))
					{
						MoScale = FMax(0, filmaxdamage - 1.1 * Dist);
						Victims.Velocity = Victims.Velocity + dir * (MoScale + 20);	
						Victims.TakeDamage(MoScale,Instigator,Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,(1000 * dir),'RedeemerDeath');
					}
				}	
			return;
		}
	}

	foreach VisibleCollidingActors( class 'TOMAPlayer', Victims, ShockSize*29, Location )
	{
		dir = Victims.Location - Location;
		dist = FMax(1,VSize(dir));
		dir = dir/dist + vect(0,0,0.3); 
		if (dist> OldShockDistance || (dir dot Victims.Velocity < 0))
		{
			MoScale = FMax(0, filmaxdamage - 1.1 * Dist);
			if (Victims.bIsPawn)
				Victims.AddVelocity(dir * (MoScale + 20));
			else
				Victims.Velocity = Victims.Velocity + dir * (MoScale + 20);	
			Victims.TakeDamage(MoScale,Instigator,Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,(1000 * dir),'RedeemerDeath');
		}
	}	
	OldShockDistance = ShockSize*29;	
}

defaultproperties
{
	LifeSpan=1
	filmaxdamage=775
}
