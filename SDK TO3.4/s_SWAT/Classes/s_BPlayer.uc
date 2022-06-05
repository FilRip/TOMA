class s_BPlayer extends TO_SysPlayer;

var bool bDead;
var bool bNotPlaying;
var bool bSZoomStraight;
var bool bSZoom;
var float SZoomVal;
var bool bDoRecoil;
var bool bBinocs;
var(Movement) globalconfig float OriginalBob;
var config bool bAutomaticReload;
var config bool bSwitchToLastWeapon;
var config bool bHideCrosshairs;
var config bool bHUDModFix;
var config bool bHideDeathMsg;
var config bool bHideWidescreen;
var TO_FLight Flashlight;
var float DefaultOriginalFOV;
var float DefaultZoomLvl1;
var float DefaultZoomLvl2;
var float DefaultSurroundFOV;
var float DefaultSurroundZoomLvl1;
var float DefaultSurroundZoomLvl2;
var config bool bSurroundGaming;
var Weapon LastSelectedWeapon;
var bool bFixCalcBehindView;
var float LastFireModeChange;

simulated event Destroyed ()
{
}

simulated event PostNetBeginPlay ()
{
}

exec function DumpToLog (string Message)
{
}

exec function TestAnimMode ()
{
}

exec function TestAnim (name SeqName, optional float Rate, optional float TweenTime)
{
}

exec function TestAnimFreeze (bool Val)
{
}

state TestingAnim
{
	function PlayChatting ()
	{
	}
	
	function ZoneChange (ZoneInfo NewZone)
	{
	}
	
	function AnimEnd ()
	{
	}
	
	function PlayerCalcView (out Actor ViewActor, out Vector CameraLocation, out Rotator CameraRotation)
	{
	}
	
	event PlayerTick (float DeltaTime)
	{
	}
	
	function PlayerMove (float DeltaTime)
	{
	}
	
	function ProcessMove (float DeltaTime, Vector newAccel, EDodgeDir DodgeMove, Rotator DeltaRot)
	{
	}
	
	function FindGoodView ()
	{
	}
	
	function BeginState ()
	{
	}
	
	function EndState ()
	{
	}
	
}

exec function KillAll (Class<Actor> aClass)
{
}

exec function Summon (string ClassName)
{
}

function SendVoiceMessage (PlayerReplicationInfo Sender, PlayerReplicationInfo Recipient, name MessageType, byte MessageID, name broadcasttype)
{
}

exec function SetName (coerce string S)
{
}

exec function KickBan (string S)
{
}

exec function PKick (int pid, optional string Reason)
{
}

exec function PKickBan (int pid, optional string Reason)
{
}

exec function PTempKickBan (int pid, optional string Reason)
{
}

function ForceTempKickBan (string Reason)
{
}

exec function Ignore (int pid)
{
}

exec function Surround ()
{
}

event TeamMessage (PlayerReplicationInfo PRI, coerce string S, name Type, optional bool bBeep)
{
}

function ClientVoiceMessage (PlayerReplicationInfo Sender, PlayerReplicationInfo Recipient, name MessageType, byte MessageID)
{
}

function UpdateBob (float F)
{
}

function ServerSetAutoReload (bool bval)
{
}

function ServerSetHideDeathMsg (bool bval)
{
}

simulated event Possess ()
{
}

event UpdateEyeHeight (float DeltaTime)
{
}

simulated function ToggleSZoom ()
{
}

simulated function StartSZoom ()
{
}

simulated function EndSZoom ()
{
}

function ServerSetbSZoom (bool bval, float SVal)
{
}

function ClientReStart ()
{
}

exec function bool SwitchToBestWeapon ()
{
}

exec function SwitchToLastWeapon (optional bool Nade)
{
}

exec function SwitchWeapon (byte F)
{
}

exec function s_kReload ()
{
}

exec function s_kWeaponSwitchMode ()
{
}

simulated function ClientReloadW ()
{
}

exec function s_kChangeFireMode ()
{
}

function s_ChangeFireMode ()
{
}

exec function s_kFlashlight ()
{
}

function s_Flashlight ()
{
}

event PlayerInput (float DeltaTime)
{
}

function PreCacheReferences ()
{
}

state PlayerWalking
{
	event PlayerTick (float DeltaTime)
	{
	}
	
	function PlayerMove (float DeltaTime)
	{
	}
	
}

state PlayerSwimming
{
	event PlayerTick (float DeltaTime)
	{
	}
	
	event UpdateEyeHeight (float DeltaTime)
	{
	}
	
}

function Inventory FindInventoryType (Class DesiredClass)
{
}

simulated function ClientPlaySound (Sound ASound, optional bool bInterrupt, optional bool bVolumeControl)
{
}
