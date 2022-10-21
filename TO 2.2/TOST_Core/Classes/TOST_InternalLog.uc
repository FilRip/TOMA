//------------------------------------------------------------------------------
// PROJECT : Tactical Ops ServerAdmin Tool
// FILE    : TOST_InternalLog.uc
// VERSION : 1.0
// INFO    : Handles Logging of Events or Messages
// AUTHOR  : Xian
//------------------------------------------------------------------------------
// CHANGES :
// v1.0     + Initial version
//------------------------------------------------------------------------------

class TOST_InternalLog expands TOST_LogModule;

// Init Logging; Setting Filename
function StartLog ()
{
	local string FileName;
	local string Server;
	local string Replace;
	local string Illegal;
	local int i;

	bWorld = False;

    Illegal = (Chr(34)$Chr(42)$Chr(47)$Chr(58)$Chr(60)$Chr(62)$Chr(63)$Chr(92)$Chr(124));
	if (Level.Game!=None) Server = Level.Game.GameReplicationInfo.ServerName;

	for (i = 0; i < (Len(Server)); ++ i)
	{
        if (InStr(Illegal, Mid(Server, i, 1)) != -1)
			Replace = Replace $ Chr(95);
		else
			Replace = Replace $ Mid(Server, i, 1);
	}

	FileName = "../Logs/TOST."$Replace$"."$GetShortAbsoluteTime();
	StatLogFile = FileName$".log";
	StatLogFinal = FileName$".log";
	OpenLog();
}

// Function that handles Logging
function LogEventString (coerce string Event)
{
	FileLog(Event);
	FlushLog();
}

// =============================================================================
// Default Properties

defaultproperties
{
   StatLogFile="../Logs/TOST.log"
   ActorID="TOST Internal Log:"
}
