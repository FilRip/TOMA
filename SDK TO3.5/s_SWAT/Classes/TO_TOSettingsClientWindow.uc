class TO_TOSettingsClientWindow extends UMenu.UMenuPageWindow;

var S_Player sp;
var int YPos;
var UWindowComboControl FiremodesCombo;
var UWindowCheckbox AutoReloadCheck;
var UWindowCheckbox DeathMsgCheck;
var UWindowCheckbox RadarCheck;
var UWindowCheckbox FlashCheck;
var UWindowCheckbox TimeDemoCheck;
var UWindowCheckbox ObjectivesCheck;
var UWindowCheckbox LaserCheck;
var UWindowCheckbox HUDModFixCheck;
var UWindowCheckbox SwitchToLastWeaponCheck;
var s_HUD sh;
var UWindowLabelControl Label;
var UWindowCheckbox WidescreenCheck;
var bool Initialized;
var S_Player sPClass;
var UWindowCheckbox HQVoicesCheck;

latent simulated exec noexport function Created ()
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


defaultproperties
{
}

