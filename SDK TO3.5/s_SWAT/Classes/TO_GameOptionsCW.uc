class TO_GameOptionsCW extends UMenu.UMenuPageWindow;

var UWindowComboControl GoreCombo;
var UWindowEditControl NameEdit;
var float ControlOffset;
var UWindowComboControl WeaponHandCombo;
var UWindowCheckbox LocalCheck;
var UWindowHSliderControl SpeedSlider;
var UWindowHSliderControl ViewBobSlider;
var UWindowCheckbox SpectatorCheck;
var bool Initialized;
var UWindowCheckbox WeaponFlashCheck;
var UWindowCheckbox DodgingCheck;
var bool bShowGoreControl;

native(440) static simulated event operator(103) Created ()
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


defaultproperties
{
}

