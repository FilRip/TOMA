class TO_TOSettingsClientWindow extends UMenuPageWindow;

var s_BPlayer sp;
var Class<s_BPlayer> sPClass;
var UWindowCheckbox HQVoicesCheck;
var localized string HQVoicesText;
var localized string HQVoicesHelp;
var UWindowCheckbox AutoReloadCheck;
var localized string AutoReloadText;
var localized string AutoReloadHelp;
var UWindowCheckbox SwitchToLastWeaponCheck;
var localized string SwitchToLastWeaponText;
var localized string SwitchToLastWeaponHelp;
var UWindowCheckbox CrosshairCheck;
var localized string CrosshairText;
var localized string CrosshairHelp;
var UWindowCheckbox WidescreenCheck;
var localized string WidescreenText;
var localized string WidescreenHelp;
var UWindowCheckbox DeathMsgCheck;
var localized string DeathMsgText;
var localized string DeathMsgHelp;
var UWindowCheckbox HUDModFixCheck;
var localized string HUDModFixText;
var localized string HUDModFixHelp;
var bool Initialized;
var UWindowLabelControl Label;
var localized string LabelText;

function Created ()
{
}

function BeforePaint (Canvas C, float X, float Y)
{
}

function Notify (UWindowDialogControl C, byte E)
{
}

function AutoReloadChanged ()
{
}

function SwitchToLastWeaponChanged ()
{
}

function CrosshairChanged ()
{
}

function WidescreenChanged ()
{
}

function DeathMsgChanged ()
{
}

function HUDModFixChanged ()
{
}

function SaveConfigs ()
{
}
