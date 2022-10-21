// $Id: TOSTClientHandler.uc 503 2004-03-21 16:21:47Z stark $
//----------------------------------------------------------------------------
// Project : TOST
// File    : TOSTClientHandler.uc
// Version : 1.0
// Author  : BugBunny
//----------------------------------------------------------------------------
// Version	Changes
// 0.5		+ first release
// 0.6		+ first beta release
// 1.0		+ first public release
//----------------------------------------------------------------------------

class TOSTClientHandler expands ReplicationInfo;

// server
var TOSTPiece			Bridge;
var PlayerPawn			MyPlayer; // Server+Client
var float				LastMessage;

// client
var	TOSTClientPiece		Piece;

struct MsgParams {
	var	int			Param1;
	var int			Param2;
	var	float		Param3;
	var string		Param4;
	var	bool		Param5;
};
var MsgParams	Params;

replication
{
    // Server -> Client
   	reliable if (ROLE == ROLE_Authority && !bDemoRecording)
		CltPassMessage;

	// Client -> Server
	reliable if ( Role < ROLE_Authority )
		PassMessage;
}

// --------------- SERVER -----------------

// * SendClientMessage - send message to client pieces
function	SendClientMessage(TOSTPiece Sender, int MsgIndex)
{
	Params.Param1 = Sender.Params.Param1;
	Params.Param2 = Sender.Params.Param2;
	Params.Param3 = Sender.Params.Param3;
	Params.Param4 = Sender.Params.Param4;
	Params.Param5 = Sender.Params.Param5;

	CltPassMessage(MsgIndex, Params);
}

// * PassMessage - receive message from client
function	PassMessage(int MsgIndex, MsgParams CltParams)
{
	if  ((MsgIndex == 100 || MsgIndex == 204)) // tostinfo + Policydetails spamprotection
	{
		if (LastMessage + 5.0 > Level.TimeSeconds)
		{
			MyPlayer.ClientMessage("Command only allowed all 5 seconds!");
			return;
		} else {
			LastMessage = Level.TimeSeconds;
		}
	}
	Bridge.Params.Param1 = CltParams.Param1;
	Bridge.Params.Param2 = CltParams.Param2;
	Bridge.Params.Param3 = CltParams.Param3;
	Bridge.Params.Param4 = CltParams.Param4;
	Bridge.Params.Param5 = CltParams.Param5;
	Bridge.Params.Param6 = MyPlayer;
	if (Bridge.CheckClearance(MyPlayer, MsgIndex)) {
		Bridge.SendMessage(MsgIndex);
	} else {
		if (MsgIndex != 120)
			MyPlayer.ClientMessage("You do not have the privileges to use this command !");
	}
}

// --------------- CLIENT -----------------

// *** PIECE MANAGMENT

simulated function	AddPiece(TOSTClientPiece NewPiece)
{
	if (Piece == None)
		Piece = NewPiece;
	else
		Piece.AddPiece(NewPiece);
}

// *** MESSAGE HANDLING

simulated function	CltSendMessage(int MsgIndex)
{
	PassMessage(MsgIndex, Params);
}

simulated function	CltPassMessage(int MsgIndex, MsgParams CltParams)
{
	Params = CltParams;

	if (Piece != None)
		Piece.EventMessage(MsgIndex);
}

defaultproperties
{
	bHidden=true

	bAlwaysRelevant=False
	bAlwaysTick=True
	RemoteRole=ROLE_SimulatedProxy
	NetPriority=2.000000
}
