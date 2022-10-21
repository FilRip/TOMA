//----------------------------------------------------------------------------
// Project : TOST
// File    : TOSTSettings.uc
// Version : 1.1
// Author  : BugBunny
//----------------------------------------------------------------------------
// Version	Changes
// 0.5		+ first release
// 0.6		+ first beta release
// 1.0		+ first public release
// 1.1		# adjusted to TO 340
//----------------------------------------------------------------------------

class TOSTSettings expands TOSTPiece config;

var string			CurrentSetting;
var PlayerPawn		SettingMaster;

var config	string	Description[10];
var config	string	Settings[10];
var config	string	Password[10];

function		SaveSettings(PlayerPawn Player, int Index, string Desc)
{
	if (Index < 0 || Index > ArrayCount(Description) - 1)
	{
		NotifyPlayer(1, Player, "Invalid index "$Index$" (allowed : 0-"$(ArrayCount(Description)-1)$"). No settings saved.");
		return;
	}

	if (Desc == "")
		Description[Index] = "Unknown Set #"$Index;
	else
		Description[Index] = Desc;

	// collect settings
	CurrentSetting = "";
	SendMessage(BaseMessage+3);
	Settings[Index] = CurrentSetting;
	Password[Index] = Level.Game.ConsoleCommand("get Engine.GameInfo GamePassword");

	SaveConfig();

	NotifyPlayer(1, Player, "Settings saved. (Index"@Index$", Description '"$Description[Index]$"')");
}

function		LoadSettings(PlayerPawn Player, int Index, string Pass, bool NewPass)
{
	local	int			i, j;
	local	string		Piece;
	local	TOSTPiece	P;

	if (Index < 0 || Index > ArrayCount(Description) - 1)
	{
		NotifyPlayer(1, Player, "Invalid index "$Index$" (allowed : 0-"$(ArrayCount(Description)-1)$"). No settings loaded.");
		return;
	}

	SettingMaster = Player;

	CurrentSetting = Settings[Index];
	while (CurrentSetting != "")
	{
		i = InStr(CurrentSetting, "*");
		j = InStr(CurrentSetting, "=");
		if (i != -1)
		{
			CurrentSetting = Mid(CurrentSetting, 1);
			i = InStr(CurrentSetting, "*");
			Piece = Left(CurrentSetting, j-1);
			if (i == -1)
			{
				Params.Param4 = Mid(CurrentSetting, j);
				CurrentSetting = "";
			} else {
				Params.Param4 = Mid(CurrentSetting, j, i-j);
				CurrentSetting = Mid(CurrentSetting, i);
			}

			P = TOST.GetPieceByName(Piece);
			if (P != none)
				SendAnswerMessage(P, BaseMessage+4);
		}
	}

	Params.Param1 = 101;
	if (NewPass && CheckClearance(Player, 121))
	{
		Params.Param4 = Pass;
		Params.Param6 = Player;
    	SendMessage(121);
	} else {
		Params.Param4 = Password[Index];
		Params.Param6 = Player;
    	SendMessage(121);
	}

	NotifyPlayer(1, Player, "Settings '"$Description[Index]$"' loaded.");
	NotifyRest(1, Player, "Server settings have changed.");
}

function		ListSettings(PlayerPawn Player, TOSTPiece Sender)
{
	local	string	s;
	local	int		i;

	for (i=0; i<ArrayCount(Description); i++)
		s = s$"*"$Description[i];

	Params.Param1 = 124;
	Params.Param4 = s;
	if (Player != none)
	{
		Params.Param6 = Player;
		SendClientMessage(100);
	} else {
		SendAnswerMessage(Sender, 120);
	}
}

function		GetSettings(TOSTPiece Sender)
{
	local	int			Bits, Bits2, i;
	local	s_SWATGame	SG;

	SG = s_SWATGame(Level.Game);

	Bits = 0;
	if (SG.bPlayersBalanceTeams)
		Bits += 1;
	if (SG.bBalanceTeams)
		Bits += 2;
	if (SG.bDisableRealDamages)
		Bits += 4;
	if (SG.bExplosionFF)
		Bits += 8;
	if (SG.bAllowGhostCam)
		Bits += 16;
	if (SG.bMirrorDamage)
		Bits += 32;
	if (SG.bEnableBallistics)
		Bits += 64;
	if (SG.bAllowPunishTK)
		Bits += 128;
	Bits2 = 0;
	if (SG.bAllowBehindView)
		Bits2 += 1;

	Params.Param4 = ((SG.TimeLimit & 0xFFFF) << 16) + ((SG.RoundLimit & 0xFF) << 8) + (SG.RoundDuration & 0xFF)$";"$
					((SG.PreRoundDuration1 & 0xFF) << 24) + ((SG.MaxSpectators & 0xFF) << 16) + ((Bits & 0xFF) << 8) + (Bits2 & 0xFF)$";"$
    				SG.FriendlyFireScale;
    for (i=0; i<10; i++)
    	Params.Param4 = Params.Param4$";"$TOST.SA.Mutators[i];
	SendAnswerMessage(Sender, BaseMessage+3);
}

function		SetSettings(TOSTPiece Sender, string Settings)
{
	local	int			i, j;
	local	string		s;
	local	s_SWATGame	SG;
	local	s_GameReplicationInfo	GRI;

	SG = s_SWATGame(Level.Game);
	GRI = s_GameReplicationInfo(SG.GameReplicationInfo);

	s = Settings;

	if (s != "")
	{
		j = InStr(s, ";");
		if (j != -1)
		{
			i = int(Left(s, j));
			s = Mid(s, j+1);
		} else {
			i = int(s);
			s = "";
		}

		SG.TimeLimit = ((i >> 16) & 0xFFFF);
		GRI.TimeLimit = SG.TimeLimit;
		SG.RoundLimit = ((i >> 8) & 0xFF);
		SG.RoundDuration = i & 0xFF;
		GRI.RoundDuration = SG.RoundDuration;

		if (s != "")
		{
			j = InStr(s, ";");
			if (j != -1)
			{
				i = int(Left(s, j));
				s = Mid(s, j+1);
			} else {
				i = int(s);
				s = "";
			}

			SG.PreRoundDuration1 = ((i >> 24) & 0xFF);
			SG.MaxSpectators = ((i >> 16) & 0xFF);

	 		SG.bAllowBehindView = ((i & 1) == 1);

			i = (i >> 8) & 0xFF;

			SG.bPlayersBalanceTeams = ((i & 1) == 1);
			SG.bBalanceTeams = ((i & 2) == 2);
			SG.bDisableRealDamages = ((i & 4) == 4);
			SG.bExplosionFF = ((i & 8) == 8);
			SG.bAllowGhostCam = ((i & 16) == 16);
			SG.bMirrorDamage = ((i & 32) == 32);
			SG.bEnableBallistics = ((i & 64) == 64);
			SG.bAllowPunishTK = ((i & 128) == 128);

			GRI.bMirrorDamage = SG.bMirrorDamage;
			GRI.bAllowGhostCam = SG.bAllowGhostCam;
			GRI.bEnableBallistics = SG.bEnableBallistics;

			if (s != "")
			{
				j = InStr(s, ";");
				if (j != -1)
				{
					SG.FriendlyFireScale = float(Left(s, j));
					s = Mid(s, j+1);
				} else {
					SG.FriendlyFireScale = float(s);
					s = "";
				}
				GRI.friendlyfirescale = int(SG.FriendlyFireScale*100);

                i = 0;
				while (s != "")
				{
					j = InStr(s, ";");
					if (j != -1)
					{
						TOST.SA.Mutators[i] = Left(s, j);
						s = Mid(s, j+1);
					} else {
						TOST.SA.Mutators[i] = s;
						s = "";
					}
					i++;
				}
				TOST.SA.SaveConfig();
			}
		}
	}
	SG.SaveConfig();
}

function	GetValue(PlayerPawn	Player, TOSTPiece Sender, int Index)
{
	if (Index == 124)
		ListSettings(Player, Sender);
}

function	SetValue(PlayerPawn Player, int Index, int i, float f, string s, bool b)
{
}

// Event Handling

function		EventMessage(TOSTPiece Sender, int MsgIndex)
{
	switch (MsgIndex)
	{
		// SaveSettings
		case BaseMessage+0 :	SaveSettings(Sender.Params.Param6, Sender.Params.Param1, Sender.Params.Param4);
								break;
		// LoadSettings
		case BaseMessage+1 :	LoadSettings(Sender.Params.Param6, Sender.Params.Param1, Sender.Params.Param4, Sender.Params.Param5);
								break;
		// GetSettings
		case BaseMessage+3 :	GetSettings(Sender);
								break;
		// GetValue
		case 120 			:	GetValue(Sender.Params.Param6, Sender, Sender.Params.Param1);
								break;
		// SetValue
		case 121 			:	SetValue(Sender.Params.Param6, Sender.Params.Param1, Sender.Params.Param2, Sender.Params.Param3, Sender.Params.Param4, Sender.Params.Param5);
								break;
		// GetMessageName
		case 203			:	TranslateMessage(Sender);
								break;
	}
	super.EventMessage(Sender, MsgIndex);
}

function		EventAnswerMessage(TOSTPiece Sender, int MsgIndex)
{
	switch (MsgIndex)
	{
		// GetSettings - add to setting string
		case BaseMessage+3 :	CurrentSetting = CurrentSetting$"*"$Sender.PieceName$"="$Sender.Params.Param4;
								break;
		// SetSettings - report back error messages
		case BaseMessage+4 :	if (SettingMaster != none && Sender != self)
									NotifyPlayer(1, SettingMaster, Sender.PieceName$":"@Sender.Params.Param4);
								else
									SetSettings(Sender, Sender.Params.Param4);
								break;
	}
}

function	TranslateMessage(TOSTPiece Sender)
{
	switch (Sender.Params.Param1)
	{
		case BaseMessage+0  : Sender.Params.Param4 = "SaveSettings"; break;
		case BaseMessage+1  : Sender.Params.Param4 = "LoadSettings"; break;

		default : break;
	}
}

defaultproperties
{
	bHidden=True

	PieceName="TOST Settings"
	PieceVersion="1.1.0.0"
	ServerOnly=true

	BaseMessage=140

	Description(0)=""
	Settings(0)=""
	Description(1)=""
	Settings(1)=""
	Description(2)=""
	Settings(2)=""
	Description(3)=""
	Settings(3)=""
	Description(4)=""
	Settings(4)=""
	Description(5)=""
	Settings(5)=""
	Description(6)=""
	Settings(6)=""
	Description(7)=""
	Settings(7)=""
	Description(8)=""
	Settings(8)=""
	Description(9)=""
	Settings(9)=""
}


