class TO_DeathMatchPlus extends Botpack.TournamentGameInfo;

var int TimeLimit;
var LadderInventory RatedGameLadderObj;
var int NumBots;
var int RemainingTime;
var int MinPlayers;
var ChallengeBotInfo BotConfig;
var bool bNoviceMode;
var int FragLimit;
var int IDnum;
var bool bRequireReady;
var bool bHardCoreMode;
var bool bMegaSpeed;
var RatedMatchInfo RatedMatchConfig;
var float PlayerRating;
var int RemainingBots;
var bool bTournament;
var PlayerPawn RatedPlayer;
var float AirControl;
var bool bChangeLevels;
var int LadderTypeIndex;
var int CountDown;
var bool bThreePlus;
var bool bNetReady;
var bool bStartMatch;
var int LastTaunt;
var float EndTime;
var float AvgOpponentRating;
var int InitialBots;
var NavigationPoint LastStartSpot;
var int ElapsedTime;
var bool bJumpMatch;
var bool bMultiWeaponStay;
var bool bForceRespawn;
var bool bDontRestart;
var bool bAlreadyChanged;
var bool bFirstBlood;
var bool bUseTranslocator;
var float LastTauntTime;
var int MaxCommanders;
var ChallengeBotInfo BotConfigType;
var int WinCount;
var int LoseCount;
var bool bTutorialGame;
var int NumCommanders;
var bool bRatedTranslocator;
var bool bFixMutatorQuerying;
var int TO_RestartWait;
var bool bAltScoring;
var bool bChallengeMode;
var int NumOpp;
var int StartCount;
var bool bFulfilledSpecial;
var int NetWait;
var bool bAlwaysForceRespawn;

function PostBeginPlay ()
{
}

event InitGame (string Options, out string Error)
{
}

function InitRatedGame (LadderInventory LadderObj, PlayerPawn LadderPlayer)
{
}

event PostLogin (PlayerPawn NewPlayer)
{
}

function int ReduceDamage (int Damage, name DamageType, Pawn injured, Pawn instigatedBy)
{
}

function Timer ()
{
}

function InitGameReplicationInfo ()
{
}

function LogGameParameters (StatLog StatLog)
{
}

function Logout (Pawn Exiting)
{
}

function GiveWeapon (Pawn PlayerPawn, string aClassName)
{
}

function byte AssessBotAttitude (Bot aBot, Pawn Other)
{
}

function PickAmbushSpotFor (Bot aBot)
{
}

function bool CanSpectate (Pawn Viewer, Actor ViewTarget)
{
}

function NavigationPoint FindPlayerStart (Pawn Player, optional byte InTeam, optional string incomingName)
{
}

function PlayStartUpMessage (PlayerPawn NewPlayer)
{
}

function bool AddBot ()
{
}

function string GetRules ()
{
}

function Bot SpawnBot (out NavigationPoint StartSpot)
{
}

function bool RestartPlayer (Pawn aPlayer)
{
}

function Killed (Pawn Killer, Pawn Other, name DamageType)
{
}

function CheckReady ()
{
}

function bool NeverStakeOut (Bot Other)
{
}

function float SpawnWait (Bot B)
{
}

function bool OneOnOne ()
{
}

function bool CheckThisTranslocator (Bot aBot, TranslocatorTarget t)
{
}

function bool AllowsBroadcast (Actor broadcaster, int Len)
{
}

function RestartGame ()
{
}

function bool NeedPlayers ()
{
}

function SkipAll ()
{
}

function Skip ()
{
}

function RateVs (Pawn Other, Pawn Killer)
{
}

function float GameThreatAdd (Bot aBot, Pawn Other)
{
}

function float PlayerJumpZScaling ()
{
}

function ModifyBehaviour (Bot NewBot)
{
}

function bool ForceAddBot ()
{
}

function Bot SpawnRatedBot (out NavigationPoint StartSpot)
{
}

function SendStartMessage (PlayerPawn P)
{
}

function bool TooManyBots ()
{
}

function StartMatch ()
{
}

function ScoreKill (Pawn Killer, Pawn Other)
{
}

function EndSpree (Pawn Killer, Pawn Other)
{
}

function NotifySpree (Pawn Other, int Num)
{
}

function PlayWinMessage (PlayerPawn Player, bool bWinner)
{
}

function AcceptInventory (Pawn PlayerPawn)
{
}

function SetGameSpeed (float t)
{
}

function RegisterMessageMutator (Mutator M)
{
}

function RegisterDamageMutator (Mutator M)
{
}

function PlayTeleportEffect (Actor Incoming, bool bOut, bool bSound)
{
}

function float PlaySpawnEffect (Inventory Inv)
{
}

function bool ShouldRespawn (Actor Other)
{
}

function bool SuccessfulGame ()
{
}


defaultproperties
{
}

