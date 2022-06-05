class TOMAStartMatchCW extends TO_StartMatchCW;

function Created ()
{
	local int i;
	local int j;
	local int Selection;
	local int BestCategory;
	local int CategoryCount;
	local int pos;
	local Class<GameInfo> tempClass;
	local string TempGame;
	local string NextGame;
	local string Package;
	local string TempGames[256];
	local string NextEntry;
	local string NextCategory;
	local string Categories[256];
	local bool bFoundSavedGameClass;
	local bool bAlreadyHave;
	local int ControlWidth;
	local int ControlLeft;
	local int ControlRight;
	local int CenterWidth;
	local int CenterPos;

	Super(UWindowWindow).Created();
	DesiredWidth=270;
	DesiredHeight=100;
	ControlWidth=WinWidth/2.5;
	ControlLeft=(WinWidth/2-ControlWidth)/2;
	ControlRight=WinWidth/2+ControlLeft;
	CenterWidth=WinWidth/4*3;
	CenterPos=(WinWidth-CenterWidth)/2;
	BotmatchParent=UMenuBotmatchClientWindow(GetParent(Class'UMenuBotmatchClientWindow'));
	if (BotmatchParent==None)
		Log("Error: UMenuStartMatchClientWindow without UMenuBotmatchClientWindow parent.");
	CategoryCombo=UWindowComboControl(CreateControl(Class'UWindowComboControl',CenterPos,20,CenterWidth,1));
	CategoryCombo.SetButtons(True);
	CategoryCombo.SetText(CategoryText);
	CategoryCombo.SetHelpText(CategoryHelp);
	CategoryCombo.SetFont(0);
	CategoryCombo.SetEditable(False);
	CategoryCombo.AddItem(GeneralText);
	for (i=0;i<256;i++)
	{
		if (Len(Categories[i])>0)
		{
			CategoryCombo.AddItem(Categories[i]);
			CategoryCount++;
			if (Categories[i]~=LastCategory)
				BestCategory=CategoryCount;
		}
	}
	CategoryCombo.SetSelectedIndex(BestCategory);
	GameCombo=UWindowComboControl(CreateControl(Class'UWindowComboControl',CenterPos,45,CenterWidth,1));
	GameCombo.SetButtons(True);
	GameCombo.SetText(GameText);
	GameCombo.SetHelpText(GameHelp);
	GameCombo.SetFont(0);
	GameCombo.SetEditable(False);
	i=0;
	tempClass=Class'TournamentGameInfo';
	GetPlayerOwner().GetNextIntDesc("TournamentGameInfo",0,NextGame,NextCategory);
JL02E8:
	if (NextGame!="")
	{
		pos=InStr(NextGame,".");
		Package=Left(NextGame,pos);
		if (Package=="TOMA2")
			TempGames[i]=NextGame;
		else
			TempGames[i]="";
		i++;
		if (i==256)
			Log("More than 256 gameinfos listed in int files");
		else
		{
			GetPlayerOwner().GetNextIntDesc("TournamentGameInfo",i,NextGame,NextCategory);
			goto JL02E8;
		}
	}
	for (i=0;i<256;i++)
	{
		if (TempGames[i]!="")
		{
			Games[MaxGames]=TempGames[i];
			if ((!bFoundSavedGameClass) && (Games[MaxGames]~=BotmatchParent.GameType))
			{
				bFoundSavedGameClass=True;
				Selection=MaxGames;
			}
			tempClass=Class<GameInfo>(DynamicLoadObject(Games[MaxGames],Class'Class'));
			GameCombo.AddItem(tempClass.Default.GameName);
			MaxGames++;
		}
	}
	GameCombo.SetSelectedIndex(Selection);
	BotmatchParent.GameType=Games[Selection];
	BotmatchParent.GameClass=Class<GameInfo>(DynamicLoadObject(BotmatchParent.GameType,Class'Class'));
	MapCombo=UWindowComboControl(CreateControl(Class'UWindowComboControl',CenterPos,70,CenterWidth,1));
	MapCombo.SetButtons(True);
	MapCombo.SetText(MapText);
	MapCombo.SetHelpText(MapHelp);
	MapCombo.SetFont(0);
	MapCombo.SetEditable(False);
	IterateMaps(BotmatchParent.Map);
	MapListButton=UWindowSmallButton(CreateControl(Class'UWindowSmallButton',CenterPos,95,48,16));
	MapListButton.SetText(MapListText);
	MapListButton.SetFont(0);
	MapListButton.SetHelpText(MapListHelp);
	MutatorButton=UWindowSmallButton(CreateControl(Class'UWindowSmallButton',CenterPos,120,48,16));
	MutatorButton.SetText(MutatorText);
	MutatorButton.SetFont(0);
	MutatorButton.SetHelpText(MutatorHelp);
	ControlWidth=WinWidth/2.5;
	ControlLeft=(WinWidth/2-ControlWidth)/2;
	ControlRight=WinWidth/2+ControlLeft;
	CenterWidth=WinWidth/4*3;
	CenterPos=(WinWidth-CenterWidth)/2;
	ChangeLevelsCheck=UWindowCheckbox(CreateControl(Class'UWindowCheckbox',CenterPos,145,ControlWidth,1));
	ChangeLevelsCheck.SetText(ChangeLevelsText);
	ChangeLevelsCheck.SetHelpText(ChangeLevelsHelp);
	ChangeLevelsCheck.SetFont(0);
	ChangeLevelsCheck.Align=TA_Right;
	SetChangeLevels();
	Initialized=True;
}

function CategoryChanged ()
{
	local string CurCategory;
	local int i;
	local int Selection;
	local int pos;
	local string NextGame;
	local string NextCategory;
	local string Package;
	local string TempGames[256];
	local Class<GameInfo> tempClass;
	local bool bFoundSavedGameClass;

	if (!Initialized)
		return;
	Initialized=False;
	CurCategory=CategoryCombo.GetValue();
	LastCategory=CurCategory;
	GameCombo.Clear();
	for(i=0;i<256;i++)
		Games[i]="";
	i=0;
	tempClass=Class'TournamentGameInfo';
	GetPlayerOwner().GetNextIntDesc("TournamentGameInfo",0,NextGame,NextCategory);
JL00B3:
	if (NextGame!="")
	{
		if ((CurCategory~=GeneralText) && (NextCategory==""))
			TempGames[i]=NextGame;
		else
			if (NextCategory~=CurCategory)
				TempGames[i]=NextGame;
		pos=InStr(NextGame,".");
		Package=Left(NextGame,pos);
		if (Package!="TOMA2")
			TempGames[i]="";
		i++;
		if (i==256)
			Log("More than 256 gameinfos listed in int files");
		else
		{
			GetPlayerOwner().GetNextIntDesc("TournamentGameInfo",i,NextGame,NextCategory);
			goto JL00B3;
		}
	}
	for (i=0;i<256;i++)
	{
		if (TempGames[i]!="")
		{
			Games[MaxGames]=TempGames[i];
			if (!bFoundSavedGameClass && (Games[MaxGames]~=BotmatchParent.GameType))
			{
				bFoundSavedGameClass=True;
				Selection=MaxGames;
			}
			tempClass=Class<GameInfo>(DynamicLoadObject(Games[MaxGames],Class'Class'));
			GameCombo.AddItem(tempClass.Default.GameName);
			MaxGames++;
		}
	}
	GameCombo.SetSelectedIndex(0);
	Initialized=True;
	GameChanged();
	SaveConfig();
}

defaultproperties
{
}
