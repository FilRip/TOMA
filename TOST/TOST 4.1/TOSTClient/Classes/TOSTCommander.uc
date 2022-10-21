//----------------------------------------------------------------------------
// Project : TOST
// File    : TOSTCommander.uc
// Version : 1.0
// Author  : BugBunny
//----------------------------------------------------------------------------
// Version	Changes
// 0.5		+ first release
// 0.6		+ first beta release
// 1.0		+ first public release
//----------------------------------------------------------------------------

class TOSTCommander expands Inventory;

var TOSTClientPiece		Connect;
var TOSTHUDExtension	HUD;

// init

simulated event PostNetBeginPlay ()
{
	super.PostNetBeginPlay();
	if ( (Level.NetMode == NM_Client && ROLE < ROLE_SimulatedProxy) || (!bNetOwner))
		return;
	// ClientPiece only used for sending, so no need for an extra class
	Connect = spawn(class'TOSTClientPiece', self);
}

function DropFrom(vector StartLocation)
{
	log("DEBUG : Commander dropped - destroyed", 'Debug');
	Connect.Destroy();
	Destroy();
}

// server features

exec simulated function TOSTInfo()
{
	Connect.SendMessage(100);
}

exec simulated function MkTeams(optional bool RemoveWeapons)
{
	Connect.SendMessage(102, , , , , RemoveWeapons);
}

exec simulated function FTeamChg(int PID, optional bool RemoveWeapons)
{
	Connect.SendMessage(103, ProcessPID(PID), , , , RemoveWeapons);
}

exec simulated function KickBanTK(optional int PID)
{
	Connect.SendMessage(104, ProcessPID(PID));
}

exec simulated function SAMapChg(string Map)
{
	Connect.SendMessage(105, , , , Map);
}

exec simulated function Punish(int PID, optional int Damage)
{
	Connect.SendMessage(106, ProcessPID(PID), Damage);
}

exec simulated function	SAKick(string PlayerName)
{
	Connect.SendMessage(107, , , , PlayerName);
}

exec simulated function	SAXKick(string PlayerName)
{
	Connect.SendMessage(107, , , , PlayerName, true);
}

exec simulated function	SAPKick(int PID)
{
	Connect.SendMessage(107, ProcessPID(PID));
}

exec simulated function	SAXPKick(int PID)
{
	Connect.SendMessage(107, ProcessPID(PID), , , , true);
}

exec simulated function	SATempKickBan(string PlayerName, optional int Days, optional int Mins)
{
	Connect.SendMessage(108, , Days, float(Mins), PlayerName);
}

exec simulated function	SAPTempKickBan(int PID, optional int Days, optional int Mins)
{
	Connect.SendMessage(108, ProcessPID(PID), Days, float(Mins));
}

exec simulated function	SAKickBan(string PlayerName)
{
	Connect.SendMessage(109, , , , PlayerName);
}

exec simulated function	SAPKickBan(int PID)
{
	Connect.SendMessage(109, ProcessPID(PID));
}

exec simulated function	SAAdminReset()
{
	Connect.SendMessage(110);
}

exec simulated function	SAEndRound()
{
	Connect.SendMessage(111);
}

exec simulated function	SASay(string Msg)
{
	Connect.SendMessage(112, , , , Msg);
}

exec simulated function	ProtectSrv(optional int Duration)
{
	Connect.SendMessage(113, Duration);
}

exec simulated function	ShowIP(int PID)
{
	Connect.SendMessage(114, ProcessPID(PID));
}

exec simulated function	ChangeMutator(int Index, string Mutator)
{
	Connect.SendMessage(115, Index, , , Mutator);
}

exec simulated function	ChangePiece(int Index, string Piece)
{
	Connect.SendMessage(116, Index, , , Piece);
}

exec simulated function	ForceName(int PID, string NewName)
{
	Connect.SendMessage(118, ProcessPID(PID), , , NewName);
}

exec simulated function	Whisper(int PID, string Text)
{
	Connect.SendMessage(119, ProcessPID(PID), , , FormatString(Text));
}

exec simulated function	SAPause()
{
	Connect.SendMessage(130);
}

exec simulated function	CWMode(bool Flag)
{
	Connect.SendMessage(121, 125, , , , Flag);
}

exec simulated function	SASetGamePw(string Password)
{
	Connect.SendMessage(121, 101, , , Password);
}

exec simulated function GetNextMap()
{
	Connect.SendMessage(150);
}

exec simulated function SASetNextMap(string Map)
{
	Connect.SendMessage(151, , , , Map);
}

exec simulated function SetNextMap(string Map)
{
	Connect.SendMessage(151, , , , Map);
}

exec simulated function VoteMap(string Map)
{
	Connect.SendMessage(152, , , , Map);
}

exec simulated function SkipMap()
{
	Connect.SendMessage(153);
}

exec simulated function SaveSettings(int Index, optional string Desc)
{
	Connect.SendMessage(140, Index, , , Desc);
}

exec simulated function LoadSettingsPW(int Index, optional string Pass)
{
	Connect.SendMessage(141, Index, , , Pass, true);
}

exec simulated function LoadSettings(int Index)
{
	Connect.SendMessage(141, Index, , , , false);
}

exec simulated function SALogin(string Pass)
{
 	Connect.SendMessage(200, , , , Pass);
}

exec simulated function SALogout()
{
	Connect.SendMessage(201);
}

exec simulated function	ExplainPolicy(int Level)
{
	Connect.SendMessage(204, Level, , , , True);
}

exec simulated function	SAaddPW(int Level, String newpw)
{
	Connect.SendMessage(206, Level, , , newpw);
}

exec simulated function	SAdelPW(String toDel)
{
	Connect.SendMessage(207, , , , toDel);
}

exec simulated function	SAHelp()
{
	Connect.SendMessage(208);
}

exec simulated function	SApasswd(String newPass, String confirm)
{
	if (newPass==confirm)
		Connect.SendMessage(209, , , , newPass);
}

exec simulated function	ShowVoteTab()
{
	Connect.SendClientMessage(112, , , , "TOST VoteTab", false);
}

exec simulated function	ShowGameTab()
{
	Connect.SendClientMessage(112, , , , "TOST GameTab", false);
}

exec simulated function	ShowAdminTab()
{
	Connect.SendClientMessage(112, , , , "TOST AdminTab", false);
}

/*
exec simulated function	TostSetup()
{
	Connect.SendClientMessage(112, , , , "TOST SetupTab", false);
}
*/

exec simulated function	PlayExtraSound(int PID, string MySound)
{
	Connect.SendMessage(163, ProcessPID(PID), , , MySound);
}

exec simulated function	Time ()
{
	Connect.SendClientMessage(122);
}

// client only features

exec simulated function XSay(coerce string s)
{
   PlayerPawn(Owner).Say(FormatString(s));
}

exec simulated function XTeamSay(coerce string s)
{
   PlayerPawn(Owner).TeamSay(FormatString(s));
}

exec simulated function Echo(coerce string s)
{
   PlayerPawn(Owner).ClientMessage(PlayerPawn(Owner).PlayerReplicationInfo.PlayerName$":(Echo)"@FormatString(s));
}

exec simulated function ShowTeamInfo()
{
	if (HasHUDMut())
		Hud.SwitchTeamInfo();
}

exec simulated function ShowWeapon()
{
	if (HasHUDMut())
		Hud.SwitchWeaponHud();
}

exec simulated function ShowWeaponInfo()
{
	if (HasHUDMut())
		Hud.SwitchWeaponHud();
}

exec simulated function	SetSoundLength(float len)
{
	if (HasHUDMut())
	{
		Hud.AllowedSoundLength = len;
		Hud.SaveConfig();
	}
}

exec simulated function	SetSoundClass(int i)
{
	if (HasHUDMut())
	{
		Hud.AllowedSoundClass = i;
		Hud.SaveConfig();
	}
}

exec simulated function	IgnoreSound(int PID)
{
	if (HasHUDMut())
	{
		Hud.IgnoreSound(ProcessPID(PID));
	}
}

exec simulated function	QuickConsole(string Text)
{
	local	Console	Con;

	Con = PlayerPawn(Owner).Player.Console;
	if (Con != None)
	{
		Con.TypedStr = Text$" ";
		Con.bNoStuff = true;
		Con.GotoState( 'Typing' );
	}
}

exec simulated function	GetServerIP()
{
	PlayerPawn(Owner).ClientMessage("Server IP is : "$PlayerPawn(Owner).Level.GetAddressURL());
}

// - helper

// * HasHUDMut - check and evtually search for TOSTHudExtension
simulated function	bool	HasHUDMut()
{
	if (Hud == None)
		foreach AllActors(class'TOSTHUDExtension', Hud)
			break;
	return (Hud != None);
}

// * ProcessPID - check for "trace PID"
simulated function	int		ProcessPID(int PID)
{
	if (PID == -1 && HasHUDMut())
	{
		if (Hud.MyHUD.TraceIdentify(None))
		{
			return (Hud.MyHUD.IdentifyTarget.PlayerID);
		} else {
			Hud.MyPlayer.ClientMessage("No valid target.");
			return -1;
		}

	} else
		return PID;
}

// * FormatString
//
// Codes :
// ## - print #
// #W - players weapon
// #T - players target name
// #N - players name
// #L - players location (if defined by the mapper !)
// #H - players health
// #B - players buddies (all people of the same team within 1500 units)
simulated function string FormatString(string mMsg)
{
   local int i, amt, numBuddy, lBuddyLen;
   local float BuddyRadius;
   local string nMsg, tStr, bStr, lbStr;
   local Pawn Buddy;
   local PlayerReplicationInfo mPRI, bPRI;

   BuddyRadius = 1500.0;
   mPRI = PlayerPawn(Owner).PlayerReplicationInfo;

   // step through the string and look for escape char
   // Len(string) returns the length of the string
   for (i = 0;i <= Len(mMsg);i++)
   {
      // use mid to get the char at i in Msg since msg[i] doesn't work
      // Mid(string, pos, count) returns a string starting at pos and
      // ending at pos+count, so to get one char we use a count of 1
      if (Mid(mMsg, i, 1) == "#")
      {
         // found escape char, now get the next char and parse
         i += 1;
         tStr = Mid(mMsg,i,1);
               // this is our main switch statement, to add more escape codes
               // just add more cases in here
         switch (tStr)
         {
        	 // player weapon - inserts weapon name
	         case "W":  nMsg = nMsg $ PlayerPawn(Owner).Weapon.ItemName;
                        break;
             // player name - inserts this player's name
             case "N":  nMsg = nMsg $ mPRI.PlayerName;
                        break;
             // player location - inserts the player's location
             case "L":  if (mPRI.PlayerLocation != none  && (mPRI.PlayerLocation.LocationName != "")) {
                          	nMsg = nMsg $ mPRI.PlayerLocation.LocationName;
                        } else {
                           	if (mPRI.PlayerZone != none  && (mPRI.PlayerZone.ZoneName != ""))
                           		nMsg = nMsg $ mPRI.PlayerZone.ZoneName;
                           	else
                           		nMsg = nMsg $ "somewhere";
                        }
                        break;
             // player health - inserts player's health
             case "H":  nMsg = nMsg $ PlayerPawn(Owner).Health;
                        break;
             // players target - inserts name of players target
             case "T":  if (ChallengeHUD(PlayerPawn(Owner).MyHUD) != None && ChallengeHUD(PlayerPawn(Owner).MyHUD).TraceIdentify(None))
                        {
                           	//if (ChallengeHUD(PlayerPawn(Owner).MyHUD).IdentifyFadeTime < 3.0)
                        		nMsg = nMsg $ ChallengeHUD(PlayerPawn(Owner).MyHUD).IdentifyTarget.PlayerName;
                        	//else
                           	//	nMsg = nMsg $ "unknown";
                        } else {
                           	nMsg = nMsg $ "nobody";
                        }
                        break;
                        /*
                    	StartTrace = PawnOwner.Location;
						StartTrace.Z += PawnOwner.BaseEyeHeight;
						EndTrace = StartTrace + vector(PawnOwner.ViewRotation) * MaxRange;
						Other = Trace(HitLocation, HitNormal, EndTrace, StartTrace, true);
                      	if (Pawn(Other))
                       		nMsg = nMsg $ Pawn(Other).PlayerReplicationInfo.PlayerName;
                        else
                           	nMsg = nMsg $ "nobody";
                        }
						break;*/
             // player buddies - inserts a list of friendly units within
             // a defined radius
             case "B":  numBuddy = 0;
                        foreach PlayerPawn(Owner).RadiusActors(class'Pawn', Buddy, BuddyRadius)
                        {
                        	bPRI = Buddy.PlayerReplicationInfo;
                            if (Buddy != PlayerPawn(Owner) && Buddy.bIsPlayer && bPRI.Team == mPRI.Team)
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
                        // backtrack a bit and add an "and" to the message if
                        // we had 2 or more buddies, to be grammatically correct
                        if (numBuddy >= 3)
	                        bStr = Left(bStr, Len(bStr) - lBuddyLen) $ " and " $ lbStr;
                        else if (numBuddy == 2)
    	                    bStr = Left(bStr, Len(bStr) - lBuddyLen - 2) $ " and " $ lbStr;
                        else if (numBuddy == 0)
        	                bStr = "nobody";

            	        nMsg = nMsg $ bStr;
                        break;

              // print the '#' character
              case "#": nMsg = nMsg $ "#";
                        break;
              default:  break;
			}
      	} else {
         	// if we didn't find an escape code just copy char straight over
         	// to the new message
			nMsg = nMsg $ Mid(mMsg, i, 1);
		}
	}
	// and finally return the new message
	return nMsg;
}

defaultproperties
{
	bHidden=True
}
