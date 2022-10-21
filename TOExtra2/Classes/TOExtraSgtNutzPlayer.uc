class TOExtraSgtNutzPlayer extends s_player_t;

simulated function AddNewModel()
{
    local int i;

    Class'TO_ModelHandler'.Default.Skin0[0]="TOExtraModels.Skins.VisageBleu";
    Class'TO_ModelHandler'.Default.Skin1[0]="TOExtraModels.Skins.TenuVert";
    Class'TO_ModelHandler'.Default.ModelMesh[0]=LODMesh'TOExtraModels.Squirrel';
    Class'TO_ModelHandler'.Default.ModelName[0]="Sergent Nutz - Terrorist One";
    Class'TO_ModelHandler'.Default.ModelType[0]=MT_Terrorist;

    Class'TO_ModelHandler'.Default.Skin0[1]="TOExtraModels.Skins.VisageBleu";
    Class'TO_ModelHandler'.Default.Skin1[1]="TOExtraModels.Skins.TenuJaune";
    Class'TO_ModelHandler'.Default.ModelMesh[1]=LODMesh'TOExtraModels.Squirrel';
    Class'TO_ModelHandler'.Default.ModelName[1]="Sergent Nutz - Terrorist Two";
    Class'TO_ModelHandler'.Default.ModelType[1]=MT_Terrorist;

    Class'TO_ModelHandler'.Default.Skin0[2]="TOExtraModels.Skins.VisageMarron";
    Class'TO_ModelHandler'.Default.Skin1[2]="TOExtraModels.Skins.TenuNoir";
    Class'TO_ModelHandler'.Default.ModelMesh[2]=LODMesh'TOExtraModels.Squirrel';
    Class'TO_ModelHandler'.Default.ModelName[2]="Sergent Nutz - Special Force One";
    Class'TO_ModelHandler'.Default.ModelType[2]=MT_SpecialForces;

    Class'TO_ModelHandler'.Default.Skin0[3]="TOExtraModels.Skins.VisageMarron";
    Class'TO_ModelHandler'.Default.Skin1[3]="TOExtraModels.Skins.TenuBleu";
    Class'TO_ModelHandler'.Default.ModelMesh[3]=LODMesh'TOExtraModels.Squirrel';
    Class'TO_ModelHandler'.Default.ModelName[3]="Sergent Nutz - Special Force Two";
    Class'TO_ModelHandler'.Default.ModelType[3]=MT_SpecialForces;

    Class'TO_ModelHandler'.Default.Skin0[4]="TOExtraModels.Skins.VisageBleu";
    Class'TO_ModelHandler'.Default.Skin1[4]="TOExtraModels.Skins.TenuOtage";
    Class'TO_ModelHandler'.Default.ModelMesh[4]=LODMesh'TOExtraModels.Squirrel';
    Class'TO_ModelHandler'.Default.ModelName[4]="Sergent Nutz - Hostage";
    Class'TO_ModelHandler'.Default.ModelType[4]=MT_Hostage;

    for (i=5;i<19;i++)
        class'TO_ModelHandler'.Default.ModelType[i]=MT_None;
}

simulated event Possess()
{
	local s_SWATLevelInfo SWLI;
	local TO_ScenarioInfoInternal SIint;
	local TournamentConsole C;
	local UWindowRootWindow Root;
	local string Message;
	local TO_ScenarioInfo localSI;
	local s_SWATLevelInfo localSWLI;

    AddNewModel();

// Possess S_Player_t
	UpdateURL("Class","s_SWAT.s_Player_T",True);
	UpdateURL("Skin","None",True);
	UpdateURL("Face","None",True);
	UpdateURL("Team","255",True);
	UpdateURL("Voice","None",True);
	if ((PlayerReplicationInfo != None) && (PlayerReplicationInfo.PlayerName~="Player"))
	{
		ChangeName(Class'TO_GameOptionsCW'.Default.DefaultPlayerName);
		UpdateURL("Name",Class'TO_GameOptionsCW'.Default.DefaultPlayerName,True);
	}

// Possess to_sysplayer

	if (Level.NetMode==NM_Client)
	{
		ServerNeverSwitchOnPickup(bNeverAutoSwitch);
		ServerSetHandedness(Handedness);
		UpdateWeaponPriorities();
	}
	ServerUpdateWeapons();
	bIsPlayer=True;
	DodgeClickTime=FMin(0.30,DodgeClickTime);
	EyeHeight=BaseEyeHeight;
	NetPriority=3;
	if ((Level.Game!=None) && (!Level.Game.IsA('s_SWATGame')))
	{
		StartWalk();
		if (Handedness==1)
			LoadLeftHand();
	}
	else
	{
		if ((Role==Role_Authority) && (Level.NetMode!=NM_Standalone))
			Spawn(Class'TO_Protect',self);
	}
	if (Level.NetMode==NM_Client)
	{
		ServerSetTaunt(bAutoTaunt);
		if ((Level.Game!=None) && (!Level.Game.IsA('s_SWATGame')))
			ServerSetInstantRocket(bInstantRocket);
	}

// Possess s_bplayer
	if ( Role < Role_Authority )
	{
		ServerSetHideDeathMsg(bHideDeathMsg);
		ServerSetAutoReload(bAutomaticReload);
	}
	Bob=OriginalBob;

// Possess S_Player_t
	FixMapProblems();
	if ((Level!=None) && (Level.Game!=None) && !Level.Game.IsA('s_SWATGame'))
		return;
	if (Level.NetMode!=NM_DedicatedServer)
	{
		Message="s_Player::Possess - " $ Class'TO_MenuBar'.Default.TOVersionText;
		Log(Message);
		if ((Player!=None) && (Player.Console!=None))
		{
			SetupRainGen();
			if (Level.bHighDetailMode)
				toggleraingen();
		}
	}
	if (PZone!=None)
		PZone.Destroy();
	PZone=Spawn(Class'TOExtraSgtNutzPZone',self);
	if (PZone!=None)
		PZone.Initialize();
	if (SI==None)
	{
		foreach AllActors(Class'TO_ScenarioInfo',SI)
			if (SI!=None) localSI=SI;
		if (localSI!=None) SI=localSI;
	}
	if (Role<Role_Authority)
	{
		if (SI==None)
		{
			foreach AllActors(Class's_SWATLevelInfo',SWLI)
				if (SWLI!=None) localSWLI=SWLI;
			if (LocalSWLI!=None) SWLI=localSWLI;
			if (SWLI!=None)
			{
				SIint=Spawn(Class'TO_ScenarioInfoInternal',self,,Location);
				if (SIint!=None)
				{
					SIint.ConvertActor(SWLI);
					SI=SIint;
				}
				else
					Log("s_Player - PostBeginPlay - ConvertSWLI - SI == None");
			}
			else
				Log("s_Player - PostBeginPlay - SWLI == None");
		}
	}
	if ((Player!=None) && (Player.Console==None) && (Role==Role_Authority))
		return;
	if ((myHUD!=None) && (s_HUD(myHUD)!=None) && (s_HUD(myHUD).UserInterface!=None))
	{
		s_HUD(myHUD).UserInterface.Destroy();
		s_HUD(myHUD).UserInterface=None;
	}
	bGUIActive=True;
	if (StartMenu!=None)
	{
		StartMenu.Close();
		StartMenu=None;
	}
	if ((Player!=None) && (Player.Console!=None))
		C=TournamentConsole(Player.Console);
	if (C.bShowSpeech)
		C.HideSpeech();
	if (C.Root==None)
	{
		Log("s_Player::Possess - C.Root == None - creating Root");
		C.CreateRootWindow(None);
	}
	else
	{
		if ((Level.Game!=None) && s_SWATGame(Level.Game).bSinglePlayer)
		{
			C.bQuickKeyEnable=True;
			C.LaunchUWindow();
			StartMenu=TOSgtNutzTeamSelectAuto(C.Root.CreateWindow(Class'TOSgtNutzTeamSelectAuto',0,0,C.Root.WinWidth,C.Root.WinHeight));
		}
		else
		{
			C.bQuickKeyEnable=True;
			C.LaunchUWindow();
			StartMenu=TOSgtNutzTeamSelect(C.Root.CreateWindow(Class'TOSgtNutzTeamSelect',0,0,C.Root.WinWidth,C.Root.WinHeight));
		}
	}
	if ((Player!=None) && (Player.Console!=None) && (TO_Console(Player.Console)!=None) && ((TO_Console(Player.Console).SpeechWindow==None) || !TO_Console(Player.Console).SpeechWindow.IsA('s_SWATWindow')))
	{
		Root=WindowConsole(Player.Console).Root;
		TO_Console(Player.Console).SpeechWindow=SpeechWindow(Root.CreateWindow(Class's_SWATWindow',100,100,200,200));
		if (TO_Console(Player.Console).SpeechWindow==None)
		{
			Log("s_Player::Possess - Speechwindow == None");
			return;
		}
		TO_Console(Player.Console).SpeechWindow.bLeaveOnscreen=True;
		if (TO_Console(Player.Console).bShowSpeech)
		{
			Root.SetMousePos(0,132/768*Root.WinWidth);
			TO_Console(Player.Console).SpeechWindow.SlideInWindow();
		}
		else
			TO_Console(Player.Console).SpeechWindow.HideWindow();
	}
	else
		Log("s_Player::Possess - cannot replace speechwindow");
	if (StartMenu==None)
		Log("s_Player::Possess - StartMenu == None");
	GotoState('PlayerWaiting');
}

defaultproperties
{
    CollisionRadius=44
    CollisionHeight=42
    CrouchHeight=35
    DrawScale=1.250000
}

