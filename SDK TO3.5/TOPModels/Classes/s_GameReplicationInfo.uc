class s_GameReplicationInfo extends Botpack.TournamentGameReplicationInfo;

var int RoundDuration;
var int RoundStarted;
var bool bPlayersBalanceTeams;
var bool bPreRound;
var bool bAllowGhostCam;
var bool bMirrorDamage;
var bool bEnableBallistics;
var int FriendlyFireScale;
var bool bTOProtectActive;
var TO_SpecialGameBehaviors SpecialGameBehaviors;
var bool bAllowBehindView;
var int RoundNumber;

function Timer ()
{
}

simulated function PostBeginPlay ()
{
}


defaultproperties
{
}

