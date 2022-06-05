class TO_TeamSelect extends UWindowDialogClientWindow;

enum EMenuItem
{
	MI_SERVER,
	MI_TEAM,
	MI_SKIN,
	MI_CREDITS
};

var TO_TeamSelectButton BtnExitGame;
var TO_TeamSelectButton BtnPrev;
var TO_TeamSelectButton BtnNext;
var TO_TeamSelectButton BtnEnter;
var TO_TeamSelectButton BtnServerQt;
var TO_TeamSelectButton BtnServerDis;
var TO_TeamSelectButton BtnMiscBack;
var TO_TeamSelectButton BtnServerSF;
var TO_TeamSelectButton BtnServerTR;
var TO_TeamSelectButton BtnRndTeam;
var TO_TeamSelectButton BtnTeamJnSF;
var TO_TeamSelectButton BtnTeamJnTR;
var Color WhiteColor;
var Color BlueColor;
var Color DarkBlueColor;
var Color RedColor;
var Color DarkRedColor;
var EMenuItem MenuItem;
var EMenuItem menuNext;
var int menuFadingFrame;
var int menuFadingSpeed;
var int menuTeam;
var int menuSkin;
var config int LastUsedSFSkin;
var config int LastUsedTRSkin;
var bool bRandomTeam;
var float XO;
var float YO;
var float xm;
var float ym;
var float We;
var float he;
var float Scale;
var string ModelHandlerClass;
var Class<TO_ModelHandler> ModelHandler;
var TO_MeshActor MeshActor;
var Rotator CenterRotator;
var Rotator ViewRotator;
var TO_Credits Credits;
var int LastUsedSFPrevSkin;
var int LastUsedTRPrevSkin;
var Color ColorGrey;
var Color ColorGreyH;
var Color ColorRed;
var Color ColorRedH;
var Color ColorBlue;
var Color ColorBlueH;
var Color ColorGreen;
var Color ColorGreenH;
var Color ColorYellow;
var Color ColorYellowH;
var localized string LS_Server;
var localized string LS_Admin;
var localized string LS_Email;
var localized string LS_Scenario;
var localized string LS_Author;
var localized string LS_IdealPlayerCount;
var localized string LS_Terrorists;
var localized string LS_SpecialForces;
var localized string LS_RemainingRoundTime;
var localized string LS_RemainingTotalTime;
var localized string LS_PreRound;
var localized string LS_AllowGhostCam;
var localized string LS_MirrorDamage;
var localized string LS_Ballistics;
var localized string LS_FriendlyFireScale;
var localized string LS_Team;
var localized string LS_Nick;
var localized string LS_Score;
var localized string LS_Time;
var localized string LS_Ping;
var localized string LS_Players;
var localized string LS_Wins;
var localized string LS_Info;
var localized string LS_ModelSelection;
var localized string LS_ExitGame;
var localized string LS_Credits;
var localized string LS_VictoryAtAnyCost;
var localized string LS_Btn_Exit;
var localized string LS_Btn_Back;
var localized string LS_Btn_Quit;
var localized string LS_Btn_Disconnect;
var localized string LS_Btn_SF;
var localized string LS_Btn_TR;
var localized string LS_Btn_Random;
var localized string LS_Btn_Prev;
var localized string LS_Btn_Next;
var localized string LS_Btn_Enter;
var localized string LS_Btn_JoinSF;
var localized string LS_Btn_JoinTR;
var localized string LS_bPlayersBalanceTeam;
var localized string LS_bPlayersBalanceTeam2;
var localized string LS_WaitForGRI;
var localized string LS_WaitForGRI2;
var localized string LS_WaitForGRI3;
var localized string LS_on;
var localized string LS_off;

function Created ()
{
}

function ResolutionChanged (float W, float H)
{
}

function Paint (Canvas C, float X, float Y)
{
}

function Notify (UWindowDialogControl C, byte E)
{
}

function Close (optional bool bByParent)
{
}

function Tick (float DeltaTime)
{
}

function EscClose ()
{
}

function TOTeamsel_Paint (Canvas C)
{
}

function TOTeamsel_Paint_Bg (Canvas C, float X1, float X2)
{
}

function TOTeamsel_Paint_Headline (Canvas C, string hl)
{
}

function TOTeamsel_Paint_Time (Canvas C, string Prefix, int Time)
{
}

function TOTeamsel_Paint_Server (Canvas C)
{
}

function TOTeamsel_Paint_Team (Canvas C)
{
}

function TOTeamsel_Paint_Skin (Canvas C)
{
}

function TOTeamsel_Paint_Credits (Canvas C)
{
}

function string TOTeamsel_Tool_Init ()
{
}

function TO_TeamSelectButton AddButton (int X, int Y, int W, int H, Texture BG, string txt, Color ct, Color co)
{
}

function TOTeamsel_Btn_HideAll ()
{
}

function string GetOptionStatus (bool bval)
{
}

function string TOTeamsel_Tool_TwoDigits (int Num)
{
}

function bool TOTeamsel_Tool_ChangeTeam (int NewTeam)
{
}

function DynamicLoadModelHandler ()
{
}

function SetMeshActor ()
{
}

function DelMeshActor ()
{
}

function AnimEnd (TO_MeshActor MyMesh)
{
}
