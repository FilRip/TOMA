class TO_DynamicSound extends Engine.Keypoint;

var int numSounds;
var int lastSound;
var float rePlayTime;
var float minReCheckTime;
var Sound Sounds;
var float maxReCheckTime;
var float Volume;
var int Radius;
var bool bDontRepeat;
var float playProbability;
var bool bInitiallyOn;
var bool soundPlaying;

function Timer ()
{
}

function BeginPlay ()
{
}


defaultproperties
{
}

