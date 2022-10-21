class TO_GUITabScores extends TO_GUIBaseTab;

var PlayerReplicationInfo PlayerList;
var int MyY;
var float OffsetLoc2;
var float OffsetLoc;
var float OffsetKills;
var byte PlayerCount;
var float OffsetKills2;
var int MyX;
var bool BlinkFlag;
var float OffsetNick;
enum ETOScoreboardSortMode {
	SM_SCOREPTS,
	SM_KILLRATIO
};
var ETOScoreboardSortMode SortMode;
var float OffsetTime;
var bool bShowMode;
var int TeamMaxPlayerCount;
var float OffsetScore;
var float OffsetID;
var float OffsetNick2;
var float OffsetScore2;
var float OffsetID2;
var float OffsetPing2;
var int SpecCount;
var float OffsetPing;
var float OffsetPL;
var Texture DotTex;
var bool bInitialized;

final simulated function TOScoreboard_Tool_UpdatePlayerlist ()
{
}

native(27419) exec noexport function TOScoreboard_DrawPlayer (Canvas Canvas, PlayerReplicationInfo PRI, int YPos, int BoxHeight, int MyX)
{
}

final latent function TOScoreboard_DrawTeamstats (Canvas Canvas)
{
}

function TOScoreboard_DrawTeamstats2 (Canvas Canvas)
{
}

native(271) latent noexport function TOScoreboard_DrawTableHeader (Canvas Canvas)
{
}

native(27905) simulated exec function TOScoreboard_DrawPlayerList (Canvas Canvas)
{
}

final simulated function TOScoreboard_DrawIcon (Canvas Canvas, float U, float V, float YPos, int MyX, int BoxHeight)
{
}

final simulated function TOScoreboard_DrawIcon2 (Canvas Canvas, float U, float V, float YPos)
{
}

final simulated exec operator(118) TOScoreboard_DrawPlayer2 (Canvas Canvas, PlayerReplicationInfo PRI, float YPos)
{
}

final simulated function TOScoreboard_DrawTable (Canvas Canvas, float YPos)
{
}

final simulated function string TOScoreboard_Tool_GetDescription ()
{
}

final simulated function bool TOScoreboard_Tool_ComparePlayer (int p1, int p2)
{
}

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

simulated function RenderTOPStatus (Canvas C, TO_PRI TOPRI, float YPos, int MyX, int BoxHeight)
{
}


defaultproperties
{
}

