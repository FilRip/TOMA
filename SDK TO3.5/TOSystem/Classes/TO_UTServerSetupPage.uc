class TO_UTServerSetupPage extends TO_ServerSetupPage;

var UWindowEditControl WebAdminUsernameEdit;
var UWindowEditControl GamePasswordEdit;
var UWindowEditControl WebAdminPasswordEdit;
var UWindowEditControl ListenPortEdit;
var UWindowEditControl AdminPasswordEdit;
var UWindowCheckbox EnableWebserverCheck;
var bool bInitialized;

function BeforePaint (Canvas C, float X, float Y)
{
}

function Notify (UWindowDialogControl C, byte E)
{
}

native(11540) latent simulated function Created ()
{
}


defaultproperties
{
}

