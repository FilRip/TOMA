// $Id: TOSTCommander.uc 549 2004-04-11 11:43:20Z stark $
//----------------------------------------------------------------------------
// Project : TOST
// File    : TOSTCommander.uc
// Version : 1.1
// Author  : BugBunny/Stark
//----------------------------------------------------------------------------

class TOSTCommander expands Inventory;

var TOSTClientPiece		Connect;
var TOSTHUDExtension	HUD;

var float	LastRandomTriggered;
var float	LastTriggeredCommand;
// var float	LastVotetime;	// anti lagscript - obsolete

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

exec simulated function Punish(int PID, optional int Damage, optional string Reason)
{
	Connect.SendMessage(106, ProcessPID(PID), Damage, , Reason);
}

exec simulated function	SAKick(string Args)
{
	local string	PlayerName, Reason;

	// Fix not splitted arguments (string-string)
	SplitArgs(Args, PlayerName, Reason);
	Connect.SendMessage(107, ProcessPlayerName(PlayerName), , , Reason);
}

exec simulated function	SAXKick(string Args)
{
	local string	PlayerName, Reason;

	// Fix not splitted arguments (string-string)
	SplitArgs(Args, PlayerName, Reason);
	Connect.SendMessage(107, ProcessPlayerName(PlayerName), , , Reason, true);
}

exec simulated function	SATempKickBan(string PlayerName, optional int Days, optional int Mins, optional string Reason)
{
	Connect.SendMessage(108, ProcessPlayerName(PlayerName), Days, float(Mins), Reason);
}

exec simulated function	SAKickBan(string Args)
{
	local string	PlayerName, Reason;

	// Fix not splitted arguments (string-string)
	SplitArgs(Args, PlayerName, Reason);
	Connect.SendMessage(109, ProcessPlayerName(PlayerName), , , Reason);
}

exec simulated function SAPKick(int PID, optional string Reason)
{
	Connect.SendMessage(107, ProcessPID(PID), , , Reason);
}

exec simulated function SAPXKick(int PID, optional string Reason)
{
	Connect.SendMessage(107, ProcessPID(PID), , , Reason, true);
}

exec simulated function	SAPTempKickBan(int PID, optional int Days, optional int Mins, optional string Reason)
{
	Connect.SendMessage(108, ProcessPID(PID), Days, float(Mins), Reason);
}

exec simulated function	SAPKickBan(int PID, optional string Reason)
{
	Connect.SendMessage(109, ProcessPID(PID), , , Reason);
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

	/*
	// removed check cause TOST messages are now queued
	if(Level.TimeSeconds > LastVotetime + 0.3)
	{
		LastVotetime = Level.Timeseconds;
		Connect.SendMessage(152, , , , Map);
	} else {
		PlayerPawn(Owner).ClientMessage("You have been removed from the game for abusing the votemap command.");
		TournamentConsole(PlayerPawn(Owner).Player.Console).bQuickKeyEnable=True;
	    TournamentConsole(PlayerPawn(Owner).Player.Console).LaunchUWindow();
	    TournamentConsole(PlayerPawn(Owner).Player.Console).ShowConsole();
		PlayerPawn(Owner).ConsoleCommand("disconnect");
	}
	*/
}

exec simulated function SkipMap()
{
	Connect.SendMessage(153);
}

exec simulated function SAChangeGameType(int Index)
{
	Connect.SendMessage(155, Index);
}

exec simulated function ChangeGameType(int Index)
{
	Connect.SendMessage(155, Index);
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

exec simulated function	SApasswd(String Args)
{
    local string newPass, confirm;

	// Fix not splitted arguments (string-string)
	SplitArgs(Args, newPass, confirm);

	if (newPass==confirm)
		Connect.SendMessage(209, , , , newPass);
}

exec simulated function SAForceLogout(optional int PID)
{
	Connect.SendMessage(210, ProcessPID(PID));
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

exec simulated function ForceDemoRec(optional int PID, optional string DemoName)
{
	Connect.SendMessage(132, ProcessPID(PID), , ,DemoName);
}

exec simulated function MkClanTeams(optional int Team, optional string Tag)
{
	Connect.SendMessage(134, Team, , ,Tag);
}

exec simulated function SAPMute(int PID, optional int Duration, optional string Reason)
{
	Connect.SendMessage(135, ProcessPID(PID), Duration, , Reason);
}

exec simulated function SAPWarn(int PID, optional string Reason)
{
	Connect.SendMessage(136, ProcessPID(PID), , , Reason);
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

/*
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
}*/

exec simulated function	GetServerIP()
{
	PlayerPawn(Owner).ClientMessage("Server IP is : "$PlayerPawn(Owner).Level.GetAddressURL());
}

exec simulated function AutoDemoRec()
{
	local string 	sResult;

	sResult = GetDemoName();
	sResult = PlayerPawn(Owner).ConsoleCommand("demorec"@sResult);
	PlayerPawn(Owner).Player.Console.addstring(sResult);
}

exec simulated function Random(string Arguments)
{
	local string 	Command;
	local string	entries[32];
	local int		size, use;

	if (LastRandomTriggered + 3 > Level.TimeSeconds)
		return; // Allow Random only once per 5 seconds...

	LastRandomTriggered = Level.TimeSeconds;

	Command = Mid(Arguments, 0, InStr(Arguments, "("));
	Arguments = Mid(Arguments, InStr(Arguments, "(")+1);
	Arguments = Mid(Arguments, 0, InStr(Arguments, ")"));

	size = SplitString (Arguments, ";", entries);
	use = Rand(size);

	PlayerPawn(Owner).ConsoleCommand(Command @ entries[use]);
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
// #P - Ping
// #C - PacketLoss
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
			switch (tStr)
			{
				// player weapon - inserts weapon name
				case "W":	nMsg = nMsg $ PlayerPawn(Owner).Weapon.ItemName;
							break;
				// player name - inserts this player's name
				case "N":	nMsg = nMsg $ mPRI.PlayerName;
							break;
				// player location - inserts the player's location
				case "L":	if (mPRI.PlayerLocation != none  && (mPRI.PlayerLocation.LocationName != "")) {
							  	nMsg = nMsg $ mPRI.PlayerLocation.LocationName;
							} else {
								if (mPRI.PlayerZone != none  && (mPRI.PlayerZone.ZoneName != ""))
									nMsg = nMsg $ mPRI.PlayerZone.ZoneName;
								else
									nMsg = nMsg $ "somewhere";
							}
							break;
				// player health - inserts player's health
				case "H":	nMsg = nMsg $ PlayerPawn(Owner).Health;
							break;
				// players target - inserts name of players target
				case "T":	if (ChallengeHUD(PlayerPawn(Owner).MyHUD) != None && ChallengeHUD(PlayerPawn(Owner).MyHUD).TraceIdentify(None))
							{
								if (ChallengeHUD(PlayerPawn(Owner).MyHUD).IdentifyFadeTime < 3.0)
									nMsg = nMsg $ ChallengeHUD(PlayerPawn(Owner).MyHUD).IdentifyTarget.PlayerName;
								else
									nMsg = nMsg $ "unknown";
							} else {
								nMsg = nMsg $ "nobody";
							}
							break;
							/*StartTrace = PawnOwner.Location;
							StartTrace.Z += PawnOwner.BaseEyeHeight;
							EndTrace = StartTrace + vector(PawnOwner.ViewRotation) * MaxRange;
							Other = Trace(HitLocation, HitNormal, EndTrace, StartTrace, true);
							if (Pawn(Other))
								nMsg = nMsg $ Pawn(Other).PlayerReplicationInfo.PlayerName;
							else
									nMsg = nMsg $ "nobody";
							}
							break;*/
				// player buddies - inserts a list of friendly units within a defined radius
				case "B":	numBuddy = 0;
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
				// print player ping
				case "P":	nMsg = nMsg $ PlayerPawn(Owner).PlayerReplicationInfo.Ping;
							break;
				// print player packetloss
				case "C":	nMsg = nMsg $ PlayerPawn(Owner).PlayerReplicationInfo.PacketLoss;
							break;
				// print the '#' character
				case "#":	nMsg = nMsg $ "#";
							break;

				default:	break;
			}
		}
		else {
			// if we didn't find an escape code just copy char straight over
			// to the new message
			nMsg = nMsg $ Mid(mMsg, i, 1);
		}
	}
	// and finally return the new message
	return nMsg;
}

// * ProcessPlayerName - returns playerID
simulated function int ProcessPlayerName(string PlayerName)
{
	local PlayerReplicationInfo PRI;

	foreach AllActors(class'PlayerReplicationInfo', PRI)
	{
		if (PRI.PlayerName == PlayerName)
			return PRI.PlayerID;
	}
	if (PlayerPawn(Owner).bAdmin)
		PlayerPawn(Owner).ClientMessage("No valid name.");
	return -1;
}

// * GetDemoName - return a name: level-date-time
simulated function string GetDemoName()
{
	return AlphaNumeric(level.title$"-"$string(level.Month)$"-"$string(level.Day)$"-"$string(level.year)$"@"$string(level.Hour)$"H"$string(level.Minute));
}

// * AlphaNumeric - remove illegal char from string
simulated static final function string AlphaNumeric(string s)
{
	local string result;
	local int i, c;

	for (i = 0; i < Len(s); i++) {
		c = Asc(Right(s, Len(s) - i));
		if ( c == Clamp(c, 48, 57) )  // 0-9
			result = result $ Chr(c);
		else if ( c == Clamp(c, 64, 90) ) // A-Z and @
			result = result $ Chr(c);
		else if ( c == Clamp(c, 97, 122) ) // a-z
			result = result $ Chr(c);
		else if ( c == 45 || c == 95)  // - _
			result = result $ Chr(c);
	}

	return result;
}

// * SplitString - Split a string in parts
simulated static final function int SplitString ( coerce string Src, string Divider, out string Parts[32] )
{
	local string temp;
	local int index;

	index = 0;

	if ( Divider != "" || Src != "" ){
		while ( Src != "" ) {
			temp = removePart ( Src, Divider );
			log ( temp );
			if ( temp != "" ) {
				parts[index] = temp;
				index++;
			}
		}
	}
	return index;
}

// * removePart - Helper for Splitstring
simulated static final function string removePart ( out string Src, string Divider )
{
	local int pos;
	local string result;

	pos = InStr ( Src, Divider );

	if ( pos == -1 ) {
		result = Src;
		Src = "";
	}
	else {
		result = Left( Src, pos);
		Src = Mid ( Src, pos + len ( Divider ) );
	}
	return result;
}

// * SplitArgs - splits a string in two on first space
simulated static final function SplitArgs (out string Src, out string String1, out string String2)
{
	local int pos;

	pos = InStr (Src, " ");

	if ( pos == -1 ) {
		String1 = Src;
		String2 = "";
	}
	else {
		String1 = Left(Src, pos);
		String2 = Mid (Src, pos + 1);
	}
}

defaultproperties
{
	bHidden=True
}
