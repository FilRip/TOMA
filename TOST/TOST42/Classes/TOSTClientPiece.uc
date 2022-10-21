// $Id: TOSTClientPiece.uc 503 2004-03-21 16:21:47Z stark $
//----------------------------------------------------------------------------
// Project : TOST
// File    : TOSTClientPiece.uc
// Version : 1.0
// Author  : BugBunny/Stark
//----------------------------------------------------------------------------
// Version	Changes
// 0.5		+ first release
// 0.6		+ first beta release
// 1.0		+ first public release
//----------------------------------------------------------------------------

class TOSTClientPiece expands Info;

var	TOSTClientHandler	Handler;
var TOSTClientPiece 	NextPiece;

var int					BaseMessage;
var Actor				Master;
var TO_GUIBaseTab		MasterTab;

// *** MESSAGE-QUEUE
const QIdletime = 0.5;
struct Msg
{
	var int		MsgIndex;
	var int 	Param1;
	var int 	Param2;
	var float 	Param3;
	var string 	Param4;
	var bool 	Param5;
};
var Msg Q[64];
var int QHead, QTail;
var float QWait;

// *** INIT

auto simulated state Init
{
begin:
	QInit();
	while (Handler==None)
	{
		global.SearchHandler();
		Sleep(0.2);
	}
}

simulated function SearchHandler()
{
	local TOSTClientHandler H;
    local PlayerPawn P;

	if (Handler == None)
		foreach AllActors(class'TOSTClientHandler', H)
		{
			Handler = H;
			Handler.AddPiece(self);
			EventInit();
			GotoState('');
			break;
		}

	if (Handler != None && Handler.MyPlayer == None)
		foreach AllActors(class'PlayerPawn', P)
			if (P.Player != None)
			{
				Handler.MyPlayer = P;
				break;
			}
}

// acc. nones here.....
function Tick (float delta)
{
	local int MsgIndex, Param1, Param2, Param5;
	local float Param3;
	local string Param4;
	local float IDLE;

    if (Handler!=None && Handler.MyPlayer!=None
		&& Handler.MyPlayer.PlayerReplicationInfo != none
		&& Handler.MyPlayer.PlayerReplicationInfo.bAdmin) // O_o
		IDLE = QIdletime/5;
    else
		IDLE = QIdletime;

	QWait += delta;
	if (QWait > IDLE)
	{
		if (QHead != QTail) // Queue not empty?
		{
			QDequeue(MsgIndex, Param1, Param2, Param3, Param4, Param5);
			Handler.Params.Param1 = Param1;
			Handler.Params.Param2 = Param2;
			Handler.Params.Param3 = Param3;
			Handler.Params.Param4 = Param4;
			Handler.Params.Param5 = bool(Param5);
			Handler.CltSendMessage(MsgIndex);
			QWait = 0;
		}
	}
}

// *** PIECE HANDLING

simulated function		AddPiece(TOSTClientPiece P)
{
	if (NextPiece == none)
	{
		NextPiece = P;
		P.Handler = Handler;
	} else
		NextPiece.AddPiece(P);
}

simulated event			Destroyed()
{
	local	TOSTClientPiece	next, prev;

	if (MasterTab != none)
		MasterTab = none;

	if (Handler == none)
		return;

	next = Handler.Piece;
	prev = none;
	while (next != self && next != none)
	{
		prev = next;
		next = next.NextPiece;
	}
	if (next == self && prev == none)
		Handler.Piece = NextPiece;
	if (next == self && prev != none)
		prev.NextPiece = NextPiece;

}

// *** MESSAGE HANDLING

simulated function	SendMessage(int MsgIndex, optional int Param1, optional int Param2, optional float Param3, optional string Param4, optional bool Param5)
{
	if (Handler == None) SearchHandler();

	if (MsgIndex==130 || MsgIndex==200 || MsgIndex==205 || MsgIndex==192)
	{
		Handler.Params.Param1 = Param1;
		Handler.Params.Param2 = Param2;
		Handler.Params.Param3 = Param3;
		Handler.Params.Param4 = Param4;
		Handler.Params.Param5 = Param5;
		Handler.CltSendMessage(MsgIndex);
	}
	else
	{
		QEnqueue(MsgIndex, Param1, Param2, Param3, Param4, Param5);
	}
}

simulated function	SendClientMessage(int MsgIndex, optional int Param1, optional int Param2, optional float Param3, optional string Param4, optional bool Param5)
{
	Handler.Params.Param1 = Param1;
	Handler.Params.Param2 = Param2;
	Handler.Params.Param3 = Param3;
	Handler.Params.Param4 = Param4;
	Handler.Params.Param5 = Param5;
	Handler.CltPassMessage(MsgIndex, Handler.Params);
}

simulated function	EventMessage(int MsgIndex)
{
	if (NextPiece != none)
		NextPiece.EventMessage(MsgIndex);
}

// *** Message Queue Functions
function QInit()
{
	local int i;

	QHead = 0;
    QTail = 0;
    for (i=0; i < ArrayCount(Q); i++)
	{
		Q[i].MsgIndex = 0;
		Q[i].Param1 = 0;
	    Q[i].Param2 = 0;
	    Q[i].Param3 = 0.0;
	    Q[i].Param4 = "";
	    Q[i].Param5 = false;
	};
}

function QEnqueue (int MsgIndex, optional int Param1, optional int Param2, optional float Param3, optional string Param4, optional bool Param5)
{
    if (QHead == (QTail+1)%ArrayCount(Q))
    {
        log("local message queue overflow, Size="$ArrayCount(Q), 'TOSTdebug');
        QHead = (QHead+1)%ArrayCount(Q);
    }
    Q[QTail].MsgIndex = MsgIndex;
	Q[QTail].Param1 = Param1;
    Q[QTail].Param2 = Param2;
    Q[QTail].Param3 = Param3;
    Q[QTail].Param4 = Param4;
    Q[QTail].Param5 = Param5;

    QTail = (QTail+1)%ArrayCount(Q);
}

function QDequeue(out int MsgIndex, out int Param1, out int Param2, out float Param3, out string Param4, out int Param5)
{
    MsgIndex = Q[QHead].MsgIndex;
	Param1 = Q[QHead].Param1;
    Param2 = Q[QHead].Param2;
    Param3 = Q[QHead].Param3;
    Param4 = Q[QHead].Param4;
    Param5 = int(Q[QHead].Param5);

    QHead = (QHead+1)%ArrayCount(Q);
}

simulated function	EventInit()
{
}

defaultproperties
{
	bHidden=true

	BaseMessage=0
}
