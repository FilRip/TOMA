//----------------------------------------------------------------------------
// Project : TOST
// File    : TOSTStatLog.uc
// Version : 1.1
// Author  : BugBunny
//----------------------------------------------------------------------------
// Version	Changes
// 0.5		+ first release
// 0.6		+ first beta release
// 1.0		+ first public release
// 1.1		+ Added configurable File format (by DiLDoG)
//----------------------------------------------------------------------------

class TOSTStatLog extends StatLogFile;

var	TOSTServerMutator	TOST;
var bool				TOSTLogEnabled;
var	string				TOSTLogFileFormat;
var	bool				AlreadyStarted;
var bool				TOSTMessage;
var StatLog				Backup;

function StartLog()
{
	local string FileName;

	if (AlreadyStarted)
		return;
	AlreadyStarted = true;

	TOSTLogEnabled = TOST.TOSTLogEnabled;
	TOSTLogFileFormat = TOST.TOSTLogFileFormat;
	bWorld = false;

	if (!TOSTLogEnabled)
	{
	   	TOST.StartUp();
		return;
	}

	FileName = "../Logs/"$TOSTLogFileFormat;

	ReplaceText(FileName, "%YYYY",	Level.Year);
	ReplaceText(FileName, "%YY",	Mid(String(Level.Year),2,2));
	ReplaceText(FileName, "%MM",	PrePad(Level.Month,2));
	ReplaceText(FileName, "%DD",	PrePad(Level.Day,2));

	ReplaceText(FileName, "%HH",	PrePad(Level.Hour,2));
	ReplaceText(FileName, "%MI",	PrePad(Level.Minute,2));
	ReplaceText(FileName, "%SS",	PrePad(Level.Second,2));

	ReplaceText(FileName, "%MAP",	StripSpecialChars(Level.Title));
	ReplaceText(FileName, "%NAME",	StripSpecialChars(Level.Game.GameReplicationInfo.ServerName));

	StatLogFile = FileName$".tmp";
	StatLogFinal = FileName;
	OpenLog();

   	TOST.StartUp();
}

function StopLog()
{
	if (TOSTLogEnabled)
		super.StopLog();
	if (Backup != none)
		Backup.StopLog();
}

function FlushLog()
{
	if (TOSTLogEnabled)
		super.FlushLog();
	if (Backup != none)
		Backup.FlushLog();
}

function Timer() {
	// do not log pings
}

function LogEventString( string EventString )
{
    if (Backup != none && !TOSTMessage)
		Backup.LogEventString(EventString);
	if (TOSTLogEnabled && TOSTMessage)
		super.LogEventString(EventString);
}

// events

function LogStandardInfo()
{
	if (Backup != none)
		Backup.LogStandardInfo();
}

function LogServerInfo()
{
	if (Backup != none)
		Backup.LogServerInfo();
}

function LogMapParameters()
{
	if (Backup != none)
		Backup.LogMapParameters();
}

function LogPlayerInfo(Pawn Player)
{
	if (Backup != none)
		Backup.LogPlayerInfo(Player);
}

function LogPlayerConnect(Pawn Player, optional string Checksum)
{
    if (Player.IsA('PlayerPawn'))
		TOST.EventPlayerConnect(Player);
	if (Backup != none)
		Backup.LogPlayerConnect(Player, Checksum);
}

function LogPlayerDisconnect(Pawn Player)
{
	if (Player.IsA('PlayerPawn'))
		TOST.EventPlayerDisconnect(Player);
	if (Backup != none)
		Backup.LogPlayerDisconnect(Player);
}

function LogKill( int KillerID, int VictimID, string KillerWeaponName, string VictimWeaponName, name DamageType )
{
    if (Backup != none)
		Backup.LogKill(KillerID, VictimID, KillerWeaponName, VictimWeaponName, DamageType);
}

function LogTeamKill( int KillerID, int VictimID, string KillerWeaponName, string VictimWeaponName, name DamageType )
{
	if (Backup != none)
		Backup.LogTeamKill(KillerID, VictimID, KillerWeaponName, VictimWeaponName, DamageType);
}

function LogSuicide(Pawn Killed, name DamageType, Pawn Instigator)
{
	if (Backup != none)
		Backup.LogSuicide(Killed, DamageType, Instigator);
}

function LogNameChange(Pawn Other)
{
	if (Other.IsA('PlayerPawn'))
		TOST.EventNameChange(Other);
	if (Backup != none)
		Backup.LogNameChange(Other);
}

function LogTeamChange(Pawn Other)
{
	if (Other.IsA('PlayerPawn'))
		TOST.EventTeamChange(Other);
	if (Backup != none)
		Backup.LogTeamChange(Other);
}

function LogTypingEvent(bool bTyping, Pawn Other)
{
	if (Backup != none)
		Backup.LogTypingEvent(bTyping, Other);
}

function LogPickup(Inventory Item, Pawn Other)
{
	TOST.EventPickup(Item, Other);
	if (Backup != none)
		Backup.LogPickup(Item, Other);
}

function LogItemActivate(Inventory Item, Pawn Other)
{
	if ( (Other == None) || (Other.PlayerReplicationInfo == None) || (Item == None) )
		return;
	TOST.EventItemActivate(Item, Other);
	if (Backup != none)
		Backup.LogItemActivate(Item, Other);
}

function LogItemDeactivate(Inventory Item, Pawn Other)
{
	TOST.EventItemDeactivate(Item, Other);
	if (Backup != none)
		Backup.LogItemDeactivate(Item, Other);
}

function LogSpecialEvent(string EventType, optional coerce string Arg1, optional coerce string Arg2, optional coerce string Arg3, optional coerce string Arg4)
{
	TOST.EventSpecialEvent(EventType, Arg1, Arg2, Arg3, Arg4);
	if (Backup != none)
		Backup.LogSpecialEvent(EventType, Arg1, Arg2, Arg3, Arg4);
}

function LogPings()
{
	if (Backup != none)
		Backup.LogPings();
}

function LogGameStart()
{
	if (Backup != none)
		Backup.LogGameStart();
}

function LogGameEnd( string Reason )
{
	TOST.EventGameEnd(Reason);
	if (Backup != none)
		Backup.LogGameEnd(Reason);
}

static final function string ReplaceText(out coerce string Text, coerce string Replace, coerce string With)
{
    local int i;
    local string Output;

    i = InStr(Text, Replace);
    while (i != -1) {
        Output = Output $ Left(Text, i) $ With;
        Text = Mid(Text, i + Len(Replace));
        i = InStr(Text, Replace);
    }
    Text = Output $ Text;
}

static final function string StripSpecialChars(string str)
{
	local int 		i;
	local string 	str2;

	str2 = "";
	for (i = 0; i<Len(str); i++)
		if (InStr("\\*?:<>\"| ", Mid(str, i, 1)) != -1)
			str2 = str2 $ "_";
		else
			str2 = str2 $ Mid(str, i, 1);

	return str2;
}

static function string PrePad(coerce string s, int Size, optional string Pad)
{
	if (Pad == "") Pad = "0";
	while (Len(s) < Size) s = Pad$s;
	return s;
}

defaultproperties
{
	bHidden=True
    StatLogFile="../Logs/TOST.log"
}

