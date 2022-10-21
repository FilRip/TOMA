class TO_MenuBar extends UWindow.UWindowMenuBar;

var bool ShownDisclaimer;
var bool ShowHelp;
var UMenuModMenuList ModItems;
var bool bShowMenu;
var UWindowMenuBarItem GameItem;
var UWindowMenuBarItem OldHelpItem;
var UWindowMenuBarItem ModItem;
var UWindowMenuBarItem HelpItem;
var UWindowMenuBarItem ToolItem;
var UWindowMenuBarItem OptionsItem;
var UWindowMenuBarItem MultiplayerItem;
var UWindowPulldownMenu Options;
var int Build;
var UWindowMenuBarItem OldSelected;
var UWindowMenuBarItem StatsItem;
var TO_ModMenu Mods;
var UWindowPulldownMenu Help;
var UWindowPulldownMenu Game;
var UWindowPulldownMenu Multiplayer;
var UWindowPulldownMenu Stats;
var UWindowPulldownMenu Tool;
var UMenuHelpWindow HelpWindow;

function MenuCmd (int Menu, int Item)
{
}

function NotifyAfterLevelChange ()
{
}

function NotifyBeforeLevelChange ()
{
}

function NotifyQuitUnreal ()
{
}

function bool LoadMods ()
{
}

function LMouseDown (float X, float Y)
{
}

function DrawMenuBar (Canvas C)
{
}

function DrawItem (Canvas C, UWindowList Item, float X, float Y, float W, float H)
{
}

function BeforePaint (Canvas C, float X, float Y)
{
}

function Select (UWindowMenuBarItem i)
{
}

function ShowHelpItem (UWindowMenuBarItem i)
{
}

function ShowWindow ()
{
}

function HideWindow ()
{
}

function CloseUp ()
{
}

function SetHelp (string NewHelpText)
{
}

function MessageBoxDone (UWindowMessageBox W, MessageBoxResult Result)
{
}

function Created ()
{
}


defaultproperties
{
}

