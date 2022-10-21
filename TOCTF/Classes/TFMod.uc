class TFMod extends s_SWATGame;

var vector TerroBase,SFBase;
var bool MapCantPlayCTF;
var TerroFlag TF;
var SFFlag SFF;
var Actor TFHomeBase,SFHomeBase;
var() config int ScorePerRound;
var() config int AmountForFlagScore;
var() config bool DoGlowOnFlagCarrier;
var() config bool bPlayTimeAnnouncer;
var() config bool bShowEffectInvulnerable;
var() config byte SecGodMod;
var() config bool bRemoveCarcass;
var int currentscore;
var() config bool FixMutatorReplicationBugUT436;
var() config bool bKeepInventory;
var() config int AmountForKill;
var() config byte DisableWeapon[32];

function string GetRules()
{
    local string a;

	a=Super.GetRules();
	if ((FixMutatorReplicationBugUT436) && (EnabledMutators!=""))
		a=a$"\\mutators\\"$EnabledMutators;
	return a;
}

function PreBeginPlay()
{
	Super.PrebeginPlay();
	SetNewInventory();
	CreateFlags();
}

function SetNewInventory()
{
    local byte i;

    for (i=0;i<32;i++)
        if (DisableWeapon[i]==1) class'TO_WeaponsHandler'.Default.WeaponTeam[i]=WT_None;
}

function RestartRound()
{
	Super.RestartRound();
	FlagsToHome();
}

function FlagsToHome()
{
	ResetFlagCarrier();
	if (TF!=None)
	{
		TF.SetLocation(TerroBase);
		TF.bHidden=false;
		TF.SetCollision(true,false,false);
		TF.GotoState('HomeBase');
	}
	if (SFF!=None)
	{
		SFF.SetLocation(SFBase);
		SFF.bHidden=false;
		SFF.SetCollision(true,false,false);
		SFF.GotoState('HomeBase');
	}
}

function CheckEndGame()
{
//	Super.CheckEndGame();
}

function CreateFlags()
{
	local s_ZoneControlPoint szcp;
	local TFGameReplicationInfo GRI;

	GRI=TFGameReplicationInfo(GameReplicationInfo);
	foreach AllActors(class's_ZoneControlPoint',szcp)
		if ((szcp.bHomeBase) || (szcp.bBuyPoint))
		{
			if (szcp.OwnedTeam==0)
            {
                TerroBase=szcp.Location;
                TFHomeBase=szcp;
            }
			if (szcp.OwnedTeam==1)
            {
                SFBase=szcp.Location;
                SFHomeBase=szcp;
            }
		}

	if ((TerroBase==vect(0,0,0)) || (SFBase==vect(0,0,0)))
	{
		MapCantPlayCTF=true;
		Log("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
		Log("!!! ERROR : Map can't be played as TO-CTF !!!");
		Log("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
	}

	if (!MapCantPlayCTF)
	{
		TF=Spawn(class'TerroFlag',,,TerroBase);
		TF.Home=TerroBase;
		SFF=Spawn(class'SFFlag',,,SFBase);
		SFF.Home=SFBase;
		Log("Flags created");
    	if (GRI!=None)
        {
            GRI.TheFlags[0]=TF;
            GRI.TheFlags[1]=SFF;
        } else log("BUG ?! GRI = None !!!");
	}
}

function playerpawn TOTeamGamePlusLogin(string Portal,string Options,out string Error,class<playerpawn> SpawnClass)
{
	local PlayerPawn newPlayer;
	local NavigationPoint StartSpot;
	local String InFace,InPassword,InSkin;
	local byte InTeam;

	SpawnClass=class'TFPlayer';
	bRequireReady=false;
	newPlayer=super(TO_DeathMatchPlus).Login(Portal,Options,Error,SpawnClass);

	if (NewPlayer==None)
	{
		Error="Couldn't spawn player.";
		return None;
	}

	if (Left(NewPlayer.PlayerReplicationInfo.PlayerName,6)==DefaultPlayerName)
	{
		if (Level.Game.WorldLog!=None)
			Level.Game.WorldLog.LogSpecialEvent("forced_name_change", NewPlayer.PlayerReplicationInfo.PlayerName,NewPlayer.PlayerReplicationInfo.PlayerID,DefaultPlayerName$NumPlayers);
		ChangeName( NewPlayer, (DefaultPlayerName$NumPlayers), false );
	}

	NewPlayer.bAutoActivate=true;
	NewPlayer.GameReplicationInfo=GameReplicationInfo;

	PlayerTeamNum=NewPlayer.PlayerReplicationInfo.Team;
	return newPlayer;
}

event PlayerPawn Login(string Portal,string Options,out string Error,Class<PlayerPawn> SpawnClass)
{
	local PlayerPawn newPlayer;
    local byte i;

	if (GetIntOption(Options,"Team",254)!=255)
		Options=SetTeamOption(Options,"Team","255");

	if (ParseOption(Options,"OverrideClass")~="Botpack.CHSpectator")
		Options=SetTeamOption(Options,"OverrideClass","s_SWAT.TO_Spectator");

	newPlayer=TOTeamGamePlusLogin(Portal,Options,Error,SpawnClass);

	if (NewPlayer!=None)
	{
        for (i=0;i<32;i++)
            TFPlayer(NewPlayer).DisableWeapon[i]=DisableWeapon[i];
		NewPlayer.SetCollision(false,false,false);
		NewPlayer.EyeHeight=NewPlayer.BaseEyeHeight;
		NewPlayer.SetPhysics(PHYS_None);

		if ((NewPlayer.PlayerReplicationInfo!=None) && (NewPlayer.PlayerReplicationInfo.Team==0))
			SetRandomTerrModel(NewPlayer);
		else
			SetRandomSFModel(NewPlayer);

		SetPlayerStartPoint(NewPlayer);
		TFPlayer(NewPlayer).CptIAR=SecGodMod;
	}

	return newPlayer;
}

function Killed(pawn Killer,pawn Other,name damageType)
{
	local	Pawn										PawnLink;
	local TFPlayer								P;
	local	s_Bot										B;
	local	s_NPCHostage						H;
	local	PlayerReplicationInfo		VictimPRI, KillerPRI;

	// punish handling
	if(killer != none && Other != none)
		if(Killer.PlayerReplicationInfo.Team == Other.PlayerReplicationInfo.Team && Killer.isA('s_Player') && Other.isA('s_Player'))
		{
			s_Player(Other).KillerID = Killer.PlayerReplicationInfo.PlayerID;
			s_Player(Other).KillTime = Level.Timeseconds;
		}

	//log("killed - Other: "$Other$" - Killer: "$Killer$" - damagetype: "$damageType);
	LogKillStats(Killer, Other, damagetype);

/*	if ( Other.IsA('s_NPC') )
	{
		if ( s_NPCHostage(Other) != None )
		{
			H = s_NPCHostage(Other);

			if ( (Killer != None) && (!Killer.IsA('s_NPC')) )
			{
				if ( bSinglePlayer )
				{
					HostageKilled(killer, Other, damageType);
				}
				else
					AddMoney(Killer, KillHostagePrice);

				// If terrorists shoot hostages, default win goes to Special Forces
				if ( Killer.PlayerReplicationInfo.Team == 0 )
					bTShotHostages = true;
			}

			if ( (H.Followed != None) && (s_Bot(H.Followed) != None) )
			{
				if ( s_Bot(H.Followed).HostageFollowing > 0 )
					s_Bot(H.Followed).HostageFollowing--;
				if ( s_Bot(H.Followed).HostageFollowing < 1 )
					ClearBotObjective(s_Bot(H.Followed));
				//ClearBotObjective(s_Bot(H.Followed));
				//s_Bot(H.Followed).bHostageFollowing = false;
			}

			nbHostagesLeft--;
			// In case enough hostages were rescued.
			CheckHostageWin();
		}

		Other.PlayerReplicationInfo.bIsSpectator = true;
		return;
	} */

	ResetNPCPlayer(Other);

	if ( BotConfig.bAdjustSkill && (killer.IsA('PlayerPawn') || Other.IsA('PlayerPawn')) )
  {
    if ( killer.IsA('Bot') )
      BotConfig.AdjustSkill(Bot(killer),true);

    if ( Other.IsA('Bot') )
      BotConfig.AdjustSkill(Bot(Other),false);
  }

	if ( Other.PlayerReplicationInfo != None )
	{
		VictimPRI = Other.PlayerReplicationInfo;
		Other.PlayerReplicationInfo.Deaths += 1;
		Other.PlayerReplicationInfo.bIsSpectator = true;
	}
	else
		VictimPRI = None;

	TFDropInventory(Other, true);
	Other.DieCount++;

	if ( damageType == 'MirrorDamage' )
	{
		// Team Killer !!
		//Other.PlayerReplicationInfo.Score -= 1;
		AddMoney(Other, -4*KillPrice);

		//CheckTK(Other);
	}


	if ( (Killer == None) || (Killer == Other) )
	{
		//Other.PlayerReplicationInfo.Score -= 1;
		KillerPRI = None;
		CheckTK(Other);
	}
	else
	{
		//log("TO_GameBasics::Killed - "@Other.GetHumanName()@"got killed by"@Killer.GetHumanName());
		bFirstKill = true;

		if ( (s_Bot(Killer) != None) && (s_Bot(Killer).LastObjective != '') )
			s_Bot(Killer).ResetLastObj();

		if ( !killer.IsA('s_NPC') )
		{
			if ( Killer.PlayerReplicationInfo != None )
			{
				KillerPRI = Killer.PlayerReplicationInfo;
				if ( Killer.PlayerReplicationInfo.Team != Other.PlayerReplicationInfo.Team )
				{
					killer.killCount++;
					Killer.PlayerReplicationInfo.Score += 1;

					if ( !bSinglePlayer )		// Only add money for kills if it is not a singleplayer game
						AddMoney(Killer, AmountForKill);
					//PlayRandEnemyDown(Killer);
				}
				else
				{ // Team Killer !!
					Killer.PlayerReplicationInfo.Score -= 1;
					if ( damageType != 'MirrorDamage' )
						AddMoney(Killer, -4*KillPrice);
					AddMoney(Other, 4*KillPrice);
				}
			}
			else
				KillerPRI = None;

			CheckTK( Killer );
		}
	}

	BaseMutator.ScoreKill(Killer, Other);

	//PlaySoundDeath(Other);
	P = TFPlayer(Other);
	B = s_Bot(Other);

	if ( B != None )
	{
		ClearBotObjective(B);
		if (!bKeepInventory)
		{
            B.VestCharge=0;
            B.HelmetCharge=0;
            B.LegsCharge=0;
        }
        B.bDead = true;
		B.bNotPlaying = true;
		Other.Health = -1;
	}
	else if ( P != None )
	{
		if (!bKeepInventory)
		{
            P.VestCharge = 0;
            P.HelmetCharge = 0;
            P.LegsCharge = 0;
//            P.zzbHasNV = false;
            P.Die();
        }
		if ( P.Flashlight != None )
		{
			P.Flashlight.Destroy();
			P.Flashlight = None;
		}
		//P.PlayerRestartState = 'PlayerSpectating';
		P.SetPhysics(PHYS_None);
		P.bDead = true;
		P.bNotPlaying = true;
		Other.Health = -1;
	}

	// Sending death message to players
	if ( VictimPRI != None )
	{
		for (PawnLink=Level.PawnList; PawnLink!=None; PawnLink=PawnLink.nextPawn)
		{
			if ( PawnLink.IsA('s_Player') && !s_Player(PawnLink).bHideDeathMsg )
				s_Player(PawnLink).HUD_Add_Death_Message(KillerPRI, VictimPRI);
		}
	}

	BotCheckOrderObject(Other);
	CheckEndGame();
	//ReBalance();
	//log("killed - end");

	if (Other!=None)
	{
	   if (Killer==None) AddMoney(Other,-1000);
		if ((Other.PlayerReplicationInfo!=None) && (TFPlayerReplicationInfo(Other.PlayerReplicationInfo)!=None))
			if (TFPlayerReplicationInfo(Other.PlayerReplicationInfo).bHasFlag)
			{
				TFPlayerReplicationInfo(Other.PlayerReplicationInfo).bHasFlag=false;
				Other.PlayerReplicationInfo.HasFlag=None;
				if (Other.PlayerReplicationInfo.Team==0) SFF.Carrier=None; else TF.Carrier=None;
				ResetAmbientToPlayer(Other);
				DropFlag(1-Other.PlayerReplicationInfo.Team,Other.Location);
                BroadcastLocalizedMessage(class'TFCTFMessage',2,Other.PlayerReplicationInfo, None, Teams[1-Other.PlayerReplicationInfo.Team] );
			}
		if ((Other.PlayerReplicationInfo!=None) && (TFBRI(Other.PlayerReplicationInfo)!=None))
			if (TFBRI(Other.PlayerReplicationInfo).bHasFlag)
			{
				TFBRI(Other.PlayerReplicationInfo).bHasFlag=false;
				Other.PlayerReplicationInfo.HasFlag=None;
				if (Other.PlayerReplicationInfo.Team==0) SFF.Carrier=None; else TF.Carrier=None;
				ResetAmbientToPlayer(Other);
				DropFlag(1-Other.PlayerReplicationInfo.Team,Other.Location);
                BroadcastLocalizedMessage(class'TFCTFMessage',2,Other.PlayerReplicationInfo, None, Teams[1-Other.PlayerReplicationInfo.Team] );
			}
	}
}

function Logout(pawn Exiting)
{
	if (Exiting!=None)
	{
		if ((Exiting.PlayerReplicationInfo!=None) && (TFPlayerReplicationInfo(Exiting.PlayerReplicationInfo)!=None))
			if (TFPlayerReplicationInfo(Exiting.PlayerReplicationInfo).bHasFlag)
			{
				TFPlayerReplicationInfo(Exiting.PlayerReplicationInfo).bHasFlag=false;
				if (Exiting.PlayerReplicationInfo.Team==0) SFF.Carrier=None; else TF.Carrier=None;
				DropFlag(1-Exiting.PlayerReplicationInfo.Team,Exiting.Location);
                BroadcastLocalizedMessage(class'TFCTFMessage',2,Exiting.PlayerReplicationInfo, None, Teams[1-Exiting.PlayerReplicationInfo.Team] );
				ResetAmbientToPlayer(Exiting);
			}
		if ((Exiting.PlayerReplicationInfo!=None) && (TFBRI(Exiting.PlayerReplicationInfo)!=None))
			if (TFBRI(Exiting.PlayerReplicationInfo).bHasFlag)
			{
				TFBRI(Exiting.PlayerReplicationInfo).bHasFlag=false;
				if (Exiting.PlayerReplicationInfo.Team==0) SFF.Carrier=None; else TF.Carrier=None;
				DropFlag(1-Exiting.PlayerReplicationInfo.Team,Exiting.Location);
                BroadcastLocalizedMessage(class'TFCTFMessage',2,Exiting.PlayerReplicationInfo, None, Teams[1-Exiting.PlayerReplicationInfo.Team] );
				ResetAmbientToPlayer(Exiting);
			}
	}
	super.Logout(Exiting);
}

function DropFlag(byte FlagTeam,vector place)
{
	if (FlagTeam==0)
	{
		TF.SetLocation(place);
		TF.bHidden=false;
		TF.SetCollision(true,false,false);
		TF.GotoState('Dropped');
	}
	else
	{
		SFF.SetLocation(place);
		SFF.bHidden=false;
		SFF.SetCollision(true,false,false);
		SFF.GotoState('Dropped');
	}
}

function ResetFlagCarrier()
{
	local Pawn P;

    for (P=Level.PawnList;P!=None;P=P.NextPawn)
	{
        if (P.PlayerReplicationInfo!=None)
        {
            if (TFPlayerReplicationInfo(P.PlayerReplicationInfo)!=None)
            {
        		TFPlayerReplicationInfo(P.PlayerReplicationInfo).bHasFlag=false;
        		P.PlayerReplicationInfo.HasFlag=none;
                ResetAmbientToPlayer(P);
            }
            if (TFBRI(P.PlayerReplicationInfo)!=None)
            {
        		TFBRI(P.PlayerReplicationInfo).bHasFlag=false;
        		P.PlayerReplicationInfo.HasFlag=None;
                ResetAmbientToPlayer(P);
            }
        }
	}

    if (TF.Carrier!=None) TF.Carrier.PlayerReplicationInfo.HasFlag=None;
	TF.Carrier=None;
    if (SFF.Carrier!=None) SFF.Carrier.PlayerReplicationInfo.HasFlag=None;
	SFF.Carrier=None;
}

function PlaySoundToAll(sound s)
{
	local Pawn aPlayer;

	for (aPlayer=Level.PawnList;aPlayer!=None;aPlayer=aPlayer.NextPawn)
		if (aPlayer.IsA('TFPlayer'))
			TFPlayer(aPlayer).ClientPlaySound(s,,true);
}

function TeamScored(Pawn P)
{
    PlaySoundToAll(Sound'TFModelsF.CaptureSound2');
	TournamentGameReplicationInfo(GameReplicationInfo).Teams[P.PlayerReplicationInfo.Team].Score+=1;
	AddMoney(P,AmountForFlagScore);
	currentscore++;
	if ((currentscore>=ScorePerRound) && (ScorePerRound>0))
	{
		BroadcastLocalizedMessage(class'TFMessageWin',18);
		currentscore=0;
		FlagsToHome();
		SetWinner(P.PlayerReplicationInfo.Team);
		EndGame("All flags captured, new round...");
	} else FlagsToHome();
}

/*function int SWATReduceDamage(int Damage, name DamageType, pawn injured, pawn instigatedBy, Vector HitLocation)
{
	local int newdm;

	newdm=Super.SWATReduceDamage(Damage,DamageType,injured,instigatedBy,HitLocation);
// Half damage for flag carrier, removed after first beta test
	if ((injured!=None) && (injured.IsA('TFPlayer')) && (injured.PlayerReplicationInfo!=None) && (TFPlayerReplicationInfo(injured.PlayerReplicationInfo).bHasFlag)) newdm*=0.5;
	else return newdm;
}*/

function ResetAmbientToPlayer(Pawn P)
{
    if (!DoGlowOnFlagCarrier) return;
	P.AmbientGlow=2;
	P.LightEffect=LE_None;
	P.LightRadius=0;
	P.LightType=LT_None;
	P.LightBrightness=0;
	P.LightSaturation=0;
	P.LightHue=0;
}

final function TFChangePModel(Pawn P,int num,int team,bool bDie)
{
	local Actor StartPoint;
	local byte OldTeam;
	local s_Player sP;
	local bool bNoWeapons,bChangeModel,bChangeTeam,bNotPlaying,HasFlag;

	if (bBalancing)
		return;

	if (!bSinglePlayer)
		bDie=true;

	sP=s_Player(P);

	OldTeam=P.PlayerReplicationInfo.Team;
	bChangeTeam=OldTeam!=team;

	if (sP!=None)
	{
		if ((sP.bAlreadyChangedTeam) && (bChangeTeam))
		{
			sP.ReceiveLocalizedMessage(class's_MessageVote',7);
			return;
		}

		if ((!sP.PlayerReplicationInfo.bWaitingPlayer) && (bChangeTeam))
			sP.bAlreadyChangedTeam=true;

		bNotPlaying=((sP.bNotPlaying) || (sP.PlayerReplicationInfo.bWaitingPlayer));
		bNoWeapons=((sP.bDead) || (sP.PlayerReplicationInfo.bWaitingPlayer));
		bChangeModel=((num==255) || (num!=sP.PlayerModel));

		if ((bNotPlaying) || (!bChangeTeam) || (GamePeriod!=GP_RoundPlaying))
			bDie=false;
	}
	else if ((P.PlayerReplicationInfo.bWaitingPlayer) || (P.PlayerReplicationInfo.bIsSpectator))
		bDie=false;

	if ((TFPlayerReplicationInfo(p.PlayerReplicationInfo)!=None) && (TFPlayerReplicationInfo(P.PlayerReplicationInfo).bHasFlag) && (bChangeTeam))
	{
		TFPlayerReplicationInfo(P.PlayerReplicationInfo).bHasFlag=false;
		HasFlag=true;
	}

	if ((TFBRI(p.PlayerReplicationInfo)!=None) && (TFBRI(P.PlayerReplicationInfo).bHasFlag) && (bChangeTeam))
	{
		TFBRI(P.PlayerReplicationInfo).bHasFlag=false;
		HasFlag=true;
	}

	if ((bDie) || (HasFlag))
    {
		P.TakeDamage(500000,None,P.Location,vect(0,0,0),'ChangedTeam');
		if (HasFlag)
        {
			if (SFF.Carrier==P) SFF.Carrier=None;
			if (TF.Carrier==P) TF.Carrier=None;
			P.PlayerReplicationInfo.HasFlag=None;
            DropFlag(1-P.PlayerReplicationInfo.Team,P.Location);
            BroadcastLocalizedMessage(class'TFCTFMessage',2,P.PlayerReplicationInfo, None, Teams[1-P.PlayerReplicationInfo.Team] );
			ResetAmbientToPlayer(P);
        }
	}
	else
	{
		if ((bChangeTeam) && (!bNoWeapons))
		{
			DropInventory(P,false);
		}
	}

	if (bChangeTeam)
		ChangeTeam(P,team);

	if ((P.PlayerReplicationInfo.Team==Team) && (Team<3))
	{
		if (num==255)
		{
			if (team==1)
				SetRandomSFModel(P);
			else
				SetRandomTerrModel(P);
		}
		else
			ChangeModel(P, num);

		if ((bChangeTeam) && (P.GetStateName()=='PlayerSpectating'))
			PlayerPawn(P).Fire(0.0);
	}

	if ((!bDie) && (bChangeTeam) && (!bNoWeapons) && (!bNotPlaying))
	{
		GiveTeamWeapons(P);
		if (P.Weapon==None)
			P.SwitchToBestWeapon();
	}
	if (HasFlag) ChangeModel(P,num);
}

/*event InitGame(string Options,out string Error)
{
	Super.InitGame(Options,Error);
}*/

final function TFPlayerJoined(s_Player P)
{
	if (Level.NetMode==NM_Standalone)
	{
		while ((RemainingBots>0) && AddBot())
			RemainingBots--;

		TOResetGame();
	}
	else
		RemainingBots=0;

	if (GamePeriod==GP_PreRound )
		P.GotoState('PreRound');
	else
		P.GotoState('PlayerWalking');

	SetPlayerStartPoint(P);
	AddDefaultInventory(P);
}

// New GiveBomb function
// To do not give it
function GiveBomb()
{
	bBombGiven=true;
	return;
}

function Bot SpawnBot(out NavigationPoint StartSpot)
{
	local bot NewBot;
	local int BotN;
	local Pawn P;

	Difficulty=BotConfig.Difficulty;

	if (Difficulty>=4)
	{
		bNoviceMode=false;
		Difficulty=Difficulty-4;
	}
	else
	{
		if (Difficulty>3)
		{
			Difficulty=3;
			bThreePlus=true;
		}
		bNoviceMode=true;
	}
	BotN=1;

	StartSpot=FindPlayerStart(None,255);
	if (StartSpot==None)
	{
		log("Could not find starting spot for Bot");
		return None;
	}

	NewBot = Spawn(class'TFBot',,,StartSpot.Location,StartSpot.Rotation);

	if (NewBot==None)
		log("Couldn't spawn player at "$StartSpot);

	if (NewBot!=None)
	{
		NewBot.PlayerReplicationInfo.PlayerID=CurrentID++;
		NewBot.PlayerReplicationInfo.Team=BotConfig.GetBotTeam(BotN);
		BotConfig.CHIndividualize(NewBot,NumBots,NumBots);
		NewBot.ViewRotation=StartSpot.Rotation;
		BroadcastMessage(NewBot.PlayerReplicationInfo.PlayerName$EnteredMessage,false);

		ModifyBehaviour(NewBot);
		AddDefaultInventory(NewBot);
		NumBots++;
		if ((bRequireReady) && (CountDown>0))
			NewBot.GotoState('Dying','WaitingForStart');
		NewBot.AirControl=AirControl;

		if ((Level.NetMode!=NM_Standalone) && ((bNetReady) || (bRequireReady)))
		{
			for (P=Level.PawnList;P!=None;P=P.NextPawn)
				if ((P.bIsPlayer) && (P.PlayerReplicationInfo!=None) && (P.PlayerReplicationInfo.bWaitingPlayer) && (P.IsA('PlayerPawn')))
				{
					if (NewBot.bIsMultiSkinned)
						PlayerPawn(P).ClientReplicateSkins(NewBot.MultiSkins[0],NewBot.MultiSkins[1],NewBot.MultiSkins[2],NewBot.MultiSkins[3]);
					else
						PlayerPawn(P).ClientReplicateSkins(NewBot.Skin);
				}
		}
	}
	return NewBot;
}

function TOResetGame()
{
    super.TOResetGame();
    currentscore=0;
    ResetFlagCarrier();
    FlagsToHome();
}

function Timer()
{
    local Pawn P;

    for (P=Level.PawnList;P!=None;P=P.NextPawn)
    {
        if ((P.IsA('TFPlayer')) && (!P.PlayerReplicationInfo.bWaitingPlayer))
            if (TFPlayer(P).CptIAR>0)
            {
//                if (bShowEffectInvulnerable) Spawn(class'UTTeleportEffect',,,P.Location,P.Rotation);
                TFPlayer(P).CptIAR--;
            }
        if (P.IsA('TFBot'))
            if (TFBot(P).CptIAR>0)
            {
                TFBot(P).CptIAR--;
//                if (bShowEffectInvulnerable) Spawn(class'UTTeleportEffect',,,P.Location,P.Rotation);
                if (TFBot(P).CptIAR==0) P.GotoState('Roaming');
            }
    }
    super.Timer();

//	s_GameReplicationInfo(GameReplicationInfo).RoundDuration=99*60;
	RoundStarted=0;

	if (bPlayTimeAnnouncer) CheckAnnouncer();

	if ((TimeLimit>0) && (RemainingTime<=0) && (ScorePerRound==0) && (GamePeriod!=GP_PostRound))
	{
		GamePeriod=GP_PostRound;
		Super(GameInfo).EndGame("Time Limit");
		return;
	}
}

function CheckAnnouncer()
{
    local TFGameReplicationInfo TFGRI;

    TFGRI=TFGameReplicationInfo(GameReplicationInfo);
    if (TFGRI==None) return;
    if (TFGRI.RemainingTime==300) PlayTimeRemaining(Sound'Announcer.cd5min');
    if (TFGRI.RemainingTime==180) PlayTimeRemaining(Sound'Announcer.cd3min');
    if (TFGRI.RemainingTime==60) PlayTimeRemaining(Sound'Announcer.cd1min');
    if (TFGRI.RemainingTime==10) PlayTimeRemaining(Sound'Announcer.cd10');
    if (TFGRI.RemainingTime==9) PlayTimeRemaining(Sound'Announcer.cd9');
    if (TFGRI.RemainingTime==8) PlayTimeRemaining(Sound'Announcer.cd8');
    if (TFGRI.RemainingTime==7) PlayTimeRemaining(Sound'Announcer.cd7');
    if (TFGRI.RemainingTime==6) PlayTimeRemaining(Sound'Announcer.cd6');
    if (TFGRI.RemainingTime==5) PlayTimeRemaining(Sound'Announcer.cd5');
    if (TFGRI.RemainingTime==4) PlayTimeRemaining(Sound'Announcer.cd4');
    if (TFGRI.RemainingTime==3) PlayTimeRemaining(Sound'Announcer.cd3');
    if (TFGRI.RemainingTime==2) PlayTimeRemaining(Sound'Announcer.cd2');
    if (TFGRI.RemainingTime==1) PlayTimeRemaining(Sound'Announcer.cd1');
}

function PlayTimeRemaining(sound snd)
{
    local TFPlayer P;

    foreach AllActors(class'TFPlayer',P)
        P.ClientPlaySound(snd,true,true);
}

function BeginRound()
{
	local s_NPCHostage s;
    local TO_ConsoleTimer C;
    local s_OICW o;

    super.BeginRound();
	foreach AllActors(class's_NPCHostage',s)
		s.Destroy();
	foreach AllActors(class'TO_ConsoleTimer',c)
	{
		c.bActive=false;
//		bBeingActivated=true;
	}
	foreach AllActors(class's_OICW',o)
		o.Destroy();
}

function bool OldRestartPlayer( pawn aPlayer )
{
	local NavigationPoint startSpot;
	local bool						foundStart;
	local int							check, i;
	local	s_Player				P;

	P = s_Player(aPlayer);

	// Don't restart waiting players
	if ( (P != None) && P.PlayerReplicationInfo.bWaitingPlayer )
		return false;

	// Checking if player is dead
/*	if ( aPlayer.IsA('s_Bot') )
		check = int(s_Bot(aPlayer).bNotPlaying);
	else if ( P != None )
		check = int(P.bNotPlaying);
	else
		check = -1;*/

/*	if ( check == 1 )
	{
		// Player just died, send to spectating

		if ( aPlayer.IsA('s_Bot') )
		{
			aPlayer.PlayerReplicationInfo.bIsSpectator = true;
			aPlayer.GotoState('GameEnded');
			aPlayer.bAlwaysRelevant = false;
			return false; // bots don't respawn when ghosts
		}
		else if ( P != None )
		{
			//P.TOStandUp(true);
			//P.bHidden = true;
			//P.SetCollision( false, false, false );
			P.PlayerRestartState = 'PlayerSpectating';

			return true;
		}
	}
	else if ( check == 0 )
	{  */
		// Restart to play

		aPlayer.Acceleration = vect(0,0,0);
		aPlayer.Velocity = vect(0,0,0);

		if ( P != None )
		{
			P.TOStandUp(true);
			P.SetBlindTime(0.0);
		}

		aPlayer.bAlwaysRelevant = true;
		aPlayer.bHidden = false;
		aPlayer.SoundDampening = aPlayer.Default.SoundDampening;

		//see if this fixes the sunken into the ground problem on start
		aPlayer.SetPhysics(PHYS_Walking);

		if (aPlayer.IsA('s_Bot')) addDefaultInventory(aPlayer);

		while ( !foundStart )
		{
			i++;
			if (i>50)
				break;

			startSpot = FindPlayerStart(aPlayer, aPlayer.PlayerReplicationInfo.Team);
			if ( startSpot == None )
			{
				log("TO_GameBasics::RestartPlayer - Player start not found!!! Add more player starts in your map!!");
				break;
			}

			foundStart = aPlayer.SetLocation(startSpot.Location+Vect(0,0,10.0));
			if ( !foundStart )
				log(startspot$" Player start not useable!!!");
		}

		aPlayer.ClientSetLocation(startSpot.Location+Vect(0,0,10.0), startSpot.Rotation );
		aPlayer.ClientSetRotation(startSpot.Rotation);
		aPlayer.SetRotation(startSpot.Rotation);
		aPlayer.ViewRotation = aPlayer.Rotation;

		aPlayer.SetCollisionSize(aPlayer.Default.CollisionRadius, aPlayer.Default.CollisionHeight);
		aPlayer.SetCollision( true, true, true );
		aPlayer.DamageScaling = aPlayer.Default.DamageScaling;
		aPlayer.PlayerReplicationInfo.bIsSpectator = false;
		aPlayer.PlayerReplicationInfo.bWaitingPlayer = false;
//		aPlayer.Health = 100;
		return foundStart;
//	}
}

function bool RestartPlayer(pawn aPlayer)
{
    local bool retour;

	retour=OldRestartPlayer(aPlayer);

	if (retour)
	{
        if (aPlayer!=None)
        {
            if (TFPlayer(aPlayer)!=None)
            {
                if ((TFPlayer(aPlayer).bAutoBuyArmor) && (TFPlayer(aPlayer).Money>900)) BuyArmor(aPlayer);
                TFPlayer(aPlayer).CptIAR=SecGodMod;
			    RestartToPlay(aPlayer);
			    if (bShowEffectInvulnerable) GiveShieldEffect(aPlayer);
			    TFPlayer(aPlayer).GotoState('PlayerWalking');
		    }
		    if (TFBot(aPlayer)!=None)
		    {
                TFBot(aPlayer).CptIAR=SecGodMod;
                TFBot(aPlayer).BlindTime=0.0;
			    RestartToPlay(aPlayer);
			    if (bShowEffectInvulnerable) GiveShieldEffect(aPlayer);
			    TFBot(aPlayer).GotoState('BotBuying');
		    }
		}
		return true;
	} else return false;
}

function BuyArmor(Pawn P)
{
    s_Player(P).money=s_Player(P).Money-900;
    s_Player(P).VestCharge=100;
	s_Player(P).HelmetCharge=100;
    s_Player(P).LegsCharge=100;
}

function GiveShieldEffect(Pawn aPlayer)
{
    local TFShieldEffect tms;

    tms=Spawn(class'TFShieldEffect',aPlayer,,aPlayer.Location,aPlayer.Rotation);
    tms.Mesh=aPlayer.Mesh;
    tms.DrawScale=aPlayer.DrawScale;
    tms.ScaleGlow=1;
/*    if (aPlayer.PlayerReplicationInfo.Team==0) tms.texture=FireTexture'UnrealShare.Belt_fx.ShieldBelt.RedShield';
    else tms.texture=FireTexture'UnrealShare.Belt_fx.ShieldBelt.BlueShield';*/
    if (aPlayer.PlayerReplicationInfo.Team==0) tms.texture=Texture'UnrealShare.Belt_fx.ShieldBelt.newRed';
    else tms.texture=Texture'UnrealShare.Belt_fx.ShieldBelt.newBlue';
}

function RestartToplay(Pawn aPlayer)
{
	aPlayer.PlayerReplicationInfo.bIsSpectator=false;
	aPlayer.PlayerReplicationInfo.bWaitingPlayer=false;
	aPlayer.Acceleration=vect(0,0,0);
	aPlayer.Velocity=vect(0,0,0);
	if (TFPlayer(aPlayer)!=None)
		TFPlayer(aPlayer).TOStandUp(true);
	aPlayer.SetCollisionSize(aPlayer.Default.CollisionRadius,aPlayer.Default.CollisionHeight);
	aPlayer.SetCollision(true,true,true);
	aPlayer.bAlwaysRelevant=true;
	aPlayer.bHidden=false;
	aPlayer.bBehindView=false;
	aPlayer.DamageScaling=aPlayer.Default.DamageScaling;
	aPlayer.SoundDampening=aPlayer.Default.SoundDampening;
	aPlayer.SetPhysics(PHYS_Walking);
	aPlayer.Health=100;
	addDefaultInventory(aPlayer);
	if (bRemoveCarcass)
	{
	   if ((TFPlayer(aPlayer)!=None) && (TFPlayer(aPlayer).carc!=none)) TFPlayer(aPlayer).carc.destroy();
	   if ((TFBot(aPlayer)!=None) && (TFBot(aPlayer).carc!=none)) TFBot(aPlayer).carc.destroy();
	}
}

function ReBalance()
{
	local int big,small,i,bigsize,smallsize;
	local Pawn P,A;
	local Bot B;

	if ((bBalancing) || (NumBots==0) || (!bBalanceTeams))
		return;

	big=0;
	small=0;
	bigsize=Teams[0].Size;
	smallsize=Teams[0].Size;
	for (i=1;i<2;i++)
	{
		if (Teams[i].Size>bigsize)
		{
			big=i;
			bigsize=Teams[i].Size;
		}
		else if (Teams[i].Size<smallsize)
		{
			small=i;
			smallsize=Teams[i].Size;
		}
	}

	bBalancing=true;
	while (bigsize-smallsize>1)
	{
		for (P=Level.PawnList;P!=None;P=P.NextPawn)
			if ((P.bIsPlayer) && (P.PlayerReplicationInfo!=None) && (P.PlayerReplicationInfo.Team==big)
				&& (P.IsA('Bot')))
			{
				B=Bot(P);
				break;

			}
		if (B!=None)
		{
			B.Health=0;
			B.Died(None,'Suicided',B.Location);
			bigsize--;
			smallsize++;
			ChangeTeam(B,small);
		}
		else
			Break;
	}
	bBalancing=false;

	// re-assign orders to follower bots with no leaders
	for (P=Level.PawnList;P!=None;P=P.NextPawn)
		if ((P.bIsPlayer) && (P.IsA('Bot')) && (BotReplicationInfo(P.PlayerReplicationInfo)!=None) && (BotReplicationInfo(P.PlayerReplicationInfo).RealOrders=='Follow'))
		{
			A=Pawn(Bot(P).OrderObject);
			if ((A==None) || (A.bDeleteMe) || (!A.bIsPlayer) || (A.PlayerReplicationInfo.Team!=P.PlayerReplicationInfo.Team))
			{
				Bot(P).OrderObject=None;
				SetBotOrders(Bot(P));
			}
		}

}

function bool FindSpecialAttractionFor(Bot aBot)
{
	local		Actor									Nav, Best;
	local		s_HostageControlPoint	HNav;
	local		int										BestScore, Score;
	local		float									Dist;
	local		s_Bot									B;

	//return false;

	B = s_Bot(aBot);

	// Don't call this to often
	if ( aBot==None || (aBot.LastAttractCheck > Level.TimeSeconds) || (B == None) || (GamePeriod != GP_RoundPlaying) )
		return false;

    // TO CTF special
/*    if ((TFBRI(B.PlayerReplicationInfo)!=None) && (TFBRI(B.PlayerReplicationInfo).bHasFlag))
    {
        if (B.PlayerReplicationInfo.Team==0)
        {
				ResetBotObjective(B, 0.0);
                B.Orders='O_GotoLocation';
	            B.OrderObject=TFHomeBase;
        }
        else
        {
				ResetBotObjective(B, 0.0);
                B.Orders='O_GotoLocation';
	            B.OrderObject=SFHomeBase;
        }
        return true;
    }
    // End special TO CTF
  */
	if ( B.IsInState('BotBuying') )
		return false;

	aBot.LastAttractCheck = Level.TimeSeconds/* + 1.5*/;
	//log("s_SWATGame::FindSpecialAttractionFor - "@B.GetHumanName()@"- S:"@B.GetStateName()@"- O:"@B.Objective);

	// Check if bot needs ammo
	if ( (B.Objective != 'O_FindClosestBuyPoint')
		&& (B.Weapon != None) && (s_Weapon(B.Weapon) != None) && (s_Weapon(B.Weapon).bUseClip) && (B.bNeedAmmo) )
	{
		if (B.Money > 100)
		{
			// No more ammo
			Best = FindBuyPoint(B);
			if (Best != None)
			{
				//log("Check if bot needs ammo");
				ResetBotObjective(B, 0.0);
				B.Objective = 'O_FindClosestBuyPoint';
				B.OrderObject = FindBuyPoint(B);
				return true;
			}
			else
				B.bNeedAmmo = false;
		}
		else
			B.bNeedAmmo = false;
	}


	// If bot supports another one, then do so
	if (aBot.Orders == 'Follow')
	{
		// Checking if leader is dead
		if ( (B.OrderObject != None && B.OrderObject.IsA('s_Player') && s_Player(B.OrderObject).bNotPlaying)
		|| (B.OrderObject != None && B.OrderObject.IsA('s_Bot') && s_Bot(B.OrderObject).bNotPlaying) )
		{
			//log("FindSpecialAttractionFor - Leader is dead - Follow - Now go to Freelance !");
			ResetBotObjective(B, 1.0);
			return false;
		}
		return false;
	}

    // Special TO CTF
/*	if (B.Orders == 'Attack')
	{
	   if (B.Enemy==None)
	   {
	       if (B.PlayerReplicationInfo.Team==0)
	       {
	           if (SFF.Carrier!=None)
	           {
				ResetBotObjective(B, 0.0);
	               B.Orders='Follow';
	               B.OrderObject=SFF.Carrier;
	               return true;
	           }
	           else
	           {
				ResetBotObjective(B, 0.0);
                B.Orders='O_GotoLocation';
	            B.OrderObject=SFHomeBase;
	            return true;
	           }
	       }
	       else
	       {
	           if (TF.Carrier!=None)
	           {
				ResetBotObjective(B, 0.0);
	               B.Orders='Follow';
	               B.OrderObject=TF.Carrier;
	               return true;
	           }
	           else
	           {
				ResetBotObjective(B, 0.0);
                B.Orders='O_GotoLocation';
	            B.OrderObject=TFHomeBase;
	            return true;
	           }
	       }
	   }
	}          */
     // End Special TO CTF

	// Assign new objective to bot !
	if ( (aBot.Orders == '') || ((B.Objective == 'O_DoNothing') && (aBot.Orders == 'Freelance')) )
	{
		//log("calling SetNextObjective ! "$B);
		TFSetNextObjective(B);
		if ( B.Objective != 'O_DoNothing' )
			SpecialObjectiveHandling(B);
	}

	if ( B.Objective == 'O_DoNothing' /*&& B.OrderObject == None*/)
	{
		//if (B.MoveTarget == None && aBot.Orders != 'Freelance')
		//	ResetBotObjective(B, 0.0);
		return false;
	}

	Best = B.OrderObject;

	// Huge Objective list...
	switch (B.Objective)
	{
		// O_GoHome
		case 'O_GoHome' :
			if (aBot.OrderObject != None && aBot.OrderObject.IsA('s_SWATPathNode'))
			{
				if ( NavigateSWATPathNode(B, s_SWATPathNode(aBot.OrderObject), Best) )
					Best = FindHomeBase(B);
			}
			else if (aBot.OrderObject != None && aBot.OrderObject.IsA('s_ZoneControlPoint'))
			{
				if ( NavigateActor(B, aBot.OrderObject, Best) )
				{
					// Objective accomplished
					if ((B.PlayerReplicationInfo!=None) && (IsOrderObjective(B.PlayerReplicationInfo.Team, B.O_number)))
						SetAccomplishedObjective(B.PlayerReplicationInfo.Team, B.O_number);

					//log("O_GoHome - Objective accomplished");
					ResetBotObjective(B, 1.0);
					return false;
				}
			}
			else if (aBot.OrderObject == None)
			{
				Best = FindSWATPathNode(B);
				if (Best == None)
					Best = FindHomeBase(B);
			}
			break;

		// O_AssaultEnemy
		case 'O_AssaultEnemy' :
			if (aBot.OrderObject != None && aBot.OrderObject.IsA('s_SWATPathNode'))
			{
				if ( NavigateSWATPathNode(B, s_SWATPathNode(aBot.OrderObject), Best) )
					Best = FindEnemyBase(B);
			}
			else if (aBot.OrderObject != None && aBot.OrderObject.IsA('s_ZoneControlPoint'))
			{
				if ( NavigateActor(B, aBot.OrderObject, Best) )
				{
					// Objective accomplished
					if ((B.PlayerReplicationInfo!=None) && (IsOrderObjective(B.PlayerReplicationInfo.Team, B.O_number)))
						SetAccomplishedObjective(B.PlayerReplicationInfo.Team, B.O_number);

					//log("O_AssaultEnemy - Objective accomplished");
					ResetBotObjective(B, 2.0);
					return false;
				}
			}
			else if (aBot.OrderObject == None)
			{
				Best = FindSWATPathNode(B);
				if (Best == None)
					Best = FindEnemyBase(B);
			}
			break;

		// O_FindClosestBuyPoint
		case 'O_FindClosestBuyPoint' :
			if (aBot.OrderObject != None && aBot.OrderObject.IsA('s_SWATPathNode'))
			{
				if ( NavigateSWATPathNode(B, s_SWATPathNode(aBot.OrderObject), Best) )
					Best = FindBuyPoint(B);
			}
			else if (aBot.OrderObject != None && aBot.OrderObject.IsA('s_ZoneControlPoint'))
			{
				if ( NavigateActor(B, aBot.OrderObject, Best) )
				{
					// Objective accomplished
					if ((B.PlayerReplicationInfo!=None) && (IsOrderObjective(B.PlayerReplicationInfo.Team, B.O_number)))
						SetAccomplishedObjective(B.PlayerReplicationInfo.Team, B.O_number);

					//log("O_FindClosestBuyPoint - Objective accomplished");
					ResetBotObjective(B, 1.0);
					B.LetsGetLoaded();
					return true;
				}
			}
			else if (aBot.OrderObject == None)
			{
				Best = FindSWATPathNode(B);
				if (Best == None)
					Best = FindBuyPoint(B);
			}
			break;

		// O_GotoLocation
		case 'O_GotoLocation' :
			if (aBot.OrderObject != None && aBot.OrderObject.IsA('s_SWATPathNode'))
			{
				if ( NavigateSWATPathNode(B, s_SWATPathNode(aBot.OrderObject), Best) )
				{
					//log("O_GotoLocation - last path node reached !");
					// Objective accomplished
					if ((B.PlayerReplicationInfo!=None) && (IsOrderObjective(B.PlayerReplicationInfo.Team, B.O_number)))
						SetAccomplishedObjective(B.PlayerReplicationInfo.Team, B.O_number);

					//log("O_GotoLocation - Objective accomplished");
					ResetBotObjective(B, 1.0);
					return false;
				}
			}
			else if (aBot.OrderObject == None)
				// Try to find PathNode
				Best = FindSWATPathNode(B);
			else
			{ // Goto Target location
				if ( NavigateActor(B, aBot.OrderObject, Best) )
				{
					// Objective accomplished
					if ((B.PlayerReplicationInfo!=None) && (IsOrderObjective(B.PlayerReplicationInfo.Team, B.O_number)))
						SetAccomplishedObjective(B.PlayerReplicationInfo.Team, B.O_number);

					//log("O_GotoLocation - Target Objective accomplished");
					ResetBotObjective(B, 1.0);
					return false;
				}
			}
				// Goto Target location
				//Best = aBot.OrderObject;
			break;

		// O_TriggerTarget
		case 'O_TriggerTarget' :
			if (aBot.OrderObject != None && aBot.OrderObject.IsA('s_SWATPathNode'))
			{
				if ( NavigateSWATPathNode(B, s_SWATPathNode(aBot.OrderObject), Best) )
				{
					if (B.O_number == 255)
					{
						//log("O_TriggerTarget - Target pathnode");
						ResetBotObjective(B, 1.0);
						return false;
					}
					else if ((B.PlayerReplicationInfo!=None) && (SI.GetTeamObjectivePriv(B.PlayerReplicationInfo.Team, B.O_number).ActorTarget.IsA('Triggers')))
						Best = SI.GetTeamObjectivePriv(B.PlayerReplicationInfo.Team, B.O_number).ActorTarget;
				}
			}
			else if (aBot.OrderObject == None)
				// Try to find PathNode
				Best = FindSWATPathNode(s_Bot(aBot));
			else
			{ // Goto Target location
				if ( NavigateActor(B, aBot.OrderObject, Best) )
				{
					if (aBot.OrderObject.IsA('s_Trigger'))
					{
						if (s_Trigger(aBot.OrderObject).TriggerType == TT_Use)
						{
							//log("O_TriggerTarget - s_Trigger Use "$B);
							s_Trigger(aBot.OrderObject).Use(aBot);

							// Objective accomplished
							// Coded in s_Trigger
							ResetBotObjective(B, 1.0);
							return false;
						}
						else if (Dist < 60)
						{
							//log("O_TriggerTarget - s_Trigger - Close enough "$B);
							ResetBotObjective(B, 0.0);
							return false;
						}
						else
							// Goto Target location
							Best = aBot.OrderObject;
					}
					else if (Dist < 60)
					{
						//log("O_TriggerTarget - Trigger - Close enough "$B);
						ResetBotObjective(B, 1.0);
						return false;
					}
					else
						// Goto Target location
						Best = aBot.OrderObject;
				}
			}
			break;



	}


	// Checking if destination is reachable
	if ( Best != None )
	{
		if (BotReplicationInfo(aBot.PlayerReplicationInfo)!=None) BotReplicationInfo(aBot.PlayerReplicationInfo).OrderObject = None;
		aBot.OrderObject = Best;
		if ( VSize(Best.Location - aBot.Location) < (DistReachThreshold / 2.0) )
		{
			aBot.OrderObject.Touch(aBot);
			aBot.OrderObject = None;
			return false;
		}
		else if ( aBot.ActorReachable(Best) )
			aBot.MoveTarget = Best;
		else
			aBot.MoveTarget = aBot.FindPathToward(Best);

		if ( aBot.MoveTarget != None )
		{
			if ( aBot.bVerbose )
				log(aBot$" moving toward "$Best$" using "$aBot.MoveTarget);

			SetAttractionStateFor(aBot);
			return true;
		}
		else
		{
			//log("s_SWATGame::FindSpecialAttractionFor - MoveTarget == None, resetting bot: "$B.GetHumanName()$" O:"$B.Objective$" I:"$B.O_number$" T:"$B.PlayerReplicationInfo.Team$" E:"$B.Enemy$" O:"$B.Orders);
			B.bNeedAmmo = false;
			ResetBotObjective(B, 2.0);
		}
	}
	else
	{
		// maybe for bot to camp or go to random location.
		//log("s_SWATGame::FindSpecialAttractionFor -"@B.GetHumanName()@"- Best == None");
		if ( (B.Objective != 'O_DoNothing') || (B.MoveTarget != None) )
		{
			//log("s_SWATGame::FindSpecialAttractionFor - Best == None, resetting bot "$B.GetHumanName()$" O:"$B.Objective$" I:"$B.O_number$" T:"$B.PlayerReplicationInfo.Team$" E:"$B.Enemy$" O:"$B.Orders);
			ResetBotObjective(B, 2.0);
		}
	}


	return false;
}

final function TFSetNextObjective(s_Bot B)
{
	// Set Objectives to bots, based on Objectives' priorities
	local	byte			i, Team, numsupport, numleaders, numbots;
	local	s_Bot			Bl, BBot, BBotL;
	local	s_Bot			bot;
	local	float			Score, BestScore;
	local	s_Player	P, BP;
	local	bool			bTooManyLeaders;
	local	Pawn			PawnLink;

	//log("SetNextObjective - B.State - "$B.GetStateName());

	if ( (B.PlayerReplicationInfo == None) || (GamePeriod != GP_RoundPlaying) || B.bDoNotDisturb )
		return;

	if ( !TFCanAcceptObjective(B) )
		return;

	bTooManyLeaders = false;

	// Count leaders
	for ( PawnLink=Level.PawnList; PawnLink!=None; PawnLink=PawnLink.nextPawn )
	{
		BBotL = s_Bot(PawnLink);
		if (BBotL != None)
		{
			i++;
			if (i > 50)
				break;
			if (BBotL.PlayerReplicationInfo.Team == B.PlayerReplicationInfo.Team && !BBotL.bNotPlaying)
			{
				numbots++;
				if (BBotL.Orders == 'Freelance')
				{
					if (BBotL != B)
					{
						Score = FRand() * 100 + BBotL.Health * 100 + BBotL.Skill * 100;
						if (Score > BestScore)
							BBot = BBotL;
					}
					if (BBotL.Objective != 'O_DoNothing')
						numleaders++;
				}
				else if (BBotL.Orders == 'Follow')
					numsupport++;
			}
		}
	}

	if ( numleaders > (numbots * SI.LeaderThreshold) )
		bTooManyLeaders = true;

	// Do OrderObjectives first
	Team = B.PlayerReplicationInfo.Team;
	i = 0;
	while ( i < 10 )
	{
		if ( !IsNullObjective(Team, i) )
		{
			// Check leaders
			if ( SI.GetTeamObjectivePriv(Team, i).Leader != None )
			{
				// Check if leader is still on the objective
				bot = s_Bot(SI.GetTeamObjectivePriv(Team, i).Leader);

				if ( !Bot.bNotPlaying && (Bot.O_number != i) && ((Bot.LastObjective == '') || (Bot.LastO_number != i)) )
				{
					//log("s_SWATGame::SetNextObjective - resetting leader:"@Bot.GetHumanName()@"-O:"@Bot.O_number@"-O:"@Bot.Objective);

					// Reset Objective leader
					if ( Team == 1 )
						SI.SF_ObjectivesPriv[i].Leader = None;
					else
						SI.Terr_ObjectivesPriv[i].Leader = None;

					ResetBotObjective(bot, 2.0);
				}
				else if ( Bot.bNotPlaying || (Bot.PlayerReplicationInfo.Team != Team) )
				{
					// Reset Objective leader
					if (Team == 1)
						SI.SF_ObjectivesPriv[i].Leader = None;
					else
						SI.Terr_ObjectivesPriv[i].Leader = None;
				}
				else
				{
					// Still active objective leaders
					Score = FRand();
					if (Score > BestScore)
						Bl = s_Bot(SI.GetTeamObjectivePriv(Team, i).Leader);
				}
			}

			// If too many team leaders, continue and go to support
			if ( bTooManyLeaders && !TFDoesBotLead(B) )
			{
				i++;
				continue;
			}

			if ( !IsObjectiveAccomplished(Team, i) )
			{
				if (IsOrderObjective(Team, i) && CheckOrder(Team, i))
				{
					if (IsOnceObjective(Team, i) && SI.GetTeamObjectivePriv(Team, i).Leader == None)
					{ // Send bot to OnceOrder Objective
						SI.SetObjectiveLeader(Team, i, B);
						B.Objective = SI.GetTeamObjectiveName(Team, i);
						B.OrderObject = SI.GetTeamObjectivePriv(Team, i).ActorTarget;
						B.O_number = i;
						//log("assigned OnceOrder objective to: "$B$" - Objective: "$B.Objective$" - OrderObject: "$B.OrderObject$" - O_number: "$B.O_number);
						return;
					}
					if (!IsOnceObjective(Team, i) && (FRand() < 0.5))
					{ // Send bot to AlwaysOrder Objective
						//SI.SetObjectiveLeader(Team, i, B);
						B.Objective = SI.GetTeamObjectiveName(Team, i);
						B.OrderObject = SI.GetTeamObjectivePriv(Team, i).ActorTarget;
						B.O_number = i;
						//log("assigned AlwaysOrder objective to: "$B$" - Objective: "$B.Objective$" - OrderObject: "$B.OrderObject$" - O_number: "$B.O_number);
						return;
					}
				}
				if (!IsOrderObjective(Team, i))
				{
					if (IsOnceObjective(Team, i) && SI.GetTeamObjectivePriv(Team, i).Leader == None)
					{ // Send bot to Once Objective
						SI.SetObjectiveLeader(Team, i, B);
						B.Objective = SI.GetTeamObjectiveName(Team, i);
						B.OrderObject = SI.GetTeamObjectivePriv(Team, i).ActorTarget;
						B.O_number = i;
						//log("assigned Once objective to: "$B$" - Objective: "$B.Objective$" - OrderObject: "$B.OrderObject$" - O_number: "$B.O_number);
						return;
					}
					if (!IsOnceObjective(Team, i) && (FRand() < 0.5))
					{ // Send bot to Always Objective
						//SI.SetObjectiveLeader(Team, i, B);
						B.Objective = SI.GetTeamObjectiveName(Team, i);
						B.OrderObject = SI.GetTeamObjectivePriv(Team, i).ActorTarget;
						B.O_number = i;
						//log("assigned Always objective to: "$B$" - Objective: "$B.Objective$" - OrderObject: "$B.OrderObject$" - O_number: "$B.O_number);
						return;
					}
				}
			}
		}
		i++;
	}

	// If bot cannot get any objectives, then support a leader if any
	if ( !TFDoesBotLead(B) )
	{
		BestScore = 0;
		i = 0;

		for ( PawnLink=Level.PawnList; PawnLink!=None; PawnLink=PawnLink.nextPawn )
		{
			i++;
			if (i > 50)
				break;

			P = s_Player(PawnLink);
			if (P != None && P.PlayerReplicationInfo.Team == B.PlayerReplicationInfo.Team && !P.bNotPlaying)
			{
				Score = FRand() * P.Health * P.Skill;
				if (Score > BestScore)
					BP = P;
			}
		}

		if (numsupport < numplayers * 0.66 && FRand() < 0.50)
		{
			//log("SetNextObjective - Sent to Support");
			ResetBotObjective(B, 1.0);

			if (BP != None && FRand() < 0.33)
				B.SetOrders('Follow', BP, true);
			else if (Bl != None && Bl != B && FRand() < 0.33)
				B.SetOrders('Follow', Bl, true);
			else if (BBot != None && FRand() < 0.33)
				B.SetOrders('Follow', BBot, true);

			return;
		}
	}
}

final function bool TFDoesBotLead(s_Bot B)
{
	return false;
}

final function bool TFCanAcceptObjective(s_Bot B)
{
	return true;
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
	Spawn(Class'TFFlags');
	Spawn(Class'TerroFlag');
	Spawn(Class'SFFlag');
	Spawn(Class'TFPlayer');
	Spawn(Class'TFBot');
}

function DiscardInventory(Pawn Other)
{
    if (bKeepInventory) return; else super.DiscardInventory(Other);
}

final function TFKillInventory(Pawn P,optional bool buymenu)
{
	local Inventory Inv,InvTmp;

    if (bKeepInventory) return;
	Inv=P.Inventory;
	While (Inv!=None)
	{
		InvTmp=Inv.Inventory;
		if ((!buymenu) || ((Inv.Class!=class's_SWAT.s_C4') && (Inv.Class!=class's_SWAT.s_OICW')) )
			Inv.Destroy();
		Inv=InvTmp;
	}

	P.Weapon=None;
}

final function TFDropInventory(Pawn Other,bool bDropMoney)
{
	local int Eidx, PezAmount,ammo,clip,backammo,backclip;
	local Inventory Inv, InvTmp;
	local vector X, Y, Z;
	local s_Player P;
	local s_Bot	B;
	local vector DropLocation;
    local string weaponname;

	if (other==none)
		return;

	P=s_Player(Other);
	B=s_Bot(Other);

	Other.GetAxes(Other.Rotation,X,Y,Z);
	DropLocation=Other.Location+1.5*Other.CollisionRadius*X;

    if (bKeepInventory)
    {
        Inv=Other.Inventory;
	    while (Inv!=None)
    	{
	   	    InvTmp=Inv.Inventory;
    	   	if ((Inv.IsA('s_Weapon')) && (!s_Weapon(Inv).IsA('s_Knife')) && ((s_Weapon(Inv)==Other.Weapon) || (Inv.IsA('s_C4')) || (Inv.IsA('s_OICW'))))
	       	{
// give again the weapon he have droped
                if (bKeepInventory)
                {
                    weaponname=string(Other.Weapon.class);
                    ammo=s_weapon(Other.Weapon).clipAmmo;
                    backammo=s_weapon(Other.Weapon).BackupClip;
                    clip=s_weapon(other.weapon).RemainingClip;
                    backclip=s_weapon(other.weapon).BackClipAmmo;
                }
		      	s_Weapon(Inv).Velocity=Vector(Other.ViewRotation)*200*FRand()+vect(1.0,0,500)*FRand();
    			s_Weapon(Inv).bTossedOut=true;
	       		s_Weapon(Inv).DropFrom(DropLocation);
	       		if (bKeepInventory) RegiveWeapon(Other,weaponname,ammo,clip,backammo,backclip);
		    }
		    Inv=InvTmp;
	   }
	}


	TFKillInventory(Other);

	if (P!=None)
	{
		Eidx=P.Eidx;
		while (Eidx>0)
		{
			Eidx--;
			DropEvidence(P.Evidence[Eidx],Other,DropLocation);
			P.Evidence[Eidx]=None;
		}
		P.Eidx=0;

		if (P.bSpecialItem)
		{
			DropSpecialItem(P.SpecialItemClass,Other,DropLocation);
			P.bSpecialItem=false;
		}

		if (!bDropMoney)
			return;

		if (P.Money<2000)
		{
			if (P.Money>50)
			{
				PezAmount=P.Money/2;
				AddMoney(P,-PezAmount);
			}
		}
		else
		{
			PezAmount=1000;
			AddMoney(P,-PezAmount);
		}

		if (PezAmount>0)
			DropMoney(P,PezAmount,DropLocation);


	}
	else if (B!=None)
	{
		Eidx=B.Eidx;
		while (Eidx>0)
		{
			Eidx--;
			DropEvidence(B.Evidence[Eidx],Other,DropLocation);
			B.Evidence[Eidx]=None;
		}
		B.Eidx=0;

		if (B.bSpecialItem)
		{
			DropSpecialItem(B.SpecialItemClass,Other,DropLocation);
			B.bSpecialItem=false;
		}

		if (!bDropMoney)
			return;

		if (B.Money<2000)
		{
			if (B.Money>50)
			{
				PezAmount=B.Money/2;
				AddMoney(Other,-PezAmount);
			}
		}
		else
		{
			PezAmount=1000;
			AddMoney(B,-PezAmount);
		}

		if (PezAmount>0)
			DropMoney(B,PezAmount,DropLocation);
	}
}

function ReGiveWeapon(Pawn PlayerPawn,string aClassName,int ammo,int clip,int backammo,int backclip)
{
	local class<Weapon> WeaponClass;
	local Weapon NewWeapon;

	WeaponClass = class<Weapon>(DynamicLoadObject(aClassName, class'Class'));

	if( PlayerPawn.FindInventoryType(WeaponClass) != None )
		return;
	newWeapon = Spawn(WeaponClass);
	if ( newWeapon != None )
	{
		newWeapon.RespawnTime=0.0;
		newWeapon.GiveTo(PlayerPawn);
		newWeapon.bHeldItem=true;
		newWeapon.GiveAmmo(PlayerPawn);
		newWeapon.SetSwitchPriority(PlayerPawn);
		newWeapon.WeaponSet(PlayerPawn);
		newWeapon.AmbientGlow=0;
		s_weapon(newWeapon).SetRemainingAmmo(clip,ammo,false);
		s_weapon(newWeapon).SetRemainingAmmo(backclip,backammo,true);
		if (PlayerPawn.IsA('PlayerPawn'))
			newWeapon.SetHand(PlayerPawn(PlayerPawn).Handedness);
		else
			newWeapon.GotoState('Idle');
		PlayerPawn.Weapon.GotoState('DownWeapon');
		PlayerPawn.PendingWeapon=None;

		if (PlayerPawn.IsA('s_BPlayer'))
			s_BPlayer(PlayerPawn).LastSelectedWeapon=PlayerPawn.Weapon;

		PlayerPawn.Weapon=newWeapon;
	}
}

defaultproperties
{
	BeaconName="Tactical Flags"
	GameName="Tactical Flags"
	ScorePerRound=0
	AmountForFlagScore=1000
	DoGlowOnFlagCarrier=false
    HUDType=class'TOCTF.TFHUD'
    GameReplicationInfoClass=class'TOCTF.TFGameReplicationInfo'
    bPlayTimeAnnouncer=true
    bShowEffectInvulnerable=true
    SecGodMod=6
    bRemoveCarcass=true
    FixMutatorReplicationBugUT436=true
    bKeepInventory=True
    AmountForKill=1000
    DisableWeapon(20)=1
    DisableWeapon(23)=1
    DisableWeapon(15)=1
}

