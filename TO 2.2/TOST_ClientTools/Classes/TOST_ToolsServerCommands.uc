//------------------------------------------------------------------------------
// PROJECT : Tactical Ops ServerAdmin Tool
// FILE    : TOST_ToolsServerCommands.uc
// VERSION : 1.0
// INFO    : Handles execution of Tools Server Console Commands
// AUTHOR  : Xian
//------------------------------------------------------------------------------
// CHANGES :
// v1.0     + Initial version
//------------------------------------------------------------------------------

class TOST_ToolsServerCommands expands TOST_ServerCommandModule;

// =============================================================================
// TOST Engine Functions

// Runs the Command on the Server
function ExecuteCommand (int ConsoleCommand, s_Player Player, optional string sResult, optional string sValue, optional bool bResult, optional int iValue, optional float fValue, optional byte bValue, optional Actor Actor)
{
   switch ConsoleCommand
   {
      case 0 : GetStats(Player); break;
      case 1 : PunishTK(Player); break;
      case 2 : ForgiveTK(Player); break;
   }
}

function ForgiveTK (s_Player Player)
{
   local int ID;

   ID = Engine.GetPlayerIndex(Player);

   if (ID == -1)
      return;

   Engine.ExecuteFunction(53,Player,,,ID);
}

function PunishTK (s_Player Player)
{
   local int ID;

   ID = Engine.GetPlayerIndex(Player);

   if (ID == -1)
      return;

   Engine.ExecuteFunction(54,Player,,,ID);
}

function GetStats (s_Player Player)
{
   local int ID;

   ID = Engine.GetPlayerIndex(Player);

   if (ID == -1)
      return;

   Engine.ExecuteFunction(55,Player,,,ID);
}

// =============================================================================
// Default Properties

defaultproperties
{
   ActorID="TOST Server Tools Commands:"
}
