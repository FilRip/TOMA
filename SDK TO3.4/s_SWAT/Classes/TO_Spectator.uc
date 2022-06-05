class TO_Spectator extends TO_SysSpectator;

var Actor oldTarget;
var bool bBackupBehindView;
var bool bGUIActive;
var bool bMenuVisible;

exec function ShowMenu ()
{
}

simulated event Possess ()
{
}

event PreClientTravel ()
{
}

simulated function bool EscapePress ()
{
}

simulated function MenuClosed ()
{
}

simulated event Destroyed ()
{
}

exec function AdminReset ()
{
}

exec function AdminSet (int Val, string S)
{
}

exec function EndRound ()
{
}

function ServerEndRound ()
{
}

exec function PKick (int pid)
{
}

exec function PKickBan (int pid)
{
}

exec function PTempKickBan (int pid)
{
}

event PostBeginPlay ()
{
}

exec function Jump (optional float F)
{
}

exec function Fire (optional float F)
{
}

exec function AltFire (optional float F)
{
}
