class S_Player extends s_BPlayer;

struct Equipment
{
	var byte Flags;
	var byte Weapon2;
	var byte Weapon3;
	var byte Weapon4;
	var byte Weapon5;
	var int Ammo;
	var int BackupAmmo;
};

var Equipment Equip;
var s_PRI TOPRI;
var TO_PZone PZone;
var bool bSpecialItem;
var Class<s_SpecialItem> SpecialItemClass;
var Class<s_Evidence> Evidence[10];
var byte Eidx;
var int money;
var bool zzbNightVisiom;
var bool zzbNightVision;
var bool bHasNV;
var bool zzbHasNV;
var bool bAlreadyChangedTeam;
var bool bActionWindow;
var bool bBackupBehindView;
var bool bCantStandUp;
var float CrouchHeight;
var byte PlayerModel;
var byte HelmetCharge;
var byte VestCharge;
var byte LegsCharge;
var bool bShowDebug;
var float OldLadderZ;
var bool bUsingCT;
var float CTUseTime;
var float CTEndTime;
var TO_ConsoleTimer CurrentCT;
var s_ExplosiveC4 CurrentC4;
var TO_ScenarioInfo SI;
var float BlindTime;
var float CurrentSoundDuration;
var bool bInBuyZone;
var bool bInHomeBase;
var bool bInEscapeZone;
var bool bInRescueZone;
var bool bInBombingZone;
var bool bBuyingWeapon;
var bool bGUIActive;
var SpeechWindow SpeechOld;
var bool bMenuVisible;
var s_RainGeneratorInternal RG;
var s_RainGenerator RGLink;
var TO_Ladder CurrentLadder;
var int KillerID;
var float KillTime;
var string LastMessage;
var float LastMessageTime;
var bool bOldFire;
var TO_CCHook ConsoleCommandHook;

exec function Loaded ()
{
}

function LoadLeftHand ()
{
}

function ChangeTeam (int N)
{
}

exec function SShot ()
{
}

function string ConsoleCommand (string Command)
{
}

simulated function bool AdjustHitLocation (out Vector HitLocation, Vector TraceDir)
{
}

function ChangeSnapView (bool B)
{
}

function bool Gibbed (name DamageType)
{
}

function SpawnGibbedCarcass ()
{
}

function Carcass SpawnCarcass ()
{
}

function TossWeapon ()
{
}

function ServerTaunt (name Sequence)
{
}

exec function Taunt (name Sequence)
{
}

simulated function PostBeginPlay ()
{
}

simulated event Possess ()
{
}

simulated function FixMapProblems ()
{
}

simulated event Destroyed ()
{
}

simulated function SetupRainGen ()
{
}

simulated exec function toggleraingen ()
{
}

simulated exec function colorblind ()
{
}

simulated function ParticlesDetailChanged ()
{
}

function s_Flashlight ()
{
}

simulated event Touch (Actor Other)
{
}

simulated event UnTouch (Actor Other)
{
}

function RoundEnded ()
{
}

simulated function ClientRoundEnded ()
{
}

event PreClientTravel ()
{
}

function ClientShake (Vector shake)
{
}

function KilledBy (Pawn EventInstigator)
{
}

function Died (Pawn Killer, name DamageType, Vector HitLocation)
{
}

exec function ShowScores ()
{
}

exec function s_kFlashlight ()
{
}

exec function SwitchWeapon (byte F)
{
}

exec function PrevWeapon ()
{
}

exec function NextWeapon ()
{
}

exec function punishTK ()
{
}

function ServerpunishTK ()
{
}

exec function vote (int PlayerID)
{
}

function ServerVote (int PlayerID)
{
}

simulated function SetBlindTime (float Time)
{
}

simulated function bool EscapePress ()
{
}

simulated function MenuClosed ()
{
}

exec function ShowMenu ()
{
}

simulated function bool TraceTarget (out Actor HitTarget, out float Distance)
{
}

simulated function UsePress ()
{
}

function ServerUsePress ()
{
}

simulated function UseRelease ()
{
}

function UseReleaseServer (bool Succeed, bool bCheck)
{
}

function ActivateConsoleTimer (TO_ConsoleTimer ct)
{
}

simulated function ClientUseConsoleTimer (float BeginActivate, float duration, TO_ConsoleTimer ct)
{
}

function ActivateC4 (s_ExplosiveC4 c4)
{
}

simulated function ClientUseC4 (float duration)
{
}

function bool CheckTrigger ()
{
}

exec function s_kNightVision ()
{
}

exec function s_kammo ()
{
}

function TeamRadio (Sound Radio)
{
}

simulated function s_ChangeTeam (int Num, int Team, bool bDie)
{
}

function Escape ()
{
}

exec function EndRound ()
{
}

function ServerEndRound ()
{
}

function AddMoney (int Amount, optional bool bnocheck)
{
}

simulated function HUD_Add_Death_Message (PlayerReplicationInfo KillerPRI, PlayerReplicationInfo VictimPRI)
{
}

simulated function HUD_Add_Money_Message (int Amount)
{
}

function BuyKnives ()
{
}

function bool HaveMoney (int Amount)
{
}

function S_Weapon FindWeaponByGroup (int Group)
{
}

function CheckWeaponSell (S_Weapon W, int Wish)
{
}

function CloseBuymenu ()
{
}

function AddVelocity (Vector NewVelocity)
{
}

function PlayHit (float Damage, Vector HitLocation, name DamageType, Vector Momentum)
{
}

function TakeDamage (int Damage, Pawn instigatedBy, Vector HitLocation, Vector Momentum, name DamageType)
{
}

exec function ViewPlayerNum (optional int Num)
{
}

exec function ViewPlayer (string S)
{
}

exec function ViewSelf ()
{
}

exec function ViewClass (Class<Actor> aClass, optional bool bQuiet)
{
}

exec function BehindView (bool B)
{
}

exec function AdminSet (int Val, string S)
{
}

exec function AdminReset ()
{
}

simulated function ResetTime (float nrt)
{
}

state PlayerSpectating
{
	function ChangeTeam (int N)
	{
	}
	
	function ViewShake (float DeltaTime)
	{
	}
	
	simulated function UsePress ()
	{
	}
	
	exec function Fire (optional float F)
	{
	}
	
	exec function AltFire (optional float F)
	{
	}
	
	function PlayerMove (float DeltaTime)
	{
	}
	
	exec function Say (string Msg)
	{
	}
	
	exec function TeamSay (string Msg)
	{
	}
	
	function EndState ()
	{
	}
	
	function BeginState ()
	{
	}
	
}

state PlayerWaiting
{
	function ChangeTeam (int N)
	{
	}
	
	exec function Jump (optional float F)
	{
	}
	
	exec function Suicide ()
	{
	}
	
	exec function Fire (optional float F)
	{
	}
	
	exec function AltFire (optional float F)
	{
	}
	
	function ProcessMove (float DeltaTime, Vector newAccel, EDodgeDir DodgeMove, Rotator DeltaRot)
	{
	}
	
	function PlayWaiting ()
	{
	}
	
	event PlayerTick (float DeltaTime)
	{
	}
	
	function PlayerMove (float DeltaTime)
	{
	}
	
	function EndState ()
	{
	}
	
	function BeginState ()
	{
	}
	
}

simulated function SetMesh ()
{
}

function ServerChangeSkin (coerce string SkinName, coerce string FaceName, byte TeamNum)
{
}

static function SetMultiSkin (Actor SkinActor, string SkinName, string FaceName, byte TeamNum)
{
}

static function bool SetSkinElement (Actor SkinActor, int SkinNo, string SkinName, string DefaultSkinName)
{
}

function PlayDying (name DamageType, Vector HitLoc)
{
}

function PlayGutHit (float TweenTime)
{
}

function PlayHeadHit (float TweenTime)
{
}

function PlayLeftHit (float TweenTime)
{
}

function PlayRightHit (float TweenTime)
{
}

function CalcBehindView (out Vector CameraLocation, out Rotator CameraRotation, float dist)
{
}

function RescueHostage (s_NPCHostage Hostage)
{
}

function HandleWalking ()
{
}

function TOCrouch ()
{
}

function bool TOStandUp (bool bForce)
{
}

exec function Say (string Msg)
{
}

exec function TeamSay (string Msg)
{
}

state PlayerWalking
{
	exec function FeignDeath ()
	{
	}
	
	function ProcessMove (float DeltaTime, Vector newAccel, EDodgeDir DodgeMove, Rotator DeltaRot)
	{
	}
	
	function BeginState ()
	{
	}
	
	function EndState ()
	{
	}
	
}

state PlayerSwimming
{
	function BeginState ()
	{
	}
	
}

state Dying
{
	event PlayerTick (float DeltaTime)
	{
	}
	
	function ViewFlash (float DeltaTime)
	{
	}
	
	function Timer ()
	{
	}
	
	exec function Fire (optional float F)
	{
	}
	
	exec function AltFire (optional float F)
	{
	}
	
	function BeginState ()
	{
	}
	
	function EndState ()
	{
	}
	
}

state Climbing
{
	function AnimEnd ()
	{
	}
	
	function ProcessMove (float DeltaTime, Vector newAccel, EDodgeDir DodgeMove, Rotator DeltaRot)
	{
	}
	
	event PlayerTick (float DeltaTime)
	{
	}
	
	function PlayerMove (float DeltaTime)
	{
	}
	
	function BeginState ()
	{
	}
	
	function EndState ()
	{
	}
	
}

state PreRound
{
	exec function AltFire (optional float F)
	{
	}
	
	exec function Fire (optional float F)
	{
	}
	
	function AnimEnd ()
	{
	}
	
	event PlayerTick (float DeltaTime)
	{
	}
	
	function PlayerMove (float DeltaTime)
	{
	}
	
	function ReplicateMove (float DeltaTime, Vector newAccel, EDodgeDir DodgeMove, Rotator DeltaRot)
	{
	}
	
	function ProcessMove (float DeltaTime, Vector newAccel, EDodgeDir DodgeMove, Rotator DeltaRot)
	{
	}
	
	simulated function BeginState ()
	{
	}
	
	simulated function EndState ()
	{
	}
	
Begin:
}

state UsingConsoleTimer
{
	function TakeDamage (int Damage, Pawn instigatedBy, Vector HitLocation, Vector Momentum, name DamageType)
	{
	}
	
	function RoundEnded ()
	{
	}
	
	simulated function ClientRoundEnded ()
	{
	}
	
	exec function AltFire (optional float F)
	{
	}
	
	exec function Fire (optional float F)
	{
	}
	
	event PlayerTick (float DeltaTime)
	{
	}
	
	function PlayerMove (float DeltaTime)
	{
	}
	
	simulated function UseRelease ()
	{
	}
	
	function UseReleaseServer (bool bSucceed, bool bCheck)
	{
	}
	
	function BeginState ()
	{
	}
	
	function EndState ()
	{
	}
	
Begin:
}

state UsingC4
{
	function TakeDamage (int Damage, Pawn instigatedBy, Vector HitLocation, Vector Momentum, name DamageType)
	{
	}
	
	function RoundEnded ()
	{
	}
	
	simulated function ClientRoundEnded ()
	{
	}
	
	exec function AltFire (optional float F)
	{
	}
	
	exec function Fire (optional float F)
	{
	}
	
	event PlayerTick (float DeltaTime)
	{
	}
	
	function PlayerMove (float DeltaTime)
	{
	}
	
	simulated function UseRelease ()
	{
	}
	
	function UseReleaseServer (bool bSucceed, bool bCheck)
	{
	}
	
	function BeginState ()
	{
	}
	
	function EndState ()
	{
	}
	
Begin:
}

simulated function GetNearByHostage (out string HostageName[30], out s_NPCHostage Hostage[30], out int NumHostage)
{
}

exec function debug ()
{
}

simulated function bool IsInBuyZone ()
{
}

function PlayLadderSound ()
{
}

function PlayDecap ()
{
}

function ClientPlayTakeHit (Vector HitLoc, byte Damage, bool bServerGuessWeapon)
{
}

function TakeFallingDamage ()
{
}

exec function s_kammoAuto (int QuikBuyNum)
{
}

exec function k_SellWeapon ()
{
}

simulated function bool ShouldWeaponBeShown (string WeaponString)
{
}

simulated function CalculateWeight ()
{
}

event HeadZoneChange (ZoneInfo newHeadZone)
{
}

exec function ThrowWeapon ()
{
}

function ViewFlash (float DeltaTime)
{
}

simulated function PlayFootStep ()
{
}

simulated function FootStepping ()
{
}

exec function AddBotNamed (string BotName)
{
}

event bool EncroachingOn (Actor Other)
{
}

exec function Fire (optional float F)
{
}

exec function AltFire (optional float F)
{
}

exec function ToggleHUDDisplay ()
{
}

exec function Advance ()
{
}

exec function AdvanceAll ()
{
}

function PlayDyingSound ()
{
}

function PlayWinMessage (bool bWinner)
{
}

function ReplicateMove (float DeltaTime, Vector newAccel, EDodgeDir DodgeMove, Rotator DeltaRot)
{
}
