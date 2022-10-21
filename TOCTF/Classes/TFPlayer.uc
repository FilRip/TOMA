class TFPlayer extends S_Player_T;

var localized string Objective;
var byte CptIAR;
var() config bool bPlayAnnouncer;
var Carcass carc;
var byte DisableWeapon[32];
var() config bool bAutoBuyArmor;

#EXEC OBJ LOAD NAME=TOCTFTex FILE=..\Textures\TOCTFTex.utx

replication
{
	reliable if (Role<ROLE_Authority)
	    ServerSetAutoBuyArmor;
    reliable if (Role==Role_Authority)
        CptIAR,UpdateWeaponsList,DisableWeapon;
}

exec function s_kAutoBuyArmor()
{
    bAutoBuyArmor=!bAutoBuyArmor;
    ServerSetAutoBuyArmor(bAutoBuyArmor);
}

function ServerSetAutoBuyArmor(bool bval)
{
	bAutoBuyArmor=bval;
}

exec function Fire(optional float F)
{
    if (CptIAR>0) bFire=0;
    else super.Fire(F);
}

function TakeDamage(int Damage,Pawn instigatedBy,Vector hitlocation,Vector momentum,name damageType)
{
    if (CptIAR>0) return; else super.TakeDamage(Damage,instigatedBy,hitlocation,momentum,damageType);
}

simulated function CalculateWeight()
{
	Super.CalculateWeight();
/*
    Slow down players who carrying flag  REMOVED

    if (TFPlayerReplicationInfo(PlayerReplicationInfo)!=None)
		if (TFPlayerReplicationInfo(PlayerReplicationInfo).bHasFlag) GroundSpeed-=100;
*/
	GroundSpeed*=1.25;
}

state Dying
{
	ignores SeePlayer, HearNoise, KilledBy, Bump, HitWall, HeadZoneChange, FootZoneChange, ZoneChange, SwitchWeapon, Falling, PainTimer;

	event PlayerTick(float DeltaTime)
	{
		ViewShake(DeltaTime);
		ViewFlash(DeltaTime);
		Super.PlayerTick(DeltaTime);
	}

	function ViewFlash(float DeltaTime)
	{
		Super(PlayerPawn).ViewFlash(DeltaTime);
	}

	function ServerReStartPlayer()
	{
		if (((bFrozen) && (TimerRate>0.0)) || (Level.NetMode==NM_Client))
			return;
		if(Level.Game.RestartPlayer(self))
		{
			ServerTimeStamp=0;
			TimeMargin=0;
			Enemy=None;
			bHidden=false;
			EndState();
//			TFMod(Level.Game).ReStartPlayer(self);
			if (Mesh!=None)
				PlayWaiting();
			ClientReStart();
			Health=Default.Health;
			SetPhysics(PHYS_Walking);
			GotoState('PlayerWalking');
		}
		else
			log("Restartplayer failed");
	}

	function Timer()
	{
		bFrozen=false;
		bPressedJump=false;
		ViewRotation.Roll=0;
		ServerRestartPlayer();
	}

	exec function Fire(optional float F)
	{
	}

	exec function AltFire(optional float F)
	{
	}

	function BeginState()
	{
		if (bSZoom)
			ToggleSZoom();
		ViewRotation.Roll=0;
		Super.BeginState();
		bFrozen=false;
		bAlwaysRelevant=false;
		bNotPlaying=true;
		PlayerReplicationInfo.bIsSpectator=true;
		SetTimer(3,false);
	}

	function EndState()
	{
		Super.EndState();
		bAlwaysRelevant=true;
		bNotPlaying=false;
		PlayerReplicationInfo.bIsSpectator=false;
		bBehindView=false;
		ViewRotation.Roll=0;
	}
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
	if ((Level.Game!=None) && (!Level.Game.IsA('TFMod')))
	{
		StartWalk();
		if (Handedness==1)
			LoadLeftHand();
	}
	else
	{
		if ((Role==Role_Authority) && (Level.NetMode!=NM_Standalone))
			Spawn(Class'TFProtect',self);
	}
	if (Level.NetMode==NM_Client)
	{
		ServerSetTaunt(bAutoTaunt);
		if ((Level.Game!=None) && (!Level.Game.IsA('TFMod')))
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
	if ((Level!=None) && (Level.Game!=None) && !Level.Game.IsA('TFMod'))
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
	PZone=Spawn(Class'TFPZone',self);
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
		if ((Level.Game!=None) && TFMod(Level.Game).bSinglePlayer)
		{
			C.bQuickKeyEnable=True;
			C.LaunchUWindow();
			StartMenu=TFAutoTeamSelect(C.Root.CreateWindow(Class'TFAutoTeamSelect',0,0,C.Root.WinWidth,C.Root.WinHeight));
		}
		else
		{
			C.bQuickKeyEnable=True;
			C.LaunchUWindow();
			StartMenu=TFTeamSelect(C.Root.CreateWindow(Class'TFTeamSelect',0,0,C.Root.WinWidth,C.Root.WinHeight));
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
	UpdateWeaponsList();
	InitNewObjectives();
	if ( Role < Role_Authority )
	{
		ServerSetAutoBuyArmor(bAutoBuyArmor);
	}
}

simulated function UpdateWeaponsList()
{
    local byte i;

    for (i=0;i<32;i++)
        if (DisableWeapon[i]==1)
            class'TO_WeaponsHandler'.default.WeaponTeam[i]=WT_None;
}

function InitNewObjectives()
{
	SI.ScenarioDescription1=Objective;
	SI.ScenarioDescription2="";
	SI.SF_Objective1="";
	SI.SF_Objective2="";
	SI.SF_Objective3="";
	SI.SF_Objective4="";
	SI.Terr_Objective1="";
	SI.Terr_Objective2="";
	SI.Terr_Objective3="";
	SI.Terr_Objective4="";
	SI.ObjShot1=Texture'TOCTFTex.Logo';
	SI.objShot2=None;
	SI.ObjShot3=None;
	SI.ObjShot4=None;
}

simulated function s_ChangeTeam(int num,int team,bool bDie)
{
	local TFMod SG;

	if (Role==Role_Authority)
	{
		SG=TFMod(Level.Game);
		if (SG==None)
		{
			Log("s_Player::s_ChangeTeam - Unable to locate game !!!");
			return;
		}

		SG.TFChangePModel(self, num, team, bDie);
		SG.ForceSkinUpdate(self);

		if (PlayerReplicationInfo.bWaitingPlayer)
			SG.TFPlayerJoined(Self);
	}
}

simulated function bool IsInBuyZone()
{
	return true;
}

/*function bool IsMyFlagFree()
{
    local TFGameReplicationInfo TFGRI;

    TFGRI=TFGameReplicationInfo(GameReplicationInfo);
    if (TFGRI!=None)
        return TFGRI.TheFlags[PlayerReplicationInfo.Team].IsFree;
}*/

function PreCacheReferences ()
{
	Spawn(Class's_Player_T');
	Spawn(Class's_BotMCounterTerrorist1');
	Spawn(Class's_Knife');
	Spawn(Class's_Glock');
	Spawn(Class's_DEagle');
	Spawn(Class'TO_Berreta');
	Spawn(Class's_MAC10');
	Spawn(Class's_MP5N');
	Spawn(Class'TO_MP5KPDW');
	Spawn(Class's_Mossberg');
	Spawn(Class's_M3');
	Spawn(Class'TO_Saiga');
	Spawn(Class's_Ak47');
	Spawn(Class'TO_HK33');
	Spawn(Class's_PSG1');
	Spawn(Class'TO_SteyrAug');
	Spawn(Class's_p85');
	Spawn(Class's_OICW');
	Spawn(Class'TO_M4m203');
	Spawn(Class'TO_Grenade');
	Spawn(Class'TFFlags');
	Spawn(Class'TerroFlag');
	Spawn(Class'SFFlag');
	Spawn(Class'TFPlayer');
	Spawn(Class'TFBot');
}

function ToggleAutoAnnouncer()
{
    bPlayAnnouncer=!bPlayAnnouncer;
}

function Carcass SpawnCarcass()
{
//	local	Carcass	carc;

	//log("s_Player::SpawnCarcass - s:"@GetStateName());
	carc = Super.SpawnCarcass();
/*	if (TMMod(Level.Game).bExplodeCarcass)
    {
        carc.ChunkUp(100);
    }         */
	HidePlayer();

	return carc;
}

function Die()
{
	bHasNV = false;
}

function Escape()
{
}

defaultproperties
{
    bAutoBuyArmor=True
    PlayerReplicationInfoClass=Class'TFPlayerReplicationInfo'
    JumpZ=385
    HUDType=class'TOCTF.TFHUD'
    Objective="Defend your flag against the other team and get the flag of the opposide team"
    bPlayAnnouncer=true
}
