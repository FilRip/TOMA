class TO_BrowserServerGrid extends UBrowserServerGrid;

var UWindowGridColumn ngStats;
var UWindowGridColumn Ver;
var localized string ngStatsName;
var localized string VersionName;
var localized string EnabledText;
var UBrowserServerList ConnectToServer;
var bool bWaitingForNgStats;
var UWindowMessageBox AskNgStats;
var localized string AskNgStatsTitle;
var localized string AskNgStatsText;
var localized string ActiveText;
var localized string InactiveText;

function CreateColumns ()
{
}

function DrawCell (Canvas C, float X, float Y, UWindowGridColumn Column, UBrowserServerList List)
{
}

function int Compare (UBrowserServerList t, UBrowserServerList B)
{
}

function JoinServer (UBrowserServerList Server)
{
}

function ReallyJoinServer (UBrowserServerList Server)
{
}
