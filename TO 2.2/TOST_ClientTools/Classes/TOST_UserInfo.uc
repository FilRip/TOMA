//------------------------------------------------------------------------------
// PROJECT : Tactical Ops ServerAdmin Tool
// FILE    : TOST_UserInfo.uc
// VERSION : 1.0
// INFO    : Saves User Settings, ClientSide
// AUTHOR  : Xian
//------------------------------------------------------------------------------
// CHANGES :
// v1.0     + Initial version
//------------------------------------------------------------------------------

class TOST_UserInfo expands TOST_Core abstract config (TOST_Client);

// =============================================================================
// Configuration

var () config bool DisplayHostages;                                             // Whether or not to display Hostages
var () config int TeamInfo;                                                     // Team Info Display Type
var () config int WeaponInfo;                                                   // Weapon Display Type

// =============================================================================
// TOST Engine Functions

// Toggle Settings
static simulated function ToggleSetting (string Setting)
{
   switch Setting
   {
      case "ShowNPC" :
         Class 'TOST_UserInfo'.default.DisplayHostages = !Class 'TOST_UserInfo'.default.DisplayHostages;
         Log(default.ActorID @ "[Config] Changed setting" @ Setting @ "to" @ Class 'TOST_UserInfo'.default.DisplayHostages, 'TOST');
         break;

      case "ShowTeamInfo":
         switch Class 'TOST_UserInfo'.default.TeamInfo
         {
            case 0  : ++ Class 'TOST_UserInfo'.default.TeamInfo; break;
            case 1  : ++ Class 'TOST_UserInfo'.default.TeamInfo; break;
            case 2  : Class 'TOST_UserInfo'.default.TeamInfo = 0; break;
         }
         Log(default.ActorID @ "[Config] Changed setting" @ Setting @ "to" @ Class 'TOST_UserInfo'.default.TeamInfo, 'TOST');
         break;

      case "ShowWeaponInfo" :
         switch Class 'TOST_UserInfo'.default.WeaponInfo
         {
            case 0  : ++ Class 'TOST_UserInfo'.default.WeaponInfo; break;
            case 1  : ++ Class 'TOST_UserInfo'.default.WeaponInfo; break;
            case 2  : ++ Class 'TOST_UserInfo'.default.WeaponInfo; break;
            case 3  : ++ Class 'TOST_UserInfo'.default.WeaponInfo; break;
            case 4  : Class 'TOST_UserInfo'.default.WeaponInfo = 0; break;
         }
         Log(default.ActorID @ "[Config] Changed setting" @ Setting @ "to" @ Class 'TOST_UserInfo'.default.WeaponInfo, 'TOST');
         break;
   }

   StaticSaveConfig();
}

// Sets a setting
static simulated function SetSetting (string Setting, int Value)
{
   switch Setting
   {
      case "ShowNPC" :
         switch Value
         {
            case 0 : Class 'TOST_UserInfo'.default.DisplayHostages = False; break;
            case 1 : Class 'TOST_UserInfo'.default.DisplayHostages = True; break;
         }
         break;

      case "ShowTeamInfo":
         if (Value > 2)
            Class 'TOST_UserInfo'.default.TeamInfo = 0;
         else
            Class 'TOST_UserInfo'.default.TeamInfo = Value;
         break;

      case "ShowWeaponInfo" :
         if (Value > 4)
            Class 'TOST_UserInfo'.default.WeaponInfo = 0;
         else
            Class 'TOST_UserInfo'.default.WeaponInfo = Value;
         break;
   }

   Log(default.ActorID @ "[Config] Changed setting" @ Setting @ "to" @ Value, 'TOST');
   StaticSaveConfig();
}

// =============================================================================
// Default Properties

defaultproperties
{
   ActorID="TOST User Settings:"

   DisplayHostages=True
   TeamInfo=1
   WeaponInfo=1
}
