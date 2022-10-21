//----------------------------------------------------------------------------
// Project : TOST
// File    : TOSTLog.uc
// Version : 1.2
// Author  : BugBunny
//----------------------------------------------------------------------------

class TOSTLog extends StatLogFile;

function StartLog()
{
	local string zzFileName;
	local string zzstr, zzstr2;
	local int zzi;

	zzstr = Level.Game.GameReplicationInfo.ServerName;
	zzstr2 = "";
	for (zzi = 0; zzi<Len(zzstr); zzi++)
		if (InStr("\\/*?:<>\"|", Mid(zzstr, zzi, 1)) != -1)
			zzstr2 = zzstr2 $ "_";
		else
			zzstr2 = zzstr2 $ Mid(zzstr, zzi, 1);
	zzFileName = "../Logs/TOST."$zzstr2$"."$GetShortAbsoluteTime();
	StatLogFile = zzFileName$".tmp";
	StatLogFinal = zzFileName$".log";
	OpenLog();
}

function Timer() {
}	// Don't log pings every 30 seconds

defaultproperties
{
     StatLogFile="../Logs/TOST.log"
}
