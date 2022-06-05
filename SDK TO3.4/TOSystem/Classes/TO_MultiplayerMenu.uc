class TO_MultiplayerMenu extends UWindowPulldownMenu;

var config string OnlineServices[10];
var UWindowPulldownMenuItem OnlineServiceItems[10];
var string OnlineServiceCmdType[10];
var string OnlineServiceCmdAction[10];
var string OnlineServiceHelp[10];
var int OnlineServiceCount;
var UWindowPulldownMenuItem Start;
var UWindowPulldownMenuItem Browser;
var UWindowPulldownMenuItem LAN;
var UWindowPulldownMenuItem Patch;
var UWindowPulldownMenuItem Disconnect;
var UWindowPulldownMenuItem Reconnect;
var UWindowPulldownMenuItem OpenLocation;
var UBrowserMainWindow BrowserWindow;
var localized string StartName;
var localized string StartHelp;
var localized string BrowserName;
var localized string BrowserHelp;
var localized string LANName;
var localized string LANHelp;
var localized string OpenLocationName;
var localized string OpenLocationHelp;
var localized string PatchName;
var localized string PatchHelp;
var localized string DisconnectName;
var localized string DisconnectHelp;
var localized string ReconnectName;
var localized string ReconnectHelp;
var localized string SuggestPlayerSetupTitle;
var localized string SuggestPlayerSetupText;
var localized string SuggestNetspeedTitle;
var localized string SuggestNetspeedText;
var config string UBrowserClassName;
var config string StartGameClassName;
var UWindowMessageBox SuggestPlayerSetup;
var UWindowMessageBox SuggestNetspeed;
var bool bOpenLocation;
var bool bOpenLAN;
var UWindowPulldownMenuItem LV_URL;
var localized string LV_URLName;
var localized string LV_URLHelp;

function Created ()
{
}

function WindowShown ()
{
}

function ResolutionChanged (float W, float H)
{
}

function NotifyQuitUnreal ()
{
}

function NotifyBeforeLevelChange ()
{
}

function NotifyAfterLevelChange ()
{
}

function Select (UWindowPulldownMenuItem i)
{
}

function ExecuteItem (UWindowPulldownMenuItem i)
{
}

function MessageBoxDone (UWindowMessageBox W, MessageBoxResult Result)
{
}

function LoadUBrowser ()
{
}

function string ParseOption (string Input, int pos)
{
}
