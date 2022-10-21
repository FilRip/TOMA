//----------------------------------------------------------------------------
// Project : TOST
// File    : TOSTGUIVoteTab.uc
// Version : 4.0
// Author  : BugBunny
//----------------------------------------------------------------------------
// Version	Changes
// 4.0		+ first release
//----------------------------------------------------------------------------

class TOSTGUIVoteTab extends TOSTGUIBaseTab;

var localized string		TextVoteTitle;

var localized string		TextHintDefault, TextHintDefaultAlt;

var localized string		TextButtonClose, TextHintCloseButton;
var localized string		TextButtonVote, TextHintVoteButton;
var localized string		TextButtonVoteLvl, TextHintVoteLvlButton;
var localized string		TextBoxLevels, TextHintLevelsBox;
var localized string		TextBoxPlayers, TextHintPlayersBox;

var TOSTGUIBaseButton		ButtonClose;
var TOSTGUIBaseButton		ButtonVoteLvl, ButtonVote;
var TOSTGUITextListbox		BoxPlayers;
var TOSTGUIVoteListbox		BoxLevels;

var int						LastMapCount;

var int						Top10[10];

simulated function Created ()
{
	Super.Created();

	Title = TextVoteTitle;

	ButtonClose = TOSTGUIBaseButton(CreateWindow(class'TOSTGUIBaseButton', 0, 0, WinWidth, WinHeight));
	ButtonClose.Text = TextButtonClose;
	ButtonClose.OwnerTab = self;

	// player buttons

	ButtonVote = TOSTGUIBaseButton(CreateWindow(class'TOSTGUIBaseButton', 0, 0, WinWidth, WinHeight));
	ButtonVote.Text = TextButtonVote;
	ButtonVote.OwnerTab = self;

	// level buttons
	ButtonVoteLvl = TOSTGUIBaseButton(CreateWindow(class'TOSTGUIBaseButton', 0, 0, WinWidth, WinHeight));
	ButtonVoteLvl.Text = TextButtonVoteLvl;
	ButtonVoteLvl.OwnerTab = self;

	// list boxes
	BoxLevels = TOSTGUIVoteListbox(CreateWindow(class'TOSTGUIVoteListbox', 0, 0, WinWidth, WinHeight));
	BoxLevels.Label = TextBoxLevels;
	BoxLevels.OwnerTab = self;

	BoxPlayers = TOSTGUITextListbox(CreateWindow(class'TOSTGUITextListbox', 0, 0, WinWidth, WinHeight));
	BoxPlayers.Label = TextBoxPlayers;
	BoxPlayers.OwnerTab = self;
	BoxPlayers.bMultiSelect = true;
}

simulated function Close (optional bool bByParent)
{
	ButtonClose.Close();
	ButtonVote.Close();
	ButtonVoteLvl.Close();
	BoxLevels.Close();
	BoxPlayers.Close();

	Super.Close(bByParent);
}

simulated function BeforePaint (Canvas Canvas, float x, float y)
{
	Super.BeforePaint(Canvas, x, y);

	UpdatePlayerList();
	UpdateMapList();
}

// update functions

simulated function UpdatePlayerList()
{
	local PlayerReplicationInfo	PRI[32], Swap;
	local int					Selected[32];
	local PlayerReplicationInfo a;
	local int					i, j, k, l, Count, position;

	position = BoxPlayers.TopIndex;
	Count = 0;

	for(l=0; l<32; l++)
	{
		a = OwnerPlayerPawn.GameReplicationInfo.PRIArray[l];
		if (a == none || a.bIsABot || (a.bIsSpectator && a.PlayerName == "Player"))
			continue;
		i = BoxPlayers.FindData(a.PlayerID);
		PRI[Count] = a;
		k = Count;
		for (j=Count-1; j>=0; j--)
		{
			if (PRI[j].bIsSpectator) { 	// Spec
				if (PRI[j+1].bIsSpectator && PRI[j+1].StartTime > PRI[j].StartTime)
					break;
			} else {
				if (PRI[j].Team == 1) { // Swat
					if (PRI[j+1].Team == 1 && PRI[j+1].StartTime > PRI[j].StartTime)
						break;
				} else {		// Terr
					if (PRI[j+1].Team == 0 && PRI[j+1].StartTime > PRI[j].StartTime)
						break;
				}
			}
			// exchange
			Swap = PRI[j+1];
			PRI[j+1] = PRI[j];
			PRI[j] = Swap;
			Selected[j+1] = Selected[j];
			k=j;
		}
		if (i != -1 && BoxPlayers.IsSelectedByIndex(i))	{
			Selected[k] = 1;
		} else {
			Selected[k] = 0;
		}
		Count++;
	}
	// update list
	BoxPlayers.Clear();
	for (i=0; i<Count; i++)
		if (PRI[i].Team == 0)
			BoxPlayers.AddItem(PRI[i].PlayerName@"[Terr]", "Player ID :"@PRI[i].PlayerID, PRI[i].PlayerID, (Selected[i] == 1));
		else if (PRI[i].Team == 1)
			BoxPlayers.AddItem(PRI[i].PlayerName@"[Swat]", "Player ID :"@PRI[i].PlayerID, PRI[i].PlayerID, (Selected[i] == 1));
		else
			BoxPlayers.AddItem(PRI[i].PlayerName@"[Spec]", "Player ID :"@PRI[i].PlayerID, PRI[i].PlayerID, (Selected[i] == 1));
	BoxPlayers.TopIndex = position;
}


simulated function UpdateMapList()
{
	local int	i, j;
	local int	mv;

	if (Master.MapHandler.MapUpdate)
	{
		j=0;
		for (i=0; i<LastMapCount; i++)
		{
			if (Master.MapHandler.GetMapVoteCount(i) != -1)
			{
				BoxLevels.UpdateData(j, Master.MapHandler.GetMapVoteCount(i));
				j++;
			}
		}
		mv = 0;
		for (i=0; i<10; i++)
			Top10[i]=-1;
		for (i=0; i<LastMapCount; i++)
		{
			if (Master.MapHandler.GetMapVoteCount(i) > mv)
				mv = Master.MapHandler.GetMapVoteCount(i);
		}
		j = 0;
		while (mv > 0) do
		{
			for(i=0; i<LastMapCount; i++)
			{
				if (Master.MapHandler.GetMapVoteCount(i) == mv)
					TOP10[j++] = i;
				if (j>9)
					break;
			}
			mv--;
			if (j>9 || mv < 1)
				break;
		}
		Master.MapHandler.MapUpdate = false;
	}

	// check for updates
	if (LastMapCount == Master.MapHandler.MapCount)
		return;

	// simply add new maps
	for (i=LastMapCount; i<Master.MapHandler.MapCount; i++)
	{
		if (Master.MapHandler.GetMapVoteCount(i) != -1)
			BoxLevels.AddItem(Master.MapHandler.GetMap(i), "", i, False);
	}

	LastMapCount = Master.MapHandler.MapCount;
}

// paint
simulated function Paint (Canvas Canvas, float x, float y)
{
	Super.Paint(Canvas, x, y);

	if (bDraw)
		DrawTop10(Canvas);
}

simulated function DrawTop10(Canvas C)
{
	local int		i, y, x, x2;
	local float		xl, yl;
	local string 	s;

	y = ButtonVoteLvl.WinTop+ButtonVoteLvl.WinHeight+1.5*Padding[Resolution];
	x = ButtonVoteLvl.WinLeft;
	x2 = ButtonVoteLvl.WinLeft + ButtonVoteLvl.WinWidth - 0.5*Padding[Resolution];
	C.DrawColor = OwnerInterface.Design.ColorYellow;
	C.Font = OwnerHud.Design.Font12;

	for (i=1; i<=5; i++)
	{
		if (Top10[i-1] != -1)
		{
			s = i$". "$Master.MapHandler.GetMap(Top10[i-1]);
			C.StrLen(s, xl, yl);
			C.SetPos(x, y);
			C.DrawText(s);
			s = "("$Master.MapHandler.GetMapVoteCount(Top10[i-1])$")";
			C.StrLen(s, xl, yl);
			C.SetPos(x2 - xl, y);
			C.DrawText(s);
			y += yl + 0.5*Padding[Resolution];
			C.DrawColor = C.DrawColor * 0.85;
		}
	}

	y = ButtonVoteLvl.WinTop+ButtonVoteLvl.WinHeight+1.5*Padding[Resolution];
	x = ButtonVote.WinLeft;
	x2 = ButtonVote.WinLeft + ButtonVote.WinWidth - 0.5*Padding[Resolution];
	for (i=6; i<=10; i++)
	{
		if (Top10[i-1] != -1)
		{
			s = i$". "$Master.MapHandler.GetMap(Top10[i-1]);
			C.StrLen(s, xl, yl);
			C.SetPos(x, y);
			C.DrawText(s);
			s = "("$Master.MapHandler.GetMapVoteCount(Top10[i-1])$")";
			C.StrLen(s, xl, yl);
			C.SetPos(x2 - xl, y);
			C.DrawText(s);
			y += yl + 0.5*Padding[Resolution];
			C.DrawColor = C.DrawColor * 0.85;
		}
	}
}

// Control events

simulated function Notify (UWindowDialogControl control, byte event)
{
	local int	i, j;

	// close
	if (control == ButtonClose)
	{
		if (event == DE_Click)
		{
			OwnerInterface.Hide();
		}
		else if (event == DE_MouseMove)
		{
			Hint = TextHintCloseButton;
			AltHint = "";
		}
		else if (event == DE_MouseLeave)
		{
			Hint = TextHintDefault;
			AltHint = TextHintDefaultAlt;
		}
	}
	// vote player
	else if (control == ButtonVote)
	{
		if (event == DE_Click)
		{
			for (i=0; i<BoxPlayers.NumItems; i++)
			{
				if (BoxPlayers.IsSelectedByIndex(i))
					OwnerPlayer.ConsoleCommand("vote "@BoxPlayers.GetData(i));
			}
			ClearUp();
		}
		else if (event == DE_MouseMove)
		{
			Hint = TextHintVoteButton;
			AltHint = "";
		}
		else if (event == DE_MouseLeave)
		{
			Hint = TextHintDefault;
			AltHint = TextHintDefaultAlt;
		}
	}
	// vote map
	else if (control == ButtonVoteLvl)
	{
		if (event == DE_Click)
		{
			i = BoxLevels.GetSelected();
			if (i < BoxLevels.NumItems)
			{
				OwnerPlayer.ConsoleCommand("VoteMap"@BoxLevels.ItemsText[i]);
				Master.MapHandler.MyMapVote=BoxLevels.ItemsText[i];
			}
		}
		else if (event == DE_MouseMove)
		{
			Hint = TextHintVoteLvlButton;
			AltHint = "";
		}
		else if (event == DE_MouseLeave)
		{
			Hint = TextHintDefault;
			AltHint = TextHintDefaultAlt;
		}
	}
	// player list
	else if (control == BoxPlayers)
	{
		if (event == DE_MouseMove)
		{
			Hint = TextHintPlayersBox;
			AltHint = "";
		}
		else if (event == DE_MouseLeave)
		{
			Hint = TextHintDefault;
			AltHint = TextHintDefaultAlt;
		}
	}
	// level list
	else if (control == BoxLevels)
	{
		if (event == DE_MouseMove)
		{
			Hint = TextHintLevelsBox;
			AltHint = "";
		}
		else if (event == DE_MouseLeave)
		{
			Hint = TextHintDefault;
			AltHint = TextHintDefaultAlt;
		}
	}
}

simulated function KeyDown (int Key, float x, float y)
{
	local string	keyname, alias;

	keyname = OwnerPlayer.ConsoleCommand("KEYNAME"@Key);
	alias = OwnerPlayer.ConsoleCommand("KEYBINDING"@keyname);

	if (Caps(alias) ~= "SHOWVOTETAB")
	{
		OwnerInterface.Hide();
	}
}

simulated function Clearup()
{
	local int	i;

	if (!bInitialized)
		return;

	for (i=0; i<BoxPlayers.NumItems; i++)
	{
		BoxPlayers.SetSelectedByIndex(i, False);
	}
	BoxPlayers.SelectedIndex = BoxPlayers.LBIT_NONE;
	BoxPlayers.TopIndex = 0;

	BoxLevels.SetSelectedByIndex(BoxLevels.SelectedIndex, False);
	BoxLevels.SelectedIndex = BoxLevels.LBIT_NONE;
	BoxLevels.TopIndex = 0;
}

simulated function BeforeShow ()
{
	ClearUp();

	ButtonClose.ShowWindow();
	ButtonVote.ShowWindow();
	ButtonVoteLvl.ShowWindow();
	BoxLevels.ShowWindow();
	BoxPlayers.ShowWindow();
}

simulated function BeforeHide ()
{
	ButtonClose.HideWindow();
	ButtonVote.HideWindow();
	ButtonVoteLvl.HideWindow();
	BoxLevels.HideWindow();
	BoxPlayers.HideWindow();
}

// setup control positions
simulated function Setup(Canvas Canvas)
{
	local float				l, w, t, w2, w4, xw, wb3, wb2;
	local int				i, lh;

	for (i=0; i<10; i++)
		Top10[i]=-1;

	OwnerHUD.Design.SetHeadlineFont(Canvas);

	xw = Width*0.5 - 3*Padding[Resolution];
	w = Width*0.25 - Padding[Resolution];
	lh = OwnerHud.Design.LineHeight;
	l = int(Width*0.125);
	w2 = int(w*0.5);
	w4 = int(w*0.4);

	ButtonClose.WinLeft = Left + Width - w;
	ButtonClose.WinTop = Top + Height - Padding[Resolution] - lh - 3;
	ButtonClose.SetWidth(Canvas, w - Padding[Resolution]);

	t = Left + Width - Padding[Resolution] - xw;

	BoxPlayers.WinLeft = t;
	BoxPlayers.WinTop = Top + Padding[Resolution];
	BoxPlayers.NumVisItems = 16;
	BoxPlayers.SetWidth(Canvas, xw);

	wb3 = (xw - 2*Padding[Resolution]) / 3;
	wb2 = (xw - Padding[Resolution]) / 2;

	ButtonVote.WinLeft = t;
	ButtonVote.WinTop = BoxPlayers.WinTop + BoxPlayers.WinHeight + Padding[Resolution];
	ButtonVote.SetWidth(Canvas, xw);

	BoxLevels.WinLeft = Left + Padding[Resolution];
	BoxLevels.WinTop = Top + Padding[Resolution];
	BoxLevels.NumVisItems = 16;
	BoxLevels.SetWidth(Canvas, xw);

  	ButtonVoteLvl.WinLeft = Left + Padding[Resolution];
	ButtonVoteLvl.WinTop = BoxLevels.WinTop + BoxLevels.WinHeight + Padding[Resolution];
	ButtonVoteLvl.SetWidth(Canvas, xw);
}

defaultproperties
{
	TextVoteTitle="Vote screen"

	TextHintDefault="Select your actions"
	TextHintDefaultAlt=""

	TextButtonClose="close"
	TextHintCloseButton="Click to close admin menu"

	TextButtonVote="vote player"
	TextHintVoteButton="Vote selected player(s)"

	TextButtonVoteLvl="vote level"
	TextHintVoteLvlButton="Vote selected level"

	TextBoxLevels="maps"
	TextHintLevelsBox="choose map"
	TextBoxPlayers="players"
	TextHintPlayersBox="choose one or more players"

	ShowNav=true

	TabName="TOST VoteTab"
}
