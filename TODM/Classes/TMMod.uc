class TMMod extends s_SWATGame;

#EXEC AUDIO IMPORT NAME=FirstBloodSound FILE=Sounds/firstblood.wav

var() config int ScorePerRound;
var int NbCandidate;
var() config int AmountForFrag;
var NavigationPoint Candidate[255];
var() config bool bKeepInventory;
var() config bool bPlayTimeAnnouncer;
var() config bool bShowEffectInvulnerable;
var() config byte SecGodMod;
var() config bool bRemoveCarcass;
var() config bool FixMutatorReplicationBugUT436;
var() config byte DisableWeapon[32];

function BuyArmor(Pawn P)
{
    s_Player(P).money=s_Player(P).Money-900;
    s_Player(P).VestCharge=100;
	s_Player(P).HelmetCharge=100;
    s_Player(P).LegsCharge=100;
}

function PreBeginPlay()
{
	Super.PrebeginPlay();
	SetNewInventory();
}

function SetNewInventory()
{
    local byte i;

    for (i=0;i<32;i++)
        if (DisableWeapon[i]==1) class'TO_WeaponsHandler'.Default.WeaponTeam[i]=WT_None;
}

function string GetRules()
{
    local string a;

	a=Super.GetRules();
	if ((EnabledMutators!="") && (FixMutatorReplicationBugUT436))
		a=a$"\\mutators\\"$EnabledMutators;
	return a;
}

/*function SendMessageTOAllPlayers(string msg)
{
	local TMPlayer P;

	foreach AllActors(class'TMPlayer',P)
	{
		P.ClearProgressMessages();
		P.SetProgressTime(4);
		P.SetProgressMessage(Msg,0);
	}
}*/

function RestartRound()
{
	local TMPlayer P;
	local TMBot B;

	Super.RestartRound();

	foreach AllActors(class'TMPlayer',P)
	{
		if ((P!=None) && (TMPRI(P.PlayerReplicationInfo)!=None))
			TMPRI(P.PlayerReplicationInfo).CurrentScore=0;
	}

	foreach AllActors(class'TMBot',B)
	{
		if ((B!=None) && (TMBRI(B.PlayerReplicationInfo)!=None))
			TMBRI(B.PlayerReplicationInfo).CurrentScore=0;
	}
}

function CheckEndGame()
{
//	Super.CheckEndGame();
}

function PlayerPawn Login(string Portal,string Options,out string Error,Class<PlayerPawn> SpawnClass)
{
	local PlayerPawn NewPlayer;
	local NavigationPoint StartSpot;
	local string InFace;
	local string InPassword;
	local string InSkin;
	local byte InTeam;
    local byte i;

	SpawnClass=Class'TMPlayer';
	bRequireReady=False;
	NewPlayer=Super(TO_DeathMatchPlus).Login(Portal,Options,Error,SpawnClass);
	if (NewPlayer==None)
	{
		Error="Couldn't spawn player.";
		return None;
	}
        for (i=0;i<32;i++)
            TMPlayer(NewPlayer).DisableWeapon[i]=DisableWeapon[i];

	if (Left(NewPlayer.PlayerReplicationInfo.PlayerName,6)==DefaultPlayerName)
	{
		if (Level.Game.WorldLog!=None)
			Level.Game.WorldLog.LogSpecialEvent("forced_name_change",NewPlayer.PlayerReplicationInfo.PlayerName,string(NewPlayer.PlayerReplicationInfo.PlayerID),DefaultPlayerName $ string(NumPlayers));
		ChangeName(NewPlayer,DefaultPlayerName $ string(NumPlayers),False);
	}
	NewPlayer.bAutoActivate=True;
	TMPlayer(NewPlayer).CptIAR=SecGodMod;
	NewPlayer.GameReplicationInfo=GameReplicationInfo;
	PlayerTeamNum=NewPlayer.PlayerReplicationInfo.Team;
	return NewPlayer;
}

function Killed(pawn Killer,pawn Other,name damageType)
{
	local Pawn PawnLink;
	local TMPlayer P;
	local s_Bot B;
	local s_NPCHostage H;
	local PlayerReplicationInfo VictimPRI, KillerPRI;
	local bool oldbfirstkill;

	oldbfirstkill=bFirstKill;
	if ((killer!=none) && (Other!=none))
		if ((Killer.PlayerReplicationInfo.Team==Other.PlayerReplicationInfo.Team) && (Killer.isA('s_Player')) && (Other.isA('s_Player')))
		{
			s_Player(Other).KillerID=Killer.PlayerReplicationInfo.PlayerID;
			s_Player(Other).KillTime=Level.Timeseconds;
		}

	LogKillStats(Killer,Other,damagetype);

	if (Other.IsA('s_NPC'))
	{
		if (s_NPCHostage(Other)!=None)
		{
			H=s_NPCHostage(Other);

			if ((Killer!=None) && (!Killer.IsA('s_NPC')))
			{
				if (bSinglePlayer)
					HostageKilled(killer, Other, damageType);
				else
					AddMoney(Killer, KillHostagePrice);

				if (Killer.PlayerReplicationInfo.Team==0)
					bTShotHostages=true;
			}

			if ((H.Followed!=None) && (s_Bot(H.Followed)!=None))
			{
				if (s_Bot(H.Followed).HostageFollowing>0)
					s_Bot(H.Followed).HostageFollowing--;
				if (s_Bot(H.Followed).HostageFollowing<1)
					ClearBotObjective(s_Bot(H.Followed));
			}

			nbHostagesLeft--;
			CheckHostageWin();
		}

		Other.PlayerReplicationInfo.bIsSpectator=true;
		return;
	}

	ResetNPCPlayer(Other);

	if ((BotConfig.bAdjustSkill) && (killer.IsA('PlayerPawn') || Other.IsA('PlayerPawn')))
	{
		if (killer.IsA('Bot'))
			BotConfig.AdjustSkill(Bot(killer),true);
		if ( Other.IsA('Bot') )
			BotConfig.AdjustSkill(Bot(Other),false);
	}

	if (Other.PlayerReplicationInfo!=None)
	{
		VictimPRI=Other.PlayerReplicationInfo;
		Other.PlayerReplicationInfo.Deaths+=1;
		Other.PlayerReplicationInfo.bIsSpectator=true;
	}
	else
		VictimPRI=None;

	TMDropInventory(Other,true);
	Other.DieCount++;

/*	if (damageType=='MirrorDamage')
		AddMoney(Other,-4*KillPrice);*/


	if ((Killer==None) || (Killer==Other))
	{
		KillerPRI=None;
//		CheckTK(Other);
	}
	else
	{
		bFirstKill=true;

		if ((s_Bot(Killer)!=None) && (s_Bot(Killer).LastObjective!=''))
			s_Bot(Killer).ResetLastObj();

		if (!killer.IsA('s_NPC'))
		{
			if (Killer.PlayerReplicationInfo!=None)
			{
				KillerPRI=Killer.PlayerReplicationInfo;
/*				if (Killer.PlayerReplicationInfo.Team!=Other.PlayerReplicationInfo.Team)
				{*/
					killer.killCount++;
					Killer.PlayerReplicationInfo.Score+=1;

/*					if (!bSinglePlayer)
						AddMoney(Killer,KillPrice);*/
/*				}
				else
				{
					Killer.PlayerReplicationInfo.Score-=1;
					if (damageType!='MirrorDamage')
						AddMoney(Killer,-4*KillPrice);
					AddMoney(Other,4*KillPrice);
					CheckTK(Killer);
				}*/
			}
			else
				KillerPRI=None;
		}
	}

	BaseMutator.ScoreKill(Killer,Other);

	P=TMPlayer(Other);
	B=s_Bot(Other);

	if (B!=None)
	{
		ClearBotObjective(B);
		if (!bKeepInventory)
		{
            B.VestCharge=0;
            B.HelmetCharge=0;
            B.LegsCharge=0;
        }
		B.bDead=true;
		B.bNotPlaying=true;
		Other.Health=-1;
	}
	else if (P!=None)
	{
		if (!bKeepInventory)
		{
            P.VestCharge=0;
            P.HelmetCharge=0;
            P.LegsCharge=0;
            P.Die();
        }
		if (P.Flashlight!=None)
		{
			P.Flashlight.Destroy();
			P.Flashlight=None;
		}
		P.SetPhysics(PHYS_None);
		P.bDead=true;
		P.bNotPlaying=true;
		Other.Health=-1;
	}

	if (VictimPRI!=None)
	{
		for (PawnLink=Level.PawnList;PawnLink!=None;PawnLink=PawnLink.nextPawn)
		{
			if ((PawnLink.IsA('s_Player')) && (!s_Player(PawnLink).bHideDeathMsg))
				s_Player(PawnLink).HUD_Add_Death_Message(KillerPRI,VictimPRI);
		}
	}

	BotCheckOrderObject(Other);
	CheckEndGame();

// New killed function start here
    if (GamePeriod==GP_PreRound)
    {
        bFirstKill=false;
        return;
    }

	if ((Killer!=None) && (Killer.PlayerReplicationInfo!=None))
	{
		if ((Other!=None) && (Other.PlayerReplicationInfo!=None))
/*			if (Other.PlayerReplicationInfo.Team!=Killer.PlayerReplicationInfo.Team)
			{*/
			    if ((Killer!=None) && (Other!=None) && (Other!=Killer))
			    {
                    if (Killer.IsA('TMPlayer')) TMPRI(Killer.PlayerReplicationInfo).CurrentScore++;
                    if (Killer.IsA('TMBot')) TMBRI(Killer.PlayerReplicationInfo).CurrentScore++;
		  		  AddMoney(Killer,AmountForFrag);
    		  		if (oldbfirstkill!=bFirstKill)
                    {
                        AddMoney(Killer,AmountForFrag);
                        if (Other.IsA('TMPlayer')) TMPlayer(Other).ClientPlaySound(Sound'TODM.FirstBlood');
                        if (Killer.IsA('TMPlayer')) TMPlayer(Killer).ClientPlaySound(Sound'TODM.FirstBlood');
                    }

                    if (ScorePerRound>0)
    	       			if (GetCurrentScoreOf(Killer)>=ScorePerRound)
	      	       		{
                            if (Killer.IsA('TMPlayer')) TMPRI(Killer.PlayerReplicationInfo).NbRound++;
		      	     	    if (Killer.IsA('TMBot')) TMBRI(Killer.PlayerReplicationInfo).NbRound++;
                            BroadcastLocalizedMessage(class'TMMessageWin',18,Killer.PlayerReplicationInfo);
//                            SendMessageToAllPlayers(Killer.PlayerReplicationInfo.PlayerName$" reach limit of frags");
                            SetWinner(2);
                            EndGame("Limit frags reached");
	       			     }
	       		}
/*			}
			else
			{
                if (Killer.IsA('TMPlayer')) TMPRI(Killer.PlayerReplicationInfo).CurrentScore--;
                if (Killer.IsA('TMBot')) TMBRI(Killer.PlayerReplicationInfo).CurrentScore--;
			}*/
	}
}

function int GetCurrentScoreOf(Pawn P)
{
    if (P.IsA('TMPlayer')) return TMPRI(P.PlayerReplicationInfo).CurrentScore;
    if (P.IsA('TMBot')) return TMBRI(P.PlayerReplicationInfo).CurrentScore;
    return 0;
}

function GetPathNodeList()
{
	local int i;
	local PathNode Dest;
	local PlayerStart PS;

	i=0;

	foreach AllActors(class'PlayerStart',PS)
	{
		i++;
		if (PS!=None)
			Candidate[i]=PS;
	}

	foreach AllActors(class'PathNode',Dest)
	{
		i++;
		if (i>254)
			break;

		if (Dest!=None)
			if (!Dest.Region.Zone.bWaterZone) Candidate[i]=Dest;
	}
	NbCandidate=i;
}

function NavigationPoint FindPlayerStart(Pawn Player,optional byte InTeam,optional string incomingName)
{
	return Candidate[Rand(NbCandidate)+1];
}

event InitGame(string Options,out string Error)
{
	Super.InitGame(Options,Error);
	GetPathNodeList();
	FriendlyFireScale=1.000000;
	bMirrorDamage=False;
    bExplosionFF=True;
    bAllowPunishTK=False;
}

// New GiveBomb function
function GiveBomb()
{
	bBombGiven=true;
	return;
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
		check = -1;

	if ( check == 1 )
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
	{*/
		// Restart to play

		aPlayer.Acceleration = vect(0,0,0);
		aPlayer.Velocity = vect(0,0,0);

		if ( P != None )
		{
			P.TOStandUp(true);
			P.SetBlindTime(0.0);
		}
		//else

		aPlayer.bAlwaysRelevant = true;
		aPlayer.bHidden = false;
		aPlayer.SoundDampening = aPlayer.Default.SoundDampening;

		//see if this fixes the sunken into the ground problem on start
		aPlayer.SetPhysics(PHYS_Walking);

		addDefaultInventory(aPlayer);

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
            if (TMPlayer(aPlayer)!=None)
            {
                if ((TMPlayer(aPlayer).bAutoBuyArmor) && (TMPlayer(aPlayer).Money>900)) BuyArmor(aPlayer);
                TMPlayer(aPlayer).CptIAR=SecGodMod;
			    RestartToPlay(aPlayer);
			    if (bShowEffectInvulnerable) GiveShieldEffect(aPlayer);
			    TMPlayer(aPlayer).GotoState('PlayerWalking');
		    }
		    if (TMBot(aPlayer)!=None)
		    {
                TMBot(aPlayer).CptIAR=SecGodMod;
                TMBot(aPlayer).BlindTime=0.0;
			    RestartToPlay(aPlayer);
			    if (bShowEffectInvulnerable) GiveShieldEffect(aPlayer);
			    TMBot(aPlayer).GotoState('BotBuying');
		    }
		}
		return true;
	} else return false;
}

function GiveShieldEffect(Pawn aPlayer)
{
    local TMShieldEffect tms;

    tms=Spawn(class'TMShieldEffect',aPlayer,,aPlayer.Location,aPlayer.Rotation);
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
	if (TMPlayer(aPlayer)!=None)
		TMPlayer(aPlayer).TOStandUp(true);
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
	   if ((TMPlayer(aPlayer)!=None) && (TMPlayer(aPlayer).carc!=none)) TMPlayer(aPlayer).carc.destroy();
	   if ((TMBot(aPlayer)!=None) && (TMBot(aPlayer).carc!=none)) TMBot(aPlayer).carc.destroy();
	}
}

final function TMPlayerJoined(s_Player P)
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

/*function NoAttack(TMPlayer P)
{
	if (P.CptIAR>0)	P.CptIAR--; else BackToGame(P);
}*/

function Timer()
{
    local Pawn P;

    super.Timer();
	RoundStarted=0;
    for (P=Level.PawnList;P!=None;P=P.NextPawn)
    {
        if ((P.IsA('TMPlayer')) && (!P.PlayerReplicationInfo.bWaitingPlayer))
            if (TMPlayer(P).CptIAR>0)
            {
                TMPlayer(P).CptIAR--;
//                if (bShowEffectInvulnerable) Spawn(class'UTTeleportEffect',,,P.Location,P.Rotation);
            }
        if (P.IsA('TMBot'))
            if (TMBot(P).CptIAR>0)
            {
                TMBot(P).CptIAR--;
//                if (bShowEffectInvulnerable) Spawn(class'UTTeleportEffect',,,P.Location,P.Rotation);
                if (TMBot(P).CptIAR==0) P.GotoState('Roaming');
            }
    }
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
    local s_GameReplicationInfo GRI;

    GRI=s_GameReplicationInfo(GameReplicationInfo);
    if (GRI==None) return;
    if (GRI.RemainingTime==300) PlayTimeRemaining(Sound'Announcer.cd5min');
    if (GRI.RemainingTime==180) PlayTimeRemaining(Sound'Announcer.cd3min');
    if (GRI.RemainingTime==60) PlayTimeRemaining(Sound'Announcer.cd1min');
    if (GRI.RemainingTime==10) PlayTimeRemaining(Sound'Announcer.cd10');
    if (GRI.RemainingTime==9) PlayTimeRemaining(Sound'Announcer.cd9');
    if (GRI.RemainingTime==8) PlayTimeRemaining(Sound'Announcer.cd8');
    if (GRI.RemainingTime==7) PlayTimeRemaining(Sound'Announcer.cd7');
    if (GRI.RemainingTime==6) PlayTimeRemaining(Sound'Announcer.cd6');
    if (GRI.RemainingTime==5) PlayTimeRemaining(Sound'Announcer.cd5');
    if (GRI.RemainingTime==4) PlayTimeRemaining(Sound'Announcer.cd4');
    if (GRI.RemainingTime==3) PlayTimeRemaining(Sound'Announcer.cd3');
    if (GRI.RemainingTime==2) PlayTimeRemaining(Sound'Announcer.cd2');
    if (GRI.RemainingTime==1) PlayTimeRemaining(Sound'Announcer.cd1');
}

function PlayTimeRemaining(sound snd)
{
    local TMPlayer P;

    foreach AllActors(class'TMPlayer',P)
        P.ClientPlaySound(snd,true,true);
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

	NewBot = Spawn(class'TMBot',,,StartSpot.Location,StartSpot.Rotation);

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

function byte AssessBotAttitude(Bot aBot,Pawn Other)
{
	if (((Other.bIsPlayer) && (aBot.PlayerReplicationInfo.Team==Other.PlayerReplicationInfo.Team)) || (Other.IsA('TeamCannon') && (StationaryPawn(Other).SameTeamAs(aBot.PlayerReplicationInfo.Team))))
		return 1;
	else
{
	if (Other.PlayerReplicationInfo.bWaitingPlayer || Other.PlayerReplicationInfo.bIsSpectator)
		return 2;

	if (Other.PlayerReplicationInfo.Team>2)
		return 2;

	if (Other.IsInState('PlayerWaiting'))
		return 2;

	if (Other.IsA('s_Bot') && s_Bot(Other).bNotPlaying)
		return 2;

	if (Other.IsA('s_Player') && s_Player(Other).bNotPlaying)
		return 2;

	if (Other.IsA('s_NPCHostage'))
		return 3;

	return Super.AssessBotAttitude(aBot,Other);
}
}

function AddDefaultInventory( pawn PlayerPawn )
{
	local Bot B;

	if ((PlayerPawn.IsA('s_Player')) && (PlayerPawn.PlayerReplicationInfo.bWaitingPlayer))
		return;

	GiveTeamWeapons(PlayerPawn);

	if ((s_Player(PlayerPawn)!=None) && (s_Player(PlayerPawn).Money==0)) AddMoney(PlayerPawn,1000);
	if ((s_Bot(PlayerPawn)!=None) && (s_Bot(PlayerPawn).Money==0)) AddMoney(PlayerPawn,1000);

	B=Bot(PlayerPawn);
	if (B!=None)
		B.bHasImpactHammer=false;

	BaseMutator.ModifyPlayer(PlayerPawn);

	PlayerPawn.SwitchToBestWeapon();
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
		c.bActive=false;
	foreach AllActors(class's_OICW',o)
		o.Destroy();
}

final function ChangeTMPModel(Pawn P,int num,int team,bool bDie)
{
	local Actor	StartPoint;
	local byte OldTeam;
	local s_Player sP;
	local bool bNoWeapons,bChangeModel,bChangeTeam,bNotPlaying;

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

		bNotPlaying=sP.bNotPlaying || sP.PlayerReplicationInfo.bWaitingPlayer;
		bNoWeapons=sP.bDead || sP.PlayerReplicationInfo.bWaitingPlayer;
		bChangeModel=(num==255) || (num!=sP.PlayerModel);

		if ((bNotPlaying) || (!bChangeTeam) || (GamePeriod!=GP_RoundPlaying))
			bDie=false;
	}
	else if ((P.PlayerReplicationInfo.bWaitingPlayer) || (P.PlayerReplicationInfo.bIsSpectator))
		bDie=false;


	if (bDie)
		P.TakeDamage(500000,None,P.Location,vect(0,0,0),'ChangedTeam');
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
			ChangeModel(P,num);

		if ( bChangeTeam && (P.GetStateName() == 'PlayerSpectating') )
			PlayerPawn(P).Fire(0.0);
	}

	if ((!bDie) && (bChangeTeam) && (!bNoWeapons) && (!bNotPlaying))
	{
		GiveTeamWeapons(P);
		if (P.Weapon==None)
			P.SwitchToBestWeapon();
	}
}

function AddToTeam(int num,Pawn Other)
{
	local teaminfo aTeam;
	local Pawn P;
	local bool bSuccess;
	local string SkinName,FaceName;
	local actor StartSpot;
	local byte Oldteam;

	if ((Other==None) || (Other.PlayerReplicationInfo==None) || (num==255))
	{
		log("Added none to team!!!");
		return;
	}

	ClearOrders(Other);
	OldTeam=Other.PlayerReplicationInfo.Team;
	aTeam=Teams[num];

	Other.PlayerReplicationInfo.Team=num;
	Other.PlayerReplicationInfo.TeamName=aTeam.TeamName;

	if (LocalLog!=None)
		LocalLog.LogTeamChange(Other);
	if (WorldLog!=None)
		WorldLog.LogTeamChange(Other);

	bSuccess=false;
	if (Other.IsA('PlayerPawn'))
	{
		Other.PlayerReplicationInfo.TeamID=0;
		PlayerPawn(Other).ClientChangeTeam(Other.PlayerReplicationInfo.Team);
	}
	else
		Other.PlayerReplicationInfo.TeamID=1;

	while (!bSuccess)
	{
		bSuccess=true;
		for (P=Level.PawnList;P!=None;P=P.nextPawn)
            if ((P.bIsPlayer) && (P!=Other) && (P.PlayerReplicationInfo.Team==Other.PlayerReplicationInfo.Team)	&& (P.PlayerReplicationInfo.TeamId==Other.PlayerReplicationInfo.TeamId))
				bSuccess=false;
		if (!bSuccess)
			Other.PlayerReplicationInfo.TeamID++;
	}

	BroadcastLocalizedMessage(class'TMDeathMatchMessage',3,Other.PlayerReplicationInfo,None,aTeam);

	if (num==0)
		SetRandomTerrModel(Other);
	else
		SetRandomSFModel(Other);

	StartSpot=FindPlayerStart(Other,Other.PlayerReplicationInfo.Team);
	if (StartSpot==None)
	{
		log("AddToTeam - FindPlayerStart failed - Destroy");
		Other.Destroy();
		return;
	}

	Other.SetLocation(StartSpot.Location);
	Other.SetRotation(StartSpot.Rotation);
	Other.ViewRotation=StartSpot.Rotation;
	Other.SetRotation(Other.Rotation);

	aTeam.Size++;

	if (OldTeam<2)
		Teams[OldTeam].Size--;

	if ((bBalanceTeams) && (!bRatedGame))
		ReBalance();

	CheckEndGame();
}

function TOResetGame()
{
    local TMPlayer P;
    local TMBot B;

    super.TOResetGame();
	foreach AllActors(class'TMPlayer',P)
	{
		if ((P!=None) && (TMPRI(P.PlayerReplicationInfo)!=None))
		{
			TMPRI(P.PlayerReplicationInfo).CurrentScore=0;
			TMPRI(P.PlayerReplicationInfo).NbRound=0;
		}
	}

	foreach AllActors(class'TMBot',B)
	{
		if ((B!=None) && (TMBRI(B.PlayerReplicationInfo)!=None))
		{
			TMBRI(B.PlayerReplicationInfo).CurrentScore=0;
			TMBRI(B.PlayerReplicationInfo).NbRound=0;
		}
	}
}

final function TMDropInventory(Pawn Other,bool bDropMoney)
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


	TMKillInventory(Other);

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

final function TMKillInventory(Pawn P,optional bool buymenu)
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

function DiscardInventory(Pawn Other)
{
    if (bKeepInventory) return; else super.DiscardInventory(Other);
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

function int SWATReduceDamage(int Damage, name DamageType, pawn injured, pawn instigatedBy, Vector HitLocation)
{
	local int reducedamage;
/*
	if ( instigatedBy != None )
		log("TO_GameBasics::SWATReduceDamage -D:"@Damage@"-DT:"@DamageType@"-injured:"@injured@"-instigatedBy:"@instigatedBy@"-HL:"@HitLocation);
	else
		log("TO_GameBasics::SWATReduceDamage -D:"@Damage@"-DT:"@DamageType@"-injured:"@injured@"-instigatedBy: None -HL:"@HitLocation);
*/
	// Damage only enabled during round playing
	// But not for bots!!
	if ( GamePeriod != GP_RoundPlaying )
	{
		if ( injured.IsA('s_Player') )
			return 0;

		else if ( injured.IsA('Bot') && instigatedBy.IsA('Pawn') && (instigatedBy != injured) )
			return 0;
	}

/*
	// Handle stomped damage
	if ( injured.IsA('s_Player') && (DamageType=='stomped') )
	{
		if ( Damage < 20 )
			return 0;
	}
*/
	if ( bDisableRealDamages )
		damage /= 2;

	if (  injured.bIsPlayer && (instigatedBy != None) && instigatedBy.bIsPlayer
	&& (injured.PlayerReplicationInfo.Team == instigatedBy.PlayerReplicationInfo.Team) && ReduceExplosions( DamageType ) )
	{
		if ( (instigatedBy != injured) && injured.IsA('Bot') )
			Bot(Injured).YellAt(instigatedBy);
		damage = Damage * FriendlyFireScale;
	}

	if ( damage == 0 )
		return 0;

	// Explosions hit the torso and not the legs!
	if ( (DamageType == 'heshockwave') || (DamageType == 'explosion') || (DamageType == 'Explosion') )
		HitLocation.Z = 1.0;

	// Falling damage isn't protected by armor anymore.
	if ( DamageType == 'Fell' )
		return Damage;

	if ( InstigatedBy!=None && InstigatedBy.IsA('s_Bot') )
	{
		// Reduce damage depending on difficulty
		if ( Bot(InstigatedBy).bNovice )
		{
			// range from (novice) x2.0 -> x1.0
			if ( Bot(InstigatedBy).Skill < 2)
				Damage = Damage * 0.5;
			else
				Damage = Damage * 0.67;
			//AimError = PlayerAimError * FClamp((2.0 - Bot(Owner).Skill/2.0), 3.0, 2.0);
		}
		else
		{
			if ( Bot(InstigatedBy).Skill < 2)
				Damage = Damage * 0.84;
			else
				Damage = Damage * 1.0;
		}

		// Suppress Team Kill
/*		if ( damageType=='shot' /*&& injured.IsA('s_Bot')*/ && injured.PlayerReplicationInfo.Team==InstigatedBy.PlayerReplicationInfo.team)
			Damage = 0;*/
	}

	if (injured.IsA('s_NPC'))
		reducedamage = SWAT_NPC_ReduceDamage(Damage, DamageType, s_NPC(Injured), InstigatedBy, HitLocation);
	else if (injured.IsA('s_Bot'))
		reducedamage = SWAT_BOT_ReduceDamage(Damage, DamageType, s_Bot(Injured), InstigatedBy, HitLocation);
	else if (injured.IsA('s_Player'))
		reducedamage = SWAT_PLAYER_ReduceDamage(Damage, DamageType, s_Player(Injured), InstigatedBy, HitLocation);

	if ( (reducedamage != 0) && bMirrorDamage )
	{
		if ( (InstigatedBy!=None) && (PlayerPawn(InstigatedBy) != None )
			&& (Injured.PlayerReplicationInfo.Team == PlayerPawn(InstigatedBy).PlayerReplicationInfo.Team) && InstigatedBy != Injured)
		{
			InstigatedBy.TakeDamage(Damage * 2, None, InstigatedBy.Location, Vect(0,0,0), 'MirrorDamage');
		}
	}

	//if (Damage'decapitated') || (damageType == 'shot'
/*	if ( instigatedBy == None || DamageType == 'heshockwave')
		return Damage;


	else */
	return reducedamage;
}

defaultproperties
{
	BeaconName="Tactical Match"
	GameName="Tactical Match"
	ScorePerRound=0
	AmountForFrag=1000
	bRequireReady=false
	HUDType=class'TMHUD'
	bKeepInventory=true
	bPlayTimeAnnouncer=true
	bShowEffectInvulnerable=true
	SecGodMod=6
	bRemoveCarcass=True
	FixMutatorReplicationBugUT436=true
    DisableWeapon(20)=1
    DisableWeapon(23)=1
    DisableWeapon(15)=1
}

