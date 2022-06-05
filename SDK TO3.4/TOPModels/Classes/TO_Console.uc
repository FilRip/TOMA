class TO_Console extends TournamentConsole;

var SpeechWindow SpeechWindow;
var globalconfig byte SpeechKey;
var globalconfig byte UseKey;
var bool bUseKey;
var bool bTimeDemoIsEntry;
var bool bShowMessage;
var bool bWasShowingMessage;
var MessageWindow MessageWindow;
var string ManagerWindowClass;
var string InterimObjectType;
var string SlotWindowType;
var config string SavedPasswords[10];

event PostRender (Canvas Canvas)
{
}

event bool KeyEvent (EInputKey Key, EInputAction Action, float Delta)
{
}

event Tick (float Delta)
{
}

state UWindow
{
	event bool KeyEvent (EInputKey Key, EInputAction Action, float Delta)
	{
	}
	
	event Tick (float Delta)
	{
	}
	
	exec function MenuCmd (int Menu, int Item)
	{
	}
	
}

state Typing
{
	exec function MenuCmd (int Menu, int Item)
	{
	}
	
}

function LaunchUWindow ()
{
}

function CloseUWindow ()
{
}

function CreateRootWindow (Canvas Canvas)
{
}

function EvaluateMatch (int PendingChange, bool Evaluate)
{
}

function StartNewGame ()
{
}

function LoadGame ()
{
}

function NotifyLevelChange ()
{
}

function CreateSpeech ()
{
}

function ShowSpeech ()
{
}

function HideSpeech ()
{
}

function UsePress ()
{
}

function UseRelease ()
{
}

function CreateMessage ()
{
}

function ShowMessage ()
{
}

function HideMessage ()
{
}

function AddMessage (string NewMessage)
{
}

exec function ShowObjectives ()
{
}

event ConnectFailure (string FailCode, string URL)
{
}

function ConnectWithPassword (string URL, string Password)
{
}

exec function MenuCmd (int Menu, int Item)
{
}

function StartTimeDemo ()
{
}

function TimeDemoRender (Canvas C)
{
}

function PrintTimeDemoResult ()
{
}

function bool EscapePress ()
{
}

function MenuClosed ()
{
}
