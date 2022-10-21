//------------------------------------------------------------------------------
// PROJECT : Tactical Ops ServerAdmin Tool
// FILE    : TOST_ToolsClientCommands.uc
// VERSION : 1.0
// INFO    : Handles execution of Tools Client Console Commands
// AUTHOR  : Xian
//------------------------------------------------------------------------------
// CHANGES :
// v1.0     + Initial version
//------------------------------------------------------------------------------

class TOST_ToolsClientCommands expands TOST_ClientCommandModule;

// =============================================================================
// TOST Engine Functions

// Runs the Command on the Client
simulated function ExecuteCommand (int ConsoleCommand, s_Player Player, optional string sResult, optional string sValue, optional bool bResult, optional int iValue, optional float fValue, optional byte bValue, optional Actor Actor)
{
   switch ConsoleCommand
   {
      case 0 : TOST_Say(Player,sResult); break;
      case 1 : TOST_TeamSay(Player,sResult); break;
      case 2 : TOST_Echo(Player,sResult); break;
      case 3 : TOST_Toggle(Player,"ShowTeamInfo"); break;
      case 4 : TOST_Toggle(Player,"ShowWeaponInfo"); break;
      case 5 : TOST_Toggle(Player,"ShowNPC"); break;
      case 6 : TOST_Set(Player,sResult,iValue); break;
      case 7 : TestRender(Player); break;
   }
}

simulated function TOST_Say (s_Player Player, coerce string Message)
{
   local string Msg;

   Msg = FormatString(Player,Message);

   if ((Message != "") && (Msg != ""))
      Player.Say(Msg);
}

simulated function TOST_TeamSay (s_Player Player, coerce string Message)
{
   local string Msg;

   Msg = FormatString(Player,Message);

   if ((Message != "") && (Msg != ""))
      Player.TeamSay(Msg);
}

simulated function TOST_Echo (s_Player Player, coerce string Message)
{
   local string Msg;

   Msg = (Player.GetHumanName() $ ": [Echo] -" @ FormatString(Player,Message));

   if ((Message != "") && (Msg != ""))
      Player.ClientMessage(Msg,'TOST');
}

simulated function TOST_Toggle (s_Player Player, coerce string Option)
{
   Class 'TOST_UserInfo'.static.ToggleSetting(Option);
}

simulated function TOST_Set (s_Player Player, coerce string Option, int Value)
{
   Class 'TOST_UserInfo'.static.SetSetting(Option,Value);
}

simulated function TestRender (s_Player Player)
{
   local Texture Test;

   Test = Texture (DynamicLoadObject("TOSTTex.Knife", Class 'Texture'));

   if (Test == None)
      Player.ClientMessage(ActorID @ "Weapon Textures are not installed - Rendering disabled",'TOST');
   else
      Player.ClientMessage(ActorID @ "Weapon Textures are installed - Rendering enabled",'TOST');
}

simulated function string FormatString (s_Player Player, coerce string mMsg)
{
   local int i, numBuddy, lBuddyLen;
   local int Health, Armor;
   local string nMsg, bStr, tStr, lbStr;
   local Pawn Buddy;
   local PlayerReplicationInfo mPRI, bPRI;
   local s_HUD mHUD;

   if ((Player == None) || (Player.PlayerReplicationInfo == None) || (mMsg == "") || (Player.Weapon == None))
      return "";

   mPRI = Player.PlayerReplicationInfo;
   mHUD = s_HUD(Player.MyHUD);

   for (i = 0; i <= Len(mMsg); ++ i)
   {
      if (Mid(mMsg, i, 1) == "#")
      {
         i += 1;
         tStr = Mid(mMsg,i,1);

         switch tStr
         {
            case "W" : nMsg = nMsg $ Player.Weapon.ItemName; break;
            case "N" : nMsg = nMsg $ mPRI.PlayerName; break;
            case "L" :
               if ((mPRI.PlayerLocation != None) && (mPRI.PlayerLocation.LocationName != ""))
                  nMsg = nMsg $ mPRI.PlayerLocation.LocationName;
               else if ((mPRI.PlayerZone != None) && (mPRI.PlayerZone.ZoneName != ""))
                  nMsg = nMsg $ mPRI.PlayerZone.ZoneName;
               else
                  nMsg = nMsg $ "somewhere";
               break;
            case "H" :
               if (Player.Health > 0)
                  Health = Player.Health;
               else
                  Health = 0;
               nMsg = nMsg $ Health;
               break;
            case "A" :
               Armor = (Player.VestCharge + Player.LegsCharge + Player.HelmetCharge);
               if (Armor > 0)
                  Armor /= 3;
               nMsg = nMsg $ Armor;
               break;
            case "T" :
               if ((mHUD != None) && mHUD.TraceIdentify(None))
                  nMsg = nMsg $ mHUD.IdentifyTarget.PlayerName;
               else
                  nMsg = nMsg $ "somebody";
               break;
            case "B" :
               numBuddy = 0;

               foreach Player.RadiusActors(class'Pawn', Buddy, 1500)
               {
                  bPRI = Buddy.PlayerReplicationInfo;

                  if ((Buddy != Player) && Buddy.bIsPlayer && (bPRI.Team == mPRI.Team))
                  {
                     lbStr = bPRI.PlayerName;
                     lBuddyLen = Len(lbStr);

                     if (numBuddy < 1)
                        bStr = lbStr;
                     else
                        bStr = bStr $ ", " $ lbStr;
                     numBuddy++;
                  }
               }

               if (numBuddy >= 3)
                  bStr = Left(bStr, Len(bStr) - lBuddyLen) $ " and " $ lbStr;
               else if (numBuddy == 2)
                  bStr = Left(bStr, Len(bStr) - lBuddyLen - 2) $ " and " $ lbStr;
               else if (numBuddy == 0)
                  bStr = "nobody";

               nMsg = nMsg $ bStr;
               break;
             case "#" : nMsg = nMsg $ "#"; break;
             default  : break;
         }
      }
      else
         nMsg = nMsg $ Mid(mMsg, i, 1);
   }

   return nMsg;
}

// =============================================================================
// Default Properties

defaultproperties
{
   ActorID="TOST Client Tools Commands:"
}
