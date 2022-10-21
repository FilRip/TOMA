//------------------------------------------------------------------------------
// PROJECT : Tactical Ops ServerAdmin Tool
// FILE    : TOST_Core.uc
// VERSION : 1.0
// INFO    : Base Class of most TOST Files
// AUTHOR  : Xian
//------------------------------------------------------------------------------
// CHANGES :
// v1.0     + Initial version
//------------------------------------------------------------------------------

class TOST_Core expands ReplicationInfo;

// =============================================================================
// Helpers

var string ActorID;

// =============================================================================
// Engine Specific Functions

// Called after being created
function Spawned ()
{
   SaveConfig();

   Super.Spawned();                                                             // Call Super
}

// Called after being destroyed
function Destroyed ()
{
   SaveConfig();

   Super.Destroyed();                                                           // Call Super
}

function String GetHumanName()
{
	return ActorID;
}

// =============================================================================
// Helpers

// Returns IP or Port
final function string ResolveHost (string Address, byte Type)
{
    local int SplitPoint;

    SplitPoint = (InStr(Address, ":"));

    if (SplitPoint != -1)
    {
       switch Type
       {
          case 0  : return (Left(Address, SplitPoint)); break;
          case 1  : return (Mid(Address, (SplitPoint + Type))); break;
          default : return Address; break;
       }
    }
    else
       return Address;
}

// =============================================================================
// Default Properties

defaultproperties
{
   bHidden=True
   NetPriority=5
   ActorID="TOST Core:"
}
