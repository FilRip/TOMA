//------------------------------------------------------------------------------
// PROJECT : Tactical Ops ServerAdmin Tool
// FILE    : TOST_Reporter.uc
// VERSION : 1.0
// INFO    : Logs events such as Player Connects, Disconnects etc.
// AUTHOR  : Xian
//------------------------------------------------------------------------------
// CHANGES :
// v1.0     + Initial version
//------------------------------------------------------------------------------

class TOST_Reporter expands TOST_Core;

// =============================================================================
// Helpers

var TOST_Engine Engine;                                                         // Pointer to the Engine
var string TimeStamp;
var float UpdateTick;

// =============================================================================
// Engine Specific Functions

// Called every frame
function Tick (float Ticks)
{
   local float RelativeTime;
   local string RelativePart;
   local string TickPart;

   if (UpdateTick > 120)
      UpdateTick = 0;

   UpdateTick += Ticks;
   RelativeTime = Level.TimeSeconds;

   RelativePart = (Left(RelativeTime,(InStr(RelativeTime,"."))));
   TickPart = (Left(UpdateTick,(InStr(UpdateTick,"."))));

   TimeStamp = (RelativePart $ "." $ TickPart);
}

// =============================================================================
// TOST Engine Functions

function LogConnect (TOST_Client Module)
{
   local string OS;
   local string Version;
   local string IP;
   local string Name;

   if (Module == None)
      return;                                                                   // Ignore "bad" or missing Modules

   OS = Module.OperatingSystem;
   Version = Module.EngineVersion;
   IP = Module.IP;
   Name = Module.Player.GetHumanName();

   LogHeader ("------- PLAYER CONNECTED -------",'Connect');
   LogBody("* Player Name:" @ Name,'Connect');
   LogBody("* Player IP:" @ IP,'Connect');
   LogBody("* Operating System:" @ OS,'Connect');
   LogBody("* Game Engine Version:" @ Version,'Connect');
   LogFooter('Connect');
}

function LogDisconnect (TOST_Client Module)
{
   local string OS;
   local string Version;
   local string IP;
   local string Name;

   if (Module == None)
      return;                                                                   // Ignore "bad" or missing Modules

   OS = Module.OperatingSystem;
   Version = Module.EngineVersion;
   IP = Module.IP;
   Name = Module.Player.GetHumanName();

   LogHeader ("----- PLAYER  DISCONNECTED -----",'Connect');
   LogBody("* Player Name:" @ Name,'Connect');
   LogBody("* Player IP:" @ IP,'Connect');
   LogBody("* Operating System:" @ OS,'Connect');
   LogBody("* Game Engine Version:" @ Version,'Connect');
   LogFooter('Connect');
}

// =============================================================================
// Logging

function LogHeader (coerce string Header, name Event)
{
   Engine.LogEvent("--------------------------------",Event,Self);
   Engine.LogEvent(Header,Event,Self);
   Engine.LogEvent("--------------------------------",Event,Self);
}

function LogBody (coerce string Entry, name Event)
{
   Engine.LogEvent(Entry,Event,Self);
}

function LogFooter (name Event)
{
   Engine.LogEvent("* TimeStamp:" @ TimeStamp,Event,Self);
   Engine.LogEvent("--------------------------------",Event,Self);
}

// =============================================================================
// Default Properties

defaultproperties
{
   ActorID="TOST Status Reporter:"
}
