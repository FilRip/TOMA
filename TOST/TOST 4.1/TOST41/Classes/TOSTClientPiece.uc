//----------------------------------------------------------------------------
// Project : TOST
// File    : TOSTClientPiece.uc
// Version : 1.0
// Author  : BugBunny
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

// *** INIT

auto simulated state Init
{
	simulated function SearchHandler()
	{
		local TOSTClientHandler 	H;

		if ( Handler == None)
		{
			foreach AllActors(class'TOSTClientHandler', H)
			{
				Handler = H;
				Handler.AddPiece(self);
				EventInit();
				GotoState('');
				break;
			}
		}
	}
begin:
	while(true)
	{
		SearchHandler();
		Sleep(0.2);
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
	Handler.Params.Param1 = Param1;
	Handler.Params.Param2 = Param2;
	Handler.Params.Param3 = Param3;
	Handler.Params.Param4 = Param4;
	Handler.Params.Param5 = Param5;
	Handler.CltSendMessage(MsgIndex);
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

simulated function	EventInit()
{
}

defaultproperties
{
	bHidden=true

	BaseMessage=0
}
