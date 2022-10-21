class TO_HitShadow extends Engine.Actor;

var int SavedLocationsIndex;
struct PlayerStateMemory
{
	var bool bCrouched;
	var bool bSwimming;
	var Vector Loc;
	var Rotator Rot;
	var float TimeStamp;
}
var PlayerStateMemory SavedLocations;
var int CurrentLoc;
var bool bActive;

function PreBeginPlay ()
{
}

function Tick (float Delta)
{
}

function Vector GetSavedLocation (int i)
{
}

function Rotator GetSavedRotation (int i)
{
}

function float GetSavedTimeStamp (int i)
{
}

function bool GetSavedSwim (int i)
{
}

function bool GetSavedCrouch (int i)
{
}


defaultproperties
{
}

