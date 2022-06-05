class TO_GameBasics extends TO_TeamGamePlus;

enum EGamePeriod
{
	GP_PreRound,
	GP_RoundPlaying,
	GP_PostRound,
	GP_RoundRestarting,
	GP_PostMatch
};

var EGamePeriod GamePeriod;
var config byte RoundLimit;
var byte RoundNumber;
var byte RoundDelay;
var string RoundReason;
var bool RoundRestarting;
var() config int RoundDuration;
var int RoundStarted;
var() config int PreRoundDuration1;
var int PreRoundDelay;
var bool bFirstKill;
var int CTAmount;
var int TerrAmount;
var int KillPrice;
var int KillHostagePrice;
var int WinAmount;
var int LostAmount;
var int RescueAmount;
var int RescueTeamAmount;
var int EvidenceAmount;
var byte WinningTeam;
var byte LTLostRounds;
var bool bHasHostages;
var bool bHostageRescueWin;
var byte nbHostages;
var byte nbRescuedHostages;
var byte nbHostagesLeft;
var bool bTShotHostages;
var byte Escaped_Terr;
var byte Escaped_SF;
var bool bBombDefusion;
var byte BombTeam;
var bool bBombDefusionWin;
var bool bBombGiven;
var bool bBombPlanted;
var bool bGivingBomb;
var bool bBombDropped;
var bool bC4Explodes;
var Actor C4Link;
var s_NPCHostageInfo NPCHConfig;
var TO_ScenarioInfo SI;
var s_Ladder s_Ladder;
var S_Trigger S_Trigger;
var TO_ConsoleTimerPN CTLink;
var s_ZoneControlPoint ZCPLink;
var bool bOldZoomType;
var() config bool bEnableBallistics;
var() config bool bReduceSFX;
var() config bool bDisableRealDamages;
var() config bool bDisableIDLEManager;
var() config bool bLinuxFix;
var() config bool bDisableActorResetter;
var() config bool bMirrorDamage;
var() config bool bExplosionFF;
var() config bool bAllowPunishTK;
var() config bool bAllowGhostCam;
var() config bool bAllowBehindView;
var() config int MinAllowedScore;
var S_Player NextTempKickBan;
var ActorList ActorManager;
var TO_IDLEManager IDLEManager;
var int MaxMoney;
var string TempBanList[50];
var PlayerPawn TO_LocalPlayer;
var int EndRoundDelay;
var bool bFixedMapProblems;
var float NameChangeInterval;
var bool bSinglePlayer;
var int postGameTime;

function TOResetGame ()
{
}

function RestartRound ()
{
}

function BeginRound ()
{
}

function GiveBomb ()
{
}

event PostBeginPlay ()
{
}

event Destroyed ()
{
}

function TO_CleanUp ()
{
}

function ProcessServerTravel (string URL, bool bItems)
{
}

event InitGame (string Options, out string Error)
{
}

function InitGameReplicationInfo ()
{
}

function InitRatedGame (LadderInventory LadderObj, PlayerPawn LadderPlayer)
{
}

function CheckReady ()
{
}

function bool SetEndCams (string Reason)
{
}

event PreLogin (string Options, string Address, out string Error, out string FailCode)
{
}

final function string SetTeamOption (string Options, string Key, string NewVal)
{
}

function PlayerPawn Login (string Portal, string Options, out string Error, Class<PlayerPawn> SpawnClass)
{
}

event PostLogin (PlayerPawn NewPlayer)
{
}

final function PlayerJoined (S_Player P)
{
}

function Logout (Pawn Exiting)
{
}

final function Kick (PlayerPawn P)
{
}

final function KickBan (PlayerPawn P, string Reason)
{
}

final function TempKickBan (PlayerPawn P, string Reason)
{
}

final function bool IsTempBanned (string IP)
{
}

function AdminLogin (PlayerPawn P, string Password)
{
}

function AdminLogout (PlayerPawn P)
{
}

function byte FindTeamByName (string TeamName)
{
}

function NavigationPoint FindPlayerStart (Pawn Player, optional byte InTeam, optional string incomingName)
{
}

final function bool ReduceExplosions (name DamageType)
{
}

function int SWATReduceDamage (int Damage, name DamageType, Pawn injured, Pawn instigatedBy, Vector HitLocation)
{
}

final function int SWAT_NPC_ReduceDamage (int Damage, name DamageType, s_NPC injured, Pawn instigatedBy, Vector HitLocation)
{
}

final function int SWAT_Player_ReduceDamage (int Damage, name DamageType, S_Player injured, Pawn instigatedBy, Vector HitLocation)
{
}

final function int SWAT_Bot_ReduceDamage (int Damage, name DamageType, s_bot injured, Pawn instigatedBy, Vector HitLocation)
{
}

final function bool CheckTK (Pawn Other)
{
}

function Killed (Pawn Killer, Pawn Other, name DamageType)
{
}

final function LogKillStats (Pawn Killer, Pawn Other, name DamageType)
{
}

function ReBalance ()
{
}

function SetPlayerStartPoint (Pawn aPlayer)
{
}

function bool RestartPlayer (Pawn aPlayer)
{
}

function CheckEndGame ()
{
}

function EndGame (string Reason)
{
}

final function bool IsRoundPeriodPlaying ()
{
}

final function RoundEnded ()
{
}

final function SetWinner (int WinTeam)
{
}

final function SetMoney ()
{
}

function Timer ()
{
}

final function EndPreRound ()
{
}

final function Rescued (s_NPCHostage H)
{
}

final function CheckHostageWin ()
{
}

final function Escape (Pawn aPawn)
{
}

final function SetupHostages ()
{
}

final function ClearNPC ()
{
}

final function ResetNPCPlayer (Pawn aPlayer)
{
}

function bool ChangeTeam (Pawn Other, int NewTeam)
{
}

function AddToTeam (int Num, Pawn Other)
{
}

function bool CanSpectate (Pawn Viewer, Actor ViewTarget)
{
}

function TeamInfo GetTeam (int TeamNum)
{
}

function bool IsOnTeam (Pawn Other, int TeamNum)
{
}

function bool AddBot ()
{
}

function Bot SpawnBot (out NavigationPoint StartSpot)
{
}

function SetBotOrders (Bot NewBot)
{
}

function bool BotCanReachTarget (s_bot aBot, Actor Target)
{
}

final function NavigationPoint FindHostages (s_bot aBot)
{
}

final function bool IsCloseToHidingPoint (Actor B)
{
}

final function NavigationPoint FindHomeBase (s_bot aBot)
{
}

final function NavigationPoint FindEnemyBase (s_bot aBot)
{
}

final function NavigationPoint FindRescuePoint (s_bot aBot)
{
}

final function NavigationPoint FindBuyPoint (s_bot aBot)
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

final function Actor FindC4Explosive (s_bot aBot)
{
}

final function s_SpecialItem FindSpecialItem (s_bot aBot)
{
}

final function s_Evidence FindEvidence (s_bot aBot)
{
}

final function ResetBotObjective (s_bot B, float CampTime)
{
}

final function ClearBotObjective (s_bot B)
{
}

function ClearOrders (Pawn Leaving)
{
}

function BotCheckOrderObject (Pawn P)
{
}

function byte AssessBotAttitude (Bot aBot, Pawn Other)
{
}

function AddDefaultInventory (Pawn PlayerPawn)
{
}

function GiveTeamWeapons (Pawn P)
{
}

final function AddMoney (Pawn Dude, int Amount, optional bool nocheck)
{
}

final function S_Weapon BuyWeapon (Pawn P, int WeaponNum, optional bool nocheck)
{
}

simulated function bool ShouldWeaponBeHidden (string WeaponString)
{
}

simulated function bool ShouldWeaponBeShown (string WeaponString)
{
}

final function bool HaveMoney (Pawn Man, int Amount)
{
}

final function buyammo (Pawn P, S_Weapon W)
{
}

final function BuyPrimaryAmmo (Pawn P, S_Weapon W)
{
}

final function BuyAltAmmo (Pawn P, S_Weapon W)
{
}

final function BuyKnives (Pawn P)
{
}

final function RescueHostage (Pawn P, s_NPCHostage H)
{
}

final function LockHostage (Pawn P, s_NPCHostage H)
{
}

final function TerrEscortHostage (Pawn P, s_NPCHostage H)
{
}

final function Bot SpawnNPCH (NavigationPoint StartSpot)
{
}

function GiveWeapon (Pawn PlayerPawn, string aClassName)
{
}

final function ForceSkinUpdate (Pawn P)
{
}

final simulated function bool IsInBuyZone (Pawn P)
{
}

function SpawnSpecialItems ()
{
}

function SpawnEvidence ()
{
}

final function DropEvidence (Class<s_Evidence> Evidence, Pawn Other, Vector DropLocation)
{
}

final function DropSpecialItem (Class<s_SpecialItem> SpecialItem, Pawn Other, Vector DropLocation)
{
}

function DropMoney (Pawn Other, int PezAmount, Vector DropLocation)
{
}

final function KillInventory (Pawn P, optional bool buymenu)
{
}

final function DropInventory (Pawn Other, bool bDropMoney)
{
}

final function SpawnScriptedPawn ()
{
}

function PreCacheReferences ()
{
}

function bool PickupQuery (Pawn Other, Inventory Item)
{
}

final function ChangeModel (Pawn P, int Num)
{
}

final function ChangePModel (Pawn P, int Num, int Team, bool bDie)
{
}

final function SetRandomSFModel (Pawn Other)
{
}

final function SetRandomTerrModel (Pawn Other)
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

function PlayRandEnemyDown (Pawn P)
{
}

function ChangeName (Pawn Other, string S, bool bNameChange)
{
}

function SetBotObjectives (s_bot B)
{
}

function SetWinnerPlus (int WinTeam)
{
}

function EndGamePlus (string Reason)
{
}

function HostageKilled (Pawn Killer, Pawn Other, name DamageType)
{
}

function C4ExplodedPlus (bool bExplodedInBombingZone, Actor BombingZone)
{
}

function DrawAdditionnalHudElements (Canvas Canvas, TO_DesignInfo Design, s_HUD mainHud)
{
}

function IncrementPlayerShotsFired (Pawn ShotInstigator)
{
}

function C4Planted (Vector PlantLocation, s_ExplosiveC4 PlantedC4)
{
}

function int GetSPPlayerTeam ()
{
}

function int GetbSpawnEndGameTriggers ()
{
}

function int GetSPBestCurrentTime ()
{
}

function int GetSPCurrentTime ()
{
}
