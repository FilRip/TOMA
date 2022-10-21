//------------------------------------------------------------------------------
// PROJECT : Tactical Ops ServerAdmin Tool
// FILE    : TOST_Client.uc
// VERSION : 1.0
// INFO    : Client Main Piece; Handles Player Information
// AUTHOR  : Xian
//------------------------------------------------------------------------------
// CHANGES :
// v1.0     + Initial version
//------------------------------------------------------------------------------

class TOST_Client expands TOST_ClientModule;

// =============================================================================
// Helpers

var string EngineVersion;                                                       // Pointer to the Client Version
var string OperatingSystem;                                                     // Pointer to the OS of the Player
var string IP;                                                                  // Pointer to the Player IP Address

var TOST_HUDModule HUDModule;                                                   // Pointer to the HUD Module

var bool bInit;                                                                 // Debug: Is the Module initialzied ?

// =============================================================================
// Replication Statements

replication
{
   // Client -> Server
   reliable if (ROLE < ROLE_Authority)
      SetInfo;
}

// =============================================================================
// Initialization

simulated function ClientInit ()
{
   GoToState('AddHUDMutator');
}

// =============================================================================
// TOST Engine Functions

// Get Client Info ClientSide
simulated function GetInfo ()
{
   local string Version;
   local string OS;

   // Find Local Player
   if (Player == None)
      Player = GetLocalPlayer();

   // Find Engine Version and OS
   if (Player != None)
   {
      Version = Player.Level.EngineVersion;                                     // Find Engine Version
      OS = "Linux";                                                             // Default OS = "Linux"

      if (Player.Player != None)
      {
         if (InStr(Caps(Player.Player.Class), "WINDOWSVIEWPORT") != -1)
            OS = "Windows";                                                     // Search for Windows Viewports
         else if (InStr(Caps(Player.Player.Class), "MACVIEWPORT") != -1)
            OS = "Mac";                                                         // Search for Mac Viewports
      }

      SetInfo(OS, Version);
   }
}

// Set Client Info ServerSide
function SetInfo (coerce string OS, coerce string Version)
{
   OperatingSystem = OS;                                                        // Apply OS ServerSide
   EngineVersion = Version;                                                     // Apply Version ServerSide
   IP = ResolveHost(Player.GetPlayerNetworkAddress(),0);                        // Apply IP ServerSide

   Engine.ExecuteFunction(1, Self);
}

// =============================================================================
// HUD Module Handling

simulated state AddHUDMutator
{
   simulated function AddMutator ()
   {
      // Find Local Player
      if (Player == None)
         Player = GetLocalPlayer();

      if (bInit)
         return;

      AttachHUDMutator();
   }

Begin:
   while (True)
   {
      Sleep(0.5);
      AddMutator();
   }
}

simulated function AttachHUDMutator ()
{
   local TOST_HUDMutator HUD;

   if ((Player == None) || (Player.MyHUD == None))
      return;

   HUD = Spawn (Class 'TOST_HUDMutator', Player.MyHUD);

   if (HUD == None)
   {
      ClientDebugLog("Failed to attach TOST HUD Mutator on" @ Player.GetHumanName(),'Error', Self);
      return;
   }

   HUD.Link = Self;
   HUD.Player = Player;
   HUD.HUD = s_HUD(Player.MyHUD);
   HUD.RegisterHUDMutator();
   HUD.RegisterHUDModule("TOST_ClientTools.TOST_StatusHUD", Self);
   HUDModule = HUD.Module;
   GetInfo();
   bInit = True;
}

// =============================================================================
// Engine Specific Functions

// Called after being destroyed
function Destroyed ()
{
   if (ROLE == ROLE_Authority)
      Engine.ExecuteFunction(2, Self);

   Super.Destroyed();                                                           // Call Super
}

// =============================================================================
// Message Handling

simulated function ReceiveMessage (coerce string Message)
{
   HUDModule.AddSimpleMsg(Message);
}

// =============================================================================
// Default Properties

defaultproperties
{
   ActorID="TOST Client:"
}
