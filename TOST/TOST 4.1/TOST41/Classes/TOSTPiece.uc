//----------------------------------------------------------------------------
// Project : TOST
// File    : TOSTPiece.uc
// Version : 1.2
// Author  : BugBunny
//----------------------------------------------------------------------------
// Version	Changes
// 0.5		+ first release
// 0.6		+ first beta release
// 1.0		+ first public release
// 1.1		+ added CheckReplacement/AlwaysKeep mutator calls
// 1.2		+ added GetPackageName function/PackageName variable
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

struct MsgParams {
	var	int			Param1;
	var int			Param2;
	var	float		Param3;
	var string		Param4;
	var	bool		Param5;
	var PlayerPawn	Param6;
};
var MsgParams	Params;

// *** COMMON HELPER

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

// *** PIECE HANDLING

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

// *** LOGGING

function        XLog(string msg)
{
	if ((TOST.TOSTLogFilter == "") || (InStr(";"$PieceName$";", ";"$TOST.TOSTLogFilter$";") != -1))
	    TOST.TOSTLog(PieceName$":"@msg);
}


function		Logging(out string Msg)
{
	if (NextLogPiece != none)
		NextLogPiece.Logging(Msg);
}

// *** EVENTS

// StatLog
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

// Mutator

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


// Other

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

// *** MESSAGE HANDLING

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

defaultproperties
{
	bHidden=True
	PieceName=""
	PieceVersion=""
	PieceOrder=100
	ServerOnly=True
	BaseMessage=0
	CountDown=-1
}
