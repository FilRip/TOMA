class TO_TeamSelect extends UWindow.UWindowDialogClientWindow;

var float YO;
var float XO;
var s_GameReplicationInfo GRI;
var float xm;
var int menuSkin;
enum EMenuItem {
	MI_SERVER,
	MI_TEAM,
	MI_SKIN,
	MI_CREDITS
};
var EMenuItem MenuItem;
var TO_MeshActor MeshActor;
var int menuTeam;
var TO_Credits Credits;
var TO_TeamSelectButton BtnMiscBack;
var float he;
var TO_TeamSelectButton BtnExitGame;
var TO_ModelHandler ModelHandler;
var int menuFadingFrame;
var Color WhiteColor;
var TO_TeamSelectButton BtnTeamJnTR;
var TO_TeamSelectButton BtnPrev;
var TO_TeamSelectButton BtnTeamJnSF;
var TO_TeamSelectButton BtnRndTeam;
var TO_TeamSelectButton BtnServerTR;
var TO_TeamSelectButton BtnServerSF;
var TO_TeamSelectButton BtnServerDis;
var Color ColorGreyH;
var Color ColorGrey;
var TO_TeamSelectButton BtnServerQt;
var TO_TeamSelectButton BtnEnter;
var TO_TeamSelectButton BtnNext;
var int LastUsedTRSkin;
var int LastUsedSFSkin;
var int menuFadingSpeed;
var int PreferredTRSkin;
var int PreferredSFSkin;
var float ym;
var Rotator ViewRotator;
var float Scale;
var float We;
var Color RedColor;
var Color BlueColor;
var Color ColorRed;
var Color ColorYellowH;
var Color ColorBlueH;
var Color ColorBlue;
var Color ColorRedH;
var Color ColorYellow;
var Color ColorGreenH;
var Color ColorGreen;
var int LastUsedSFPrevSkin;
var Color DarkRedColor;
var Color DarkBlueColor;
enum EMenuItem {
	MI_SERVER,
	MI_TEAM,
	MI_SKIN,
	MI_CREDITS
};
var EMenuItem menuNext;
var bool bRandomTeam;
var Rotator CenterRotator;
var int LastUsedTRPrevSkin;

function AnimEnd (TO_MeshActor MyMesh)
{
}

function DelMeshActor ()
{
}

function SetMeshActor ()
{
}

function DynamicLoadModelHandler ()
{
}

function bool TOTeamsel_Tool_ChangeTeam (int NewTeam)
{
}

function string TOTeamsel_Tool_TwoDigits (int Num)
{
}

function string GetOptionStatus (bool bval)
{
}

function TOTeamsel_Btn_HideAll ()
{
}

function TO_TeamSelectButton AddButton (int X, int Y, int W, int H, Texture BG, string txt, Color ct, Color co)
{
}

function string TOTeamsel_Tool_Init ()
{
}

function TOTeamsel_Paint_Credits (Canvas C)
{
}

function TOTeamsel_Paint_Skin (Canvas C)
{
}

function TOTeamsel_Paint_Team (Canvas C)
{
}

function TOTeamsel_Paint_Server (Canvas C)
{
}

function TOTeamsel_Paint_Time (Canvas C, string Prefix, int Time)
{
}

function TOTeamsel_Paint_Headline (Canvas C, string hl)
{
}

function TOTeamsel_Paint_Bg (Canvas C, float X1, float X2)
{
}

function TOTeamsel_Paint (Canvas C)
{
}

function EscClose ()
{
}

function Tick (float DeltaTime)
{
}

function Close (optional bool bByParent)
{
}

function Notify (UWindowDialogControl C, byte E)
{
}

function Paint (Canvas C, float X, float Y)
{
}

function s_GameReplicationInfo FindGRIInfo ()
{
}

function Created ()
{
}

function ResolutionChanged (float W, float H)
{
}


defaultproperties
{
}

