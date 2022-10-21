//------------------------------------------------------------------------------
// PROJECT : Tactical Ops ServerAdmin Tool
// FILE    : TOST_ClientModule.uc
// VERSION : 1.0
// INFO    : Handles Client specific information
// AUTHOR  : Xian
//------------------------------------------------------------------------------
// CHANGES :
// v1.0     + Initial version
//------------------------------------------------------------------------------

class TOST_ClientModule expands TOST_Module;

// =============================================================================
// Internal Configuration

var string Commands;                                                            // Handling the Command List Class
var string ServerLink;                                                          // Handling the Server Command Class
var string ClientLink;                                                          // Handling the Client Command Class

var bool bAttached;                                                             // Debug - is CommandList added ?
var float AlphaTime;                                                            // Debug - Tick Time

// =============================================================================
// Attachments

var s_Player Player;                                                            // Pointer to the Player Owner
var TOST_ClientModule NextModule;                                               // Pointer to the Next Module
var TOST_ClientModule PrevModule;                                               // Pointer to the Prev Module
var TOST_ServerModule Module;                                                   // Pointer to the Server Owner

// =============================================================================
// Replication Statements

replication
{
   // Client -> Server
   reliable if (ROLE < ROLE_Authority)
      ServerDebugLog;
   // Server -> Client
   reliable if (ROLE == ROLE_Authority)
      ReceiveMessage;
}

// =============================================================================
// Engine Specific Functions

// Called every frame
function Tick (float DeltaTime)
{
   if (ROLE == ROLE_Authority)
   {
      if (Commands == "")
         return;

      if (AlphaTime <= (Rand(2) + (FRand() * 2)))
         AlphaTime += DeltaTime;
      else
      {
         AlphaTime = 0;
         bAttached = HasInventoryType(Commands);

         if (!bAttached)
            AttachCommandModule();
      }
   }
}

// Called after being destroyed
simulated function Destroyed ()
{
   local TOST_Core TOST;

   if (ROLE < ROLE_Authority)
   {
      foreach AllActors (Class 'TOST_Core', TOST)
         if (TOST != None)
            TOST.Destroy();
   }

   if (ROLE == ROLE_Authority)
   {
      if (NextModule != None)
         NextModule.Destroy();
   }

   Super.Destroyed();                                                           // Call Super
}

// =============================================================================
// Initialization

simulated function s_Player GetLocalPlayer ()
{
   local s_Player LocalPlayer;

   // Find Local Player
   if (Player == None)
      foreach AllActors(Class 's_Player', LocalPlayer)
         if (LocalPlayer != None)
            break;

   if ((LocalPlayer != None) && (LocalPlayer.Player != None))
      return LocalPlayer;                                               // Check for a valid connection
   else
      return None;
}

simulated function PostNetBeginPlay ()
{
   Super.PostNetBeginPlay();

   if (((Level.NetMode == NM_Client) && (ROLE < ROLE_SimulatedProxy)) || !bNetOwner)
		return;

   ClientInit();
}

simulated function ClientInit ();

function ServerInit ();

// =============================================================================
// Commands Handling

function bool HasInventoryType (coerce string InventoryClass)
{
   local Inventory Inventory;
   local bool bFound;
   local int Count;

   for (Inventory = Player.Inventory; Inventory != None && !bFound; Inventory = Inventory.Inventory)
   {
      if (Inventory.IsA('TOST_CommandList') && ((string(Inventory.Class)) ~= InventoryClass))
         bFound = True;

      if (++ Count > 100)
         break;
   }

   return bFound;
}

function AttachCommandModule ()
{
   local Class <TOST_CommandList> ClientModuleClass;
   local TOST_CommandList ClientModule;
   local Class <TOST_ServerCommandModule> ServerModuleClass;
   local TOST_ServerCommandModule ServerModule;
   local Inventory Inventory;

   if (NextModule != None)
      NextModule.AttachCommandModule();

   if (Commands == "")
      return;                                                                   // Ignore missing Command Modules

   // Load Class
   ClientModuleClass = Class <TOST_CommandList> (DynamicLoadObject(Commands, Class 'Class'));
   // Spawn Module
   ClientModule = Spawn (ClientModuleClass, Self);

   if (ServerLink != "")
   {
      // Load Class
      ServerModuleClass = Class <TOST_ServerCommandModule> (DynamicLoadObject(ServerLink, Class 'Class'));
      // Spawn Module
      ServerModule = Spawn (ServerModuleClass, Self);
   }

   if (ClientModule != None)
   {
      Inventory = Player.FindInventoryType(ClientModuleClass);

      if (Inventory != None)
         return;

      if (ServerModule != None)
      {
         ClientModule.ServerLink = ServerModule;
         ServerModule.Engine = Engine;
      }
      else if ((ServerModule == None) && (ServerLink != ""))
         ServerDebugLog("Failed to attach Server Command Module -" @ ServerLink @ "on" @ Player.GetHumanName(), 'Error', Self);

      ClientModule.Player = Player;
      ClientModule.Module = Self;
      ClientModule.GiveTo(Player);
      ClientModule.bHeldItem = True;
      ClientModule.ServerInit(ClientLink);
   }
   else                                                                         // if Error occurs, log it
      ServerDebugLog("Failed to attach Command Module -" @ Commands @ "on" @ Player.GetHumanName(), 'Error', Self);
}

// =============================================================================
// Logging

// Log a Debug Message
simulated function ClientDebugLog (coerce string Event, name Type, Actor Sender)
{
   ServerDebugLog(Event,Type,Sender);
   Log(Sender.GetHumanName() @ "[" $ Type $ "]" @ Event, 'TOST');
}

function ServerDebugLog (coerce string Event, name Type, Actor Sender)
{
   DebugLog(Event,Type,Sender);
}

// =============================================================================
// Message Handling

// Send the message from the Server to the Module
function SendMessage (coerce string Message)
{
   PassMessage(Message);
}

// Pass the message from the Module to the Client
function PassMessage (coerce string Message)
{
   ReceiveMessage(Message);

   if (NextModule != None)
      NextModule.SendMessage(Message);
}

// Forward Message to the HUD Module; defined in subclass
simulated function ReceiveMessage (coerce string Message);

// =============================================================================
// TOST Engine Functions

// Set Next & Prev Client Modules
function SetModule (TOST_ClientModule Module)
{
	if (NextModule == None)
	{
		NextModule = Module;
        NextModule.PrevModule = Self;
        NextModule.ServerInit();
	}
	else
	{
        if (Module.Class != NextModule.Class)
		    NextModule.SetModule(Module);
    }
}

// =============================================================================
// Default Properties

defaultproperties
{
   bAlwaysRelevant=False
   bAlwaysTick=True
   RemoteRole=ROLE_SimulatedProxy
   NetPriority=5
   ActorID="Unknown TOST Client Module:"
}
