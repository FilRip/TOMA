//------------------------------------------------------------------------------
// PROJECT : Tactical Ops ServerAdmin Tool
// FILE    : TOST_ToolsHandler.uc
// VERSION : 1.0
// INFO    : Handles Tools ClientSide
// AUTHOR  : Xian
//------------------------------------------------------------------------------
// CHANGES :
// v1.0     + Initial version
//------------------------------------------------------------------------------

class TOST_ToolsHandler expands TOST_ClientModule;

// =============================================================================
// Default Properties

defaultproperties
{
   ActorID="TOST Tools Handler:"

   Commands="TOST_ClientTools.TOST_ToolsCommands"
   ClientLink="TOST_ClientTools.TOST_ToolsClientCommands"
   ServerLink="TOST_ClientTools.TOST_ToolsServerCommands"
}
