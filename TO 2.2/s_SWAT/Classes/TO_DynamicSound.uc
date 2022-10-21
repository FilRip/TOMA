//=============================================================================
// TO_Ladder
//=============================================================================
//
// Tactical Ops
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen
//=============================================================================
//
// Taken from DynamicAmbientSound.
// Added Volume and Range parameters.

class TO_DynamicSound extends Keypoint;

var() bool       bInitiallyOn;   	// Initial state
var() sound      Sounds[16];      	// What to play (must be at least one sound)
var() float      playProbability;	// The chance of the sound effect playing
var() float      minReCheckTime;   // Try to restart the sound after (min amount)
var() float      maxReCheckTime;   // Try to restart the sound after (max amount)
var() bool       bDontRepeat;		// Never play two of the same sound in a row
var()	float			 Volume;	// Volume %
var()	int				 Radius;	// sound range

var   bool       soundPlaying;   	// Is it currently playing it?
var   float      rePlayTime;
var   int        numSounds;		// The number of sounds available
var   int        lastSound;		// Which sound was played most recently?


///////////////////////////////////////
// BeginPlay 
///////////////////////////////////////

function BeginPlay() 
{
	
	local int i;
	
	// Calculate how many sounds the user specified
	numSounds=6;
	for (i=0; i<16; i++) 
	{
		if (Sounds[i] == None) 
		{
			numSounds=i;
			break;
		}
	}

	lastSound = -1;
	if ( bInitiallyOn ) 
	{
		// Which sound should be played?
		i = Rand(numSounds);
		PlaySound(Sounds[i], Slot_None, Volume, , Radius);
		lastSound = i;
	}

	rePlayTime = (maxReCheckTime-minReCheckTime)*FRand() + minReCheckTime;
	SetTimer(rePlayTime, False);
}


///////////////////////////////////////
// Timer 
///////////////////////////////////////

function Timer() 
{

	local int i;
	
	if (FRand() <= playProbability) 
	{
	
		// Play the sound
		// Which sound should be played?
		i = Rand(numSounds);
		while( i == lastSound && bDontRepeat && numSounds > 1 )
			i = Rand(numSounds);
		
		PlaySound(Sounds[i], Slot_None, Volume, , Radius);
		lastSound = i;
	}

	rePlayTime = (maxReCheckTime-minReCheckTime)*FRand() + minReCheckTime;
	SetTimer(rePlayTime, False);
}


///////////////////////////////////////
// defaultproperties 
///////////////////////////////////////

defaultproperties
{
     playProbability=0.600000
     minReCheckTime=5.000000
     maxReCheckTime=10.000000
     Volume=1.000000
     Radius=4096
     bStatic=False
}
