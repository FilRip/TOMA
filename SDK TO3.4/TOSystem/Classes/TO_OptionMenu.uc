class TO_OptionMenu extends UWindowPulldownMenu;

var UWindowPulldownMenuItem Preferences;
var UWindowPulldownMenuItem Desktop;
var UWindowPulldownMenuItem Advanced;
var UWindowPulldownMenuItem Player;
var localized string PreferencesName;
var localized string PreferencesHelp;
var localized string DesktopName;
var localized string DesktopHelp;
var localized string PlayerMenuName;
var localized string PlayerMenuHelp;
var Class<UWindowWindow> PlayerWindowClass;
var Class<UWindowWindow> WeaponPriorityWindowClass;

function Created ()
{
}

function UWindowWindow PlayerSetup ()
{
}

function ShowPreferences (optional bool bNetworkSettings)
{
}

function ExecuteItem (UWindowPulldownMenuItem i)
{
}

function Select (UWindowPulldownMenuItem i)
{
}
