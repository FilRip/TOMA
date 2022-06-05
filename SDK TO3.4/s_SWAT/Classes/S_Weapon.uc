class S_Weapon extends TournamentWeapon;

enum EFireModes
{
	FM_None,
	FM_SingleFire,
	FM_BurstFire,
	FM_FullAuto
};

struct s_WAnimation
{
	var() name AnimSeq;
	var() float AnimRate;
};

var() bool bUseAmmo;
var() bool bUseClip;
var() byte clipSize;
var() byte clipAmmo;
var() byte BackClipAmmo;
var() byte RemainingClip;
var() byte MaxClip;
var byte ClipInc;
var() int ClipPrice;
var bool bAltMode;
var byte BackupClip;
var byte BackupAmmo;
var byte BackupClipSize;
var byte BackupMaxClip;
var int BackupClipPrice;
var localized string AmmoName;
var localized string BackupAmmoName;
var() float MaxDamage;
var() int RoundPerMin;
var float FirePause;
var() bool bTracingBullets;
var() byte TraceFrequency;
var() byte TraceShotCount;
var() int price;
var() bool bNoDrop;
var bool bShowWeaponLight;
var bool bSingleFireBasedROF;
var bool bReloadingWeapon;
var() float BotAimError;
var() float PlayerAimError;
var() float VRecoil;
var() float HRecoil;
var() float RecoilMultiplier;
var float RecoilVal;
var byte ShotCount;
var float rPower;
var bool bZeroAccuracy;
var bool bStaticAimError;
var bool bHasMultiSkins;
var byte ArmsNb;
var byte WeaponID;
var byte WeaponClass;
var float WeaponWeight;
var byte zoom_mode;
var(s_WAnimation) s_WAnimation aReloadWeapon;
var Sound EmptyClipSound;
var float MaxWallPiercing;
var float MaxRange;
var float ProjectileSpeed;
var float XSurroundCorrection;
var float YSurroundCorrection;
var float rofmultiplier;
var byte BurstRoundnb;
var byte BurstRoundCount;
var EFireModes FireModes[5];
var byte CurrentFireMode;
var bool bUseFireModes;
var int MuzFrame;
var float MuzLastTime;
var float MuzScale;
var int MuzX;
var int MuzY;
var int MuzRadius;
var bool bUseShellCase;
var bool bNeedFix;
var int numShellCase;
var int maxShellCase;
var string ShellCaseType;
var Vector ShellEjectOffset;
var Texture OldTex;
var byte OldMaterialIndex;
var float WaterRange;

function AltFire (float F)
{
}

simulated function bool ClientAltFire (float Value)
{
}

function SetHand (float hand)
{
}

function SetSkins ()
{
}

simulated function ForceStillFrame ()
{
}

simulated event RenderOverlays (Canvas Canvas)
{
}

simulated function PostRender (Canvas Canvas)
{
}

final function bool ValidReloadOwner ()
{
}

function Fire (float Value)
{
}

simulated function bool ClientFire (float Value)
{
}

function ClientForceFire ()
{
}

simulated function ForceClientFire ()
{
}

function GenerateBullet ()
{
}

function SetAimError ()
{
}

final function bool HasHighROF ()
{
}

function FiringEffects ()
{
}

final function SpawnShellCase (Vector X, Vector Y, Vector Z)
{
}

simulated function PlayFiring ()
{
}

final simulated function PlaySynchedAnim (name AnimName, float DesiredTime, float DesiredTween)
{
}

function Finish ()
{
}

function TraceFireBallistics (float Accuracy)
{
}

function TraceFireBallisticsLow (float Accuracy)
{
}

function TraceFire (float Accuracy)
{
}

function TraceFireLow (float Accuracy)
{
}

function FireBulletInstantHit (Vector StartTrace, Vector EndTrace, Vector AimDir)
{
}

function FireBulletInstantHitLow (Vector StartTrace, Vector EndTrace, Vector AimDir)
{
}

final simulated function Recoil ()
{
}

state Active
{
	function BeginState ()
	{
	}
	
Begin:
}

state ClientActive
{
	simulated function ForceClientFire ()
	{
	}
	
	simulated function ForceClientAltFire ()
	{
	}
	
	simulated function bool ClientFire (float Value)
	{
	}
	
	simulated function bool ClientAltFire (float Value)
	{
	}
	
	simulated function AnimEnd ()
	{
	}
	
	simulated function BeginState ()
	{
	}
	
	simulated function EndState ()
	{
	}
	
}

simulated function PlayPostSelect ()
{
}

final function ForceServerFire ()
{
}

state Idle
{
	function AnimEnd ()
	{
	}
	
	function Timer ()
	{
	}
	
	function EndState ()
	{
	}
	
	function bool PutDown ()
	{
	}
	
	function BeginState ()
	{
	}
	
Begin:
}

simulated function PlayIdleAnim ()
{
}

simulated function ForceIdleFrame ()
{
}

function bool UseAmmo (int N)
{
}

function ForceClientReloadWeapon ()
{
}

simulated function s_ReloadW ()
{
}

function sReloadWeapon ()
{
}

simulated function PlayReloadWeapon ()
{
}

simulated function ChangeFireMode ()
{
}

simulated function bool DoChangeFireMode ()
{
}

simulated function ResetFireMode ()
{
}

simulated function PlayChangeFireMode ()
{
}

event float BotDesireability (Pawn Bot)
{
}

function Inventory SpawnCopy (Pawn Other)
{
}

function DropFrom (Vector StartLocation)
{
}

simulated function TweenToStill ()
{
}

auto state Pickup
{
	singular function ZoneChange (ZoneInfo NewZone)
	{
	}
	
	function bool ValidTouch (Actor Other)
	{
	}
	
	function Touch (Actor Other)
	{
	}
	
	function Landed (Vector HitNormal)
	{
	}
	
	function CheckTouching ()
	{
	}
	
	function Timer ()
	{
	}
	
	function BeginState ()
	{
	}
	
	function EndState ()
	{
	}
	
Begin:
dropped:
}

simulated function ClientPutDown (Weapon NextWeapon)
{
}

state ClientDown
{
	simulated function BeginState ()
	{
	}
	
}

state DownWeapon
{
	function BeginState ()
	{
	}
	
Begin:
}

function Weapon RecommendWeapon (out float rating, out int bUseAltMode)
{
}

function float RateSelf (out int bUseAltMode)
{
}

function float SwitchPriority ()
{
}

simulated function BecomeItem ()
{
}

state ServerReloadWeapon
{
	function Fire (float F)
	{
	}
	
	function AltFire (float F)
	{
	}
	
	function bool PutDown ()
	{
	}
	
	function BeginState ()
	{
	}
	
	function EndState ()
	{
	}
	
	function AnimEnd ()
	{
	}
	
Begin:
}

state ClientReloadWeapon
{
	simulated function ForceClientFire ()
	{
	}
	
	simulated function bool ClientFire (float Value)
	{
	}
	
	simulated function bool ClientAltFire (float Value)
	{
	}
	
	simulated function BeginState ()
	{
	}
	
	simulated function EndState ()
	{
	}
	
	simulated function AnimEnd ()
	{
	}
	
}

state ForceIdle
{
Begin:
}

final simulated function PlayWeaponSound (Sound DaSound)
{
}

simulated function AnimFire ()
{
}

state sServerFire
{
	function Fire (float F)
	{
	}
	
	function AltFire (float F)
	{
	}
	
	function BeginState ()
	{
	}
	
	function DoFire ()
	{
	}
	
	function EndState ()
	{
	}
	
	function AnimEnd ()
	{
	}
	
Begin:
}

state sClientFire
{
	simulated function bool ClientFire (float Value)
	{
	}
	
	simulated function bool ClientAltFire (float Value)
	{
	}
	
	simulated function BeginState ()
	{
	}
	
	simulated function EndState ()
	{
	}
	
	simulated function AnimEnd ()
	{
	}
	
}

simulated function int GetRemainingBullets (bool Mode)
{
}

simulated function int GetRemainingClips (bool Mode)
{
}

simulated function SetRemainingAmmo (int clips, int bullets, bool Mode)
{
}

final simulated function Vector TOCalcDrawOffset ()
{
}
