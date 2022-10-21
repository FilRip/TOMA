// $Id: TOSTHUDExtComm.uc 487 2004-03-07 14:29:51Z dildog $
//----------------------------------------------------------------------------
// Project : TOST
// File    : TOSTHUDExtComm.uc
// Version : 1.0
// Author  : BugBunny
//----------------------------------------------------------------------------
// Version	Changes
// 0.5		+ first release
// 0.6		+ first beta release
// 1.0		+ first public release
//----------------------------------------------------------------------------

class TOSTHUDExtComm extends TOSTClientPiece;

var string		RecordingList;
var	bool		CWMode;

simulated function	EventInit()
{
	// Ask for CWmode
	SendMessage(120, 125);

	super.EventInit();
}

simulated function	EventMessage(int MsgIndex)
{
	switch (MsgIndex) {
		case 100		 	:	AcceptInfo(Handler.Params.Param1, Handler.Params.Param2,  Handler.Params.Param3,  Handler.Params.Param4,  Handler.Params.Param5);
								break;
		case BaseMessage+0 	:	TOSTHUDExtension(Master).AddStatusMessage(Handler.Params.Param4);
								break;
		case BaseMessage+1	:	TOSTHUDExtension(Master).PlayClientSound(Handler.Params.Param4, Handler.Params.Param1, Handler.Params.Param2);
								break;
		case BaseMessage+2	:	TOSTHUDExtension(Master).ShowTime();
								break;
		case BaseMessage+3	:	Demo_Rec(Handler.Params.Param1, Handler.Params.Param4);
								break;
		case BaseMessage+4	:	RecordingList=Handler.Params.Param4;
								break;
	}
	super.EventMessage(MsgIndex);
}

simulated function	AcceptInfo(int Index, int i, float f, string s, bool b)
{
	switch (Index)
	{
		case 125 :	CWMode = b;
					break;
	}
}

simulated function Demo_Rec(int PlayerID, string sFilename)
{
	local string sResult;

	if ( (Playerpawn(Owner.Owner).PlayerReplicationInfo.PlayerID != PlayerID) && (PlayerID != 0) )
		return;

	sResult = PlayerPawn(Owner.Owner).ConsoleCommand("demorec"@sFilename$".dem");
	PlayerPawn(Owner.Owner).Player.Console.addstring(sResult@"(Forced by Admin)");
}

defaultproperties
{
	BaseMessage=120
}

