//------------------------------------------------------------------------------
// PROJECT : Tactical Ops ServerAdmin Tool
// FILE    : TOST_ClientCommandModule.uc
// VERSION : 1.0
// INFO    : Handles execution of Client Console Commands
// AUTHOR  : Xian
//------------------------------------------------------------------------------
// CHANGES :
// v1.0     + Initial version
//------------------------------------------------------------------------------

class TOST_ClientCommandModule expands TOST_Core;

// =============================================================================
// TOST Engine Functions

// Runs the Command on the Client; defined in subclass
simulated function ExecuteCommand (int ConsoleCommand, s_Player Player, optional string sResult, optional string sValue, optional bool bResult, optional int iValue, optional float fValue, optional byte bValue, optional Actor Actor);

// =============================================================================
// Default Properties

defaultproperties
{
   ActorID="Unknown TOST Client Command Module:"
}
