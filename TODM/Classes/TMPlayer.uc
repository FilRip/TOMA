class TMPlayer extends s_Player_T;

var byte CptIAR;
var() config bool bShowMyCurrentScore;
var() config bool bPlayAnnouncer;
var localized string Objective;
var carcass carc;
var byte DisableWeapon[32];
var() config bool bAutoBuyArmor;

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

simulated function CalculateWeight()
{
	local float Weight;
    local Inventory inv;

	if (bNotPlaying)
		return;

	if (bSpecialItem)
		Weight+=class's_SpecialItem'.default.Weight;

	if (HelmetCharge>0)
		Weight+=5;

	if (VestCharge>0)
		Weight+=10;

	if (LegsCharge>0)
		Weight+=10;

    for (inv=Inventory;Inv!=None;inv=inv.inventory)
    {
        if ((inv!=None) && (inv.IsA('s_Weapon')))
            Weight+=s_Weapon(inv).WeaponWeight;
    }

	if (bIsCrouching)
	{
		PrePivot.Z=Default.CollisionHeight-CrouchHeight-2.0;
		Weight+=200;
	}
	else
		PrePivot.Z=0.0;

	if (Weight>220)
		Weight=220;

	GroundSpeed=280-Weight;
	AirSpeed=300+Weight;
  	AccelRate=2048.000000+Weight;
  	AirControl=0.300000-Weight/1000;

	GroundSpeed*=1.25;
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
	if ((Level.Game!=None) && (!Level.Game.IsA('TMMod')))
	{
		StartWalk();
		if (Handedness==1)
			LoadLeftHand();
	}
	else
	{
		if ((Role==Role_Authority) && (Level.NetMode!=NM_Standalone))
			Spawn(Class'TMProtect',self);
	}
	if (Level.NetMode==NM_Client)
	{
		ServerSetTaunt(bAutoTaunt);
		if ((Level.Game!=None) && (!Level.Game.IsA('TMMod')))
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
	if ((Level!=None) && (Level.Game!=None) && !Level.Game.IsA('TMMod'))
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
	PZone=Spawn(Class'TMPZone',self);
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
		if ((Level.Game!=None) && TMMod(Level.Game).bSinglePlayer)
		{
			C.bQuickKeyEnable=True;
			C.LaunchUWindow();
			StartMenu=TMAutoTeamSelect(C.Root.CreateWindow(Class'TMAutoTeamSelect',0,0,C.Root.WinWidth,C.Root.WinHeight));
		}
		else
		{
			C.bQuickKeyEnable=True;
			C.LaunchUWindow();
			StartMenu=TMTeamSelect(C.Root.CreateWindow(Class'TMTeamSelect',0,0,C.Root.WinWidth,C.Root.WinHeight));
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
	SetTimer(1,true);
	UpdateWeaponsList();
	InitNewObjectives();
	if (Role<Role_Authority)
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
	SI.ObjShot1=Texture'TODM.Logo';
	SI.objShot2=None;
	SI.ObjShot3=None;
	SI.ObjShot4=None;
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
//			TMMod(Level.Game).ReStartPlayer(self);
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

simulated function bool IsInBuyZone()
{
	return true;
}

/*function ServerCountDown()
{
	TMMod(Level.Game).NoAttack(self);
}*/

function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, name damageType)
{
    if (CptIAR>0) return; else OldTakeDamage(Damage,instigatedBy,hitlocation,momentum,damageType);
}

/*state JustRespawnedPlayer extends PlayerWalking
{
	ignores TakeDamage;

	function Timer()
	{
		Super.Timer();
		ClearProgressMessages();
		SetProgressTime(1);
		SetProgressMessage(String(CptIAR),0);
//		ServerCountDown();
	}
Begin:
	SetTimer(1,true);
	CptIAR=5;
}*/

function Die()
{
	bHasNV=false;
}

simulated function s_ChangeTeam(int num,int team,bool bDie)
{
	local TMMod SG;

	if (Role==Role_Authority)
	{
		SG=TMMod(Level.Game);
		if (SG==None)
		{
			Log("s_Player::s_ChangeTeam - Unable to locate game !!!");
			return;
		}

		SG.ChangeTMPModel(self,num,team,bDie);
		SG.ForceSkinUpdate(self);

		if (PlayerReplicationInfo.bWaitingPlayer)
			SG.TMPlayerJoined(Self);
	}

}

event PostRender(canvas Canvas)
{
	Super.PostRender(Canvas);
	if (bShowMyCurrentScore) DrawMyCurrentScore(Canvas);
}

exec function ToggleMyCurrentScore()
{
    bShowMyCurrentScore=!bShowMyCurrentScore;
}

simulated function DrawMyCurrentScore(Canvas C)
{
	if ((s_HUD(myHUD).bHideHUD) || (s_HUD(myHUD).bHideStatus)) return;
	C.DrawColor=s_HUD(MyHUD).Design.ColorSuperwhite;
	C.Style=3;
	if (s_HUD(MyHUD).bDrawBackground)
	{
		C.SetPos(C.ClipX-79,C.ClipY-169);
		C.DrawTile(Texture'hud_elements',79,18,0,52,79,18);
		C.Style=2;
		C.SetPos(C.ClipX-79,C.ClipY-169);
		C.DrawTile(Texture'hud_elements',79,18,0,70,79,18);
	}
	s_HUD(MyHUD).TOHud_SetTeamColor(C,3);
	C.SetPos(C.ClipX-59,C.ClipY-169);
	s_HUD(MyHUD).TOHud_Tool_DrawNum(C,TMPRI(PlayerReplicationInfo).CurrentScore,FS_SMALL,3);
}

function OldTakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, name damageType)
{
	local int actualDamage;
	local bool bAlreadyDead;

	bAlreadyDead = (Health <= 0);

	if ( s_SWATGame(Level.Game).GamePeriod != GP_RoundPlaying )
		return;

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
		else if (Inventory != None)
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

	if (instigatedBy != none)
	{
		if (instigatedBy.IsA('s_Player'))
		{
			if ( PlayerReplicationInfo == instigatedBy.PlayerReplicationInfo ) {
				if ( Health > ActualDamage)
					TO_PRI(instigatedBy.PlayerReplicationInfo).InflictedDmg -= actualDamage;
				else
					TO_PRI(instigatedBy.PlayerReplicationInfo).InflictedDmg -= Health;
			} else {
				if (Health > ActualDamage)
					TO_PRI(instigatedBy.PlayerReplicationInfo).InflictedDmg += actualDamage;
				else
					TO_PRI(instigatedBy.PlayerReplicationInfo).InflictedDmg += Health;
			}
		} else if (instigatedBy.IsA('s_Bot')) {
        	if ( PlayerReplicationInfo == instigatedBy.PlayerReplicationInfo ) {
				if (Health > ActualDamage)
					TO_BRI(instigatedBy.PlayerReplicationInfo).InflictedDmg -= actualDamage;
				else
					TO_BRI(instigatedBy.PlayerReplicationInfo).InflictedDmg -= Health;
			} else {
				if (Health > ActualDamage)
					TO_BRI(instigatedBy.PlayerReplicationInfo).InflictedDmg += actualDamage;
				else
					TO_BRI(instigatedBy.PlayerReplicationInfo).InflictedDmg += Health;
			}
		}// else log("s_Player::TakeDamage - Instigator is not a pawn");
	}

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

simulated function HUD_Add_Death_Message(PlayerReplicationInfo KillerPRI,PlayerReplicationInfo VictimPRI)
{
	if (TMHUD(myHUD)!=None) TMHUD(myHUD).TMAdd_Death_Message(KillerPRI,VictimPRI);
}

exec function Fire(optional float F)
{
    if (CptIAR>0) bFire=0;
    else super.Fire(F);
}

function ToggleAutoAnnouncer()
{
    bPlayAnnouncer=!bPlayAnnouncer;
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
	Spawn(Class'TMPlayer');
	Spawn(Class'TMBot');
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

/*function SpawnGibbedCarcass()
{
    Log("exec gibbedcarcass");
	carc = Spawn(CarcassType);
	if ( carc != None )
	{
		carc.Initfor(self);
		carc.ChunkUp(-1 * Health);
	}
}*/

function Escape()
{
}

defaultproperties
{
    bAutoBuyArmor=True
    JumpZ=385
    PlayerReplicationInfoClass=class'TODM.TMPRI'
	HUDType=class'TMHUD'
	bShowMyCurrentScore=true
	bPlayAnnouncer=true
	Objective="This is a DeathMatch, Kill'em ALL, regardless the team"
}
