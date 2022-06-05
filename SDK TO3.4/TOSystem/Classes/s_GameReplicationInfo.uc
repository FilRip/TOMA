class s_GameReplicationInfo extends TournamentGameReplicationInfo;

var int RoundStarted;
var int RoundDuration;
var int RoundNumber;
var bool bPreRound;
var bool bAllowGhostCam;
var bool bAllowBehindView;
var bool bMirrorDamage;
var bool bEnableBallistics;
var int FriendlyFireScale;
var bool bPlayersBalanceTeams;
var TO_SpecialGameBehaviors SpecialGameBehaviors;
var bool bTOProtectActive;

simulated function PostBeginPlay ()
{
}

simulated function Timer ()
{
}
