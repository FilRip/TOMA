class TO_Spectator extends TOPModels.TO_SysSpectator;

var TO_EffectRI EffectRI;
var TO_CCInput CCInput;
var bool bGUIActive;
var bool bBackupBehindView;
var bool bMenuVisible;
var byte AdminLoginTries;
var byte SemiAdminLevel;
var int ViewTarRep;
var float LastReplicateMove;
var bool bSilentAdmin;
var Actor oldTarget;

final function bool AllowAdminInput (int Command)
{
}

final function bool HandleAdminInput (int Command)
{
}

event PostBeginPlay ()
{
}

exec function AdminReset ()
{
}

exec function Jump (optional float F)
{
}

exec function Fire (optional float F)
{
}

exec function TOStartFire ()
{
}

exec function TOStartAltFire ()
{
}

exec function AltFire (optional float F)
{
}

function ServerEndRound ()
{
}

function bool SetPause (bool bPause)
{
}

exec function AdminSet (int Val, string S)
{
}

exec function KickBanTK ()
{
}

exec function PTempKickBan (int PlayerID, optional string Reason)
{
}

exec function PKickBan (int PlayerID, optional string Reason)
{
}

exec function PKick (int PlayerID, optional string Reason)
{
}

exec function TempKickBan (string PlayerName)
{
}

exec function KickBan (string PlayerName)
{
}

exec function Kick (string PlayerName)
{
}

exec function Summon (string ClassName)
{
}

exec function KillAll (Class<Actor> aClass)
{
}

function ServerAddBots (int N)
{
}

exec function SwitchLevel (string URL)
{
}

exec function RestartLevel ()
{
}

exec function Admin (string CommandLine)
{
}

exec function EndRound ()
{
}

simulated event Destroyed ()
{
}

simulated function MenuClosed ()
{
}

simulated function bool EscapePress ()
{
}

event PreClientTravel ()
{
}

simulated event Possess ()
{
}

exec function ShowMenu ()
{
}

exec function Say (string Msg)
{
}

function ServerQuality ()
{
}

simulated function HUD_Add_Death_Message (PlayerReplicationInfo KillerPRI, PlayerReplicationInfo VictimPRI)
{
}

exec function Ghost ()
{
}

function TO_SpectatorServerMove ()
{
}

event TeamMessage (PlayerReplicationInfo PRI, coerce string S, name Type, optional bool bBeep)
{
}

state CheatFlying
{
	function PlayerMove (float DeltaTime)
	{
	}

}

function ReplicateMove (float DeltaTime, Vector newAccel, EDodgeDir DodgeMove, Rotator DeltaRot)
{
}

function InitPlayerReplicationInfo ()
{
}

function Replace (out string S, string t, string W)
{
}

function string ReverseFixANSI (string S)
{
}

function string FixANSI (string S)
{
}

function string ConsoleCommand (string Command)
{
}

event PlayerCalcView (out Actor ViewActor, out Vector CameraLocation, out Rotator CameraRotation)
{
}

function AttachCCInput (Class<TO_CCInput> CC)
{
}

simulated function s_ChangeTeam (int N, int Team, bool bDie)
{
}

function ChangeTeam (int N)
{
}


defaultproperties
{
}

