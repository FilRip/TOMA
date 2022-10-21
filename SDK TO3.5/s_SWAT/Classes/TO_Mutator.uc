class TO_Mutator extends Engine.Mutator;

var TO_Mutator NextTOMutator;

function AddMutator (Mutator M)
{
}

function HandleCCInput (PlayerPawn Player)
{
}

function bool HandleAdminInput (PlayerPawn Player, int Command)
{
}

function bool EventAdminLogout (PlayerPawn Player)
{
}

function bool EventHandleAdminBroadcast (PlayerPawn Player, string Password, optional out string AdminWarning)
{
}

function EventAdminLogin (PlayerPawn Player, string Password)
{
}

function EventSpectatorLogin (TO_Spectator Player, string Portal, string Options, out string Error)
{
}

function GetRules (out string ResultSet)
{
}

function EventGamePeriodChanged (name GP, string Reason)
{
}

function EventSpecialEvent (string EventType, optional coerce string Arg1, optional coerce string Arg2, optional coerce string Arg3, optional coerce string Arg4)
{
}

function string EventSkinChange (Pawn Player, byte ModelId, bool Forced)
{
}

function string EventTeamChange (Pawn Player, bool Forced)
{
}

function string EventNameChange (S_Player Player, string NewName, bool Forced)
{
}

function bool EventPlayerKicked (S_Player Player, name Type, string Reason)
{
}

function EventPlayerDisconnect (S_Player Player)
{
}

function EventPlayerJoin (S_Player Player)
{
}

function EventPlayerConnect (S_Player Player)
{
}

function EventPlayerLogin (S_Player Player, string Portal, string Options, out string Error)
{
}

function EventPreLogin (string Options, string Address, out string Error, out string FailCode)
{
}


defaultproperties
{
}

