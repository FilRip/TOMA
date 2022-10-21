//------------------------------------------------------------------------------
// PROJECT : Tactical Ops ServerAdmin Tool
// FILE    : TOST_LogModule.uc
// VERSION : 1.0
// INFO    : Base class of TOST Logs
// AUTHOR  : Xian
//------------------------------------------------------------------------------
// CHANGES :
// v1.0     + Initial version
//------------------------------------------------------------------------------

class TOST_LogModule expands StatLogFile;

// =============================================================================
// Helpers

var string ActorID;
var TOST_Engine Engine;                                                         // Pointer to the Engine

// =============================================================================
// Disable Ping Logging (pings were logged every 30 seconds)

function LogPings ();
function Timer ();

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
   bHidden=True
   ActorID="Unknwon TOST Log Module:"
}
