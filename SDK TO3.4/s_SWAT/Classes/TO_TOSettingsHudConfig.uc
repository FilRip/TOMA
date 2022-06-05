class TO_TOSettingsHudConfig extends UMenuPageWindow;

var UWindowSmallButton DefaultsButton;
var localized string DefaultsText;
var localized string DefaultsHelp;
var UWindowCheckbox ShowHUDCheck;
var localized string ShowHUDText;
var localized string ShowHUDHelp;
var UWindowCheckbox ShowStatusCheck;
var localized string ShowStatusText;
var localized string ShowStatusHelp;
var UWindowCheckbox ShowWidescreenCheck;
var localized string ShowWidescreenText;
var localized string ShowWidescreenHelp;
var UWindowCheckbox ShowBackgroundCheck;
var localized string ShowBackgroundText;
var localized string ShowBackgroundHelp;
var UWindowCheckbox ShowArmorguyCheck;
var localized string ShowArmorguyText;
var localized string ShowArmorguyHelp;
var UWindowCheckbox ShowHitlocationCheck;
var localized string ShowHitlocationText;
var localized string ShowHitlocationHelp;
var UWindowCheckbox ShowTimeCheck;
var localized string ShowTimeText;
var localized string ShowTimeHelp;
var UWindowCheckbox ShowHintCheck;
var localized string ShowHintText;
var localized string ShowHintHelp;
var UWindowComboControl BgQualityCombo;
var localized string BgQualityModes[3];
var localized string BgQualityText;
var localized string BgQualityHelp;
var UWindowCheckbox ShowTextCheck;
var localized string ShowTextText;
var localized string ShowTextHelp;
var UWindowCheckbox ShowTranslucentCheck;
var localized string ShowTranslucentText;
var localized string ShowTranslucentHelp;
var UWindowCheckbox ShowChatCheck;
var localized string ShowChatText;
var localized string ShowChatHelp;
var UWindowCheckbox ShowDeathmsgCheck;
var localized string ShowDeathmsgText;
var localized string ShowDeathmsgHelp;
var UWindowHSliderControl CrosshairSlider;
var localized string CrosshairText;
var localized string CrosshairHelp;
var localized string HUDColorNames[20];
var localized string HUDColorValues[20];
var bool bInitialized;
var int ControlOffset;

function Created ()
{
}

function LoadCurrentValues ()
{
}

function LoadDefaultValues ()
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

function ResetHUD ()
{
}

singular function HUDLayoutChanged ()
{
}

function CrosshairChanged ()
{
}

function SaveConfigs ()
{
}
