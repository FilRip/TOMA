//------------------------------------------------------------------------------
// PROJECT : Tactical Ops ServerAdmin Tool
// FILE    : TOST_CommandList.uc
// VERSION : 1.0
// INFO    : It holds the Console Commands and sends them to the server
// AUTHOR  : Xian
//------------------------------------------------------------------------------
// CHANGES :
// v1.0     + Initial version
//------------------------------------------------------------------------------

class TOST_CommandList expands Inventory;

// =============================================================================
// Command Info: Specific Console Command and its explanation

var struct StructCL
{
   var string Command;                                                          // Specific Command: ex. Kick
   var string Help;                                                             // Command Help
} CommandList[50];                                                              // Pointer to the CommandList

var TOST_ServerCommandModule ServerLink;                                        // Pointer to the Server Execution
var TOST_ClientCommandModule ClientLink;                                        // Pointer to the Server Execution
var TOST_ClientModule Module;                                                   // Pointer to the Client Module
var s_Player Player;                                                            // Pointer to the Player Owner
var TO_Console Console;                                                         // Pointer to the Console

// =============================================================================
// Helpers

var string ActorID;

// =============================================================================
// Replication Statements

replication
{
   // Client -> Server
   reliable if (ROLE < ROLE_Authority)
      ReceiveCommand;
   // Server -> Client
   reliable if (ROLE == ROLE_Authority)
      ClientInit;
}

// =============================================================================
// Initialization

// Init Module
function ServerInit (coerce string CommandClass)
{
   ClientInit(Player,CommandClass);                                             // Send relevant Client data
}

// Add a Player Pointer ClientSide
simulated function ClientInit (s_Player Pawn, coerce string CommandClass)
{
   local Class <TOST_ClientCommandModule> ModuleClass;
   local TOST_ClientCommandModule cModule;

   if (ROLE == ROLE_Authority)
      return;

   if (Pawn == None)
      return;

   Player = Pawn;                                                               // Assign Player Owner Client Side

   if ((Pawn.Player != None) && (Pawn.Player.Console != None))
      Console = TO_Console(Pawn.Player.Console);                                // Assign Player Console

   if ((CommandClass == "") || (ClientLink != None))
      return;                                                                   // Ignore missing Command Modules

   // Load Class
   ModuleClass = Class <TOST_ClientCommandModule> (DynamicLoadObject(CommandClass, Class 'Class'));
   // Spawn Module
   cModule = Spawn (ModuleClass, Self);

   // Assign Client Side Data
   if (cModule != None)
      ClientLink = cModule;
}

// =============================================================================
// Console Command Execution

// Sends all specific information to the Link
function ReceiveCommand (int ConsoleCommand, optional string sResult, optional string sValue, optional bool bResult, optional int iValue, optional float fValue, optional byte bValue, optional Actor Actor)
{
   ServerLink.ExecuteCommand(ConsoleCommand,Player,sResult,sValue,bResult,iValue,fValue,bValue,Actor);
}

// Called by the Client, sent to the Server; defined in subclass
simulated function SendCommand (int ConsoleCommand, optional bool bServerSide, optional string sResult, optional string sValue, optional bool bResult, optional int iValue, optional float fValue, optional byte bValue, optional Actor Actor)
{
   if (bServerSide)
      ReceiveCommand(ConsoleCommand,sResult,sValue,bResult,iValue,fValue,bValue,Actor);
   else
      ClientLink.ExecuteCommand(ConsoleCommand,Player,sResult,sValue,bResult,iValue,fValue,bValue,Actor);
}

// =============================================================================
// Console Commands

exec simulated function Explain (coerce string Command)
{
   ExplainCommand(Command);
}

// =============================================================================
// Helpers

// sends Command Specific Information to the Client: ex. "Kick = removes a player from the server"
simulated function ExplainCommand (coerce string ConsoleCommand)
{
   local int Index;

   Index = GetCommandIndex(ConsoleCommand);

   Player.ClientMessage(ActorID @ CommandList[Index].Command @ "-" @ CommandList[Index].Help,'TOST');
}

// Returns Command Index
simulated function int GetCommandIndex (coerce string ConsoleCommand)
{
   local int i, j;

   j = -1;

   for (i = 0; i < 50; ++ i)
   {
      if ((CommandList[i].Command != "") && (CommandList[i].Command ~= ConsoleCommand))
      {
         j = i;
         break;
      }
   }

   return j;
}

// =============================================================================
// Engine Specific Functions

function String GetHumanName()
{
	return ActorID;
}

// =============================================================================
// Default Properties

defaultproperties
{
   ActorID="Unknown TOST Command Module:"
}
