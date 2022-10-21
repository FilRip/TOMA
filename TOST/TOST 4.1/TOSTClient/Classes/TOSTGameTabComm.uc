//----------------------------------------------------------------------------
// Project : TOST
// File    : TOSTGameTabComm.uc
// Version : 1.0
// Author  : BugBunny
//----------------------------------------------------------------------------
// Version	Changes
// 0.5		+ first release
// 0.6		+ first beta release
// 1.0		+ first public release
//----------------------------------------------------------------------------

class TOSTGameTabComm extends TOSTClientPiece;

simulated function	EventInit()
{
	super.EventInit();
}

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
	}
}

simulated function	EventMessage(int MsgIndex)
{
	switch (MsgIndex) {
		case BaseMessage+0 	:	AcceptInfo(Handler.Params.Param1, Handler.Params.Param2,  Handler.Params.Param3,  Handler.Params.Param4,  Handler.Params.Param5);
								break;
	}
	super.EventMessage(MsgIndex);
}

defaultproperties
{
	bHidden=true

	BaseMessage=100
}

