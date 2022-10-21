//=============================================================================
// s_RainGenerator
//=============================================================================
//
// Tactical Ops
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Greg '[DM]Matryx' Sweetman
//=============================================================================
// Enhanced by Laurent 'Shag' Delayen
//=============================================================================
  
class s_RainGeneratorInternal extends s_RainGenerator;


var	int			LowFPSLimit;
var	float		LowInterval, DropDiag, LowVariance, lowtime;
var	vector	defaultvelocity, defaultlocation;


///////////////////////////////////////
// Init 
///////////////////////////////////////

final simulated function Init()
{
	// Precalc
	LowFPSLimit = max(NumberOfDrips / 5, 1);
	defaultvelocity = Vect(0, 0, -1) * 0.1;
	LowInterval = Interval * 5.0;
	DropDiag = DropRadius * 2.0;
	LowVariance = Variance / 5.0;

	defaultlocation = location;
	defaultlocation.z = Location.z - 8;

	// launch the machine
	if ( Level.bDropDetail )
		SetTimer(LowInterval, false);
	else
		SetTimer(Interval, false);
}


///////////////////////////////////////
// tick 
///////////////////////////////////////

simulated function tick( float deltatime )
{
	if ( Level.bAggressiveLOD )
		lowtime = 6.0;
	else if ( Level.bDropDetail )
		lowtime = 3.0;
	else if ( lowtime > 0 )
		lowtime -= deltatime;
}


///////////////////////////////////////
// timer 
///////////////////////////////////////

simulated function timer()
{
	local	int		i, limit;
	local	bool	bLow;
 
//	if ( bProcessing )
//		return;

//	bProcessing = true;
	bLow = lowtime > 0;

	// keep reasonable FPS
	if ( bLow )
		limit = LowFPSLimit;
	else
		limit = NumberOfDrips;

	for (i=0; i<limit; i++)
		SpawnRain();

//	bProcessing = false;

	// keep reasonable FPS
	if ( bLow )
		SetTimer(LowInterval, false);
	else
		SetTimer(Interval, false);
}
	

///////////////////////////////////////
// SpawnRain 
///////////////////////////////////////

final simulated function SpawnRain()
{
	local s_raindrop		d;
	local	TO_SnowFlake	Snow;
	local vector				start;

	//log("s_RainGenerator - SpawnRain");
	start = defaultlocation;
	start.x += (FRand() - 0.5) * DropDiag;
 	start.y += (FRand() - 0.5) * DropDiag;

	switch ( RainType )
	{
		case RT_Rain:
			if ( bMeshRainDrop )
				d = Spawn(class's_raindrop',,,Start);							
			else
				d = Spawn(class's_raindropSprite',,,Start);

			if ( d != None )
			{
				d.speed *= DropSpeed;
				d.Velocity = defaultvelocity * d.speed;
				d.DrawScale = (1.0 + FRand() ) * Variance;				
				//d.RemoteRole = Role_None;
			}
			break;
	
		case RT_Snow:
			Snow = Spawn(class'TO_SnowFlake',,, Start);

			if ( Snow != None ) 
			{
				Snow.speed *= DropSpeed;
				Snow.Velocity = defaultvelocity * Snow.speed;
				Snow.DrawScale = 0.2 + FRand() * LowVariance;

				if ( bJerky )
					Snow.Jerkyness = Jerkyness;
				//Snow.RemoteRole = ROLE_None;
			}
			break;

	}
}


///////////////////////////////////////
// defaultproperties 
///////////////////////////////////////

defaultproperties
{
     bStatic=False
}
