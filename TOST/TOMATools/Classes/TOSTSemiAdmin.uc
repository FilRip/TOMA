// $Id: TOSTSemiAdmin.uc 519 2004-04-01 23:43:40Z stark $
//----------------------------------------------------------------------------
// Project   : TOST
// File      : TOSTSemiAdmin.uc
// Version   : 1.0
// Author    : Stark/BugBunny
//----------------------------------------------------------------------------
// Version	Changes
// 0.5		+ first release
// 0.5.1	+ redid code to allow more levels
//			+ added user policies
//			+ added explainpolicy
// 0.6		+ first beta release
// 0.7		+ added SAaddPW, SAdelPW, SAhelp, SApasswd
// 1.0		+ first public release
// 1.1.5	+ added force logout
//----------------------------------------------------------------------------

class TOSTSemiAdmin expands TOSTPiece config;

var	config private string	SApw[10]; // Format: "pass" or "pass1;pass2;pass3" ...
var config private string	Policy[10]; // Format: "101" | "101-103" and combinations of both with ";"
var config private string   ReadPolicy[10];  //  ReadPolicies for changing gamesettings
var config private string	WritePolicy[10]; // WritePolicies for changing gamesettings
var config private int		SilentLogin; // dont notify the other Players of the login
var	config private string	UserReadPolicy, UserWritePolicy, UserPolicy; // Policies for normal players
var	config private int		MaxTry; // ban the Player after this amount of failed logins
var	config private int		minPWLen; // the minimum Length of a new password
var config private bool     forceDigit; // if true, the Password needs to have at least one Digit

var string 	LoginMsg, LogoutMsg, ForcedMsg, FailedMsg, BanMsg;
var	int		TestLevel;
var bool	CWMode;

struct SAlevels {
	var	int SAL;
	var int FailedLogins;
	var	string myPW;
};
var private SALevels Admins[32];

function EventInit()
{
	local int i;

	// Bugfix for old versions
	for (i=0; i<10; i++)
	{
		if (SAPw[i]!="")
		{
			SAPw[i] = Trim(SAPw[i], ";");
			SAPw[i] = ReplaceText(SAPw[i], ";;", ";");
		}
	}

	super.EventInit();
}

function	TranslateMessage(TOSTPiece Sender)
{
	switch (Sender.Params.Param1)
	{
		case BaseMessage+0  : Sender.Params.Param4 = "SALogin - Login as Semi-Admin (SALogin <Password>)"; break;
		case BaseMessage+1  : Sender.Params.Param4 = "SALogout - Give up Semi-Admin abilities"; break;
		case BaseMessage+4  : Sender.Params.Param4 = "ExplainPolicy - Shows available commands for a SA Level (ExplainPolicy <Level>)"; break;
		case BaseMessage+6  : Sender.Params.Param4 = "SAaddpw - Adds a new password for a SA-Level (SAaddpw <Level> <Password>)"; break;
		case BaseMessage+7  : Sender.Params.Param4 = "SAdelpw - Deletes a SA-password (SAdelpw <Password>)"; break;
		case BaseMessage+8  : Sender.Params.Param4 = "SAhelp - Shows your current rights"; break;
		case BaseMessage+9  : Sender.Params.Param4 = "SApasswd - Changes your SA password (SApasswd <Password> <Password confirm>)"; break;

		case 120			: if (Sender.Params.Param2 == 0)
								Sender.Params.Param4 = "GetValue";
							  else
								TranslateValueMessage(Sender);
							  break;
		case 121			: if (Sender.Params.Param2 == 0)
								Sender.Params.Param4 = "SetValue";
							  else
								TranslateValueMessage(Sender);
							  break;
		default : break;
	}
}

function	TranslateValueMessage(TOSTPiece Sender)
{
	switch (Sender.Params.Param2)
	{
		case 125 :	Sender.Params.Param4 = "CW Mode"; break;
	}
}

function	SALogin(PlayerPawn Player, string Pass)
{
	local  int     i;
	local  bool    bSilent;

	i = TOST.FindPlayerIndex(Player);

	if (i != -1)
	{
		Admins[i].SAL = CheckPW(Pass);
		if (Admins[i].SAL == 0)
		{
			Admins[i].FailedLogins++;
			NotifyPlayer(1, Player, FailedMsg@"("$Admins[i].FailedLogins$"/"$MaxTry$")");

			if (Admins[i].Failedlogins >= MaxTry)
			{
				// ban him
				Params.Param1 = Player.PlayerReplicationInfo.PlayerID;
				Params.Param4 = BanMsg;
				SendMessage(109);
			}
		} else {
			Admins[i].myPW = Pass; //save password for password-changes
			if (Admins[i].SAL < SilentLogin || CWMode) {
				NotifyRest(0, Player, Player.PlayerReplicationInfo.PlayerName@LoginMsg@Admins[i].SAL);
				NotifyPlayer(1, Player, Player.PlayerReplicationInfo.PlayerName@LoginMsg@Admins[i].SAL);
				XLog(Player.PlayerReplicationInfo.PlayerName@LoginMsg@Admins[i].SAL@"(Index="$InStr(SAPw[Admins[i].SAL], Pass)$")");
				bSilent = false;
			} else {
				NotifyPlayer(1, Player, "You"@LoginMsg@Admins[i].SAL@"silently");
				XLog(Player.PlayerReplicationInfo.PlayerName@LoginMsg@Admins[i].SAL@"silently (Index="$InStr(SAPw[Admins[i].SAL], Pass)$")");
				bSilent = true;
			}

			Params.Param1 = Admins[i].SAL;
			Params.Param5 = bSilent;
			Params.Param6 = Player;
			SendClientMessage(200);
			SendMessage(BaseMessage + 5);
		}
	}
}

function	SALogOut(PlayerPawn Player, optional bool Forced)
{
	local	int		i;
	local	string	Temp;

	i = TOST.FindPlayerIndex(Player);

	if (i != -1 && Admins[i].SAL > 0)
	{
		if (Forced) Temp = ForcedMsg;
		if (Admins[i].SAL < SilentLogin || CWMode) {
            NotifyRest(0, Player, Player.PlayerReplicationInfo.PlayerName@LogoutMsg@Admins[i].SAL@Temp);
            NotifyPlayer(1, Player, Player.PlayerReplicationInfo.PlayerName@LogoutMsg@Admins[i].SAL@Temp);
   		    XLog(Player.PlayerReplicationInfo.PlayerName@LogoutMsg@Admins[i].SAL@Temp);
        } else {
           	NotifyPlayer(1, Player, "You"@LogoutMsg@Admins[i].SAL@"silently"@Temp);
			XLog(Player.PlayerReplicationInfo.PlayerName@LogoutMsg@Admins[i].SAL@"silently"@Temp);
		}

		Admins[i].SAL = 0;

		Params.Param1 = 0;
		Params.Param6 = Player;
		SendClientMessage(200);
		SendMessage(BaseMessage + 5);
	}
}

function SAForceLogOut(PlayerPawn Player, int PID)
{
	local	int			i;
	local	int			PlayerSAL;

	PlayerSAL = Admins[TOST.FindPlayerIndex(Player)].SAL;
	dLog(Player.PlayerReplicationInfo.PlayerName@"("$PlayerSAL$") forced"@PID@"to logout");

	for(i=0; i<32; i++)
	{
		if (TOST.ClientHandler[i] != none && (TOST.ClientHandler[i].MyPlayer.PlayerReplicationInfo.PlayerID == PID || PID == 0))
		{
			SALogout(TOST.ClientHandler[i].MyPlayer, true);
		}
	}
}

function bool   SAaddPW(PlayerPawn Player, int Level, String newpw, bool bsilent)
{
	local String res;
	local int i;
	local bool bFree, ok;
	Level--;

	newpw = ReplaceText(newpw, ";", "");

	if (Level >= 0 && Len(newpw) < minPWLen)
	   res = "Error: The password is too short (min. "$minPWLen$" characters)";
	else if (forceDigit && !hasDigit(newpw))
	   res = "Error: The password has to contain at least one number.";
    else if (Level >= 0 && Level < ArrayCount(SAPw))
	{
		bFree = True;
		for (i=0; i<ArrayCount(SAPw); i++)
			if (InStr(SAPw[i], newpw) != -1) bFree = False;

		if (bFree)
		{
			ok = True;
            if (SAPw[Level]=="") SAPw[Level] = newpw;
			else SAPw[Level] = SAPw[Level] $ ";" $ newpw;
			res = "Successfully added new password \""$newpw$"\" to Level"@(Level+1)$"!";
			SaveConfig();
	    }
	    else res = "Error: Password allready exists!";
	}
	else res = "Error, usage: \"addpw Level Password\", available Levels: 1-"$Arraycount(SAPw)$".";

	if (!bsilent) NotifyPlayer(1, Player, res);
	return ok;
}

function bool   SAdelPW(PlayerPawn Player, String toDel, bool bsilent)
{
	local int Level;
	local String res;
	local bool ok;

	toDel = ReplaceText(toDel, ";", "");
	res = "Error: the given password does not exist!";

	Level = CheckPW(toDel)-1;
	if (Level >= 0)
	{
		ok = True;
		SAPw[Level] = RemovePw(Level, toDel);
    	res = "Level "$(Level+1)$" Password \""$toDel$"\" successfully removed.";
    	SaveConfig();
    }

	if (!bsilent) NotifyPlayer(1, Player, res);
	return ok;
}

function	SApasswd(PlayerPawn Player, String newPass)
{
	local int i;
    local string tmp;

    i = TOST.FindPlayerIndex(Player);

	if (Len(newPass) < minPWLen || (forceDigit && !hasDigit(newPass)))
	{
	   tmp = "Error: the password has to be at least "$minPWLen$" characters long";
	   if (forceDigit) tmp = tmp $ " and contain one number";
       NotifyPlayer(1, Player, tmp);
    } else if (i != -1 && Admins[i].SAL > 0 && Admins[i].myPW != "" )
	{
		//del:
        if (SAdelPW(Player, Admins[i].myPW, True))
        {
          //add:
          if (SAaddPW(Player, Admins[i].SAL, newPass, True))
          {
		      Admins[i].myPW = newPass;
		      NotifyPlayer(1, Player, "Your password is now: \""$newPass$"\".");
		      SaveConfig();
		  }
		  else NotifyPlayer(1, Player, "Error: the password allready exists!");
	    }
	}
}

function	SAhelp(PlayerPawn Player)
{
	local	int	i;

	i = TOST.FindPlayerIndex(Player);

	if (i != -1)
	{
		ExplainPolicy(Player, Admins[i].SAL, False);
	}
}

function int	CheckPW(string Pass)
{
	local String 	s, IniPW;
	local int		i, j;

	for (j=ArrayCount(SAPw)-1; j >= 0; j--)
	{
		IniPw = SAPw[j];

		if (IniPw == "")
			continue;

		while (true)
		{
			i = InStr(IniPW, ";");
			if (i != -1)
			{
				s = Left(IniPW, i);
				IniPW = Mid(IniPW, i+1);
			} else
				s = IniPW;

			if (s == Pass)
				return j+1;

			if (i == -1)
				break;
		}
	}
	return 0;
}

function bool CheckPolicy (int Msg, int Level)
{
	local String 	S;
	local int		i, j, a, bis, b;
	local String 	pol;

	j = Level-1;
	if (j < 0)
		pol = UserPolicy;
	else
		pol = Policy[j];

	while (true)
	{
		i = InStr(Pol, ";");
		if (i != -1)
		{
			S = Left(Pol, i);
			Pol=Mid(Pol, i+1);
		} else
			S = Pol;

		if (S == string(Msg) )
			return true;
		else
			if (InStr(S, "-") != -1)
			{
				bis = InStr(S, "-");
				a = int(Left(S, bis));
				b = int(Mid(S, bis+1));
				if (a <= Msg && Msg <= b)
					return true;
			}

		if (i == -1)
			return false;
	}
}

function bool CheckRWPolicy (int Msg, int Level, bool WriteAccess)
{
	local String 	S;
	local int		i, j, a, bis, b;
	local String 	pol;

	j = Level-1;
	if (WriteAccess)
	{
		if (j < 0)
			pol = UserWritePolicy;
		else
			pol = WritePolicy[j];
	} else {
		if (j < 0)
			pol = UserReadPolicy;
		else
			pol = ReadPolicy[j];
	}

	while (true)
	{
		i = InStr(Pol, ";");
		if (i != -1)
		{
			S = Left(Pol, i);
			Pol=Mid(Pol, i+1);
		} else
			S = Pol;

		if (S == string(Msg) )
			return true;
		else
			if (InStr(S, "-") != -1)
			{
				bis = InStr(S, "-");
				a = int(Left(S, bis));
				b = int(Mid(S, bis+1));
				if (a <= Msg && Msg <= b)
					return true;
			}

		if (i == -1)
			return false;
	}
}

function	ExplainPolicy(PlayerPawn Player, int Level, bool verbose)
{
	local	int	i;

	if (Level == 0)
		NotifyPlayer(2, Player, "Allowed functions for normal users :");
	else
		NotifyPlayer(2, Player, "Allowed functions for level "$Level$" semi admins :");

	Params.Param6 = none;

	TestLevel = Level;
	for (i=100; i<255; i++)
	{
		Params.Param1 = i;
		Params.Param2 = 0;
		if (CheckClearance(none, i))
		{
			Params.Param4 = "";
			SendMessage(BaseMessage+3);
			if (Params.Param4 != "")
				NotifyPlayer(2, Player, "-"@Params.Param4);
		}
	}

	if (verbose)
	{
		if (Level >= SilentLogin)
			NotifyPlayer(2, Player, "- SilentLogin");

		if (CWMode)
			NotifyPlayer(2, Player, "(SilentLogin is disabled - ClanWar Mode)");

		if (Level == 0)
			NotifyPlayer(2, Player, "System read/write access for normal users :");
		else
			NotifyPlayer(2, Player, "System read/write access for level "$Level$" semi admins :");
		for (i=100; i<255; i++)
		{
			Params.Param1 = i;
			if (CheckClearance(none, 120))
			{
				Params.Param1 = 120;
				Params.Param2 = i;
				Params.Param4 = "";
				SendMessage(BaseMessage+3);
				Params.Param1 = i;
				if (CheckClearance(none, 121))
					NotifyPlayer(2, Player, "-"@Params.Param4@"r/w");
				else
					NotifyPlayer(2, Player, "-"@Params.Param4@"r");
			}
		}
	}
	TestLevel = -1;
}

// ** SETTINGS

function	GetSettings(TOSTPiece Sender)
{
}

function	SetSettings(TOSTPiece Sender, string Settings)
{
}

function	GetValue(PlayerPawn	Player, TOSTPiece Sender, int Index)
{
}

function	SetValue(PlayerPawn Player, int Index, int i, float f, string s, bool b)
{
}

// ** EVENT HANDLING

function 		EventPlayerConnect(Pawn Player)
{
	local	int		i;

	i = TOST.FindPlayerIndex(PlayerPawn(Player));
	if (i != 1)
	{
		Admins[i].SAL = 0;
		Admins[i].FailedLogins = 0;
		Admins[i].myPW = "";
	}

	super.EventPlayerConnect(Player);
}

function 		EventPlayerDisconnect(Pawn Player)
{
	local	int		i;

	i = TOST.FindPlayerIndex(PlayerPawn(Player));
	if (i != -1)
	{
		Admins[i].SAL = 0;
		Admins[i].FailedLogins = 0;
		Admins[i].myPW = "";
	}

	super.EventPlayerDisconnect(Player);
}

// ** MESSAGE HANDLING

function bool	EventCheckClearance(TOSTPiece Sender, PlayerPawn Player, int MsgType, out int Allowed)
{
	local 	int 	i;
	local	bool	b;


	b =	super.EventCheckClearance(Sender, Player, MsgType, Allowed);

	if (MsgType == 200 || MsgType == 201 || MsgType == 208 || (MsgType == 204 && Player == None))
	{
		Allowed = 1;
		return true;
	} else {
		if (MsgType == 204)
		{
			i = TOST.FindPlayerIndex(Player);
			if (i != -1)
			{
				Allowed = int((Admins[i].SAL >= Sender.Params.Param1) || Player.PlayerReplicationInfo.bAdmin || Sender.Params.Param1 == 0);
				return true;
			}

		}

        if (MsgType == 209)
		{
			i = TOST.FindPlayerIndex(Player);
			if (i != -1)
			{
				Allowed = int(Admins[i].SAL > 0);
				return true;
			}

		} else {
			if (Player == None)
			{
				if (TestLevel != -1 && !b)
				{
					if (MsgType == 120 || MsgType == 121)
					{
						if (Sender.Params.Param1 == 0)
							Allowed = int(MsgType == 120);
						else
							Allowed = int(CheckRWPolicy(Sender.Params.Param1, TestLevel, (MsgType == 121)));
					} else
						Allowed = int(CheckPolicy(MsgType, TestLevel));
					return true;
				}
			} else {
				i = TOST.FindPlayerIndex(Player);
				if (i != -1 && !Player.PlayerReplicationInfo.bAdmin && !b)
				{
					if (MsgType == 120 || MsgType == 121)
						Allowed = int(CheckRWPolicy(Sender.Params.Param1, Admins[i].SAL, (MsgType == 121)));
					else
						Allowed = int(CheckPolicy(MsgType, Admins[i].SAL));
					return true;
				}
			}
		}
	}

	return b;
}

function	EventMessage(TOSTPiece Sender, int MsgIndex)
{
	switch (MsgIndex)
	{
		// SALogin
		case BaseMessage+0	:	SALogin(Sender.Params.Param6, Sender.Params.Param4);
								break;
		// SALogOut
		case BaseMessage+1	:	SALogOut(Sender.Params.Param6);
								break;

		// GetMessageName
		case BaseMessage+3	:	TranslateMessage(Sender);
								break;
		// PolicyDetails
		case BaseMessage+4	:	ExplainPolicy(Sender.Params.Param6, Sender.Params.Param1, Sender.Params.Param5);
								break;

		// addPW
		case BaseMessage+6	:	SAaddPW(Sender.Params.Param6, Sender.Params.Param1, Sender.Params.Param4, False);
								break;
		// delPW
		case BaseMessage+7	:	SAdelPW(Sender.Params.Param6, Sender.Params.Param4, False);
								break;
		// saHelp
		case BaseMessage+8	:	SAhelp(Sender.Params.Param6);
								break;
		// SApasswd
		case BaseMessage+9	:	SApasswd(Sender.Params.Param6, Sender.Params.Param4);
								break;
		// SAForceLogout
		case BaseMessage+10	:	SAForceLogout(Sender.Params.Param6, Sender.Params.Param1);
								break;

		// CWMode
		case 117			:	CWMode = Sender.Params.Param5;
								break;
		// GetValue
		case 120 			:	GetValue(Sender.Params.Param6, Sender, Sender.Params.Param1);
								break;
		// SetValue
		case 121 			:	SetValue(Sender.Params.Param6, Sender.Params.Param1, Sender.Params.Param2, Sender.Params.Param3, Sender.Params.Param4, Sender.Params.Param5);
								break;
		// GetSettings
		case 143 			:	GetSettings(Sender);
								break;
	}
	super.EventMessage(Sender, MsgIndex);
}

function		EventAnswerMessage(TOSTPiece Sender, int MsgIndex)
{
	switch (MsgIndex)
	{
		// SetSettings - report back error messages
		case 144 			:	SetSettings(Sender, Sender.Params.Param4);
								break;
	}
}

function int GetLevel (PlayerPawn Player)
{
    local int i, level;

    i = TOST.FindPlayerIndex(Player);
    if (i != -1)
        level = Admins[i].SAL;
    else level = 0;

    return level;
}

function string RemovePw(int Level, string Pass)
{
    local string s, IniPW, output;
    local int i;

    IniPW = SApw[Level];
    Level++;

	while (true)
	{
    i = InStr(IniPW, ";");
    	if (i != -1)
		{
		    s = Left(IniPW, i);
			IniPW = Mid(IniPW, i+1);
			if (CheckPW(s)==Level && s!=Pass)
                output = output $ s $ ";";
		} else {
			s = IniPW;
			if (CheckPW(s)==Level && s!=Pass)
                output = output $ s;
			if (i == -1)
                break;
        }
	}
	output = Trim(output, ";");

    return output;
}

function bool   hasDigit(String s)
{
    local string digits;
    local string test;
    local int i;
    local bool bFound;

    digits = "0123456789";

    for (i=0; i<Len(s); i++)
    {
        test = Mid(s, i, 1);
        if (InStr(digits, test) != -1)
        {
            bFound = true;
            break;
        }
    }
    return bFound;
}

// End Helper

defaultproperties
{
	PieceName="TOST SemiAdmin"
	PieceVersion="1.1.5.1"
	ServerOnly=true

	BaseMessage=200

	LoginMsg="logged in as Semi-Administrator Level"
	LogoutMsg="gave up Semi-Administrator Level"
	ForcedMsg="(forced by admin)"
	FailedMsg="Login failed!"
	BanMsg="too many wrong Semi-Admin logins"

	Policy(0)="102;104;112-114" // example for guest Account with lowest priviliges
	Policy(1)="102-114;151;153" // example for a normal Clan-member
	Policy(2)="100-199;206-207" // example for a Clan-Admin/Leader, all rights
	Policy(3)="100-199;206-207" // example for a Clan-Admin/Leader, all rights + (SILENT login, see "SilentLogin=")

	ReadPolicy(0)=""
	ReadPolicy(1)="102-126"
	ReadPolicy(2)="102-126"
	ReadPolicy(3)="102-126"

	WritePolicy(0)=""
	WritePolicy(1)="101-103;105;110-116;126"
	WritePolicy(2)="101-103;105;110-116;126"
	WritePolicy(3)="101-103;105;110-116;126"

	UserPolicy=""
	UserReadPolicy=""
	UserWritePolicy=""

	SilentLogin=4

	MaxTry=5

    minPWLen=6
    forceDigit=false

	TestLevel=-1
}
