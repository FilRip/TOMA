class TO_PRI extends PlayerReplicationInfo;

var int InflictedDmg;
var bool bEscaped;
var bool bHasBomb;
var bool bRealSpectator;
var Vector IDOldLocation;
var byte IDWarnings;
var byte IDDeaths;
var byte AdminLoginTries;
var PlayerReplicationInfo VoteFrom[48];
var int Ignored[48];
var localized string IgnoreString;
var localized string ListeningString;
var float TimeOfLastNickChange;
var byte TOPStatus;

final function ClearVotes ()
{
}

final simulated function ClearIgnoreList ()
{
}

final simulated function ToggleIgnored (int pid)
{
}

final simulated function bool IsIgnored (PlayerReplicationInfo PRI)
{
}
