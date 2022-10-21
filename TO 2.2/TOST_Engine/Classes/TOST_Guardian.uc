//------------------------------------------------------------------------------
// PROJECT : Tactical Ops ServerAdmin Tool
// FILE    : TOST_Guardian.uc
// VERSION : 1.0
// INFO    : Handles execution of Server Console Commands
// AUTHOR  : Xian
//------------------------------------------------------------------------------
// CHANGES :
// v1.0     + Initial version
//------------------------------------------------------------------------------

class TOST_Guardian expands TOST_Core config (TOST_Server);

// =============================================================================
// Configuration

var () config bool bDisableGuardian;                                            // Whether or not to disable TOST
var () config int AdvertiseGuardian;                                            // Whether or not to Advertise TOST

// =============================================================================
// Attachments

var s_SWATGame Game;                                                            // Pointer to the Game
var TOST_Mutator Internal;                                                      // Pointer to the Mutator

// =============================================================================
// Engine Specific Functions

// Called after match begins
function PostBeginPlay ()
{
   Super.PostBeginplay();                                                       // Call Super

   if (Game == None)
      Game = s_SWATGame(Level.Game);                                            // Assign Game Pointer

   Initialize();                                                                // Init Advertising

   Log(ActorID @ "Internal Actor added successfully...", 'TOST');

   if (bDisableGuardian)                                                        // Check to see if TOST is disabled
   {
      Log(ActorID @ "TOST has been disabled...", 'TOST');
      Destroy();
      return;
   }

   foreach AllActors (Class 'TOST_Mutator', Internal)                           // And if it is already added
   {
      if (Internal != None)
      {
         Internal.Engine.LogEvent("Internal Mutator already added...",'Error',Self);
         return;
      }
   }

   Internal = Spawn (Class 'TOST_Mutator');                                     // Otherwise, add it

   if ((Internal == None) || (Game == None))
      return;

   Game.BaseMutator.AddMutator(Internal);                                       // And add it as a Mutator
   Internal.Main = Self;
   Internal.Initialize();                                                       // Init Mutator
   Internal.Engine.LogEvent("Internal Mutator added successfully...",'Register',Self);
}

// Called after being destroyed
function Destroyed ()
{
   SaveConfig();                                                                // Save current options

   Super.Destroyed();                                                           // Call Super
}

// =============================================================================
// Initialization

function Initialize ()
{
   local string Server;
   local string TestServer;
   local int SplitPoint;

   if (Game == None)
      return;

   Server = Game.GameReplicationInfo.ServerName;
   TestServer = (Caps(Server));
   SplitPoint = InStr(TestServer, "TOST");                                      // Check to see if Server already
   if (SplitPoint != -1)                                                        // has TOST in its name, so we don't
      AdvertiseGuardian = -1;                                                   // add another TOST banner

   switch AdvertiseGuardian                                                     // Check Advertising type
   {
      case 0 :
         Log(ActorID @ "TOST Advertising has been disabled by the Admin...", 'TOST');
         break;
      case 1 :
         Server = Server @ "[TOST v1.3]";
         Log(ActorID @ "TOST Advertising has been enabled by the Admin:" @ Server, 'TOST');
         break;
     case 2 :
         Server = "[TOST v1.3]" @ Server;
         Log(ActorID @ "TOST Advertising has been enabled by the Admin:" @ Server, 'TOST');
         break;
     default :
         Log(ActorID @ "No TOST Advertising is required:" @ Server, 'TOST');
         break;
   }

   Game.GameReplicationInfo.ServerName = Server;                                // Add TO advertising

   // Check to see if TO version is in the Server Name
   if ((InStr(Server, "2.2") != -1) || (InStr(Server, "2.2.0") != -1) || (InStr(Server, "2.20") != -1))
      return;

   // If not, add it in front of the Server Name
   Game.GameReplicationInfo.ServerName = "2.2" @ Game.GameReplicationInfo.ServerName;
}

// =============================================================================
// Default Properties

defaultproperties
{
   ActorID="TOST Guardian:"

   bDisableGuardian=False
   AdvertiseGuardian=1
}
