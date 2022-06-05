class TO_UTServerSetupPage extends TO_ServerSetupPage;

var UWindowEditControl GamePasswordEdit;
var localized string GamePasswordText;
var localized string GamePasswordHelp;
var UWindowEditControl AdminPasswordEdit;
var localized string AdminPasswordText;
var localized string AdminPasswordHelp;
var UWindowCheckbox EnableWebserverCheck;
var localized string EnableWebserverText;
var localized string EnableWebserverHelp;
var UWindowEditControl WebAdminUsernameEdit;
var localized string WebAdminUsernameText;
var localized string WebAdminUsernameHelp;
var UWindowEditControl WebAdminPasswordEdit;
var localized string WebAdminPasswordText;
var localized string WebAdminPasswordHelp;
var UWindowEditControl ListenPortEdit;
var localized string ListenPortText;
var localized string ListenPortHelp;
var bool bInitialized;

function Created ()
{
}

function Notify (UWindowDialogControl C, byte E)
{
}

function BeforePaint (Canvas C, float X, float Y)
{
}
