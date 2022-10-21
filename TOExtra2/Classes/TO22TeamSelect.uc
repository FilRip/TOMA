class TO22TeamSelect extends TO_TeamSelect;

function Notify (UWindowDialogControl C, byte E)
{
	local	bool	bAnimateMenu;

	bAnimateMenu = true;
	super(UWindowDialogClientWindow).Notify(C,E);

	if ( E == DE_Click )
	{
		switch( C )
		{
			case BtnServerTR:	menuTeam = 0;
								if ( GetPlayerOwner().Level.NetMode == NM_StandAlone )
								{ // Against bots, no need to see the TEAM page, since it's empty
									DynamicLoadModelHandler();
									//menuSkin = ModelHandler.static.GetNextModel(MenuSkin, menuTeam);
									MenuSkin = 0;
									SetMeshActor();
									menuItem = MI_SKIN;
								}
								else
									menuItem = MI_TEAM;
								break;

			case BtnServerSF:	menuTeam = 1;
								if ( GetPlayerOwner().Level.NetMode == NM_StandAlone )
								{ // Against bots, no need to see the TEAM page, since it's empty
									MenuSkin = LastUsedSFPrevSkin;
									DynamicLoadModelHandler();
									//menuSkin = ModelHandler.static.GetNextModel(MenuSkin, menuTeam);
									menuSkin = 2;
									SetMeshActor();
									menuItem = MI_SKIN;
								}
								else
									menuItem = MI_TEAM;
								break;

			case BtnRndTeam:
								menuTeam = 254; // Random Team (255 being waiting players)
								menuSkin = 255; // Random Model
								TOTeamsel_Tool_ChangeTeam(menuTeam);
								Close();
								break;

			case BtnTeamJnSF:   // Load last used skin by default instead
								DynamicLoadModelHandler();
								//ModelHandler = class<TO_ModelHandler>(DynamicLoadObject(ModelHandlerClass, class'Class'));
								//menuSkin = ModelHandler.static.GetNextModel(MenuSkin, menuTeam);
								MenuSkin = 2;
								SetMeshActor();
								menuItem = MI_SKIN;
								//TOTeamsel_Tool_ChangeTeam(menuTeam);
								//Close();
								break;

			case BtnTeamJnTR:
								// Load last used skin by default instead
								DynamicLoadModelHandler();
								//ModelHandler = class<TO_ModelHandler>(DynamicLoadObject(ModelHandlerClass, class'Class'));
								//menuSkin = ModelHandler.static.GetNextModel(MenuSkin, menuTeam);
								MenuSkin = 0;
								SetMeshActor();
								menuItem = MI_SKIN;
								//TOTeamsel_Tool_ChangeTeam(menuTeam);
								//Close();
								break;



			case	BtnPrev:
								//ModelHandler = class<TO_ModelHandler>(DynamicLoadObject(ModelHandlerClass, class'Class'));
								DynamicLoadModelHandler();
								menuSkin = ModelHandler.static.GetPrevModel(MenuSkin, menuTeam);
								SetMeshActor();
//								if (menuTeam == 1) LastUsedSFSkin = menuSkin; else LastUsedTRSkin = menuSkin;
								break;

			case	BtnNext:
								DynamicLoadModelHandler();
								//ModelHandler = class<TO_ModelHandler>(DynamicLoadObject(ModelHandlerClass, class'Class'));
								menuSkin = ModelHandler.static.GetNextModel(MenuSkin, menuTeam);
								SetMeshActor();
//								if (menuTeam == 1) LastUsedSFSkin = menuSkin; else LastUsedTRSkin = menuSkin;
								break;

			case BtnEnter:
								TOTeamsel_Tool_ChangeTeam(menuTeam);
								DelMeshActor();
								Close();
								break;

			case BtnExitGame:
								if ( menuItem != MI_CREDITS )
								{
									menuItem = MI_CREDITS;
									Credits = GetPlayerOwner().Spawn(class'TO_Credits',GetPlayerOwner());
									if ( Credits != None )
										Credits.Initialize(xo-40, yo-168, xo+256, yo+192, Font(DynamicLoadObject("LadderFonts.UTLadder10", class'Font')), 15.0);
								}
								else
									bAnimateMenu = false;
								break;

			case BtnServerQt:	Close();
								//GetPlayerOwner().ConsoleCommand("disconnect");
								GetPlayerOwner().ConsoleCommand("exit");
								break;

			case BtnServerDis:	Close();
								GetPlayerOwner().ConsoleCommand("disconnect");
								break;

			case BtnMiscBack:
								menuItem = MI_SERVER;
								if ( menuItem == MI_CREDITS )
								{
									Credits.Destroy();
									Credits = None;
								}
								else if ( menuItem == MI_SKIN )
									DelMeshActor();
								break;
		}

		if ( bAnimateMenu )
		{
			TOTeamsel_Btn_HideAll();
			menuFadingFrame = menuFadingSpeed;
		}
	}
}

defaultproperties
{
}

