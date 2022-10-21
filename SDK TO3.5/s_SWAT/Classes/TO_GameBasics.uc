class TO_GameBasics extends TO_TeamGamePlus;

var TO_ScenarioInfo SI;
enum EGamePeriod {
	GP_PreRound,
	GP_RoundPlaying,
	GP_PostRound,
	GP_RoundRestarting,
	GP_PostMatch
};
var EGamePeriod GamePeriod;
var bool bSinglePlayer;
var Rotator LastFireDir;
var S_Weapon LastUsedWeapon;
var int RoundDuration;
var bool bEnableBallistics;
var bool bAllowBehindView;
var byte RoundNumber;
var s_NPCHostageInfo NPCHConfig;
var int MinAllowedScore;
var s_ZoneControlPoint ZCPLink;
var int CTAmount;
var byte WinningTeam;
var int TerrAmount;
var bool bAllowGhostCam;
var ActorList ActorManager;
var bool bMirrorDamage;
var int EvidenceAmount;
var byte RoundDelay;
var int WinAmount;
var int PreRoundDuration;
var byte LTLostRounds;
var byte nbHostages;
var byte Escaped_Terr;
var bool bReduceSFX;
var bool bExplosionFF;
var TO_IDLEManager IDLEManager;
var S_Trigger S_Trigger;
var Actor C4Link;
var bool bBombDropped;
var byte nbHostagesLeft;
var byte RoundLimit;
var bool bAdminMessageHack;
var int TraceAgainTargetsNum;
var PlayerPawn TO_LocalPlayer;
var S_Player NextTempKickBan;
var TO_ConsoleTimerPN CTLink;
var bool bBombPlanted;
var bool bBombDefusion;
var bool bHasHostages;
var int LostAmount;
var int KillPrice;
var int MaxMoney;
var int PreRoundDelay;
var int RoundStarted;
var bool bFirstKill;
var bool bHostageRescueWin;
var byte nbRescuedHostages;
var bool bTShotHostages;
var byte Escaped_SF;
var bool bBombGiven;
var bool bGivingBomb;
var bool bC4Explodes;
var bool bDisableRealDamages;
var bool bDisableIDLEManager;
var bool bDisableActorResetter;
var bool bAllowPunishTK;
var float RemainingLength;
var bool bHandleRestartGame;
var bool bHandleEndGame;
var int StartUpMoney;
var Actor TraceAgainTargets;
var S_Weapon DefTeamWeapon;
var int postGameTime;
var bool bFixedMapProblems;
var bool bLinuxFix;
var bool bBombDefusionWin;
var int KillHostagePrice;
var int RescueAmount;
var int RescueTeamAmount;
var float NameChangeInterval;
var S_Weapon DefTeamWeapo;
var int EndRoundDelay;
var bool bNoLagCompensation;
var bool bOldZoomType;
var s_Ladder s_Ladder;
var byte BombTeam;
var bool RoundRestarting;

final function ResetBotObjective (s_bot B, float CampTime)
{
}

final function AddMoney (Pawn Dude, int Amount, optional bool nocheck)
{
}

final function SetWinner (int WinTeam)
{
}

final function ClearBotObjective (s_bot B)
{
}

final function bool HaveMoney (Pawn Man, int Amount)
{
}

final function TempKickBan (PlayerPawn P, optional string Reason)
{
}

final function KickBan (PlayerPawn P, optional string Reason)
{
}

final function NavigationPoint FindHostages (s_bot aBot)
{
}

final function S_Weapon BuyWeapon (Pawn P, int WeaponNum, optional bool nocheck)
{
}

final function NavigationPoint FindRescuePoint (s_bot aBot)
{
}

final function ChangeModel (Pawn P, int Num)
{
}

final function TerrEscortHostage (Pawn P, s_NPCHostage H)
{
}

final function DropInventory (Pawn Other, bool bDropMoney)
{
}

final function SetRandomSFModel (Pawn Other)
{
}

final function SetRandomTerrModel (Pawn Other)
{
}

final function NavigationPoint FindBuyPoint (s_bot aBot)
{
}

final function bool IsCloseToHidingPoint (Actor B)
{
}

final function bool ReduceExplosions (name DamageType)
{
}

final function Kick (Pawn P, optional string Reason)
{
}

final function bool IsRoundPeriodPlaying ()
{
}

final function RoundEnded ()
{
}

final function LockHostage (Pawn P, s_NPCHostage H)
{
}

final function KillInventory (Pawn P, optional bool buymenu)
{
}

function DropSpecialItem (Class<s_SpecialItem> SpecialItem, Pawn Other, Vector DropLocation)
{
}

function DropEvidence (Class<s_Evidence> Evidence, Pawn Other, Vector DropLocation)
{
}

final function RescueHostage (Pawn P, s_NPCHostage H)
{
}

final function buyammo (Pawn P, S_Weapon W)
{
}

final function Actor FindC4Explosive (s_bot aBot)
{
}

final function NavigationPoint FindEnemyBase (s_bot aBot)
{
}

final function NavigationPoint FindHomeBase (s_bot aBot)
{
}

final function ResetNPCPlayer (Pawn aPlayer)
{
}

final function ClearNPC ()
{
}

final function Escape (Pawn aPawn)
{
}

final function CheckHostageWin ()
{
}

final function bool IsTempBanned (string IP)
{
}

final function string SetTeamOption (string Options, string Key, string NewVal)
{
}

function TOResetGame ()
{
}

function RestartRound (optional string Reason)
{
}

function BeginRound ()
{
}

function GiveBomb ()
{
}

final function PlayerJoined (S_Player P)
{
}

native(4) final latent function int SWAT_NPC_ReduceDamage (int Damage, name DamageType, s_NPC injured, Pawn instigatedBy, Vector HitLocation)
{
}

native(4) final latent function int SWAT_Player_ReduceDamage (int Damage, name DamageType, S_Player injured, Pawn instigatedBy, Vector HitLocation)
{
}

native(4) final latent function int SWAT_Bot_ReduceDamage (int Damage, name DamageType, s_bot injured, Pawn instigatedBy, Vector HitLocation)
{
}

final function bool CheckTK (Pawn Other)
{
}

final function LogKillStats (Pawn Killer, Pawn Other, name DamageType)
{
}

final function SetMoney ()
{
}

final function EndPreRound ()
{
}

final function Rescued (s_NPCHostage H)
{
}

final function SetupHostages ()
{
}

final function NavigationPoint FindEscapeZone (s_bot aBot)
{
}

final function NavigationPoint FindC4TargetLocation (s_bot aBot)
{
}

final function Actor FindTOConsoleTimer (s_bot aBot)
{
}

final function s_SpecialItem FindSpecialItem (s_bot aBot)
{
}

final function s_Evidence FindEvidence (s_bot aBot)
{
}

final function BuyPrimaryAmmo (Pawn P, S_Weapon W)
{
}

final function BuyAltAmmo (Pawn P, S_Weapon W)
{
}

final function Bot SpawnNPCH (NavigationPoint StartSpot)
{
}

final function ForceSkinUpdate (Pawn P)
{
}

final function SpawnScriptedPawn ()
{
}

final function ChangePModel (Pawn P, int Num, int Team, bool bDie, optional bool Forced)
{
}

final function VotePlayerOut (S_Player Instigator, S_Player Victim)
{
}

final function ClientPlaySoundBeginRound (S_Player P)
{
}

final function ClientPlaySoundEndRound (S_Player P, byte WinningTeam)
{
}

function int GetSPCurrentTime ()
{
}

function int GetSPBestCurrentTime ()
{
}

function int GetbSpawnEndGameTriggers ()
{
}

function int GetSPPlayerTeam ()
{
}

function C4Planted (Vector PlantLocation, s_ExplosiveC4 PlantedC4)
{
}

function IncrementPlayerShotsFired (Pawn ShotInstigator)
{
}

function DrawAdditionnalHudElements (Canvas Canvas, TO_DesignInfo Design, s_HUD mainHud)
{
}

function C4ExplodedPlus (bool bExplodedInBombingZone, Actor BombingZone)
{
}

function HostageKilled (Pawn Killer, Pawn Other, name DamageType)
{
}

function EndGamePlus (string Reason)
{
}

function SetWinnerPlus (int WinTeam)
{
}

function SetBotObjectives (s_bot B)
{
}

function bool HitCylinder (Vector HitLocation, Vector HitVector, Vector StartLocation, Vector base1, Vector base2, float Radius, optional out Vector Entryloc)
{
}

function bool IsRelevant (Actor Other)
{
}

function TOClientBip (Vector Loc, Rotator Rot, byte Kind, int pid)
{
}

function TOClientCarcass (Vector Loc, int Id)
{
}

function TOPlayEffect (Class<Actor> SpawnClass, Vector Loc, optional Rotator Rot, optional bool sendroll, optional Actor NoSpawn)
{
}

function ChangeName (Pawn Other, string S, bool bNameChange)
{
}

function PlayRandEnemyDown (Pawn P)
{
}

function SetGamePeriod (EGamePeriod NewGamePeriod, optional string Reason)
{
}

function string GetRules ()
{
}

function bool PickupQuery (Pawn Other, Inventory Item)
{
}

function PreCacheReferences ()
{
}

function DropMoney (Pawn Other, int PezAmount, Vector DropLocation)
{
}

function SpawnEvidence ()
{
}

function SpawnSpecialItems ()
{
}

final simulated function bool IsInBuyZone (Pawn P)
{
}

function GiveWeapon (Pawn PlayerPawn, string aClassName)
{
}

final function BuyKnives (Pawn P)
{
}

simulated function bool ShouldWeaponBeShown (string WeaponString)
{
}

simulated function bool ShouldWeaponBeHidden (string WeaponString)
{
}

function GiveTeamWeapons (Pawn P, optional bool bNoPistols)
{
}

function AddDefaultInventory (Pawn PlayerPawn)
{
}

function byte AssessBotAttitude (Bot aBot, Pawn Other)
{
}

function BotCheckOrderObject (Pawn P)
{
}

function ClearOrders (Pawn Leaving)
{
}

function bool BotCanReachTarget (s_bot aBot, Actor Target)
{
}

function SetBotOrders (Bot NewBot)
{
}

function Bot SpawnBot (out NavigationPoint StartSpot)
{
}

function bool AddBot ()
{
}

function bool IsOnTeam (Pawn Other, int TeamNum)
{
}

function TeamInfo GetTeam (int TeamNum)
{
}

function bool CanSpectate (Pawn Viewer, Actor ViewTarget)
{
}

function AddToTeam (int Num, Pawn Other)
{
}

function bool ChangeTeam (Pawn Other, int NewTeam)
{
}

function Timer ()
{
}

function TOEndGame (string Reason)
{
}

function EndGame (string Reason)
{
}

function CheckEndGame ()
{
}

function bool RestartPlayer (Pawn aPlayer)
{
}

function SetPlayerStartPoint (Pawn aPlayer)
{
}

function ReBalance ()
{
}

function Killed (Pawn Killer, Pawn Other, name DamageType)
{
}

native(4) latent function int SWATReduceDamage (int Damage, name DamageType, Pawn injured, Pawn instigatedBy, Vector HitLocation)
{
}

function int GetHitBox (Pawn P, Vector HitLocation, bool bShoot, optional bool bSupressFire)
{
}

function TraceAgain (Vector Loc, Pawn P)
{
}

function NavigationPoint FindPlayerStart (Pawn Player, optional byte InTeam, optional string incomingName)
{
}

function byte FindTeamByName (string TeamName)
{
}

function AdminLogout (PlayerPawn P)
{
}

function AdminLogin (PlayerPawn P, string Password)
{
}

function Logout (Pawn Exiting)
{
}

event PostLogin (PlayerPawn NewPlayer)
{
}

function PlayerPawn Login (string Portal, string Options, out string Error, Class<PlayerPawn> SpawnClass)
{
}

event PreLogin (string Options, string Address, out string Error, out string FailCode)
{
}

function bool SetEndCams (string Reason)
{
}

function CheckReady ()
{
}

function InitRatedGame (LadderInventory LadderObj, PlayerPawn LadderPlayer)
{
}

function InitGameReplicationInfo ()
{
}

event InitGame (string Options, out string Error)
{
}

function ProcessServerTravel (string URL, bool bItems)
{
}

function TO_CleanUp ()
{
}

event Destroyed ()
{
}

event PostBeginPlay ()
{
}


defaultproperties
{
}

