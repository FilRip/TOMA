class TO_TOSettingsHudConfig extends UMenu.UMenuPageWindow;

var int ControlOffset;
var UWindowCheckbox ShowHUDCheck;
var UWindowCheckbox ShowTextCheck;
var UWindowHSliderControl CrosshairSlider;
var UWindowCheckbox ShowTranslucentCheck;
var UWindowCheckbox ShowStatusCheck;
var UWindowCheckbox ShowBackgroundCheck;
var UWindowHSliderControl ColorRSlider;
var UWindowHSliderControl ColorGSlider;
var UWindowHSliderControl ColorBSlider;
var UWindowComboControl BgQualityCombo;
var UWindowCheckbox ShowDeathmsgCheck;
var UWindowCheckbox ShowChatCheck;
var UWindowCheckbox ShowWidescreenCheck;
var UWindowCheckbox CustomColorCheck;
var UWindowCheckbox ShowArmorguyCheck;
var UWindowCheckbox ShowHitlocationCheck;
var UWindowCheckbox ShowTimeCheck;
var UWindowCheckbox ShowHintCheck;
var UWindowCheckbox CrosshairCheck;
var UWindowCheckbox CrosshairTeamCheck;
var UWindowCheckbox RoundsCheck;
var bool bInitialized;

native(22811) function Created ()
{
}

function LoadCurrentValues ()
{
}

function BeforePaint (Canvas C, float X, float Y)
{
}

function Paint (Canvas C, float X, float Y)
{
}

function Notify (UWindowDialogControl C, byte E)
{
}

function HUDLayoutChanged ()
{
}

function CrosshairShowChanged ()
{
}

function CrosshairChanged ()
{
}

function ColorChanged (int i)
{
}

function SaveConfigs ()
{
}

function Close (optional bool bByParent)
{
}


defaultproperties
{
}

