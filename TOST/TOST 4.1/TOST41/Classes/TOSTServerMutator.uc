//----------------------------------------------------------------------------
// Project : TOST
// File    : TOSTServerMutator.uc
// Version : 1.0
// Author  : BugBunny
//----------------------------------------------------------------------------
// Version	Changes
// 0.5		+ first release
// 0.6		+ first beta release
// 1.0		+ first public release
//----------------------------------------------------------------------------

class TOSTServerMutator expands Mutator config;

// *** VARIABLES

// ** Configuration

// Version
var 		string	TOSTVersion;

// Logging
var config	bool	TOSTLogEnabled;
var config	string	TOSTLogFilter;

// Pieces
var config	string	Pieces[20];

// **

var			TOSTServerActor		SA;

// Pieces
var			TOSTPiece	Piece;
var			TOSTPiece	LogPiece;
var			TOSTPiece	Bridge;		// special TOST piece for handling client messages

// Tracker
var			int			OldPeriod;

// Hook
var			TOSTLogSpawnNotify	LogSN;
var			TOSTStatLog			LogHook;

// Client Messager
var			TOSTClientHandler	ClientHandler[32];

// *** EVENTS

// ** Stat Events

function EventPlayerConnect(Pawn Player)
{
	AddClientHandler(PlayerPawn(Player));
	if (Piece != none)
		Piece.EventPlayerConnect(Player);
}

function EventPlayerDisconnect(Pawn Player)
{
	RemoveClientHandler(PlayerPawn(Player));
	if (Piece != none)
		Piece.EventPlayerDisconnect(Player);
}

function EventNameChange(Pawn Other)
{
	if (Piece != none)
		Piece.EventNameChange(Other);
}

function EventTeamChange(Pawn Other)
{
	if (Piece != none)
		Piece.EventTeamChange(Other);
}

function EventPickup(Inventory Item, Pawn Other)
{
	if (Piece != none)
		Piece.EventAfterPickup(Item, Other);
}

function EventItemActivate(Inventory Item, Pawn Other)
{
	if (Piece != none)
		Piece.EventItemActivate(Item, Other);
}

function EventItemDeactivate(Inventory Item, Pawn Other)
{
	if (Piece != none)
		Piece.EventItemDeactivate(Item, Other);
}

function EventSpecialEvent(string EventType, optional coerce string Arg1, optional coerce string Arg2, optional coerce string Arg3, optional coerce string Arg4)
{
	if (Piece != none)
		Piece.EventSpecialEvent(EventType, Arg1, Arg2, Arg3, Arg4);
}

function EventGameEnd( string Reason )
{
	if (Piece != none)
		Piece.EventAfterEndGame(Reason);
}


function EventGamePeriodChanged( int NewPeriod )
{
	if (Piece != none)
		Piece.EventGamePeriodChanged(NewPeriod);
}

// ** Mutator Events

function bool HandleRestartGame()
{
	local	bool	b;

	if (Piece != none)
		b = Piece.EventRestartGame();
	if (!b)
		b = super.HandleRestartGame();
	return b;
}

function bool HandleEndGame()
{
	local	bool	b;

	SaveConfig();
   	if (Piece != none)
	   	Piece.EventSaveConfig();

	if (Piece != none)
		b = Piece.EventBeforeEndGame();
	if (!b)
		b = super.HandleEndGame();
	return b;
}

function bool HandlePickupQuery(Pawn Other, Inventory item, out byte bAllowPickup)
{
	local	bool	b;

	if (Piece != none)
		b = Piece.EventBeforePickup(Other, Item, bAllowPickup);
	if (!b)
		b = super.HandlePickupQuery(Other, Item, bAllowPickup);
	return b;
}

function bool PreventDeath(Pawn Killed, Pawn Killer, name damageType, vector HitLocation)
{
	local	bool	b;

	if (Piece != none)
		b = Piece.EventPreventDeath(Killed, Killer, DamageType, HitLocation);
	if (!b)
		b = super.PreventDeath(Killed,Killer, damageType,HitLocation);
	return b;
}

function ScoreKill(Pawn Killer, Pawn Other)
{
	if (Piece != none)
		Piece.EventScoreKill(Killer, Other);
	super.ScoreKill(Killer, Other);
}

function ModifyPlayer(Pawn Other)
{
	if (Piece != none)
		Piece.EventModifyPlayer(Other);
	super.ModifyPlayer(Other);
}

function MutatorTakeDamage( out int ActualDamage, Pawn Victim, Pawn InstigatedBy, out Vector HitLocation,
						out Vector Momentum, name DamageType)
{
	if ( Piece != None )
		Piece.EventTakeDamage(ActualDamage, Victim, InstigatedBy, HitLocation, Momentum, DamageType);
	super.MutatorTakeDamage(ActualDamage, Victim, InstigatedBy, HitLocation, Momentum, DamageType);
}

function bool MutatorTeamMessage( Actor Sender, Pawn Receiver, PlayerReplicationInfo PRI, coerce string S, name Type, optional bool bBeep )
{
	local	bool	b;

	if (Piece != none)
		b = Piece.EventTeamMessage(Sender, Receiver, PRI, S, Type, bBeep);
	if (b)
		return super.MutatorTeamMessage( Sender, Receiver, PRI, S, Type, bBeep );
	else
		return false;
}

function bool MutatorBroadcastMessage( Actor Sender, Pawn Receiver, out coerce string Msg, optional bool bBeep, out optional name Type )
{
	local	bool	b;

	if (Piece != none)
		b = Piece.EventBroadcastMessage(Sender, Receiver, Msg, Type, bBeep);
	if (b)
		return super.MutatorBroadcastMessage( Sender, Receiver, Msg, bBeep, Type);
	else
		return false;
}

function bool MutatorBroadcastLocalizedMessage( Actor Sender, Pawn Receiver, out class<LocalMessage> Message, out optional int Switch, out optional PlayerReplicationInfo RelatedPRI_1, out optional PlayerReplicationInfo RelatedPRI_2, out optional Object OptionalObject )
{
	local	bool	b;

	if (Piece != none)
		b = Piece.EventBroadcastLocalizedMessage(Sender, Receiver, Message, switch, RelatedPRI_1, RelatedPRI_2, optionalObject );
	if (b)
		return super.MutatorBroadcastLocalizedMessage(Sender, Receiver, Message, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject );
	else
		return false;
}

function bool AlwaysKeep(Actor Other)
{
	local	bool	b;

	if (Piece != none)
		b = Piece.EventAlwaysKeep(Other);
	if (b)
		return super.AlwaysKeep(Other);
	else
		return false;
}

function bool IsRelevant(Actor Other, out byte bSuperRelevant)
{
	local bool bResult;

	// allow mutators to remove actors
	bResult = CheckReplacement(Other, bSuperRelevant);
	if (bResult)
		bResult = super.IsRelevant(Other, bSuperRelevant);
	return bResult;
}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	if (Piece != none)
		return	Piece.EventCheckReplacement(Other, bSuperRelevant);
	else
		return	true;
}


// ** Other Events

function Timer()
{
	local	TOSTPiece	Next;

	Next = Piece;
	while (Next != none)
	{
		if (Next.CountDown > 0)
		{
			Next.CountDown = Next.CountDown - 1;
		} else {
			if (Next.CountDown == 0)
				Next.CountDown = Next.EventTimer();
		}
		Next = Next.NextPiece;
	}
}

// *** GAME TRACKER

function Tick(float Delta)
{
	local int	GP;

	// check game period
	GP = GetCurrentGamePeriod();
	if (GP != OldPeriod)
	{
		EventGamePeriodChanged(GP);
		OldPeriod = GP;
	}
}

// * GameTracker Helper

function int GetCurrentGamePeriod()
{
	local	s_SWATGame	SG;

	SG = s_SWATGame(Level.Game);

	switch SG.GamePeriod
	{
		case	GP_PreRound:
					return 0;
		case	GP_RoundPlaying:
					return 1;
		case	GP_PostRound:
					return 2;
		case	GP_RoundRestarting:
					return 3;
		case	GP_PostMatch:
					return 4;
	}
}

// *** CLIENT MESSAGER

function	AddClientHandler(PlayerPawn Player)
{
	local int	i;

	for(i=0; i<32; i++)
	{
		if (ClientHandler[i] == none)
		{
			ClientHandler[i] = spawn(class'TOSTClientHandler', Player);
			ClientHandler[i].MyPlayer = Player;
			ClientHandler[i].Bridge = Bridge;
			break;
		}
	}
}

function	RemoveClientHandler(PlayerPawn Player)
{
	local int	i;

	i = FindPlayerIndex(Player);
	if (i != -1)
		ClientHandler[i].Destroy();
}

function	SendClientMessage(TOSTPiece Sender, int MsgIndex)
{
	local int	i;

	i = FindPlayerIndex(Sender.Params.Param6);
	if (i != -1)
		ClientHandler[i].SendClientMessage(Sender, MsgIndex);
}

function	BroadcastClientMessage(TOSTPiece Sender, int MsgIndex)
{
	local int	i;

	for (i=0; i<32; i++)
	{
		if (ClientHandler[i] != none)
			ClientHandler[i].SendClientMessage(Sender, MsgIndex);
	}
}

// *** PIECE MANAGMENT

function	ChangePieceEntry(int Index, string Piece)
{
	if (Index >= 0 && Index < ArrayCount(Pieces))
	{
		Pieces[Index] = Piece;
		SaveConfig();
	}
}

function	LoadPieces()
{
	local int				i;
	local class<TOSTPiece> 	TPC;
	local TOSTPiece			TP, next;

	Bridge = Spawn(class'TOSTClientBridge', self);
	Bridge.TOST = self;

	for (i=0; i<ArrayCount(Pieces); i++)
	{
		if (Pieces[i]!="")
		{
			TPC = class<TOSTPiece>(DynamicLoadObject(Pieces[i], class'Class', true));
			TP = Spawn(TPC, self);
			if (TP == none)
				continue;
			if (Piece == none)
			{
				Piece = TP;
				Piece.TOST = self;
			} else {
				if (Piece.PieceOrder > TP.PieceOrder)
				{
					TP.NextPiece = Piece;
					Piece = TP;
					Piece.TOST = self;
				} else
					Piece.AddPiece(TP);
			}
			TP.PackageName = TP.GetPackageName(TP.Class);
			TOSTLog("Loaded TOST piece : "$TP.PieceName$" (Version "$TP.PieceVersion$")");
		}
	}

	Bridge.NextPiece = Piece;

	if (Piece != none)
	{
		Piece.EventInit();
		Piece.EventPostInit();
	}

	SaveConfig();
   	if (Piece != none)
	   	Piece.EventSaveConfig();
}

function	TOSTPiece	GetPieceByIndex(int index)
{
	local TOSTPiece	next;
	local int		i;

	i = 0;
	next = Piece;
	while (i < index && next != none)
	{
		i++;
		next = next.NextPiece;
	}
	return next;
}

function	TOSTPiece	GetPieceByName(string PieceName)
{
	local TOSTPiece	next;

	next = Piece;
	while (next != none && next.PieceName != PieceName)
	{
		next = next.NextPiece;
	}
	return next;
}

// ** HELPER

function	int		FindPlayerIndex(PlayerPawn Player)
{
	local	int	i;

	if (Player != None)
	{
		for(i=0; i<32; i++)
		{
			if (ClientHandler[i] != None && ClientHandler[i].MyPlayer == Player)
				return i;
		}
	}
	return -1;
}

function	bool	PlayerPresent(int i)
{
	return (ClientHandler[i] != none);
}

// *** LOGGING
function	TOSTLog(string Msg)
{
	local Pawn	P;

	if (LogPiece != none)
		LogPiece.Logging(Msg);

    log(Msg, 'TOST');
    if (LogHook != none)
    {
    	LogHook.TOSTMessage = true;
        LogHook.LogEventString(Msg);
    	LogHook.TOSTMessage = false;
    }

	for (P = Level.PawnList; P != None; P = P.NextPawn)
	{
		if (P.IsA('MessagingSpectator'))
			P.ClientMessage(Msg, 'TOST');
	}
}

// *** START

function	StartUp()
{
	TOSTLog(TOSTVersion$" loaded...");

	LoadPieces();
}

function	PostBeginPlay()
{
	// register mutators
	Level.Game.RegisterDamageMutator(self);
	Level.Game.RegisterMessageMutator(self);

	// init variables
	OldPeriod = GetCurrentGamePeriod();

    // start timer
	SetTimer(1, true);

	LogHook = spawn(class'TOSTStatLog', Level.Game);
	LogHook.TOST = self;
	LogHook.Backup = none;
    if (Level.Game.bLoggingGame && Level.Game.bLocalLog)
    {
    	LogSN = spawn(class'TOSTLogSpawnNotify');
    	LogSN.TOST = self;
    } else {
		Level.Game.LocalLog = LogHook;
		LogHook.StartLog();
	}
}

defaultproperties
{
	bHidden=True
	TOSTVersion="TOST 4.1.4.0"
	TOSTLogEnabled=True
	TOSTLogFilter=""

	Pieces(0)="TOSTTools.TOSTServerTools"
	Pieces(1)="TOSTTools.TOSTServerAds"
	Pieces(2)="TOSTTools.TOSTMapHandling"
	Pieces(3)="TOSTTools.TOSTSettings"
	Pieces(4)="TOSTTools.TOSTSemiAdmin"
	Pieces(5)="TOSTTools.TOSTCheatID"
	Pieces(6)="TOSTFun.TOSTFunPiece"
	Pieces(7)="TOSTProtect.TOSTProtect"
	Pieces(8)="TOSTClient.TOSTClient"
	Pieces(9)="TOSTIRC.TOSTServerReporter"
	Pieces(10)="TOSTHitparade.TOSTHitparade"
	Pieces(11)="TOSTTools.TOSTBanList"
	Pieces(12)=""
	Pieces(13)=""
	Pieces(14)=""
	Pieces(15)=""
	Pieces(16)=""
	Pieces(17)=""
	Pieces(18)=""
	Pieces(19)=""
}



