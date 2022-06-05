class TO_UTWeaponsClientWindow extends UMenuPageWindow;

var UWindowCheckbox RandomCheck;
var localized string RandomText;
var localized string RandomHelp;
var UWindowComboControl WCombo[11];
var localized string Weapons[2];
var localized string WText[11];
var localized string WHelp;
var UWindowSmallButton DefaultButton;
var localized string DefaultText;
var localized string DefaultHelp;
var UWindowSmallButton RemoveButton;
var localized string RemoveText;
var localized string RemoveHelp;
var Class<TO_Replacer> ReplacerClass;
var int Y;

function Created ()
{
}

function BeforePaint (Canvas C, float X, float Y)
{
}

function Notify (UWindowDialogControl C, byte E)
{
}

function RandomChanged ()
{
}

function Close (optional bool bByParent)
{
}

function SetSavedValues ()
{
}

function SetDefault ()
{
}

function RemoveWeapons ()
{
}
