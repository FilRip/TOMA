class TO_PRI extends Engine.PlayerReplicationInfo;

var int InflictedDmgToRep;
var int InflictedDmg;
var PlayerReplicationInfo VoteFrom;
var bool bHasBomb;
var byte IDWarnings;
var int Ignored;
var byte NetSpeed;
var byte IDDeaths;
var bool bEscaped;
var byte RoundsPlayed;
var bool IgnoreAll;
var Rotator IDOldRotation;
var Vector IDOldLocation;
var bool bRealSpectator;
var float LastShotSound;
var float TimeOfLastNickChange;
var byte TOPStatus;
var float LastPingUpdate;

final function ReplicateInflictedDmg ()
{
}

final simulated function ToggleIgnored (int pid)
{
}

final simulated function bool IsIgnored (PlayerReplicationInfo PRI)
{
}

final simulated function ClearIgnoreList ()
{
}

final function ClearVotes ()
{
}

function Timer ()
{
}


defaultproperties
{
}

