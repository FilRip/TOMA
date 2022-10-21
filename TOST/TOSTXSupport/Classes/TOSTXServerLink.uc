//----------------------------------------------------------------------------
// Project : TOST
// File    : TOSTXServerLink.uc
// Version : 0.5
// Author  : BugBunny
//----------------------------------------------------------------------------
// Version	Changes
// 0.5		+ First Release
//----------------------------------------------------------------------------

class TOSTXServerLink extends TCPLink config;

var config	int		MaxConnections;

var TOSTXSupport	Master;
var	TOSTXClientLink	Links[32];

var int				ConnectionCount;

function Init()
{
	Master.XLog("Listening on port : "$BindPort(Level.Game.GetServerPort()+2, true));
	Listen();
}

event GainedChild( Actor C )
{
	local	int	i;

	Super.GainedChild(C);

	if (!C.IsA('TOSTXClientLink'))
		return;

	ConnectionCount++;
	for (i=0; i<ArrayCount(Links); i++)
		if (Links[i] == None)
		{
			Links[i] = TOSTXClientLink(C);
			break;
		}

	// if too many connections, close down listen.
	if(MaxConnections > 0 && ConnectionCount > MaxConnections && LinkState == STATE_Listening)
	{
		Master.XLog("Too many connections - closing down Listen.");
		Close();
	}
}

event LostChild( Actor C )
{
	local	int	i;

	Super.LostChild(C);
	ConnectionCount--;

	if (!C.IsA('TOSTXClientLink'))
		return;

	for (i=0; i<ArrayCount(Links); i++)
		if (Links[i] == C)
		{
			Links[i] = none;
			break;
		}

	// if closed due to too many connections, start listening again.
	if(ConnectionCount <= MaxConnections && LinkState != STATE_Listening)
	{
		Master.XLog("Listening again - connections have been closed.");
		Listen();
	}
}

function	AnnounceMessage(string Msg)
{
	local	int i;

	for (i=0; i<ArrayCount(Links); i++)
		if (Links[i] != None)
			Links[i].ConsoleMessage(Msg);
}

defaultproperties
{
	MaxConnections=5
    AcceptClass=Class'TOSTXClientLink'
}
