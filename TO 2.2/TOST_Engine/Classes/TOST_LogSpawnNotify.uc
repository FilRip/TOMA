//------------------------------------------------------------------------------
// PROJECT : Tactical Ops ServerAdmin Tool
// FILE    : TOST_Mutator.uc
// VERSION : 1.0
// INFO    : Attaches old Game Log to the current one
// AUTHOR  : BugBunny, updated by Xian
//------------------------------------------------------------------------------
// CHANGES :
// v1.0     + Initial version
//------------------------------------------------------------------------------

class TOST_LogSpawnNotify expands SpawnNotify;

// =============================================================================
// Helpers

var string ActorID;
var	TOST_Mutator TOST;                                                          // Pointer to the Mutator
var bool bInit;                                                                 // Has the Log Hook been attached ?

// =============================================================================
// Engine Specific Functions

function String GetHumanName()
{
	return ActorID;
}

// Called on Actor Spawning
function Actor SpawnNotification (Actor Actor)
{
   if (!bInit && Actor.IsA('StatLog'))
   {
      TOST.LogHook.NextLog = StatLog(Actor);
      TOST.LogHook.NextLog.bWorld = False;
      TOST.LogHook.NextLog.StartLog();
      Destroy();
      bInit = True;

      return TOST.LogHook;
   }
   else
      return Actor;
}

defaultproperties
{
   bHidden=True
   ActorClass=Class'StatLog'
   ActorID="TOST Log Spawn Notify:"
}

