//----------------------------------------------------------------------------
// Project : TOST
// File    : TOSTGUIBaseTab.uc
// Version : 4.0
// Author  : BugBunny
//----------------------------------------------------------------------------
// Version	Changes
// 4.0		+ first release
//----------------------------------------------------------------------------

class TOSTGUIBaseTab extends TO_GUIBaseTab;

var	string		TabName;
var class<TOSTClientPiece>	TabCommClass;

var TOSTCommunicator		Master;
var TOSTClientPiece			TabComm;

simulated function Close (optional bool bByParent)
{
	OwnerPlayerPawn = None;
	OwnerPlayer = None;
	OwnerHud = none;
	OwnerInterface = None;

	TabComm = none;
	Master = none;
	super.Close(bByParent);
}

// paint
simulated function BeforePaint (Canvas Canvas, float x, float y)
{
	if (!bInitialized)
	{
		Super.BeforePaint(Canvas, x, y);
		Setup(Canvas);
	}
	else
		Super.BeforePaint(Canvas, x, y);
}

simulated function Paint (Canvas Canvas, float x, float y)
{
	if (!bDraw)
		return;

	// background
	if (OwnerHud.bDrawBackground)
		Super.Paint(Canvas, x, y);
}

simulated function WindowEvent(WinMessage Msg, Canvas C, float X, float Y, int Key)
{
  	if (Msg == WM_KeyDown)
    	KeyDown(Key, X, Y);

  	Super.WindowEvent(Msg,C,X,Y,Key);
}

simulated function KeyDown (int Key, float x, float y)
{
}

simulated function Setup(Canvas Canvas)
{
}

defaultproperties
{
	TabName=""
	TabCommClass=none
}
