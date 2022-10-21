//------------------------------------------------------------------------------
// PROJECT : Tactical Ops ServerAdmin Tool
// FILE    : TOST_ServerCommandModule.uc
// VERSION : 1.0
// INFO    : Handles execution of Server Console Commands
// AUTHOR  : Xian
//------------------------------------------------------------------------------
// CHANGES :
// v1.0     + Initial version
//------------------------------------------------------------------------------

class TOST_ServerCommandModule expands TOST_Core;

var TOST_Engine Engine;                                                         // Pointer to the Engine

// =============================================================================
// TOST Engine Functions

// Runs the Command on the Server; defined in subclass
function ExecuteCommand (int ConsoleCommand, s_Player Player, optional string sResult, optional string sValue, optional bool bResult, optional int iValue, optional float fValue, optional byte bValue, optional Actor Actor);

// =============================================================================
// Default Properties

defaultproperties
{
   ActorID="Unknown TOST Server Command Module:"
}
