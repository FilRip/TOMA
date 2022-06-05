class TO_MenuBar extends UWindowMenuBar;

var UWindowPulldownMenu Game;
var UWindowPulldownMenu Multiplayer;
var UWindowPulldownMenu Stats;
var UWindowPulldownMenu Tool;
var UWindowPulldownMenu Help;
var UWindowPulldownMenu Options;
var TO_ModMenu Mods;
var UWindowMenuBarItem GameItem;
var UWindowMenuBarItem MultiplayerItem;
var UWindowMenuBarItem OptionsItem;
var UWindowMenuBarItem StatsItem;
var UWindowMenuBarItem ToolItem;
var UWindowMenuBarItem HelpItem;
var UWindowMenuBarItem ModItem;
var UWindowMenuBarItem OldHelpItem;
var UMenuHelpWindow HelpWindow;
var config bool ShowHelp;
var UWindowMenuBarItem OldSelected;
var string VersionText;
var string TOVersionText;
var bool bShowMenu;
var localized string GameName;
var localized string GameHelp;
var localized string MultiplayerName;
var localized string MultiplayerHelp;
var localized string OptionsName;
var localized string OptionsHelp;
var localized string StatsName;
var localized string StatsHelp;
var localized string ToolName;
var localized string ToolHelp;
var localized string HelpName;
var localized string HelpHelp;
var localized string VersionName;
var localized string ModName;
var localized string ModHelp;
var UMenuModMenuList ModItems;
var config string GameUMenuDefault;
var config string MultiplayerUMenuDefault;
var config string OptionsUMenuDefault;
var config int Build;
var config string ModMenuClass;

function Created ()
{
}

function SetHelp (string NewHelpText)
{
}

function CloseUp ()
{
}

function HideWindow ()
{
}

function ShowWindow ()
{
}

function ShowHelpItem (UWindowMenuBarItem i)
{
}

function Select (UWindowMenuBarItem i)
{
}

function BeforePaint (Canvas C, float X, float Y)
{
}

function DrawItem (Canvas C, UWindowList Item, float X, float Y, float W, float H)
{
}

function DrawMenuBar (Canvas C)
{
}

function LMouseDown (float X, float Y)
{
}

function bool LoadMods ()
{
}

function NotifyQuitUnreal ()
{
}

function NotifyBeforeLevelChange ()
{
}

function NotifyAfterLevelChange ()
{
}

function MenuCmd (int Menu, int Item)
{
}
