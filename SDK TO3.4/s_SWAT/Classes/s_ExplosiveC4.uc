class s_ExplosiveC4 extends Actor;

var float CDSpeed;
var float CountDown;
var int Count;
var int MaxCount;
var int ChangeCount;
var bool bPlantedInBombingSpot;
var bool bExploded;
var bool bToldToLeave;
var() Sound SoundActivated;
var() Sound SoundFailed;
var() Sound SoundCompleted;
var bool bBeingActivated;
var Actor DefusedBy;
var Actor CurrentBombingZone;
var int C4RadiusRange;
var float C4Duration;

simulated function BeginPlay ()
{
}

simulated function PostBeginPlay ()
{
}

simulated function Destroyed ()
{
}

simulated event RenderTexture (ScriptedTexture Tex)
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
