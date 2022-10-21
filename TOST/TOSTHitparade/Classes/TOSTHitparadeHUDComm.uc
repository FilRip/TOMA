// $Id: TOSTHitparadeHUDComm.uc 433 2004-02-16 18:24:54Z stark $
//----------------------------------------------------------------------------
// Project : TOSTPiece hitparade
// Author  : [BB]Stark <stark@bbclan.de>
//----------------------------------------------------------------------------
// Comments:
//
// 	MsgIdx	Details					Param1(int) 	Param4(string) 	Param5(bool)
//	260		HUD on/off				0/1 Timer-off?	-				enable
//	261		add a Attacker-Line		-				Line			-
//	262		add a Victim-Line		-				Line			-
//	263		add a Pstat-Line		-				Line			-
//	264		add a Gstat-Line		-				Line			-
//	265		reset HUD				-				-				-
//	266		toggle HUD				-				-				-
//----------------------------------------------------------------------------

class TOSThitparadeHUDComm expands TOSTClientPiece;

simulated function	EventMessage(int MsgIndex)
{
	switch (MsgIndex) {
		case BaseMessage:	TOSThitparadeHUD(Master).bEnabled = Handler.Params.Param5;
							if (Handler.Params.Param1 == 1)
								TOSThitparadeHUD(Master).fadeOutTimer();
							break;
		case BaseMessage+1:	TOSThitparadeHUD(Master).addAttLine(Handler.Params.Param4);
							break;
		case BaseMessage+2:	TOSThitparadeHUD(Master).addVicLine(Handler.Params.Param4);
							break;
		case BaseMessage+3:	TOSThitparadeHUD(Master).addPstatLine(Handler.Params.Param4);
							break;
		case BaseMessage+4:	TOSThitparadeHUD(Master).addGstatLine(Handler.Params.Param4);
							break;
		case BaseMessage+5:	TOSThitparadeHUD(Master).resetHUD();
							break;
		case BaseMessage+6:	TOSThitparadeHUD(Master).toggleHUD();
							break;
        // GetValue
		case 120 			:	GetValue(Handler.Params.Param1);
								break;
		// SetValue
		case 121 			:	SetValue(Handler.Params.Param1, Handler.Params.Param2, Handler.Params.Param3, Handler.Params.Param4, Handler.Params.Param5);
								break;
	}
	super.EventMessage(MsgIndex);
}

function	GetValue(int Index)
{
//	Handler.Params.Param6 = Player;
	Handler.Params.Param1 = Index;

	switch (Index)
	{
		case 253 :	Handler.Params.Param5 = TOSThitparadeHUD(Master).bShowStats;
					break;
		case 254 :	Handler.Params.Param2 = TOSThitparadeHUD(Master).HUDDisplayTime;
					break;

	}
	if (Index >= 253 && Index <= 254)
	{
		SendMessage(120);
	}
}

function	SetValue(int Index, int i, float f, string s, bool b)
{
	switch (Index)
	{
        case 253 :	TOSThitparadeHUD(Master).bShowStats = b;
            		break;
        case 254 :	TOSThitparadeHUD(Master).HUDDisplayTime = i;
            		break;
	}
	SaveConfig();
}

defaultproperties
{
	bHidden=true
	BaseMessage=260
}
