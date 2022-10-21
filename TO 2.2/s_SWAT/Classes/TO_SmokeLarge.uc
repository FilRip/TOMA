//=============================================================================
// TO_SmokeLarge
//=============================================================================
//
// Tactical Ops
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen
//=============================================================================
// Smoke sprite for smoke grenades

class TO_SmokeLarge extends UT_SpriteSmokePuff;


var() float MovingRate;


///////////////////////////////////////
// BeginPlay 
///////////////////////////////////////

simulated function BeginPlay()
{
	Velocity = Vect(0,0,1) * RisingRate * FRand();
	Velocity.Y = (FRand() - 0.5 ) * MovingRate;
	Velocity.X = (FRand() - 0.5 ) * MovingRate;

	Texture = SSPrites[Rand(NumSets)];
	
	SetTimer(0.01, false);
}


///////////////////////////////////////
// Timer 
///////////////////////////////////////

simulated function Timer()
{
	if ( LifeSpan > 8.0 )
	{
		ScaleGlow = (10.0 - LifeSpan);
		//ScaleGlow = (10.0 - LifeSpan) / 2.0;
		DrawScale = Default.DrawScale * ScaleGlow;
	}
	else if ( LifeSpan < 2.0 )
	{
		ScaleGlow = LifeSpan;
		//ScaleGlow = LifeSpan / 2.0;
		DrawScale = Default.DrawScale * ScaleGlow;
	}
	else
	{
		SetTimer(8.0, false);
		return;
	}

	if ( Level.bDropDetail || !Level.bHighDetailMode )
		SetTimer(0.2 + FRand() * 0.10, false);
	else
		SetTimer(0.1, false);

	return;
}


///////////////////////////////////////
// defaultproperties 
///////////////////////////////////////
/*
  SSprites(0)=Texture'Botpack.utsmoke.us1_a00'
  SSprites(1)=Texture'Botpack.utsmoke.US3_A00'
	NumSets=2
*/

defaultproperties
{
     MovingRate=60.000000
     SSprites(1)=Texture'Botpack.utsmoke.US3_A00'
     RisingRate=60.000000
     NumSets=2
     Pause=0.100000
     RemoteRole=ROLE_None
     LifeSpan=10.000000
     DrawScale=15.000000
}
