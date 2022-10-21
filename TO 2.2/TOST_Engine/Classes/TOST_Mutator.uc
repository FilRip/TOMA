//------------------------------------------------------------------------------
// PROJECT : Tactical Ops ServerAdmin Tool
// FILE    : TOST_Mutator.uc
// VERSION : 1.0
// INFO    : Handles execution of Server Console Commands
// AUTHOR  : Xian
//------------------------------------------------------------------------------
// CHANGES :
// v1.0     + Initial version
//------------------------------------------------------------------------------

class TOST_Mutator expands Mutator;

// =============================================================================
// Helpers

var string ActorID;

// =============================================================================
// Attachments

var TOST_Guardian Main;
var TOST_LogHook LogHook;
var TOST_Engine Engine;

// =============================================================================
// Init Options

var bool bPreBeginPlay;                                                         // Has PreBeginPlay() been called
var bool bPostBeginPlay;                                                        // Has PostBeginPlay() been called

// =============================================================================
// Engine Specific Functions

function String GetHumanName()
{
	return ActorID;
}

// Called before match begins
function PreBeginPlay ()
{
   if (bPreBeginPlay)
      return;

   bPreBeginPlay = True;

   Super.PreBeginplay();                                                        // Call Super

   if (LogHook == None)
      LogHook = Spawn (Class 'TOST_LogHook', Self);                             // Attach Log Hook

   if (Engine == None)
      Engine = Spawn (Class 'TOST_Engine', Self);                               // Attach Engine
}

// Called after match begins
function PostBeginPlay ()
{
   local TOST_LogSpawnNotify LogSN;                                             // Pointer to the Log Spawn Notify

   if (bPostBeginPlay)
      return;

   bPostBeginPlay = True;

   Super.PostBeginplay();                                                       // Call Super

   if (Engine != None)
   {
      Engine.Initialize();                                                      // Init Engine

      if ((LogHook != None) && (Engine.Game != None))                           // Attach the Log Hook to the Game
      {
         Engine.Game.bWorldLog = False;
         LogHook.Engine = Engine;                                               // Assign Engine
         LogHook.Link = Self;                                                   // Assign Mutator

         // Assign Log Hook to the Game
         if (Engine.Game.bLoggingGame && Engine.Game.bLocalLog)                 // Check to see if the Game
         {                                                                      // is already logging or if it
            LogSN = Spawn (Class 'TOST_LogSpawnNotify', Engine.Game);           // has an existing Local Log.
            LogSN.TOST = Self;                                                  // We use a SpawnNotify to intercept
         }                                                                      // the old Log and add our own,
         else                                                                   // while keeping the old Log
         {
            Engine.Game.bLocalLog = True;                                       // Enable bLocalLog and if
            Engine.Game.LocalLog = LogHook;                                     // there is no default Log
         }                                                                      // we add our own to receive calls

         Engine.LogEvent("Log Hook successfully added...",'Debug',Self);
      }
   }
}

// Called after being destroyed
function Destroyed ()
{
   Super.Destroyed();                                                           // Call Super

   // Remove attachments

   if (LogHook != None)                                                         // Remove Log Hook
   {
      LogHook.Destroy();
      LogHook = None;
   }

   if (Engine != None)                                                          // Remove Engine
   {
      Engine.Destroy();
      Engine = None;
   }

   if (Main != None)                                                            // Remove Guardian
   {
      Main.Destroyed();
      Main = None;
   }
}

// =============================================================================
// Initialization

function Initialize ()
{
   local int i;
   local string ID;
   local string Version;
   local string Build;
   local string SModule;
   local string bServerSide;
   local string GameVersion;
   local string EngineVersion;
   local string ServerName;
   local string ModuleClass;
   local TOST_ServerModule Module;
   local TOST_Core TOST, TOSTCR;

   if ((Engine == None) || (Engine.Game == None))
      return;

   foreach AllActors (Class 'TOST_Core', TOST)
   {
      if ((TOST != None) && TOST.IsA('TOST_CheatReporter'))
      {
         TOSTCR = TOST;
         break;
      }
   }

   SetTimer(1, True);

   ServerName = Engine.Game.GameReplicationInfo.ServerName;

   Engine.Game.RegisterDamageMutator(Self);
   Engine.Game.RegisterMessageMutator(self);

   GameVersion = Class 'TOSystem.TO_MenuBar'.default.TOVersionText;
   EngineVersion = Level.EngineVersion;

   Engine.LogEvent("---------------------------------------",'Init',Self);
   Engine.LogEvent("------------ TACTICAL  OPS ------------",'Init',Self);
   Engine.LogEvent("----- Version:" @ GameVersion @ "-----",'Init',Self);
   Engine.LogEvent("--------- Engine Version:" @ EngineVersion @ "---------",'Init',Self);
   Engine.LogEvent("---- Current Map:" @ Level.Title @ "----",'Init',Self);
   Engine.LogEvent("---------------------------------------",'Init',Self);
   Engine.LogEvent("* Server Name:" @ ServerName,'Init',Self);
   Engine.LogEvent("---------------------------------------",'Init',Self);
   Engine.LogEvent("- TACTICAL OPS SERVER-ADMIN TOOL v1.3 -",'Init',Self);
   Engine.LogEvent("--------- Version: v1.00 BETA ---------",'Init',Self);
   Engine.LogEvent("---------------------------------------",'Init',Self);

   if (Engine.ModuleCount != 0)
   {
      if (Engine.ModuleCount != 1)
         SModule = "Modules";
      else
         SModule = " Module";

      Engine.LogEvent("- Running TOST with" @ Engine.ModuleCount @ "Server" @ SModule @ "-",'Init',Self);
      Engine.LogEvent("---------------------------------------",'Init',Self);
   }

   Engine.LogEvent("------ INSTALLED SYSTEM MODULES: ------",'Init',Self);
   Engine.LogEvent("* Slot: 1 - ID: Internal Mutator",'Init',Self);
   Engine.LogEvent("* Slot: 2 - ID: Internal Engine",'Init',Self);
   Engine.LogEvent("* Slot: 3 - ID: System Log Hook",'Init',Self);
   Engine.LogEvent("* Slot: 4 - ID: HUD Module",'Init',Self);
   Engine.LogEvent("* Slot: 5 - ID: HUD Mutator Link",'Init',Self);

   if (Engine.bUseReporter)
   {
      Engine.LogEvent("* Slot: 6 - ID: Status Reporter",'Init',Self);

      if (Engine.bUseTOSTLog)
      {
         Engine.LogEvent("* Slot: 7 - ID: TOST Stat Log",'Init',Self);

         if (TOSTCR != None)
            Engine.LogEvent("* Slot: 8 - ID: Cheat Reporter",'Init',Self);
      }
      else
      {
         if (TOSTCR != None)
            Engine.LogEvent("* Slot: 7 - ID: Cheat Reporter",'Init',Self);
      }
   }
   else
   {
      if (Engine.bUseTOSTLog)
         Engine.LogEvent("* Slot: 6 - ID: TOST Stat Log",'Init',Self);
   }

   Engine.LogEvent("---------------------------------------",'Init',Self);
   Engine.LogEvent("------ INSTALLED SERVER MODULES: ------",'Init',Self);

   Module = Engine.ServerModule;

   if (Module == None)
   {
      Engine.LogEvent("* No Server Modules Installed...",'Init',Self);
      Engine.LogEvent("---------------------------------------",'Init',Self);
      return;
   }

   while (Module != None)
   {
      ModuleClass = string(Module.Class);
      ID = "Unknown:" @ ModuleClass;
      Version = "Unknown";
      Build = "Unknown";
      bServerSide = "";

      if (Module.ID != "Unknown TOST Server Module")
         ID = Module.ID;
      if (Module.Version != "Unknown")
         Version = Module.Version;
      if (Module.Build != "Unknown")
         Build = Module.Build;
      if (Module.bServerSide)
      {
         bServerSide = "(Server Side Only)";
         Engine.AddServerSide(Left(ModuleClass,InStr(ModuleClass,".")));
      }

      ++ i;
      Engine.LogEvent("* Slot:" @ i @ "- ID:" @ ID @ "- Version:" @ Version @ "(Build:" @ Build $ ")" @ bServerSide,'Init',Self);
      Module = Module.NextModule;
   }

   Engine.LogEvent("---------------------------------------",'Init',Self);

   if (Engine.ServerModule != None)
      Engine.ServerModule.PostInitModule();                                     // PostInit call on the Server Module
}

// =============================================================================
// TOST Engine Functions

function KillPlayer (int KillerID, int VictimID, string KillerWeapon, string VictimWeapon, name DamageType)
{
   if (Engine.ServerModule != None)
      Engine.ServerModule.NotifyEvent_EnemyKill(KillerID,VictimID,KillerWeapon,VictimWeapon,DamageType);
}

function TeamKillPlayer (int KillerID, int VictimID, string KillerWeapon, string VictimWeapon, name DamageType)
{
   if (Engine.ServerModule != None)
      Engine.ServerModule.NotifyEvent_TeamKill(KillerID, VictimID, KillerWeapon, VictimWeapon, DamageType);
}

function SuicidePlayer (Pawn Victim, name DamageType, Pawn Killer)
{
   if (Engine.ServerModule != None)
      Engine.ServerModule.NotifyEvent_Suicide(Victim, DamageType, Killer);
}

function ConnectPlayer (s_Player Player)
{
   Engine.AddPlayer(Player);

   if (Engine.ServerModule != None)
      Engine.ServerModule.NotifyPlayer_Connect(Player);
}

function DisconnectPlayer (s_Player Player)
{
   if (Engine.ServerModule != None)
      Engine.ServerModule.NotifyPlayer_Disconnect(Player);

   Engine.LogoutPlayer(Player);
}

function ChangeTeam (s_Player Player)
{
   if (Engine.ServerModule != None)
      Engine.ServerModule.NotifyPlayer_ChangeTeam(Player);
}

function ChangeName (s_Player Player)
{
   local string OldName;
   local string NewName;

   OldName = Player.PlayerReplicationInfo.OldName;
   NewName = Player.GetHumanName();

   if (Engine.ServerModule != None)
      Engine.ServerModule.NotifyPlayer_ChangeName(Player);

   if (OldName != NewName)
      Player.PlayerReplicationInfo.OldName = NewName;
}

function ChangeMap ()
{
   if (Engine.ServerModule != None)
      Engine.ServerModule.NotifyMap_Change();
}

function QuitMap ()
{
   if (Engine.ServerModule != None)
      Engine.ServerModule.NotifyMap_Quit();
}

function MutatorTakeDamage (out int Damage, Pawn Victim, Pawn Killer, out Vector HitLocation, out Vector Momentum, name DamageType)
{
   if (Engine.ServerModule != None)
      Engine.ServerModule.NotifyEvent_TakeDamage(Damage, Victim, Killer, Momentum, DamageType);

   if (NextMutator != None)
      NextMutator.MutatorTakeDamage(Damage,Victim,Killer,HitLocation,Momentum,DamageType);
}

function ScoreKill (Pawn Killer, Pawn Victim)
{
   if (Engine.ServerModule != None)
      Engine.ServerModule.NotifyEvent_Scoring(Killer, Victim);

   if (NextMutator != None)
      NextMutator.ScoreKill(Killer,Victim);
}

function ModifyPlayer (Pawn Player)
{
   if (Engine.ServerModule != None)
      if (Player.IsA('s_Player'))
         Engine.ServerModule.NotifyPlayer_Modify(s_Player(Player));

   if (NextMutator != None)
      NextMutator.ModifyPlayer(Player);
}

function bool MutatorTeamMessage (Actor S, Pawn R, PlayerReplicationInfo P, coerce string M, name T, optional bool B)
{
   local bool bHandled;

   if (Engine.ServerModule != None)
      bHandled = Engine.ServerModule.NotifyMessage_Team(S,R,P,M,T,B);

   if (bHandled)
      return Super.MutatorTeamMessage(S,R,P,M,T,B);

   return False;
}

function bool MutatorBroadcastMessage (Actor S, Pawn R, out coerce string M, optional bool B, out optional name T)
{
   local bool bHandled;

   if (Engine.ServerModule != None)
      bHandled = Engine.ServerModule.NotifyMessage_Broadcast(S,R,M,B,T);

   if (bHandled)
      return Super.MutatorBroadcastMessage(S,R,M,bHandled,T);

   return False;
}

function bool MutatorBroadcastLocalizedMessage (Actor S, Pawn R, out class <LocalMessage> M, out optional int W, out optional PlayerReplicationInfo P1, out optional PlayerReplicationInfo P2, out optional Object O)
{
   local bool bHandled;

   if (Engine.ServerModule != None)
      bHandled = Engine.ServerModule.NotifyMessage_Localized(S,R,M,W,P1,P2,O);

   if (bHandled)
      return Super.MutatorBroadcastLocalizedMessage(S,R,M,W,P1,P2,O);

   return False;
}

function bool HandleRestartGame ()
{
   local bool bHandled;

   if (Engine.ServerModule != None)
      bHandled = Engine.ServerModule.NotifyMap_Restart ();

   if (!bHandled)
      bHandled = Super.HandleRestartGame();

   return bHandled;
}

function bool HandleEndGame ()
{
   local bool bHandled;

   if (Engine.ServerModule != None)
      bHandled = Engine.ServerModule.NotifyMap_End();

   if (!bHandled)
      bHandled = Super.HandleEndGame();

   return bHandled;
}

function Tick (float Ticks)
{
   if (Engine.ServerModule != None)
      Engine.ServerModule.NotifyEvent_Tick();
}

function Timer ()
{
   if ((Engine.ServerModule != None) && (Engine.ServerModule.TotalSeconds > 0))
   {
      if (Engine.ServerModule.RemainingSeconds > 0)
         Engine.ServerModule.RemainingSeconds -= 1;
      else
      {
         Engine.ServerModule.NotifyEvent_Timer();
         Engine.ServerModule.RemainingSeconds = Engine.ServerModule.TotalSeconds;
      }
   }
}

// =============================================================================
// Default Properties

defaultproperties
{
   ActorID="TOST:"
}
