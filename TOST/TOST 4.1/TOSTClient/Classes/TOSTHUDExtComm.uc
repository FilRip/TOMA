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

simulated function	EventMessage(int MsgIndex)
{
	switch (MsgIndex) {
		case BaseMessage+0 	:	TOSTHUDExtension(Master).AddStatusMessage(Handler.Params.Param4);
								break;
		case BaseMessage+1	:	TOSTHUDExtension(Master).PlayClientSound(Handler.Params.Param4, Handler.Params.Param1, Handler.Params.Param2);
								break;
		case BaseMessage+2	:	TOSTHUDExtension(Master).ShowTime();
								break;
	}
	super.EventMessage(MsgIndex);
}

defaultproperties
{
	bHidden=true

	BaseMessage=120
}

