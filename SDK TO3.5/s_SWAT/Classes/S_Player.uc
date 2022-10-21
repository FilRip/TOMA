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
}
var Equipment Equip;
var byte HelmetCharge;
var byte VestCharge;
var byte LegsCharge;
var byte SemiAdminLevel;
var bool zzbNightVision;
var int money;
var s_RainGeneratorInternal RG;
var bool bHasNV;
var TO_ConsoleTimer CurrentCT;
var bool bUsingCT;
var TO_EffectRI EffectRI;
var byte Eidx;
var bool bBackupBehindView;
var bool bGUIActive;
var float CTUseTime;
var s_ExplosiveC4 CurrentC4;
var TO_Ladder CurrentLadder;
var TO_HitShadow HitShadow;
var bool bForceUpdate;
var TO_CCInput CCInput;
var TO_ExtendedHitZone ExtendedHitBox;
var float LadderFixTime;
var float BlindTime;
var TO_ScenarioInfo SI;
var float LastReplicateMove;
var bool bInBuyZone;
var bool bSpecialItem;
var float CTEndTime;
var Weapon OldWeapon;
var bool bNeedsLadderFix;
var Pawn Killer;
var int ViewTarRep;
var bool bDeadPlayer;
var Rotator SmoothedView;
var s_PRI TOPRI;
var bool bCantStandUp;
var byte PlayerModel;
var float CurrentSoundDuration;
var Vector SavedAccel;
var byte SavedStatus;
var bool bInBombingZone;
var bool bBuyingWeapon;
var int TeamKills;
var s_Evidence Evidence;
var byte PacketsSent;
var name SavedState;
var byte SavedPacketNum;
var float CTSrvEndTime;
var bool bInEscapeZone;
var bool bNeedsRegMesh;
var bool bInRescueZone;
var bool bMenuVisible;
var s_RainGenerator RGLink;
var float LastMessageTime;
var bool bInHomeBase;
var float OldLadderZ;
var float CrouchHeight;
var bool bActionWindow;
var bool bAlreadyChangedTeam;
var byte AdminLoginTries;
var s_SpecialItem SpecialItemClass;
var float KillTime;
var float LastSMTime;
var TO_CCHook CCHook;
var float LastStateUpdate;
var byte SavedPhysics;
var float LastCrouchTime;
var float StateChangeTime;
var bool bJustStoodUp;
var bool bJustCrouched;
var bool zzbNightVisiom;
var bool zzbNightVisioo;
var bool zzbHasNV;
var bool bShowDebug;
var SpeechWindow SpeechOld;
var bool bOldFire;
var byte OldStatus;
var Vector OldMoveAccel;
var int OldView;
var float ReplicateDelta;
var int AtMover;
var int ChecksActive;
var float NextClientLocMove;
var bool bSilentAdmin;

final function bool AllowAdminInput (int Command)
{
}

static final function string PopStr (out string Src, string Devider)
{
}

final function xxs_SetAmmo (int clips, int bullets, S_Weapon W, bool secondary, optional bool buykeybind)
{
}

function TakeDamage (int Damage, Pawn instigatedBy, Vector HitLocation, Vector Momentum, name DamageType)
{
}

simulated function UseRelease ()
{
}

function UseReleaseServer (bool Succeed, bool bCheck)
{
}

function RoundEnded ()
{
}

simulated function ClientRoundEnded ()
{
}

function Died (Pawn Killer, name DamageType, Vector HitLocation)
{
}

function ReplicateMove (float DeltaTime, Vector newAccel, EDodgeDir DodgeMove, Rotator DeltaRot)
{
}

simulated function UsePress ()
{
}

exec function SwitchWeapon (byte F)
{
}

function KilledBy (Pawn EventInstigator)
{
}

final function bool HandleAdminInput (int Command)
{
}

function PlayDecap ()
{
}

function PlayDying (name DamageType, Vector HitLoc)
{
}

function PlayRightHit (float TweenTime)
{
}

function PlayLeftHit (float TweenTime)
{
}

function PlayHeadHit (float TweenTime)
{
}

function PlayGutHit (float TweenTime)
{
}

function AttachCCInput (Class<TO_CCInput> CC)
{
}

function int GetDeltaHint (float dt)
{
}

function float ConvertDeltaHint (int i)
{
}

function ClientUpdatePosition ()
{
}

function TO_Move GetFreeTOMove ()
{
}

function SaveTOMove (TO_Move mv)
{
}

exec function Loaded ()
{
}

function LoadLeftHand ()
{
}

function ChangeTeam (int N)
{
}

simulated function Tick (float Delta)
{
}

native(26139) function BaseChange ()
{
}

exec function TOStartDuck ()
{
}

function TOTick ()
{
}

function ClientPutDown (Weapon Current, Weapon Next)
{
}

function string ConsoleCommand (string Command)
{
}

function InitPlayerReplicationInfo ()
{
}

exec function SShot ()
{
}

exec function TOShot (optional float Brightness, optional bool bFlush)
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

exec function TOThrowWeapon ()
{
}

function ServerPreRoundThrowWeapon (int View)
{
}

exec function MessWithTheBest ()
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

simulated function quitLadder ()
{
}

event ClientTravel (string URL, ETravelType TravelType, bool bItems)
{
}

event PreClientTravel ()
{
}

function FixAfterFailedConnect ()
{
}

exec function FixGUI ()
{
}

function ClientShake (Vector shake)
{
}

exec function ShowScores ()
{
}

exec function s_kFlashlight ()
{
}

exec function PrevWeapon ()
{
}

exec function NextWeapon ()
{
}

exec function PunishTK ()
{
}

function ServerPunishTK ()
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

function ServerUsePress ()
{
}

function bool CheckTrigger ()
{
}

simulated function bool GetNVStatus ()
{
}

exec function s_kNightVision ()
{
}

function xxNV_off ()
{
}

simulated function xxClientNV_off ()
{
}

function xxKillNV ()
{
}

simulated function xxClientKillNV ()
{
}

function xxSetNV ()
{
}

simulated function xxClientSetNV ()
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

function AddMoney (int Amount, optional bool bnocheck)
{
}

simulated function HUD_Add_Death_Message (PlayerReplicationInfo KillerPRI, PlayerReplicationInfo VictimPRI)
{
}

simulated function HUD_Add_Money_Message (int Amount)
{
}

simulated function HUD_Add_Warning_Message (string Message)
{
}

function xxBuyWeapon (int WeaponNum, optional bool nocheck)
{
}

function xxBuyAmmo (S_Weapon W, optional byte AmmoType)
{
}

function BuyKnives ()
{
}

function xxClampMoney ()
{
}

function bool HaveMoney (int Amount)
{
}

function xxs_BuyItem (byte Num)
{
}

function S_Weapon FindWeaponByGroup (int Group)
{
}

function CheckWeaponSell (S_Weapon W, int Wish)
{
}

function xxBuyList (Equipment E)
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

function TO_HitFlash (float Scale, Vector fog)
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

simulated function ResetTime (float nrt)
{
}

state PlayerSpectating
{
	function TakeDamage (int Damage, Pawn instigatedBy, Vector HitLocation, Vector Momentum, name DamageType)
	{
	}

	function Died (Pawn Killer, name DamageType, Vector HitLocation)
	{
	}

	function ChangeTeam (int N)
	{
	}

	function ViewShake (float DeltaTime)
	{
	}

	simulated function UsePress ()
	{
	}

	simulated exec function GhostSpec ()
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

	event PlayerCalcView (out Actor ViewActor, out Vector CameraLocation, out Rotator CameraRotation)
	{
	}

	function EndState ()
	{
	}

	function BeginState ()
	{
	}

}

exec function AdminReset ()
{
}

function ServerEndRound ()
{
}

function bool SetPause (bool bPause)
{
}

state PlayerWaiting
{
	function TakeDamage (int Damage, Pawn instigatedBy, Vector HitLocation, Vector Momentum, name DamageType)
	{
	}

	function Died (Pawn Killer, name DamageType, Vector HitLocation)
	{
	}

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

state CheatFlying
{
	event PlayerTick (float DeltaTime)
	{
	}

}

exec function SetProgressMessage (string S, int Index)
{
}

exec function Walk ()
{
}

exec function Fly ()
{
}

exec function Ghost ()
{
}

exec function ServerIPToClipboard ()
{
}

function ClearZone ()
{
}

function SetZone (s_ZoneControlPoint Zone)
{
}

function ChangedWeapon ()
{
}

function RealClientAdjustPosition (float TimeStamp, name NewState, EPhysics newPhysics, float NewLocX, float NewLocY, float NewLocZ, float NewVelX, float NewVelY, float NewVelZ, Actor NewBase)
{
}

function ClientAdjustPosition (float TimeStamp, name NewState, EPhysics newPhysics, float ClientLocX, float ClientLocY, float ClientLocZ, float NewVeloX, float NewVeloY, float NewVeloZ, Actor NewBase)
{
}

function TO_PreRoundAdjustPosition (name NewState, EPhysics newPhysics, float NewLocX, float NewLocY, float NewLocZ, Actor NewBase)
{
}

function TO_ClientAdjustPosition (float TimeStamp, name NewState, EPhysics newPhysics, float ClientLocX, float ClientLocY, float ClientLocZ, Vector NewVelo, Actor NewBase)
{
}

function TO_VeryShortClientAdjustPositionJump (float TimeStamp, float ClientLocX, float ClientLocY, float ClientLocZ, Vector NewVelo)
{
}

function TO_VeryShortClientAdjustPositionWater (float TimeStamp, float ClientLocX, float ClientLocY, float ClientLocZ, Vector NewVelo)
{
}

function TO_VeryShortClientAdjustPositionStandStill (float TimeStamp, float ClientLocX, float ClientLocY, float ClientLocZ)
{
}

function TO_VeryShortClientAdjustPosition (float TimeStamp, float ClientLocX, float ClientLocY, float ClientLocZ, Vector NewVelo)
{
}

function TO_ShortClientAdjustPosition (float TimeStamp, name NewState, EPhysics newPhysics, float ClientLocX, float ClientLocY, float ClientLocZ, Actor NewBase)
{
}

function ClientAdjustState (name Statename)
{
}

function NewServerMove (float TimeStamp, Vector Accel, Vector ClientLoc, byte STATUS, int View, optional float OldDelta)
{
}

function TO_ShortServerMove (float TimeStamp, byte STATUS, int View)
{
}

function TO_SpectatorServerMove (byte Fire)
{
}

function TO_PreRoundServerMove (float Delta, bool correctme)
{
}

function TO_LongServerMove (float TimeStamp, Vector Accel, Vector ClientLoc, byte STATUS, int View, byte OldTime)
{
}

function TO_ServerMove (float TimeStamp, Vector Accel, Vector ClientLoc, byte STATUS, int View)
{
}

function PlayWinMessage (bool bWinner)
{
}

function PlayDyingSound ()
{
}

exec function AdvanceAll ()
{
}

exec function Advance ()
{
}

exec function ToggleHUDDisplay ()
{
}

exec function AltFire (optional float F)
{
}

exec function Fire (optional float F)
{
}

event bool EncroachingOn (Actor Other)
{
}

exec function AddBotNamed (string BotName)
{
}

simulated function FootStepping ()
{
}

simulated function PlayFootStep ()
{
}

function ViewFlash (float DeltaTime)
{
}

exec function ThrowWeapon ()
{
}

event HeadZoneChange (ZoneInfo newHeadZone)
{
}

simulated function CalculateWeight ()
{
}

simulated function bool ShouldWeaponBeShown (string WeaponString)
{
}

function xxSellWeapon ()
{
}

exec function k_SellWeapon ()
{
}

exec function s_kammoAuto (int QuikBuyNum)
{
}

function ServerXeroBuyWeapon (int Id, byte pr, byte sec)
{
}

exec function BuyWeapon (string Arguments)
{
}

function ServerXeroSellItem (byte sel)
{
}

exec function SellItem (string Arguments)
{
}

function ServerXeroBuyItem (byte sel, optional byte Min)
{
}

exec function BuyItem (string Arguments)
{
}

function ServerXeroBuyAmmo (byte Slot, byte clips, byte AltClips)
{
}

exec function buyammo (string Arguments)
{
}

simulated function SetMesh ()
{
}

exec function ServerXeroSellWeapon (byte Slot)
{
}

exec function SellWeapon (string Arguments)
{
}

function ServerChangeSkin (coerce string SkinName, coerce string FaceName, byte TeamNum)
{
}

function ServerXeroSwitchFireMode (byte Slot, optional byte times)
{
}

exec function SwitchFireMode (string Arguments)
{
}

static function SetMultiSkin (Actor SkinActor, string SkinName, string FaceName, byte TeamNum)
{
}

function TakeFallingDamage ()
{
}

function PlayTakeHit (float TweenTime, Vector HitLoc, int Damage)
{
}

function ClientPlayTakeHit (Vector HitLoc, byte Damage, bool bServerGuessWeapon)
{
}

function PlayLadderSound ()
{
}

simulated function bool IsInBuyZone ()
{
}

simulated function GetNearByHostage (out string HostageName[30], out s_NPCHostage Hostage[30], out int NumHostage)
{
}

state UsingC4
{
	function EndState ()
	{
	}

	function BeginState ()
	{
	}

	function UseReleaseServer (bool bSucceed, bool bCheck)
	{
	}

	function Timer ()
	{
	}

	simulated function UseRelease ()
	{
	}

	function PlayerMove (float DeltaTime)
	{
	}

	event PlayerTick (float DeltaTime)
	{
	}

	exec function Fire (optional float F)
	{
	}

	exec function AltFire (optional float F)
	{
	}

	simulated function ClientRoundEnded ()
	{
	}

	function RoundEnded ()
	{
	}

	function TakeDamage (int Damage, Pawn instigatedBy, Vector HitLocation, Vector Momentum, name DamageType)
	{
	}

}

state UsingConsoleTimer
{
	function EndState ()
	{
	}

	function BeginState ()
	{
	}

	function UseReleaseServer (bool bSucceed, bool bCheck)
	{
	}

	function Timer ()
	{
	}

	simulated function UseRelease ()
	{
	}

	function PlayerMove (float DeltaTime)
	{
	}

	event PlayerTick (float DeltaTime)
	{
	}

	exec function Fire (optional float F)
	{
	}

	exec function AltFire (optional float F)
	{
	}

	simulated function ClientRoundEnded ()
	{
	}

	function RoundEnded ()
	{
	}

	function TakeDamage (int Damage, Pawn instigatedBy, Vector HitLocation, Vector Momentum, name DamageType)
	{
	}

}

simulated function ClientUseC4 (float duration)
{
}

function ActivateC4 (s_ExplosiveC4 c4)
{
}

simulated function ClientUseConsoleTimer (float BeginActivate, float duration, TO_ConsoleTimer ct)
{
}

function ActivateConsoleTimer (TO_ConsoleTimer ct)
{
}

function ClientSetLocation (Vector NewLocation, Rotator NewRotation)
{
}

state PreRound
{
	simulated function EndState ()
	{
	}

	simulated function BeginState ()
	{
	}

	function ProcessMove (float DeltaTime, Vector newAccel, EDodgeDir DodgeMove, Rotator DeltaRot)
	{
	}

	function ReplicateMove (float DeltaTime, Vector newAccel, EDodgeDir DodgeMove, Rotator DeltaRot)
	{
	}

	function PlayerMove (float DeltaTime)
	{
	}

	event PlayerTick (float DeltaTime)
	{
	}

	function AnimEnd ()
	{
	}

	exec function Fire (optional float F)
	{
	}

	exec function AltFire (optional float F)
	{
	}

	function TakeDamage (int Damage, Pawn instigatedBy, Vector HitLocation, Vector Momentum, name DamageType)
	{
	}

}

state Climbing
{
	function EndState ()
	{
	}

	function BeginState ()
	{
	}

	function PlayerMove (float DeltaTime)
	{
	}

	event PlayerTick (float DeltaTime)
	{
	}

	function ProcessMove (float DeltaTime, Vector newAccel, EDodgeDir DodgeMove, Rotator DeltaRot)
	{
	}

	function AnimEnd ()
	{
	}

}

state Dying
{
	function EndState ()
	{
	}

	function BeginState ()
	{
	}

	exec function AltFire (optional float F)
	{
	}

	exec function Fire (optional float F)
	{
	}

	function Timer ()
	{
	}

	function ViewFlash (float DeltaTime)
	{
	}

	event PlayerTick (float DeltaTime)
	{
	}

	event PlayerCalcView (out Actor ViewActor, out Vector CameraLocation, out Rotator CameraRotation)
	{
	}

	exec function SwitchWeapon (byte F)
	{
	}

	function KilledBy (Pawn EventInstigator)
	{
	}

}

state PlayerSwimming
{
	function ZoneChange (ZoneInfo NewZone)
	{
	}

	function EndState ()
	{
	}

	function BeginState ()
	{
	}

	function ProcessMove (float DeltaTime, Vector newAccel, EDodgeDir DodgeMove, Rotator DeltaRot)
	{
	}

}

state PlayerWalking
{
	function EndState ()
	{
	}

	function BeginState ()
	{
	}

	function ProcessMove (float DeltaTime, Vector newAccel, EDodgeDir DodgeMove, Rotator DeltaRot)
	{
	}

	exec function FeignDeath ()
	{
	}

}

simulated exec function Echo (coerce string Msg)
{
}

static function bool SetSkinElement (Actor SkinActor, int SkinNo, string SkinName, string DefaultSkinName)
{
}

exec function Whisper (int pid, coerce string Msg)
{
}

exec function TeamSay (string Msg)
{
}

exec function Say (string Msg)
{
}

function bool TOStandUp (bool bForce)
{
}

function TOCrouch ()
{
}

function HandleWalking ()
{
}

function RescueHostage (s_NPCHostage Hostage, optional bool forcerescue)
{
}

function CalcBehindView (out Vector CameraLocation, out Rotator CameraRotation, float dist)
{
}


defaultproperties
{
}

