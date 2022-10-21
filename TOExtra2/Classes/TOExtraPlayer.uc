class TOExtraPlayer extends s_player_t;

simulated function AddNewModel()
{
    local int i;

    Class'TO_ModelHandler'.Default.Skin0[2]="TOPModels220.SFMediumArmyTex2";
    Class'TO_ModelHandler'.Default.Skin0[3]="TOPModels220.SFMediumDesertTex2";
    Class'TO_ModelHandler'.Default.Skin0[4]="TOPModels220.SWAT_Face";
    Class'TO_ModelHandler'.Default.Skin0[9]="TOPModels220.YakuzaTorse";
    Class'TO_ModelHandler'.Default.Skin1[0]="TOPModels220.CJunk_Face";
    Class'TO_ModelHandler'.Default.Skin1[1]="TOPModels220.HSuitHead";
    Class'TO_ModelHandler'.Default.Skin1[2]="TOPModels220.SFMediumArmyTex1";
    Class'TO_ModelHandler'.Default.Skin1[3]="TOPModels220.SFMediumDesertTex1";
    Class'TO_ModelHandler'.Default.Skin1[4]="TOPModels220.SFMedSWATTex1";
    Class'TO_ModelHandler'.Default.Skin1[5]="TOPModels220.SWAT_Face";
    Class'TO_ModelHandler'.Default.Skin1[6]="TOPModels220.CC_Face";
    Class'TO_ModelHandler'.Default.Skin1[7]="TOPModels220.CCSM_Face";
    Class'TO_ModelHandler'.Default.Skin1[8]="TOPModels220.Scarface_Face";
    Class'TO_ModelHandler'.Default.Skin1[9]="TOPModels220.YakuzaArms";
    Class'TO_ModelHandler'.Default.Skin2[0]="TOPModels220.SFMediumSnowTex1";
    Class'TO_ModelHandler'.Default.Skin2[1]="TOPModels220.HSuitTorse";
    Class'TO_ModelHandler'.Default.Skin2[2]="TOPModels220.SFMediumArmyTex3";
    Class'TO_ModelHandler'.Default.Skin2[3]="TOPModels220.SFMediumDesertTex3";
    Class'TO_ModelHandler'.Default.Skin2[4]="TOPModels220.SFMedSWATTex3";
    Class'TO_ModelHandler'.Default.Skin2[5]="TOPModels220.SFMedSWATBTex1";
    Class'TO_ModelHandler'.Default.Skin2[6]="TOPModels220.CCSM_Hands";
    Class'TO_ModelHandler'.Default.Skin2[7]="TOPModels220.CCSM_Hands";
    Class'TO_ModelHandler'.Default.Skin2[8]="TOPModels220.Scarface_Hands";
    Class'TO_ModelHandler'.Default.Skin2[9]="TOPModels220.YakuzaHead";
    Class'TO_ModelHandler'.Default.Skin3[0]="TOPModels220.SFMediumSnowTex3";
    Class'TO_ModelHandler'.Default.Skin3[1]="TOPModels220.HSuitLegs";
    Class'TO_ModelHandler'.Default.Skin3[2]="TOPModels220.SFMediumArmyTex0";
    Class'TO_ModelHandler'.Default.Skin3[3]="TOPModels220.SFMediumDesertTex0";
    Class'TO_ModelHandler'.Default.Skin3[4]="TOPModels220.SFMedSWATTex0";
    Class'TO_ModelHandler'.Default.Skin3[5]="TOPModels220.SFMedSWATBTex3";
    Class'TO_ModelHandler'.Default.Skin3[6]="TOPModels220.CCSM_Legs";
    Class'TO_ModelHandler'.Default.Skin3[7]="TOPModels220.CCSM_Legs";
    Class'TO_ModelHandler'.Default.Skin3[8]="TOPModels220.Scarface_Legs";
    Class'TO_ModelHandler'.Default.Skin3[9]="TOPModels220.YakuzaLegs";
    Class'TO_ModelHandler'.Default.Skin4[0]="TOPModels220.SFMediumSnowTex0";
    Class'TO_ModelHandler'.Default.Skin4[2]="TOPModels220.SFMediumArmyTex4";
    Class'TO_ModelHandler'.Default.Skin4[3]="TOPModels220.SFMediumDesertTex4";
    Class'TO_ModelHandler'.Default.Skin4[4]="TOPModels220.SFMedSWATTex4";
    Class'TO_ModelHandler'.Default.Skin4[5]="TOPModels220.SFMedSWATTex0";
    Class'TO_ModelHandler'.Default.Skin4[6]="TOPModels220.CCSM_Torse";
    Class'TO_ModelHandler'.Default.Skin4[7]="TOPModels220.CCSM_Torse";
    Class'TO_ModelHandler'.Default.Skin4[8]="TOPModels220.Scarface_Torse";
    Class'TO_ModelHandler'.Default.Skin5[2]="TOPModels220.SFMediumArmyTex4";
    Class'TO_ModelHandler'.Default.Skin5[3]="TOPModels220.SFMediumDesertTex4";
    Class'TO_ModelHandler'.Default.Skin5[4]="TOPModels220.SFMedSWATTex4";
    Class'TO_ModelHandler'.Default.ModelMesh[0]=SkeletalMesh'TOPModels220.TerrorMesh';
    Class'TO_ModelHandler'.Default.ModelMesh[1]=SkeletalMesh'TOPModels220.HostageMesh';
    Class'TO_ModelHandler'.Default.ModelMesh[2]=SkeletalMesh'TOPModels220.SFMediumMesh';
    Class'TO_ModelHandler'.Default.ModelMesh[3]=SkeletalMesh'TOPModels220.SFMediumMesh';
    Class'TO_ModelHandler'.Default.ModelMesh[4]=SkeletalMesh'TOPModels220.SFMediumMesh';
    Class'TO_ModelHandler'.Default.ModelMesh[5]=SkeletalMesh'TOPModels220.TerrorMesh';
    Class'TO_ModelHandler'.Default.ModelMesh[6]=SkeletalMesh'TOPModels220.TerrorMesh';
    Class'TO_ModelHandler'.Default.ModelMesh[7]=SkeletalMesh'TOPModels220.TerrorMesh';
    Class'TO_ModelHandler'.Default.ModelMesh[8]=SkeletalMesh'TOPModels220.TerrorMesh';
    Class'TO_ModelHandler'.Default.ModelMesh[9]=SkeletalMesh'TOPModels220.YakuzaMesh';
    Class'TO_ModelHandler'.Default.ModelName[0]="Alpine Squad";
    Class'TO_ModelHandler'.Default.ModelName[1]="Hostage SuitBoy";
    Class'TO_ModelHandler'.Default.ModelName[2]="U.S. Army";
    Class'TO_ModelHandler'.Default.ModelName[3]="Desert Trooper";
    Class'TO_ModelHandler'.Default.ModelName[4]="Black S.W.A.T.";
    Class'TO_ModelHandler'.Default.ModelName[5]="Blue S.W.A.T.";
    Class'TO_ModelHandler'.Default.ModelName[6]="Camo Johnson";
    Class'TO_ModelHandler'.Default.ModelName[7]="Camo Ski Mask";
    Class'TO_ModelHandler'.Default.ModelName[8]="Scarface";
    Class'TO_ModelHandler'.Default.ModelName[9]="Yakuza";
    Class'TO_ModelHandler'.Default.ModelType[0]=MT_Terrorist;
    Class'TO_ModelHandler'.Default.ModelType[1]=MT_Hostage;
    Class'TO_ModelHandler'.Default.ModelType[2]=MT_SpecialForces;
    Class'TO_ModelHandler'.Default.ModelType[3]=MT_SpecialForces;
    Class'TO_ModelHandler'.Default.ModelType[4]=MT_SpecialForces;
    Class'TO_ModelHandler'.Default.ModelType[5]=MT_SpecialForces;
    Class'TO_ModelHandler'.Default.ModelType[6]=MT_Terrorist;
    Class'TO_ModelHandler'.Default.ModelType[7]=MT_Terrorist;
    Class'TO_ModelHandler'.Default.ModelType[8]=MT_Terrorist;
    Class'TO_ModelHandler'.Default.ModelType[9]=MT_Terrorist;
    for (i=10;i<19;i++)
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
	PZone=Spawn(Class'TOExtraPZone',self);
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
			StartMenu=TO22TeamSelectAuto(C.Root.CreateWindow(Class'TO22TeamSelectAuto',0,0,C.Root.WinWidth,C.Root.WinHeight));
		}
		else
		{
			C.bQuickKeyEnable=True;
			C.LaunchUWindow();
			StartMenu=TO22TeamSelect(C.Root.CreateWindow(Class'TO22TeamSelect',0,0,C.Root.WinWidth,C.Root.WinHeight));
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

function PlayInAir()
{
	local vector X,Y,Z, Dir;
	local float f, TweenTime;

	BaseEyeHeight =  0.7 * Default.BaseEyeHeight;

	if ( (GetAnimGroup(AnimSequence) == 'Landing') && !bLastJumpAlt )
	{
		GetAxes(Rotation, X,Y,Z);
		Dir = Normal(Acceleration);
		f = Dir dot Y;
		if ( f > 0.7 )
		{
			if ( (Weapon==None) || (Weapon.Mass<20) )
				TweenAnim('DodgeL', 0.35);
			else
				TweenAnim('DodgeL', 0.35);
		}
		else if ( f < -0.7 )
		{
			if ( (Weapon==None) || (Weapon.Mass<20) )
				TweenAnim('DodgeR', 0.35);
			else
				TweenAnim('DodgeR', 0.35);
		}
		else if ( Dir dot X > 0 )
		{
			if ( (Weapon==None) || (Weapon.Mass<20) )
				TweenAnim('DodgeF', 0.35);
			else
				TweenAnim('DodgeF', 0.35);
		}
		else
		{
			if ( (Weapon==None) || (Weapon.Mass<20) )
				TweenAnim('DodgeB', 0.35);
			else
				TweenAnim('DodgeB', 0.35);
		}
		bLastJumpAlt = true;
		return;
	}
	bLastJumpAlt = false;
	if ( GetAnimGroup(AnimSequence) == 'Jumping' )
	{
		if ( (Weapon == None) || (Weapon.Mass < 20) )
			TweenAnim('DuckWlkS', 2);
		else
			TweenAnim('DuckWlkL', 2);
		return;
	}
	else if ( GetAnimGroup(AnimSequence) == 'Ducking' )
		TweenTime = 2;
	else
		TweenTime = 0.7;

	if ( AnimSequence == 'StrafeL' )
	{
		if ( (Weapon==None) || (Weapon.Mass<20) )
			TweenAnim('DodgeR', TweenTime);
		else
			TweenAnim('DodgeR', TweenTime);
	}
	else if ( AnimSequence == 'StrafeR' )
	{
		if ( (Weapon==None) || (Weapon.Mass<20) )
			TweenAnim('DodgeL', TweenTime);
		else
			TweenAnim('DodgeL', TweenTime);
	}
	else if ( (AnimSequence == 'BackRun') || (AnimSequence == 'BackRunS') || (AnimSequence == 'BackRunKG')
		|| (AnimSequence == 'BackWalk') )
	{
		if ( (Weapon==None) || (Weapon.Mass<20) )
			TweenAnim('DodgeB', TweenTime);
		else
			TweenAnim('DodgeB', TweenTime);
	}
	else if ( (Weapon == None) || (Weapon.Mass < 20) )
		TweenAnim('JumpSMFR', TweenTime);
	else
		TweenAnim('JumpLGFR', TweenTime);
}

function PlayRunning()
{
	local vector X,Y,Z, Dir;

	BaseEyeHeight = Default.BaseEyeHeight;

	// determine facing direction
	GetAxes(Rotation, X,Y,Z);
	Dir = Normal(Acceleration);
	if ( (Dir Dot X < 0.75) && (Dir != vect(0,0,0)) )
	{
		// strafing or backing up
		if ( (Weapon==None) || (Weapon.Mass < 11) )
		{
			if ( Dir Dot X < -0.75 )
				LoopAnim('BackRun');
			else if ( Dir Dot Y > 0 )
				LoopAnim('StrafeR');
			else
				LoopAnim('StrafeL');
		}
		else if (Weapon.Mass < 20)
		{
			if ( Dir Dot X < -0.75 )
				LoopAnim('BackRunS');
			else if ( Dir Dot Y > 0 )
				LoopAnim('StrafeSmR');
			else
				LoopAnim('StrafeSmL');
		}
		else
		{
			if ( Dir Dot X < -0.75 )
				LoopAnim('BackRun');
			else if ( Dir Dot Y > 0 )
				LoopAnim('StrafeR');
			else
				LoopAnim('StrafeL');
		}
	}
	else if ( Weapon == None )
		LoopAnim('Run');
	else if ( Weapon.bPointing )
	{
		if (Weapon.Mass < 11)
			LoopAnim('RunKG');
		else if (Weapon.Mass < 20)
			LoopAnim('RunSMFR');
		else
			LoopAnim('RunLGFR');
	}
	else
	{
		if ( Weapon.Mass < 11 )
			LoopAnim('RunKG');
		else if (Weapon.Mass < 20)
			LoopAnim('RunSM');
		else
			LoopAnim('RunLG');
	}
}

function TweenToRunning(float tweentime)
{
	local vector X,Y,Z, Dir;

	if ( mesh == None )
		return;

	BaseEyeHeight = Default.BaseEyeHeight;
	if ( bIsWalking )
	{
		TweenToWalking(0.1);
		return;
	}

	GetAxes(Rotation, X,Y,Z);
	Dir = Normal(Acceleration);
	if ( (Dir Dot X < 0.75) && (Dir != vect(0,0,0)) )
	{
		// strafing or backing up
		if ( (Weapon==None) || (Weapon.Mass < 11) )
		{
			if ( Dir dot X < -0.75 )
				PlayAnim('BackRun', 0.9, tweentime);
			else if ( Dir Dot Y > 0 )
				PlayAnim('StrafeR', 0.9, tweentime);
			else
				PlayAnim('StrafeL', 0.9, tweentime);
		}
		else if ( Weapon.Mass < 20 )
		{
			if ( Dir Dot X < -0.75 )
				PlayAnim('BackRunS', 0.9, tweentime);
			else if ( Dir Dot Y > 0 )
				PlayAnim('StrafeSmR', 0.9, tweentime);
			else
				PlayAnim('StrafeSmL', 0.9, tweentime);
		}
		else
		{
			if ( Dir Dot X < -0.75 )
				PlayAnim('BackRun', 0.9, tweentime);
			else if ( Dir Dot Y > 0 )
				PlayAnim('StrafeR', 0.9, tweentime);
			else
				PlayAnim('StrafeL', 0.9, tweentime);
		}
	}
	else if ( Weapon == None )
		PlayAnim('RunSm', 0.9, tweentime);
	else if ( Weapon.bPointing )
	{
		if ( Weapon.Mass < 11 )
			PlayAnim('RunKG', 0.9, tweentime);
		else if (Weapon.Mass < 20)
			PlayAnim('RunSMFR', 0.9, tweentime);
		else
			PlayAnim('RunLGFR', 0.9, tweentime);
	}
	else
	{
		if ( Weapon.Mass < 11 )
			PlayAnim('RunKG', 0.9, tweentime);
		else if (Weapon.Mass < 20)
			PlayAnim('RunSM', 0.9, tweentime);
		else
			PlayAnim('RunLG', 0.9, tweentime);
	}
}

function PlayGutHit(float tweentime)
{
	if ( (AnimSequence == 'GutHit') || (AnimSequence == 'Dead2') )
	{
		if (FRand() < 0.5)
		{
			if ( (Weapon==None) || (Weapon.Mass<20) )
				TweenAnim('LeftHit', tweentime);
			else
				TweenAnim('LeftHit', tweentime);
		}
		else
		{
			if ( (Weapon==None) || (Weapon.Mass<20) )
				TweenAnim('RightHit', tweentime);
			else
				TweenAnim('RightHit', tweentime);
		}
	}
	else if ( FRand() < 0.6 )
		TweenAnim('GutHit', tweentime);
	else
		TweenAnim('Dead8', tweentime);

}

function PlayDuck()
{
	local vector Dir;

	Dir = Normal(Acceleration);
	BaseEyeHeight = 0;

	if ( Dir == vect(0,0,0) )
	{
			if ( Weapon.Mass < 11 )
				TweenAnim('DuckIdleKG', 0.25);
			else if ( Weapon.Mass < 20 )
				TweenAnim('DuckIdleS', 0.25);
			else
				TweenAnim('DuckIdleL', 0.25);
	}
	else
	{
			if ( (Weapon != None) && (Weapon.Mass < 11) )
				TweenAnim('DuckWalkKG', 0.25);
			else if ( (Weapon == None) || (Weapon.Mass < 20) )
				TweenAnim('DuckWlkS', 0.25);
			else
				TweenAnim('DuckWlkL', 0.25);
	}
}

function PlayCrawling()
{
	local vector Dir;

	Dir = Normal(Acceleration);
	BaseEyeHeight = 0;

	if ( Dir == vect(0,0,0) )
	{
		if ( (Weapon!=None) && (Weapon.bPointing) )
		{
			if ( Weapon.Mass < 6 )
				LoopAnim('DuckSlashKG');
			else if ( Weapon.Mass < 11 )
				LoopAnim('DuckThrowKG');
			else if ( Weapon.Mass < 20 )
				LoopAnim('DuckFireS');
			else
				LoopAnim('DuckFireL');
		}
		else
		{
			if ( Weapon.Mass < 6 )
				LoopAnim('DuckIdleKG');
			else if ( Weapon.Mass < 20 )
				LoopAnim('DuckIdleS');
			else
				LoopAnim('DuckIdleL');
		}
	}
	else
	{
		if ( (Weapon!=None) && (Weapon.bPointing) )
		{
			if ( Weapon.Mass < 6 )
				LoopAnim('DuckWalkKGSlash');
			else if ( Weapon.Mass < 11 )
				LoopAnim('DuckWalkKGThrow');
			else if ( Weapon.Mass < 20 )
				LoopAnim('DuckWlkSFr');
			else
				LoopAnim('DuckWlkLFr');
		}
		else
		{
			if ( (Weapon != None) && (Weapon.Mass < 11) )
				LoopAnim('DuckWalkKG');
			else if ( (Weapon == None) || (Weapon.Mass < 20) )
				LoopAnim('DuckWlkS');
			else
				LoopAnim('DuckWlkL');
		}
	}
}

defaultproperties
{
}

