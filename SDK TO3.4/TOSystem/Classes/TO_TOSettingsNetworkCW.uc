class TO_TOSettingsNetworkCW extends UMenuPageWindow;

var UWindowComboControl NetSpeedCombo;
var localized string NetSpeedText;
var localized string NetSpeedHelp;
var localized string NetSpeeds[4];
var bool bInitialized;
var float ControlOffset;
var config bool bShownWindow;

function Created ()
{
}

function AfterCreate ()
{
}

function BeforePaint (Canvas C, float X, float Y)
{
}

function Notify (UWindowDialogControl C, byte E)
{
}

function NetSpeedChanged ()
{
}

function SaveConfigs ()
{
}
