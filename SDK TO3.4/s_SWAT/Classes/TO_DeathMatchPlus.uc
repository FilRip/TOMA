class TO_DeathMatchPlus extends TournamentGameInfo;

var() globalconfig int MinPlayers;
var() globalconfig float AirControl;
var() config int FragLimit;
var() config int TimeLimit;
var() globalconfig bool bChangeLevels;
var() globalconfig bool bHardCoreMode;
var bool bChallengeMode;
var() globalconfig bool bMegaSpeed;
var() globalconfig bool bAltScoring;
var() config bool bMultiWeaponStay;
var() config bool bForceRespawn;
var bool bAlwaysForceRespawn;
var bool bDontRestart;
var bool bAlreadyChanged;
var bool bFirstBlood;
var() globalconfig bool bTournament;
var bool bRequireReady;
var() bool bNoviceMode;
var() globalconfig int NetWait;
var() globalconfig int TO_RestartWait;
var config bool bUseTranslocator;
var bool bJumpMatch;
var bool bThreePlus;
var bool bFulfilledSpecial;
var bool bNetReady;
var bool bRatedTranslocator;
var bool bStartMatch;
var int RemainingTime;
var int ElapsedTime;
var int CountDown;
var int StartCount;
var localized string StartUpMessage;
var localized string TourneyMessage;
var localized string WaitingMessage1;
var localized string WaitingMessage2;
var localized string ReadyMessage;
var localized string NotReadyMessage;
var localized string CountDownMessage;
var localized string StartMessage;
var localized string GameEndedMessage;
var localized string SingleWaitingMessage;
var localized string gamegoal;
var float LastTauntTime;
var NavigationPoint LastStartSpot;
var() config int MaxCommanders;
var int NumCommanders;
var bool bTutorialGame;
var int NumBots;
var int RemainingBots;
var int LastTaunt[4];
var() globalconfig int InitialBots;
var ChallengeBotInfo BotConfig;
var localized string NoNameChange;
var localized string OvertimeMessage;
var Class<ChallengeBotInfo> BotConfigType;
var float PlayerRating;
var float AvgOpponentRating;
var int NumOpp;
var int WinCount;
var int LoseCount;
var PlayerPawn RatedPlayer;
var int IDnum;
var RatedMatchInfo RatedMatchConfig;
var float EndTime;
var int LadderTypeIndex;
var LadderInventory RatedGameLadderObj;
var string NextURL;

function bool SuccessfulGame ()
{
}

function bool ShouldRespawn (Actor Other)
{
}

function float PlaySpawnEffect (Inventory Inv)
{
}

function PlayTeleportEffect (Actor Incoming, bool bOut, bool bSound)
{
}

function RegisterDamageMutator (Mutator M)
{
}

function RegisterMessageMutator (Mutator M)
{
}

function PostBeginPlay ()
{
}

function CheckReady ()
{
}

function SetGameSpeed (float t)
{
}

event InitGame (string Options, out string Error)
{
}

function InitRatedGame (LadderInventory LadderObj, PlayerPawn LadderPlayer)
{
}

function AcceptInventory (Pawn PlayerPawn)
{
}

function PlayWinMessage (PlayerPawn Player, bool bWinner)
{
}

function NotifySpree (Pawn Other, int Num)
{
}

function EndSpree (Pawn Killer, Pawn Other)
{
}

function ScoreKill (Pawn Killer, Pawn Other)
{
}

function Killed (Pawn Killer, Pawn Other, name DamageType)
{
}

event PostLogin (PlayerPawn NewPlayer)
{
}

function int ReduceDamage (int Damage, name DamageType, Pawn injured, Pawn instigatedBy)
{
}

function StartMatch ()
{
}

function Timer ()
{
}

function bool TooManyBots ()
{
}

function bool RestartPlayer (Pawn aPlayer)
{
}

function SendStartMessage (PlayerPawn P)
{
}

function Bot SpawnBot (out NavigationPoint StartSpot)
{
}

function Bot SpawnRatedBot (out NavigationPoint StartSpot)
{
}

function bool ForceAddBot ()
{
}

function bool AddBot ()
{
}

function ModifyBehaviour (Bot NewBot)
{
}

function PlayStartUpMessage (PlayerPawn NewPlayer)
{
}

function float PlayerJumpZScaling ()
{
}

function GiveWeapon (Pawn PlayerPawn, string aClassName)
{
}

function byte AssessBotAttitude (Bot aBot, Pawn Other)
{
}

function float GameThreatAdd (Bot aBot, Pawn Other)
{
}

function PickAmbushSpotFor (Bot aBot)
{
}

function RateVs (Pawn Other, Pawn Killer)
{
}

function Skip ()
{
}

function SkipAll ()
{
}

function bool CanSpectate (Pawn Viewer, Actor ViewTarget)
{
}

function ChangeName (Pawn Other, string S, bool bNameChange)
{
}

function NavigationPoint FindPlayerStart (Pawn Player, optional byte InTeam, optional string incomingName)
{
}

function Logout (Pawn Exiting)
{
}

function bool NeedPlayers ()
{
}

function RestartGame ()
{
}

function bool AllowsBroadcast (Actor broadcaster, int Len)
{
}

function LogGameParameters (StatLog StatLog)
{
}

function string GetRules ()
{
}

function InitGameReplicationInfo ()
{
}

function bool CheckThisTranslocator (Bot aBot, TranslocatorTarget t)
{
}

function bool OneOnOne ()
{
}

function float SpawnWait (Bot B)
{
}

function bool NeverStakeOut (Bot Other)
{
}
