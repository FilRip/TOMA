//------------------------------------------------------------------------------
// PROJECT : Tactical Ops ServerAdmin Tool
// FILE    : TOST_HUDMutator.uc
// VERSION : 1.0
// INFO    : Mutator Hook; Link between the Base HUD Mutators and the HUD Module
// AUTHOR  : Xian
//------------------------------------------------------------------------------
// CHANGES :
// v1.0     + Initial version
//------------------------------------------------------------------------------

class TOST_HUDMutator expands Mutator;

// =============================================================================
// Attachments

var TOST_HUDModule Module;                                                      // Pointer to the HUD Module
var TOST_ClientModule Link;                                                     // Pointer to Module Owner
var s_HUD HUD;                                                                  // Pointer to the HUD Owner
var s_Player Player;                                                            // Pointer to the Player Owner

// =============================================================================
// Helpers

var string ActorID;

// =============================================================================
// Engine Specific Functions

function String GetHumanName()
{
	return ActorID;
}

// Called by HUD.PostRender()
simulated function PostRender (Canvas Canvas)
{
   if (Module != None)
      Module.Render(Canvas);

   if (NextHUDMutator != None)
      NextHUDMutator.PostRender(Canvas);
}

// Registers the current Mutator on the client to receive PostRender calls.
simulated function RegisterHUDMutator ()
{
   if (HUD == None)
   {
      Log(ActorID @ "[Error] Player HUD is not found",'TOST');
      return;
   }

   if (bHUDMutator)
      return;

   if (HUD.HUDMutator != None)
      NextHUDMutator = HUD.HUDMutator;

   HUD.HUDMutator = Self;
   bHUDMutator = True;
}

// =============================================================================
// TOST Engine Functions

// Registers the current Module on the client to receive PostRender calls.
simulated function RegisterHUDModule (coerce string ClassString, TOST_ClientModule Client)
{
   local TOST_HUDModule NextModule;
   local TOST_HUDModule HUDModule;
   local Class <TOST_HUDModule> ModuleClass;

   if ((ClassString == "") || (HUD == None) || (Player == None) || (Client == None))
      return;

   // Load Class
   ModuleClass = Class <TOST_HUDModule> (DynamicLoadObject(ClassString, Class 'Class'));
   // Spawn Module
   HUDModule = Spawn (ModuleClass, Self);

   if (HUDModule == None)
      return;

   if (Module != None)
   {
      if (Module.IsAttached(HUDModule))
         return;

      NextModule = Module;
      HUDModule.NextModule = NextModule;
   }

   HUDModule.HUD = HUD;
   HUDModule.Player = Player;
   HUDModule.Module = Client;
   Module = HUDModule;
   Module.Initialize();
}

// =============================================================================
// Default Properties

defaultproperties
{
   ActorID="TOST HUD Mutator:"
}
