class s_BPlayer extends TOPModels.TO_SysPlayer;

var bool bNotPlaying;
var bool bSZoom;
var float SZoomVal;
var Weapon LastSelectedWeapon;
var TO_FlashLight Flashlight;
var float DefaultSurroundFOV;
var float DefaultOriginalFOV;
var TO_Move SavedTOMoves;
var TO_Move FreeTOMoves;
var TO_LaserDot LaserDot;
var bool bHUDModFix;
var float OriginalBob;
var bool bSurroundGaming;
var int RecoilTimes;
var TO_Move SkippedMove;
var bool bSZoomStraight;
var bool bFlashlight;
var bool bWantsToFire;
var bool bLaserDot;
var bool bHideCrosshairs;
var bool bDoRecoil;
var bool bRememberLaserDot;
var bool bDead;
var bool bSwitchToLastWeapon;
var int RepView;
var bool bWantsToCrouch;
var TO_Move LastSavedTOMove;
var bool bHideDeathMsg;
var bool bAutomaticReload;
var bool bBinocs;
var int ServerRecoilTimes;
var bool zzbValidAltFire;
var bool zzbValidFire;
var bool SkipObjectives;
var bool bAutoTimedemo;
var bool bScreenFlashes;
var float DefaultSurroundZoomLvl2;
var float DefaultSurroundZoomLvl1;
var float DefaultZoomLvl2;
var float DefaultZoomLvl1;
var float LastFireModeChange;
var bool bHideWidescreen;
var bool bFixCalcBehindView;

event Destroyed ()
{
}

simulated function Tick (float Delta)
{
}

function TOTick ()
{
}

simulated event Possess ()
{
}

exec function SwitchWeapon (byte F)
{
}

exec function s_kFlashlight ()
{
}

function s_Flashlight ()
{
}

exec function TOStartDuck ()
{
}

function ChangeSnapView (bool B)
{
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

state PlayerWalking
{
	event PlayerTick (float DeltaTime)
	{
	}

	function PlayerMove (float DeltaTime)
	{
	}

}

exec function Summon (string ClassName)
{
}

exec function KillAll (Class<Actor> aClass)
{
}

function CleanTOMoves ()
{
}

simulated event PostNetBeginPlay ()
{
}

exec function AllYourBaseAreBelongToUs ()
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

function SendVoiceMessage (PlayerReplicationInfo Sender, PlayerReplicationInfo Recipient, name MessageType, byte MessageID, name broadcasttype)
{
}

exec function SetName (coerce string S)
{
}

exec function Ignore (string pid)
{
}

exec function Surround ()
{
}

event TeamMessage (PlayerReplicationInfo PRI, coerce string S, name Type, optional bool bBeep)
{
}

static function string FixANSI (string S)
{
}

static function string ReverseFixANSI (string S)
{
}

static function Replace (out string S, string t, string W)
{
}

exec function Speech (int Type, int Index, int Callsign)
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

function ServerSetRememberLaserDot (bool B)
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

event PlayerInput (float DeltaTime)
{
}

function PreCacheReferences ()
{
}

function Inventory FindInventoryType (Class DesiredClass)
{
}

simulated function ClientPlaySound (Sound ASound, optional bool bInterrupt, optional bool bVolumeControl)
{
}

exec function Grab ()
{
}

exec function FOV (float F)
{
}

exec function SetDesiredFOV (float F)
{
}

exec function centerview ()
{
}

exec function FeignDeath ()
{
}

exec function rmode ()
{
}

exec function togglehudcredits ()
{
}

exec function SetMouseSmoothThreshold (float F)
{
}

exec function SetMaxMouseSmoothing (bool B)
{
}

exec function ChangeHud ()
{
}

exec function ChangeCrosshair ()
{
}

exec function AlwaysMouseLook (bool B)
{
}

exec function SnapView (bool B)
{
}

exec function StairLook (bool B)
{
}

exec function SetDodgeClickTime (float F)
{
}

exec function SetAutoAim (float F)
{
}

exec function SetHand (string S)
{
}

exec function NeverSwitchOnPickup (bool B)
{
}

function ServerNeverSwitchOnPickup (bool B)
{
}

exec function InvertMouse (bool B)
{
}

exec function SetBob (float F)
{
}

exec function SetSensitivity (float F)
{
}

function ServerQuality ()
{
}

exec function TOStartFire ()
{
}

exec function TOStopFire ()
{
}

exec function TOStartAltFire ()
{
}

exec function TOStopAltFire ()
{
}

exec function TOStopDuck ()
{
}


defaultproperties
{
}

