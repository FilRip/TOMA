class AssaultMod extends s_SWATGame;

var() config byte LimitOfSupport,LimitOfSniper,LimitOfAssault;
var() config int LimitBuyTime;
var() config bool FixMutatorReplicationBugUT436;

function string GetRules()
{
    local string a;

	a=Super.GetRules();

	// Fix mutator replication bug of UT436
	if ((EnabledMutators!="") && (FixMutatorReplicationBugUT436))
		a=a$"\\mutators\\"$EnabledMutators;
	return a;
}

function PlayerPawn Login (string Portal, string Options, out string Error, Class<PlayerPawn> SpawnClass)
{
	local PlayerPawn NewPlayer;
	local NavigationPoint StartSpot;
	local string InFace;
	local string InPassword;
	local string InSkin;
	local byte InTeam;

	SpawnClass=Class'AssaultPlayer';
	bRequireReady=False;
	if ( GetIntOption(Options, "Team", 254) != 255 )
		Options = SetTeamOption(Options, "Team", "255");
	if ( ParseOption(Options, "OverrideClass") ~= "Botpack.CHSpectator" )
		Options = SetTeamOption(Options, "OverrideClass", "s_SWAT.TO_Spectator");
	NewPlayer=Super(TO_DeathMatchPlus).Login(Portal,Options,Error,SpawnClass);
	if (NewPlayer==None)
	{
		Error="Couldn't spawn player.";
		return None;
	}
	if (Left(NewPlayer.PlayerReplicationInfo.PlayerName,6)==DefaultPlayerName)
	{
		NewPlayer.SetCollision(false,false,false);
		NewPlayer.EyeHeight = NewPlayer.BaseEyeHeight;
		NewPlayer.SetPhysics(PHYS_None);

		if ( NewPlayer.PlayerReplicationInfo.Team == 0 )
			AssaultSetRandomTerrModel(NewPlayer);
		else
			AssaultSetRandomSFModel(NewPlayer);

		SetPlayerStartPoint( NewPlayer );
		if (Level.Game.WorldLog!=None)
			Level.Game.WorldLog.LogSpecialEvent("forced_name_change",NewPlayer.PlayerReplicationInfo.PlayerName,string(NewPlayer.PlayerReplicationInfo.PlayerID),DefaultPlayerName $ string(NumPlayers));
		ChangeName(NewPlayer,DefaultPlayerName $ string(NumPlayers),False);
	}
	NewPlayer.bAutoActivate=True;
	NewPlayer.GameReplicationInfo=GameReplicationInfo;
	PlayerTeamNum=NewPlayer.PlayerReplicationInfo.Team;
	return NewPlayer;
}

function AddDefaultInventory (Pawn PlayerPawn)
{
	local Bot B;

	B=Bot(PlayerPawn);

	if ((PlayerPawn.IsA('AssaultPlayer')) && (PlayerPawn.PlayerReplicationInfo.bWaitingPlayer))
		return;
	GiveTeamWeapons(PlayerPawn);
	AddMoney(PlayerPawn,20000);
	if (B!=None)
		B.bHasImpactHammer=False;
	BaseMutator.ModifyPlayer(PlayerPawn);
	PlayerPawn.SwitchToBestWeapon();
}

function GiveTeamWeapons (Pawn P)
{
	local Inventory Inv;
	local bool bKnife;

	if ((P.PlayerReplicationInfo==None) || (P.PlayerReplicationInfo.bIsSpectator) || (P.PlayerReplicationInfo.bWaitingPlayer))
		return;
	bKnife=False;
	for (Inv=P.Inventory;Inv!=None;Inv=Inv.Inventory)
	{
		if (Inv.IsA('s_Knife'))
		{
			bKnife=True;
			break;
		}
	}
	if (!bKnife)
		GiveWeapon(P,"s_SWAT.s_Knife");
}

function Logout(Pawn Exiting)
{
	local TO_PRI TOPRI;
	local Pawn P;
	local int i;

	if (Exiting.IsA('AssaultPlayer'))
		for (P=Level.PawnList;P != None;P=P.nextPawn)
			if ( P.IsA('AssaultPlayer') && (P != Exiting) )
			{
				TOPRI=TO_PRI(P.PlayerReplicationInfo);
				i=0;
				while (i<48)
				{
					if (TOPRI.VoteFrom[i]== Exiting.PlayerReplicationInfo)
					{
						TOPRI.VoteFrom[i]=None;
						break;
					}
					i++;
				}
			}
//	DropInventory(Exiting,False);
	if (Exiting.IsA('s_NPC'))
		return;
	Super(TO_TeamGamePlus).Logout(Exiting);
	ResetNPCPlayer(Exiting);
	CheckEndGame();
}

function Killed(Pawn Killer,Pawn Other,name DamageType)
{
	local Pawn PawnLink;
	local S_Player P;
	local s_bot B;
	local s_NPCHostage H;
	local PlayerReplicationInfo VictimPRI;
	local PlayerReplicationInfo KillerPRI;

	LogKillStats(Killer,Other,DamageType);
	if (Other.IsA('s_NPC'))
	{
		if (s_NPCHostage(Other)!=None)
		{
			H=s_NPCHostage(Other);
			if ((Killer!=None) && (!Killer.IsA('s_NPC')))
			{
				if (bSinglePlayer)
					HostageKilled(Killer,Other,DamageType);
				else
					AddMoney(Killer,KillHostagePrice);
				if (Killer.PlayerReplicationInfo.Team==0)
					bTShotHostages=True;
			}
			if ((H.Followed!=None) && (s_bot(H.Followed)!=None))
			{
				if (s_bot(H.Followed).HostageFollowing>0)
					s_bot(H.Followed).HostageFollowing--;
				if (s_bot(H.Followed).HostageFollowing<1)
					ClearBotObjective(s_bot(H.Followed));
			}
			nbHostagesLeft--;
			CheckHostageWin();
		}
		Other.PlayerReplicationInfo.bIsSpectator=True;
		return;
	}
	ResetNPCPlayer(Other);
	if ((BotConfig.bAdjustSkill) && (Killer.IsA('PlayerPawn')) || (Other.IsA('PlayerPawn')))
	{
		if (Killer.IsA('Bot'))
			BotConfig.AdjustSkill(Bot(Killer),True);
		if (Other.IsA('Bot'))
			BotConfig.AdjustSkill(Bot(Other),False);
	}
	if (Other.PlayerReplicationInfo!=None)
	{
		VictimPRI=Other.PlayerReplicationInfo;
		Other.PlayerReplicationInfo.Deaths+=1;
		Other.PlayerReplicationInfo.bIsSpectator=True;
	}
	else
		VictimPRI=None;
//	DropInventory(Other,True);
	Other.DieCount++;
	if (DamageType=='MirrorDamage')
		AddMoney(Other,-4*KillPrice);
	if ((Killer==None) || (Killer==Other))
	{
		KillerPRI=None;
		CheckTK(Other);
	}
	else
	{
		bFirstKill=True;
		if ((s_bot(Killer)!=None) && (s_bot(Killer).LastObjective!='None'))
			s_bot(Killer).ResetLastObj();
		if (!Killer.IsA('s_NPC'))
		{
			if (Killer.PlayerReplicationInfo!=None)
			{
				KillerPRI=Killer.PlayerReplicationInfo;
				if (Killer.PlayerReplicationInfo.Team!=Other.PlayerReplicationInfo.Team)
				{
					Killer.KillCount++;
					Killer.PlayerReplicationInfo.Score+=1;
					if (!bSinglePlayer)
						AddMoney(Killer,KillPrice);
				}
				else
				{
					Killer.PlayerReplicationInfo.Score-=1;
					if (DamageType!='MirrorDamage')
						AddMoney(Killer,-4*KillPrice);
					AddMoney(Other,4*KillPrice);
				}
			}
			else
				KillerPRI=None;
			CheckTK(Killer);
		}
	}
	BaseMutator.ScoreKill(Killer,Other);
	P=S_Player(Other);
	B=s_bot(Other);
	if (B!=None)
	{
		ClearBotObjective(B);
		B.VestCharge=0;
		B.HelmetCharge=0;
		B.LegsCharge=0;
		B.bDead=True;
		B.bNotPlaying=True;
		Other.Health=-1;
	}
	else
	{
		if (P!=None)
		{
			P.VestCharge=0;
			P.HelmetCharge=0;
			P.LegsCharge=0;
			P.bHasNV=False;
			P.zzbNightVision=False;
			if (P.Flashlight!=None)
			{
				P.Flashlight.Destroy();
				P.Flashlight=None;
			}
			P.SetPhysics(PHYS_None);
			P.bDead=True;
			P.bNotPlaying=True;
			Other.Health=-1;
		}
	}
	if (VictimPRI!=None)
		for (PawnLink=Level.PawnList;PawnLink!=None;PawnLink=PawnLink.nextPawn)
			if ((PawnLink.IsA('S_Player')) && (!S_Player(PawnLink).bHideDeathMsg))
				S_Player(PawnLink).HUD_Add_Death_Message(KillerPRI,VictimPRI);
	BotCheckOrderObject(Other);
	CheckEndGame();
}

function bool PickupQuery(Pawn Other,Inventory Item)
{
	if (Item.IsA('s_c4')) return Super.PickupQuery(Other,Item); else return false;
}

final function ChangePlModel (Pawn P, int Num, int Team, bool bDie)
{
	local Actor StartPoint;
	local byte OldTeam;
	local S_Player sp;
	local bool bNoWeapons;
	local bool bChangeModel;
	local bool bChangeTeam;
	local bool bNotPlaying;

	if (bBalancing)

		return;
	if (!bSinglePlayer)
		bDie=True;
	sp=S_Player(P);
	OldTeam=P.PlayerReplicationInfo.Team;
	bChangeTeam=OldTeam!=Team;
	if (sp!=None)
	{
		if ((sp.bAlreadyChangedTeam) && (bChangeTeam))
		{
			sp.ReceiveLocalizedMessage(Class's_MessageVote',7);
			return;
		}
		if ((!sp.PlayerReplicationInfo.bWaitingPlayer) && (bChangeTeam))
			sp.bAlreadyChangedTeam=True;
		bNotPlaying=(sp.bNotPlaying || sp.PlayerReplicationInfo.bWaitingPlayer);
		bNoWeapons=(sp.bDead || sp.PlayerReplicationInfo.bWaitingPlayer);
		bChangeModel=((Num==255) || (Num!=sp.PlayerModel));
		if ((bNotPlaying) || (!bChangeTeam) || (GamePeriod!=GP_RoundPlaying))
			bDie=True;
	}
	else
	{
		if ((P.PlayerReplicationInfo.bWaitingPlayer) || (P.PlayerReplicationInfo.bIsSpectator))
			bDie=True;
	}
	if (bDie)
		P.TakeDamage(500000,None,P.Location,vect(0,0,0),'ChangedTeam');
/*	else
	{
		if ((bChangeTeam) && (!bNoWeapons))
			DropInventory(P,False);
	}*/
	if (bChangeTeam)
		ChangeTeam(P,Team);
	if ((P.PlayerReplicationInfo.Team==Team) && (Team<3))
	{
		if (Num==255)
		{
			if (Team==1)
				AssaultSetRandomSFModel(P);
			else
				AssaultSetRandomTerrModel(P);
			AssaultPRI(P.PlayerReplicationInfo).PlayerModel=s_Player(P).PlayerModel;
		}
		else
			ChangeModel(P,Num);
		if ((bChangeTeam) && (P.GetStateName()=='PlayerSpectating'))
			PlayerPawn(P).Fire(0);
	}
	if ((!bDie) && (bChangeTeam) && (!bNoWeapons) && (!bNotPlaying))
	{
		GiveTeamWeapons(P);
		if (P.Weapon==None)
			P.SwitchToBestWeapon();
	}
}

function Bot SpawnBot(out NavigationPoint StartSpot)
{
	local Bot NewBot;
	local int BotN;
	local Pawn P;

	Difficulty=BotConfig.Difficulty;
	if ( Difficulty>=4)
	{
		bNoviceMode=False;
		Difficulty=Difficulty-4;
	}
	else
	{
		if (Difficulty>3)
		{
			Difficulty=3;
			bThreePlus=True;
		}
		bNoviceMode=True;
	}
	BotN=1;
	StartSpot=FindPlayerStart(None,255);
	if (StartSpot==None)
	{
		Log("Could not find starting spot for Bot");
		return None;
	}
	NewBot=Spawn(Class'AssaultBot',,,StartSpot.Location,StartSpot.Rotation);
	if (NewBot==None)
		Log("Couldn't spawn player at " $ string(StartSpot));
	if (NewBot!=None)
	{
		NewBot.PlayerReplicationInfo.PlayerID=CurrentID++;
		NewBot.PlayerReplicationInfo.Team=BotConfig.GetBotTeam(BotN);
		BotConfig.CHIndividualize(NewBot,NumBots,NumBots);
		NewBot.ViewRotation=StartSpot.Rotation;
		BroadcastMessage(NewBot.PlayerReplicationInfo.PlayerName $ EnteredMessage,False);
		ModifyBehaviour(NewBot);
		AddDefaultInventory(NewBot);
		NumBots++;
		if ((bRequireReady) && (CountDown>0))
			NewBot.GotoState('Dying','WaitingForStart');
		NewBot.AirControl=AirControl;
		if ((Level.NetMode!=NM_Standalone) && ((bNetReady) || (bRequireReady)))
			for (P=Level.PawnList;P!=None;P=P.nextPawn)
				if ((P.bIsPlayer) && (P.PlayerReplicationInfo!=None) && (P.PlayerReplicationInfo.bWaitingPlayer) && (P.IsA('PlayerPawn')))
					if (NewBot.bIsMultiSkinned)
						PlayerPawn(P).ClientReplicateSkins(NewBot.MultiSkins[0],NewBot.MultiSkins[1],NewBot.MultiSkins[2],NewBot.MultiSkins[3]);
					else
						PlayerPawn(P).ClientReplicateSkins(NewBot.Skin);
	}
	return NewBot;
}

function bool AddBot ()
{
	local Bot NewBot;
	local NavigationPoint StartSpot;
	local NavigationPoint OldStartSpot;
	local int DesiredTeam;
	local int i;
	local int MinSize;

	NewBot=SpawnBot(StartSpot);
	if (NewBot==None)
	{
		Log("Failed to spawn bot");
		return False;
	}
	NewBot.Health=100;
	DesiredTeam=NewBot.PlayerReplicationInfo.Team;
	NewBot.PlayerReplicationInfo.bIsABot=True;
	if ((DesiredTeam==255) || (!ChangeTeam(NewBot,DesiredTeam)))
	{
		DesiredTeam=0;
		if (Teams[1].Size<Teams[0].Size)
			DesiredTeam=1;
		if (!ChangeTeam(NewBot,DesiredTeam))
		{
			Log("AddBot - ChangeTeam failed - Destroy");
			NewBot.Destroy();
			return False;
		}
	}
	NewBot.PlayerReplicationInfo.Team=DesiredTeam;
	StartSpot=FindPlayerStart(NewBot,NewBot.PlayerReplicationInfo.Team);
	if (StartSpot==None)
	{
		Log("AddBot - FindPlayerStart failed - Destroy");
		NewBot.Destroy();
		return False;
	}
	NewBot.SetLocation(StartSpot.Location);
	NewBot.SetRotation(StartSpot.Rotation);
	NewBot.ViewRotation=StartSpot.Rotation;
	NewBot.SetRotation(NewBot.Rotation);
// TODO : Rajouter la vérification des Limit de class
	if (NewBot.PlayerReplicationInfo.Team==0)
	{
		AssaultSetRandomTerrModel(NewBot);
/*		while ((class'AssaultModelHandler'.static.ReturnClassName(AssaultBot(NewBot).PlayerModel)=="") && (AssaultGameReplicationInfo(GameReplicationInfo).PlaceInClass(class'AssaultModelHandler'.default.PClass[AssaultBot(NewBot).PlayerModel],0)>0))
			SetRandomTerrModel(NewBot);*/
	}
	else
	{
    	AssaultSetRandomSFModel(NewBot);
/*		while ((class'AssaultModelHandler'.static.ReturnClassName(AssaultBot(NewBot).PlayerModel)=="") && (AssaultGameReplicationInfo(GameReplicationInfo).PlaceInClass(class'AssaultModelHandler'.default.PClass[AssaultBot(NewBot).PlayerModel],1)>0))
			SetRandomSFModel(NewBot);*/
	}
	AssaultBRI(NewBot.PlayerReplicationInfo).PlayerModel=AssaultBot(NewBot).PlayerModel;
	if (LocalLog!=None)
	{
		LocalLog.LogPlayerConnect(NewBot);
		LocalLog.FlushLog();
	}
	if (WorldLog!=None)
	{
		WorldLog.LogPlayerConnect(NewBot);
		WorldLog.FlushLog();
	}
	if (GamePeriod==GP_PreRound)
	{
		s_bot(NewBot).GotoState('PreRound');
	}
	return True;
}

/*function bool FindSpecialAttractionFor(Bot aBot)
{
	if (s_Bot(aBot)!=None)
		if (s_Bot(aBot).Objective!='O_FindClosestBuyPoint')
			if (s_GameReplicationInfo(GameReplicationInfo).RoundStarted-s_GameReplicationInfo(GameReplicationInfo).RemainingTime<30)
			{
				s_Bot(aBot).Objective='Freelance';
				return false;
			}
	return Super.FindSpecialAttractionFor(aBot);
}*/

function InitGameReplicationInfo()
{
	local AssaultGameReplicationInfo GRI;

	Super.InitGameReplicationInfo();
	GRI=AssaultGameReplicationInfo(GameReplicationInfo);
	GRI.RoundStarted=RemainingTime;
	GRI.RoundDuration=RoundDuration;
	GRI.bAllowGhostCam=bAllowGhostCam;
	GRI.bAllowBehindView=bAllowBehindView;
	GRI.bMirrorDamage=bMirrorDamage;
	GRI.bEnableBallistics=bEnableBallistics;
	GRI.FriendlyFireScale=int(FriendlyFireScale*100);
	GRI.bPlayersBalanceTeams=bPlayersBalanceTeams;
	GRI.SupportLimit=LimitOfSupport;
	GRI.SniperLimit=LimitOfSniper;
	GRI.AssaultLimit=LimitOfAssault;
	GRI.LimitBuyTime=LimitBuyTime;
}

function bool CheckWeaponClass(Pawn P,int num)
{
    local Inventory Inv;

	for (Inv=P.Inventory;Inv!=None;Inv=Inv.Inventory)
        if (s_Weapon(Inv)!=None)
            if (s_Weapon(Inv).default.WeaponClass==num) return true;
    return false;
}

final function s_Weapon AssaultBuyWeapon(Pawn P, int weaponnum, optional bool nocheck)
{
	local class<Weapon>					WeaponClass;
	local Weapon								NewWeapon;
	local int										Price, i;
	local Texture NewSkin;
	local	Inventory							Inv;
	local vector								X, Y, Z;

		if ( (class'TOModels.TO_WeaponsHandler'.default.WeaponStr[weaponnum] == "")
			|| (!(class'TOModels.TO_WeaponsHandler'.static.IsTeamMatch(P, WeaponNum)))
            || (!(class'TOAS.AssaultWeaponsHandler'.static.IsClassMatch(P,weaponnum)))  )
			return none;

	WeaponClass = class<Weapon>(DynamicLoadObject(class'TOModels.TO_WeaponsHandler'.default.WeaponStr[weaponnum], class'Class'));

	// Pawn can buy the weapon?
	if ( (P.FindInventoryType(WeaponClass) != None)
		|| (P.IsA('s_Player') && (s_Player(P).bNotPlaying || s_Player(P).bBuyingWeapon)) )
		return none;

	if ( P.IsA('s_Player') )
		s_Player(P).bBuyingWeapon = true;

	newWeapon = Spawn(WeaponClass);

// Special check
    if (s_Weapon(newWeapon)!=None)
        if ((class'AssaultModelHandler'.default.PClass[AssaultPlayer(P).PlayerModel]==1) || (class'AssaultModelHandler'.default.PClass[AssaultPlayer(P).PlayerModel]==2))
        {
            if ((s_Weapon(newWeapon).default.WeaponClass==1) && (CheckWeaponClass(P,2)))
            {
                newWeapon.Destroy();
                return none;
            }
            if ((s_Weapon(newWeapon).default.WeaponClass==2) && (CheckWeaponClass(P,1)))
            {
                newWeapon.Destroy();
                return none;
            }
        }

	if ( NewWeapon == None )
	{
		if ( P.IsA('s_Player') )
			s_Player(P).bBuyingWeapon = false;
		return none;
	}

	if ( !HaveMoney(P, s_Weapon(newWeapon).Price) || !newWeapon.IsA('s_Weapon') )
	{
		NewWeapon.Destroy();
		if ( P.IsA('s_Player') )
			s_Player(P).bBuyingWeapon = false;
		return none;
	}

	for( Inv=P.Inventory; Inv!=None; Inv=Inv.Inventory )
	{
		if ( (Inv != NewWeapon) && Inv.IsA('s_Weapon') && (s_Weapon(Inv).WeaponClass != 0)
			&& (s_Weapon(Inv).WeaponClass == s_Weapon(NewWeapon).WeaponClass) )
		{
			P.GetAxes(P.Rotation, X, Y, Z);
	    s_Weapon(Inv).DropFrom(P.Location + 0.8 * P.CollisionRadius * X + - 0.5 * P.CollisionRadius * Y);
		}
	}

	newWeapon.RespawnTime = 0.0;
	newWeapon.GiveTo(P);
	if ( s_Weapon(newWeapon).bHasMultiSkins )
		s_Weapon(newWeapon).SetSkins();
	newWeapon.PlayIdleAnim();
	newWeapon.GotoState('idle');
	s_Weapon(newWeapon).ForceStillFrame();

	newWeapon.bHeldItem = true;
	newWeapon.bTossedOut = false;
	//newWeapon.GiveAmmo(P);
	newWeapon.SetSwitchPriority(P);
	if ( P.IsA('PlayerPawn') )
		newWeapon.SetHand(PlayerPawn(P).Handedness);
	else
		newWeapon.GotoState('Idle');

	P.PendingWeapon = newWeapon;

	//Used by LastWeapon
	if (P.IsA('s_BPlayer'))

		If (P.Weapon != none)
		{
			if ( !P.Weapon.IsA('TO_Binocs') && !P.Weapon.IsA('s_Knife') && !P.Weapon.IsA('TO_Grenade'))
				s_BPlayer(P).LastSelectedWeapon = P.Weapon;
			else
				s_BPlayer(P).LastSelectedWeapon = none;
		} else {
				s_BPlayer(P).LastSelectedWeapon = none;
		}

	if ( P.Weapon == None )
		P.ChangedWeapon();
	else if ( !P.Weapon.PutDown() )
		P.PendingWeapon = None;
		//P.Weapon.GotoState('DownWeapon');

 	//P.ClientMessage(-s_Weapon(newWeapon).Price@-s_Weapon(newWeapon).default.Price);
	AddMoney(P, -s_Weapon(newWeapon).Price, nocheck);

    /* j3rky - remove default ammo */
	s_Weapon(newWeapon).RemainingClip = 0;
	s_Weapon(newWeapon).BackupClip = 0;
	s_Weapon(newWeapon).ClipAmmo = 0;
	s_Weapon(newWeapon).BackClipAmmo = 0;
	/* j3rky */

	if ( P.IsA('s_Player') )
		s_Player(P).bBuyingWeapon = false;

	return s_Weapon(newWeapon);
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

function AddToTeam( int num, Pawn Other )
{
	local teaminfo aTeam;
	local Pawn		P;
	local bool		bSuccess;
	local string	SkinName, FaceName;
	local	actor	  StartSpot;
	local	byte		Oldteam;

	if ( (Other == None) || (Other.PlayerReplicationInfo == None) || (num == 255) )
	{
		log("Added none to team!!!");
		return;
	}

	ClearOrders(Other);
	OldTeam = Other.PlayerReplicationInfo.Team;
	aTeam = Teams[num];

	//Teams[Other.playerReplicationInfo.team].Size--;
	Other.PlayerReplicationInfo.Team = num;
	Other.PlayerReplicationInfo.TeamName = aTeam.TeamName;

	if ( LocalLog != None )
		LocalLog.LogTeamChange(Other);
	if ( WorldLog != None )
		WorldLog.LogTeamChange(Other);

	bSuccess = false;
	if ( Other.IsA('PlayerPawn') )
	{
		Other.PlayerReplicationInfo.TeamID = 0;
		PlayerPawn(Other).ClientChangeTeam(Other.PlayerReplicationInfo.Team);
	}
	else
		Other.PlayerReplicationInfo.TeamID = 1;

	while ( !bSuccess )
	{
		bSuccess = true;
		for ( P=Level.PawnList; P!=None; P=P.nextPawn )
            if ( P.bIsPlayer && (P != Other)
				&& (P.PlayerReplicationInfo.Team == Other.PlayerReplicationInfo.Team)
				&& (P.PlayerReplicationInfo.TeamId == Other.PlayerReplicationInfo.TeamId) )
				bSuccess = false;
		if ( !bSuccess )
			Other.PlayerReplicationInfo.TeamID++;
	}

	BroadcastLocalizedMessage( class'DeathMatchMessage', 3, Other.PlayerReplicationInfo, None, aTeam );

	if ( num == 0 )
		AssaultSetRandomTerrModel(Other);
	else
		AssaultSetRandomSFModel(Other);

	//SetVoiceType(Other.PlayerReplicationInfo);

	StartSpot = FindPlayerStart(Other, Other.PlayerReplicationInfo.Team);
	if ( StartSpot == None )
		//StartSpot = OldStartSpot;
	{
		log("AddToTeam - FindPlayerStart failed - Destroy");
		Other.Destroy();
		return;
	}

	Other.SetLocation(StartSpot.Location);
	Other.SetRotation(StartSpot.Rotation);
	Other.ViewRotation = StartSpot.Rotation;
	Other.SetRotation(Other.Rotation);

	aTeam.Size++;

	if ( OldTeam < 2 )//&& OldTeam != num)
		Teams[OldTeam].Size--;

	if ( bBalanceTeams && !bRatedGame )
		ReBalance();

	CheckEndGame();
}

final function AssaultSetRandomSFModel(Pawn Other)
{
	ChangeModel(Other, class'TOAS.AssaultModelHandler'.static.GetRandomSFModel(Other));
}

final function AssaultSetRandomTerrModel(Pawn Other)
{
	ChangeModel(Other, class'TOAS.AssaultModelHandler'.static.GetRandomTerrModel(Other));
}

defaultproperties
{
	BeaconName="Tactical Assault"
	GameName="Tactical Assault"
	HUDType=Class'TOAS.TOASHUD'
	LimitOfSupport=2
	LimitOfSniper=2
	LimitOfAssault=0
    GameReplicationInfoClass=Class'TOAS.AssaultGameReplicationInfo'
    LimitBuyTime=0
    FixMutatorReplicationBugUT436=true
}
