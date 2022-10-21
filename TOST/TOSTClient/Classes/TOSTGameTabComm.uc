// $Id: TOSTGameTabComm.uc 487 2004-03-07 14:29:51Z dildog $
//----------------------------------------------------------------------------
// Project : TOST
// File    : TOSTGameTabComm.uc
// Version : 1.0
// Author  : BugBunny
//----------------------------------------------------------------------------

class TOSTGameTabComm extends TOSTClientPiece;

enum BanType
{
	B_None,
	B_GlobalBan,
	B_PermBan,
	B_TimedBan,
	B_TempBan
};

struct BanStruct
{
	var		int		ValidTil;
	var		int		TimeStamp;
	var		string	VictimIp;
	var		string	VictimName;
	var		string	AdminIP;
	var		string	AdminName;
	var		string	Reason;
};

var string RecieveBuffer;

//----------------------------------------------------------------------------
// Main functions
//----------------------------------------------------------------------------
simulated function	SetSettingsDesc(string Desc)
{
	local	int		i, j;

	j = 0;
	Desc = Mid(Desc, 1); // remove the first *
	i = InStr(Desc, "*");
	while (i != -1)
	{
		TOSTGUIGameTab(MasterTab).EditSettings[j++].SetValue(Left(Desc, i));
		Desc = Right(Desc, Len(Desc) - i - 1);
		i = InStr(Desc, "*");
	}
	TOSTGUIGameTab(MasterTab).EditSettings[j].SetValue(Desc);
}

simulated function	SetGameTypes(string Desc)
{
	local	int		i;
	local	string	Temp;

	Desc = Mid(Desc, 1); // remove the first *
	class'TOSTPiece'.static.SplitStr(Desc, "*", Temp, Desc);

	for (i=0;i<10;i++)
	{
		if (Temp == "")
			TOSTGUIGameTab(MasterTab).ButtonChange[i].HideWindow();
		else
			TOSTGUIGameTab(MasterTab).ButtonChange[i].ShowWindow();
		TOSTGUIGameTab(MasterTab).LabelGameType[i].Text = Temp;
		class'TOSTPiece'.static.SplitStr(Desc, "*", Temp, Desc);
	}
}

simulated function	SetCurrentGameType(int GameType)
{
	local	int	i;

	for (i=0; i<10; i++)
	{
		TOSTGUIGameTab(MasterTab).LabelGameType[i].bBackground = (i==GameType);
	}
}

simulated function	UpdateBanList(int Action, string List)
{
	local int		i, j, Position;
	local string	temp;

	// Start of transfer (Clear Buffer)
	if (Action == 1)
	{
		RecieveBuffer = List;
	}
	// Add data
	else if (Action == 2)
	{
		RecieveBuffer = RecieveBuffer $ List;
	}
	// End of transfer (update list)
	else if (Action == 3)
	{
		RecieveBuffer = RecieveBuffer $ List;

		Position = TOSTGUIGameTab(MasterTab).BoxBanList.TopIndex;
		TOSTGUIGameTab(MasterTab).BoxBanList.Clear();

		i = InStr(RecieveBuffer, "\\*");
		while (i != -1)
		{
			j = int(Left(RecieveBuffer, i));
			RecieveBuffer = Mid(RecieveBuffer, i + 2);
			i = InStr(RecieveBuffer, "\\*");

			temp = Left(RecieveBuffer, i);
			RecieveBuffer = Mid(RecieveBuffer, i + 2);
			i = InStr(RecieveBuffer, "\\*");

			TOSTGUIGameTab(MasterTab).BoxBanList.AddItem(temp, "", j, (j == TOSTGUIGameTab(MasterTab).CurrentBanIndex));
		}
		TOSTGUIGameTab(MasterTab).BoxBanList.TopIndex = Position;
	}
}

simulated function	UpdateBanDetails(int Index, string Details)
{
	local BanStruct	BanDetails;

	BanDetails = ParseBanDetails(Details);
	if (Type(BanDetails) > B_GlobalBan)
	{
		switch (Type(BanDetails))
		{
			case B_TempBan	:	TOSTGUIGameTab(MasterTab).CurrentBanText = "";
								TOSTGUIGameTab(MasterTab).CurrentBanTimeStamp = 0;
								TOSTGUIGameTab(MasterTab).CurrentBanType = 1;
								break;
			case B_PermBan	:	TOSTGUIGameTab(MasterTab).CurrentBanText = "";
								TOSTGUIGameTab(MasterTab).CurrentBanTimeStamp = 0;
								TOSTGUIGameTab(MasterTab).CurrentBanType = 5;
								break;
			case B_TimedBan	:	TOSTGUIGameTab(MasterTab).CurrentBanText = ResolveTimeStamp(BanDetails.ValidTil);
								TOSTGUIGameTab(MasterTab).CurrentBanTimeStamp = BanDetails.TimeStamp;
								TOSTGUIGameTab(MasterTab).CurrentBanType = 0;
								break;
		}
		TOSTGUIGameTab(MasterTab).GetBanDuration();
		TOSTGUIGameTab(MasterTab).CurrentBanIndex = Index;

	 	TOSTGUIGameTab(MasterTab).EditBanTimeStamp.SetValue(ResolveTimeStamp(BanDetails.TimeStamp));
	 	TOSTGUIGameTab(MasterTab).EditAdminIP.SetValue(BanDetails.AdminIP);
	 	TOSTGUIGameTab(MasterTab).EditAdminName.SetValue(BanDetails.AdminName);
	 	TOSTGUIGameTab(MasterTab).EditVictimIP.SetValue(BanDetails.VictimIp);
	 	TOSTGUIGameTab(MasterTab).EditVictimName.SetValue(BanDetails.VictimName);
	 	TOSTGUIGameTab(MasterTab).EditReason.SetValue(BanDetails.Reason);

	 	TOSTGUIGameTab(MasterTab).EditVictimIP.SetEditable(False);
	 	TOSTGUIGameTab(MasterTab).EditVictimName.SetEditable(False);
	 	TOSTGUIGameTab(MasterTab).ButtonBanSave.Text = "Update";
	}
	else
	{
		TOSTGUIGameTab(MasterTab).ClearBanDetails();
	}
}

//----------------------------------------------------------------------------
// Misc helper functions
//----------------------------------------------------------------------------
function BanStruct ParseBanDetails(string Entry)
{
	local BanStruct	TempDetails;
	local string	Char, Temp;
	local int		CurrentField, i;

	CurrentField=0;
	Temp="";
	for(i=0;i<Len(Entry);i++)
	{
		Char = Mid(Entry,i,1);

		// Handle Special Chars
		if(Char == "\\")
		{
			Char = Mid(Entry,++i,1);
			if(Char == "*")
			{
				// Store current field
				switch (CurrentField++)
				{
					case 0	:	TempDetails.TimeStamp	= int(Temp);
								break;
					case 1	:	TempDetails.ValidTil	= int(Temp);
								break;
					case 2	:	TempDetails.VictimIp	= Temp;
								break;
					case 3	:	TempDetails.VictimName	= Temp;
								break;
					case 4	:	TempDetails.AdminIP		= Temp;
								break;
					case 5	:	TempDetails.AdminName	= Temp;
								break;
					case 6	:	TempDetails.Reason		= Temp;
								break;
				}
				Temp = "";
				continue;
			}
		}
		Temp = Temp $ Char;
	}
	return TempDetails;
}

function BanType Type(BanStruct TempDetails)
{
	if (TempDetails.VictimIP == "")
	 	return B_None;
	else if (TempDetails.ValidTil == -2)
		return B_TempBan;
	else if (TempDetails.ValidTil == -1)
		return B_GlobalBan;
	else if (TempDetails.ValidTil == 0)
		return B_PermBan;
 	else if (TempDetails.ValidTil > 0)
		return B_TimedBan;

	return B_None;
}

final function	string	ResolveTimeStamp(coerce int TimeStamp, optional string Format)
{
	local	int		i;

	if (Format == "")
		Format = "%YYYY-%MM-%DD %HH:%MI";

	// Year
	i = (TimeStamp >> 20);
	Format = ReplaceText(Format, "%YYYY",	PrePad(i));
	Format = ReplaceText(Format, "%YY",	Mid(i,2,2));

	// Month
	i = ((TimeStamp >> 16) & 15);
	Format = ReplaceText(Format, "%MM",	PrePad(i));

	// Day
	i = ((TimeStamp >> 11) & 31);
	Format = ReplaceText(Format, "%DD",	PrePad(i));

	// Hour
	i = ((TimeStamp >> 6) & 31);
	Format = ReplaceText(Format, "%HH",	PrePad(i));

	// Minute
	i = (TimeStamp & 63);
	Format = ReplaceText(Format, "%MI",	PrePad(i));

	return Format;
}

static final function string	ReplaceText(coerce string Text, coerce string Replace, coerce string With)
{
    local	int		i;
    local	string	Output;

    i = InStr(Text, Replace);
    while (i != -1) {
        Output = Output $ Left(Text, i) $ With;
        Text = Mid(Text, i + Len(Replace));
        i = InStr(Text, Replace);
    }
    Output = Output $ Text;
    return Output;
}

static final function string PrePad(coerce string s, optional int Size, optional string Pad)
{
	if (Size == 0) Size = 2;
	if (Pad == "") Pad = "0";
	while (Len(s) < Size) s = Pad$s;
	return s;
}

//----------------------------------------------------------------------------
// TOST event Handling
//----------------------------------------------------------------------------
simulated function	AcceptInfo(int Index, int i, float f, string s, bool b)
{
	switch (Index)
	{
		// Rules Page
		case 100 :	TOSTGUIGameTab(MasterTab).EditAdminPwd.SetValue(s);
					break;
		case 101 :	TOSTGUIGameTab(MasterTab).EditGamePwd.SetValue(s);
					break;
		case 102 :	TOSTGUIGameTab(MasterTab).UpDownMapTime.Value = i;
					break;
		case 103 :	TOSTGUIGameTab(MasterTab).UpDownRoundTime.Value = i;
					break;
		case 104 :	TOSTGUIGameTab(MasterTab).CheckBoxBallistics.bChecked = b;
					break;
		case 105 :	TOSTGUIGameTab(MasterTab).CheckBoxGhostCam.bChecked = b;
					break;
		case 106 :	TOSTGUIGameTab(MasterTab).CheckBoxPunishTK.bChecked = b;
					break;
		case 107 :	TOSTGUIGameTab(MasterTab).CheckBoxEnhVote.bChecked = b;
					break;
		case 108 :	TOSTGUIGameTab(MasterTab).CheckBoxAutoMkTeams.bChecked = b;
					break;
		case 109 :	TOSTGUIGameTab(MasterTab).CheckBoxPlayerBackup.bChecked = b;
					break;
		case 125 :	TOSTGUIGameTab(MasterTab).CheckBoxCWMode.bChecked = b;
					break;
		case 126 :	TOSTGUIGameTab(MasterTab).UpDownRoundLimit.Value = i;
					break;
		case 127 :	TOSTGUIGameTab(MasterTab).CheckBoxBehindView.bChecked = b;
					break;
		// X Settings Page
		case 140 :	TOSTGUIGameTab(MasterTab).EditSlotPwd.SetValue(s);
					break;
		case 141 :	TOSTGUIGameTab(MasterTab).UpDownNumberSlot.Value = i;
					break;
		case 142 :	TOSTGUIGameTab(MasterTab).UpDownPreRound.Value = i;
					break;
		case 143 :	TOSTGUIGameTab(MasterTab).UpDownMaxWarnings.Value = i;
					break;
		case 144 :	TOSTGUIGameTab(MasterTab).EditTag.SetValue(s);
					break;
		case 145 :	TOSTGUIGameTab(MasterTab).CheckBoxMakeClanTeams.bChecked = b;
					break;
		case 170 :	TOSTGUIGameTab(MasterTab).CheckBoxEnableTOP.bChecked = (i > 0);
					TOSTGUIGameTab(MasterTab).CheckBoxForceTOP.bChecked = (i > 1);
					break;
		case 171 :	TOSTGUIGameTab(MasterTab).CheckBoxWarPix.bChecked = b;
					break;
		case 190 :	TOSTGUIGameTab(MasterTab).CheckBoxHitParade.bChecked = b;
					break;
		case 200 :	TOSTGUIGameTab(MasterTab).CheckBoxAnnouncer.bChecked = b;
					break;
		// Damage Page
		case 110 :	TOSTGUIGameTab(MasterTab).UpDownFFScale.Value = i;
					break;
		case 111 :	TOSTGUIGameTab(MasterTab).CheckBoxExplosionFF.bChecked = b;
					break;
		case 112 :	TOSTGUIGameTab(MasterTab).CheckBoxMirrorDmg.bChecked = b;
					break;
		case 113 :	TOSTGUIGameTab(MasterTab).CheckBoxTKHandling.bChecked = b;
					break;
		case 114 :	TOSTGUIGameTab(MasterTab).UpDownMaxTK.Value = i;
					break;
		case 115 :	TOSTGUIGameTab(MasterTab).UpDownMinAllowedScore.Value = i;
					break;
		case 116 :	TOSTGUIGameTab(MasterTab).CheckBoxHPMessage.bChecked = b;
					break;
		// Map Page
		case 117 :	TOSTGUIGameTab(MasterTab).CheckBoxNextMap.bChecked = b;
					break;
		case 118 :	TOSTGUIGameTab(MasterTab).CheckBoxMapVote.bChecked = b;
					break;
		case 119 :	TOSTGUIGameTab(MasterTab).UpDownMVPercInGame.Value = i;
					break;
		case 120 :	TOSTGUIGameTab(MasterTab).UpDownMVPercMapEnd.Value = i;
					break;
		case 122 :	TOSTGUIGameTab(MasterTab).UpDownMVTime.Value = i;
					break;
		case 123 :	TOSTGUIGameTab(MasterTab).UpDownMVNoReplay.Value = i;
					break;
		case 121 :	TOSTGUIGameTab(MasterTab).MVMode = i;
					if (i==0)
						TOSTGUIGameTab(MasterTab).LabelMVMode.Text = "all maps";
					else
						TOSTGUIGameTab(MasterTab).LabelMVMode.Text = "map cycle only";
					break;
		// Settings Page
		case 124 :	SetSettingsDesc(s);
					break;
		// GameType Page
		case 128 :	SetGameTypes(s);
					break;
		case 129 :	SetCurrentGameType(i);
					break;
	}
}

simulated function	EventMessage(int MsgIndex)
{
	switch (MsgIndex) {
		case BaseMessage+0 	:	AcceptInfo(Handler.Params.Param1, Handler.Params.Param2,  Handler.Params.Param3,  Handler.Params.Param4,  Handler.Params.Param5);
								break;
		case 221			:	if (TOSTGUIGameTab(MasterTab).CurrentPage == 5) SendMessage(180);
								break;
		case 222			:	UpdateBanList(Handler.Params.Param1, Handler.Params.Param4);
								break;
		case 223			:	UpdateBanDetails(Handler.Params.Param1, Handler.Params.Param4);
								break;
	}
	super.EventMessage(MsgIndex);
}

//----------------------------------------------------------------------------
// defaultproperties
//----------------------------------------------------------------------------
defaultproperties
{
	bHidden=true

	BaseMessage=100
}
