class TO_GameOptionsCW extends UMenuPageWindow;

var UWindowCheckbox WeaponFlashCheck;
var localized string WeaponFlashText;
var localized string WeaponFlashHelp;
var UWindowComboControl WeaponHandCombo;
var localized string WeaponHandText;
var localized string WeaponHandHelp;
var localized string LeftName;
var localized string CenterName;
var localized string RightName;
var localized string HiddenName;
var UWindowCheckbox DodgingCheck;
var localized string DodgingText;
var localized string DodgingHelp;
var UWindowHSliderControl ViewBobSlider;
var localized string ViewBobText;
var localized string ViewBobHelp;
var UWindowHSliderControl SpeedSlider;
var localized string SpeedText;
var UWindowComboControl GoreCombo;
var localized string GoreText;
var localized string GoreHelp;
var localized string GoreLevels[3];
var UWindowCheckbox LocalCheck;
var localized string LocalText;
var localized string LocalHelp;
var UWindowCheckbox SpectatorCheck;
var localized string SpectatorText;
var localized string SpectatorHelp;
var UWindowEditControl NameEdit;
var localized string NameText;
var localized string NameHelp;
var bool Initialized;
var localized string DefaultPlayerName;
var globalconfig bool bShowGoreControl;
var float ControlOffset;

function Created ()
{
}

function AfterCreate ()
{
}

function LoadCurrent ()
{
}

function BeforePaint (Canvas C, float X, float Y)
{
}

function Notify (UWindowDialogControl C, byte E)
{
}

function NameChanged ()
{
}

function SpectatorChanged ()
{
}

function WeaponFlashChecked ()
{
}

function DodgingChecked ()
{
}

function WeaponHandChanged ()
{
}

function ViewBobChanged ()
{
}

function SpeedChanged ()
{
}

function GoreChanged ()
{
}

function SaveConfigs ()
{
}

function LocalChecked ()
{
}
