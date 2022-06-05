class s_SettingsCW extends UMenuPageWindow;

var UMenuBotmatchClientWindow BotmatchParent;
var bool Initialized;
var float ControlOffset;
var bool bControlRight;
var UWindowCheckbox EnableBallisticsCheck;
var localized string EnableBallisticsText;
var localized string EnableBallisticsHelp;
var UWindowCheckbox ReduceSFXCheck;
var localized string ReduceSFXText;
var localized string ReduceSFXHelp;
var UWindowCheckbox DisableRealDamagesCheck;
var localized string DisableRealDamagesText;
var localized string DisableRealDamagesHelp;
var UWindowCheckbox DisableIDLEManagerCheck;
var localized string DisableIDLEManagerText;
var localized string DisableIDLEManagerHelp;
var UWindowCheckbox LinuxFixCheck;
var localized string LinuxFixText;
var localized string LinuxFixHelp;
var UWindowCheckbox DisableActorResetterCheck;
var localized string DisableActorResetterText;
var localized string DisableActorResetterHelp;

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
