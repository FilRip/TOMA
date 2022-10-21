//----------------------------------------------------------------------------
// Project : TOST
// File    : TOSTHUDLogoComm.uc
// Version : 1.0
// Author  : BugBunny
//----------------------------------------------------------------------------
// Version	Changes
// 0.5		+ first release
// 0.6		+ first beta release
// 1.0		+ first public release
//----------------------------------------------------------------------------

class TOSTHUDLogoComm extends TOSTClientPiece;

simulated function	EventInit()
{
	SendMessage(162, 0);
}

simulated function	AcceptString(int Index, string Info, bool Finished)
{
	switch (Index) {
		case 0 : TOSTHUDTOSTLogo(Master).VersionStr = Info;	break;
		case 1 : TOSTHUDTOSTLogo(Master).CustomLogoTexture = Info; break;
		case 2 : TOSTHUDTOSTLogo(Master).ServerText[0] = Info; break;
		case 3 : TOSTHUDTOSTLogo(Master).ServerText[1] = Info; break;
		case 4 : TOSTHUDTOSTLogo(Master).ServerText[2] = Info; break;
		case 5 : TOSTHUDTOSTLogo(Master).ServerText[3] = Info; break;
		case 6 : TOSTHUDTOSTLogo(Master).LogoHeight = int(Info); break;
		case 7 : TOSTHUDTOSTLogo(Master).TOPVersionStr = Info; break;
	}
	TOSTHUDTOSTLogo(Master).bInitialized = Finished;
}

simulated function	EventMessage(int MsgIndex)
{
	switch (MsgIndex) {
		case BaseMessage+0 	:	if (Handler.Params.Param1 == 0)
									AcceptString(Handler.Params.Param2, Handler.Params.Param4, Handler.Params.Param5);
								break;
	}
	super.EventMessage(MsgIndex);
}

defaultproperties
{
	bHidden=true

	BaseMessage=130
}

