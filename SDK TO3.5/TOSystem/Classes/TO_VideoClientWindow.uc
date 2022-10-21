class TO_VideoClientWindow extends UMenu.UMenuPageWindow;

var float ControlOffset;
var UWindowComboControl TextureDetailCombo;
var UWindowComboControl SkinDetailCombo;
var UWindowComboControl ResolutionCombo;
var UWindowComboControl FeedbackCombo;
var UWindowComboControl ParticlesCombo;
var UWindowComboControl ColorDepthCombo;
var UWindowComboControl GuiSkinCombo;
var UWindowEditControl MinFramerateEdit;
var UWindowHSliderControl MouseSlider;
var UWindowHSliderControl BrightnessSlider;
var UWindowCheckbox ShowDecalsCheck;
var bool bInitialized;
var UWindowSmallButton DriverButton;
var UWindowLabelControl DriverLabel;
var UWindowLabelControl DriverDesc;
var int OldSkinDetail;
var int OldTextureDetail;
var int OldParticles;
var UWindowMessageBox ConfirmSettings;
var UWindowMessageBox ConfirmDriver;
var UWindowMessageBox ConfirmWorldTextureDetail;
var UWindowMessageBox ConfirmSkinTextureDetail;
var UWindowCheckbox DynamicLightsCheck;

native(440) static final latent event delegate Created ()
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


defaultproperties
{
}

