//----------------------------------------------------------------------------
// Project : TOST
// File    : TOSTServerAds.uc
// Version : 1.0
// Author  : BugBunny
//----------------------------------------------------------------------------
// Version	Changes
// 0.5		+ first release
// 0.6		+ first beta release
// 1.0		+ first public release
//----------------------------------------------------------------------------

class TOSTServerAds expands TOSTPiece config;

var config	string	Messages[25];
var config	int		MessageTime;
var int				CurrentMessage;
var bool			CWMode;

// ** Event Handling

function	EventInit()
{
	CountDown = MessageTime;
	CurrentMessage = -1;
	super.EventInit();
}

function	int	EventTimer()
{
	local	int i;

	if (!CWMode)
	{
		CurrentMessage++;
		while (CurrentMessage < ArrayCount(Messages) && Messages[CurrentMessage]=="")
			CurrentMessage++;
		if (CurrentMessage >= ArrayCount(Messages))
			CurrentMessage=0;
		if (InStr(Messages[CurrentMessage], ";") == 1)
		{
			i = int(Left(Messages[CurrentMessage], 1));
			Level.Game.BroadcastMessage(Mid(Messages[CurrentMessage], 2));
			while (i > 1)
			{
				CurrentMessage++;
				while (CurrentMessage < ArrayCount(Messages) && Messages[CurrentMessage]=="")
					CurrentMessage++;
				if (CurrentMessage >= ArrayCount(Messages))
					CurrentMessage=0;
				Level.Game.BroadcastMessage(Messages[CurrentMessage]);
				i--;
			}
		} else
			if (Messages[CurrentMessage] != "")
				Level.Game.BroadcastMessage(Messages[CurrentMessage]);
	}
	return MessageTime;
}

// ** Message Handling

function	EventMessage(TOSTPiece Sender, int MsgIndex)
{
	switch (MsgIndex)
	{
		// CWMode
		case 117			:	CWMode = Sender.Params.Param5;
								break;
	}
	super.EventMessage(Sender, MsgIndex);
}

defaultproperties
{
	bHidden=True

	PieceName="TOST Server Ads"
	PieceVersion="1.0.0.0"
	ServerOnly=true

	MessageTime=150
}

