class TO_DynamicSound extends Keypoint;

var() bool bInitiallyOn;
var() Sound Sounds[16];
var() float playProbability;
var() float minReCheckTime;
var() float maxReCheckTime;
var() bool bDontRepeat;
var() float Volume;
var() int Radius;
var bool soundPlaying;
var float rePlayTime;
var int numSounds;
var int lastSound;

function BeginPlay ()
{
}

function Timer ()
{
}
