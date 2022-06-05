class TO_GameMenu extends UWindowPulldownMenu;

var config bool bShowSinglePlayer;
var UWindowPulldownMenuItem Botmatch;
var UWindowPulldownMenuItem Quit;
var UWindowPulldownMenuItem ReturnToGame;
var UWindowPulldownMenuItem StartSinglePlayer;
var localized string StartSinglePlayerName;
var localized string StartSinglePlayerHelp;
var localized string BotmatchName;
var localized string BotmatchHelp;
var localized string ReturnToGameName;
var localized string ReturnToGameHelp;
var localized string QuitName;
var localized string QuitHelp;
var localized string QuitTitle;
var localized string QuitText;
var UWindowMessageBox ConfirmQuit;

function Created ()
{
}

function ShowWindow ()
{
}

function MessageBoxDone (UWindowMessageBox W, MessageBoxResult Result)
{
}

function ExecuteItem (UWindowPulldownMenuItem i)
{
}

function Select (UWindowPulldownMenuItem i)
{
}
