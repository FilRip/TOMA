class TO_GUITabScores extends TO_GUIBaseTab;

enum ETOScoreboardSortMode
{
	SM_SCOREPTS,
	SM_KILLRATIO
};

var PlayerReplicationInfo PlayerList[32];
var byte PlayerCount;
var int TeamMaxPlayerCount;
var int SpecCount;
var int MyX;
var int MyY;
var bool bInitialized;
var ETOScoreboardSortMode SortMode;
var bool bShowMode;
var float OffsetNick[5];
var float OffsetScore[5];
var float OffsetTime[5];
var float OffsetPing[5];
var float OffsetLoc[5];
var float OffsetKills[5];
var float OffsetID[5];
var float OffsetPL[5];
var float OffsetNick2;
var float OffsetScore2;
var float OffsetPing2;
var float OffsetLoc2;
var float OffsetKills2;
var float OffsetID2;
var bool BlinkFlag;
var Texture DotTex;
var localized string TextScoresHint;
var localized string TextScoresSort;
var localized string TextScoresScore;
var localized string TextScoresScoregroup;
var localized string TextScoresPing;
var localized string TextScoresTime;
var localized string TextScoresKillratio;
var localized string TextScoresScorePts;
var localized string TextScoresOrders;
var localized string TextScoresRound;
var localized string TextScoresIn;
var localized string TextScoresTimeNick;
var localized string TextScoresLocation;
var localized string TextScoresKD;
var localized string TextScoresPL;
var localized string TextScoresID;
var localized string TextScoresPing2;
var localized string TextScoresScore2;
var localized string TextScoresTime2;

simulated function Created ()
{
}

simulated function Close (optional bool bByParent)
{
}

simulated function BeforePaint (Canvas Canvas, float X, float Y)
{
}

simulated function Paint (Canvas Canvas, float X, float Y)
{
}

simulated function OwnerTimer ()
{
}

simulated function OwnerToggleMode ()
{
}

final simulated function TOScoreboard_DrawTeamstats (Canvas Canvas)
{
}

final simulated function TOScoreboard_DrawTeamstats2 (Canvas Canvas)
{
}

final simulated function TOScoreboard_DrawTableHeader (Canvas Canvas)
{
}

final simulated function TOScoreboard_DrawPlayerList (Canvas Canvas)
{
}

simulated function RenderTOPStatus (Canvas C, TO_PRI TOPRI, float YPos, int MyX, int BoxHeight)
{
}

final simulated function TOScoreboard_DrawIcon (Canvas Canvas, float U, float V, float YPos, int MyX, int BoxHeight)
{
}

final simulated function TOScoreboard_DrawIcon2 (Canvas Canvas, float U, float V, float YPos)
{
}

final simulated function TOScoreboard_DrawPlayer (Canvas Canvas, PlayerReplicationInfo PRI, int YPos, int BoxHeight, int MyX)
{
}

final simulated function TOScoreboard_DrawPlayer2 (Canvas Canvas, PlayerReplicationInfo PRI, float YPos)
{
}

final simulated function TOScoreboard_DrawTable (Canvas Canvas, float YPos)
{
}

final simulated function string TOScoreboard_Tool_GetDescription ()
{
}

final simulated function TOScoreboard_Tool_UpdatePlayerlist ()
{
}

final simulated function bool TOScoreboard_Tool_ComparePlayer (int p1, int p2)
{
}
