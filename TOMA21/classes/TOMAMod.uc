//
// FilRip
//
// TOMAv2.1 (for TO3.4)
// MAIN CLASS, THE MOD CLASS
//

Class TOMAMod extends s_SWATGame config(TOMA2);

#exec OBJ LOAD FILE=..\Sounds\TOMASounds21.uax PACKAGE=TOMASounds21

var int nbmonstres,nbmonstrestue;
var() config int InitialMonsters,nbMapMonster,NbMainMonsters;
var int nbpathnode,nbps;
var vector PathNode[255],PS[48];
var int PathNodeIsInWater[255];
var() config string MonstersString[64];
var byte AlreadyPlayed[64];
var() config byte CanBeRandom[64];
var() config int MoneyDrop[64];
var() config int NbMonstersKilledForEndRound[64];
var() config byte HealthMult;
var() config byte NbSFKilledForEndRound;
var() config int MoneyStart;
var() config bool TerroristStartPoint;
var() config byte SecBeforeRandomSpawn;
var() config bool EnableCanBeRandom;
var() config bool EverythingToSF;
var() config bool RandomMonster;
var() config bool RandomSpawn;
var() config bool RageMode;
var() config bool BuyEverywhere;
var() config bool DisplayMonsterLoginMessage;
var() config bool EnableNewWeapons;
var() config bool UseINIMonstersStart;
var() config int NewKillPrice,NewRescueHostagePrice,NewRescueTeamHostagePrice;
var() config bool DisableMapTimeLimit;
var() config bool DisableRoundTimeLimit;
var() config bool EndRoundWhenHalfSFDied;
var() config int NewMaxMoney;
var() config bool PunishTeamKill;
var() config bool PunishFriendlyFire;
var() config int ScorePunishTeamKill;
var() config int ScorePunishFriendlyFire;
var() config bool DestroyKilledMonsters;
var() config bool EnableVote;
var() config bool RespawnPlayer;
var() config byte SecBeforeRespawnPlayer;
var() config byte SecGodMod;
var() config bool FixMutatorReplicationBugUT436;
var int numlevel;
var byte VoteForSkip,NextMonster;
var() config byte MaxLevel;
var() config byte StartAtLevel;
var byte currentsfkilled;
var int NbMainMonstersKilled;
var byte NbDifferentMonsters;
var byte currentseccount;
var int cptinitmonster;
var() config bool ShareMoneyInTeam;
var bool sharedforthisround;
var localized string LoginMonstersText,TextVoteGagne,TextVoteSkipLevel,TextVoteFor,TextSkipLevel;
var() config byte LimitOfSpecialNade;
var() config string Maps[64];
var() config string MonstersStart[64];
var() config bool changemapwhenlevelend;
var byte VoteOfThisOne[64];
var localized string SD1,SFO1,SFO2,SFO3,SFO4,LevelText,NamedText,Currentleveltext,Monsterstokilltext,MonstersInMapText;
var string ScenarioNameText;
var() config bool MonstersCanStealWeaponsOnTheFloor;
var() config bool MonstersCanStealHealthPack;
var() config bool MonstersCanClimbWall;
var() config bool MonstersCanHaveWeapon;
var() config bool DestroyWeaponThatMonsterCarryingWhenDie;
var() config bool bShowEffectInvulnerable;
var() config bool bRemoveCarcass;
var() config bool bAllowRadar;
var() config bool bHealthPack;
var() config bool bKeepInventory;
var() config bool bRandomWeaponsForMonsters;
var() config byte WeaponNumberForMonster;
var localized string LimitSpecialNadeExceed;
var localized string MonstersForVote;
var TOMAVoteR VoteR;
var() config bool bEnableMagic;
var Sound MonsterInsult[12];

// Remove space before and after the gived string
function string RemoveSpace(string m)
{
	while (left(m,1)==" ")
		m=right(m,len(m)-1);
	while (right(m,1)==" ")
		m=left(m,len(m)-1);
	return m;
}

// return specified string in a big string (string separated by comma)
function string RetourneNomPos(string fullline,byte position)
{
	local string retour,tempchaine;
	local byte i;

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

// return number of string in a BIG string (strings separated by comma)
function int RetourneNbNom(string fullline)
{
	local byte retour;
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

// At initgame, "precache" all possible monsters start
// (specified in INI or if not : PathNode & PlayerStart
function FindMonsterStart()
{
	local PlayerStart PSS;
	local int i,j,k,exist;
	local string nom;
	local Actor A;

	nbps=0;
	exist=-1;
	if (UseINIMonstersStart)
	{
		for(i=0;i<64;i++)
			if (Caps(RemoveSpace(Maps[i]))==Caps(RemoveSpace(Level.Title)))
			{
				Log("This is a known map, number "$string(i));
				exist=i;
			}
	}
	if (exist>-1)
	{
		j=RetourneNbNom(MonstersStart[exist]);
		for(k=1;k<j+1;k++)
		{
			nom=RetourneNomPos(MonstersStart[exist],k);
			foreach AllActors(class'Actor',A)
				if (string(A.name)==nom)
				{
					nbPS++;
					PS[nbPS]=A.Location;
				}
		}
	} else
	{
		Log("Map not in INI or don't use INI, use classic terrorists start for monsters");
		foreach AllActors(class'PlayerStart',PSS)
			if (PSS!=None)
				if (PSS.TeamNumber==0)
				{
					nbps++;
					PS[nbPS]=PSS.Location;
				}
		if (nbps==0) Log("WARNING MAP INCOMPATIBLE, NO PLAYERSTART TERRORISTS FOUND");
	}
}

// new Initgame (after call the on of S_SWATGame class)
event InitGame (string Options, out string Error)
{
	local PathNode PN;
	local int i;
	local bool find;

    bAllowGhostCam=true;
	Super.InitGame(Options,Error);
	nbpathnode=0;
	foreach AllActors(class'PathNode',PN)
	{
		if (PN!=None)
		{
			nbpathnode++;
			if (nbpathnode<255)
			{
				PathNode[nbpathnode]=PN.Location;
				if (PN.Region.Zone.bWaterZone) PathNodeIsInWater[nbpathnode]=1; else PathNodeIsInWater[nbpathnode]=0;
			}
		}
	}
	if (nbpathnode==0) Log("WARNING MAP INCOMPATIBLE, NO PATHNODE FOUND");
	FindMonsterStart();
	NumberOfMonstersInINIFile();
	SetTimer(1,True);
	numlevel=StartAtLevel;
	if (RandomMonster)
    {
        find=true;
        while(find)
        {
            find=false;
            numlevel=Rand(maxlevel)+1;
    		if ((instr(Caps(MonstersString[numlevel]),"DEVILFISH")>0) || (instr(Caps(MonstersString[numlevel]),"SQUID")>0) || (instr(Caps(MonstersString[numlevel]),"PARENTBLOB")>0) || (instr(Caps(MonstersString[numlevel]),"QUEEN")>0) && (instr(Caps(MonstersString[numlevel]),"ALIENQUEEN")==0))
    		  find=true;
        }
    }
	currentseccount=0;

	if (NewKillPrice!=0) KillPrice=NewKillPrice;
	if (NewRescueHostagePrice!=0) RescueAmount=NewRescueHostagePrice;
	if (NewRescueTeamHostagePrice!=0) RescueTeamAmount=NewRescueTeamHostagePrice;
	if (NewMaxMoney!=0)
		MaxMoney=NewMaxMoney;

	if (EnableVote) VoteR=Spawn(class'TOMAVoteR');
	NextMonster=255;
}

// Send the specified message to all TOMA players
// Message as admin say# , white centered on screen
function SendMessageTOAllPlayers(string msg)
{
    local Pawn P;

    for (P=Level.PawnList;P!=None;P=P.NextPawn)
        if (P.IsA('TOMAPlayer'))
        {
    		TOMAPlayer(P).ClearProgressMessages();
            TOMAPlayer(P).SetProgressTime(4);
            TOMAPlayer(P).SetProgressMessage(Msg,0);
        }
}

// New tick of this mod class
// To spawn main monsters (monsters of current round)
function Tick(float delta)
{
	Super.Tick(delta);
	if (GamePeriod==GP_RoundPlaying)
	{
//		if (NbMainMonstersKilled<NbMainMonsters)
			if (cptinitmonster<InitialMonsters)
				if (MonstersString[NumLevel]!="") SummonMe(MonstersString[numlevel]);
	}
}

// new getrules
// To fix Mutator replication UT436 BUGS
function string GetRules()
{
    local string a;

	a=Super.GetRules();
	if ((EnabledMutators!="") && (FixMutatorReplicationBugUT436))
		a=a$"\\mutators\\"$EnabledMutators;
	return a;
}

function GiveShieldEffect(Pawn aPlayer)
{
    local TOMAShieldEffect tms;

    tms=Spawn(class'TOMAShieldEffect',aPlayer,,aPlayer.Location,aPlayer.Rotation);
    tms.Mesh=aPlayer.Mesh;
    tms.DrawScale=aPlayer.DrawScale;
    tms.ScaleGlow=1;
/*    if (aPlayer.PlayerReplicationInfo.Team==0) tms.texture=FireTexture'UnrealShare.Belt_fx.ShieldBelt.RedShield';
    else tms.texture=FireTexture'UnrealShare.Belt_fx.ShieldBelt.BlueShield';*/
    if (aPlayer.PlayerReplicationInfo.Team==0) tms.texture=Texture'UnrealShare.Belt_fx.ShieldBelt.newRed';
    else tms.texture=Texture'UnrealShare.Belt_fx.ShieldBelt.newBlue';
}

// Timer function, second part
// This one check players (force SF team) and bots
function SecondTimer()
{
	local Pawn P;
	local TOMAPlayer SP;
	local S_Bot SB;
	local int locali;
	local int localj;

	for(P=Level.PawnList;P!=None;P=P.nextPawn)
	{
        if (P.IsA('TOMAPlayer'))
        {
            if (P.PlayerReplicationInfo.Team==0)
            {
                TOMAPlayer(P).balreadychangedteam=false;
                TOMAPlayer(P).s_changeteam(1,1,false);
            }
            if ((TOMAPlayer(P).WBR>0) && (GamePeriod==GP_RoundPlaying))
            {
                TOMAPlayer(P).WBR--;
                if (TOMAPlayer(P).WBR==0)
                {
                    RestartHimNow(P);
                    TOMAPlayer(P).CptIAR=SecGodMod;
    			    if (bShowEffectInvulnerable) GiveShieldEffect(P);
                }
            }
            if (TOMAPlayer(P).CptIAR>0)
            {
                TOMAPlayer(P).CptIAR--;
//                if (bShowEffectInvulnerable) Spawn(class'UTTeleportEffect',,,P.Location,P.Rotation);
            }
        }
        if (P.IsA('TOMABot'))
        {
            if (P.PlayerReplicationInfo.Team==0)
            {
                P.PlayerReplicationInfo.Team=1;
                s_bot(P).bNotPlaying=false;
                RestartPlayer(P);
            }
            if ((TOMABot(P).WBR>0) && (GamePeriod==GP_RoundPlaying))
            {
                TOMABot(P).WBR--;
                TOMABot(P).OldState='Attacking';
                if (TOMABot(P).WBR==0)
                {
                    TOMABot(P).CptIAR=SecGodMod;
			        if (bShowEffectInvulnerable) GiveShieldEffect(P);
                    RestartHimNow(P);
                }
            }
            if (TOMABot(P).CptIAR>0)
            {
                TOMABot(P).CptIAR--;
//                if (bShowEffectInvulnerable) Spawn(class'UTTeleportEffect',,,P.Location,P.Rotation);
            }
        }
        if ((P.IsA('TOMAScriptedPawn')) && (GamePeriod==GP_RoundPlaying))
        {
            localj++;
            if (string(P.Class)==MonstersString[numlevel]) localI++;
        }
    }

// Yes, that's a stupid thing, to stop the "no stop respawn" on some monsters that spawn same monsters every time.
    if ((instr(Caps(MonstersString[numlevel]),"WARLORD")==0) && (instr(Caps(MonstersString[numlevel]),"SKAARJ")==0))
    {
        cptinitmonster=locali;
//        nbmonstres=localj;
    }
}

// Clean all. It's the end of the round
// We destroy all monsters and others little stuff
// Before restart new round
function CleanUp()
{
	local int i;
	local TOMAPlayer joueur;
	local Projectile P;
	local TOMAProjSmokeGren A;
    local TOMAScriptedPawn M;

	foreach AllActors(class'TOMAScriptedPawn',M)
		M.Destroy();

	foreach AllActors(class'Projectile',p)
		P.Destroy();

	foreach AllActors(class'TOMAProjSmokeGren',A)
		A.Destroy();

	foreach AllActors(class'TOMAPlayer',joueur)
		if (joueur.bHasAlreadyBeInRageMode) joueur.BackFromRageMode();
}

// Share money system
// not working ?
function ShareMoneyNow()
{
	local int mnt;
	local int mntforone;

	SharedForThisRound=true;
	mnt=MoneyOfSF();
	mntforone=mnt/Teams[1].size;
	if (mntforone>20000) mntforone=20000;
	ShareForAllSF(mntforone);
}

// Clean monsters vote after vote end or restart new round
function CleanVote()
{
	local int i;
	local Pawn P;

	for(i=0;i<RetourneNbNom(MonstersForVote);i++)
		VoteOfThisOne[i]=0;
	for (P=Level.PawnList;P!=None;P=P.nextPawn)
        if (P.IsA('TOMAPlayer'))
            TOMAPlayer(P).myvote=0;
    VoteForSkip=0;
    ResetVoteR();
}

function ResetVoteR()
{
    local byte i;

    for (i=0;i<64;i++)
        VoteR.VoteM[i]=VoteOfThisOne[i];
    VoteR.VoteS=VoteForSkip;
}

// Main new timer function of this mod class
// Check end game, winners, spawn random monsters at random place in the map
// Fix round/map time
// and others little stuff
function timer()
{
	Super.Timer();

	currentseccount++;

	SecondTimer();

	if (GamePeriod==GP_RoundPlaying)
	{
		if ((NbMonstres<NbMapMonster) && (RandomSpawn) && (currentseccount>=SecBeforeRandomSpawn))
		{
			currentseccount=0;
			SummonEverywhere();
		}
		TOMAGameReplicationInfo(GameReplicationInfo).nbmonstersinmap=(NbMonstres-nbmonstrestue);
		TOMAGameReplicationInfo(GameReplicationInfo).nbmonsterstokill=(nbmonsterskilledforendround[numlevel]-nbmonstrestue);
	}

	if (currentseccount==SecBeforeRandomSpawn) currentseccount=0;

	if (DisableMapTimeLimit)
		RemainingTime=99*60;
	if (DisableRoundTimeLimit)
		s_GameReplicationInfo(GameReplicationInfo).RoundDuration=99*60;

	nbHostagesLeft=10;
}

// Spawn main monsters, monsters of current round
function SummonMe(string ClassName)
{
	local class<TOMAScriptedPawn> NewClass;
	local Vector place;
	local TOMAScriptedPawn monstre;
	local int a;

    if (ClassName=="") return;

	if (nbps>0)
	{
		place=ReturnRandomStartPoint();
		if (instr(Caps(classname),"BLOBET")>0)
		{
			a=rand(10);
			if (a>=8) ClassName="TOMA21.TOMAParentBlob";
		}
		NewClass=class<TOMAScriptedPawn>(DynamicLoadObject(ClassName,class'Class'));
		if (NewClass!=None)
		{
			monstre=Spawn(NewClass,self);
			if (monstre!=None)
			{
				monstre.SetLocation(place);
				if (monstre!=None)
				{
					monstre.health*=healthmult;
					if (!GoodLocationSpawning(place,monstre.location))
					{
						monstre.bIsPlayer=false;
						monstre.destroy();
					} else
					{
						nbmonstres++;
						cptinitmonster++;
						monstre.StartRoaming();
					}
				}
			}
		}
	}
}

// Check if monsters have been spawned in the right place we have choice
// UT engine spawn at LevelInfo position when it can't spawn it at the place we decide
// So here, we check and destroy it if it's not in the right place
function bool GoodLocationSpawning(vector place,vector newplace)
{
	local int gx,gy,gz,lx,ly,lz;

	gx=place.x+200;
	gy=place.y+200;
	gz=place.z+200;
	lx=place.x-200;
	ly=place.y-200;
	lz=place.z-200;
	if ((newplace.x<gx) && (newplace.x>lx))
		if ((newplace.y<gy) && (newplace.y>ly))
			if ((newplace.z<gz) && (newplace.z>lz))
	return true; else return false;
}

// How many monsters have been set in TOMA.INI
function NumberOfMonstersInINIFile()
{
	local int a;

	NbDifferentMonsters=0;
	for(a=0;a<64;a++)
		if (MonstersString[a]!="") NbDifferentMonsters++;
}

// Spawn random monsters at random place
function SummonEverywhere()
{
	local class<TOMAScriptedPawn> NewClass;
	local Vector place;
	local TOMAScriptedPawn monstre;
	local int RandMonst;
	local bool inwater;

choiceamonster:
	RandMonst=rand(NbDifferentMonsters+1);
	if ((CanBeRandom[RandMonst]==0) && (EnableCanBeRandom)) GoTo ChoiceaMonster;
	if (RandMonst==NumLevel) GoTo ChoiceAMonster;
	if (Instr(Caps(MonstersString[RandMonst]),"DEVILFISH")>0)
		if (IsThereSomeWater()) inwater=true; else Goto ChoiceAMonster;
	if (Instr(Caps(MonstersString[RandMonst]),"SQUID")>0)
		if (IsThereSomeWater()) inwater=true; else Goto ChoiceAMonster;
	place=ReturnRandomPlace(inwater);

	if (nbpathnode>0)
	{
		NewClass=class<TOMAScriptedPawn>(DynamicLoadObject(MonstersString[randmonst],class'Class'));
		if (NewClass!=None)
		{
			monstre=Spawn(NewClass,self);
			if (monstre!=None)
			{
				monstre.SetLocation(place);
				if (monstre!=None)
				{
					monstre.health*=healthmult;
					if (monstre!=None)
					{
						nbmonstres++;
						monstre.StartRoaming();
						if (DisplayMonsterLoginMessage) Level.Game.BroadcastMessage(right(MonstersString[randmonst],len(MonstersString[randmonst])-11) $ " "$LoginMonstersText);
					}
				}
			}
		}
	}
}

// Return yes if the map have some PathNode under water
function Bool IsThereSomeWater()
{
	local int i;
	local bool retour;

	retour=false;
	for(i=0;i<nbpathnode;i++)
		if ((i<255) && (PathNodeIsInWater[i]==1))
		{
			retour=true;
			break;
		}
	return retour;
}

// Give a random place to spawn a random monsters
function vector ReturnRandomPlace(bool inwater)
{
	local int nbrand;
    local byte i;

ChoiceAPlace:
	nbrand=rand(nbpathnode)+1;
	i++;
	if (nbrand>255) goto ChoiceAPlace;
	if ((inwater) && (PathNodeIsInWater[nbrand]==0) && (i<254)) goto ChoiceAPlace;
	return PathNode[nbrand];
}

// Return a place for main monsters
function vector ReturnRandomStartPoint()
{
	local int nbrand;

    if (TerroristStartPoint)
    {
ChoiceAPlaceInTerro:
        nbrand=rand(nbps)+1;
	   if (nbrand>255) goto ChoiceAPlaceInTerro;
        return PS[nbrand];
	}
    else
	{
ChoiceAPlaceEverywhere:
        nbrand=rand(nbpathnode)+1;
	   if (nbrand>255) goto ChoiceAPlaceEverywhere;
        return PathNode[nbrand];
	}
}

// return amount this monsters cost (money droped where he's dead)
function int ReturnMoneyOfThisMonster(string namemonster)
{
	local int i;
	local int retour;

	retour=100;
	for(i=0;i<64;i++)
		if (MonstersString[i]==namemonster) retour=MoneyDrop[i];
	return retour;
}

// New Killed function of this new mod class
// After called the one of S_SWATGame
// Check number of alive SF
// Spawn money of killed monsters
// Check TK, do punish, etc..., ...
function Killed(Pawn Killer,Pawn Other,name DamageType)
{
	local s_MoneyPickup Money;
	local float size;

   	local	Pawn										PawnLink;
	local TOMAPlayer								P;
	local	s_Bot										B;
	local	s_NPCHostage						H;
	local	PlayerReplicationInfo		VictimPRI, KillerPRI;

	if (Other.IsA('TOMAScriptedPawn'))
		if (Other.Weapon!=None)
			if (DestroyWeaponThatMonsterCarryingWhenDie)
				Other.Weapon.Destroy();

	// punish handling
	if(killer != none && Other != none)
		if(Killer.PlayerReplicationInfo.Team == Other.PlayerReplicationInfo.Team && Killer.isA('s_Player') && Other.isA('s_Player'))
		{
			s_Player(Other).KillerID = Killer.PlayerReplicationInfo.PlayerID;
			s_Player(Other).KillTime = Level.Timeseconds;
		}

	//log("killed - Other: "$Other$" - Killer: "$Killer$" - damagetype: "$damageType);
	LogKillStats(Killer, Other, damagetype);

	if ( Other.IsA('s_NPC') )
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
//			CheckHostageWin();
		}

		Other.PlayerReplicationInfo.bIsSpectator = true;
		return;
	}

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

    if (!bKeepInventory) TOMADropInventory(Other, true);
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
				if ( Killer.PlayerReplicationInfo.Team == Other.PlayerReplicationInfo.Team )
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
	P = TOMAPlayer(Other);
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
//	CheckEndGame();
	//ReBalance();
	//log("killed - end");

	if (Other!=None)
	{
		if (Other.IsA('TOMAScriptedPawn'))
		{
			if (Killer!=None)
			{
				if ((Killer.IsA('TOMAPlayer')) || (Killer.IsA('s_Bot')))
				{
					Other.bIsPlayer=false;
					NbMonstresTue++;
					Money=Spawn(class's_MoneyPickup',self,,Other.Location);
					Money.Amount=ReturnMoneyOfThisMonster(string(other.class));
					size=Money.Amount/500;
					if (size<0.5) size=0.5;
					Money.DrawScale=size;
					Money.PickupViewScale=size;
					Killer.PlayerReplicationInfo.Score+=TOMAScriptedPawn(Other).ScoreForKill;
				}
			}
			if (string(Other.class)==MonstersString[numlevel])
			{
				NbMainMonstersKilled++;
				cptinitmonster--;
				if (NbMainMonstersKilled+cptinitmonster<NbMainMonsters)	cptinitmonster--;
			}
			if ((cptinitmonster<InitialMonsters) && (GamePeriod==GP_RoundPlaying))
				if (MonstersString[NumLevel]!="") SummonMe(MonstersString[numlevel]);
			if (DestroyKilledMonsters)
			{
				TOMAScriptedPawn(Other).SpawnGibbedCarcass();
				Other.PlayerReplicationInfo.Destroy();
			}
		}
		if ((Other.IsA('TOMAPlayer')) || (Other.IsA('TOMABot')))
		{
            if ( (Killer.IsA('TOMAScriptedPawn')) && (!Killer.IsA('TOMACow')) && (!Killer.IsA('TOMANali')) && (!Killer.IsA('TOMAFly')) && (!Killer.IsA('TOMAPupae')) && (!Killer.IsA('TOMAManta')) && (!Killer.IsA('TOMATentacle')) && (!Killer.IsA('TOMAGasBag')) && (!Killer.IsA('TOMASlith')) )
                if (Other.IsA('TOMAPlayer')) TOMAPlayer(Other).ClientPlaySound(MonsterInsult[Rand(11)],true,true);
			if ((RespawnPlayer) && (RetourneNbAlivePlayer()>0) && (GamePeriod==GP_RoundPlaying))
			{
				if (Other.IsA('TOMAPlayer')) TOMAPlayer(Other).WBR=SecBeforeRespawnPlayer;
				if (Other.IsA('TOMABot')) TOMABot(Other).WBR=SecBeforeRespawnPlayer;
			}
			if (PunishTeamKill)
				if ((Killer!=None) && (Other!=Killer))
					if (Killer.IsA('TOMAPlayer')) Killer.PlayerReplicationInfo.Score=Killer.PlayerReplicationInfo.Score-ScorePunishTeamKill;
		}
	}
	CheckEndGame();
}

// How many players are still alive
function int RetourneNbAlivePlayer()
{
	local Pawn joueur;
	local int j;

	for(joueur=Level.PawnList;joueur!=None;Joueur=Joueur.NextPawn)
	{
		if ((joueur.IsA('TOMABot')) || (joueur.IsA('TOMAPlayer')))
            if (joueur.Health>0) j++;
    }

	return j;
}

// eh...
function Vector RecherchePlace(int numplace)
{
	local PlayerStart PS;
	local int compteur;

	foreach AllActors(class'PlayerStart',PS)
	{
		if ((PS.TeamNumber==0) && (compteur==numplace))
			return PS.Location;
		compteur++;
	}
}

// New Login function just to set the new PlayerClass
function PlayerPawn Login(string Portal, string Options, out string Error, Class<PlayerPawn> SpawnClass)
{
	local PlayerPawn NewPlayer;
	local NavigationPoint StartSpot;
	local string InFace;
	local string InPassword;
	local string InSkin;
	local byte InTeam;

	// Make sure player starts in NO teams
	if ( GetIntOption(Options, "Team", 254) != 255 )
		Options = SetTeamOption(Options, "Team", "255");

	// Force new Spectator class
	if ( ParseOption(Options, "OverrideClass") ~= "Botpack.CHSpectator" )
		Options = SetTeamOption(Options, "OverrideClass", "s_SWAT.TO_Spectator");

	SpawnClass=Class'TOMAPlayer';
	bRequireReady=False;

	NewPlayer=Super(TO_DeathMatchPlus).Login(Portal,Options,Error,SpawnClass);

	if ( NewPlayer == None )
	{
		Error = "Couldn't spawn player.";
		return None;
	}

	if ( Left(NewPlayer.PlayerReplicationInfo.PlayerName, 6) == DefaultPlayerName )
	{
		if (Level.Game.WorldLog != None)
			Level.Game.WorldLog.LogSpecialEvent("forced_name_change", NewPlayer.PlayerReplicationInfo.PlayerName, NewPlayer.PlayerReplicationInfo.PlayerID, DefaultPlayerName$NumPlayers);
		ChangeName( NewPlayer, (DefaultPlayerName$NumPlayers), false );
	}

	NewPlayer.bAutoActivate = true;
	NewPlayer.GameReplicationInfo = GameReplicationInfo;

	PlayerTeamNum = NewPlayer.PlayerReplicationInfo.Team;
	return newPlayer;
}

// New SWATReduceDamage
// To prevent TK, punish FF
// And pass player to RageMode
function int SWATReduceDamage (int Damage, name DamageType, Pawn injured, Pawn instigatedBy, Vector HitLocation)
{
	if ((InstigatedBy!=None) && (injured!=None))
	{
		if (injured.IsA('TOMAPlayer'))
		{
			if (RageMode)
			{
				if (InstigatedBy.IsA('TOMAScriptedPawn'))
					if ((injured.Health-Damage<=15) && (injured.health-Damage>0))
						if (!TOMAPlayer(injured).bHasAlreadyBeInRageMode)
						{
//							Level.Game.BroadcastMessage(injured.PlayerReplicationInfo.PlayerName $ " "$IsInRageModeText);
                            BroadcastLocalizedMessage(class'TOMAMessage',19,injured.PlayerReplicationInfo);
							TOMAPlayer(injured).PassInRageModeNow();
						}
			}
			if ((InstigatedBy.IsA('TOMAPlayer')) && (PunishFriendlyFire) && (injured!=InstigatedBy)) InstigatedBy.PlayerReplicationInfo.Score=InstigatedBy.PlayerReplicationInfo.Score-ScorePunishFriendlyFire;
		}
	}
	return Super.SWATReduceDamage(Damage,DamageType,injured,InstigatedBy,HitLocation);
}

// Set new GameReplicationInfo of this mod class
function InitGameReplicationInfo ()
{
	local TOMAGameReplicationInfo GRI;

	Super.InitGameReplicationInfo();
	GRI=TOMAGameReplicationInfo(GameReplicationInfo);
	GRI.RoundStarted=RemainingTime;
	GRI.RoundDuration=RoundDuration;
	GRI.bAllowGhostCam=bAllowGhostCam;
	GRI.bMirrorDamage=bMirrorDamage;
	GRI.bEnableBallistics=bEnableBallistics;
	GRI.FriendlyFireScale=FriendlyFireScale * 100;
	GRI.bPlayersBalanceTeams=bPlayersBalanceTeams;
	GRI.bAllowRadar=bAllowRadar;
	GRI.bRespawnPlayer=RespawnPlayer;
	GRI.bEnableMagic=bEnableMagic;
}

// Check if it's the end of round
// And set who is the winner if yes
function CheckEndGame()
{
    local bool WrongLevel,Full;
    local byte t;

	if (nbmonstrestue>=NbMonstersKilledForEndRound[numlevel])
	{
        AlreadyPlayed[numlevel]=1;
        if (EnableVote) CleanVote();
		CleanUp();
		SetWinner(1);
		BroadcastLocalizedMessage(class'TOMAMessage',18);
		EndGame("Terrorists exterminated!");
		if ((NextMonster!=255) && (EnableVote))
		{
            numlevel=NextMonster;
            NextMonster=255;
		}
		else
		{
            if (numlevel==MaxLevel)
            {
                healthmult++;
                SaveConfig();
                numlevel=StartAtLevel;
                if (RandomMonster) numlevel=Rand(NbDifferentMonsters)+1;
                    else if (changemapwhenlevelend) GamePeriod=GP_PostMatch;
            }
            else
            {
                numlevel++;
                if (numlevel>MaxLevel) numlevel=0;
                if (RandomMonster) numlevel=Rand(NbDifferentMonsters)+1;
            }
            if (RandomMonster)
            {
                if (AlreadyPlayed[numlevel]>0) WrongLevel=True;
                full=true;
                for (t=0;t<64;t++)
                    if (AlreadyPlayed[t]==0) Full=false;
                if (Full)
                    for (t=0;t<64;t++)
                        AlreadyPlayed[t]=0;
            }
ChoiceNextLevelMonster:
            if (WrongLevel)
            {
                numlevel++;
                if (numlevel>MaxLevel) numlevel=0;
                if (RandomMonster) numlevel=Rand(NbDifferentMonsters)+1;
                WrongLevel=False;
            }
            if ((instr(Caps(MonstersString[numlevel]),"DEVILFISH")>0) || (instr(Caps(MonstersString[numlevel]),"SQUID")>0) || (instr(Caps(MonstersString[numlevel]),"PARENTBLOB")>0) || (instr(Caps(MonstersString[numlevel]),"TOMAQUEEN")>0) || (AlreadyPlayed[numlevel]>0))
            {
                WrongLevel=True;
                goto ChoiceNextLevelMonster;
            }
        }
	}

	if (EndRoundWhenHalfSFDied)
	{
		if (RetourneNbAlivePlayer()<=(Teams[1].Size/2))
		{
			CleanUp();
			SetWinner(0);
            BroadcastLocalizedMessage(class'TOMAMessage',1);
//			SendMessageTOAllPlayers(looseMsg);
			EndGame("Special Forces exterminated!");
		}
	}
	if (RetourneNbAlivePlayer()==0)
	{
//		CleanUp();
		SetWinner(0);
        BroadcastLocalizedMessage(class'TOMAMessage',1);
//		SendMessageTOAllPlayers(looseMsg);
		EndGame("Special Forces exterminated!");
	}
}

// For Share System
// return how many money have a team (count money of all players)
// Doesn't work ?
function int MoneyOfSF()
{
	local S_Player_T joueur;
	local s_Bot lebot;
	local int total;

	total=0;
	foreach AllActors(class'S_Player_T',joueur)
		if (joueur.PlayerReplicationInfo.team==1) total+=joueur.money;
	foreach AllActors(class'S_Bot',lebot)
		if (lebot.PlayerReplicationInfo.team==1) total+=lebot.money;
	return total;
}

// For Share System
// Set new money to players of a team
// Doesn't work ?
function ShareForAllSF(int montant)
{
	local S_Player_T joueur;
	local s_Bot lebot;

	foreach AllActors(class'S_Player_T',joueur)
		if (joueur.PlayerReplicationInfo.team==1) joueur.money=montant;
	foreach AllActors(class'S_bot',lebot)
		if (lebot.PlayerReplicationInfo.team==1) lebot.money=montant;
}

// New killinventory function to prevent special weapons destroy
final function KillTOMAInventory(Pawn P,optional bool buymenu)
{
	local Inventory Inv;
	local Inventory InvTmp;

	for (Inv=P.Inventory;Inv != None ;Inv=InvTmp)
	{
		InvTmp=Inv.Inventory;
		if ((!buymenu) || (Inv.Class!=Class's_C4'))
			Inv.Destroy();
	}
	P.Weapon=None;
}

// New buy function
// To support new functions and terrorists weapons to SF
final function s_weapon BuyTOMAWeapon (Pawn P, int WeaponNum, optional bool nocheck)
{
	local Class<Weapon> WeaponClass;
	local Weapon NewWeapon;
	local int price;
	local int i;
	local Texture NewSkin;
	local Inventory Inv;
	local Vector X;
	local Vector Y;
	local Vector Z;
	local string classweapon;

	if ((!nocheck) && (!TOMAGameReplicationInfo(GameReplicationInfo).NewWeapons) && (!TOMAGameReplicationInfo(GameReplicationInfo).TerroristsWeapons))
		if ((Class'TO_WeaponsHandler'.Default.WeaponStr[WeaponNum]=="") || (!Class'TO_WeaponsHandler'.static.IsTeamMatch(P,WeaponNum)) && (!ShouldWeaponBeShown(Class'TO_WeaponsHandler'.Default.WeaponStr[WeaponNum])) || (ShouldWeaponBeHidden(Class'TO_WeaponsHandler'.Default.WeaponStr[WeaponNum])))
			return none;
	classweapon=Class'TO_WeaponsHandler'.Default.WeaponStr[WeaponNum];
	if (TOMAGameReplicationInfo(GameReplicationInfo).NewWeapons)
		classweapon=Class'TOMAWeaponsHandler'.Default.WeaponStr[WeaponNum];
	WeaponClass=Class<Weapon>(DynamicLoadObject(classweapon,Class'Class'));
	if ((P.FindInventoryType(WeaponClass)!=None) || (P.IsA('S_Player')) && ((S_Player(P).bNotPlaying) || (S_Player(P).bBuyingWeapon)))
		return none;
	if ((WeaponNum==19) || (WeaponNum==12) || (WeaponNum==13) || (WeaponNum==14))
	{
		if (TOMAPlayer(P).NbSpecialNade==0)
		{
			TOMAPlayer(P).ClientMessage(LimitSpecialNadeExceed);
			return none;
		} else TOMAPlayer(P).NbSpecialNade--;
	}
 	if (P.IsA('S_Player'))
		S_Player(P).bBuyingWeapon=True;
	NewWeapon=Spawn(WeaponClass);
	if (NewWeapon==None)
	{
		if ( P.IsA('S_Player') )
			S_Player(P).bBuyingWeapon=False;
		return none;
	}
	if ((!HaveMoney(P,S_Weapon(NewWeapon).price)) || (!NewWeapon.IsA('S_Weapon')))
	{
		NewWeapon.Destroy();
		if (P.IsA('S_Player'))
			S_Player(P).bBuyingWeapon=False;
		return none;
	}
	for (Inv=P.Inventory;Inv != None ;Inv=Inv.Inventory)
		if ((Inv!=NewWeapon) && (Inv.IsA('S_Weapon')) && (S_Weapon(Inv).WeaponClass!=0) && (S_Weapon(Inv).WeaponClass==S_Weapon(NewWeapon).WeaponClass))
		{
			P.GetAxes(P.Rotation,X,Y,Z);
			S_Weapon(Inv).DropFrom(P.Location+0.80*P.CollisionRadius*X+(-0.50*P.CollisionRadius*Y));
		}
	NewWeapon.RespawnTime=0;
	NewWeapon.GiveTo(P);
	if (S_Weapon(NewWeapon).bHasMultiSkins)
		S_Weapon(NewWeapon).SetSkins();
	NewWeapon.PlayIdleAnim();
	NewWeapon.GotoState('Idle');
	S_Weapon(NewWeapon).ForceStillFrame();
	NewWeapon.bHeldItem=True;
	NewWeapon.bTossedOut=False;
	NewWeapon.SetSwitchPriority(P);
	if (P.IsA('PlayerPawn'))
		NewWeapon.SetHand(PlayerPawn(P).Handedness);
	else
		NewWeapon.GotoState('Idle');
	P.PendingWeapon=NewWeapon;
	if (P.Weapon==None)
		P.ChangedWeapon();
	else
	{
		if (!P.Weapon.PutDown())
			P.PendingWeapon=None;
	}
	AddMoney(P,-(S_Weapon(NewWeapon).price),nocheck);
	S_Weapon(NewWeapon).RemainingClip=0;
	S_Weapon(NewWeapon).BackupClip=0;
	S_Weapon(NewWeapon).clipAmmo=0;
	S_Weapon(NewWeapon).BackClipAmmo=0;
	if (P.IsA('S_Player'))
		S_Player(P).bBuyingWeapon=False;
	return s_Weapon(NewWeapon);
}

function BeginRound()
{
    super.BeginRound();
	if ((DisableMapTimeLimit) && (DisableRoundTimeLimit)) TOMAGameReplicationInfo(GameReplicationInfo).bInfiniteTime=true; else TOMAGameReplicationInfo(GameReplicationInfo).bInfiniteTime=false;
	TOMAGameReplicationInfo(GameReplicationInfo).nbmonstersinmap=0;
	TOMAGameReplicationInfo(GameReplicationInfo).nbmonsterstokill=nbmonsterskilledforendround[numlevel];
	TOMAGameReplicationInfo(GameReplicationInfo).nameofmonster=MonstersString[numlevel];
	TOMAGameReplicationInfo(GameReplicationInfo).numlevel=numlevel;
	TOMAGameReplicationInfo(GameReplicationInfo).SecBeforeRespawnPlayer=SecBeforeRespawnPlayer;
	TOMAGameReplicationInfo(GameReplicationInfo).nbmonstersinmap=0;
	TOMAGameReplicationInfo(GameReplicationInfo).nbmonsterstokill=nbmonsterskilledforendround[numlevel];
	TOMAGameReplicationInfo(GameReplicationInfo).nameofmonster=MonstersString[numlevel];
	TOMAGameReplicationInfo(GameReplicationInfo).bFixBuyZone=BuyEverywhere;
	TOMAGameReplicationInfo(GameReplicationInfo).TerroristsWeapons=EverythingToSF;
	TOMAGameReplicationInfo(GameReplicationInfo).NewWeapons=EnableNewWeapons;
}

// new RoundEnded to prevent special weapons destroying
final function TOMARoundEnded()
{
	local Pawn P;

	CleanUp();
	NbMonstres=0;
	NbMonstresTue=0;
	cptinitmonster=0;
	NbMainMonstersKilled=0;

	if ((ShareMoneyInTeam) && (!SharedForThisRound)) ShareMoneyNow();

	for (P=Level.PawnList;P!=None;P=P.nextPawn)
	{
		if (P.IsA('TOMABot'))
		{
			TOMABot(P).RoundEnded();
			TOMABot(P).NbSpecialNade=LimitOfSpecialNade;
		}
		else
			if (P.IsA('TOMAPlayer'))
			{
				TOMAPlayer(P).RoundEnded();
    			TOMAPlayer(P).NbSpecialNade=LimitOfSpecialNade;
			}
	}
}

function RestartHimNow(Pawn PawnLink)
{
	local TO_PRI TOPRI;
	local TO_BRI TOBRI;
	local S_Player P;

    if (GamePeriod!=GP_RoundPlaying) return;

		P=S_Player(PawnLink);

			if (PawnLink.IsA('s_bot'))
			{
				TOBRI=TO_BRI(PawnLink.PlayerReplicationInfo);
				if (TOBRI!=None)
				{
					TOBRI.bEscaped=False;
					TOBRI.bIsSpectator=False;
				}
				else
					Log("RestartRound - TOBRI == None");
				s_bot(PawnLink).bNotPlaying=False;
				s_bot(PawnLink).O_Count=0;
				RestartPlayer(PawnLink);
				s_bot(PawnLink).bDead=False;
				s_bot(PawnLink).SetOrders('Freelance',None,False);
				s_bot(PawnLink).OrderObject=None;
				s_bot(PawnLink).Objective='O_DoNothing';
				s_bot(PawnLink).O_number=255;
				s_bot(PawnLink).HostageFollowing=0;
				AddDefaultInventory(PawnLink);
				s_bot(PawnLink).GotoState('BotBuying');
				if ((bRemoveCarcass) && (TOMABot(PawnLink).carc!=None)) TOMABot(PawnLink).carc.Destroy();
			}
			else if (P!=None)
			{
				TOPRI=TO_PRI(PawnLink.PlayerReplicationInfo);
				if (TOPRI!=None)
				{
					TOPRI.bEscaped=False;
					if ((Level.NetMode!=NM_Standalone) && (RoundNumber%4==0))
					{
						P.ReceiveLocalizedMessage(Class's_MessageVote',6);
						TOPRI.ClearVotes();
					}
					TOPRI.bIsSpectator=false;
				}
				else
					Log("RestartRound - TOPRI == None");
				P.bNotPlaying=False;
				P.bAlreadyChangedTeam=False;
				RestartPlayer(PawnLink);
				P.bDead=False;
				AddDefaultInventory(PawnLink);
				P.GotoState('PlayerWalking');
				P.ViewSelf();
				if ((bRemoveCarcass) && (TOMAPlayer(P).carc!=None)) TOMAPlayer(P).carc.Destroy();
			}
			else
				RestartPlayer(PawnLink);
}

// New RestartRound function
// To do some stuff for TOMA init
function RestartRound()
{
	local Pawn PawnLink;
	local TO_PRI TOPRI;
	local TO_BRI TOBRI;
	local S_Player P;
	local TO_ConsoleTimer ct;
	local TacticalOpsMapActors TOMAc;
	local S_Trigger ST;
	local s_Weapon SW;

	if (GamePeriod==GP_RoundRestarting)
		return;
	if ((RoundLimit>0) && (RoundNumber==RoundLimit))
	{
		GamePeriod=GP_PostRound;
		EndGame("Round Limit");
		return;
	}
	if ((TimeLimit>0) && (RemainingTime<=0))
	{
		GamePeriod=GP_PostRound;
		EndGame("Time Limit");
		return;
	}
	TOMARoundEnded();
	Spawn(Class'TOMARemover',self);
	GamePeriod=GP_RoundRestarting;
	RoundDelay=Default.RoundDelay;
	RoundNumber++;
	s_GameReplicationInfo(GameReplicationInfo).RoundNumber=RoundNumber;
	if (RoundNumber==RoundLimit)
		foreach AllActors(Class'S_Player',P)
			P.ReceiveLocalizedMessage(Class's_MessageRoundWinner',8);
	for (PawnLink=Level.PawnList;PawnLink!=None;PawnLink=PawnLink.nextPawn)
	{
		if (PawnLink.IsA('TOMAPlayer'))
        {
            TOMAPlayer(PawnLink).UpdateObjectives();
            TOMAPlayer(PawnLink).WBR=0;
        }
        if (PawnLink.IsA('TOMABot'))
            TOMABot(PawnLink).WBR=0;
		P=S_Player(PawnLink);
		if (!PawnLink.IsA('s_NPC'))
		{
			PawnLink.bFire=0;
			PawnLink.bAltFire=0;
			if (PawnLink.IsA('s_bot'))
			{
				TOBRI=TO_BRI(PawnLink.PlayerReplicationInfo);
				if (TOBRI!=None)
				{
					TOBRI.bEscaped=False;
					TOBRI.bIsSpectator=False;
				}
				else
					Log("RestartRound - TOBRI == None");
				s_bot(PawnLink).bNotPlaying=False;
				s_bot(PawnLink).O_Count=0;
				RestartPlayer(PawnLink);
				s_bot(PawnLink).bDead=False;
				s_bot(PawnLink).SetOrders('Freelance',None,False);
				s_bot(PawnLink).OrderObject=None;
				s_bot(PawnLink).Objective='O_DoNothing';
				s_bot(PawnLink).O_number=255;
				s_bot(PawnLink).HostageFollowing=0;
			}
			else if (P!=None)
			{
				if (P.PlayerReplicationInfo.bWaitingPlayer)
					continue;
				TOPRI=TO_PRI(PawnLink.PlayerReplicationInfo);
				if (TOPRI!=None)
				{
					TOPRI.bEscaped=False;
					if ((Level.NetMode!=NM_Standalone) && (RoundNumber%4==0))
					{
						P.ReceiveLocalizedMessage(Class's_MessageVote',6);
						TOPRI.ClearVotes();
					}
				}
				else
					Log("RestartRound - TOPRI == None");
				P.bNotPlaying=False;
				P.bAlreadyChangedTeam=False;
				RestartPlayer(PawnLink);
				P.bDead=False;
			}
			else
				RestartPlayer(PawnLink);
		}
	}
	ClearNPC();
	SetMoney();
	if (ActorManager!=None)
		ActorManager.RecoverAll();
	foreach AllActors(Class'S_Trigger',ST)
		ST.ResetTrigger();
	foreach AllActors(Class'TacticalOpsMapActors',TOMAc)
		TOMAc.RoundReset();
	foreach AllActors(Class'TO_ConsoleTimer',ct)
		ct.bActive=false;
	BeginRound();
}

// New logout functions
// To prevent logout of monsters (ex. : do not display "Warlord left the game")
// And save score of players (but this doesn't seems to work)
function Logout(Pawn Exiting)
{
	if (Exiting!=None)
	{
		if (Exiting.IsA('TOMAScriptedPawn'))
			if (Exiting.bIsPlayer) Exiting.bIsPlayer=false;
		if (Exiting.IsA('TOMAPlayer'))
        {
//            TOMAPlayer(Exiting).CheckYourMaxScore();
            CheckEndGame();
        }
	}
	Super.Logout(Exiting);
}

// New pickup query function
// For new stuff like do not pickup money if you're already full
// or for monsters, that can steal weapons of SF that are on the floor
function bool PickupQuery (Pawn Other, Inventory Item)
{
	local Mutator M;
	local byte bAllowPickup;
	local int OldAmmo;
	local Inventory	Inv;

	if (Other!=None)
	{
		if (Other.IsA('TOMAPlayer'))
			if (Item.IsA('s_MoneyPickup'))
				if (TOMAPlayer(Other).money>=MaxMoney) return false;
		if (Other.IsA('TOMAScriptedPawn'))
		{
			if (Item.IsA('S_Weapon'))
				if (!MonstersCanStealWeaponsOnTheFloor) return false; else return true;
			if (Item.IsA('TOMAHealth'))
				if (!MonstersCanStealHealthPack) return false; else return true;
		}
	}

	if ( BaseMutator.HandlePickupQuery(Other, item, bAllowPickup) )
		return (bAllowPickup == 1);

	// Hack to prevent players from picking up NullAmmo
	if ( item.IsA('NullAmmo') && Other.IsA('s_Player') )
		return false;

	if ( Other.Inventory == None )
		return true;
	else
	{
		if (item.IsA('s_weapon'))
		{
				for( Inv=Other.Inventory; Inv!=None; Inv=Inv.Inventory )
				{
					if (Inv.IsA('s_Weapon') && s_Weapon(Inv).WeaponClass == s_Weapon(Item).WeaponClass)
					{
						// Player can only carry a grenade.
						if (s_Weapon(Inv).WeaponClass == 5)
						{
							return false;
						}
						else if (Item.Class == Inv.Class)
						{
							//P = Pawn(Other);
							if (s_Weapon(Item) != None && s_Weapon(Item).bUseClip)
							{
								s_Weapon(Inv).RemainingClip += s_Weapon(Item).RemainingClip;
								if (s_Weapon(Inv).RemainingClip > s_Weapon(Inv).MaxClip)
									s_Weapon(Inv).RemainingClip = s_Weapon(Inv).MaxClip;

								if (Other.IsA('s_Player'))
									Other.ReceiveLocalizedMessage( class'PickupMessagePlus', 0, None, None, s_Weapon(Inv).Class );
								Item.PlaySound(Item.PickupSound);

								if (Level.Game.LocalLog != None)
									Level.Game.LocalLog.LogPickup(Item, Other);
								if (Level.Game.WorldLog != None)
									Level.Game.WorldLog.LogPickup(Item, Other);
							}
							Item.Destroy();
							//Item.SetRespawn();
						}
						return false;
					}
				}
				return true;

		}
		else
			return !Other.Inventory.HandlePickupQuery(Item);
	}
}

// A player have just entered, we set some little new stuff (objectives, limit of special nades,...)
function FirstConnect(TOMAPlayer who)
{
	Who.NbSpecialNade=LimitOfSpecialNade;
}

// Vote monsters system, to vote for the next type of monster as the main monster for next round
function CmdClient(string MutateString, PlayerPawn Sender)
{
	local string tt;
	local int i;

    if (Sender.bAdmin)
	{
        if (left(mutatestring,12)==" SKIP LEVEL ")
        {
            BroadcastMessage(TextSkipLevel);
            nbmonstrestue=NbMonstersKilledForEndRound[numlevel];
            CheckEndGame();
        }
		if (Left(MutateString,12)==" VOTE LEVEL ")
		{
            NextMonster=i;
//            MonstersString[numlevel+1]="TOMA21.TOMA"$RetourneNomPos(MonstersForVote,i);
			BroadcastMessage(RetourneNomPos(MonstersForVote,i)$" "$TextVoteGagne$".");
		}
		return;
	}

	if (EnableVote)
	{
		if (Left(MutateString,12)==" VOTE LEVEL ")
		{
			tt=Right(MutateString,Len(MutateString)-11);
			i=int(tt);
			if (TOMAPlayer(Sender).myvote!=i)
			{
				VoteOfThisOne[TOMAPlayer(Sender).myvote]-=1;
                TOMAPlayer(Sender).myvote=i;
                VoteOfThisOne[i]+=1;
                ResetVoteR();
                BroadcastMessage(Sender.PlayerReplicationInfo.PlayerName$" "$TextVoteFor$" : "$RetourneNomPos(MonstersForVote,i));
			}
			if (VoteOfThisOne[i]>(Teams[1].Size/2))
			{
                NextMonster=i;
//				MonstersString[numlevel+1]="TOMA21.TOMA"$RetourneNomPos(MonstersForVote,i);
				BroadcastMessage(RetourneNomPos(MonstersForVote,i)$" "$TextVoteGagne$".");
			}
		}
        if (left(mutatestring,12)==" SKIP LEVEL ")
        {
			ResetVoteR();
            VoteForSkip++;
			BroadcastMessage(Sender.PlayerReplicationInfo.PlayerName$" "$TextVoteSkipLevel);
            if (VoteForSkip>(Teams[1].Size/2))
            {
                BroadcastMessage(TextSkipLevel);
                VoteForSkip=0;
                nbmonstrestue=NbMonstersKilledForEndRound[numlevel];
                CheckEndGame();
            }
        }
	}
	if ( (bEnableMagic) && (left(mutatestring,8)=="USE MANA") )
	{
	   if (TOMAPlayer(Sender).Mana>0)
	   {
	   }
	}
}

// Change Name
// Prevent access none on monsters (already monsters with same name)
function ChangeName(Pawn Other,string S,bool bNameChange)
{
	local Pawn aPlayer;

	if (S=="")
		return;
	S=Left(S,24);
	if (Other.PlayerReplicationInfo.PlayerName~=S)
		return;
	for (aPlayer=Level.PawnList;aPlayer!=None;aPlayer=aPlayer.nextPawn)
	{
		if ((aPlayer.bIsPlayer) && (aPlayer.PlayerReplicationInfo.PlayerName~=S))
		{
			Other.ClientMessage(S$NoNameChange);
			return;
		}
	}
	Other.PlayerReplicationInfo.OldName=Other.PlayerReplicationInfo.PlayerName;
	Other.PlayerReplicationInfo.PlayerName=S;
	if ((bNameChange) && (!Other.IsA('Spectator')))
		BroadcastLocalizedMessage(DMMessageClass,2,Other.PlayerReplicationInfo);
	if (LocalLog!=None)
		LocalLog.LogNameChange(Other);
	if (WorldLog!=None)
		WorldLog.LogNameChange(Other);
}

// New GiveBomb function
// To do not give it to a monsters LOL
function GiveBomb()
{
	bBombGiven=true;
	return;
}

// New C4Defused function
// For SF : -1- do not end round
//          -2- Take it in his inventory
final function TOMAC4Defused(Actor Instigator)
{
	if (GamePeriod!=GP_RoundPlaying)
		return;

	if ((Pawn(Instigator)!=None) && (Pawn(Instigator).PlayerReplicationInfo!=None))
		BroadcastLocalizedMessage(class's_MessageRoundWinner',13,Pawn(Instigator).PlayerReplicationInfo);

	GiveWeapon(Pawn(Instigator),"TOMA21.TOMAC4");
}

// New set of default inventory of players
function AddDefaultInventory(pawn PlayerPawn)
{
	local Bot B;
    local Weapon Old;

	if (PlayerPawn.IsA('s_Player') && (PlayerPawn.PlayerReplicationInfo.bWaitingPlayer))
		return;

    old=PlayerPawn.Weapon;

	GiveTeamWeapons(PlayerPawn);
	if (PlayerPawn.IsA('TOMAPlayer') && (TOMAPlayer(PlayerPawn).money==0)) AddMoney(PlayerPawn,MoneyStart);
	if (PlayerPawn.IsA('TOMABot') && (TOMABot(PlayerPawn).money==0)) AddMoney(PlayerPawn,MoneyStart);
	B=Bot(PlayerPawn);
	if (B!=None)
		B.bHasImpactHammer=false;
	BaseMutator.ModifyPlayer(PlayerPawn);
	if (old==None) PlayerPawn.SwitchToBestWeapon();
}

final function TOMAC4Exploded( bool bExplodedInBombingZone, Actor BombingZone )
{
	local byte Team,number;

	if ((SI == None) || (GamePeriod!=GP_RoundPlaying))
		return;

	if (bSinglePlayer)
		C4ExplodedPlus(bExplodedInBombingZone,BombingZone);

	Team=0;

	for (number=0;number<10;number++)
		if (SI.GetTeamObjectivePub(Team,number).ObjectiveType==O_C4TargetLocation)
		{
			if ((BombingZone==None) || (SI.GetTeamObjectivePriv(Team,number).ActorTarget==None)	|| (SI.GetTeamObjectivePriv(Team,number).ActorTarget==BombingZone))
			{
				if (bSinglePlayer && (GetbSpawnEndGameTriggers()>0))
					Team=Team;
/*				else
					BroadcastLocalizedMessage(class's_MessageRoundWinner',10);
//				SetAccomplishedObjective(Team,number);*/
				return;
			}
		}
}

function SpawnEvidence()
{
	local s_EvidenceStartPoint E;
    local s_SpecialItemStartPoint S;
    local s_ZoneControlPoint B;

    if (!bHealthPack) return;

	foreach allactors(class's_EvidenceStartPoint',E)
        Spawn(class'TOMAHealth',,,E.Location);
	foreach allactors(class's_SpecialItemStartPoint',S)
        Spawn(class'TOMAHealth',,,S.Location);
	foreach allactors(class's_ZoneControlPoint',B)
        if (B.bBombingZone) Spawn(class'TOMAHealth',,,B.Location);
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

	NewBot = Spawn(class'TOMABot',,,StartSpot.Location,StartSpot.Rotation);

	if (NewBot==None)
		log("Couldn't spawn player at "$StartSpot);

	if (NewBot!=None)
	{
		NewBot.PlayerReplicationInfo.PlayerID=CurrentID++;
		NewBot.PlayerReplicationInfo.Team=1;
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
		TOMABot(NewBot).NbSpecialNade=LimitOfSpecialNade;
	}
	return NewBot;
}

final function TOMAChangePModel( Pawn P, int num, int team, bool bDie)
{
	local	Actor	StartPoint;
	local	byte	OldTeam;
	local	s_Player	sP;
	local	bool	bNoWeapons, bChangeModel, bChangeTeam, bNotPlaying;

	if ((bFirstKill) && (TOMAPlayer(P).PlayerModel==0)) TOMAPlayer(P).WBR=SecBeforeRespawnPlayer;

	if ( bBalancing )
		return;

	sP = s_Player(P);

	OldTeam = P.PlayerReplicationInfo.Team;
	bChangeTeam = OldTeam != team;

	// Allow only one team change per round.
	if (sP != None)
	{
		if ( sP.bAlreadyChangedTeam && bChangeTeam )
		{
			sP.ReceiveLocalizedMessage(class's_MessageVote', 7);
			return;
		}

		if ( !sP.PlayerReplicationInfo.bWaitingPlayer && bChangeTeam )
			sP.bAlreadyChangedTeam = true;

		bNotPlaying = sP.bNotPlaying || sP.PlayerReplicationInfo.bWaitingPlayer;
		bNoWeapons = sP.bDead || sP.PlayerReplicationInfo.bWaitingPlayer;
		bChangeModel = (num == 255) || (num != sP.PlayerModel);

		// Prevent player from dying during team/model switch?
		if ( bNotPlaying || (!bChangeTeam) || (GamePeriod != GP_RoundPlaying) )
			bDie = false;
	}
	else if ( P.PlayerReplicationInfo.bWaitingPlayer || P.PlayerReplicationInfo.bIsSpectator )
	{
		if (P.IsA('TOMAPlayer')) TOMAPlayer(P).WBR=SecBeforeRespawnPlayer;
		bDie = false;
	}

	//log("TO_GameBasics::ChangePModel - P"@P.GetHumanName()@"num"@num@"team"@team@"bDie"@bDie);

	if ( bDie )
	{
		P.TakeDamage(500000, None, P.Location, vect(0,0,0), 'ChangedTeam');
	}
	else
	{
		//log("TO_GameBasics::ChangePModel - don't kill");
		if ( bChangeTeam && !bNoWeapons )
		{
			//log("TO_GameBasics::ChangePModel - drop inventory");
			// Drop specific inventory
			DropInventory(P, false);
		}
	}

	if ( bChangeTeam )
		ChangeTeam(P, team);

	// Change Team successful, change model
	if ( (P.PlayerReplicationInfo.Team == Team) && (Team<3) )
	{
		if ( num == 255 )
		{
			if ( team == 1 )
				SetRandomSFModel(P);
			else
				SetRandomTerrModel(P);
		}
		else
			TOMAChangeModel(P, num);

		// Livefeeds of current team.
		if ( bChangeTeam && (P.GetStateName() == 'PlayerSpectating') )
			PlayerPawn(P).Fire(0.0);
	}

	// giving default pistol
	if ( !bDie && bChangeTeam && !bNoWeapons && !bNotPlaying )
	{
		GiveTeamWeapons(P);
		if ( P.Weapon == None )
			P.SwitchToBestWeapon();
	}

	FirstConnect(TOMAPlayer(P));
}

final function TOMAChangeModel( Pawn P, int num)
{
/*	log("set model"@class'TOPModels.TO_ModelHandler'.default.ModelMesh[num]
		@"num:"@num@"to"@P@"name:"@class'TOPModels.TO_ModelHandler'.default.ModelName[num]
		@"Skin1:"@class'TOPModels.TO_ModelHandler'.default.Skin1[num]
		@"Skin2:"@class'TOPModels.TO_ModelHandler'.default.Skin2[num]
		@"Skin3:"@class'TOPModels.TO_ModelHandler'.default.Skin3[num]
		@"Skin4:"@class'TOPModels.TO_ModelHandler'.default.Skin4[num]);
*/
	num = class'TOMA21.TOMAModelHandler'.static.TOMADressModel(P, num);

	// Set model num to pawn
	if ( P.IsA('s_Bot') )
	{
		s_Bot(P).PlayerModel = num;
		s_BotInfo(BotConfig).CheckBotName(Bot(P));
	}
	else if (P.IsA('s_Player'))
		s_Player(P).PlayerModel = num;
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

function DiscardInventory(Pawn Other)
{
    if (bKeepInventory) return; else super.DiscardInventory(Other);
}

final function TOMAKillInventory(Pawn P,optional bool buymenu)
{
	local Inventory Inv,InvTmp;

    if (bKeepInventory) return;
	Inv=P.Inventory;
	While (Inv!=None)
	{
		InvTmp=Inv.Inventory;
		if (!buymenu)
			Inv.Destroy();
		Inv=InvTmp;
	}

	P.Weapon=None;
}

final function TOMADropInventory(Pawn Other,bool bDropMoney)
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


	TOMAKillInventory(Other);

	if (P!=None)
	{
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
	HUDType=class'TOMA21.TOMAHud'
	GameReplicationInfoClass=class'TOMA21.TOMAGameReplicationInfo'
	bNoMonsters=False
	BeaconName="Tactical Ops:Monster-Attack"
	GameName="Tactical Ops:Monster-Attack"
	bBalanceTeams=False
	bPlayersBalanceTeams=False
	MonstersCanStealWeaponsOnTheFloor=True
	MonstersCanStealHealthPack=true
	LimitSpecialNadeExceed="You can't buy more grenades, limit exceed for this round"
	MapListType=class'TOMA21.TOMAMapList'
	Difficulty=3
	FixMutatorReplicationBugUT436=True

    MonstersString(0)="TOMA21.TOMACow"
    CanBeRandom(0)=0
    MoneyDrop(0)=50
    NbMonstersKilledForEndRound(0)=100

    MonstersString(1)="TOMA21.TOMANali"
    CanBeRandom(1)=0
    MoneyDrop(1)=50
    NbMonstersKilledForEndRound(1)=100

    MonstersString(2)="TOMA21.TOMANaliPriest"
    CanBeRandom(2)=0
    MoneyDrop(2)=50
    NbMonstersKilledForEndRound(2)=100

    MonstersString(3)="TOMA21.TOMAFly"
    CanBeRandom(3)=1
    MoneyDrop(3)=100
    NbMonstersKilledForEndRound(3)=100

    MonstersString(4)="TOMA21.TOMAPupae"
    CanBeRandom(4)=0
    MoneyDrop(4)=100
    NbMonstersKilledForEndRound(4)=100

    MonstersString(5)="TOMA21.TOMATentacle"
    CanBeRandom(5)=1
    MoneyDrop(5)=100
    NbMonstersKilledForEndRound(5)=100

    MonstersString(6)="TOMA21.TOMAManta"
    CanBeRandom(6)=1
    MoneyDrop(6)=100
    NbMonstersKilledForEndRound(6)=100

    MonstersString(7)="TOMA21.TOMACaveManta"
    CanBeRandom(7)=1
    MoneyDrop(7)=100
    NbMonstersKilledForEndRound(7)=100

    MonstersString(8)="TOMA21.TOMAGiantManta"
    CanBeRandom(8)=1
    MoneyDrop(8)=300
    NbMonstersKilledForEndRound(8)=100

    MonstersString(9)="TOMA21.TOMAGasbag"
    CanBeRandom(9)=1
    MoneyDrop(9)=250
    NbMonstersKilledForEndRound(9)=100

    MonstersString(10)="TOMA21.TOMAGiantGasBag"
    CanBeRandom(10)=1
    MoneyDrop(10)=400
    NbMonstersKilledForEndRound(10)=100

    MonstersString(11)="TOMA21.TOMASlith"
    CanBeRandom(11)=0
    MoneyDrop(11)=300
    NbMonstersKilledForEndRound(11)=100

    MonstersString(12)="TOMA21.TOMABrute"
    CanBeRandom(12)=0
    MoneyDrop(12)=400
    NbMonstersKilledForEndRound(12)=100

    MonstersString(13)="TOMA21.TOMAMercenary"
    CanBeRandom(13)=0
    MoneyDrop(13)=300
    NbMonstersKilledForEndRound(13)=100

    MonstersString(14)="TOMA21.TOMAMercenaryElite"
    CanBeRandom(14)=0
    MoneyDrop(14)=500
    NbMonstersKilledForEndRound(14)=100

    MonstersString(15)="TOMA21.TOMAKrall"
    CanBeRandom(15)=0
    MoneyDrop(15)=250
    NbMonstersKilledForEndRound(15)=100

    MonstersString(16)="TOMA21.TOMAKrallElite"
    CanBeRandom(16)=0
    MoneyDrop(16)=300
    NbMonstersKilledForEndRound(16)=100

    MonstersString(17)="TOMA21.TOMASkaarjBerserker"
    CanBeRandom(17)=0
    MoneyDrop(17)=400
    NbMonstersKilledForEndRound(17)=50

    MonstersString(18)="TOMA21.TOMASkaarJLord"
    CanBeRandom(18)=0
    MoneyDrop(18)=400
    NbMonstersKilledForEndRound(18)=50

    MonstersString(19)="TOMA21.TOMAIceSkaarj"
    CanBeRandom(19)=0
    MoneyDrop(19)=400
    NbMonstersKilledForEndRound(19)=50

    MonstersString(20)="TOMA21.TOMASkaarjInfantry"
    CanBeRandom(20)=0
    MoneyDrop(20)=350
    NbMonstersKilledForEndRound(20)=50

    MonstersString(21)="TOMA21.TOMASkaarjScout"
    CanBeRandom(21)=0
    MoneyDrop(21)=400
    NbMonstersKilledForEndRound(21)=50

    MonstersString(22)="TOMA21.TOMASkaarjGunner"
    CanBeRandom(22)=0
    MoneyDrop(22)=350
    NbMonstersKilledForEndRound(22)=50

    MonstersString(23)="TOMA21.TOMASkaarjTrooper"
    CanBeRandom(23)=0
    MoneyDrop(23)=350
    NbMonstersKilledForEndRound(23)=50

    MonstersString(24)="TOMA21.TOMASkaarjOfficer"
    CanBeRandom(24)=0
    MoneyDrop(24)=350
    NbMonstersKilledForEndRound(24)=50

    MonstersString(25)="TOMA21.TOMASkaarjWarrior"
    CanBeRandom(25)=0
    MoneyDrop(25)=350
    NbMonstersKilledForEndRound(25)=50

    MonstersString(26)="TOMA21.TOMASkaarjSniper"
    CanBeRandom(26)=0
    MoneyDrop(26)=350
    NbMonstersKilledForEndRound(26)=50

    MonstersString(27)="TOMA21.TOMASkaarJAssassin"
    CanBeRandom(27)=0
    MoneyDrop(27)=400
    NbMonstersKilledForEndRound(27)=50

    MonstersString(28)="TOMA21.TOMAWarlord"
    CanBeRandom(28)=1
    MoneyDrop(28)=1000
    NbMonstersKilledForEndRound(28)=30

    MonstersString(29)="TOMA21.TOMATitan"
    CanBeRandom(29)=0
    MoneyDrop(29)=1500
    NbMonstersKilledForEndRound(29)=15

    MonstersString(30)="TOMA21.TOMAStoneTitan"
    CanBeRandom(30)=0
    MoneyDrop(30)=1500
    NbMonstersKilledForEndRound(30)=15

    MonstersString(31)="TOMA21.TOMAChrek"
    CanBeRandom(31)=0
    MoneyDrop(31)=300
    NbMonstersKilledForEndRound(31)=50

    MonstersString(32)="TOMA21.TOMAAlienQueen"
    CanBeRandom(32)=0
    MoneyDrop(32)=300
    NbMonstersKilledForEndRound(32)=50

    MonstersString(33)="TOMA21.TOMABug"
    CanBeRandom(33)=0
    MoneyDrop(33)=300
    NbMonstersKilledForEndRound(33)=50

    MonstersString(34)="TOMA21.TOMAQueen"
    CanBeRandom(34)=0
    MoneyDrop(34)=2000
    NbMonstersKilledForEndRound(34)=10

    MonstersString(35)="TOMA21.TOMADevilFish"
    CanBeRandom(35)=1
    MoneyDrop(35)=50

    MonstersString(36)="TOMA21.TOMASquid"
    CanBeRandom(36)=1
    MoneyDrop(36)=100

    PunishTeamKill=True
    ScorePunishTeamKill=5
    PunishFriendlyFire=False
    ScorePunishFriendlyFire=25

    NewMaxMoney=99999
	MoneyStart=1000
    NewRescueHostagePrice=5000
    NewRescueTeamHostagePrice=500
    NewKillPrice=250

    EndRoundWhenHalfSFDied=False
    NbSFKilledForEndRound=0
	SecBeforeRespawnPlayer=20
    bShowEffectInvulnerable=False
	SecGodMod=5
    RespawnPlayer=True
    bKeepInventory=False

    EnableNewWeapons=True
    BuyEverywhere=True
    RageMode=False
    EverythingToSF=True
    LimitOfSpecialNade=255
    ShareMoneyInTeam=False
    bRandomWeaponsForMonsters=True
    WeaponNumberForMonster=0

    RandomMonster=False
    StartAtLevel=0
    MaxLevel=33
    InitialMonsters=32
    nbMapMonster=64
    NbMainMonsters=64
	MonstersCanClimbWall=False
	MonstersCanHaveWeapon=True
	DestroyWeaponThatMonsterCarryingWhenDie=True
    HealthMult=1
    EnableCanBeRandom=True
    RandomSpawn=True
    SecBeforeRandomSpawn=5
    DisplayMonsterLoginMessage=True
    DestroyKilledMonsters=True

	TerroristStartPoint=True
    UseINIMonstersStart=True
    ChangeMapWhenLevelEnd=True
    DisableMapTimeLimit=true
    DIsableRoundTimeLimit=true

    EnableVote=True
	MonstersForVote="Cow,Behemoth,Brute,CaveManta,Fly,Gasbag,GiantGasBag,GiantManta,IceSkaarj,Krall,KrallElite,LeglessKrall,Manta,Mercenary,MercenaryElite,Nali,NaliPriest,Pupae,Skaarj,SkaarjAssassin,SkaarjBerserker,SkaarjGunner,SkaarjInfantry,SkaarjLord,SkaarjOfficer,SkaarjScout,SkaarjSniper,SkaarjTrooper,SkaarjWarrior,Slith,StoneTitan,Tentacle,Titan,Warlord,Chrek,AlienQueen,Bug"

    SD1="Monsters have invaded the earth"
    SFO1="Kill all monsters"
    SFO2="Rescue any civilians if they are present and still alive"
    SFO3=""
    SFO4=""
    ScenarioNameText="Tactical-Ops:Monsters-Attack"
    LevelText="Level"
    NamedText="Named"
    Currentleveltext="Current level"
    Monsterstokilltext="Monsters to kill"
    MonstersInMapText="Monsters in map"
    LoginMonstersText="entered the arena"
    TextVoteGagne="won"
	TextVoteSkipLevel="voted for skip current level";
    TextVoteFor="voted for"
    TextSkipLevel="Skip current level"
    MinAllowedScore=0
    FriendlyFireScale=0.000000
    bNoMonsters=False
    PreRoundDuration1=7
    bMirrorDamage=False
    bExplosionFF=False
    bAllowPunishTK=False
    bAllowGhostCam=True
    bAllowBehindView=True
    bRemoveCarcass=True
    bAllowRadar=True
    bHealthPack=True
	MonsterInsult(0)=Sound'TOMASounds21.Monsters.FRboom'
	MonsterInsult(1)=Sound'TOMASounds21.Monsters.FRdiehuman'
	MonsterInsult(2)=Sound'TOMASounds21.Monsters.FReliminatec'
	MonsterInsult(3)=Sound'TOMASounds21.Monsters.FRfearme'
	MonsterInsult(4)=Sound'TOMASounds21.Monsters.FRhadtohurt'
	MonsterInsult(5)=Sound'TOMASounds21.Monsters.FRinferior'
	MonsterInsult(6)=Sound'TOMASounds21.Monsters.FRobsolete'
	MonsterInsult(7)=Sound'TOMASounds21.Monsters.FRrunhuman'
	MonsterInsult(8)=Sound'TOMASounds21.Monsters.FRsuperior'
	MonsterInsult(9)=Sound'TOMASounds21.Monsters.FRuseless'
	MonsterInsult(10)=Sound'TOMASounds21.Monsters.FRyoudie'
}

