//------------------------------------------------------------------------------
// PROJECT : Tactical Ops ServerAdmin Tool
// FILE    : TOST_Engine.uc
// VERSION : 1.0
// INFO    : Link to the Internal Log & Bridge between Server and Mutator
// AUTHOR  : Xian
//------------------------------------------------------------------------------
// CHANGES :
// v1.0     + Initial version
//------------------------------------------------------------------------------

class TOST_Engine expands TOST_Core config (TOST_Server);

// =============================================================================
// Configuration

var () config bool bUseTOSTLog;                                                 // Should the game be logged ?
var () config bool bInformSpectators;                                           // Can Spectators see Log Messages ?
var () config bool bUseReporter;                                                // Will TOST load a Status Reporter ?

var () config struct StructM
{
   var string Module;
   var string Flag;
} Modules[15];                                                                  // Setup of Server Modules

var string ServerSide[15];                                                      // Server Side Module List

// =============================================================================
// Attachments

var s_SWATGame Game;                                                            // Pointer to the Game
var TOST_InternalLog InternalLog;                                               // Pointer to the Internal Log

var byte LastGamePeriod;                                                        // Pointer to the old Game Period

// =============================================================================
// Module & Player Links

var struct StructPL
{
   var s_Player Player;                                                         // Pointer to the Player
   var bool bLoggedIn;                                                          // Is the Player Logged in ?
   var TOST_ClientModule ClientModule;                                          // Pointer to each Player
} PlayerList[32];                                                               // Pointer to the Player List

var TOST_ServerModule ServerModule;                                             // Base Server Module Chain

var int ModuleCount;                                                            // Installed Server Modules

// =============================================================================
// Initialization

function Initialize ()
{
   if (Game == None)
      Game = s_SWATGame(Level.Game);                                            // Assign Game Pointer

   if (Game == None)
      return;                                                                   // Stop if Game is not found

   AttachServerModules();                                                       // Attach the Server Modules

   if ((InternalLog == None) && bUseTOSTLog)
   {
      InternalLog = Game.Spawn(Class 'TOST_InternalLog', Game);                 // Add Internal  Log

      if (InternalLog != None)
      {
         InternalLog.StartLog();                                                // Initialize Internal Log
         InternalLog.Engine = Self;                                             // Assign Pointer
      }
   }

   LastGamePeriod = GetGamePeriod();
}

// =============================================================================
// Engine Specific Functions

// Called every frame
function Tick (float Ticks)
{
   local int i;

   for (i = 0; i < 32; ++ i)
   {
      if ((PlayerList[i].Player != None) && (PlayerList[i].Player.GetPlayerNetworkAddress() != ""))
      {
         if (!PlayerList[i].bLoggedIn)
            LoginPlayer(PlayerList[i].Player);
      }
   }

   if (LastGamePeriod != GetGamePeriod())
   {
      LastGamePeriod = GetGamePeriod();

      if (ServerModule != None)
         ServerModule.NotifyEvent_PeriodChanged();
   }
}

// Called after being destroyed
function Destroyed ()
{
   local int i;

   Super.Destroyed();                                                           // Call Super

   SaveConfig();                                                                // Save current options

   // Remove attachments

   if (InternalLog != None)                                                     // Disable Internal Log
   {
      InternalLog.StopLog();
      InternalLog.Destroy();
      InternalLog = None;
   }

   // Remove Modules

   if (ServerModule != None)                                                    // Remove Server Modules
   {
      ServerModule.Destroy();
      ServerModule = None;
   }

   for (i = 0; i < 32; ++ i)                                                    // Remove Client Modules
   {
      if (PlayerList[i].ClientModule != None)
      {
         PlayerList[i].ClientModule.Destroy();
         PlayerList[i].ClientModule = None;
      }
   }
}

// =============================================================================
// TOST Engine Functions

function LoginPlayer (s_Player Player)
{
   local int ID;

   ID = GetPlayerIndex(Player);

   if (ID != -1)
      PlayerList[ID].bLoggedIn = True;

   Player.PlayerReplicationInfo.OldName = Player.GetHumanName();

   if (!bUseReporter)
      LogEvent(Player.GetHumanName() @ "has logged in:" @ ResolveHost(Player.GetPlayerNetworkAddress(),0),'Connect',Self);

   if (ServerModule != None)
      ServerModule.NotifyPlayer_Login(Player);
}

function LogoutPlayer (s_Player Player)
{
   local int ID;

	if (Player==None) return;

   ID = GetPlayerIndex(Player);

   if (ID == -1)
      return;

   PlayerList[ID].Player = None;
   PlayerList[ID].bLoggedIn = False;
   PlayerList[ID].ClientModule.Destroy();
   PlayerList[ID].ClientModule = None;

   if (!bUseReporter)
      LogEvent(Player.GetHumanName() @ "has left the game -" @ Level.TimeSeconds,'Disconnect',Self);
}

function AddPlayer (s_Player Player)
{
   local int PlayerID;
   local int Index;

   PlayerID = GetPlayerIndex(Player);

   if (PlayerID == -1)
   {
      Index = 0;
      while ((Index < 32) && (PlayerList[Index].Player != None))
         ++ Index;

      PlayerList[Index].Player = Player;
   }

   if (!bUseReporter)
      LogEvent(Player.GetHumanName() @ "has joined the game -" @ Level.TimeSeconds,'Connect',Self);
}

// =============================================================================
// Helpers

// Returns current Game Period
function int GetGamePeriod ()
{
   if (Game == None)
      return -1;                                                                // Error - Game is not present

   switch Game.GamePeriod                                                       // Else, return 0, 1 or 2
   {
      case GP_PreRound : return 0; break;
      case GP_RoundPlaying : return 1; break;
      case GP_PostRound : return 2; break;
   }
}

// Get Player by ID
function s_Player GetPlayerByID (int PlayerID)
{
   local int Index;

   if ((Game == None) || (PlayerID > Game.CurrentID))
       return None;

   for (Index = 0; Index < 32; ++ Index)
      if (PlayerList[Index].Player != None)
         if ((PlayerList[Index].Player.PlayerReplicationInfo != None) && (PlayerList[Index].Player.PlayerReplicationInfo.PlayerID == PlayerID))
            return PlayerList[Index].Player;

   return None;
}

// Get Player by Index
function s_Player GetPlayerByIndex (int Index)
{
   return PlayerList[Index].Player;
}

// Get Index by Player
function int GetPlayerIndex (s_Player Player)
{
   local int Index;

   if (Player == None)
      return -1;

   for (Index = 0; Index < 32; ++ Index)
      if (PlayerList[Index].Player != None)
        if (PlayerList[Index].Player == Player)
           return Index;

   return -1;
}

// Set Module
function SetClientModuleByIndex (TOST_ClientModule Module, int ID)
{
   if ((ID == -1) || (Module == None))
      return;

   if (PlayerList[ID].ClientModule == None)
      PlayerList[ID].ClientModule = Module;
   else
   {
      if (PlayerList[ID].ClientModule.Class != Module.Class)
         PlayerList[ID].ClientModule.SetModule(Module);
   }
}

// Get Module By Index
function TOST_ClientModule GetClientModuleByIndex (int ID)
{
   if (ID != -1)
      return PlayerList[ID].ClientModule;

   return None;
}

// Get Module By Player
function TOST_ClientModule GetClientModuleByPlayer (s_Player Player)
{
   local int ID;

   ID = GetPlayerIndex(Player);

   if (ID != -1)
      return PlayerList[ID].ClientModule;

   return None;
}

// Get Module By Class
function TOST_ClientModule GetClientModuleByClass (s_Player Player, coerce string ModuleClass)
{
   local int ID;
   local TOST_ClientModule Module;
   local bool bFound;

   ID = GetPlayerIndex(Player);

   if (ID != -1)
   {
      Module = PlayerList[ID].ClientModule;

      while ((Module != None) && !bFound)
      {
         if ((string(Module.Class)) ~= ModuleClass)
         {
            bFound = True;
            return Module;
         }

         Module = Module.NextModule;
      }
   }

   return None;
}

// =============================================================================
// Module Handling

// Attaching Server Modules
function AttachServerModules ()
{
   local int i;
   local Class <TOST_ServerModule> ModuleClass;
   local TOST_ServerModule Module;

   for (i = 0; i < 15; ++ i)
   {
      ModuleClass = None;                                                       // Resetting Class
      Module = None;                                                            // Resetting Module

      // Only load Modules with the "Auto Load" Flag
      if ((Modules[i].Module != "") && (Modules[i].Flag ~= "Auto Load"))
      {
          // Load Class
          ModuleClass = Class <TOST_ServerModule> (DynamicLoadObject(Modules[i].Module, Class 'Class'));
          // Spawn Module
          Module = Spawn (ModuleClass, Self);

          if (Module != None)
          {
             ++ ModuleCount;                                                    // Increase Count
             Module.Engine = Self;                                              // Assign Engine

             // Add Module to the Chain
             if (ServerModule != None)
                ServerModule.AddNextModule(Module);
             else
             {
                ServerModule = Module;
                ServerModule.PreInitModule();                                   // PreInit call on the Server Module
             }
          }
          else                                                                  // if Error occurs, log it
             LogEvent("Failed to attach Server Module -" @ Modules[i].Module, 'Error', Self);
      }
   }
}

// Returns specific Server Module, based on its ID
function TOST_ServerModule GetModuleByID (string Module)
{
   local TOST_ServerModule SrvModule;

   SrvModule = ServerModule;

   while (SrvModule != None)
   {
      if ((SrvModule.ID != "") && (SrvModule.ID ~= Module))
         return SrvModule;

      SrvModule = ServerModule.NextModule;
   }

   return None;
}

// Returns Class or Flag of a Module
function string GetModulePropertyByIndex (int Index, string Property)
{
   if (Modules[Index].Module != "")
   {
      if (Property ~= "Class")
         return Modules[Index].Module;

      if (Property ~= "Flag")
         return Modules[Index].Flag;
   }

   return "None";
}

// =============================================================================
// Logging

// Logs a specific Event, Entry or Message
function LogEvent (coerce string Event, name Type, Actor Sender)
{
   local Pawn Pawn;
   local string ID;
   local string Debug;

   if (Event == "")
      return;                                                                   // Exclude empty strings

   if (Sender != None)                                                          // Find ID
      ID = Sender.GetHumanName();

   if (ServerModule != None)
      ServerModule.Notify_Logging(Event,Type,Sender);                           // Server Modules can intercept logs

   if (Type == '')
      Debug = (ID @ Event);
   else
      Debug = (ID @ "[" $ Type $ "]" @ Event);

   if (bInformSpectators)                                                       // If allowed, Spectators or
      for (Pawn = Level.PawnList; Pawn != None; Pawn = Pawn.NextPawn)           // Messaging Spectators will
         if (Pawn.IsA('Spectator'))                                             // recieve the Log entries,
            Pawn.ClientMessage(Debug, 'TOST');                                  // not just the Messages

   if (InternalLog != None)
      InternalLog.LogEventString(Debug);                                        // But if bUseTOSTLog, also log it

   Log(Debug,'TOST');                                                           // Log it on WebAdmin and Server Log
}

// =============================================================================
// Message Handling

// Sends a Private Message to a Player
function SendMessage (s_Player Player, byte Type, coerce string Event, optional bool bConsole)
{
   local int ID;

   ID = GetPlayerIndex(Player);

   if (ID == -1)
      return;

   if (bConsole && (PlayerList[ID].Player.Player.Console != None))
      PlayerList[ID].Player.Player.Console.AddString(Event);

   switch Type
   {
      case 0  :
         if (PlayerList[ID].ClientModule != None)
            PlayerList[ID].ClientModule.SendMessage(Event);
         break;                                                                 // Module Event Handling
      case 1  :
         if (PlayerList[ID].Player != None)
            PlayerList[ID].Player.ClientMessage(Event,'TOST');
         break;                                                                 // Player Event Handling
      default : break;                                                          // Console Message Handling
   }
}

// Exclude a Player from a Message Broadcast
function ExcludePlayer (s_Player Player, byte Type, coerce string Event, optional bool bConsole)
{
   local int Index;
   local int ID;

   ID = GetPlayerIndex(Player);

   for (Index = 0; Index < 32; ++ Index)
      if (Index != ID)
         SendMessage(PlayerList[Index].Player,Type,Event,bConsole);
}

// Broadcasts a Message
function BroadcastEvent (byte Type, byte SubType, coerce string Event, Actor Sender, optional s_Player Player, optional bool bConsole)
{
   local string Message;
   local string ID;

   if (Event == "")
      return;

   if (Sender != None)
   {
      ID = Sender.GetHumanName();

      if (InStr(ID,Chr(58)) == -1)
         ID = (ID $ Chr(58));
   }

   if (ID != "")
      Message = (ID @ Event);
   else
      Message = Event;

   switch Type
   {
      case 0 : SendMessage(Player,SubType,Message,bConsole); break;             // Send a Message to a Player
      case 1 : ExcludePlayer(Player,SubType,Message,bConsole); break;           // Send a Message to the Rest
      case 2 : BroadcastMessage(Message,bConsole,'TOST'); break;                // Send a Message to everyone
   }
}

function BroadcastLocalizedEvent (Class <LocalMessage> Message, optional int Switch, optional PlayerReplicationInfo PRI_1, optional PlayerReplicationInfo PRI_2, optional Object Object)
{
   local s_Player PlayerList;

   foreach AllActors (Class 's_Player', PlayerList)
      if (PlayerList != None)
         PlayerList.ReceiveLocalizedMessage(Message,Switch,PRI_1,PRI_2,Object);
}

// Sends a Function ID, executed Server Side
function ExecuteFunction (int Function, Actor Sender, optional coerce string Text, optional string sResult, optional int iResult, optional float fResult, optional bool bResult, optional byte eResult)
{
   if (ServerModule != None)
      ServerModule.ExecuteFunction(Function,Sender,Text,sResult,iResult,fResult,bResult,eResult);
}

function RemovePlayer (s_Player Player, byte Action, string Reason)
{
   local string Result;
   local string Message;
   local int ID;

   ID = GetPlayerIndex(Player);

   if ((Game == None) || (Player == None) || (Reason == "") || (ID == -1))
      return;

   switch Action
   {
      case 0  :
                Game.Kick(Player);
                Result = " been kicked from the server";
                break;
      case 1  :
                Game.KickBan(Player, Reason);
                Result = " been kick banned from the server";
                break;
      case 2  :
                Game.TempKickBan(Player, Reason);
                Result = " been temp. banned from the server";
                break;
      case 4 :
                Result = "";
                break;
      case 5 :
                Result = " been removed from the server";
                Player.Destroy();
                break;
      case 6 :
                Result = "";
                Player.Destroy();
                break;

      case 7 :
                Game.TempKickBan(Player, "TOST");
                Result = "";
                break;

      default : break;
   }

   ExecuteFunction(50,None,,,Player.PlayerReplicationInfo.PlayerID);

   if (Action < 6)
   {
      Message = ("You have" $ Result @ Reason);
      BroadcastEvent(0,1,Message,Self,Player,True);
      Message = (Player.GetHumanName() @ "has" $ Result @ Reason);
      BroadcastEvent(1,1,Message,Self,Player,True);

      if (Action == 5)
         LogEvent(Message, 'Warning', Self);
   }
}

// =============================================================================
// Server Side Module Handling

function int GetModuleIndex (string Package)
{
   local int i;
   local int j;

   j = -1;

   for (i = 0; i < 15; ++ i)
   {
      if (ServerSide[i] ~= Package)
      {
         j = i;
         break;
      }
   }

   return j;
}

function AddServerSide (string Package)
{
   local int i;
   local int j;

   if (Package == "")
      return;

   j = GetModuleIndex(Package);
   i = -1;

   if (j != -1)
      return;

   for (i = 0; i < 15; ++ i)
   {
      if (ServerSide[i] == "")
      {
         j = i;
         break;
      }
   }

   if (j != -1)
      ServerSide[j] = Package;
   else
      LogEvent("ServerSide Package List is full; ignoring" @ Package $ ".u",'Error',Self);
}

// =============================================================================
// Default Properties

defaultproperties
{
   bUseTOSTLog=True
   bInformSpectators=False
   bUseReporter=True

   ActorID="TOST Engine:"
}
