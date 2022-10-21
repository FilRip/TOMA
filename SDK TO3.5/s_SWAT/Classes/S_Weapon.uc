class S_Weapon extends Botpack.TournamentWeapon;

var byte clipAmmo;
var int RoundPerMin;
var byte RemainingClip;
var byte clipSize;
var byte CurrentFireMode;
var byte zoom_mode;
enum EFireModes {
	FM_None,
	FM_SingleFire,
	FM_BurstFire,
	FM_FullAuto
};
var EFireModes FireModes;
var float HRecoil;
var float VRecoil;
var bool bAltMode;
var float MaxRange;
var bool bUseClip;
var byte MaxClip;
var int ClipPrice;
var float RecoilMultiplier;
var int price;
var byte WeaponClass;
var bool bReloadingWeapon;
var byte BurstRoundnb;
var byte BackupClip;
var byte BackupMaxClip;
var float FirePause;
var byte BurstRoundCount;
var byte TraceFrequency;
var byte BackupClipSize;
var int BackupClipPrice;
var byte ShotCount;
var bool bWaitForAck;
var bool bUseFireModes;
var bool bTracingBullets;
var TO_SteadyWeaponLight SteadyLightActor;
var bool bLightEffect;
var float MaxDamage;
var bool bSingleFireBasedROF;
var float rPower;
var float rofmultiplier;
var Sound EmptyClipSound;
var byte WeaponID;
var byte BackupAmmo;
var bool bNoDrop;
var Vector ShellEjectOffset;
var byte ClipInc;
var byte BackClipAmmo;
var float BotAimError;
var float PlayerAimError;
var float RecoilVal;
var byte ArmsNb;
var Texture OldTex;
var bool MayOwnLaserDot;
var float WaterRange;
struct s_WAnimation
{
	var() name AnimSeq;
	var() float AnimRate;
}
var s_WAnimation aReloadWeapon;
var bool bUseAmmo;
var byte TraceShotCount;
var bool bShowWeaponLight;
var bool bHasMultiSkins;
var float WeaponWeight;
var float MuzScale;
var int numShellCase;
var byte OldMaterialIndex;
var float ClientActiveTime;
var bool NoSound;
var int MuzRadius;
var int MuzY;
var int MuzX;
var float MaxWallPiercing;
var bool bZeroAccuracy;
var bool bStaticAimError;
var float ProjectileSpeed;
var float XSurroundCorrection;
var float YSurroundCorrection;
var bool bDisplayFireModes;
var bool bUseShellCase;
var bool bNeedFix;
var int maxShellCase;
var Rotator VDBeforeRecoil;
var float FixTime;
var bool bPredictionActive;
var bool AnimWasFire;
var float oldAnimFrame;
var float MuzLastTime;
var int MuzFrame;

final simulated function PlayWeaponSound (Sound DaSound)
{
}

function RenderOverlays (Canvas Canvas)
{
}

final simulated function Vector TOCalcDrawOffset ()
{
}

simulated function PlayFiring ()
{
}

simulated function PlayIdleAnim ()
{
}

simulated function s_ReloadW ()
{
}

final simulated function PlaySynchedAnim (name AnimName, float DesiredTime, float DesiredTween)
{
}

simulated function PostRender (Canvas Canvas)
{
}

simulated function ChangeFireMode (optional bool HideCrap)
{
}

function AltFire (float F)
{
}

function Fire (float Value)
{
}

simulated event Tick (float Delta)
{
}

simulated function bool ClientAltFire (float Value)
{
}

final simulated function bool HasHighROF ()
{
}

function GenerateBullet ()
{
}

simulated function bool ClientFire (float Value)
{
}

simulated function PlayReloadWeapon ()
{
}

function DropFrom (Vector StartLocation)
{
}

function float RateSelf (out int bUseAltMode)
{
}

function float SwitchPriority ()
{
}

simulated function PlaySelect ()
{
}

simulated function ForceStillFrame ()
{
}

simulated function SetAimError ()
{
}

final function bool ValidReloadOwner ()
{
}

simulated function Destroyed ()
{
}

final latent function bool DoChangeFireMode (optional bool HideCrap)
{
}

simulated function TweenDown ()
{
}

function Recoil ()
{
}

event float BotDesireability (Pawn Bot)
{
}

state DownWeapon
{
	function BeginState ()
	{
	}

	function s_ReloadW ()
	{
	}

	function AltFire (float F)
	{
	}

	function Fire (float Value)
	{
	}

}

simulated function PlayChangeFireMode ()
{
}

simulated function ForceClientFire ()
{
}

final simulated function Vector SpecialCalcDrawOffset ()
{
}

function ClientForceFire ()
{
}

simulated function SpawnShellCase (Vector X, Vector Y, Vector Z)
{
}

function TraceFire (float Accuracy)
{
}

simulated function TweenToStill ()
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

	function BeginState ()
	{
	}

	function EndState ()
	{
	}

	function AnimEnd ()
	{
	}

	function bool PutDown ()
	{
	}

	function ChangeFireMode (optional bool HideCrap)
	{
	}

	function s_ReloadW ()
	{
	}

}

simulated event ClientFixFireMode (byte nw)
{
}

state ClientReloadWeapon
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

	simulated function ForceClientFire ()
	{
	}

	function ChangeFireMode (optional bool HideCrap)
	{
	}

	function s_ReloadW ()
	{
	}

}

simulated function int GetRemainingClips (bool Mode)
{
}

simulated event FixFireSpeed ()
{
}

simulated function LoopAnimSafely (name Sequence, optional float Rate, optional float TweenTime)
{
}

simulated function TweenAnimSafely (name Sequence, float Time)
{
}

simulated function PlayAnimSafely (name Sequence, optional float Rate, optional float TweenTime)
{
}

state Idle2
{
}

simulated function bool GetLaserDot ()
{
}

simulated function SetLaserDot (bool STATUS)
{
}

simulated function SetRemainingAmmo (int clips, int bullets, bool Mode, optional bool refill)
{
}

simulated function int GetRemainingBullets (bool Mode)
{
}

state sClientFire
{
	simulated function AnimEnd ()
	{
	}

	simulated function EndState ()
	{
	}

	simulated function BeginState ()
	{
	}

	simulated function bool ClientAltFire (float Value)
	{
	}

	simulated function bool ClientFire (float Value)
	{
	}

	function ChangeFireMode (optional bool HideCrap)
	{
	}

}

state sServerFire
{
	function AnimEnd ()
	{
	}

	function EndState ()
	{
	}

	function DoFire ()
	{
	}

	function BeginState ()
	{
	}

	function ChangeFireMode (optional bool HideCrap)
	{
	}

	function AltFire (float F)
	{
	}

	function Fire (float F)
	{
	}

	function s_ReloadW ()
	{
	}

}

simulated function AnimFire ()
{
}

state ForceIdle
{
}

simulated function BecomeItem ()
{
}

function Weapon RecommendWeapon (out float rating, out int bUseAltMode)
{
}

state ClientDown
{
	simulated function EndState ()
	{
	}

	simulated function BeginState ()
	{
	}

}

simulated function ClientPutDown (Weapon NextWeapon)
{
}

state Pickup
{
	function EndState ()
	{
	}

	function BeginState ()
	{
	}

	function Timer ()
	{
	}

	function CheckTouching ()
	{
	}

	function Landed (Vector HitNormal)
	{
	}

	function Touch (Actor Other)
	{
	}

	function bool ValidTouch (Actor Other)
	{
	}

	function ZoneChange (ZoneInfo NewZone)
	{
	}

}

function Inventory SpawnCopy (Pawn Other)
{
}

simulated function ResetFireMode ()
{
}

function sReloadWeapon ()
{
}

function ForceClientReloadWeapon ()
{
}

function bool UseAmmo (int N)
{
}

simulated function ForceIdleFrame ()
{
}

state Idle
{
	function BeginState ()
	{
	}

	function bool PutDown ()
	{
	}

	function EndState ()
	{
	}

	function Timer ()
	{
	}

	function AnimEnd ()
	{
	}

}

final function ForceServerFire ()
{
}

simulated function PlayPostSelect ()
{
}

state ClientActive
{
	simulated function Tick (float Delta)
	{
	}

	simulated function EndState ()
	{
	}

	simulated function BeginState ()
	{
	}

	simulated function AnimEnd ()
	{
	}

	simulated function bool ClientAltFire (float Value)
	{
	}

	simulated function bool ClientFire (float Value)
	{
	}

	simulated function ForceClientAltFire ()
	{
	}

	simulated function ForceClientFire ()
	{
	}

}

state Active
{
	function BeginState ()
	{
	}

}

function FireBulletInstantHitLow (Vector StartTrace, Vector EndTrace, Vector AimDir)
{
}

function FireBulletInstantHit (Vector StartTrace, Vector EndTrace, Vector AimDir)
{
}

function TraceFireLow (float Accuracy)
{
}

function TraceFireBallisticsLow (float Accuracy)
{
}

function TraceFireBallistics (float Accuracy)
{
}

function Finish ()
{
}

simulated function FiringEffects ()
{
}

function SetSkins ()
{
}

function SetHand (float hand)
{
}

simulated function PostBeginPlay ()
{
}


defaultproperties
{
}

