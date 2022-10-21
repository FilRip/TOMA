// $Id: TOSTGUIMaster.uc 487 2004-03-07 14:29:51Z dildog $
//----------------------------------------------------------------------------
// Project : TOST
// File    : TOSTGUIMaster.uc
// Version : 0.6
// Author  : BugBunny
//----------------------------------------------------------------------------

class TOSTGUIMaster extends TOSTClientPiece;

var		TO_GUIBaseMgr		Mgr;
var		bool				NoTabs;
var		int					PendingTab;

simulated function	Tick(float Delta)
{
	if (PendingTab > 0 && !NoTabs && !(WindowConsole(Mgr.OwnerHud.PlayerOwner.Player.Console).bTyping))
	{
		Mgr.ToggleTab(PendingTab);
		PendingTab = 0;
	}
}

simulated function	ShutdownGUI()
{
	if (Mgr.Visible())
		Mgr.Hide();
	NoTabs = true;
}

simulated function	RecoverGUI()
{
	NoTabs = false;
}

simulated function	ChangeTab(string TabName, bool StayOpen)
{
	local	int	i;

	if (NoTabs)
		return;
	i = TOSTCommunicator(Master).FindGUITab(TabName);
	if (i != -1)
	{
		if (StayOpen && i == Mgr.CurrentTab)
			return;
		if (WindowConsole(Mgr.OwnerHud.PlayerOwner.Player.Console).bTyping)
			PendingTab = i;
		else
			Mgr.ToggleTab(i);
	}
}

simulated function	ChangeSALevel(int Level)
{
	TOSTCommunicator(Master).SemiAdmin = Level;
}

simulated function	EventMessage(int MsgIndex)
{
	switch (MsgIndex) {
		case BaseMessage+0 :	ShutdownGUI();
								break;
		case BaseMessage+1 :	RecoverGUI();
								break;
		case BaseMessage+2 :	ChangeTab(Handler.Params.Param4, Handler.Params.Param5);
								break;
		case 200 :				ChangeSALevel(Handler.Params.Param1);
								break;
	}
	super.EventMessage(MsgIndex);
}

defaultproperties
{
	bHidden=true

	PendingTab=-1

	BaseMessage=110;
}


