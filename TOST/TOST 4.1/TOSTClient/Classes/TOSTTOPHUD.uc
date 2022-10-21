//----------------------------------------------------------------------------
// Project : TOST
// File    : TOSTTOPHUD.uc
// Version : 1.0
// Author  : BugBunny
//----------------------------------------------------------------------------
// Version	Changes
// 0.5		+ first release
// 0.6		+ first beta release
// 1.0		+ first public release
//----------------------------------------------------------------------------

class TOSTTOPHUD expands TOSTHUDMutator;

var	TO_GUITabScores		MyTab;
var TO_GUIBaseMgr		MyUI;

var Texture				Indicator;
var bool				BlinkFlag;

var PlayerReplicationInfo		PlayerList[32];
var byte						PlayerCount;

simulated function	Init()
{
	super.Init();

	SetTimer(0.75, true);
	Indicator = Texture(DynamicLoadObject("Botpack.CHair8", class'Texture', true));
	MyUI = s_HUD(MyHUD).UserInterface;
}

simulated function	PostRender(Canvas C)
{
	if (MyUI != None && MyUI.CurrentTab==10)
		DrawTOPStats(C);

	super.PostRender(C);
}

simulated function	Timer()
{
	BlinkFlag = !BlinkFlag;
}

simulated function	DrawTOPStats(Canvas C)
{
	local	int 	i, ypos;

	MyTab = TO_GUITabScores(MyUI.GetCurrentTab());
	if (MyTab == none)
		return;
	UpdatePlayerList(int(MyTab.SortMode));

	C.bNoSmooth = False;
	C.Style = MyUI.ERenderStyle.STY_Translucent;

	MyUI.Design.SetScoreboardFont(C);
	ypos = MyTab.Top + MyTab.SpaceTitle[MyTab.Resolution] + MyUI.Design.LineHeight - 8;
	for (i=0; i<PlayerCount; i++)
	{
		ypos += MyUI.Design.LineHeight;
		if ((PlayerList[i].bIsABot) || (TO_PRI(PlayerList[i]) == none))
			continue;

		C.SetPos(MyTab.Left - 80 - 12, YPos - 80);
		switch ( PlayerList[i].OldName ) {
			case "0" :	C.DrawColor = MyUI.Design.ColorYellow; break;
			case "1" :	if (BlinkFlag)
							C.DrawColor = MyUI.Design.ColorYellow;
						else
							C.DrawColor = MyUI.Design.ColorGreen;
						break;
			case "2" :	C.DrawColor = MyUI.Design.ColorGreen; break;
			case "3" :	if (BlinkFlag)
							C.DrawColor = MyUI.Design.ColorRed;
						else
							C.DrawColor = MyUI.Design.ColorGreen;
						break;
			case "4" :	if (BlinkFlag)
							C.DrawColor = MyUI.Design.ColorRed;
						else
							C.DrawColor = MyUI.Design.ColorYellow;
						break;
			case "5" :	C.DrawColor = MyUI.Design.ColorRed; break;
		}
		C.DrawIcon(Indicator, 2.5);
	}

	C.Style = MyUI.ERenderStyle.STY_Normal;
	C.bNoSmooth = True;
}

simulated function UpdatePlayerlist(int SortMode)
{
	local int						i, j, Max;
	local int						Team;
	local PlayerReplicationInfo		PRI;


	// init list
	PlayerCount = 0;
	for (i=0; i<32; i++)
		PlayerList[i] = None;

	// fill list
	for (i=0; i<32; i++)
	{
		if (MyPlayer.GameReplicationInfo.PRIArray[i] != None)
		{
			PRI = MyPlayer.GameReplicationInfo.PRIArray[i];
			Team = PRI.Team;
			if ( Team<2 || Team==255)
			{
				PlayerList[PlayerCount++] = PRI;
			}
		}
	}

	// sort list
	for (i=0; i<PlayerCount; i++)
	{
		Max = i;
		for (j=i+1; j<PlayerCount; J++ )
			if (ComparePlayer(j, Max, SortMode))
				Max = j;

		PRI = PlayerList[Max];
		PlayerList[Max] = PlayerList[i];
		PlayerList[i] = PRI;
	}
}

simulated function bool ComparePlayer (int p1, int p2, int SortMode)
{
	switch (SortMode)
	{
		case 0:	// sort by score+/kills+/deaths-/time-
				if (PlayerList[p1].Score > PlayerList[p2].Score) return true;
				else if (PlayerList[p1].Score < PlayerList[p2].Score) return false;

				if (PlayerList[p1].Deaths < PlayerList[p2].Deaths) return true;
				else if (PlayerList[p1].Deaths > PlayerList[p2].Deaths) return false;

				if (PlayerList[p1].StartTime > PlayerList[p2].StartTime) return true;
				else if (PlayerList[p1].StartTime < PlayerList[p2].StartTime) return false;

				break;


		case 1:	// sort by team-/score+/kills+/death-/time-
				if (PlayerList[p1].Team < PlayerList[p2].Team) return true;
				else if (PlayerList[p1].Team > PlayerList[p2].Team) return false;

				if (PlayerList[p1].Score > PlayerList[p2].Score) return true;
				else if (PlayerList[p1].Score < PlayerList[p2].Score) return false;

				if (PlayerList[p1].Deaths < PlayerList[p2].Deaths) return true;
				else if (PlayerList[p1].Deaths > PlayerList[p2].Deaths) return false;

				if (PlayerList[p1].StartTime < PlayerList[p2].StartTime) return true;
				else if (PlayerList[p1].StartTime > PlayerList[p2].StartTime) return false;

				break;

		case 2:	// sort by kills+/deaths-/score+/time-
				if (PlayerList[p1].Score > PlayerList[p2].Score) return true;
				else if (PlayerList[p1].Score < PlayerList[p2].Score) return false;

				if (PlayerList[p1].Deaths < PlayerList[p2].Deaths) return true;
				else if (PlayerList[p1].Deaths > PlayerList[p2].Deaths) return false;

				if (PlayerList[p1].StartTime > PlayerList[p2].StartTime) return true;
				else if (PlayerList[p1].StartTime < PlayerList[p2].StartTime) return false;

				break;

		case 3: // sort by ping-/score+/kills+/deaths-/time-
				if (PlayerList[p1].Ping < PlayerList[p2].Ping) return true;
				else if (PlayerList[p1].Ping > PlayerList[p2].Ping) return false;

				if (PlayerList[p1].Score > PlayerList[p2].Score) return true;
				else if (PlayerList[p1].Score < PlayerList[p2].Score) return false;

				if (PlayerList[p1].Deaths < PlayerList[p2].Deaths) return true;
				else if (PlayerList[p1].Deaths > PlayerList[p2].Deaths) return false;

				if (PlayerList[p1].StartTime > PlayerList[p2].StartTime) return true;
				else if (PlayerList[p1].StartTime < PlayerList[p2].StartTime) return false;

				break;

		case 4:	// sort by time+/score+/kills+/death-
				if (PlayerList[p1].StartTime > PlayerList[p2].StartTime) return true;
				else if (PlayerList[p1].StartTime < PlayerList[p2].StartTime) return false;

				if (PlayerList[p1].Score > PlayerList[p2].Score) return true;
				else if (PlayerList[p1].Score < PlayerList[p2].Score) return false;

				if (PlayerList[p1].Deaths < PlayerList[p2].Deaths) return true;
				else if (PlayerList[p1].Deaths > PlayerList[p2].Deaths) return false;

				break;
	}
	return true;
}


