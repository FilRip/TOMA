class s_SettingsCW extends UMenu.UMenuPageWindow;

var UMenuBotmatchClientWindow BotmatchParent;
var UWindowCheckbox LinuxFixCheck;
var float ControlOffset;
var UWindowCheckbox ReduceSFXCheck;
var UWindowCheckbox DisableRealDamagesCheck;
var UWindowCheckbox DisableIDLEManagerCheck;
var UWindowCheckbox EnableBallisticsCheck;
var UWindowCheckbox DisableActorResetterCheck;
var bool Initialized;
var bool bControlRight;

simulated event Created ()
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

function EnableBallisticsCheckChanged ()
{
}

function ReduceSFXCheckChanged ()
{
}

function DisableRealDamagesCheckChanged ()
{
}

function DisableIDLEManagerCheckChanged ()
{
}

function LinuxFixChanged ()
{
}

function DisableActorResetterCheckChanged ()
{
}

function LoadCurrentValues ()
{
}

function SaveConfigs ()
{
}


defaultproperties
{
}

