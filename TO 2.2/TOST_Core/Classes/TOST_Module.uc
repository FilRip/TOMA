//------------------------------------------------------------------------------
// PROJECT : Tactical Ops ServerAdmin Tool
// FILE    : TOST_Module.uc
// VERSION : 1.0
// INFO    : Base Class of Server and Client Modules
// AUTHOR  : Xian
//------------------------------------------------------------------------------
// CHANGES :
// v1.0     + Initial version
//------------------------------------------------------------------------------

class TOST_Module expands TOST_Core;

// =============================================================================
// Helpers

var TOST_Engine Engine;                                                         // Pointer to the TOST Internal Engine

// =============================================================================
// Logging

// Log a Debug Message
function DebugLog (coerce string Event, name Type, Actor Sender)
{
   Engine.LogEvent(Event,Type,Sender);
}

// =============================================================================
// Default Properties

defaultproperties
{
   ActorID="Unknown TOST Module:"
}
