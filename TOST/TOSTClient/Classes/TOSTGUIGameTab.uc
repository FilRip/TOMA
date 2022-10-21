// $Id: TOSTGUIGameTab.uc 487 2004-03-07 14:29:51Z dildog $
//----------------------------------------------------------------------------
// Project : TOST
// File    : TOSTGUIGameTab.uc
// Version : 4.1
// Author  : BugBunny
//----------------------------------------------------------------------------

class TOSTGUIGameTab extends TOSTGUIBaseTab;

var localized string		TextGameTitle;

var localized string		TextAdminWarning;

var localized string		TextHintDefault, TextHintDefaultAlt;

var localized string		TextButtonClose, TextHintCloseButton;
var localized string		TextButtonAdminTab, TextHintAdminTabButton;

var localized string		TextHintNextPageButton, TextHintPrevPageButton;

var localized string		TextHintBallistics, TextHintGhostcam, TextHintPunishTK, TextHintBehindView,
							TextHintRoundTime, TextHintMapTime, TextHintRoundLimit,
							TextHintAdminPwd, TextHintGamePwd,
							TextHintEnhVote, TextHintAutoMkTeams, TextHintPlayerBackup, TextHintCWMode;

var localized string		TextHintSlotPwd, TextHintTag, TextHintPreRound, TextHintNumberSlot, TextHintMaxWarnings,
							TextHintMakeClanTeams, TextHintAnnouncer, TextHintHitparade, TextHintEnableTOP, TextHintWarPix;

var localized string		TextHintExplosionFF, TextHintMirrorDmg, TextHintTKHandling, TextHintHPMessage,
							TextHintFFScale, TextHintMaxTK, TextHintMinAllowedScore;

var localized string		TextHintNextMap, TextHintMapVote,
							TextHintMVPercInGame, TextHintMVPercMapEnd, TextHintMVTime, TextHintMVNoReplay, TextHintMVMode;

var localized string		TextHintLoadSettings, TextHintSaveSettings;

var localized string		TextHintGameTypeChange;

var localized string        TextHintBanList, TextHintBanSearch, TextHintBanSave, TextHintBanRemove;


var TOSTGUIBaseButton		ButtonClose, ButtonAdminTab;
var TOSTGUIBaseButton		ButtonPrevPage, ButtonNextPage;
var TOSTGUILabel			LabelPage;

// Rules Page

var TOSTGUIEditControl		EditAdminPwd, EditGamePwd;
var TOSTGUIBaseButton		ButtonSetAdminPwd, ButtonSetGamePwd;
var TOSTGUICheckBox			CheckBoxGhostcam, CheckBoxBallistics, CheckBoxPlayerBackup, CheckBoxPunishTK,
							CheckBoxEnhVote, CheckBoxAutoMkTeams, CheckBoxCWMode, CheckBoxBehindView;
var TOSTGUIBaseUpdown		UpDownMapTime, UpDownRoundTime, UpDownRoundLimit;

// X Settings page

var TOSTGUIEditControl		EditSlotPwd, EditTag;
var TOSTGUIBaseButton		ButtonSetSlotPwd, ButtonSetTag;
var TOSTGUICheckBox			CheckBoxMakeClanTeams, CheckBoxHitParade;
var TOSTGUICheckBox			CheckBoxAnnouncer, CheckBoxEnableTOP;
var TOSTGUICheckBox			CheckBoxForceTOP, CheckBoxWarpix;
var TOSTGUIBaseUpdown		UpDownPreRound, UpDownNumberSlot, UpDownMaxWarnings;

// Damage Page

var TOSTGUICheckBox			CheckBoxExplosionFF, CheckBoxMirrorDmg, CheckBoxTKHandling, CheckBoxHPMessage;
var TOSTGUIBaseUpdown		UpDownFFScale, UpDownMaxTK, UpDownMinAllowedScore;

// Map Page

var TOSTGUICheckBox			CheckBoxNextMap, CheckBoxMapVote;
var TOSTGUIBaseUpdown		UpDownMVPercInGame, UpDownMVPercMapEnd, UpDownMVTime, UpDownMVNoReplay;
var TOSTGUIBaseButton		ButtonMVPrevMode, ButtonMVNextMode;
var TOSTGUILabel			LabelMVMode;

var int						MVMode;

// Settings Page

var TOSTGUIEditControl		EditSettings[10];
var TOSTGUIBaseButton		ButtonSave[10], ButtonLoad[10];

// GameType Page

var TOSTGUILabel			LabelGameType[10];
var TOSTGUIBaseButton		ButtonChange[10];

// BanList Page

var TOSTGUITextListbox      BoxBanList;

var TOSTGUIEditControl		EditBanTimeStamp;
var TOSTGUIEditControl		EditAdminIP, EditAdminName;
var TOSTGUIEditControl		EditVictimIP, EditVictimName;
var TOSTGUIEditControl		EditReason, EditBanSearch;

var TOSTGUIBaseButton		ButtonBanPrevDuration, ButtonBanNextDuration;
var TOSTGUILabel			LabelBanDuration;

var TOSTGUIBaseButton		ButtonBanSearch;
var TOSTGUIBaseButton		ButtonBanSave, ButtonBanRemove;

var	string					CurrentBanText;
var	int						CurrentBanTimeStamp;
var	int						CurrentBanType;
var	int						CurrentBanIndex;

// SemiAdmin Page


var float					AdminWarning, AdminWarnStep;

var int						CurrentPage, MaxPages;

simulated function Created ()
{
	local	int		i;

	Super.Created();

	Title = TextGameTitle;

	ButtonClose = TOSTGUIBaseButton(CreateWindow(class'TOSTGUIBaseButton', 0, 0, WinWidth, WinHeight));
	ButtonClose.Text = TextButtonClose;
	ButtonClose.OwnerTab = self;

	ButtonAdminTab = TOSTGUIBaseButton(CreateWindow(class'TOSTGUIBaseButton', 0, 0, WinWidth, WinHeight));
	ButtonAdminTab.Text = TextButtonAdminTab;
	ButtonAdminTab.OwnerTab = self;

	ButtonPrevPage = TOSTGUIBaseButton(CreateWindow(class'TOSTGUIBaseButton', 0, 0, WinWidth, WinHeight));
	ButtonPrevPage.Text = "<";
	ButtonPrevPage.OwnerTab = self;

	ButtonNextPage = TOSTGUIBaseButton(CreateWindow(class'TOSTGUIBaseButton', 0, 0, WinWidth, WinHeight));
	ButtonNextPage.Text = ">";
	ButtonNextPage.OwnerTab = self;

	LabelPage = TOSTGUILabel(CreateWindow(class'TOSTGUILabel', 0, 0, WinWidth, WinHeight));
	LabelPage.OwnerTab = self;

	// Rules Page

	EditAdminPwd = TOSTGUIEditControl(CreateControl(Class'TOSTGUIEditControl', 0, 0, WinWidth, WinHeight));
	EditAdminPwd.Label = "Admin Password";
	EditAdminPwd.OwnerTab = self;
	EditAdminPwd.SetValue("");
	EditAdminPwd.SetNumericOnly(False);
	EditAdminPwd.SetMaxLength(60);
	EditAdminPwd.SetDelayedNotify(True);

	ButtonSetAdminPwd = TOSTGUIBaseButton(CreateWindow(class'TOSTGUIBaseButton', 0, 0, WinWidth, WinHeight));
	ButtonSetAdminPwd.Text = "Set";
	ButtonSetAdminPwd.OwnerTab = self;

	EditGamePwd = TOSTGUIEditControl(CreateControl(Class'TOSTGUIEditControl', 0, 0, WinWidth, WinHeight));
	EditGamePwd.Label = "Game Password";
	EditGamePwd.OwnerTab = self;
	EditGamePwd.SetValue("");
	EditGamePwd.SetNumericOnly(False);
	EditGamePwd.SetMaxLength(60);
	EditGamePwd.SetDelayedNotify(True);

	ButtonSetGamePwd = TOSTGUIBaseButton(CreateWindow(class'TOSTGUIBaseButton', 0, 0, WinWidth, WinHeight));
	ButtonSetGamePwd.Text = "Set";
	ButtonSetGamePwd.OwnerTab = self;

	CheckBoxGhostcam = TOSTGUICheckBox(CreateWindow(class'TOSTGUICheckBox', 0, 0, WinWidth, WinHeight));
	CheckBoxGhostcam.OwnerTab = self;
	CheckBoxGhostcam.Text = "Ghostcam";

	CheckBoxBallistics = TOSTGUICheckBox(CreateWindow(class'TOSTGUICheckBox', 0, 0, WinWidth, WinHeight));
	CheckBoxBallistics.OwnerTab = self;
	CheckBoxBallistics.Text = "Ballistics";

	CheckBoxPlayerBackup = TOSTGUICheckBox(CreateWindow(class'TOSTGUICheckBox', 0, 0, WinWidth, WinHeight));
	CheckBoxPlayerBackup.OwnerTab = self;
	CheckBoxPlayerBackup.Text = "TOST Player Backup";

	CheckBoxEnhVote = TOSTGUICheckBox(CreateWindow(class'TOSTGUICheckBox', 0, 0, WinWidth, WinHeight));
	CheckBoxEnhVote.OwnerTab = self;
	CheckBoxEnhVote.Text = "TOST Vote Enhancement";

	CheckBoxPunishTK = TOSTGUICheckBox(CreateWindow(class'TOSTGUICheckBox', 0, 0, WinWidth, WinHeight));
	CheckBoxPunishTK.OwnerTab = self;
	CheckBoxPunishTK.Text = "Allow PunishTK";

	CheckBoxAutoMkTeams = TOSTGUICheckBox(CreateWindow(class'TOSTGUICheckBox', 0, 0, WinWidth, WinHeight));
	CheckBoxAutoMkTeams.OwnerTab = self;
	CheckBoxAutoMkTeams.Text = "Auto MkTeams";

	UpDownRoundTime = TOSTGUIBaseUpdown(CreateControl(class'TOSTGUIBaseUpdown', 0, 0, WinWidth, WinHeight));
    UpDownRoundTime.MinValue=1;
    UpDownRoundTime.MaxValue=10;
    UpDownRoundTime.IncValue=1;
    UpDownRoundTime.IncValue2=5;
	UpDownRoundTime.Label = "Round Duration";
	UpDownRoundTime.OwnerTab = self;

	UpDownMapTime = TOSTGUIBaseUpdown(CreateControl(class'TOSTGUIBaseUpdown', 0, 0, WinWidth, WinHeight));
    UpDownMapTime.MinValue=0;
    UpDownMapTime.MaxValue=60;
    UpDownMapTime.IncValue=1;
    UpDownMapTime.IncValue2=5;
	UpDownMapTime.Label = "Time Limit";
	UpDownMapTime.OwnerTab = self;

	UpDownRoundLimit = TOSTGUIBaseUpdown(CreateControl(class'TOSTGUIBaseUpdown', 0, 0, WinWidth, WinHeight));
    UpDownRoundLimit.MinValue=0;
    UpDownRoundLimit.MaxValue=60;
    UpDownRoundLimit.IncValue=1;
    UpDownRoundLimit.IncValue2=5;
	UpDownRoundLimit.Label = "Round Limit";
	UpDownRoundLimit.OwnerTab = self;

	CheckBoxBehindView = TOSTGUICheckBox(CreateWindow(class'TOSTGUICheckBox', 0, 0, WinWidth, WinHeight));
	CheckBoxBehindView.OwnerTab = self;
	CheckBoxBehindView.Text = "Allow BehindView";

	CheckBoxCWMode = TOSTGUICheckBox(CreateWindow(class'TOSTGUICheckBox', 0, 0, WinWidth, WinHeight));
	CheckBoxCWMode.OwnerTab = self;
	CheckBoxCWMode.Text = "ClanWar Mode";

	// X Setttings page

	EditSlotPwd = TOSTGUIEditControl(CreateControl(Class'TOSTGUIEditControl', 0, 0, WinWidth, WinHeight));
	EditSlotPwd.Label = "Slot Reserver Password";
	EditSlotPwd.OwnerTab = self;
	EditSlotPwd.SetValue("");
	EditSlotPwd.SetNumericOnly(False);
	EditSlotPwd.SetMaxLength(60);
	EditSlotPwd.SetDelayedNotify(True);

	ButtonSetSlotPwd = TOSTGUIBaseButton(CreateWindow(class'TOSTGUIBaseButton', 0, 0, WinWidth, WinHeight));
	ButtonSetSlotPwd.Text = "Set";
	ButtonSetSlotPwd.OwnerTab = self;

	EditTag = TOSTGUIEditControl(CreateControl(Class'TOSTGUIEditControl', 0, 0, WinWidth, WinHeight));
	EditTag.Label = "Clantag";
	EditTag.OwnerTab = self;
	EditTag.SetValue("");
	EditTag.SetNumericOnly(False);
	EditTag.SetMaxLength(60);
	EditTag.SetDelayedNotify(True);

	ButtonSetTag = TOSTGUIBaseButton(CreateWindow(class'TOSTGUIBaseButton', 0, 0, WinWidth, WinHeight));
	ButtonSetTag.Text = "Set";
	ButtonSetTag.OwnerTab = self;

	UpDownPreRound = TOSTGUIBaseUpdown(CreateControl(class'TOSTGUIBaseUpdown', 0, 0, WinWidth, WinHeight));
    UpDownPreRound.MinValue=0;
    UpDownPreRound.MaxValue=60;
    UpDownPreRound.IncValue=1;
    UpDownPreRound.IncValue2=5;
	UpDownPreRound.Label = "First Preround";
	UpDownPreRound.OwnerTab = self;

	UpDownNumberSlot = TOSTGUIBaseUpdown(CreateControl(class'TOSTGUIBaseUpdown', 0, 0, WinWidth, WinHeight));
    UpDownNumberSlot.MinValue=0;
    UpDownNumberSlot.MaxValue=32;
    UpDownNumberSlot.IncValue=1;
    UpDownNumberSlot.IncValue2=5;
	UpDownNumberSlot.Label = "Reserved Slots";
	UpDownNumberSlot.OwnerTab = self;

	UpDownMaxWarnings = TOSTGUIBaseUpdown(CreateControl(class'TOSTGUIBaseUpdown', 0, 0, WinWidth, WinHeight));
    UpDownMaxWarnings.MinValue=1;
    UpDownMaxWarnings.MaxValue=32;
    UpDownMaxWarnings.IncValue=1;
    UpDownMaxWarnings.IncValue2=5;
	UpDownMaxWarnings.Label = "Max Warnings";
	UpDownMaxWarnings.OwnerTab = self;

	CheckBoxMakeClanTeams = TOSTGUICheckBox(CreateWindow(class'TOSTGUICheckBox', 0, 0, WinWidth, WinHeight));
	CheckBoxMakeClanTeams.OwnerTab = self;
	CheckBoxMakeClanTeams.Text = "Auto MkClanTeams";

	CheckBoxHitparade = TOSTGUICheckBox(CreateWindow(class'TOSTGUICheckBox', 0, 0, WinWidth, WinHeight));
	CheckBoxHitparade.OwnerTab = self;
	CheckBoxHitparade.Text = "Enable HitParade";

	CheckBoxAnnouncer = TOSTGUICheckBox(CreateWindow(class'TOSTGUICheckBox', 0, 0, WinWidth, WinHeight));
	CheckBoxAnnouncer.OwnerTab = self;
	CheckBoxAnnouncer.Text = "Enable Announcer";

	CheckBoxEnableTOP = TOSTGUICheckBox(CreateWindow(class'TOSTGUICheckBox', 0, 0, WinWidth, WinHeight));
	CheckBoxEnableTOP.OwnerTab = self;
	CheckBoxEnableTOP.Text = "Enable TOP3 Support";

	CheckBoxForceTOP = TOSTGUICheckBox(CreateWindow(class'TOSTGUICheckBox', 0, 0, WinWidth, WinHeight));
	CheckBoxForceTOP.OwnerTab = self;
	CheckBoxForceTOP.Text = "Force TOP3 Support";

	CheckBoxWarpix = TOSTGUICheckBox(CreateWindow(class'TOSTGUICheckBox', 0, 0, WinWidth, WinHeight));
	CheckBoxWarpix.OwnerTab = self;
	CheckBoxWarpix.Text = "Enable WarPix";

	// Damage Page

	CheckBoxExplosionFF = TOSTGUICheckBox(CreateWindow(class'TOSTGUICheckBox', 0, 0, WinWidth, WinHeight));
	CheckBoxExplosionFF.OwnerTab = self;
	CheckBoxExplosionFF.Text = "Explosion FF";

	CheckBoxMirrorDmg = TOSTGUICheckBox(CreateWindow(class'TOSTGUICheckBox', 0, 0, WinWidth, WinHeight));
	CheckBoxMirrorDmg.OwnerTab = self;
	CheckBoxMirrorDmg.Text = "Mirror Damage";

	CheckBoxTKHandling = TOSTGUICheckBox(CreateWindow(class'TOSTGUICheckBox', 0, 0, WinWidth, WinHeight));
	CheckBoxTKHandling.OwnerTab = self;
	CheckBoxTKHandling.Text = "TK Handling";

	CheckBoxHPMessage = TOSTGUICheckBox(CreateWindow(class'TOSTGUICheckBox', 0, 0, WinWidth, WinHeight));
	CheckBoxHPMessage.OwnerTab = self;
	CheckBoxHPMessage.Text = "HP Messages";

	UpDownFFScale = TOSTGUIBaseUpdown(CreateControl(class'TOSTGUIBaseUpdown', 0, 0, WinWidth, WinHeight));
    UpDownFFScale.MinValue=0;
    UpDownFFScale.MaxValue=200;
    UpDownFFScale.IncValue=1;
    UpDownFFScale.IncValue2=10;
	UpDownFFScale.Label = "Friendly Fire Scale (%)";
	UpDownFFScale.OwnerTab = self;

	UpDownMaxTK = TOSTGUIBaseUpdown(CreateControl(class'TOSTGUIBaseUpdown', 0, 0, WinWidth, WinHeight));
    UpDownMaxTK.MinValue=-1;
    UpDownMaxTK.MaxValue=10;
    UpDownMaxTK.IncValue=1;
    UpDownMaxTK.IncValue2=5;
	UpDownMaxTK.Label = "Max TK";
	UpDownMaxTK.OwnerTab = self;

	UpDownMinAllowedScore = TOSTGUIBaseUpdown(CreateControl(class'TOSTGUIBaseUpdown', 0, 0, WinWidth, WinHeight));
    UpDownMinAllowedScore.MinValue=0;
    UpDownMinAllowedScore.MaxValue=100;
    UpDownMinAllowedScore.IncValue=1;
    UpDownMinAllowedScore.IncValue2=5;
	UpDownMinAllowedScore.Label = "Min Allowed Score";
	UpDownMinAllowedScore.OwnerTab = self;

	// Map Page

	CheckBoxNextMap = TOSTGUICheckBox(CreateWindow(class'TOSTGUICheckBox', 0, 0, WinWidth, WinHeight));
	CheckBoxNextMap.OwnerTab = self;
	CheckBoxNextMap.Text = "NextMap Handling";

	CheckBoxMapVote = TOSTGUICheckBox(CreateWindow(class'TOSTGUICheckBox', 0, 0, WinWidth, WinHeight));
	CheckBoxMapVote.OwnerTab = self;
	CheckBoxMapVote.Text = "MapVote";

	UpDownMVPercInGame = TOSTGUIBaseUpdown(CreateControl(class'TOSTGUIBaseUpdown', 0, 0, WinWidth, WinHeight));
    UpDownMVPercInGame.MinValue=0;
    UpDownMVPercInGame.MaxValue=101;
    UpDownMVPercInGame.IncValue=1;
    UpDownMVPercInGame.IncValue2=10;
	UpDownMVPercInGame.Label = "Vote In Game (%)";
	UpDownMVPercInGame.OwnerTab = self;

	UpDownMVPercMapEnd = TOSTGUIBaseUpdown(CreateControl(class'TOSTGUIBaseUpdown', 0, 0, WinWidth, WinHeight));
    UpDownMVPercMapEnd.MinValue=0;
    UpDownMVPercMapEnd.MaxValue=101;
    UpDownMVPercMapEnd.IncValue=1;
    UpDownMVPercMapEnd.IncValue2=10;
	UpDownMVPercMapEnd.Label = "Vote Map End (%)";
	UpDownMVPercMapEnd.OwnerTab = self;

	UpDownMVTime = TOSTGUIBaseUpdown(CreateControl(class'TOSTGUIBaseUpdown', 0, 0, WinWidth, WinHeight));
    UpDownMVTime.MinValue=0;
    UpDownMVTime.MaxValue=60;
    UpDownMVTime.IncValue=1;
    UpDownMVTime.IncValue2=5;
	UpDownMVTime.Label = "Vote Time";
	UpDownMVTime.OwnerTab = self;

	UpDownMVNoReplay = TOSTGUIBaseUpdown(CreateControl(class'TOSTGUIBaseUpdown', 0, 0, WinWidth, WinHeight));
    UpDownMVNoReplay.MinValue=0;
    UpDownMVNoReplay.MaxValue=25;
    UpDownMVNoReplay.IncValue=1;
    UpDownMVNoReplay.IncValue2=5;
	UpDownMVNoReplay.Label = "Map No Replay";
	UpDownMVNoReplay.OwnerTab = self;

	ButtonMVPrevMode = TOSTGUIBaseButton(CreateWindow(class'TOSTGUIBaseButton', 0, 0, WinWidth, WinHeight));
	ButtonMVPrevMode.Text = "<";
	ButtonMVPrevMode.OwnerTab = self;

	ButtonMVNextMode = TOSTGUIBaseButton(CreateWindow(class'TOSTGUIBaseButton', 0, 0, WinWidth, WinHeight));
	ButtonMVNextMode.Text = ">";
	ButtonMVNextMode.OwnerTab = self;

	LabelMVMode = TOSTGUILabel(CreateWindow(class'TOSTGUILabel', 0, 0, WinWidth, WinHeight));
	LabelMVMode.OwnerTab = self;

	// Settings Page
	for (i=0; i<10; i++)
	{
		EditSettings[i] = TOSTGUIEditControl(CreateControl(Class'TOSTGUIEditControl', 0, 0, WinWidth, WinHeight));
		EditSettings[i].Label = "Settings "$i;
		EditSettings[i].OwnerTab = self;
		EditSettings[i].SetValue("");
		EditSettings[i].SetNumericOnly(False);
		EditSettings[i].SetMaxLength(60);
		EditSettings[i].SetDelayedNotify(True);

		ButtonSave[i] = TOSTGUIBaseButton(CreateWindow(class'TOSTGUIBaseButton', 0, 0, WinWidth, WinHeight));
		ButtonSave[i].Text = "Save";
		ButtonSave[i].OwnerTab = self;

		ButtonLoad[i] = TOSTGUIBaseButton(CreateWindow(class'TOSTGUIBaseButton', 0, 0, WinWidth, WinHeight));
		ButtonLoad[i].Text = "Load";
		ButtonLoad[i].OwnerTab = self;
	}

	// Settings Page
	for (i=0; i<10; i++)
	{
		LabelGameType[i] = TOSTGUILabel(CreateWindow(class'TOSTGUILabel', 0, 0, WinWidth, WinHeight));
		LabelGameType[i].OwnerTab = self;

		ButtonChange[i] = TOSTGUIBaseButton(CreateWindow(class'TOSTGUIBaseButton', 0, 0, WinWidth, WinHeight));
		ButtonChange[i].Text = "Change";
		ButtonChange[i].OwnerTab = self;
	}

	// Banlist Page

	BoxBanList = TOSTGUITextListbox(CreateWindow(class'TOSTGUITextListbox', 0, 0, WinWidth, WinHeight));
	BoxBanList.Label = TextHintBanList;
	BoxBanList.bMultiSelect = false;
	BoxBanList.OwnerTab = self;

  	EditBanTimeStamp = TOSTGUIEditControl(CreateControl(Class'TOSTGUIEditControl', 0, 0, WinWidth, WinHeight));
	EditBanTimeStamp.Label = "TimeStamp";
	EditBanTimeStamp.OwnerTab = self;
	EditBanTimeStamp.SetValue("");
	EditBanTimeStamp.SetNumericOnly(False);
	EditBanTimeStamp.SetEditable(False);
	EditBanTimeStamp.SetMaxLength(15);
	EditBanTimeStamp.SetDelayedNotify(True);

  	EditAdminIP = TOSTGUIEditControl(CreateControl(Class'TOSTGUIEditControl', 0, 0, WinWidth, WinHeight));
	EditAdminIP.Label = "Admin IP";
	EditAdminIP.OwnerTab = self;
	EditAdminIP.SetValue("");
	EditAdminIP.SetNumericOnly(False);
	EditAdminIP.SetEditable(False);
	EditAdminIP.SetMaxLength(15);
	EditAdminIP.SetDelayedNotify(True);

  	EditAdminName = TOSTGUIEditControl(CreateControl(Class'TOSTGUIEditControl', 0, 0, WinWidth, WinHeight));
	EditAdminName.Label = "Admin Name";
	EditAdminName.OwnerTab = self;
	EditAdminName.SetValue("");
	EditAdminName.SetNumericOnly(False);
	EditAdminName.SetEditable(False);
	EditAdminName.SetMaxLength(25);
	EditAdminName.SetDelayedNotify(True);

  	EditVictimIP = TOSTGUIEditControl(CreateControl(Class'TOSTGUIEditControl', 0, 0, WinWidth, WinHeight));
	EditVictimIP.Label = "Victim IP";
	EditVictimIP.OwnerTab = self;
	EditVictimIP.SetValue("");
	EditVictimIP.SetNumericOnly(False);
	EditVictimIP.SetMaxLength(15);
	EditVictimIP.SetDelayedNotify(True);

  	EditVictimName = TOSTGUIEditControl(CreateControl(Class'TOSTGUIEditControl', 0, 0, WinWidth, WinHeight));
	EditVictimName.Label = "Victim Name";
	EditVictimName.OwnerTab = self;
	EditVictimName.SetValue("");
	EditVictimName.SetNumericOnly(False);
	EditVictimName.SetMaxLength(25);
	EditVictimName.SetDelayedNotify(True);

  	EditReason = TOSTGUIEditControl(CreateControl(Class'TOSTGUIEditControl', 0, 0, WinWidth, WinHeight));
	EditReason.Label = "Reason";
	EditReason.OwnerTab = self;
	EditReason.SetValue("");
	EditReason.SetNumericOnly(False);
	EditReason.SetMaxLength(50);
	EditReason.SetDelayedNotify(True);

	ButtonBanPrevDuration = TOSTGUIBaseButton(CreateWindow(class'TOSTGUIBaseButton', 0, 0, WinWidth, WinHeight));
	ButtonBanPrevDuration.Text = "<";
	ButtonBanPrevDuration.OwnerTab = self;

	ButtonBanNextDuration = TOSTGUIBaseButton(CreateWindow(class'TOSTGUIBaseButton', 0, 0, WinWidth, WinHeight));
	ButtonBanNextDuration.Text = ">";
	ButtonBanNextDuration.OwnerTab = self;

	LabelBanDuration = TOSTGUILabel(CreateWindow(class'TOSTGUILabel', 0, 0, WinWidth, WinHeight));
	LabelBanDuration.OwnerTab = self;

	ButtonBanSave = TOSTGUIBaseButton(CreateWindow(class'TOSTGUIBaseButton', 0, 0, WinWidth, WinHeight));
	ButtonBanSave.Text = "Add";
	ButtonBanSave.OwnerTab = self;

  	ButtonBanRemove = TOSTGUIBaseButton(CreateWindow(class'TOSTGUIBaseButton', 0, 0, WinWidth, WinHeight));
	ButtonBanRemove.Text = "Remove";
	ButtonBanRemove.OwnerTab = self;

  	EditBanSearch = TOSTGUIEditControl(CreateControl(Class'TOSTGUIEditControl', 0, 0, WinWidth, WinHeight));
	EditBanSearch.Label = "Search for IP/Name";
	EditBanSearch.OwnerTab = self;
	EditBanSearch.SetValue("");
	EditBanSearch.SetNumericOnly(False);
	EditBanSearch.SetMaxLength(25);
	EditBanSearch.SetDelayedNotify(True);

  	ButtonBanSearch = TOSTGUIBaseButton(CreateWindow(class'TOSTGUIBaseButton', 0, 0, WinWidth, WinHeight));
	ButtonBanSearch.Text = "Search";
	ButtonBanSearch.OwnerTab = self;

	for (i=0; i<MaxPages; i++)
	{
		CurrentPage = i;
		HideCurrentPage();
	}

	CurrentPage = 0;
	OpenCurrentPage();

	AdminWarning = 0.3;
	AdminWarnStep = 1;
}

simulated function Close (optional bool bByParent)
{
	local	int	i;

	ButtonClose.Close();
	ButtonAdminTab.Close();
	ButtonPrevPage.Close();
	ButtonNextPage.Close();
	LabelPage.Close();

	// Rules Page

	EditAdminPwd.Close();
	EditGamePwd.Close();
	ButtonSetAdminPwd.Close();
	ButtonSetGamePwd.Close();
	CheckBoxGhostcam.Close();
	CheckBoxBallistics.Close();
	CheckBoxPlayerBackup.Close();
	CheckBoxPunishTK.Close();
	CheckBoxEnhVote.Close();
	CheckBoxAutoMkTeams.Close();
	CheckBoxBehindView.Close();
	CheckBoxCWMode.Close();
	UpDownMapTime.Close();
	UpDownRoundTime.Close();
	UpDownRoundLimit.Close();

	// X Settings page

	EditSlotPwd.Close();
	ButtonSetSlotPwd.Close();
	EditTag.Close();
	ButtonSetTag.Close();
	UpDownPreRound.Close();
	UpDownNumberSlot.Close();
	UpDownMaxWarnings.Close();
	CheckBoxMakeClanTeams.Close();
	CheckBoxHitParade.Close();
	CheckBoxAnnouncer.Close();
	CheckBoxEnableTOP.Close();
	CheckBoxForceTOP.Close();
	CheckBoxWarpix.Close();

	// Damage Page

	CheckBoxExplosionFF.Close();
	CheckBoxMirrorDmg.Close();
	CheckBoxTKHandling.Close();
	CheckBoxHPMessage.Close();
	UpDownFFScale.Close();
	UpDownMaxTK.Close();
	UpDownMinAllowedScore.Close();

	// Map Page

	CheckBoxNextMap.Close();
	CheckBoxMapVote.Close();
	UpDownMVPercInGame.Close();
	UpDownMVPercMapEnd.Close();
	UpDownMVTime.Close();
	UpDownMVNoReplay.Close();
	ButtonMVNextMode.Close();
	ButtonMVPrevMode.Close();
	LabelMVMode.Close();

	// Settings Page

	for (i=0; i<10; i++)
	{
		EditSettings[i].Close();
		ButtonSave[i].Close();
		ButtonLoad[i].Close();
	}

	// Gametype Page

	for (i=0; i<10; i++)
	{
		LabelGameType[i].Close();
		ButtonChange[i].Close();
	}

	// BanList Page

	BoxBanList.Close();
	EditBanTimeStamp.Close();
	EditAdminIP.Close();
	EditAdminName.Close();
	EditVictimIP.Close();
	EditVictimName.Close();
	EditReason.Close();
	ButtonBanPrevDuration.Close();
	ButtonBanNextDuration.Close();
	LabelBanDuration.Close();
	ButtonBanSave.Close();
	ButtonBanRemove.Close();
	EditBanSearch.Close();
	ButtonBanSearch.Close();

	Super.Close(bByParent);
}

simulated function Tick (float delta)
{
	if (!OwnerPlayer.PlayerReplicationInfo.bAdmin)
	{
		if ((AdminWarning + (AdminWarnStep*delta) > 0.7) || (AdminWarning + (AdminWarnStep*delta) < 0.3))
			AdminWarnStep = -AdminWarnStep;
		AdminWarning += AdminWarnStep*delta;
		if (AdminWarning > 0.7)
			AdminWarning = 0.7;
		if (AdminWarning < 0.3)
			AdminWarning = 0.3;
	}
}

// paint
simulated function Paint (Canvas Canvas, float x, float y)
{
	Super.Paint(Canvas, x, y);

	// no admin warning
	if (bDraw)
		if (!OwnerPlayer.PlayerReplicationInfo.bAdmin && Master.SemiAdmin == 0)
			PaintAdminWarning(Canvas);

	// "group box"
	Canvas.DrawColor = OwnerInterface.Design.ColorWhite;
	OwnerInterface.Tool_DrawBox(Canvas, Left + 8, Top + 8, Width - 16, ButtonClose.WinTop - Top - ButtonClose.WinHeight - 16);
}

// Paint Helper

simulated function PaintAdminWarning (Canvas Canvas)
{
	local float	x1, y1;

	Canvas.Style = OwnerHUD.ERenderStyle.STY_NORMAL;
	OwnerInterface.Design.SetScoreboardFont(Canvas);

	Canvas.DrawColor.R = OwnerInterface.Design.ColorRed.R * AdminWarning;
	Canvas.DrawColor.G = OwnerInterface.Design.ColorRed.G * AdminWarning;
	Canvas.DrawColor.B = OwnerInterface.Design.ColorRed.B * AdminWarning;

	Canvas.StrLen(TextAdminWarning, x1, y1);
	Canvas.SetPos(Left + ((Width-x1) / 2), ButtonClose.WinTop - ButtonClose.WinHeight - 4 + ((ButtonClose.WinHeight - y1)/2));
	Canvas.DrawText(TextAdminWarning, true);
}

simulated function BeforeShow ()
{
	ClearUp();

	LoadCurrentPage();
	ShowCurrentPage();

	ButtonClose.ShowWindow();
	ButtonAdminTab.ShowWindow();
	ButtonPrevPage.ShowWindow();
	ButtonNextPage.ShowWindow();
	LabelPage.ShowWindow();
}

simulated function BeforeHide ()
{
	HideCurrentPage();

	ButtonClose.HideWindow();
	ButtonAdminTab.HideWindow();
	ButtonPrevPage.HideWindow();
	ButtonNextPage.HideWindow();
	LabelPage.HideWindow();
}

simulated function KeyDown (int Key, float x, float y)
{
	local string	keyname, alias;

	keyname = OwnerPlayer.ConsoleCommand("KEYNAME"@Key);
	alias = OwnerPlayer.ConsoleCommand("KEYBINDING"@keyname);

	if (Caps(alias) ~= "SHOWGAMETAB")
	{
		OwnerInterface.Hide();
	}
}

simulated function Clearup()
{
	if (!bInitialized)
		return;

	BoxBanList.SetSelectedByIndex(BoxBanList.SelectedIndex, False);
	BoxBanList.SelectedIndex = BoxBanList.LBIT_NONE;
	BoxBanList.TopIndex = 0;
}

// setup control positions
simulated function Setup(Canvas Canvas)
{
	local float				l, w, t, w2, w4, xw, wb3, wb2, xw3, t2, t3, sw;
	local int				i, lh;

	OwnerHUD.Design.SetHeadlineFont(Canvas);

	xw = Width*0.5 - 3*Padding[Resolution];
	xw3 = Width*0.33 - 2*Padding[Resolution];
	w = Width*0.25 - Padding[Resolution];
	lh = OwnerHud.Design.LineHeight;
	l = int(Width*0.125);
	w2 = int(w*0.5);
	w4 = int(w*0.4);
	t = Left + Width - Padding[Resolution] - xw;
	t2 = Left + 2*Padding[Resolution] + xw3;
	t3 = Left + Width - Padding[Resolution] - xw3;
	wb3 = (xw - 2*Padding[Resolution]) / 3;
	wb2 = (xw - Padding[Resolution]) / 2;
	sw = (xw * 0.77 - Padding[Resolution]);

	ButtonClose.WinLeft = Left + Width - w;
	ButtonClose.WinTop = Top + Height - Padding[Resolution] - lh - 3;
	ButtonClose.SetWidth(Canvas, w - Padding[Resolution]);

	ButtonAdminTab.WinLeft = Left + Width - w*2;
	ButtonAdminTab.WinTop = Top + Height - Padding[Resolution] - lh - 3;
	ButtonAdminTab.SetWidth(Canvas, w - Padding[Resolution]);

	ButtonPrevPage.WinLeft = Left + Padding[Resolution];
	ButtonPrevPage.WinTop = Top + Height - Padding[Resolution] - lh - 3;
	ButtonPrevPage.SetWidth(Canvas, w * 0.25);

   	ButtonNextPage.WinLeft = t - 2*Padding[Resolution] - ButtonPrevPage.WinWidth;
	ButtonNextPage.WinTop = Top + Height - Padding[Resolution] - lh - 3;
	ButtonNextPage.SetWidth(Canvas, w * 0.25);

	LabelPage.WinLeft = ButtonPrevPage.WinLeft + ButtonPrevPage.WinWidth + Padding[Resolution];
	LabelPage.WinTop = Top + Height - Padding[Resolution] - lh - 3;
	LabelPage.SetWidth(Canvas, ButtonNextPage.WinLeft - Padding[Resolution] - LabelPage.WinLeft);

	// Rules Page

	EditAdminPwd.WinLeft = Left + Padding[Resolution];
	EditAdminPwd.WinTop = Top + Padding[Resolution];
	EditAdminPwd.SetWidth(Canvas, xw - Padding[Resolution] - w4);

	EditGamePwd.WinLeft = Left + Padding[Resolution];
	EditGamePwd.WinTop = EditAdminPwd.WinTop + EditAdminPwd.WinHeight + Padding[Resolution];
	EditGamePwd.SetWidth(Canvas, xw - Padding[Resolution] - w4);

	ButtonSetAdminPwd.WinLeft = Left + Padding[Resolution] + xw - w4;
	ButtonSetAdminPwd.WinTop = EditAdminPwd.WinTop + 19;
	ButtonSetAdminPwd.SetWidth(Canvas, w4);

	ButtonSetGamePwd.WinLeft = Left + Padding[Resolution] + xw - w4;
	ButtonSetGamePwd.WinTop = EditGamePwd.WinTop + 19;
	ButtonSetGamePwd.SetWidth(Canvas, w4);

	UpDownMapTime.WinLeft = Left + Padding[Resolution];
	UpDownMapTime.WinTop = EditGamePwd.WinTop + EditGamePwd.WinHeight + 2*Padding[Resolution];
	UpDownMapTime.SetWidth(Canvas, w2);

	UpDownRoundTime.WinLeft = t2;
	UpDownRoundTime.WinTop = EditGamePwd.WinTop + EditGamePwd.WinHeight + 2*Padding[Resolution];
	UpDownRoundTime.SetWidth(Canvas, w2);

	UpDownRoundLimit.WinLeft = t3;
	UpDownRoundLimit.WinTop = EditGamePwd.WinTop + EditGamePwd.WinHeight + 2*Padding[Resolution];
	UpDownRoundLimit.SetWidth(Canvas, w2);

	CheckBoxGhostcam.WinLeft = Left + Padding[Resolution];
	CheckBoxGhostcam.WinTop = UpDownMapTime.WinTop + UpDownMapTime.WinHeight + 2*Padding[Resolution];
	CheckBoxGhostcam.SetWidth(Canvas, xw);

	CheckBoxBallistics.WinLeft = Left + Padding[Resolution];
	CheckBoxBallistics.WinTop = CheckBoxGhostCam.WinTop + CheckBoxGhostCam.WinHeight + Padding[Resolution];
	CheckBoxBallistics.SetWidth(Canvas, xw);

	CheckBoxPunishTK.WinLeft = Left + Padding[Resolution];
	CheckBoxPunishTK.WinTop = CheckBoxBallistics.WinTop + CheckBoxBallistics.WinHeight + Padding[Resolution];
	CheckBoxPunishTK.SetWidth(Canvas, xw);

	CheckBoxBehindView.WinLeft = Left + Padding[Resolution];
	CheckBoxBehindView.WinTop = CheckBoxPunishTK.WinTop + CheckBoxPunishTK.WinHeight + Padding[Resolution];
	CheckBoxBehindView.SetWidth(Canvas, xw);

	CheckBoxPlayerBackup.WinLeft = t;
	CheckBoxPlayerBackup.WinTop = UpDownMapTime.WinTop + UpDownMapTime.WinHeight + 2*Padding[Resolution];
	CheckBoxPlayerBackup.SetWidth(Canvas, xw);

	CheckBoxEnhVote.WinLeft = t;
	CheckBoxEnhVote.WinTop = CheckBoxPlayerBackup.WinTop + CheckBoxPlayerBackup.WinHeight + Padding[Resolution];
	CheckBoxEnhVote.SetWidth(Canvas, xw);

	CheckBoxAutoMkTeams.WinLeft = t;
	CheckBoxAutoMkTeams.WinTop = CheckBoxEnhVote.WinTop + CheckBoxEnhVote.WinHeight + Padding[Resolution];
	CheckBoxAutoMkTeams.SetWidth(Canvas, xw);

	CheckBoxCWMode.WinLeft = t;
	CheckBoxCWMode.WinTop = CheckBoxAutoMkTeams.WinTop + CheckBoxAutoMkTeams.WinHeight + Padding[Resolution];
	CheckBoxCWMode.SetWidth(Canvas, xw);

	// X Settings Page

	EditSlotPwd.WinLeft = Left + Padding[Resolution];
	EditSlotPwd.WinTop = Top + Padding[Resolution];
	EditSlotPwd.setWidth(Canvas, xw - Padding[Resolution] - w4);

	ButtonSetSlotPwd.WinLeft = Left + Padding[Resolution] + xw - w4;
	ButtonSetSlotPwd.WinTop = EditSlotPwd.WinTop + 19;
	ButtonSetSlotPwd.SetWidth(Canvas, w4);

	EditTag.WinLeft = Left + Padding[Resolution];
	EditTag.WinTop = EditSlotPwd.WinTop + EditSlotPwd.WinHeight + Padding[Resolution];
	EditTag.SetWidth(Canvas, xw - Padding[Resolution] - w4);

	ButtonSetTag.WinLeft = Left + Padding[Resolution] + xw - w4;
	ButtonSetTag.WinTop = EditTag.WinTop + 19;
	ButtonSetTag.SetWidth(Canvas, w4);

	UpDownNumberSlot.WinLeft = Left + Padding[Resolution];
	UpDownNumberSlot.WinTop = EditTag.WinTop + EditTag.WinHeight + 2*Padding[Resolution];
	UpDownNumberSlot.SetWidth(Canvas, w2);

	UpDownPreRound.WinLeft = t2;
	UpDownPreRound.WinTop = EditTag.WinTop + EditTag.WinHeight + 2*Padding[Resolution];
	UpDownPreRound.SetWidth(Canvas, w2);

	UpDownMaxWarnings.WinLeft = t3;
	UpDownMaxWarnings.WinTop = EditTag.WinTop + EditTag.WinHeight + 2*Padding[Resolution];
	UpDownMaxWarnings.SetWidth(Canvas, w2);

	CheckBoxMakeClanTeams.WinLeft = Left + Padding[Resolution];
	CheckBoxMakeClanTeams.WinTop = UpDownPreRound.WinTop + UpDownPreRound.WinHeight + 2*Padding[Resolution];
	CheckBoxMakeClanTeams.SetWidth(Canvas, xw);

	CheckBoxHitParade.WinLeft = t;
	CheckBoxHitParade.WinTop = UpDownPreRound.WinTop + UpDownPreRound.WinHeight + 2*Padding[Resolution];
	CheckBoxHitParade.SetWidth(Canvas, xw);

	CheckBoxAnnouncer.WinLeft = Left + Padding[Resolution];
	CheckBoxAnnouncer.WinTop = CheckBoxMakeClanTeams.WinTop + CheckBoxMakeClanTeams.WinHeight + Padding[Resolution];
	CheckBoxAnnouncer.SetWidth(Canvas, xw);

	CheckBoxEnableTOP.WinLeft = t;
	CheckBoxEnableTOP.WinTop = CheckBoxMakeClanTeams.WinTop + CheckBoxMakeClanTeams.WinHeight + Padding[Resolution];
	CheckBoxEnableTOP.SetWidth(Canvas, xw);

	CheckBoxForceTOP.WinLeft = Left + Padding[Resolution];
	CheckBoxForceTOP.WinTop = CheckBoxAnnouncer.WinTop + CheckBoxAnnouncer.WinHeight + Padding[Resolution];
	CheckBoxForceTOP.SetWidth(Canvas, xw);

	CheckBoxWarpix.WinLeft = t;
	CheckBoxWarpix.WinTop = CheckBoxAnnouncer.WinTop + CheckBoxAnnouncer.WinHeight + Padding[Resolution];
	CheckBoxWarpix.SetWidth(Canvas, xw);

	// Damage Page

	UpDownFFScale.WinLeft = Left + Padding[Resolution];
	UpDownFFScale.WinTop = Top + Padding[Resolution];
	UpDownFFScale.SetWidth(Canvas, w2);

	CheckBoxExplosionFF.WinLeft = Left + Padding[Resolution];
	CheckBoxExplosionFF.WinTop = UpDownFFScale.WinTop + UpDownFFScale.WinHeight + 2 * Padding[Resolution];
	CheckBoxExplosionFF.SetWidth(Canvas, xw);

	CheckBoxMirrorDmg.WinLeft = t;
	CheckBoxMirrorDmg.WinTop = UpDownFFScale.WinTop + UpDownFFScale.WinHeight + 2 * Padding[Resolution];
	CheckBoxMirrorDmg.SetWidth(Canvas, xw);

	CheckBoxTKHandling.WinLeft = Left + Padding[Resolution];
	CheckBoxTKHandling.WinTop = CheckBoxExplosionFF.WinTop + CheckBoxExplosionFF.WinHeight + 2 * Padding[Resolution];
	CheckBoxTKHandling.SetWidth(Canvas, xw);

	UpDownMaxTK.WinLeft = Left + Padding[Resolution];
	UpDownMaxTK.WinTop = CheckBoxTKHandling.WinTop + CheckBoxTKHandling.WinHeight + Padding[Resolution];
	UpDownMaxTK.SetWidth(Canvas, w2);

	UpDownMinAllowedScore.WinLeft = t;
	UpDownMinAllowedScore.WinTop = CheckBoxTKHandling.WinTop + CheckBoxTKHandling.WinHeight + Padding[Resolution];
	UpDownMinAllowedScore.SetWidth(Canvas, w2);

	CheckBoxHPMessage.WinLeft = Left + Padding[Resolution];
	CheckBoxHPMessage.WinTop = UpDownMaxTK.WinTop + UpDownMaxTK.WinHeight + 2*Padding[Resolution];
	CheckBoxHPMessage.SetWidth(Canvas, xw);

	// Map Page

	CheckBoxNextMap.WinLeft = Left + Padding[Resolution];
	CheckBoxNextMap.WinTop = Top + Padding[Resolution];
	CheckBoxNextMap.SetWidth(Canvas, xw);

	CheckBoxMapVote.WinLeft = Left + Padding[Resolution];
	CheckBoxMapVote.WinTop = CheckBoxNextMap.WinTop + CheckBoxNextMap.WinHeight + 2*Padding[Resolution];
	CheckBoxMapVote.SetWidth(Canvas, xw);

	UpDownMVPercInGame.WinLeft = Left + Padding[Resolution];
	UpDownMVPercInGame.WinTop = CheckBoxMapVote.WinTop + CheckBoxMapVote.WinHeight + Padding[Resolution];
	UpDownMVPercInGame.SetWidth(Canvas, w2);

	UpDownMVPercMapEnd.WinLeft = t;
	UpDownMVPercMapEnd.WinTop = CheckBoxMapVote.WinTop + CheckBoxMapVote.WinHeight + Padding[Resolution];
	UpDownMVPercMapEnd.SetWidth(Canvas, w2);

	UpDownMVTime.WinLeft = Left + Padding[Resolution];
	UpDownMVTime.WinTop = UpDownMVPercInGame.WinTop + UpDownMVPercInGame.WinHeight + Padding[Resolution];
	UpDownMVTime.SetWidth(Canvas, w2);

	UpDownMVNoReplay.WinLeft = t;
	UpDownMVNoReplay.WinTop = UpDownMVPercInGame.WinTop + UpDownMVPercInGame.WinHeight + Padding[Resolution];
	UpDownMVNoReplay.SetWidth(Canvas, w2);

	ButtonMVPrevMode.WinLeft = Left + Padding[Resolution];
	ButtonMVPrevMode.WinTop = UpDownMVTime.WinTop + UpDownMVTime.WinHeight + Padding[Resolution];
	ButtonMVPrevMode.SetWidth(Canvas, w * 0.25);

   	ButtonMVNextMode.WinLeft = t - 2*Padding[Resolution] - ButtonMVPrevMode.WinWidth;
	ButtonMVNextMode.WinTop = UpDownMVTime.WinTop + UpDownMVTime.WinHeight + Padding[Resolution];
	ButtonMVNextMode.SetWidth(Canvas, w * 0.25);

	LabelMVMode.WinLeft = ButtonMVPrevMode.WinLeft + ButtonMVPrevMode.WinWidth + Padding[Resolution];
	LabelMVMode.WinTop = UpDownMVTime.WinTop + UpDownMVTime.WinHeight + Padding[Resolution];
	LabelMVMode.SetWidth(Canvas, ButtonMVNextMode.WinLeft - Padding[Resolution] - LabelMVMode.WinLeft);

	// settings page

	for (i=0; i<10; i++)
	{
		EditSettings[i].WinLeft = Left + Padding[Resolution];
		if (i==0)
			EditSettings[i].WinTop = Top + Padding[Resolution];
		else
			EditSettings[i].WinTop = EditSettings[i-1].WinTop + EditSettings[i-1].WinHeight + Padding[Resolution];
		EditSettings[i].SetWidth(Canvas, xw - Padding[Resolution] + w4);

		ButtonLoad[i].WinLeft = Left + 2*Padding[Resolution] + xw + 2*w4;
		ButtonLoad[i].WinTop = EditSettings[i].WinTop + 19;
		ButtonLoad[i].SetWidth(Canvas, w4);

		ButtonSave[i].WinLeft = Left + Padding[Resolution] + xw + w4;
		ButtonSave[i].WinTop = EditSettings[i].WinTop + 19;
		ButtonSave[i].SetWidth(Canvas, w4);
	}

	// game type page

	for (i=0; i<10; i++)
	{
		LabelGameType[i].WinLeft = Left + Padding[Resolution];
		if (i==0)
			LabelGameType[i].WinTop = Top + Padding[Resolution];
		else
			LabelGameType[i].WinTop = LabelGameType[i-1].WinTop + LabelGameType[i-1].WinHeight + Padding[Resolution];
		LabelGameType[i].SetWidth(Canvas, xw - Padding[Resolution] + w + w4);
		LabelGameType[i].bBackground = false;

		ButtonChange[i].WinLeft = Left + Padding[Resolution] + xw + w + w4;
		ButtonChange[i].WinTop = LabelGameType[i].WinTop;
		ButtonChange[i].SetWidth(Canvas, w4);
	}

	// Banlist page

    BoxBanList.WinLeft = Left + Padding[Resolution];
	BoxBanList.WinTop = Top + Padding[Resolution];
	BoxBanList.NumVisItems = BanListItemsVisible();
	BoxBanList.SetWidth(Canvas, xw);

	EditBanSearch.WinLeft = Left + Padding[Resolution];
	EditBanSearch.Wintop = BoxBanList.WinTop + BoxBanList.WinHeight + Padding[Resolution];
	EditBanSearch.SetWidth(Canvas, sw);

	ButtonBanSearch.WinLeft = Left + sw + 2*Padding[Resolution];
	ButtonBanSearch.Wintop = BoxBanList.WinTop + BoxBanList.WinHeight + 19 + Padding[Resolution];
	ButtonBanSearch.SetWidth(Canvas, (xw - sw - Padding[Resolution]));

	EditBanTimeStamp.WinLeft = t;
	EditBanTimeStamp.Wintop = Top + Padding[Resolution];
	EditBanTimeStamp.SetWidth(Canvas, xw);

	EditAdminIP.WinLeft = t;
	EditAdminIP.Wintop = EditBanTimeStamp.WinTop + EditBanTimeStamp.WinHeight + Padding[Resolution];
	EditAdminIP.SetWidth(Canvas, xw);

	EditAdminName.WinLeft = t;
	EditAdminName.Wintop = EditAdminIP.WinTop + EditAdminIP.WinHeight + Padding[Resolution];
	EditAdminName.SetWidth(Canvas, xw);

	EditVictimIP.WinLeft = t;
	EditVictimIP.Wintop = EditAdminName.WinTop + EditAdminName.WinHeight + Padding[Resolution];
	EditVictimIP.SetWidth(Canvas, xw);

	EditVictimName.WinLeft = t;
	EditVictimName.Wintop = EditVictimIP.WinTop + EditVictimIP.WinHeight + Padding[Resolution];
	EditVictimName.SetWidth(Canvas, xw);

	EditReason.WinLeft = t;
	EditReason.Wintop = EditVictimName.WinTop + EditVictimName.WinHeight + Padding[Resolution];
	EditReason.SetWidth(Canvas, xw);

	ButtonBanPrevDuration.WinLeft = t;
	ButtonBanPrevDuration.WinTop = EditReason.WinTop + EditReason.WinHeight + Padding[Resolution];
	ButtonBanPrevDuration.SetWidth(Canvas, (xw - Padding[Resolution] * 2) * 0.15);

	LabelBanDuration.WinLeft = ButtonBanPrevDuration.WinLeft + ButtonBanPrevDuration.WinWidth + Padding[Resolution];
	LabelBanDuration.WinTop = EditReason.WinTop + EditReason.WinHeight + Padding[Resolution];
	LabelBanDuration.SetWidth(Canvas, (xw - Padding[Resolution] * 2) * 0.70);

   	ButtonBanNextDuration.WinLeft = LabelBanDuration.WinLeft + LabelBanDuration.WinWidth + Padding[Resolution];
	ButtonBanNextDuration.WinTop = EditReason.WinTop + EditReason.WinHeight + Padding[Resolution];
	ButtonBanNextDuration.SetWidth(Canvas, (xw - Padding[Resolution] * 2) * 0.15);

	ButtonBanSave.WinLeft = t;
	ButtonBanSave.Wintop = ButtonBanPrevDuration.WinTop + ButtonBanPrevDuration.WinHeight + Padding[Resolution];
	ButtonBanSave.SetWidth(Canvas, wb2);

	ButtonBanRemove.WinLeft = t + wb2 + Padding[Resolution];
	ButtonBanRemove.Wintop = ButtonBanPrevDuration.WinTop + ButtonBanPrevDuration.WinHeight + Padding[Resolution];
	ButtonBanRemove.SetWidth(Canvas, wb2);
}

// Control events
simulated function Notify (UWindowDialogControl control, byte Event)
{
	local int	i, j;


	// close
	if (control == ButtonClose)
	{
		if (event == DE_Click)
		{
			OwnerInterface.Hide();
			ClearUp();
		}
		else if (event == DE_MouseMove)
		{
			Hint = TextHintCloseButton;
			AltHint = "";
		}
		else if (event == DE_MouseLeave)
		{
			Hint = TextHintDefault;
			AltHint = TextHintDefaultAlt;
		}
	}
	// switch to admintab
	if (control == ButtonAdminTab)
	{
		if (event == DE_Click)
		{
			OwnerPlayer.ConsoleCommand("ShowAdminTab");
			ClearUp();
		}
		else if (event == DE_MouseMove)
		{
			Hint = TextHintAdminTabButton;
			AltHint = "";
		}
		else if (event == DE_MouseLeave)
		{
			Hint = TextHintDefault;
			AltHint = TextHintDefaultAlt;
		}
	}
	// switch to next page
	if (control == ButtonNextPage)
	{
		if (event == DE_Click)
		{
			CloseCurrentPage();
			CurrentPage++;
			if (CurrentPage >= MaxPages)
				CurrentPage = 0;
			OpenCurrentPage();
		}
		else if (event == DE_MouseMove)
		{
			Hint = TextHintNextPageButton;
			AltHint = "";
		}
		else if (event == DE_MouseLeave)
		{
			Hint = TextHintDefault;
			AltHint = TextHintDefaultAlt;
		}
	}
	// switch to prev page
	if (control == ButtonPrevPage)
	{
		if (event == DE_Click)
		{
			CloseCurrentPage();
			CurrentPage--;
			if (CurrentPage < 0)
				CurrentPage = MaxPages-1;
			OpenCurrentPage();
		}
		else if (event == DE_MouseMove)
		{
			Hint = TextHintPrevPageButton;
			AltHint = "";
		}
		else if (event == DE_MouseLeave)
		{
			Hint = TextHintDefault;
			AltHint = TextHintDefaultAlt;
		}
	}

	// Rules Page

	// Set Admin Password
	if (control == ButtonSetAdminPwd)
	{
		if (event == DE_Click)
		{
			if (TabComm != None)
			{
				TabComm.SendMessage(121, 100, , , EditAdminPwd.GetValue());
				TabComm.SendMessage(120, 100);
			}
		}
		else if (event == DE_MouseMove)
		{
			Hint = TextHintAdminPwd;
			AltHint = "";
		}
		else if (event == DE_MouseLeave)
		{
			Hint = TextHintDefault;
			AltHint = TextHintDefaultAlt;
		}
	}
	// Set Game Password
	if (control == ButtonSetGamePwd)
	{
		if (event == DE_Click)
		{
			if (TabComm != None)
			{
				TabComm.SendMessage(121, 101, , , EditGamePwd.GetValue());
				TabComm.SendMessage(120, 101);
			}
		}
		else if (event == DE_MouseMove)
		{
			Hint = TextHintGamePwd;
			AltHint = "";
		}
		else if (event == DE_MouseLeave)
		{
			Hint = TextHintDefault;
			AltHint = TextHintDefaultAlt;
		}
	}
	// Time Limit
	if (control == UpDownMapTime)
	{
		if (event == DE_Click)
		{
			if (TabComm != None)
			{
				TabComm.SendMessage(121, 102, UpDownMapTime.Value);
				TabComm.SendMessage(120, 102);
			}
		}
		else if (event == DE_MouseMove)
		{
			Hint = TextHintMapTime;
			AltHint = "";
		}
		else if (event == DE_MouseLeave)
		{
			Hint = TextHintDefault;
			AltHint = TextHintDefaultAlt;
		}
	}
	// Round Limit
	if (control == UpDownRoundLimit)
	{
		if (event == DE_Click)
		{
			if (TabComm != None)
			{
				TabComm.SendMessage(121, 126, UpDownRoundLimit.Value);
				TabComm.SendMessage(120, 126);
			}
		}
		else if (event == DE_MouseMove)
		{
			Hint = TextHintRoundLimit;
			AltHint = "";
		}
		else if (event == DE_MouseLeave)
		{
			Hint = TextHintDefault;
			AltHint = TextHintDefaultAlt;
		}
	}
	// Round Duration
	if (control == UpDownRoundTime)
	{
		if (event == DE_Click)
		{
			if (TabComm != None)
			{
				TabComm.SendMessage(121, 103, UpDownRoundTime.Value);
				TabComm.SendMessage(120, 103);
			}
		}
		else if (event == DE_MouseMove)
		{
			Hint = TextHintRoundTime;
			AltHint = "";
		}
		else if (event == DE_MouseLeave)
		{
			Hint = TextHintDefault;
			AltHint = TextHintDefaultAlt;
		}
	}
	// Ballistics
	if (control == CheckBoxBallistics)
	{
		if (event == DE_Click)
		{
			if (TabComm != None)
			{
				TabComm.SendMessage(121, 104, , , , CheckBoxBallistics.bChecked);
				TabComm.SendMessage(120, 104);
			}
		}
		else if (event == DE_MouseMove)
		{
			Hint = TextHintBallistics;
			AltHint = "";
		}
		else if (event == DE_MouseLeave)
		{
			Hint = TextHintDefault;
			AltHint = TextHintDefaultAlt;
		}
	}
	// Ghostcam
	if (control == CheckBoxGhostcam)
	{
		if (event == DE_Click)
		{
			if (TabComm != None)
			{
				TabComm.SendMessage(121, 105, , , , CheckBoxGhostcam.bChecked);
				TabComm.SendMessage(120, 105);
			}
		}
		else if (event == DE_MouseMove)
		{
			Hint = TextHintGhostCam;
			AltHint = "";
		}
		else if (event == DE_MouseLeave)
		{
			Hint = TextHintDefault;
			AltHint = TextHintDefaultAlt;
		}
	}
	// PunishTK
	if (control == CheckBoxPunishTK)
	{
		if (event == DE_Click)
		{
			if (TabComm != None)
			{
				TabComm.SendMessage(121, 106, , , , CheckBoxPunishTK.bChecked);
				TabComm.SendMessage(120, 106);
			}
		}
		else if (event == DE_MouseMove)
		{
			Hint = TextHintPunishTK;
			AltHint = "";
		}
		else if (event == DE_MouseLeave)
		{
			Hint = TextHintDefault;
			AltHint = TextHintDefaultAlt;
		}
	}
	// EnhVoteSystem
	if (control == CheckBoxEnhVote)
	{
		if (event == DE_Click)
		{
			if (TabComm != None)
			{
				TabComm.SendMessage(121, 107, , , , CheckBoxEnhVote.bChecked);
				TabComm.SendMessage(120, 107);
			}
		}
		else if (event == DE_MouseMove)
		{
			Hint = TextHintEnhVote;
			AltHint = "";
		}
		else if (event == DE_MouseLeave)
		{
			Hint = TextHintDefault;
			AltHint = TextHintDefaultAlt;
		}
	}
	// AutoMkTeams
	if (control == CheckBoxAutoMkTeams)
	{
		if (event == DE_Click)
		{
			if (TabComm != None)
			{
				TabComm.SendMessage(121, 108, , , , CheckBoxAutoMkTeams.bChecked);
				TabComm.SendMessage(120, 108);
			}
		}
		else if (event == DE_MouseMove)
		{
			Hint = TextHintAutoMkTeams;
			AltHint = "";
		}
		else if (event == DE_MouseLeave)
		{
			Hint = TextHintDefault;
			AltHint = TextHintDefaultAlt;
		}
	}
	// PlayerBackup
	if (control == CheckBoxPlayerBackup)
	{
		if (event == DE_Click)
		{
			if (TabComm != None)
			{
				TabComm.SendMessage(121, 109, , , , CheckBoxPlayerBackup.bChecked);
				TabComm.SendMessage(120, 109);
			}
		}
		else if (event == DE_MouseMove)
		{
			Hint = TextHintPlayerBackup;
			AltHint = "";
		}
		else if (event == DE_MouseLeave)
		{
			Hint = TextHintDefault;
			AltHint = TextHintDefaultAlt;
		}
	}
	// CWMode
	if (control == CheckBoxCWMode)
	{
		if (event == DE_Click)
		{
			if (TabComm != None)
			{
				TabComm.SendMessage(121, 125, , , , CheckBoxCWMode.bChecked);
				TabComm.SendMessage(120, 125);
			}
		}
		else if (event == DE_MouseMove)
		{
			Hint = TextHintCWMode;
			AltHint = "";
		}
		else if (event == DE_MouseLeave)
		{
			Hint = TextHintDefault;
			AltHint = TextHintDefaultAlt;
		}
	}
	// AllowBehindView
	if (control == CheckBoxBehindView)
	{
		if (event == DE_Click)
		{
			if (TabComm != None)
			{
				TabComm.SendMessage(121, 127, , , , CheckBoxBehindView.bChecked);
				TabComm.SendMessage(120, 127);
			}
		}
		else if (event == DE_MouseMove)
		{
			Hint = TextHintBehindView;
			AltHint = "";
		}
		else if (event == DE_MouseLeave)
		{
			Hint = TextHintDefault;
			AltHint = TextHintDefaultAlt;
		}
	}

	// X Settings Page

	// Set Slot Password
	if (control == ButtonSetSlotPwd)
	{
		if (event == DE_Click)
		{
			if (TabComm != None)
			{
				TabComm.SendMessage(121, 140, , , EditSlotPwd.GetValue());
				TabComm.SendMessage(120, 140);
			}
		}
		else if (event == DE_MouseMove)
		{
			Hint = TextHintSlotPwd;
			AltHint = "";
		}
		else if (event == DE_MouseLeave)
		{
			Hint = TextHintDefault;
			AltHint = TextHintDefaultAlt;
		}
	}
	// Set Tag
	if (control == ButtonSetTag)
	{
		if (event == DE_Click)
		{
			if (TabComm != None)
			{
				TabComm.SendMessage(121, 144, , , EditTag.GetValue());
				TabComm.SendMessage(120, 144);
			}
		}
		else if (event == DE_MouseMove)
		{
			Hint = TextHintTag;
			AltHint = "";
		}
		else if (event == DE_MouseLeave)
		{
			Hint = TextHintDefault;
			AltHint = TextHintDefaultAlt;
		}
	}
	// First Preround
	if (control == UpDownPreRound)
	{
		if (event == DE_Click)
		{
			if (TabComm != None)
			{
				TabComm.SendMessage(121, 142, UpDownPreRound.Value);
				TabComm.SendMessage(120, 142);
			}
		}
		else if (event == DE_MouseMove)
		{
			Hint = TextHintPreRound;
			AltHint = "";
		}
		else if (event == DE_MouseLeave)
		{
			Hint = TextHintDefault;
			AltHint = TextHintDefaultAlt;
		}
	}
	// Number reserved slots
	if (control == UpDownNumberSlot)
	{
		if (event == DE_Click)
		{
			if (TabComm != None)
			{
				TabComm.SendMessage(121, 141, UpDownNumberSlot.Value);
				TabComm.SendMessage(120, 141);
			}
		}
		else if (event == DE_MouseMove)
		{
			Hint = TextHintNumberSlot;
			AltHint = "";
		}
		else if (event == DE_MouseLeave)
		{
			Hint = TextHintDefault;
			AltHint = TextHintDefaultAlt;
		}
	}
	// UpDownMaxWarnings
	if (control == UpDownMaxWarnings)
	{
		if (event == DE_Click)
		{
			if (TabComm != None)
			{
				TabComm.SendMessage(121, 143, UpDownMaxWarnings.Value);
				TabComm.SendMessage(120, 143);
			}
		}
		else if (event == DE_MouseMove)
		{
			Hint = TextHintMaxWarnings;
			AltHint = "";
		}
		else if (event == DE_MouseLeave)
		{
			Hint = TextHintDefault;
			AltHint = TextHintDefaultAlt;
		}
	}
	// Make Clanteams
	if (control == CheckBoxMakeClanTeams)
	{
		if (event == DE_Click)
		{
			if (TabComm != None)
			{
				TabComm.SendMessage(121, 145, , , , CheckBoxMakeClanTeams.bChecked);
				TabComm.SendMessage(120, 145);
			}
		}
		else if (event == DE_MouseMove)
		{
			Hint = TextHintMakeClanTeams;
			AltHint = "";
		}
		else if (event == DE_MouseLeave)
		{
			Hint = TextHintDefault;
			AltHint = TextHintDefaultAlt;
		}
	}
	// Enable HitParade
	if (control == CheckBoxHitParade)
	{
		if (event == DE_Click)
		{
			if (TabComm != None)
			{
				TabComm.SendMessage(121, 190, , , , CheckBoxHitParade.bChecked);
				CheckBoxHitParade.bChecked = false;	// optional Piece
				TabComm.SendMessage(120, 190);
			}
		}
		else if (event == DE_MouseMove)
		{
			Hint = TextHintHitParade;
			AltHint = "";
		}
		else if (event == DE_MouseLeave)
		{
			Hint = TextHintDefault;
			AltHint = TextHintDefaultAlt;
		}
	}
	// Enable Announcer
	if (control == CheckBoxAnnouncer)
	{
		if (event == DE_Click)
		{
			if (TabComm != None)
			{
				TabComm.SendMessage(121, 200, , , , CheckBoxAnnouncer.bChecked);
				CheckBoxAnnouncer.bChecked = false;	// optional Piece
				TabComm.SendMessage(120, 200);
			}
		}
		else if (event == DE_MouseMove)
		{
			Hint = TextHintAnnouncer;
			AltHint = "";
		}
		else if (event == DE_MouseLeave)
		{
			Hint = TextHintDefault;
			AltHint = TextHintDefaultAlt;
		}
	}
	// Enable TOP3 Support
	if (control == CheckBoxEnableTOP)
	{
		if (event == DE_Click)
		{
			if (TabComm != None)
			{
				if (!CheckBoxEnableTOP.bChecked) i = 0;
				else if (CheckBoxForceTOP.bChecked) i = 2;
				else i = 1;
				TabComm.SendMessage(121, 170, i);
				CheckBoxEnableTOP.bChecked = false;	// optional Piece
				TabComm.SendMessage(120, 170);
			}
		}
		else if (event == DE_MouseMove)
		{
			Hint = TextHintEnableTOP;
			AltHint = "";
		}
		else if (event == DE_MouseLeave)
		{
			Hint = TextHintDefault;
			AltHint = TextHintDefaultAlt;
		}
	}
	// Force TOP3 Support
	if (control == CheckBoxForceTOP)
	{
		if (event == DE_Click)
		{
			if (TabComm != None)
			{
				if (CheckBoxForceTOP.bChecked) i = 2;
				else if (CheckBoxEnableTOP.bChecked) i = 1;
				else i = 1;
				TabComm.SendMessage(121, 170, i);
				CheckBoxForceTOP.bChecked = false;	// optional Piece
				TabComm.SendMessage(120, 170);
			}
		}
		else if (event == DE_MouseMove)
		{
			Hint = TextHintEnableTOP;
			AltHint = "";
		}
		else if (event == DE_MouseLeave)
		{
			Hint = TextHintDefault;
			AltHint = TextHintDefaultAlt;
		}
	}
	// Enable Warpix
	if (control == CheckBoxWarpix)
	{
		if (event == DE_Click)
		{
			if (TabComm != None)
			{
				TabComm.SendMessage(121, 171, , , , CheckBoxWarpix.bChecked);
				CheckBoxWarpix.bChecked = false;	// optional Piece
				TabComm.SendMessage(120, 171);
			}
		}
		else if (event == DE_MouseMove)
		{
			Hint = TextHintWarpix;
			AltHint = "";
		}
		else if (event == DE_MouseLeave)
		{
			Hint = TextHintDefault;
			AltHint = TextHintDefaultAlt;
		}
	}

	// Damage Page

	// FF Scale
	if (control == UpDownFFScale)
	{
		if (event == DE_Click)
		{
			if (TabComm != None)
			{
				TabComm.SendMessage(121, 110, UpDownFFScale.Value);
				TabComm.SendMessage(120, 110);
			}
		}
		else if (event == DE_MouseMove)
		{
			Hint = TextHintFFScale;
			AltHint = "";
		}
		else if (event == DE_MouseLeave)
		{
			Hint = TextHintDefault;
			AltHint = TextHintDefaultAlt;
		}
	}
	// ExplosionFF
	if (control == CheckBoxExplosionFF)
	{
		if (event == DE_Click)
		{
			if (TabComm != None)
			{
				TabComm.SendMessage(121, 111, , , , CheckBoxExplosionFF.bChecked);
				TabComm.SendMessage(120, 111);
			}
		}
		else if (event == DE_MouseMove)
		{
			Hint = TextHintExplosionFF;
			AltHint = "";
		}
		else if (event == DE_MouseLeave)
		{
			Hint = TextHintDefault;
			AltHint = TextHintDefaultAlt;
		}
	}
	// MirrorDmg
	if (control == CheckBoxMirrorDmg)
	{
		if (event == DE_Click)
		{
			if (TabComm != None)
			{
				TabComm.SendMessage(121, 112, , , , CheckBoxMirrorDmg.bChecked);
				TabComm.SendMessage(120, 112);
			}
		}
		else if (event == DE_MouseMove)
		{
			Hint = TextHintMirrorDmg;
			AltHint = "";
		}
		else if (event == DE_MouseLeave)
		{
			Hint = TextHintDefault;
			AltHint = TextHintDefaultAlt;
		}
	}
	// TK Handling
	if (control == CheckBoxTKHandling)
	{
		if (event == DE_Click)
		{
			if (TabComm != None)
			{
				TabComm.SendMessage(121, 113, , , , CheckBoxTKHandling.bChecked);
				TabComm.SendMessage(120, 113);
			}
		}
		else if (event == DE_MouseMove)
		{
			Hint = TextHintTKHandling;
			AltHint = "";
		}
		else if (event == DE_MouseLeave)
		{
			Hint = TextHintDefault;
			AltHint = TextHintDefaultAlt;
		}
	}
	// MaxTK
	if (control == UpDownMaxTK)
	{
		if (event == DE_Click)
		{
			if (TabComm != None)
			{
				TabComm.SendMessage(121, 114, UpDownMaxTK.Value);
				TabComm.SendMessage(120, 114);
			}
		}
		else if (event == DE_MouseMove)
		{
			Hint = TextHintMaxTK;
			AltHint = "";
		}
		else if (event == DE_MouseLeave)
		{
			Hint = TextHintDefault;
			AltHint = TextHintDefaultAlt;
		}
	}
	// Min Allowed Score
	if (control == 	UpDownMinAllowedScore)
	{
		if (event == DE_Click)
		{
			if (TabComm != None)
			{
				TabComm.SendMessage(121, 115, UpDownMinAllowedScore.Value);
				TabComm.SendMessage(120, 115);
			}
		}
		else if (event == DE_MouseMove)
		{
			Hint = TextHintMinAllowedScore;
			AltHint = "";
		}
		else if (event == DE_MouseLeave)
		{
			Hint = TextHintDefault;
			AltHint = TextHintDefaultAlt;
		}
	}
	// HP Messages
	if (control == CheckBoxHPMessage)
	{
		if (event == DE_Click)
		{
			if (TabComm != None)
			{
				TabComm.SendMessage(121, 116, , , , CheckBoxHPMessage.bChecked);
				TabComm.SendMessage(120, 116);
			}
		}
		else if (event == DE_MouseMove)
		{
			Hint = TextHintHPMessage;
			AltHint = "";
		}
		else if (event == DE_MouseLeave)
		{
			Hint = TextHintDefault;
			AltHint = TextHintDefaultAlt;
		}
	}

	// Map Page

	// NextMapHandling
	if (control == CheckBoxNextMap)
	{
		if (event == DE_Click)
		{
			if (TabComm != None)
			{
				TabComm.SendMessage(121, 117, , , , CheckBoxNextMap.bChecked);
				TabComm.SendMessage(120, 117);
			}
		}
		else if (event == DE_MouseMove)
		{
			Hint = TextHintNextMap;
			AltHint = "";
		}
		else if (event == DE_MouseLeave)
		{
			Hint = TextHintDefault;
			AltHint = TextHintDefaultAlt;
		}
	}
	// MapVote
	if (control == CheckBoxMapVote)
	{
		if (event == DE_Click)
		{
			if (TabComm != None)
			{
				TabComm.SendMessage(121, 118, , , , CheckBoxMapVote.bChecked);
				TabComm.SendMessage(120, 118);
			}
		}
		else if (event == DE_MouseMove)
		{
			Hint = TextHintMapVote;
			AltHint = "";
		}
		else if (event == DE_MouseLeave)
		{
			Hint = TextHintDefault;
			AltHint = TextHintDefaultAlt;
		}
	}
	// MV Perc InGame
	if (control == UpDownMVPercInGame)
	{
		if (event == DE_Click)
		{
			if (TabComm != None)
			{
				TabComm.SendMessage(121, 119, UpDownMVPercInGame.Value);
				TabComm.SendMessage(120, 119);
			}
		}
		else if (event == DE_MouseMove)
		{
			Hint = TextHintMVPercInGame;
			AltHint = "";
		}
		else if (event == DE_MouseLeave)
		{
			Hint = TextHintDefault;
			AltHint = TextHintDefaultAlt;
		}
	}
	// MV Perc MapEnd
	if (control == UpDownMVPercMapEnd)
	{
		if (event == DE_Click)
		{
			if (TabComm != None)
			{
				TabComm.SendMessage(121, 120, UpDownMVPercMapEnd.Value);
				TabComm.SendMessage(120, 120);
			}
		}
		else if (event == DE_MouseMove)
		{
			Hint = TextHintMVPercMapEnd;
			AltHint = "";
		}
		else if (event == DE_MouseLeave)
		{
			Hint = TextHintDefault;
			AltHint = TextHintDefaultAlt;
		}
	}
	// MapVoteMode
	if (control == ButtonMVPrevMode || control == ButtonMVNextMode)
	{
		if (event == DE_Click)
		{
			MVMode = 1-MVMode;
			if (TabComm != None)
			{
				TabComm.SendMessage(121, 121, MVMode);
				TabComm.SendMessage(120, 121);
			}
		}
		else if (event == DE_MouseMove)
		{
			Hint = TextHintMVMode;
			AltHint = "";
		}
		else if (event == DE_MouseLeave)
		{
			Hint = TextHintDefault;
			AltHint = TextHintDefaultAlt;
		}
	}
	// MV VoteTime
	if (control == 	UpDownMVTime)
	{
		if (event == DE_Click)
		{
			if (TabComm != None)
			{
				TabComm.SendMessage(121, 122, UpDownMVTime.Value);
				TabComm.SendMessage(120, 122);
			}
		}
		else if (event == DE_MouseMove)
		{
			Hint = TextHintMVTime;
			AltHint = "";
		}
		else if (event == DE_MouseLeave)
		{
			Hint = TextHintDefault;
			AltHint = TextHintDefaultAlt;
		}
	}
	// MV NoReplay
	if (control == 	UpDownMVNoReplay)
	{
		if (event == DE_Click)
		{
			if (TabComm != None)
			{
				TabComm.SendMessage(121, 123, UpDownMVNoReplay.Value);
				TabComm.SendMessage(120, 123);
			}
		}
		else if (event == DE_MouseMove)
		{
			Hint = TextHintMVNoReplay;
			AltHint = "";
		}
		else if (event == DE_MouseLeave)
		{
			Hint = TextHintDefault;
			AltHint = TextHintDefaultAlt;
		}
	}

	// Settings Page

	for (i=0; i<10; i++)
	{
		if (control == ButtonSave[i] || control == ButtonLoad[i])
		{
			if (event == DE_Click)
			{
				if (TabComm != None)
				{
					if (control == ButtonSave[i])
						TabComm.SendMessage(140, i, , , EditSettings[i].GetValue());
					else
						TabComm.SendMessage(141, i, , , , false);
					TabComm.SendMessage(120, 124);
				}
			}
			else if (event == DE_MouseMove)
			{
				if (control == ButtonSave[i])
					Hint = TextHintSaveSettings;
				else
					Hint = TextHintLoadSettings;
				AltHint = "";
			}
			else if (event == DE_MouseLeave)
			{
				Hint = TextHintDefault;
				AltHint = TextHintDefaultAlt;
			}
		}
	}

	// GameType Page

	for (i=0; i<10; i++)
	{
		if (control == ButtonChange[i])
		{
			if (event == DE_Click)
			{
				if (TabComm != None)
				{
					TabComm.SendMessage(155, i);
					TabComm.SendMessage(120, 129);
				}
			}
			else if (event == DE_MouseMove)
			{
				Hint = TextHintGameTypeChange;
				AltHint = "";
			}
			else if (event == DE_MouseLeave)
			{
				Hint = TextHintDefault;
				AltHint = TextHintDefaultAlt;
			}
		}
	}

	// Banlist page

	// Select ListItem
	if (control == BoxBanList)
	{
		if (event == DE_Click)
		{
			if (BoxBanList.GetSelected() != -1)
				TabComm.SendMessage(182, BoxBanList.GetData(BoxBanList.GetSelected()));
			else
				ClearBanDetails();
		}
		else if (event == DE_MouseMove)
		{
			Hint = TextHintBanList;
			AltHint = "";
		}
		else if (event == DE_MouseLeave)
		{
			Hint = TextHintDefault;
			AltHint = TextHintDefaultAlt;
		}
	}
	// Prev
	if (control == ButtonBanPrevDuration)
	{
		if (event == DE_Click)
		{
			GetBanDuration(-1);
		}
	}
	// Next
	if (control == ButtonBanNextDuration)
	{
		if (event == DE_Click)
		{
			GetBanDuration(1);
		}
	}
	// Add
	if (control == ButtonBanSave)
	{
		if (event == DE_Click)
		{
			CurrentBanIndex = 0;
			TabComm.SendMessage(183, , , , AssambleBanDetails());
			ClearBanDetails();
		}
		else if (event == DE_MouseMove)
		{
			Hint = TextHintBanSave;
			AltHint = "";
		}
		else if (event == DE_MouseLeave)
		{
			Hint = TextHintDefault;
			AltHint = TextHintDefaultAlt;
		}
	}
	// Remove
	if (control == ButtonBanRemove)
	{
		if (event == DE_Click)
		{
			CurrentBanIndex = 0;
			TabComm.SendMessage(184, , , , EditVictimIP.GetValue());
			ClearBanDetails();
		}
		else if (event == DE_MouseMove)
		{
			Hint = TextHintBanRemove;
			AltHint = "";
		}
		else if (event == DE_MouseLeave)
		{
			Hint = TextHintDefault;
			AltHint = TextHintDefaultAlt;
		}
	}
	// Search
	if (control == ButtonBanSearch)
	{
		if (event == DE_Click)
		{
			TabComm.SendMessage(181, , , , EditBanSearch.GetValue());
		}
		else if (event == DE_MouseMove)
		{
			Hint = TextHintBanSearch;
			AltHint = "";
		}
		else if (event == DE_MouseLeave)
		{
			Hint = TextHintDefault;
			AltHint = TextHintDefaultAlt;
		}
	}
}

simulated function	CloseCurrentPage()
{
	HideCurrentPage();
}

simulated function	LoadCurrentPage()
{
	if (TabComm != none)
	{
		switch (CurrentPage)
		{
			case 0 :	TabComm.SendMessage(120, 100);
						TabComm.SendMessage(120, 101);
						TabComm.SendMessage(120, 102);
						TabComm.SendMessage(120, 103);
						TabComm.SendMessage(120, 104);
						TabComm.SendMessage(120, 105);
						TabComm.SendMessage(120, 106);
						TabComm.SendMessage(120, 107);
						TabComm.SendMessage(120, 108);
						TabComm.SendMessage(120, 109);
						TabComm.SendMessage(120, 125);
						TabComm.SendMessage(120, 126);
						TabComm.SendMessage(120, 127);
						break;
			case 1 :	TabComm.SendMessage(120, 140);
						TabComm.SendMessage(120, 141);
						TabComm.SendMessage(120, 142);
						TabComm.SendMessage(120, 143);
						TabComm.SendMessage(120, 144);
						TabComm.SendMessage(120, 145);
						TabComm.SendMessage(120, 170);
						TabComm.SendMessage(120, 171);
						TabComm.SendMessage(120, 190);
						TabComm.SendMessage(120, 200);
						break;
			case 2 :	TabComm.SendMessage(120, 110);
						TabComm.SendMessage(120, 111);
						TabComm.SendMessage(120, 112);
						TabComm.SendMessage(120, 113);
						TabComm.SendMessage(120, 114);
						TabComm.SendMessage(120, 115);
						TabComm.SendMessage(120, 116);
						break;
			case 3 :	TabComm.SendMessage(120, 117);
						TabComm.SendMessage(120, 118);
						TabComm.SendMessage(120, 119);
						TabComm.SendMessage(120, 120);
						TabComm.SendMessage(120, 121);
						TabComm.SendMessage(120, 122);
						TabComm.SendMessage(120, 123);
						break;
			case 4 :	TabComm.SendMessage(120, 128);
						TabComm.SendMessage(120, 129);
						break;
			case 5 :	TabComm.SendMessage(120, 124);
						break;
			case 6 :	GetBanDuration();
						ClearBanDetails();
						TabComm.SendMessage(180);
						break;
			case 7 :
						break;
		}
	}
}

simulated function	OpenCurrentPage()
{
	switch (CurrentPage)
	{
		case 0 :	LabelPage.Text="Rules";
					break;
		case 1 :	LabelPage.Text="Extra Settings";
					break;
		case 2 :	LabelPage.Text="Damage Settings";
					break;
		case 3 :	LabelPage.Text="Map Settings";
					break;
		case 4 :	LabelPage.Text="Game Type";
					break;
		case 5 :	LabelPage.Text="Settings";
					break;
		case 6 :	LabelPage.Text="Ban Management";
					break;
		case 7 :	LabelPage.Text="Semi Admin";
					break;
	}
	LoadCurrentPage();
	ShowCurrentPage();
}

simulated function int	SettingsVisible()
{
	switch Resolution {
		case 0 : return 7;
				 break;
		case 1 : return 9;
				 break;
		default : return 10;
				  break;
	}
}

simulated function	ShowCurrentPage()
{
	local	int	i;
	switch (CurrentPage)
	{
		case 0 :	EditAdminPwd.ShowWindow();
					EditGamePwd.ShowWindow();
					ButtonSetAdminPwd.ShowWindow();
					ButtonSetGamePwd.ShowWindow();
					CheckBoxGhostcam.ShowWindow();
					CheckBoxBallistics.ShowWindow();
					CheckBoxPlayerBackup.ShowWindow();
					CheckBoxPunishTK.ShowWindow();
					CheckBoxEnhVote.ShowWindow();
					CheckBoxAutoMkTeams.ShowWindow();
					CheckBoxCWMode.ShowWindow();
					CheckBoxBehindView.ShowWindow();
					UpDownMapTime.ShowWindow();
					UpDownRoundTime.ShowWindow();
					UpDownRoundLimit.ShowWindow();
					break;
		case 1 :	EditSlotPwd.ShowWindow();
					ButtonSetSlotPwd.ShowWindow();
					EditTag.ShowWindow();
					ButtonSetTag.ShowWindow();
					UpDownPreRound.ShowWindow();
					UpDownNumberSlot.ShowWindow();
					UpDownMaxWarnings.ShowWindow();
					CheckBoxMakeClanTeams.ShowWindow();
					CheckBoxHitParade.ShowWindow();
					CheckBoxAnnouncer.ShowWindow();
					CheckBoxEnableTOP.ShowWindow();
					CheckBoxForceTOP.ShowWindow();
					CheckBoxWarpix.ShowWindow();
					break;
		case 2 :	CheckBoxExplosionFF.ShowWindow();
					CheckBoxMirrorDmg.ShowWindow();
					CheckBoxTKHandling.ShowWindow();
					CheckBoxHPMessage.ShowWindow();
					UpDownFFScale.ShowWindow();
					UpDownMaxTK.ShowWindow();
					UpDownMinAllowedScore.ShowWindow();
					break;
		case 3 :	CheckBoxNextMap.ShowWindow();
					CheckBoxMapVote.ShowWindow();
					UpDownMVPercInGame.ShowWindow();
					UpDownMVPercMapEnd.ShowWindow();
					UpDownMVTime.ShowWindow();
					UpDownMVNoReplay.ShowWindow();
					ButtonMVNextMode.ShowWindow();
					ButtonMVPrevMode.ShowWindow();
					LabelMVMode.ShowWindow();
					break;
		case 4 :	for (i=0; i<10; i++)
					{
						LabelGameType[i].ShowWindow();
						ButtonChange[i].ShowWindow();
					}
					break;
		case 5 :	for (i=0; i<SettingsVisible(); i++)
					{
						EditSettings[i].ShowWindow();
						ButtonSave[i].ShowWindow();
						ButtonLoad[i].ShowWindow();
					}
					break;
		case 6 :	BoxBanList.ShowWindow();
					EditBanTimeStamp.ShowWindow();
					EditAdminIP.ShowWindow();
					EditAdminName.ShowWindow();
					EditVictimIP.ShowWindow();
					EditVictimName.ShowWindow();
					EditReason.ShowWindow();
					ButtonBanPrevDuration.ShowWindow();
					ButtonBanNextDuration.ShowWindow();
					LabelBanDuration.ShowWindow();
					ButtonBanSave.ShowWindow();
					ButtonBanRemove.ShowWindow();
					EditBanSearch.ShowWindow();
					ButtonBanSearch.ShowWindow();
					break;
		case 7 :
					break;
	}
}

simulated function	HideCurrentPage()
{
	local	int	i;
	switch (CurrentPage)
	{
		case 0 :	EditAdminPwd.HideWindow();
					EditGamePwd.HideWindow();
					ButtonSetAdminPwd.HideWindow();
					ButtonSetGamePwd.HideWindow();
					CheckBoxGhostcam.HideWindow();
					CheckBoxBallistics.HideWindow();
					CheckBoxPlayerBackup.HideWindow();
					CheckBoxPunishTK.HideWindow();
					CheckBoxEnhVote.HideWindow();
					CheckBoxAutoMkTeams.HideWindow();
					CheckBoxCWMode.HideWindow();
					CheckBoxBehindView.HideWindow();
					UpDownMapTime.HideWindow();
					UpDownRoundTime.HideWindow();
					UpDownRoundLimit.HideWindow();
					break;
		case 1 :	EditSlotPwd.HideWindow();
					ButtonSetSlotPwd.HideWindow();
					EditTag.HideWindow();
					ButtonSetTag.HideWindow();
					UpDownPreRound.HideWindow();
					UpDownNumberSlot.HideWindow();
					UpDownMaxWarnings.HideWindow();
					CheckBoxMakeClanTeams.HideWindow();
					CheckBoxHitParade.HideWindow();
					CheckBoxAnnouncer.HideWindow();
					CheckBoxEnableTOP.HideWindow();
					CheckBoxForceTOP.HideWindow();
					CheckBoxWarpix.HideWindow();
					break;
		case 2 :	CheckBoxExplosionFF.HideWindow();
					CheckBoxMirrorDmg.HideWindow();
					CheckBoxTKHandling.HideWindow();
					CheckBoxHPMessage.HideWindow();
					UpDownFFScale.HideWindow();
					UpDownMaxTK.HideWindow();
					UpDownMinAllowedScore.HideWindow();
					break;
		case 3 :	CheckBoxNextMap.HideWindow();
					CheckBoxMapVote.HideWindow();
					UpDownMVPercInGame.HideWindow();
					UpDownMVPercMapEnd.HideWindow();
					UpDownMVTime.HideWindow();
					UpDownMVNoReplay.HideWindow();
					ButtonMVNextMode.HideWindow();
					ButtonMVPrevMode.HideWindow();
					LabelMVMode.HideWindow();
					break;
		case 4 :	for (i=0; i<10; i++)
					{
						LabelGameType[i].HideWindow();
						ButtonChange[i].HideWindow();
					}
					break;
		case 5 :	for (i=0; i<10; i++)
					{
						EditSettings[i].HideWindow();
						ButtonSave[i].HideWindow();
						ButtonLoad[i].HideWindow();
					}
					break;
		case 6 :	BoxBanList.HideWindow();
					EditBanTimeStamp.HideWindow();
					EditAdminIP.HideWindow();
					EditAdminName.HideWindow();
					EditVictimIP.HideWindow();
					EditVictimName.HideWindow();
					EditReason.HideWindow();
					ButtonBanPrevDuration.HideWindow();
					ButtonBanNextDuration.HideWindow();
					LabelBanDuration.HideWindow();
					ButtonBanSave.HideWindow();
					ButtonBanRemove.HideWindow();
					EditBanSearch.HideWindow();
					ButtonBanSearch.HideWindow();
					break;
		case 7 :
					break;
	}

}

simulated function int BanListItemsVisible ()
{
	switch Resolution {
		case 0 : return 7; // Y < 600
		case 1 : return 12; // >=600
		case 2 : return 15; // >=768
		case 3 : return 18; // >=1024
		case 4 : return 20; // >=1200
	}
}

simulated function string GetBanDuration(optional int Action)
{
	// 0 = CurrentBanText
	// 1 = TempBan
	// 2 = 1 hour tempban
	// 3 = 1 day tempban
	// 4 = 1 week tempban
	// 5 = Permanent ban
	if (CurrentBanType < 5 && Action ==  1) CurrentBanType++;
	if (CurrentBanType > 0 && Action == -1) CurrentBanType--;
	if (CurrentBanType == 0 && CurrentBanText == "") CurrentBanType++;

	switch (CurrentBanType)
	{
		case 0	:	LabelBanDuration.Text = CurrentBanText;
					return string(CurrentBanTimeStamp);
		case 1	:	LabelBanDuration.Text = "TempBan";
					return "-2";
		case 2	:	LabelBanDuration.Text = "1 Hour TempBan";
					return "+60";
		case 3	:	LabelBanDuration.Text = "1 Day TempBan";
					return "+1440";
		case 4	:	LabelBanDuration.Text = "1 Week TempBan";
					return "+10080";
		case 5	:	LabelBanDuration.Text = "Permanent Ban";
					return "0";
	}
}


simulated function string AssambleBanDetails()
{
	local string	TempString;

	TempString = ""														$ "\\*";
	TempString = TempString $ GetBanDuration()							$ "\\*";
	TempString = TempString $ EditVictimIP.GetValue()					$ "\\*";
	TempString = TempString $ EscapeChars(EditVictimName.GetValue())	$ "\\*";
	TempString = TempString $ EditAdminIP.GetValue()					$ "\\*";
	TempString = TempString $ EscapeChars(EditAdminName.GetValue())		$ "\\*";
	TempString = TempString $ EscapeChars(EditReason.GetValue())		$ "\\*";

	return TempString;
}

simulated function ClearBanDetails()
{
	CurrentBanIndex = 0;

	CurrentBanText = "";
	CurrentBanTimeStamp = 0;
	CurrentBanType = 1;
	GetBanDuration();

	EditBanTimeStamp.SetValue("");
	EditAdminIP.SetValue("");
	EditAdminName.SetValue("");
	EditVictimIP.SetValue("");
	EditVictimName.SetValue("");
	EditReason.SetValue("");

	EditVictimIP.SetEditable(true);
	EditVictimName.SetEditable(true);
	BoxBanList.SetSelectedByIndex(BoxBanList.GetSelected(), false);
	ButtonBanSave.Text = "Add";

	// Request new banlist
	if (EditBanSearch.GetValue() == "")
		TabComm.SendMessage(180);
	else
		TabComm.SendMessage(181, , , , EditBanSearch.GetValue());
}

simulated function string EscapeChars(string Text)
{
    local int i;
    local string Output;

    i = InStr(Text, "\\");
    while (i != -1)
	{
        Output = Output $ Mid(Text, 0, i) $ "\\\\";
        Text = Mid(Text, i + 2);
        i = InStr(Text, "\\");
    }
    Output = Output $ Text;
    return Output;
}

simulated final function string	IPOnly(string IP)
{
	local	int		i;

	i = InStr(IP, ":");

	if (i != -1)
		return Mid(IP, 0, i);
	else
		return IP;
}

defaultproperties
{
	TextGameTitle="Game Tab"

	TextHintDefault="Select your actions"
	TextHintDefaultAlt="You need admin privileges to perform any of these actions"

	TextButtonClose="close"
	TextHintCloseButton="Click to close admin menu"
	TextButtonAdminTab="admintab"
	TextHintAdminTabButton="Click to switch to the admin tab"
	TextHintNextPageButton="Goto next page"
	TextHintPrevPageButton="Goto previous page"

	TextHintBallistics="Enable/disable ballistic on the server"
	TextHintGhostcam="Enable/disable the ghostcam on the server"
	TextHintPunishTK="Enable/disable punishTK on the server"
	TextHintRoundTime="Change the maximum duration of a round"
	TextHintMapTime="Change the time limit on the server"
	TextHintRoundLimit="Change the round limit on the server"
	TextHintAdminPwd="Set a new admin password on the server"
	TextHintGamePwd="Set a new game password on the server"
	TextHintEnhVote="Enable/disable the enhanced vote system on the server"
	TextHintAutoMkTeams="Enable/disable auto mkteams on the server"
	TextHintPlayerBackup="Enable/disable player backup on the server"
	TextHintCWMode="Enable/disable clan war mode"
	TextHintBehindView="Enable/disable clients to use behindview"

    TextHintDefault="Select your actions"
    TextHintDefaultAlt="You need admin privileges to perform any of these actions"
    TextAdminWarning="You are currently not logged in as admin!"
    TextHintCloseButton="Click to close ExtraTools menu"
    TextHintAdminTabButton="Click to switch to the admin tab"
    TextHintSlotPwd="Set a new slot resever password on the server"
    TextHintTag="Set a new tag for MkClanTeams"
    TextHintPreRound="Change the first preround duration after map switch"
    TextHintNumberSlot="Change the number of reserved slots"
    TextHintMakeClanTeams="Enable/Disable auto MkClanTeams on the server"
    TextHintHitParade="Disable/Enable TOST Hitparade (if loaded)"
    TextHintAnnouncer="Disable/Enable TOST Announcer (if loaded)"
    TextHintEnableTop="Disable/Enable/Force TO-Protect Support (if loaded)"
    TextHintWarPix="Disable/Enable Warpix on CWMode (if loaded)"

	TextHintExplosionFF="Enable/disable FF from explosions (nades)"
	TextHintMirrorDmg="Enable/disable mirror damage"
	TextHintTKHandling="Enable/disable TOST TK Handling"
	TextHintHPMessage="Enable/disable TOST HP Messages"
	TextHintFFScale="Friendly Fire scale"
	TextHintMaxTK="Max allowed TKs"
	TextHintMinAllowedScore="Min allowed Score"

	TextHintNextMap="Enable/disable TOST NextMap Handling"
	TextHintMapVote="Enable/disable TOST MapVote"
	TextHintMVPercInGame="Needed votes to change map in game"
	TextHintMVPercMapEnd="Needed votes to change map at end of game"
	TextHintMVTime="Time to vote for maps"
	TextHintMVNoReplay="Number of maps until map is again allowed"
	TextHintMVMode="MapVote Mode"

   	TextHintLoadSettings="Load previously saved settings from this slot"
	TextHintSaveSettings="Save current settings to this slot"

	TextHintGameTypeChange="Switch game type"

	TextHintBanList="Select an item to view/edit details"
	TextHintBanSearch="Search for ban by IP or Name"
    TextHintBanSave="Update/Add Ban"
    TextHintBanRemove="Remove Ban"

	TextAdminWarning="You are currently not logged in as admin!"

	ShowNav=true

	TabName="TOST GameTab"

	TabCommClass=class'TOSTGameTabComm'

	MaxPages=7
}
