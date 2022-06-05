class TO_VideoClientWindow extends UMenuPageWindow;

var bool bInitialized;
var UWindowLabelControl DriverLabel;
var UWindowLabelControl DriverDesc;
var UWindowSmallButton DriverButton;
var localized string DriverText;
var localized string DriverHelp;
var localized string DriverButtonText;
var localized string DriverButtonHelp;
var UWindowComboControl ResolutionCombo;
var localized string ResolutionText;
var localized string ResolutionHelp;
var string OldSettings;
var UWindowComboControl ColorDepthCombo;
var localized string ColorDepthText;
var localized string ColorDepthHelp;
var localized string BitsText;
var UWindowComboControl TextureDetailCombo;
var localized string TextureDetailText;
var localized string TextureDetailHelp;
var localized string Details[3];
var int OldTextureDetail;
var UWindowComboControl SkinDetailCombo;
var localized string SkinDetailText;
var localized string SkinDetailHelp;
var int OldSkinDetail;
var UWindowHSliderControl BrightnessSlider;
var localized string BrightnessText;
var localized string BrightnessHelp;
var UWindowHSliderControl MouseSlider;
var localized string MouseText;
var localized string MouseHelp;
var UWindowComboControl GuiSkinCombo;
var localized string GuiSkinText;
var localized string GuiSkinHelp;
var float ControlOffset;
var UWindowMessageBox ConfirmSettings;
var UWindowMessageBox ConfirmDriver;
var UWindowMessageBox ConfirmWorldTextureDetail;
var UWindowMessageBox ConfirmSkinTextureDetail;
var localized string ConfirmSettingsTitle;
var localized string ConfirmSettingsText;
var localized string ConfirmSettingsCancelTitle;
var localized string ConfirmSettingsCancelText;
var localized string ConfirmTextureDetailTitle;
var localized string ConfirmTextureDetailText;
var localized string ConfirmDriverTitle;
var localized string ConfirmDriverText;
var UWindowCheckbox ShowDecalsCheck;
var localized string ShowDecalsText;
var localized string ShowDecalsHelp;
var UWindowEditControl MinFramerateEdit;
var localized string MinFramerateText;
var localized string MinFramerateHelp;
var UWindowCheckbox DynamicLightsCheck;
var localized string DynamicLightsText;
var localized string DynamicLightsHelp;
var UWindowComboControl FeedbackCombo;
var localized string FeedbackText;
var localized string FeedbackHelp;
var UWindowComboControl ParticlesCombo;
var localized string ParticlesText;
var localized string ParticlesHelp;
var int OldParticles;

function Created ()
{
}

function AfterCreate ()
{
}

function LoadAvailableSettings ()
{
}

function ResolutionChanged (float W, float H)
{
}

function BeforePaint (Canvas C, float X, float Y)
{
}

function Notify (UWindowDialogControl C, byte E)
{
}

function DriverChange ()
{
}

function SettingsChanged ()
{
}

function MessageBoxDone (UWindowMessageBox W, MessageBoxResult Result)
{
}

function TextureDetailChanged ()
{
}

function TextureDetailSet ()
{
}

function SkinDetailChanged ()
{
}

function SkinDetailSet ()
{
}

function BrightnessChanged ()
{
}

function MouseChanged ()
{
}

function DecalsChanged ()
{
}

function DynamicChanged ()
{
}

function MinFramerateChanged ()
{
}

function SaveConfigs ()
{
}

function FeedbackChanged ()
{
}

function ParticlesChanged ()
{
}
