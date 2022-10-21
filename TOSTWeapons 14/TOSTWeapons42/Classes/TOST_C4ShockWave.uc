//================================================================================
// s_C4ShockWave.
//================================================================================
class TOST_C4ShockWave extends ShockWave;

simulated function Tick( float DeltaTime )
{
	if ( Level.NetMode != NM_DedicatedServer )
	{
		ShockSize =  8 * (Default.LifeSpan - LifeSpan) + 3.5/(LifeSpan/Default.LifeSpan+0.05);
		ScaleGlow = Lifespan;
		AmbientGlow = ScaleGlow * 255;
		DrawScale = ShockSize;
	}
}

simulated function Timer ()
{/*
	local Actor Victims;
	local float damageScale;
	local float dist;
	local float MoScale;
	local Vector Dir;

	ShockSize= 6.00 * (Default.LifeSpan - LifeSpan) + 3.00 / (LifeSpan / Default.LifeSpan + 0.05);
	if ( Level.NetMode != 1 )
		return;

	foreach VisibleCollidingActors(Class'Actor',Victims,ShockSize * 25,Location)
	{
		Dir=Victims.Location - Location;
		dist=FMax(1.00,VSize(Dir));
		Dir=Dir / dist + vect(0.00,0.00,0.30);
		if ( (!s_SWATGame(level.game).bExplosionFF) && (PlayerPawn(Victims) != none) && (PlayerPawn(Victims).PlayerReplicationInfo != none) && (PlayerPawn(instigator) != none) && (PlayerPawn(instigator).PlayerReplicationInfo != none) && (PlayerPawn(Victims).PlayerReplicationInfo.TeamID == PlayerPawn(instigator).PlayerReplicationInfo.TeamID) )
			continue;
		if ( (dist > OldShockDistance) || (Dir dot Victims.Velocity < 0) )
		{
			MoScale=FMax(0.00,1100.00 - 1.10 * dist);
			if ( Victims.bIsPawn )
			{
				Pawn(Victims).AddVelocity(Dir * (MoScale + 20));
			}
			Victims.TakeDamage(MoScale,Instigator,Victims.Location - 0.50 * (Victims.CollisionHeight + Victims.CollisionRadius) * Dir,2000 * Dir,'Explosion');
			if ( dist > 800 )
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
	OldShockDistance=ShockSize * 20;*/
}

simulated function PostBeginPlay ()
{
	local Pawn P;
	local TOST_C4Explosion W;

	if ( Role == 4 )
	{
		for ( P=Level.PawnList; P != none; P=P.nextPawn)
		{
			if ( P.IsA('PlayerPawn') && (VSize(P.Location - Location) < 2000) )
			{
				PlayerPawn(P).ShakeView(0.50,600000.00 / VSize(P.Location - Location),10.00);
			}
		}
		if ( Instigator != None )
		{
			MakeNoise(10.00);
		}
	}
	SetTimer(0.10,True);
	if ( Level.NetMode != 1 )
	{
		PlaySound(Sound'Expl03',SLOT_Interface,16.00);
		W=Spawn(Class'TOST_C4Explosion',,,Location);
		W.RemoteRole=ROLE_None;
	}
}

defaultproperties
{
    LifeSpan=1.00
}

