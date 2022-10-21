class TO_TOSettingsNetworkCW extends UMenu.UMenuPageWindow;

var float ControlOffset;
var UWindowComboControl NetPingControl;
var UWindowComboControl NetSpeedCombo;
var UWindowEditControl ColorEffectControl;
var UWindowComboControl MapNameControl;
var UWindowComboControl ServerNameControl;
var UWindowEditControl MaxPlayersEdit;
var UWindowEditControl MinPlayersEdit;
var UWindowEditControl IPEdit;
var UWindowEditControl IRCNameEdit;
var UWindowEditControl ServerNameEdit;
var UWindowEditControl MapNameEdit;
var UWindowCheckbox ColorEffect;
var UWindowCheckbox NetPassworded;
var UWindowCheckbox NetPlayerFull;
var UWindowCheckbox NetPlayerEmpty;
var bool bShownWindow;
var bool bInitialized;

native(11540) final latent exec function Created ()
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

function NetPingChanged ()
{
}

function SaveConfigs ()
{
}


defaultproperties
{
}

