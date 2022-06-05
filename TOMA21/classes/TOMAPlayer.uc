class TOMAPlayer extends S_Player_T config(User);

// TODO : Mutate command (specialy 'vote' exec function command)
// TODO : Faire la limite des specialnades dans s_kammoauto & le buymenu

var TOMATeamSelect StartMenu;
var byte NbSpecialNade;
var bool bHasAlreadyBeInRageMode;
var bool AlreadyWarnAboutRecord;
var() config bool centerhud, countershud;
var() config int YourMax;
var byte myvote;
//var bool bShowVoteTab;
var class<TOMAScriptedPawn> MonstersClass;
var int cptbe4respawn;
var() config bool bDrawRadar;
var() config bool bPlayRadarSound;
var int lastlevel;
var byte WBR;
var byte MoreAmmo,MoreBackupAmmo;
var byte CptIAR;
var carcass carc;
var int Mana;

// RageMode
var int OldRound,OldHR,OldVR,NumWeapon;

replication
{
	reliable if (Role<ROLE_Authority)
		fonction5,ServerTOMAVote,ServerUseMana,/*fonction6,fonction7,fonction8,fonction1,fonction2,*/fonction3,fonction4;
	reliable if ((bNetOwner) && (Role==ROLE_Authority))
		CheckYourMaxScore;/*,fonction9,fonction10;*/
	reliable if (Role==Role_Authority)
		NbSpecialNade,bHasAlreadyBeInRageMode,UpdateObjectives,myvote,WBR,CptIAR,Mana;
	reliable if ((!bNotPlaying) && (Role<ROLE_Authority))
	   BuyOnServer;
}

exec function TOMACenterHud()
{
	if (centerhud) centerhud=false; else centerhud=true;
	StaticSaveConfig();
	SaveConfig();
}

exec function UseMana()
{
    if (Mana==0) exit;
    ServerUseMana();
}

function ServerUseMana()
{
	TOMAMod(Level.Game).CmdClient("USE MANA",self);
}

exec function TOMACountersHud()
{
	if (countershud) countershud=false; else countershud=true;
	StaticSaveConfig();
	SaveConfig();
}

simulated function CalculateWeight()
{
	local float Weight;

	if (bNotPlaying)
		return;
	if (bSpecialItem)
		Weight+=Class's_SpecialItem'.Default.Weight;
	if (HelmetCharge>0)
		Weight+=5;
	if (VestCharge>0)
		Weight+=10;
	if (LegsCharge>0)
		Weight+=10;
	if ((Weapon!=None) && Weapon.IsA('S_Weapon'))
		Weight+=S_Weapon(Weapon).WeaponWeight;
	if (bIsCrouching)
	{
		PrePivot.Z=Default.CollisionHeight-CrouchHeight-2;
		Weight+=200;
	}
	else
		PrePivot.Z=0;
	if (Weight>220)
		Weight=220;
	GroundSpeed=280-Weight;
	if (bHasAlreadyBeInRageMode) GRoundSpeed*=1.5;
	AirSpeed=300+Weight;
	AccelRate=2048+Weight;
	AirControl=0.30-Weight/1000;
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
	Spawn(class'TOMA21.TOMAFB');
	Spawn(class'TOMA21.TOMASmokeNade');
	Spawn(class'TOMA21.TOMAEnergyShieldNade');
	Spawn(class'TOMA21.TOMABabyCow');
	Spawn(class'TOMA21.TOMABloblet');
	Spawn(class'TOMA21.TOMACow');
	Spawn(class'TOMA21.TOMABrute');
	Spawn(class'TOMA21.TOMACaveManta');
	Spawn(class'TOMA21.TOMADevilFish');
	Spawn(class'TOMA21.TOMAFly');
	Spawn(class'TOMA21.TOMAGasbag');
	Spawn(class'TOMA21.TOMAGiantGasbag');
	Spawn(class'TOMA21.TOMAGiantManta');
	Spawn(class'TOMA21.TOMAIceSkaarj');
	Spawn(class'TOMA21.TOMAKrall');
	Spawn(class'TOMA21.TOMAKrallElite');
	Spawn(class'TOMA21.TOMALeglessKrall');
	Spawn(class'TOMA21.TOMALesserBrute');
	Spawn(class'TOMA21.TOMAManta');
	Spawn(class'TOMA21.TOMAMercenary');
	Spawn(class'TOMA21.TOMAMercenaryElite');
	Spawn(class'TOMA21.TOMANaliPriest');
	Spawn(class'TOMA21.TOMANali');
	Spawn(class'TOMA21.TOMAParentBlob');
	Spawn(class'TOMA21.TOMAPupae');
	Spawn(class'TOMA21.TOMAQueen');
	Spawn(class'TOMA21.TOMASkaarJAssassin');
	Spawn(class'TOMA21.TOMASkaarjBerserker');
	Spawn(class'TOMA21.TOMASkaarjGunner');
	Spawn(class'TOMA21.TOMASkaarjInfantry');
	Spawn(class'TOMA21.TOMASkaarJLord');
	Spawn(class'TOMA21.TOMASkaarjOfficer');
	Spawn(class'TOMA21.TOMASkaarjScout');
	Spawn(class'TOMA21.TOMASkaarjSniper');
	Spawn(class'TOMA21.TOMASlith');
	Spawn(class'TOMA21.TOMAStoneTitan');
	Spawn(class'TOMA21.TOMASquid');
	Spawn(class'TOMA21.TOMATentacle');
	Spawn(class'TOMA21.TOMATitan');
	Spawn(class'TOMA21.TOMAWarlord');
	Spawn(class'TOMA21.TOMAOICW');
	Spawn(class'TOMA21.TOMAGrenade');
	Spawn(class'TOMA21.TOMAM4M203');
	Spawn(class'TOMA21.TOMAFAMAS');
	Spawn(class'TOMA21.TOMASteyrAug');
	Spawn(class'TOMA21.TOMAConcussion');
    Spawn(class'TOMA21.TOMAShieldEffect');
    Spawn(class'TOMA21.TOMAAlienQueen');
    Spawn(class'TOMA21.TOMAChrek');
    Spawn(class'TOMA21.TOMABug');
    Spawn(class'TOMA21.TOMACobra');
    Spawn(class'TOMA21.TOMASnakey');
    Spawn(class'TOMA21.TOMASerpico');
}

simulated function CheckYourMaxScore()
{
	if (Level.NetMode==NM_CLIENT)
	{
		if (PlayerReplicationInfo.Score>YourMax) YourMax=PlayerReplicationInfo.Score;
/*		SaveConfig();
		StaticSaveConfig();*/
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

	UpdateURL("Class","s_SWAT.s_Player_T",True);
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
	if ((Level.Game!=None) && (!Level.Game.IsA('TOMAMod')))
	{
		StartWalk();
		if (Handedness==1)
			LoadLeftHand();
	}
	else
	{
		if ((Role==Role_Authority) && (Level.NetMode!=NM_Standalone))
			Spawn(Class'TOMAProtect',self);
	}
	if (Level.NetMode==NM_Client)
	{
		ServerSetTaunt(bAutoTaunt);
		if ((Level.Game!=None) && (!Level.Game.IsA('TOMAMod')))
			ServerSetInstantRocket(bInstantRocket);
	}

	if ( Role < Role_Authority )
	{
		ServerSetHideDeathMsg(bHideDeathMsg);
		ServerSetAutoReload(bAutomaticReload);
	}
	Bob=OriginalBob;

	FixMapProblems();
	if ((Level!=None) && (Level.Game!=None) && !Level.Game.IsA('TOMAMod'))
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
	PZone=Spawn(Class'TOMAPZone',self);
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
		if ((Level.Game!=None) && TOMAMod(Level.Game).bSinglePlayer)
		{
			C.bQuickKeyEnable=True;
			C.LaunchUWindow();
			StartMenu=TOMAAutoTeamSelect(C.Root.CreateWindow(Class'TOMAAutoTeamSelect',0,0,C.Root.WinWidth,C.Root.WinHeight));
		}
		else
		{
			C.bQuickKeyEnable=True;
			C.LaunchUWindow();
			StartMenu=TOMATeamSelect(C.Root.CreateWindow(Class'TOMATeamSelect',0,0,C.Root.WinWidth,C.Root.WinHeight));
		}
	}
	if ((Player!=None) && (Player.Console!=None) && (TO_Console(Player.Console)!=None) && ((TO_Console(Player.Console).SpeechWindow==None) || !TO_Console(Player.Console).SpeechWindow.IsA('TOMASWATWindow')))
	{
		Root=WindowConsole(Player.Console).Root;
		TO_Console(Player.Console).SpeechWindow=SpeechWindow(Root.CreateWindow(Class'TOMASWATWindow',100,100,200,200));
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

simulated function UpdateObjectives()
{
	MonstersClass=class<TOMAScriptedPawn>(DynamicLoadObject(TOMAGameReplicationInfo(GameReplicationInfo).nameofmonster,class'Class'));
	SI.ScenarioName=class'TOMAMod'.default.ScenarioNameText;
	SI.ScenarioDescription1=class'TOMAMod'.default.SD1;
	SI.ScenarioDescription2=class'TOMAMod'.default.LevelText$" : " $ string(TOMAGameReplicationInfo(GameReplicationInfo).numlevel) $ " " $ class'TOMAMod'.default.NamedText$" : " $ right(TOMAGameReplicationInfo(GameReplicationInfo).nameofmonster,len(TOMAGameReplicationInfo(GameReplicationInfo).nameofmonster)-11);
	SI.SF_Objective1=class'TOMAMod'.default.SFO1;
	SI.SF_Objective2=class'TOMAMod'.default.SFO2;
	SI.SF_Objective3=class'TOMAMod'.default.SFO3;
	SI.SF_Objective4=class'TOMAMod'.default.SFO4;
	if (MonstersClass!=None)
	{
		if (MonstersClass.Default.sshot1!="")
			SI.ObjShot1=Texture(DynamicLoadObject(MonstersClass.Default.sshot1,class'Texture')); else SI.ObjShot1=None;
		if (MonstersClass.Default.sshot2!="")
			SI.ObjShot2=Texture(DynamicLoadObject(MonstersClass.Default.sshot2,class'Texture')); else SI.ObjShot2=None;
		SI.ObjShot3=None;
		SI.ObjShot4=Texture(DynamicLoadObject("TOMATex21.Logo.White",class'Texture'));
	}
	lastlevel=TOMAGameReplicationInfo(GameReplicationInfo).numlevel;
}

event PostRender(canvas Canvas)
{
	super.PostRender(Canvas);

	if (Level.NetMode==NM_CLIENT)
	{
        if (TOMAGameReplicationInfo(GameReplicationInfo).numlevel!=lastlevel) UpdateObjectives();
		if (YourMax>0)
		{
			CheckYourMaxScore();
			if ((PlayerReplicationInfo.Score>YourMax) && (!AlreadyWarnAboutRecord))
			{
/*				ClearProgressMessages();
				SetProgressTime(4.00);
				SetProgressMessage(class'TOMAMod'.default.beatrecordtext,0);*/
                ReceiveLocalizedMessage(class'TOMAMessage',20);
				AlreadyWarnAboutRecord=true;
			}
		}
	}
}

exec function TOMAVoteTab()
{
    TOMAHud(myhud).bDisplayTOMAVote=true;
}

exec function TOMAVote(byte i)
{
    ServerTOMAVote(i," VOTE LEVEL ");
}

exec function TOMASkip()
{
    ServerTOMAVote(255," SKIP LEVEL ");
}

function ServerTOMAVote(byte i,string cmd)
{
	if (i!=0)
	{
//		if (i<RetourneNbNom(class'TOMAMod'.default.MonstersForVote))
		TOMAMod(Level.Game).CmdClient(cmd$string(i),self);
	}
}

function string RetourneNomPos(string fullline,int position)
{
	local string retour,tempchaine;
	local int i;

	if (position>RetourneNbNom(fullline)) retour="";
	if (position==1)
	{
		if (RetourneNbNom(fullline)==1) retour=fullline;
		else
			retour=left(fullline,instr(fullline,","));
	}
	else
	{
		i=1;
		tempchaine=fullline;
debut:
		if (instr(tempchaine,",")>0)
		{
			i++;
			tempchaine=right(tempchaine,len(tempchaine)-instr(tempchaine,",")-1);
			if (i==position)
			{
				if (instr(tempchaine,",")>0) retour=left(tempchaine,instr(tempchaine,",")); else retour=tempchaine;
			}
			else goto Debut;
		} else
		{
			retour=tempchaine;
		}
	}
	return retour;
}

function int RetourneNbNom(string fullline)
{
	local int retour;
	local string tempchaine;

	retour=0;
	tempchaine=fullline;
debut:
	if (instr(tempchaine,",")>0)
	{
		tempchaine=right(tempchaine,len(tempchaine)-instr(tempchaine,",")-1);
		retour++;
		goto debut;
	}
	if (len(retour)>0) retour++;
	return retour;
}

simulated function PassInRageModeNow()
{
	if (!bHasAlreadyBeInRageMode)
	{
		bHasAlreadyBeInRageMode=True;
		NumWeapon=S_Weapon(Weapon).WeaponID;
		OldRound=S_Weapon(Weapon).RoundPerMin;
		OldHR=S_Weapon(Weapon).HRecoil;
		OldVR=S_Weapon(Weapon).VRecoil;
		S_Weapon(Weapon).ClipAmmo=255;
		S_Weapon(Weapon).RoundPerMin=200000;
		GroundSpeed=GroundSpeed*1.5;
		S_Weapon(Weapon).HRecoil=0;
		S_Weapon(Weapon).VRecoil=0;
/*		ClientMessage(RageModeText);
		ClientMessage(RageModeText);
		ClientMessage(RageModeText);*/
	}
}

simulated function BackFromRageMode()
{
	local Inventory Inv;

	if (bHasAlreadyBeInRageMode)
	{
		bHasAlreadyBeInRageMode=False;
		if (Health<1) return;
		for (inv=inventory;inv!=none;inv=inv.inventory)
			If (S_Weapon(Inv).WeaponID==NumWeapon)
			{
				S_Weapon(Inv).RoundPerMin=OldRound;
				S_Weapon(Inv).HRecoil=OldHR;
				S_Weapon(Inv).VRecoil=OldVR;
			}
/*		S_Weapon(Weapon).RoundPerMin=OldRound;
		S_Weapon(Weapon).HRecoil=OldHR;
		S_Weapon(Weapon).VRecoil=OldVR;*/
	}
}

function fonction5(int WeaponNum,optional bool nocheck)
{
	local TOMAMod SG;

	SG=TOMAMod(Level.Game);
	if (SG==None)
		return;
	SG.BuyTOMAWeapon(self,WeaponNum,nocheck);
}

/*final function fonction6()
{
	local TOMAMod SG;

	SG=TOMAMod(Level.Game);
	if (SG==None)
		return;
	SG.KillTOMAInventory(self,True);
}*/

/*final function fonction7(int Amount)
{
	if (Role<Role_Authority)
		return;
	money=Amount;
}*/

/*final function fonction8(byte Num)
{
	local S_Weapon W;
	local TOMAMod SG;

	SG=TOMAMod(Level.Game);
	if (SG==None)
		return;
	SG.GiveWeapon(self,"s_SWAT.s_Knife");
	W=S_Weapon(FindInventoryType(Class's_Knife'));
	W.clipAmmo=Num;
	AddMoney(-((Num*W.ClipPrice)/W.clipSize),True);
}*/

/*final function fonction1(byte Item)
{
	if (Role<Role_Authority)
		return;
	if (Item==1) VestCharge=0;
	if (Item==2) HelmetCharge=0;
	if (Item==3) LegsCharge=0;
	if (Item==5) fonction21();
	CalculateWeight();
}*/

/*function fonction2(byte Num)
{
	local int price;

	PlaySound(Sound'Kevlar',slot_misc);
	if ((Num==1) && (HaveMoney(350)) && (VestCharge<100))
	{
		AddMoney(-350,True);
		VestCharge=100;
		CalculateWeight();
	}
	else
	{
		if ((Num==2) && (HaveMoney(250)) && (HelmetCharge<100))
		{
			AddMoney(-250,True);
			HelmetCharge=100;
			CalculateWeight();
		}
		else
		{
			if ((Num==3) && (HaveMoney(300)) && (LegsCharge<100))
			{
				AddMoney(-300,True);
				LegsCharge=100;
				CalculateWeight();
			}
			else
			{
				if ((Num==4) && (HaveMoney(900)) && ((VestCharge<100) || (HelmetCharge<100) || (LegsCharge<100)))
				{
					price=0;
					if (VestCharge<100)
					{
						price+=350;
						VestCharge=100;
					}
					if (HelmetCharge<100)
					{
						price+=250;
						HelmetCharge=100;
					}
					if (LegsCharge<100)
					{
						price+=300;
						LegsCharge=100;
					}
					AddMoney(-price,True);
					CalculateWeight();
				}
				else
				{
					if ((Num==5) && (HaveMoney(800)) && (!bHasNV))
					{
						ClientPlaySound(Sound'equip_nvg',,True);
						AddMoney(-800,True);
						fonction22();
					}
				}
			}
		}
	}
}*/

function fonction3()
{
	local TOMAMod SG;
	local int DiffMoney;

	SG=TOMAMod(Level.Game);
	if (SG==None)
		return;
	DiffMoney=Clamp(Money,-SG.MaxMoney,SG.MaxMoney)-Money;

	if (DiffMoney==0)
		return;

	SG.AddMoney(Self,DiffMoney,true);
}

/*function fonction21()
{
	bHasNV=False;
	fonction9();
}*/

/*simulated function fonction9()
{
	bHasNV=False;
	zzbNightVision=False;
}*/

/*function fonction22()
{
	bHasNV=True;
	fonction10();
}*/

simulated function fonction10()
{
	bHasNV=True;
}

function fonction12()
{
    bHasNV=false;
}

final function fonction4(int clips,int bullets,s_Weapon W,bool secondary,optional bool buykeybind)
{
	local int Amount;

	if (Role<Role_Authority)
		return;
	if (secondary)
	{
		Amount=(W.GetRemainingClips(true)-clips)*w.default.BackupClipPrice;
		if (!HaveMoney(-Amount)) return;
		AddMoney(Amount,true);
		w.SetRemainingAmmo(clips, bullets,true);
	}
	else
	{
		Amount=(W.GetRemainingClips(false)-clips)*w.default.ClipPrice;
        if (!HaveMoney(-Amount)) return;
		  AddMoney(Amount,true);

        if(w.IsA('s_Mossberg') && buykeybind)
	           clips=w.clipSize;

        w.SetRemainingAmmo(clips,bullets,false);
	}
}

exec function s_kammoAuto(int QuikBuyNum)
{
	local int WeaponNum;

	if (!bInBuyZone)
		return;
	WeaponNum=QuikBuyNum-101;
	if ((QuikBuyNum>100) && (QuikBuyNum<200))
	{
		if (TOMAGameReplicationInfo(GameReplicationInfo).NewWeapons)
		{
			if (WeaponNum<=Class'TOMAWeaponsHandler'.Default.NumWeapons)
			{
				if (!Class'TOMAWeaponsHandler'.static.IsTeamMatch(self,WeaponNum))
				{
					if (TOMAGameReplicationInfo(GameReplicationInfo).TerroristsWeapons) fonction5(WeaponNum);
				}
				else fonction5(WeaponNum);
			}
		}
		else
		{
			if (WeaponNum<=Class'TO_WeaponsHandler'.Default.NumWeapons)
				if (!Class'TO_WeaponsHandler'.static.IsTeamMatch(self,WeaponNum))
				{
					if (TOMAGameReplicationInfo(GameReplicationInfo).TerroristsWeapons) fonction5(WeaponNum);
				} else fonction5(WeaponNum);
		}
	} else
	Super.s_kAmmoAuto(QuikBuyNum);
}

/*function fonction11(S_Weapon W, optional byte AmmoType)
{
	local TOMAMod SG;

	SG=TOMAMod(Level.Game);
	if (SG==None)
		return;
	if (AmmoType==0)
		SG.buyammo(self,W);
	if (AmmoType==1)
		SG.BuyPrimaryAmmo(self,W);
	if (AmmoType==2)
		SG.BuyAltAmmo(self,W);
}*/

simulated function s_ChangeTeam(int Num, int Team, bool bDie)
{
	local	TOMAMod SG;

	if ( Role == Role_Authority )
	{
		SG = TOMAMod(Level.Game);
		if ( SG == None )
		{
			Log("s_Player::s_ChangeTeam - Unable to locate game !!!");
			return;
		}

		SG.TOMAChangePModel(self, num, team, bDie);
		SG.ForceSkinUpdate(self);

		if ( PlayerReplicationInfo.bWaitingPlayer )
			SG.PlayerJoined(Self);
	}
	UpdateObjectives();
}

simulated function bool IsInBuyZone()
{
	if (TOMAGameReplicationInfo(GameReplicationInfo).bFixBuyZone) return true; else return super.IsInBuyZone();
}

function ServerReStartPlayer()
{
	if (((bFrozen) && (TimerRate>0.0)) || (Level.NetMode==NM_Client))
		return;

	if (Level.Game.RestartPlayer(self))
	{
		ServerTimeStamp=0;
		TimeMargin=0;
		Enemy=None;
		bHidden=false;
		EndState();
		TOMAMod(Level.Game).ReStartPlayer(self);
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

function BuyOnServer(Equipment E,byte MA,byte MBA)
{
	local S_Weapon W;
	local TOMAMod SG;
	local int i;
	local int Id;
	local int X;
	local Inventory Inv;
	local bool boughtall;

	if (!IsInBuyZone())
	{
		return;
	}
	SG=TOMAMod(Level.Game);
	if (SG==None)
	{
		return;
	}
	boughtall=True;
	if ((VestCharge==100) && ((E.Flags & 64)==0))
	{
		AddMoney(350,True);
		VestCharge=0;
	}
	if ((HelmetCharge==100) && ((E.Flags & 128)==0))
	{
		AddMoney(250,True);
		HelmetCharge=0;
	}
	if ((LegsCharge==100) && ((E.Flags & 32)==0))
	{
		AddMoney(300,True);
		LegsCharge=0;
	}
	W=FindWeaponByGroup(2);
	if ((E.Weapon2!=0) && ((W==None) || (E.Weapon2!=Class'TOMAWeaponsHandler'.static.GetIdByClass(string(W.Class)))))
	{
		if (W!=None)
		{
			CheckWeaponSell(W,E.Weapon2);
		}
	}
	else
	{
		if ((W!=None) && (E.Weapon2==0))
		{
			CheckWeaponSell(W,E.Weapon2);
		}
	}
	W=FindWeaponByGroup(3);
	if ((E.Weapon3!=0) && ((W==None) || (E.Weapon3!=Class'TOMAWeaponsHandler'.static.GetIdByClass(string(W.Class)))))
	{
		if (W!=None)
		{
			CheckWeaponSell(W,E.Weapon3);
		}
	}
	else
	{
		if ((W!=None) && (E.Weapon3==0))
		{
			CheckWeaponSell(W,E.Weapon3);
		}
	}
	W=FindWeaponByGroup(4);
	if ((E.Weapon4!=0) && ((W==None) || (E.Weapon4!=Class'TOMAWeaponsHandler'.static.GetIdByClass(string(W.Class)))))
	{
		if (W!=None)
		{
			CheckWeaponSell(W,E.Weapon4);
		}
	}
	else
	{
		if ((W!=None) && (E.Weapon4==0))
		{
			CheckWeaponSell(W,E.Weapon4);
		}
	}
	W=FindWeaponByGroup(5);
	if ((E.Weapon5!=0) && ((W==None) || (E.Weapon5!=Class'TOMAWeaponsHandler'.static.GetIdByClass(string(W.Class)))))
	{
		if ( W!=None)
		{
			CheckWeaponSell(W,E.Weapon5);
		}
	}
	else
	{
		if ((W!=None) && (E.Weapon5==0))
		{
			CheckWeaponSell(W,E.Weapon5);
		}
	}
	if ((bHasNV) && ((E.Flags & 16)==0))
	{
		AddMoney(400,True);
		fonction12();
	}
	if ((VestCharge<100) && ((E.Flags & 64)!=0) && (HaveMoney(350)))
	{
		AddMoney(-350,True);
		VestCharge=100;
	}
	else
	{
		if (((E.Flags & 64)!=0) && (VestCharge<100))
		{
			boughtall=False;
		}
	}
	if ((HelmetCharge<100) && ((E.Flags & 128)!=0) && (HaveMoney(250)))
	{
		AddMoney(-250,True);
		HelmetCharge=100;
	}
	else
	{
		if (((E.Flags & 128)!=0) && (HelmetCharge<100))
		{
			boughtall=False;
		}
	}
	if ((LegsCharge<100) && ((E.Flags & 32)!=0) && (HaveMoney(300)))
	{
		AddMoney(-300,True);
		LegsCharge=100;
	}
	else
	{
		if (((E.Flags & 32)!=0) && (LegsCharge<100))
		{
			boughtall=False;
		}
	}
	W=S_Weapon(FindInventoryType(Class's_Knife'));
	AddMoney((W.clipAmmo-1) * (W.ClipPrice/W.clipSize),True);
	W.clipAmmo=1;
	i=E.Flags & 7;
	for (X=1;X<i && X<8;X++)
	{
		if (HaveMoney(W.ClipPrice/W.clipSize))
		{
			AddMoney(-W.ClipPrice/W.clipSize,True);
			W.clipAmmo++;
		}
		else
		{
			boughtall=False;
			break;
		}
	}
	W=FindWeaponByGroup(2);
	if ((E.Weapon2!=0) && (W==None))
	{
		W=SG.BuyTOMAWeapon(self,E.Weapon2,True);
		if (W==None)
		{
			boughtall=False;
		}
		else
		{
			W.clipAmmo=W.clipSize;
		}
	}
	if (W!=None)
	{
		fonction4(E.Ammo & 255,W.GetRemainingBullets(False),W,False);
		fonction4(E.BackupAmmo & 255,W.GetRemainingBullets(True),W,True);
	}
	W=FindWeaponByGroup(3);
	if ((E.Weapon3!=0) && (W==None))
	{
		W=SG.BuyTOMAWeapon(self,E.Weapon3,True);
		if (W==None)
		{
			boughtall=False;
		}
		else
		{
			W.clipAmmo=W.clipSize;
		}
	}
	if (W!=None)
	{
		fonction4(E.Ammo >> 8 & 255,W.GetRemainingBullets(False),W,False);
		fonction4(E.BackupAmmo >> 8 & 255,W.GetRemainingBullets(True),W,True);
	}
	W=FindWeaponByGroup(4);
	if ((E.Weapon4!=0) && (W==None))
	{
		W=SG.BuyTOMAWeapon(self,E.Weapon4,True);
		if (W==None)
		{
			boughtall=False;
		}
		else
		{
			W.clipAmmo=W.clipSize;
		}
	}
	if (W!=None)
	{
		fonction4(E.Ammo >> 16 & 255,W.GetRemainingBullets(False),W,False);
		fonction4(E.BackupAmmo >> 16 & 255,W.GetRemainingBullets(True),W,True);
	}
//	W=None;
	W=FindWeaponByGroup(5);
	if ((E.Weapon5!=0) && (W==None))
	{
		W=SG.BuyTOMAWeapon(self,E.Weapon5,True);
		if (W==None)
		{
			boughtall=False;
		}
		else if (!W.IsA('TO_Grenade'))
		{
			W.clipAmmo=W.clipSize;
		}
	}
	if ((W!=None) && (!W.IsA('TO_Grenade')))
	{
		fonction4(MA,W.GetRemainingBullets(False),W,False);
		fonction4(MBA,W.GetRemainingBullets(True),W,True);
	}
	if (!bHasNV && ((E.Flags & 16)!=0) && HaveMoney(400))
	{
		AddMoney(-400,True);
		fonction10();
	}
	else
	{
		if (((E.Flags & 16)!=0) && !bHasNV)
		{
			boughtall=False;
		}
	}
	if (!boughtall)
	{
		PlaySound(Sound'hithelmet',SLOT_None);
	}
	else
	{
		PlaySound(Sound'Kevlar',SLOT_None);
		CloseBuymenu();
	}
	fonction3();
	CalculateWeight();
	SwitchToBestWeapon();
}

function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, name damageType)
{
	local int actualDamage;
	local bool bAlreadyDead;

/*
	if ( instigatedBy != None )
		log("s_Player::TakeDamage - D:"@Damage@"i:"@instigatedBy.GetHumanName()@"DT:"@damagetype);
	else
		log("s_Player::TakeDamage - D:"@Damage@"i: None"@"DT:"@damagetype);
*/
	bAlreadyDead = (Health <= 0);

    if (CptIAR>0) return;
	if ( s_SWATGame(Level.Game).GamePeriod != GP_RoundPlaying )
		return;

	/*
	if ( !bAlreadyDead && bIsCrouching )
		TOStandUp(false);
	*/

	actualDamage = s_SWATGame(Level.Game).SWATReduceDamage(Damage, DamageType, self, instigatedBy, HitLocation-Location);

	if ( Physics == PHYS_None )
		SetMovementPhysics();

	if ( Physics == PHYS_Walking )
		momentum.Z = FMax(momentum.Z, 0.4 * VSize(momentum));

	if ( instigatedBy == self )
		momentum *= 0.6;
	momentum = momentum/Mass;

	if ( bIsPlayer )
	{
		if (ReducedDamageType == 'All') //God mode
			actualDamage = 0;
		else if (Inventory != None) //then check if carrying armor
			actualDamage = Inventory.ReduceDamage(actualDamage, DamageType, HitLocation);
		else
			actualDamage = Damage;
	}
	else if ( (InstigatedBy != None) && (InstigatedBy.IsA(Class.Name) || self.IsA(InstigatedBy.Class.Name)) )
		ActualDamage = ActualDamage * FMin(1 - ReducedDamagePct, 0.35);
	else if ( (ReducedDamageType == 'All') || ((ReducedDamageType != '') && (ReducedDamageType == damageType)) )
		actualDamage = float(actualDamage) * (1 - ReducedDamagePct);

	if ( Level.Game.DamageMutator != None )
		Level.Game.DamageMutator.MutatorTakeDamage( ActualDamage, Self, InstigatedBy, HitLocation, Momentum, DamageType );

	//New damagebased scoresystem
	if (instigatedBy != none)
	{
		if (instigatedBy.IsA('s_Player'))
		{
			if ( PlayerReplicationInfo.Team == instigatedBy.PlayerReplicationInfo.Team ) {
				if ( Health > ActualDamage)
					if (TOMAMod(Level.Game).FriendlyFireScale>0) TO_PRI(instigatedBy.PlayerReplicationInfo).InflictedDmg -= actualDamage;
				else
					if (TOMAMod(Level.Game).FriendlyFireScale>0) TO_PRI(instigatedBy.PlayerReplicationInfo).InflictedDmg -= Health;
			} else {
				if (Health > ActualDamage)
					TO_PRI(instigatedBy.PlayerReplicationInfo).InflictedDmg += actualDamage;
				else
					TO_PRI(instigatedBy.PlayerReplicationInfo).InflictedDmg += Health;
			}
		} else if (instigatedBy.IsA('s_Bot')) {
        	if ( PlayerReplicationInfo.Team == instigatedBy.PlayerReplicationInfo.Team ) {
				if (Health > ActualDamage)
					if (TOMAMod(Level.Game).FriendlyFireScale>0) TO_BRI(instigatedBy.PlayerReplicationInfo).InflictedDmg -= actualDamage;
				else
					if (TOMAMod(Level.Game).FriendlyFireScale>0) TO_BRI(instigatedBy.PlayerReplicationInfo).InflictedDmg -= Health;
			} else {
				if (Health > ActualDamage)
					TO_BRI(instigatedBy.PlayerReplicationInfo).InflictedDmg += actualDamage;
				else
					TO_BRI(instigatedBy.PlayerReplicationInfo).InflictedDmg += Health;
			}
        } else if (instigatedBy.IsA('TOMAScriptedPawn')) {
        	if (Health > ActualDamage)
					TOMAMonstersReplicationInfo(instigatedBy.PlayerReplicationInfo).InflictedDmg += actualDamage;
				else
					TOMAMonstersReplicationInfo(instigatedBy.PlayerReplicationInfo).InflictedDmg += Health;
			}
		//else log("s_Player::TakeDamage - Instigator is not a pawn");
	} //else log("s_Player::TakeDamage - Instigator == none");

	//End new damagebased scoresystem

	AddVelocity( momentum );
	Health -= actualDamage;
	if ( CarriedDecoration != None )
		DropDecoration();

	if ( HitLocation == vect(0,0,0) )
		HitLocation = Location;

	if ( Health > 0 )
	{
		if ( (instigatedBy != None) && (instigatedBy != Self) )
			damageAttitudeTo(instigatedBy);

		if ( (instigatedBy!=None) && (damageType=='shot') )
		{
			hitLocation = Location + CollisionRadius * Vector(Normalize(Rotator(instigatedBy.Location-Location)));
		}

		PlayHit(actualDamage, hitLocation, damageType, Momentum); //, instigatedBy  // crouchbugged
	}
	else if ( !bAlreadyDead )
	{
		//log(self$" died");
		NextState = '';
		PlayDeathHit(actualDamage, hitLocation, damageType, Momentum);

		if ( actualDamage > mass )
			Health = -1 * actualDamage;

		if ( (instigatedBy != None) && (instigatedBy != Self) )
			damageAttitudeTo(instigatedBy);

		Died(instigatedBy, damageType, HitLocation);
	}
	else
	{
		//Warn(self$" took regular damage "$damagetype$" from "$instigator$" while already dead");
		// SpawnGibbedCarcass();
		if ( bIsPlayer )
		{
			HidePlayer();
			GotoState('Dying');
		}
		else
			Destroy();
	}
	MakeNoise(1.0);
}

exec function ToggleRadar()
{
    bDrawRadar=!bDrawRadar;
    SaveConfig();
}

exec function ToggleRadarSound()
{
    bPlayRadarSound=!bPlayRadarSound;
    SaveConfig();
}

/*simulated event Destroyed()
{
    CheckYourMaxScore();
    super.Destroyed();
}*/

function CheckWeaponSell(s_Weapon W, int Wish)
{
	local int id;

	if (TOMAGameReplicationInfo(GameReplicationInfo).NewWeapons) Id=class'TOMA21.TOMAWeaponsHandler'.static.GetIdByClass(string(W.Class));
	else Id=class'TOModels.TO_WeaponsHandler'.static.GetIdByClass(string(W.Class));
	if (Id!=Wish)
	{
		AddMoney(W.default.price + W.GetRemainingClips(false)*W.default.ClipPrice + W.GetRemainingClips(true)*W.default.BackupClipPrice,true);
		W.Destroy();
	}

}

function s_Weapon FindWeaponByGroup(int Group)
{
	local Inventory inv;
	local int i;

	for (inv=Inventory;inv!=none;inv=inv.Inventory)
	{
		if (inv.IsA('s_Weapon'))
		{
			if (s_Weapon(Inv).InventoryGroup==Group)
				return s_Weapon(Inv);
		}
		if (++i>100)
		{
			break; // can occasionally get temporary loops in netplay
		}
	}

	return none;
}

simulated function ClientRoundEnded()
{
	if (Level.NetMode!=NM_DedicatedServer)
	{
		if (bSZoom)
			ToggleSZoom();

		if (Role<Role_Authority)
			spawn(class'TOMARemover',self);
	}
}

exec function Fire(optional float F)
{
    if (CptIAR>0) bFire=0;
    else super.Fire(F);
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
	Weapon=None;
}

function Escape()
{
}

state PlayerSpectating
{
	ignores SeePlayer, HearNoise, Bump, TakeDamage, Died, ZoneChange, FootZoneChange;

	function ChangeTeam( int N ) { }
	function ViewShake(float deltatime) {}

	simulated function UsePress()
	{
		if ( Level.NetMode == NM_StandAlone )
			EndRound();
	}

	exec function Fire( optional float F )
	{
		if ( Role == ROLE_Authority )
		{
			ViewPlayerNum(-1);
			if ( (ViewTarget != None) && (Pawn(ViewTarget) != None) && TO_GameBasics(Level.Game).bAllowBehindView)
			{
				bBehindView = bBackupBehindView;
			}
			else
				bBehindView = false;
		}
	}


	exec function AltFire( optional float F )
	{
		if ( (ViewTarget != None) && (Pawn(ViewTarget) != None) && TO_GameBasics(Level.Game) != none && TO_GameBasics(Level.Game).bAllowBehindView)
			bBackupBehindView = !bBackupBehindView;
		else
			bBackupBehindView = false;

		bBehindView = bBackupBehindView;
	}

	function PlayerMove(float DeltaTime)
	{
		local rotator newRotation;
		local vector X,Y,Z;

		// Ugly Hack.
		ViewRotation.Roll = 0;

		GetAxes(ViewRotation,X,Y,Z);

		aForward *= 0.08;
		aStrafe  *= 0.08;
		aLookup  *= 0.12;
		aTurn    *= 0.12;
		aUp		 *= 0.025;

		Acceleration = aForward*X + aStrafe*Y + aUp*vect(0,0,1);

		UpdateRotation(DeltaTime, 1);

		if ( Role < ROLE_Authority ) // then save this move and replicate it
			ReplicateMove(DeltaTime, Acceleration, DODGE_None, rot(0,0,0));
		else
			ProcessMove(DeltaTime, Acceleration, DODGE_None, rot(0,0,0));
	}

	exec function Say(string Msg)
	{
		local Pawn P;

		if ( bAdmin && (left(Msg,1) == "#") )
		{
			Msg = right(Msg,len(Msg)-1);
			for( P=Level.PawnList; P!=None; P=P.nextPawn )
				if( P.IsA('PlayerPawn') )
				{
					PlayerPawn(P).ClearProgressMessages();
					PlayerPawn(P).SetProgressTime(6);
					PlayerPawn(P).SetProgressMessage(Msg,0);
				}
			return;
		}

		if ( Level.Game.AllowsBroadcast(self, Len(Msg)) && Msg != LastMessage)
		{
			LastMessage = Msg;
			for( P=Level.PawnList; P!=None; P=P.nextPawn )
			{
				if(!P.IsA('PlayerPawn'))
					continue;
				if ( (P.bIsPlayer && P.PlayerReplicationInfo.bIsSpectator) || Self.bAdmin || PlayerPawn(P).bAdmin)
				{
					//log("s_player::spectating::say - spect:"@P.PlayerReplicationInfo.bIsSpectator@"-admin:"@bAdmin);
					if ( Level.Game.MessageMutator != None )
					{
						if ( Level.Game.MessageMutator.MutatorTeamMessage(Self, P, PlayerReplicationInfo, Msg, 'Say', true) )
							P.TeamMessage( PlayerReplicationInfo, Msg, 'Say', true );
					}
					else
						P.TeamMessage( PlayerReplicationInfo, Msg, 'Say', true );
				}
			}
		}
	}


	exec function TeamSay( string Msg )
	{
		local Pawn P;

		if ( !Level.Game.bTeamGame )
		{
			Say(Msg);
			return;
		}

		if ( Msg ~= "Help" )
		{
			CallForHelp();
			return;
		}

		if ( Level.Game.AllowsBroadcast(self, Len(Msg)) && Msg != LastMessage)
		{
			LastMessage= Msg;
			for ( P=Level.PawnList; P!=None; P=P.nextPawn )
				if ( P.bIsPlayer && (P.PlayerReplicationInfo.Team == PlayerReplicationInfo.Team) )
				{
					if ( bAdmin || P.PlayerReplicationInfo.bIsSpectator )
					{
						if ( Level.Game.MessageMutator != None )
						{
							if ( Level.Game.MessageMutator.MutatorTeamMessage(Self, P, PlayerReplicationInfo, Msg, 'TeamSay'/*'Say'*/, true) )
								P.TeamMessage( PlayerReplicationInfo, Msg, 'TeamSay', true );
						}
						else
							P.TeamMessage( PlayerReplicationInfo, Msg, 'TeamSay', true );
					}
				}
		}
	}


	function EndState()
	{
		//log("s_Player::PlayerSpectating::EndState");
		EyeHeight = Default.BaseEyeHeight;
		BaseEyeHeight = Default.BaseEyeHeight;
		SetMesh();
		SetCollisionSize(Default.CollisionRadius, Default.CollisionHeight);
		SetCollision(true,true,true);
		PlayerReplicationInfo.bIsSpectator = false;
		PlayerReplicationInfo.bWaitingPlayer = false;

		// No shake when exiting this state
		shaketimer = 0.0;

		if ( Role == Role_Authority )
		{
			bNotPlaying = false;
			bAlwaysRelevant = true;
			AirSpeed = 400.0;
			/* Onion not needed? - no problems so far; fixes "Now viewing from own camera at roundstart"
			bBehindView = false;
			Viewtarget = None;
			if ( bAdmin )
				ViewSelf();
			*/
		}
	}

	function BeginState()
	{
		//log("s_Player::PlayerSpectating::BeginState");
		if ( Level.NetMode != NM_DedicatedServer )
		{
			if ( bSZoom )
				ToggleSZoom();
		}

		PlayerReplicationInfo.bIsSpectator = true;
		PlayerReplicationInfo.bWaitingPlayer = false;
		Mesh = None;
		EyeHeight = 0;
		BaseEyeHeight = 0;
		SetCollision(false,false,false);
		SetCollisionSize(4, 4);
		SetPhysics(PHYS_None);

		// Ugly Hack.
		ViewRotation.Roll = 0;

		if ( Role == Role_Authority )
		{
			bNotPlaying = true;
			bAlwaysRelevant = false;
			bFire = 0;
			AirSpeed = 200.0;

			if ( !s_GameReplicationInfo(GameReplicationInfo).bAllowGhostCam )
				ViewPlayerNum(-1);

			if ( (ViewTarget != None) && (Pawn(ViewTarget) != None) && TO_GameBasics(Level.Game).bAllowBehindView)
				bBehindView = true;
			else
				bBehindView = false;
			bBackupBehindView = true;
		}
		Weapon=None;
	}
}

defaultproperties
{
	centerhud=false
	countershud=true
	YourMax=0
	HUDType=class'TOMA21.TOMAHud'
    bDrawRadar=true
	bPlayRadarSound=False
}

