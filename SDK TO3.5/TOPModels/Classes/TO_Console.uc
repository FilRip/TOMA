class TO_Console extends Botpack.TournamentConsole;

var SpeechWindow SpeechWindow;
var MessageWindow MessageWindow;
var bool bShowMessage;
var byte SpeechKey;
var bool bUseKey;
var byte UseKey;
var bool bTimeDemoIsEntry;
var bool bWasShowingMessage;

exec function WhisperTalk ()
{
}

exec function QuickConsole (string Msg)
{
}

function MenuClosed ()
{
}

function bool EscapePress ()
{
}

function PrintTimeDemoResult ()
{
}

function TimeDemoRender (Canvas C)
{
}

function StartTimeDemo ()
{
}

exec function MenuCmd (int Menu, int Item)
{
}

event VideoChange ()
{
}

event PostRender (Canvas Canvas)
{
}

event bool KeyEvent (EInputKey Key, EInputAction Action, float Delta)
{
}

function ConnectWithPassword (string URL, string Password, optional byte AgreeID, optional bool AlwaysAgree)
{
}

function MessageBox (string Message, string URL, bool ShowRetry, bool ShowPassword, byte Buttons, optional string Title, optional string AgreeID)
{
}

event ConnectFailure (string FailCode, string URL)
{
}

exec function ShowObjectives ()
{
}

event Message (PlayerReplicationInfo PRI, coerce string Msg, name N)
{
}

function AddMessage (string NewMessage)
{
}

function HideMessage ()
{
}

function ShowMessage ()
{
}

function CreateMessage ()
{
}

function UseRelease ()
{
}

function UsePress ()
{
}

function HideSpeech ()
{
}

function ShowSpeech ()
{
}

function CreateSpeech ()
{
}

function NotifyLevelChange ()
{
}

function LoadGame ()
{
}

function StartNewGame ()
{
}

function EvaluateMatch (int PendingChange, bool Evaluate)
{
}

function CreateRootWindow (Canvas Canvas)
{
}

function CloseUWindow ()
{
}

function LaunchUWindow ()
{
}

function string FixANSI (string S)
{
}

function HideGUI ()
{
}

function bool AllowConsole ()
{
}

state Typing
{
	native(271) static final simulated function bool KeyEvent (EInputKey Key, EInputAction Action, float Delta)
	{
	}

	exec function MenuCmd (int Menu, int Item)
	{
	}

}

state UWindow
{
	exec function MenuCmd (int Menu, int Item)
	{
	}

	event bool KeyEvent (EInputKey Key, EInputAction Action, float Delta)
	{
	}

}

event Tick (float Delta)
{
}


defaultproperties
{
}

