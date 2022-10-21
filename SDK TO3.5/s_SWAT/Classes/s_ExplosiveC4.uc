class s_ExplosiveC4 extends Engine.Actor;

var bool bBeingActivated;
var float CountDown;
var int ChangeCount;
var int MaxCount;
var float CDSpeed;
var int Count;
var Actor CurrentBombingZone;
var float C4Duration;
var Actor DefusedBy;
var Sound SoundCompleted;
var Sound SoundFailed;
var Sound SoundActivated;
var bool bToldToLeave;
var bool bExploded;
var bool bPlantedInBombingSpot;
var int C4RadiusRange;

simulated function Touch (Actor Other)
{
}

simulated function BeginPlay ()
{
}

simulated function PostBeginPlay ()
{
}

simulated function Destroyed ()
{
}

function RenderTexture (ScriptedTexture Tex)
{
}

simulated function Tick (float DeltaTime)
{
}

simulated function Timer ()
{
}

simulated function C4Explode ()
{
}

function bool IsRoundPeriodPlaying ()
{
}

function bool IsRelevant (Actor Other)
{
}

function bool C4Activate (Actor Defuser)
{
}

function C4Failed ()
{
}

function C4Complete ()
{
}

function C4Check ()
{
}


defaultproperties
{
}

