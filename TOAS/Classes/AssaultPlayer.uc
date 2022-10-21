class AssaultPlayer extends S_Player_t;

replication
{
	reliable if( !bNotPlaying && Role < ROLE_Authority)
		BuyWeapon;
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

	UpdateURL("Class","TOAS.AssaultPlayer",True);
	UpdateURL("Skin","None",True);
	UpdateURL("Face","None",True);
	UpdateURL("Team","255",True);
	UpdateURL("Voice","None",True);

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
	if ((Level.Game!=None) && (!Level.Game.IsA('AssaultMod')))
	{
		StartWalk();
		if (Handedness==1)
			LoadLeftHand();
	}
	else
	{
		if ((Role==Role_Authority) && (Level.NetMode!=NM_Standalone))
			Spawn(Class'AssaultProtect',self);
	}
	if (Level.NetMode==NM_Client)
	{
		ServerSetTaunt(bAutoTaunt);
		if ((Level.Game!=None) && (!Level.Game.IsA('AssaultMod')))
			ServerSetInstantRocket(bInstantRocket);
	}

	if ( Role < Role_Authority )
	{
		ServerSetHideDeathMsg(bHideDeathMsg);
		ServerSetAutoReload(bAutomaticReload);
	}
	Bob=OriginalBob;

	FixMapProblems();
	if ((Level!=None) && (Level.Game!=None) && (!Level.Game.IsA('AssaultMod')))
		return;
	if (Level.NetMode!=NM_DedicatedServer)
	{
		Message="AssaultPlayer::Possess - " $ Class'TO_MenuBar'.Default.TOVersionText;
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
	PZone=Spawn(Class'AssaultPZone',self);
	if (PZone!=None)
		PZone.Initialize();
	if (SI==None)
	{
		foreach AllActors(Class'TO_ScenarioInfo',SI)
			localSI=SI;
		SI=localSI;
	}
	if (Role<Role_Authority)
	{
		if (SI==None)
		{
			foreach AllActors(Class's_SWATLevelInfo',SWLI)
				localSWLI=SWLI;
			SWLI=localSWLI;
			if (SWLI!=None)
			{
				SIint=Spawn(Class'TO_ScenarioInfoInternal',self,,Location);
				if (SIint!=None)
				{
					SIint.ConvertActor(SWLI);
					SI=SIint;
				}
				else
					Log("AssaultPlayer - PostBeginPlay - ConvertSWLI - SI == None");
			}
			else
				Log("AssaultPlayer - PostBeginPlay - SWLI == None");
		}
	}
	if ((Player!=None) && (Player.Console==None) && (Role==Role_Authority))
		return;
	if ((myHUD!=None) && (s_HUD(myHUD)!=None) && (s_HUD(myHUD).UserInterface!=None))
	{
		Log("Destroy HUD");
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
		Log("AssaultPlayer::Possess - C.Root == None - creating Root");
		C.CreateRootWindow(None);
	}
	else
	{
		if ((Level.Game!=None) && AssaultMod(Level.Game).bSinglePlayer)
		{
			C.bQuickKeyEnable=True;
			C.LaunchUWindow();
			StartMenu=AssaultAutoTeamSelect(C.Root.CreateWindow(Class'AssaultAutoTeamSelect',0,0,C.Root.WinWidth,C.Root.WinHeight));
		}
		else
		{
			C.bQuickKeyEnable=True;
			C.LaunchUWindow();
			StartMenu=AssaultTeamSelect(C.Root.CreateWindow(Class'AssaultTeamSelect',0,0,C.Root.WinWidth,C.Root.WinHeight));
		}
	}
	if ((Player!=None) && (Player.Console!=None) && (TO_Console(Player.Console)!=None) && ((TO_Console(Player.Console).SpeechWindow==None) || !TO_Console(Player.Console).SpeechWindow.IsA('AssaultSWATWindow')))
	{
		Root=WindowConsole(Player.Console).Root;
		TO_Console(Player.Console).SpeechWindow=SpeechWindow(Root.CreateWindow(Class'AssaultSWATWindow',100,100,200,200));
		if (TO_Console(Player.Console).SpeechWindow==None)
		{
			Log("AssaultPlayer::Possess - Speechwindow == None");
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
		Log("AssaultPlayer::Possess - cannot replace speechwindow");
	if (StartMenu==None)
		Log("AssaultPlayer::Possess - StartMenu == None");
	GotoState('PlayerWaiting');
}

exec function ThrowWeapon()
{
	return;
}

simulated event Destroyed ()
{
	local TO_ScenarioInfoInternal SIint;

	Log("s_Player::Destroyed");
	if ((SI!=None) && (SI.IsA('TO_ScenarioInfoInternal')))
		SI.Destroy();
/*	if ((Role==Role_Authority) && (Level!=None) && (Level.Game!=None) && (AssaultMod(Level.Game)!=None))
		AssaultMod(Level.Game).DropInventory(self,False);*/
	if ((Player!=None) && (Player.Console!=None) && (TO_Console(Player.Console)!=None) && TO_Console(Player.Console).bShowSpeech)
		TO_Console(Player.Console).HideSpeech();
	if (StartMenu!=None)
	{
		StartMenu.Close();
		StartMenu=None;
	}
	if ((s_HUD(myHUD)!=None) && (s_HUD(myHUD).UserInterface!=None))
	{
		s_HUD(myHUD).UserInterface.Destroy();
		s_HUD(myHUD).UserInterface=None;
	}
	if (TOPRI!=None)
		TOPRI.Destroy();
	if (PZone!=None)
		PZone.Destroy();
	if (RG!=None)
		toggleraingen();
	Super(S_BPlayer).Destroyed();
}

final function bool OkForBuy()
{
	local AssaultGameReplicationInfo GRI;

	GRI=AssaultGameReplicationInfo(GameReplicationInfo);
	if ((GRI.RoundStarted - GRI.RemainingTime>GRI.LimitBuyTime) && (GRI.LimitBuyTime>0))
		return false;
	else
		return true;
}

exec function s_kammoAuto(int QuikBuyNum)
{
	local	int	WeaponNum;

	if (!OkForBuy()) return; else Super.s_kammoauto(QuikBuyNum);

	if ( !IsInBuyZone() )
		return;

	WeaponNum = QuikBuyNum - 101;

	if ( (QuikBuyNum > 100) && (QuikBuyNum < 200)
		&& (WeaponNum <= class'TOModels.TO_WeaponsHandler'.default.NumWeapons)
		&& ( (class'TOModels.TO_WeaponsHandler'.static.IsTeamMatch( Self, WeaponNum ))
		|| ShouldWeaponBeShown(class'TOModels.TO_WeaponsHandler'.default.WeaponStr[WeaponNum]) ) )
  	{
    	BuyWeapon(WeaponNum);
  	}
	else super.s_kAmmoAuto(QuikBuyNum);
}

function BuyWeapon(int weaponnum, optional bool nocheck)
{
	local	AssaultMod SG;
	local	s_Weapon	w;

	SG = AssaultMod(Level.Game);
	if ( SG == None )
		return;

	//log("s_Player::BuyWeapon - Buying weapon:"@class'TOModels.TO_WeaponsHandler'.default.WeaponStr[weaponnum]);
	W = SG.AssaultBuyWeapon(self, weaponnum, nocheck);
    if (W != none)
	{
		// make sure there is no alt ammo
		SetAmmo(0, 0, W, true);

		//give primary ammo ... unloaded
		if (!W.IsA('s_Knife') && !W.IsA('TO_Grenade') && W.bUseClip)
			SetAmmo(1, 0, W, false, true);
		//	w.clipammo = w.clipSize;
	}
	CalculateWeight();
}

final function SetAmmo (int clips, int bullets, s_Weapon w, bool secondary, optional bool buykeybind)
{
	Local	int Amount;

	if ( Role < Role_Authority )
	{
		return;
	}

	if ( secondary )
	{
		Amount = (W.GetRemainingClips(true)-clips) * w.default.BackupClipPrice;
		if ( !HaveMoney(-Amount) ) return;
		AddMoney(Amount, true);
		w.SetRemainingAmmo(clips, bullets, true);
	}
	else
	{
		Amount = (W.GetRemainingClips(false)-clips) * w.default.ClipPrice;
        if ( !HaveMoney(-Amount) ) return;
		  AddMoney(Amount, true);

        //fix shotties only being loaded with one shell
        if(w.IsA('s_Mossberg') && buykeybind)
	           clips = w.clipSize;

        w.SetRemainingAmmo(clips, bullets, false);
	}
}

exec function s_kammo()
{
	if (!OkForBuy()) return; else Super.s_kammo();
}

simulated function bool IsInBuyZone()
{
	if (!OkForBuy()) return false; else return Super.IsInBuyZone();
}

simulated function s_ChangeTeam (int Num, int Team, bool bDie)
{
	local AssaultMod SG;

	bDie=True;
	if (Role==Role_Authority)
	{
		SG=AssaultMod(Level.Game);
		if (SG==None)
		{
			Log("s_Player::s_ChangeTeam - Unable to locate game !!!");
			return;
		}
		SG.ChangePlModel(self,Num,Team,bDie);
		AssaultPRI(PlayerReplicationInfo).PlayerModel=num;
		SG.ForceSkinUpdate(self);
		if (PlayerReplicationInfo.bWaitingPlayer)
			SG.PlayerJoined(self);
	}
}

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
	Spawn(Class'AssaultPlayer');
	Spawn(Class'AssaultBot');
}

defaultproperties
{
	HUDType=Class'TOAS.TOASHUD'
    PlayerReplicationInfoClass=Class'TOAS.AssaultPRI'
}
