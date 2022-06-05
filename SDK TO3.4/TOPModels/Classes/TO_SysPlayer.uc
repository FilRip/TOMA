class TO_SysPlayer extends TournamentPlayer;

var TO_TeamSelect StartMenu;
var bool bUseKey;
var byte zbFire;
var byte zbAltFire;
var bool zbValidFire;

simulated function s_ChangeTeam (int Num, int Team, bool bDie)
{
}

simulated function bool EscapePress ()
{
}

simulated function MenuClosed ()
{
}

simulated function ParticlesDetailChanged ()
{
}

simulated function UsePress ()
{
}

simulated function UseRelease ()
{
}

function ForceTempKickBan (string Reason)
{
}

event Possess ()
{
}

exec function Fire (optional float F)
{
}

exec function AltFire (optional float F)
{
}

function ReplicateMove (float DeltaTime, Vector newAccel, EDodgeDir DodgeMove, Rotator DeltaRot)
{
}

function ClientUpdatePosition ()
{
}
