// $Id: TOSTGUIAdminTab.uc 487 2004-03-07 14:29:51Z dildog $
//----------------------------------------------------------------------------
// Project : TOST
// File    : TOSTGUIAdminTab.uc
// Version : 4.0
// Author  : BugBunny/MadOnion
//----------------------------------------------------------------------------

class TOSTGUIAdminTab extends TOSTGUIBaseTab;

var localized string		TextAdminTitle;

var localized string		TextAdminWarning;

var localized string		TextHintDefault, TextHintDefaultAlt;

var localized string		TextButtonClose, TextHintCloseButton;
var localized string		TextbuttonGameTab, TextHintGameTabButton;
var localized string		TextButtonKick, TextHintKickButton;
var localized string		TextButtonBan, TextHintBanButton;
var localized string		TextButtonChgTeams, TextHintChgTeamsButton;
var localized string		TextButtonMkTeams, TextHintMkTeamsButton;
var localized string		TextButtonMute, TextHintMuteButton;
var localized string		TextButtonWarn, TextHintWarnButton;
var localized string		TextButtonSwitchLvl, TextHintSwitchLvlButton;
var localized string		TextButtonSkipLvl, TextHintSkipLvlButton;
var localized string		TextButtonSetNextLvl, TextHintSetNextLvlButton;
var localized string		TextBoxLevels, TextHintLevelsBox;
var localized string		TextBoxPlayers, TextHintPlayersBox;
var localized string		TextButtonAdminReset, TextHintAdminResetButton;
var localized string		TextButtonEndRound, TextHintEndRoundButton;

var TOSTGUIBaseButton		ButtonClose, ButtonGameTab;
var TOSTGUIBaseButton		ButtonSwitchLvl, ButtonSkipLvl, ButtonSetNextLvl;
var TOSTGUIBaseButton		ButtonKick, ButtonBan, ButtonMute, ButtonWarn, ButtonChgTeams, ButtonMkTeams;
var TOSTGUITextListbox		BoxLevels, BoxPlayers;
var TOSTGUIBaseButton		ButtonAdminReset, ButtonEndRound;
var TOSTGUIEditControl		EditReason;

var float					AdminWarning, AdminWarnStep;

var int						LastMapCount;

simulated function Created ()
{
	Super.Created();

	Title = TextAdminTitle;

	ButtonClose = TOSTGUIBaseButton(CreateWindow(class'TOSTGUIBaseButton', 0, 0, WinWidth, WinHeight));
	ButtonClose.Text = TextButtonClose;
	ButtonClose.OwnerTab = self;

	ButtonGameTab = TOSTGUIBaseButton(CreateWindow(class'TOSTGUIBaseButton', 0, 0, WinWidth, WinHeight));
	ButtonGameTab.Text = TextButtonGameTab;
	ButtonGameTab.OwnerTab = self;

	// player buttons
	ButtonKick = TOSTGUIBaseButton(CreateWindow(class'TOSTGUIBaseButton', 0, 0, WinWidth, WinHeight));
	ButtonKick.Text = TextButtonKick;
	ButtonKick.OwnerTab = self;

	ButtonBan = TOSTGUIBaseButton(CreateWindow(class'TOSTGUIBaseButton', 0, 0, WinWidth, WinHeight));
	ButtonBan.Text = TextButtonBan;
	ButtonBan.OwnerTab = self;

	ButtonChgTeams = TOSTGUIBaseButton(CreateWindow(class'TOSTGUIBaseButton', 0, 0, WinWidth, WinHeight));
	ButtonChgTeams.Text = TextButtonChgTeams;
	ButtonChgTeams.OwnerTab = self;

	ButtonMkTeams = TOSTGUIBaseButton(CreateWindow(class'TOSTGUIBaseButton', 0, 0, WinWidth, WinHeight));
	ButtonMkTeams.Text = TextButtonMkTeams;
	ButtonMkTeams.OwnerTab = self;

	ButtonMute = TOSTGUIBaseButton(CreateWindow(class'TOSTGUIBaseButton', 0, 0, WinWidth, WinHeight));
	ButtonMute.Text = TextButtonMute;
	ButtonMute.OwnerTab = self;

	ButtonWarn = TOSTGUIBaseButton(CreateWindow(class'TOSTGUIBaseButton', 0, 0, WinWidth, WinHeight));
	ButtonWarn.Text = TextButtonWarn;
	ButtonWarn.OwnerTab = self;

	// level buttons
	ButtonSwitchLvl = TOSTGUIBaseButton(CreateWindow(class'TOSTGUIBaseButton', 0, 0, WinWidth, WinHeight));
	ButtonSwitchLvl.Text = TextButtonSwitchLvl;
	ButtonSwitchLvl.OwnerTab = self;

	ButtonSkipLvl = TOSTGUIBaseButton(CreateWindow(class'TOSTGUIBaseButton', 0, 0, WinWidth, WinHeight));
	ButtonSkipLvl.Text = TextButtonSkipLvl;
	ButtonSkipLvl.OwnerTab = self;

	ButtonSetNextLvl = TOSTGUIBaseButton(CreateWindow(class'TOSTGUIBaseButton', 0, 0, WinWidth, WinHeight));
	ButtonSetNextLvl.Text = TextButtonSetNextLvl;
	ButtonSetNextLvl.OwnerTab = self;

	// list boxes
	BoxLevels = TOSTGUITextListbox(CreateWindow(class'TOSTGUITextListbox', 0, 0, WinWidth, WinHeight));
	BoxLevels.Label = TextBoxLevels;
	BoxLevels.OwnerTab = self;

	BoxPlayers = TOSTGUITextListbox(CreateWindow(class'TOSTGUITextListbox', 0, 0, WinWidth, WinHeight));
	BoxPlayers.Label = TextBoxPlayers;
	BoxPlayers.OwnerTab = self;
	BoxPlayers.bMultiSelect = true;

	// Current game buttons
	ButtonAdminReset = TOSTGUIBaseButton(CreateWindow(class'TOSTGUIBaseButton', 0, 0, WinWidth, WinHeight));
	ButtonAdminReset.Text = TextButtonAdminReset;
	ButtonAdminReset.OwnerTab = self;

	ButtonEndRound = TOSTGUIBaseButton(CreateWindow(class'TOSTGUIBaseButton', 0, 0, WinWidth, WinHeight));
	ButtonEndRound.Text = TextButtonEndRound;
	ButtonEndRound.OwnerTab = self;

	// reason field
	EditReason = TOSTGUIEditControl(CreateControl(Class'TOSTGUIEditControl', 0, 0, WinWidth, WinHeight));
	EditReason.Label = "Reason";
	EditReason.OwnerTab = self;
	EditReason.SetValue("");
	EditReason.SetNumericOnly(False);
	EditReason.SetMaxLength(25);
	EditReason.SetDelayedNotify(True);

	AdminWarning = 0.3;
	AdminWarnStep = 1;
}

simulated function Close (optional bool bByParent)
{
	ButtonClose.Close();
	ButtonGameTab.Close();
	ButtonKick.Close();
	ButtonBan.Close();
	ButtonMkTeams.Close();
	ButtonChgTeams.Close();
	ButtonMute.Close();
	ButtonWarn.Close();
	ButtonSwitchLvl.Close();
	ButtonSkipLvl.Close();
	ButtonSetNextLvl.Close();
	ButtonAdminReset.Close();
	ButtonEndRound.Close();
	BoxLevels.Close();
	BoxPlayers.Close();
	EditReason.close();

	Super.Close(bByParent);
}

simulated function Tick (float delta)
{
	if (!OwnerPlayer.PlayerReplicationInfo.bAdmin)
	{
		if ((AdminWarning + (AdminWarnStep*delta) > 0.7) || (AdminWarning + (AdminWarnStep*delta) < 0.3))
			AdminWarnStep = -AdminWarnStep;
		AdminWarning += AdminWarnStep*delta;
		if (AdminWarning > 0.7)
			AdminWarning = 0.7;
		if (AdminWarning < 0.3)
			AdminWarning = 0.3;
	}
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
	local int			Selected[32];
	local PlayerReplicationInfo 	a;
	local int		i, j, k, l, Count, position;

	position = BoxPlayers.TopIndex;
	Count = 0;

	for(l=0; l<32; l++) {
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
	local int	i;

	// check for updates
	if (LastMapCount == Master.MapHandler.MapCount)
		return;

	// simply add new maps
	for (i=LastMapCount; i<Master.MapHandler.MapCount; i++)
		BoxLevels.AddItem(Master.MapHandler.GetMap(i), "", i, False);

	LastMapCount = Master.MapHandler.MapCount;
}

// paint
simulated function Paint (Canvas Canvas, float x, float y)
{
	Super.Paint(Canvas, x, y);

	// no admin warning
	if (bDraw)
		if (!OwnerPlayer.PlayerReplicationInfo.bAdmin && Master.SemiAdmin == 0)
			PaintAdminWarning(Canvas);
}

// Paint Helper

simulated function PaintAdminWarning (Canvas Canvas)
{
	local float	x1, y1;

	Canvas.Style = OwnerHUD.ERenderStyle.STY_NORMAL;
	OwnerInterface.Design.SetScoreboardFont(Canvas);

	Canvas.DrawColor.R = OwnerInterface.Design.ColorRed.R * AdminWarning;
	Canvas.DrawColor.G = OwnerInterface.Design.ColorRed.G * AdminWarning;
	Canvas.DrawColor.B = OwnerInterface.Design.ColorRed.B * AdminWarning;

	Canvas.StrLen(TextAdminWarning, x1, y1);
	Canvas.SetPos(Left + Padding[Resolution] + int((ButtonClose.WinLeft - Left - Padding[Resolution] - x1) / 2), ButtonClose.WinTop + ButtonClose.ButtonSpacing);
	Canvas.DrawText(TextAdminWarning, true);
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
			ClearUp();
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
	// switch to gametab
	if (control == ButtonGameTab)
	{
		if (event == DE_Click)
		{
			OwnerPlayer.ConsoleCommand("ShowGameTab");
			ClearUp();
		}
		else if (event == DE_MouseMove)
		{
			Hint = TextHintGameTabButton;
			AltHint = "";
		}
		else if (event == DE_MouseLeave)
		{
			Hint = TextHintDefault;
			AltHint = TextHintDefaultAlt;
		}
	}
	// mkteams / mkclanteams
	else if (control == ButtonMkTeams)
	{
		if (event == DE_Click)
		{
			OwnerPlayer.ConsoleCommand("mkteams");
			ClearUp();
		}
		else if  (event == DE_RClick)
		{
			OwnerPlayer.ConsoleCommand("mkclanteams");
			ClearUp();
		}
		else if (event == DE_MouseMove)
		{
			Hint = TextHintMkTeamsButton;
			AltHint = "";
		}
		else if (event == DE_MouseLeave)
		{
			Hint = TextHintDefault;
			AltHint = TextHintDefaultAlt;
		}
	}
	// chgteams
	else if (control == ButtonChgTeams)
	{
		if (event == DE_Click)
		{
			for (i=0; i<BoxPlayers.NumItems; i++)
			{
				if (BoxPlayers.IsSelectedByIndex(i))
					OwnerPlayer.ConsoleCommand("fteamchg "@BoxPlayers.GetData(i));
			}
			ClearUp();
		}
		else if (event == DE_RClick)
		{
			for (i=0; i<BoxPlayers.NumItems; i++)
			{
				if (BoxPlayers.IsSelectedByIndex(i))
					OwnerPlayer.ConsoleCommand("fteamchg "@BoxPlayers.GetData(i)@" true");
			}
			ClearUp();
		}
		else if (event == DE_MouseMove)
		{
			Hint = TextHintChgTeamsButton;
			AltHint = "";
		}
		else if (event == DE_MouseLeave)
		{
			Hint = TextHintDefault;
			AltHint = TextHintDefaultAlt;
		}
	}
	// kick + remove stats on RC
	else if (control == ButtonKick)
	{
		if (event == DE_Click)
		{
			for (i=0; i<BoxPlayers.NumItems; i++)
			{
				if (BoxPlayers.IsSelectedByIndex(i))
					OwnerPlayer.ConsoleCommand("SAPKick"@BoxPlayers.GetData(i)@EditReason.getValue());
			}
			ClearUp();
    	    EditReason.SetValue("");
		}
		else if (event == DE_RClick)
		{
			for (i=0; i<BoxPlayers.NumItems; i++)
			{
				if (BoxPlayers.IsSelectedByIndex(i))
					OwnerPlayer.ConsoleCommand("SAPXKick"@BoxPlayers.GetData(i)@EditReason.getValue());
			}
			ClearUp();
    	    EditReason.SetValue("");
		}
		else if (event == DE_MouseMove)
		{
			Hint = TextHintKickButton;
			AltHint = "";
		}
		else if (event == DE_MouseLeave)
		{
			Hint = TextHintDefault;
			AltHint = TextHintDefaultAlt;
		}
	}
	// Ban (only Temp on RC)
	else if (control == ButtonBan)
	{
		if (event == DE_Click)
		{
			for (i=0; i<BoxPlayers.NumItems; i++)
			{
				if (BoxPlayers.IsSelectedByIndex(i))
					OwnerPlayer.ConsoleCommand("SAPKickBan "@BoxPlayers.GetData(i)@EditReason.getValue());
			}
			ClearUp();
	        EditReason.SetValue("");
		}
		else if (event == DE_RClick)
		{
			for (i=0; i<BoxPlayers.NumItems; i++)
			{
				if (BoxPlayers.IsSelectedByIndex(i))
					OwnerPlayer.ConsoleCommand("SAPTempKickBan "@BoxPlayers.GetData(i)@EditReason.getValue());
			}
			ClearUp();
	        EditReason.SetValue("");
		}
		else if (event == DE_MouseMove)
		{
			Hint = TextHintBanButton;
			AltHint = "";
		}
		else if (event == DE_MouseLeave)
		{
			Hint = TextHintDefault;
			AltHint = TextHintDefaultAlt;
		}
	}
	// Mute / Unmute
	if (control == ButtonMute)
	{
		if (event == DE_Click)
		{
			for (i=0; i<BoxPlayers.NumItems; i++)
			{
				if (BoxPlayers.IsSelectedByIndex(i))
					OwnerPlayer.ConsoleCommand("SAPMute "@BoxPlayers.GetData(i)@"-1"@EditReason.getValue());
			}
			ClearUp();
	        EditReason.SetValue("");
		}
		else if (event == DE_RClick)
		{
			for (i=0; i<BoxPlayers.NumItems; i++)
			{
				if (BoxPlayers.IsSelectedByIndex(i))
					OwnerPlayer.ConsoleCommand("SAPMute "@BoxPlayers.GetData(i)@EditReason.getValue());
			}
			ClearUp();
	        EditReason.SetValue("");
		}
		else if (event == DE_MouseMove)
		{
			Hint = TextHintMuteButton;
			AltHint = "";
		}
		else if (event == DE_MouseLeave)
		{
			Hint = TextHintDefault;
			AltHint = TextHintDefaultAlt;
		}
	}
	// Warn
	else if (control == ButtonWarn)
	{
		if ((event == DE_Click) || (event == DE_RClick))
		{
			for (i=0; i<BoxPlayers.NumItems; i++)
			{
				if (BoxPlayers.IsSelectedByIndex(i))
					OwnerPlayer.ConsoleCommand("SAPWarn "@BoxPlayers.GetData(i)@EditReason.getValue());
			}
			ClearUp();
	        EditReason.SetValue("");
		}
		else if (event == DE_MouseMove)
		{
			Hint = TextHintWarnButton;
			AltHint = "";
		}
		else if (event == DE_MouseLeave)
		{
			Hint = TextHintDefault;
			AltHint = TextHintDefaultAlt;
		}
	}
	// AdminReset
	else if (control == ButtonAdminReset)
	{
		if (event == DE_Click)
		{
			OwnerPlayer.ConsoleCommand("SAAdminReset");
			ClearUp();
		}
		else if (event == DE_RClick)
		{
			//OwnerPlayer.ConsoleCommand("");
		}
		else if (event == DE_MouseMove)
		{
			Hint = TextHintAdminResetButton;
			AltHint = "";
		}
		else if (event == DE_MouseLeave)
		{
			Hint = TextHintDefault;
			AltHint = TextHintDefaultAlt;
		}
	}
	// EndRound
	else if (control == ButtonEndround)
	{
		if (event == DE_Click)
		{
			OwnerPlayer.ConsoleCommand("SAEndRound");
			ClearUp();
		}
		else if (event == DE_RClick)
		{
			//OwnerPlayer.ConsoleCommand("");
		}
		else if (event == DE_MouseMove)
		{
			Hint = TextHintEndRoundButton;
			AltHint = "";
		}
		else if (event == DE_MouseLeave)
		{
			Hint = TextHintDefault;
			AltHint = TextHintDefaultAlt;
		}
	}
	// switch to map
	else if (control == ButtonSwitchLvl)
	{
		if (event == DE_Click)
		{
			i = BoxLevels.GetData(BoxLevels.GetSelected());
			if (i < BoxLevels.NumItems)
			{
				 OwnerPlayer.ConsoleCommand("SAMapChg"@BoxLevels.ItemsText[i]);
				 OwnerInterface.Hide();
			}
			ClearUp();
		}
		else if (event == DE_MouseMove)
		{
			Hint = TextHintSwitchLvlButton;
			AltHint = "";
		}
		else if (event == DE_MouseLeave)
		{
			Hint = TextHintDefault;
			AltHint = TextHintDefaultAlt;
		}
	}
	// skip map
	else if (control == ButtonSkipLvl)
	{
		if (event == DE_Click)
		{
			OwnerPlayer.ConsoleCommand("SkipMap");
			OwnerInterface.Hide();
			ClearUp();
		}
		else if (event == DE_MouseMove)
		{
			Hint = TextHintSkipLvlButton;
			AltHint = "";
		}
		else if (event == DE_MouseLeave)
		{
			Hint = TextHintDefault;
			AltHint = TextHintDefaultAlt;
		}
	}
	// set next map
	else if (control == ButtonSetNextLvl)
	{
		if (event == DE_Click)
		{
			i = BoxLevels.GetData(BoxLevels.GetSelected());
			if (i < BoxLevels.NumItems)
				OwnerPlayer.ConsoleCommand("SASetNextMap"@BoxLevels.ItemsText[i]);
			ClearUp();
		}
		else if (event == DE_MouseMove)
		{
			Hint = TextHintSetNextLvlButton;
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

	if (!EditReason.EditBox.bHasKeyboardFocus && Caps(alias) ~= "SHOWADMINTAB")
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
	ButtonGameTab.ShowWindow();
	ButtonKick.ShowWindow();
	ButtonBan.ShowWindow();
	ButtonMkTeams.ShowWindow();
	ButtonChgTeams.ShowWindow();
	ButtonMute.ShowWindow();
	ButtonWarn.ShowWindow();
	ButtonSwitchLvl.ShowWindow();
	ButtonSkipLvl.ShowWindow();
	ButtonSetNextLvl.ShowWindow();
	ButtonAdminReset.ShowWindow();
	ButtonEndRound.ShowWindow();
	BoxLevels.ShowWindow();
	BoxPlayers.ShowWindow();
	EditReason.ShowWindow();
	EditReason.SetValue("");
}

simulated function BeforeHide ()
{
	ButtonClose.HideWindow();
	ButtonGameTab.HideWindow();
	ButtonKick.HideWindow();
	ButtonBan.HideWindow();
	ButtonMkTeams.HideWindow();
	ButtonChgTeams.HideWindow();
	ButtonMute.HideWindow();
	ButtonWarn.HideWindow();
	ButtonSwitchLvl.HideWindow();
	ButtonSkipLvl.HideWindow();
	ButtonSetNextLvl.HideWindow();
	ButtonAdminReset.HideWindow();
	ButtonEndRound.HideWindow();
	BoxLevels.HideWindow();
	BoxPlayers.HideWindow();
	EditReason.HideWindow();
}

// setup control positions
simulated function Setup(Canvas Canvas)
{
	local float				l, w, t, w2, w4, xw, wb3, wb2;
	local int				i, lh;

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

	ButtonGameTab.WinLeft = Left + Width - w;
	ButtonGameTab.WinTop = ButtonClose.WinTop - Padding[Resolution] - lh - 3;
	ButtonGameTab.SetWidth(Canvas, w - Padding[Resolution]);

	t = Left + Width - Padding[Resolution] - xw;

	BoxPlayers.WinLeft = t;
	BoxPlayers.WinTop = Top + Padding[Resolution];
	BoxPlayers.NumVisItems = 12;
	BoxPlayers.SetWidth(Canvas, xw);

	wb3 = (xw - 2*Padding[Resolution]) / 3;
	wb2 = (xw - Padding[Resolution]) / 2;

	ButtonKick.WinLeft = t;
	ButtonKick.WinTop = BoxPlayers.WinTop + BoxPlayers.WinHeight + Padding[Resolution];
	ButtonKick.SetWidth(Canvas, wb2);

	ButtonBan.WinLeft = t + wb2 + Padding[Resolution];
	ButtonBan.WinTop = BoxPlayers.WinTop + BoxPlayers.WinHeight + Padding[Resolution];
	ButtonBan.SetWidth(Canvas, wb2);

	ButtonMkTeams.WinLeft = t;
	ButtonMkTeams.WinTop = BoxPlayers.WinTop + BoxPlayers.WinHeight + ButtonKick.WinHeight + 2*Padding[Resolution];
	ButtonMkTeams.SetWidth(Canvas, wb2);

	ButtonChgTeams.WinLeft = t + wb2 + Padding[Resolution];
	ButtonChgTeams.WinTop = BoxPlayers.WinTop + BoxPlayers.WinHeight + ButtonKick.WinHeight + 2*Padding[Resolution];
	ButtonChgTeams.SetWidth(Canvas, wb2);

	ButtonMute.WinLeft = t;
	ButtonMute.WinTop = BoxPlayers.WinTop + BoxPlayers.WinHeight + ButtonMkTeams.WinHeight +ButtonKick.WinHeight + 3*Padding[Resolution];
	ButtonMute.SetWidth(Canvas, wb2);

	ButtonWarn.WinLeft = t + wb2 + Padding[Resolution];
	ButtonWarn.WinTop = BoxPlayers.WinTop + BoxPlayers.WinHeight + ButtonChgTeams.WinHeight + ButtonKick.WinHeight + 3*Padding[Resolution];
	ButtonWarn.SetWidth(Canvas, wb2);

	BoxLevels.WinLeft = Left + Padding[Resolution];
	BoxLevels.WinTop = Top + Padding[Resolution];
	BoxLevels.NumVisItems = 12;
	BoxLevels.SetWidth(Canvas, xw);

  	ButtonSetNextLvl.WinLeft = Left + Padding[Resolution];
	ButtonSetNextLvl.WinTop = BoxLevels.WinTop + BoxLevels.WinHeight + Padding[Resolution];
	ButtonSetNextLvl.SetWidth(Canvas, xw);

	ButtonSkipLvl.WinLeft = Left + Padding[Resolution];
	ButtonSkipLvl.WinTop = BoxLevels.WinTop + BoxLevels.WinHeight + ButtonSetNextLvl.WinHeight + 2*Padding[Resolution];
	ButtonSkipLvl.SetWidth(Canvas, xw);

	ButtonSwitchLvl.WinLeft = Left + Padding[Resolution];
	ButtonSwitchLvl.WinTop = BoxLevels.WinTop + BoxLevels.WinHeight + ButtonSkipLvl.WinHeight + ButtonSetNextLvl.WinHeight + 3*Padding[Resolution];
	ButtonSwitchLvl.SetWidth(Canvas, xw);

	ButtonAdminReset.WinLeft = Left + Padding[Resolution];
	ButtonAdminReset.WinTop = BoxLevels.WinTop + BoxLevels.WinHeight + ButtonSwitchLvl.WinHeight + 2 *ButtonSkipLvl.WinHeight + 6*Padding[Resolution];
	ButtonAdminReset.SetWidth(Canvas, xw);

	ButtonEndRound.WinLeft = Left + Padding[Resolution];
	ButtonEndRound.WinTop = BoxLevels.WinTop + BoxLevels.WinHeight + 2*ButtonSwitchLvl.WinHeight + 2*ButtonSkipLvl.WinHeight + 7*Padding[Resolution];
	ButtonEndRound.SetWidth(Canvas, xw);

	EditReason.WinLeft=t;
	EditReason.WinTop=BoxLevels.WinTop + BoxLevels.WinHeight + ButtonSwitchLvl.WinHeight + 2*ButtonSkipLvl.WinHeight + 6*Padding[Resolution];
	EditReason.setWidth(Canvas, xw);

}

defaultproperties
{
	TextAdminTitle="Admin Tab"

	TextHintDefault="Select your actions"
	TextHintDefaultAlt="You need admin privileges to perform any of these actions"

	TextButtonClose="close"
	TextHintCloseButton="Click to close admin menu"
	TextButtonGameTab="gametab"
	TextHintGameTabButton="Click to switch to the game tab"

	TextButtonKick="kick"
	TextHintKickButton="Kick selected players (on right click also erase player backup)"
	TextButtonBan="ban"
	TextHintBanButton="Ban selected players (on right click only from this map)"
	TextButtonChgTeams="change team"
	TextHintChgTeamsButton="Force selected players to change team (on right click also remove weapons)"
	TextButtonMkTeams="make teams"
	TextHintMkTeamsButton="Automatically euqualize teams (on right click also remove weapons)"
    TextButtonMute="mute"
    TextHintMuteButton="Mute selected players (on right click Unmute players)"
    TextButtonWarn="warn"
    TextHintWarnButton="Warn selected players"

	TextButtonSwitchLvl="switch"
	TextHintSwitchLvlButton="Switch to selected map"
	TextButtonSkipLvl="skip"
	TextHintSkipLvlButton="Skips current map"
	TextButtonSetNextLvl="set next"
	TextHintSetNextLvlButton="Sets next map"

	TextButtonAdminReset="adminreset"
	TextHintAdminResetButton="Reset map"
  	TextButtonEndRound="endround"
	TextHintEndRoundButton="End the round"

	TextBoxLevels="maps"
	TextHintLevelsBox="choose map"
	TextBoxPlayers="players"
	TextHintPlayersBox="choose one or more players"

	TextAdminWarning="You are currently not logged in as admin!"

	ShowNav=true

	TabName="TOST AdminTab"
}
