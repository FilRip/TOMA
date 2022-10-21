//----------------------------------------------------------------------------
// Project : TOST
// File    : TOSTPiece.uc
// Version : 1.3
// Author  : BugBunny, Modified by dildog, darix (some string functions moved from TOSTIRC)
//----------------------------------------------------------------------------
// Version	Changes
// 0.5		+ first release
// 0.6		+ first beta release
// 1.0		+ first public release
// 1.1		+ added CheckReplacement/AlwaysKeep mutator calls
// 1.2		+ added GetPackageName function/PackageName variable
// 1.3		+ added Debug/DLog and string/time helper functions
//----------------------------------------------------------------------------

class TOSTPiece expands Info;

var	TOSTServerMutator	TOST;

var TOSTPiece 	NextPiece;
var	TOSTPiece	NextLogPiece;

var int			CountDown;

var string		PieceName;
var string		PieceVersion;
var int			PieceOrder;
var bool		ServerOnly;
var bool		PieceTag;
var string		PackageName;

var int			BaseMessage;

var bool		Debug;

struct MsgParams {
	var	int			Param1;
	var int			Param2;
	var	float		Param3;
	var string		Param4;
	var	bool		Param5;
	var PlayerPawn	Param6;
};
var MsgParams	Params;


//----------------------------------------------------------------------------
// common helper
//----------------------------------------------------------------------------
// * FindPlayerByID - find playerpawn with the given player ID
function	PlayerPawn	FindPlayerByID(int PID)
{
	local	Pawn	aPawn;

	for( aPawn=Level.PawnList; aPawn!=None; aPawn=aPawn.NextPawn )
		if (aPawn.bIsPlayer && PlayerPawn(aPawn) != none && aPawn.PlayerReplicationInfo.PlayerID == pid && NetConnection(PlayerPawn(aPawn).Player)!=None )
			return PlayerPawn(aPawn);
	return None;
}

// * FindPlayerByName - find playerpawn with the given player name
function	PlayerPawn	FindPlayerByName(string PlayerName)
{
	local	Pawn	aPawn;

	for( aPawn=Level.PawnList; aPawn!=None; aPawn=aPawn.NextPawn )
		if (aPawn.bIsPlayer && PlayerPawn(aPawn) != none && Caps(aPawn.PlayerReplicationInfo.PlayerName) == Caps(PlayerName) && NetConnection(PlayerPawn(aPawn).Player)!=None )
			return PlayerPawn(aPawn);
	return None;
}

// * GetPackageName - get the packagename of a class (for easy referencing)
function	string		GetPackageName(class MyClass)
{
	local	string	s;
	s = Caps(string(MyClass));
	return Left(s, InStr(s, "."));
}

//----------------------------------------------------------------------------
// piece handling
//----------------------------------------------------------------------------
function		AddPiece(TOSTPiece P)
{
	if (NextPiece == none)
	{
		NextPiece = P;
		P.TOST = TOST;
	} else
		if (NextPiece.PieceOrder > P.PieceOrder)
		{
			P.NextPiece = NextPiece;
			NextPiece = P;
			P.TOST = TOST;
		} else
			NextPiece.AddPiece(P);
}

event 			Destroyed()
{
	local	TOSTPiece	next, prev;

	next = TOST.Piece;
	prev = none;
	while (next != self && next != none)
	{
		prev = next;
		next = next.NextPiece;
	}
	if (next == self && prev == none)
	{
		TOST.Piece = NextPiece;
		TOST.Bridge.NextPiece = NextPiece;
	}
	if (next == self && prev != none)
		prev.NextPiece = NextPiece;

}

//----------------------------------------------------------------------------
// logging
//----------------------------------------------------------------------------
function        XLog(string msg)
{
	if ((TOST.TOSTLogFilter == "") || (InStr(";"$PieceName$";", ";"$TOST.TOSTLogFilter$";") != -1))
	    TOST.TOSTLog(PieceName$":"@msg);
}

function        DLog(string msg)
{
	if (Debug && ((TOST.TOSTLogFilter == "") || (InStr(";"$PieceName$";", ";"$TOST.TOSTLogFilter$";") != -1)))
	    TOST.TOSTLog(PieceName$" Debug:"@msg);
}

function		Logging(out string Msg)
{
	if (NextLogPiece != none)
		NextLogPiece.Logging(Msg);
}

//----------------------------------------------------------------------------
// events
//----------------------------------------------------------------------------
function 		EventPlayerConnect(Pawn Player)
{
	if (NextPiece != none)
		NextPiece.EventPlayerConnect(Player);
}

function 		EventPlayerDisconnect(Pawn Player)
{
	if (NextPiece != none)
		NextPiece.EventPlayerDisconnect(Player);
}

function 		EventNameChange(Pawn Other)
{
	if (NextPiece != none)
		NextPiece.EventNameChange(Other);
}

function 		EventTeamChange(Pawn Other)
{
	if (NextPiece != none)
		NextPiece.EventTeamChange(Other);
}

function 		EventAfterPickup(Inventory Item, Pawn Other)
{
	if (NextPiece != none)
		NextPiece.EventAfterPickup(Item, Other);
}

function 		EventItemActivate(Inventory Item, Pawn Other)
{
	if (NextPiece != none)
		NextPiece.EventItemActivate(Item, Other);
}

function 		EventItemDeactivate(Inventory Item, Pawn Other)
{
	if (NextPiece != none)
		NextPiece.EventItemDeactivate(Item, Other);
}

function 		EventSpecialEvent(string EventType, optional coerce string Arg1, optional coerce string Arg2, optional coerce string Arg3, optional coerce string Arg4)
{
	if (NextPiece != none)
		NextPiece.EventSpecialEvent(EventType, Arg1, Arg2, Arg3, Arg4);
}

function		EventAfterEndGame(string Reason)
{
	if (NextPiece != none)
		NextPiece.EventAfterEndGame(Reason);
}

//----------------------------------------------------------------------------
// Mutator
//----------------------------------------------------------------------------
function bool	EventRestartGame()
{
	if (NextPiece != none)
		return NextPiece.EventRestartGame();
	return false;
}

function bool	EventBeforeEndGame()
{
	if (NextPiece != none)
		return NextPiece.EventBeforeEndGame();
	return false;
}

function bool	EventBeforePickup(Pawn Other, Inventory item, out byte bAllowPickup)
{
	if (NextPiece != none)
		return NextPiece.EventBeforePickup(Other, Item, bAllowPickup);
	return false;
}

function bool 	EventPreventDeath(Pawn Killed, Pawn Killer, name damageType, vector HitLocation)
{
	if (NextPiece != none)
		return NextPiece.EventPreventDeath(Killed, Killer, DamageType, HitLocation);
	return false;
}

function 		EventScoreKill(Pawn Killer, Pawn Other)
{
	if (NextPiece != none)
		NextPiece.EventScoreKill(Killer, Other);
}

function 		EventModifyPlayer(Pawn Other)
{
	if (NextPiece != none)
		NextPiece.EventModifyPlayer(Other);
}

function 		EventTakeDamage( out int ActualDamage, Pawn Victim, Pawn InstigatedBy, out Vector HitLocation, out vector Momentum, name DamageType)
{
	if ( NextPiece != None )
		NextPiece.EventTakeDamage(ActualDamage, Victim, InstigatedBy, HitLocation, Momentum, DamageType);
}

function bool 	EventTeamMessage( Actor Sender, Pawn Receiver, PlayerReplicationInfo PRI, coerce string S, name Type, optional bool bBeep )
{
	if (NextPiece != none)
		return NextPiece.EventTeamMessage(Sender, Receiver, PRI, S, Type, bBeep);
	return true;
}

function bool 	EventBroadcastMessage( Actor Sender, Pawn Receiver, out coerce string Msg, out optional name Type, optional bool bBeep)
{
	if (NextPiece != none)
		return NextPiece.EventBroadcastMessage(Sender, Receiver, Msg, Type, bBeep);
	return true;
}

function bool 	EventBroadcastLocalizedMessage( Actor Sender, Pawn Receiver, out class<LocalMessage> Message, out optional int Switch, out optional PlayerReplicationInfo RelatedPRI_1, out optional PlayerReplicationInfo RelatedPRI_2, out optional Object OptionalObject )
{
	if (NextPiece != none)
		return NextPiece.EventBroadcastLocalizedMessage(Sender, Receiver, Message, switch, RelatedPRI_1, RelatedPRI_2, optionalObject );
	return true;
}

function bool	EventAlwaysKeep(Actor Other)
{
	if (NextPiece != none)
		return NextPiece.EventAlwaysKeep(Other);
	return false;
}

function bool	EventCheckReplacement(Actor Other, out byte bSuperRelevant)
{
	if (NextPiece != none)
		return NextPiece.EventCheckReplacement(Other, bSuperRelevant);
	return true;
}

//----------------------------------------------------------------------------
// Other
//----------------------------------------------------------------------------
function		EventGamePeriodChanged(int GP)
{
	//		case	GP_PreRound:			return 0;
	//		case	GP_RoundPlaying:		return 1;
	//		case	GP_PostRound:   		return 2;
	//		case	GP_RoundRestarting:		return 3;
	//		case	GP_PostMatch:			return 4;
	if (NextPiece != none)
		NextPiece.EventGamePeriodChanged(GP);
}

function		EventInit()
{
	if (NextPiece != none)
		NextPiece.EventInit();
}

function		EventPostInit()
{
	if (NextPiece != none)
		NextPiece.EventPostInit();
}

function		EventSaveConfig()
{
	SaveConfig();
	if (NextPiece != none)
		NextPiece.EventSaveConfig();
}

function int	EventTimer()
{
	return -1;
}

function		NotifyPlayer(int MsgType, PlayerPawn Player, string Msg)
{
	if (!TOST.Piece.EventNotifyPlayer(Self, MsgType, Player, Msg))
	    Player.ClientMessage(PieceName@"("$PieceVersion$") :"@msg);
}

function		NotifyRest(int MsgType, PlayerPawn Player, string Msg)
{
    local Pawn  P;

	for ( P=Level.PawnList; P!=None; P=P.NextPawn )
        if ( PlayerPawn(P) != None && PlayerPawn(P) != Player)
			if (!TOST.Piece.EventNotifyPlayer(Self, MsgType, PlayerPawn(P), Msg))
        	    P.ClientMessage(PieceName@"("$PieceVersion$") :"@msg);
}

function		NotifyAll(int MsgType, string Msg)
{
    local Pawn  P;

	for ( P=Level.PawnList; P!=None; P=P.NextPawn )
        if ( PlayerPawn(P) != None )
			if (!TOST.Piece.EventNotifyPlayer(Self, MsgType, PlayerPawn(P), Msg))
        	    P.ClientMessage(PieceName@"("$PieceVersion$") :"@msg);
}

function bool	EventNotifyPlayer(TOSTPiece Sender, int MsgType, PlayerPawn Player, string Msg)
{
	if (NextPiece != none)
		return NextPiece.EventNotifyPlayer(Sender, MsgType, Player, Msg);
	return	false;
}

function bool	CheckClearance(PlayerPawn Player, int MsgIndex)
{
	local	int	Allowed;

    Allowed = 0;
	if (!TOST.Piece.EventCheckClearance(self, Player, MsgIndex, Allowed))
	{
		if (Player != None)
			return Player.PlayerReplicationInfo.bAdmin;
		else
			return false;
	}
	return (Allowed != 0);
}

function bool	EventCheckClearance(TOSTPiece Sender, PlayerPawn Player, int MsgType, out int Allowed)
{
	if (NextPiece != none)
		return NextPiece.EventCheckClearance(Sender, Player, MsgType, Allowed);
	return	false;
}

//----------------------------------------------------------------------------
// Message handling
//----------------------------------------------------------------------------
function		SendMessage(int MsgIndex)
{
	TOST.Piece.EventMessage(self, MsgIndex);
}

function		EventMessage(TOSTPiece Sender, int MsgIndex)
{
	if (NextPiece != none)
		NextPiece.EventMessage(Sender, MsgIndex);
}

function		SendAnswerMessage(TOSTPiece Destination, int MsgIndex)
{
	Destination.EventAnswerMessage(self, MsgIndex);
}

function		EventAnswerMessage(TOSTPiece Sender, int MsgIndex)
{
}

function		SendClientMessage(int MsgIndex)
{
	TOST.SendClientMessage(self, MsgIndex);
}

function		BroadcastClientMessage(int MsgIndex)
{
	TOST.BroadcastClientMessage(self, MsgIndex);
}

//----------------------------------------------------------------------------
// String helper functions
//----------------------------------------------------------------------------
// * LTrim - Trim whitespaces on start of string
static final function string	LTrim(coerce string S, optional string char)
{
    if (char=="") char = " ";
	while (Left(S, 1) == char)
        S = Right(S, Len(S) - 1);
    return S;
}

// * RTrim - Trim whitespaces on end of string
static final function string	RTrim(coerce string S, optional string char)
{
    if (char=="") char = " ";
	while (Right(S, 1) == char)
        S = Left(S, Len(S) - 1);
    return S;
}

// * RTrim - Trim whitespaces on start and end of a string
static final function string	Trim(coerce string S, optional string char)
{
    return LTrim(RTrim(S, char), char);
}

// * ReplaceText - Replace a occurance in string
static final function string	ReplaceText(coerce string Text, coerce string Replace, coerce string With)
{
    local	int		i;
    local	string	Output;

    i = InStr(Text, Replace);
    while (i != -1) {
        Output = Output $ Left(Text, i) $ With;
        Text = Mid(Text, i + Len(Replace));
        i = InStr(Text, Replace);
    }
    Output = Output $ Text;
    return Output;
}

// * AlphaNumeric - Strip special chars in a string
static final function string	AlphaNumeric(string s)
{
    local	string	result;
    local	int		i, c;

	for (i = 0; i < Len(s); i++) {
		c = Asc(Right(s, Len(s) - i));
		if ( c == Clamp(c, 48, 57) )  // 0-9
			result = result $ Chr(c);
		else if ( c == Clamp(c, 64, 90) ) // A-Z and @
			result = result $ Chr(c);
		else if ( c == Clamp(c, 97, 122) ) // a-z
			result = result $ Chr(c);
		else if ( c == 45 || c == 95)  // - _
			result = result $ Chr(c);
	}

    return result;
}

// * IPOnly - returns the IP without the port
static final function string	IPOnly(string IP)
{
	local	int		i;

	i = InStr(IP, ":");

	if (i != -1)
		return Left(IP, i);
	else
		return IP;
}

// * SplitStr - split a string in two by devider
static final function string	SplitStr(string Src, string Devider, out string LeftPart, out string RightPart)
{
	local	int		pos;

	pos = InStr (Src, Devider);

	if ( pos == -1 ) {
		LeftPart = Src;
		RightPart = "";
	}
	else {
		LeftPart = Left(Src, pos);
		RightPart = Mid (Src, pos + Len(Devider));
	}
}

// * PrePad - well doh... pad's a string @ start
static final function string PrePad(coerce string s, optional int Size, optional string Pad)
{
	if (Size == 0) Size = 2;
	if (Pad == "") Pad = "0";
	while (Len(s) < Size) s = Pad$s;
	return s;
}

// * PostPad - well doh... pad's a string @ end
static final function string PostPad(coerce string s, optional int Size, optional string Pad)
{
	if (Size == 0) Size = 2;
	if (Pad == "") Pad = "0";
	while (Len(s) < Size) s = s$Pad;
	return s;
}

static final function string Lower(coerce string Text) {
	local int IndexChar;

	for (IndexChar = 0; IndexChar < Len(Text); IndexChar++)
		if (Mid(Text, IndexChar, 1) >= "A" &&
			Mid(Text, IndexChar, 1) <= "Z")
	Text = Left(Text, IndexChar) $ Chr(Asc(Mid(Text, IndexChar, 1)) + 32) $ Mid(Text, IndexChar + 1);

	return Text;
}

//----------------------------------------------------------------------------
// Time helper functions
//----------------------------------------------------------------------------
final function	int		GetTimeStamp(int Year, int Month, int Day, int Hour, int Minute)
{
	return ((Year & 8191) << 20) | ((Month & 31) << 16) | ((Day & 31) << 11) | ((Hour & 31) << 6) | (Minute & 63);
}

final function	int		GetCurrentTimeStamp()
{
	return GetTimeStamp(Level.Year, Level.Month, Level.Day, Level.Hour, Level.Minute);
}

final function	int		GetFutureTimeStamp(optional int AddYear, optional int AddMonth, optional int AddDay, optional int AddHour, optional int AddMinute)
{
	local	int	Year, Month, Day, Hour, Minute;

	Year = Level.Year+AddYear;
	Month = Level.Month+AddMonth;
	Day = Level.Day+AddDay;
	Hour = Level.Hour+AddHour;
	Minute = Level.Minute+AddMinute;

	// correct time stamp
	while (Minute >= 60)
	{
		Minute -= 60;
		Hour++;
	}
	while (Hour >= 24)
	{
		Hour -= 24;
		Day++;
	}
	while (Month > 12)
	{
		Month -= 12;
		Year++;
	}
	while (Day > GetDayPerMonth(Month, Year))
	{
		Day -= GetDayPerMonth(Month, Year);
		Month++;
		if (Month > 12)
		{
			Month = 1;
			Year++;
		}
	}

	return GetTimeStamp(Year, Month, Day, Hour, Minute);
}

final function	string	ResolveTimeStamp(optional int TimeStamp, optional string Format)
{
	local	int		i;

	if (TimeStamp == 0)
		TimeStamp = GetCurrentTimeStamp();
	if (Format == "")
		Format = "%YYYY-%MM-%DD %HH:%MI";

	// Year
	i = (TimeStamp >> 20);
	Format = ReplaceText(Format, "%YYYY",	PrePad(i));
	Format = ReplaceText(Format, "%YY",	Mid(i,2,2));

	// Month
	i = ((TimeStamp >> 16) & 15);
	Format = ReplaceText(Format, "%MM",	PrePad(i));

	// Day
	i = ((TimeStamp >> 11) & 31);
	Format = ReplaceText(Format, "%DD",	PrePad(i));

	// Hour
	i = ((TimeStamp >> 6) & 31);
	Format = ReplaceText(Format, "%HH",	PrePad(i));

	// Minute
	i = (TimeStamp & 63);
	Format = ReplaceText(Format, "%MI",	PrePad(i));

	return Format;
}

final function	int		GetDayPerMonth(int Month, int Year)
{
	switch (Month)
	{
		case 2 :	if ((Year & 3) == 0)
						return 29;
					else
						return 28;
		case 4 :
		case 6 :
		case 9 :
		case 11 : 	return 30;
		default	:	return 31;
	}

}

final function	string	GetDayOfWeek(int i)
{
	switch (i)
	{
		case 0: return "Sun";
		case 1: return "Mon";
		case 2: return "Tue";
		case 3: return "Wed";
		case 4: return "Thu";
		case 5: return "Fri";
		case 6: return "Sat";
	}
}

//----------------------------------------------------------------------------
// defaultproperties
//----------------------------------------------------------------------------
defaultproperties
{
	bHidden=True
	Debug=false
	PieceName=""
	PieceVersion=""
	PieceOrder=100
	ServerOnly=True
	BaseMessage=0
	CountDown=-1
}
