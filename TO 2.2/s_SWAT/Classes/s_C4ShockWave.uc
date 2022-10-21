//=============================================================================
// s_C4ShockWave
//=============================================================================
//
// Tactical Ops
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen and Benoit "JAH" Delayen
//=============================================================================
  
class s_C4ShockWave extends ShockWave;

/*simulated function Tick( float DeltaTime )
{
	if ( Level.NetMode != NM_DedicatedServer )
	{
		ShockSize =  13 * (Default.LifeSpan - LifeSpan) + 3.5/(LifeSpan/Default.LifeSpan+0.05);
		ScaleGlow = Lifespan;
		AmbientGlow = ScaleGlow * 255;
		DrawScale = ShockSize;
	}
}*/


///////////////////////////////////////
// Timer 
///////////////////////////////////////

simulated function Timer()
{

	local actor Victims;
	local float damageScale, dist, MoScale;
	local vector dir;

	ShockSize =  13 * (Default.LifeSpan - LifeSpan) + 3.5/(LifeSpan/Default.LifeSpan+0.05);
	if ( Level.NetMode != NM_DedicatedServer )
	{
		if ( ICount == 4 ) 
			spawn(class's_C4Explosion',,,Location);
		
		ICount++;

		if ( Level.NetMode == NM_Client )
		{
			foreach VisibleCollidingActors( class 'Actor', Victims, ShockSize*29, Location )
				// Removed affecting all decos and actors because of "barrel jumping".
				// this should be fixed and we should see the decos fly in the air for some cool effect :)
				if ( Victims.IsA('Pawn') && (Victims.Role == ROLE_Authority) )
				{
					dir = Victims.Location - Location;
					dist = FMax(1,VSize(dir));
					dir = dir/dist +vect(0,0,0.3); 
					if ( (dist> OldShockDistance) || (dir dot Victims.Velocity <= 0))
					{
						MoScale = FMax(0, 1100 - 1.1 * Dist);
						Victims.Velocity = Victims.Velocity + dir * (MoScale + 20);	
						Victims.TakeDamage
						(
							MoScale,
							Instigator, 
							Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
							(1000 * dir),
							'Explosion'
						);
					}
				}	
			return;
		}
	}

	foreach VisibleCollidingActors( class 'Actor', Victims, ShockSize*29, Location )
	{
		// Removed affecting all decos and actors because of "barrel jumping".
		// this should be fixed and we should see the decos fly in the air for some cool effect :)
		if ( Victims.IsA('Pawn') )
		{
			dir = Victims.Location - Location;
			dist = FMax(1,VSize(dir));
			dir = dir/dist + vect(0,0,0.3); 
			if (dist> OldShockDistance || (dir dot Victims.Velocity < 0))
			{
				MoScale = FMax(0, 1100 - 1.1 * Dist);
				if ( Victims.bIsPawn )
					Pawn(Victims).AddVelocity(dir * (MoScale + 20));
				else
					Victims.Velocity = Victims.Velocity + dir * (MoScale + 20);	
				Victims.TakeDamage
				(
					MoScale,
					Instigator, 
					Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
					(1000 * dir),
					'Explosion'
				);
			}
		}
	}	

	OldShockDistance = ShockSize * 29;	
}


///////////////////////////////////////
// PostBeginPlay 
///////////////////////////////////////

simulated function PostBeginPlay()
{
	local Pawn P;

	if ( Role == ROLE_Authority ) 
	{
		for ( P=Level.PawnList; P!=None; P=P.NextPawn )
			if ( P.IsA('PlayerPawn') && (VSize(P.Location - Location) < 3000) )
				PlayerPawn(P).ShakeView(0.5, 600000.0/VSize(P.Location - Location), 10);

		if ( Instigator != None )
			MakeNoise(10.0);
	}

	SetTimer(0.1, true);

	if ( Level.NetMode != NM_DedicatedServer )
		SpawnEffects();
}


///////////////////////////////////////
// SpawnEffects 
///////////////////////////////////////

simulated function SpawnEffects()
{
	 local WarExplosion W;

	 PlaySound(Sound'Expl03', SLOT_Interface, 16.0);
	 PlaySound(Sound'Expl03', SLOT_None, 16.0);
	 PlaySound(Sound'Expl03', SLOT_Misc, 16.0);
	 PlaySound(Sound'Expl03', SLOT_Talk, 16.0);
	 W = spawn(class's_C4Explosion',,,Location);
	 W.RemoteRole = ROLE_None;
}


///////////////////////////////////////
// defaultproperties 
///////////////////////////////////////

defaultproperties
{
}
