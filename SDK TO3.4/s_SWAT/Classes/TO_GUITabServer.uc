class TO_GUITabServer extends TO_GUIBaseTab;

var localized string TextServerTitle;
var localized string TextMOTD;
var localized string TextContactInfo;
var localized string TextName;
var localized string TextAdmin;
var localized string TextEmail;
var localized string TextServerStats;
var localized string TextFragsLogged;
var localized string TextGamesHosted;
var localized string TextVictims;
var localized string TopPlayersText;
var localized string TextBestName;
var localized string TextBestFPH;
var localized string TextBestRecordSet;
var localized string TextUnknown;

simulated function Created ()
{
}

simulated function BeforePaint (Canvas Canvas, float X, float Y)
{
}

simulated function Paint (Canvas Canvas, float X, float Y)
{
}

simulated function TOUITabServer_DrawMOTD (Canvas Canvas, GameReplicationInfo GRI)
{
}

simulated function TOUITabServer_DrawGameStats (Canvas Canvas, GameReplicationInfo GRI)
{
}

simulated function TOUITabServer_DrawServerStats (Canvas Canvas, GameReplicationInfo GRI)
{
}

simulated function TOUITabServer_DrawLeaderBoard (Canvas Canvas, GameReplicationInfo GRI)
{
}
