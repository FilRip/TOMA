class KeepTheFlag extends Mutator;

var int TerroScore,SFScore;
var int CurrentRound;
var() config bool bRespawnPlayer;
var() config bool bDoGlow;
var() config string MapName[255];
var() config vector MapLocation[255];
var() config bool bCarrierCantFire;
var KTF_Flag TheFlag;
var byte CptIAR[64];
var int IDCptIAR[64];
var() config bool bShowEffectInvulnerable;
var() config byte SecGodMod;
var() config bool bRemoveCarcass;

replication
{
    reliable if (Role==Role_Authority)
        TerroScore,SFScore;
}

function PreBeginPlay()
{
    local KTF_AddHUD MyHud;

    super.PreBeginPlay();
    CreateFlag();
    SetTimer(1,true);
    Spawn(class'KTF_AddHUD');
}

function CreateFlag()
{
    local int i;

    for (i=0;i<255;i++)
        if (MapName[i]==Level.Title)
        {
            TheFlag=Spawn(class'KTF_Flag',,,MapLocation[i]);
            TheFlag.mutowner=self;
            TheFlag.Home=MapLocation[i];
            TheFlag.bDoGlow=bDoGlow;
            TheFlag.bRemoveWeapons=bCarrierCantFire;
        }
}

function MyResetterActor()
{
	local s_NPCHostage lesotages;
	local TO_ConsoleTimer CT;
    local s_OICW oicw;

	foreach AllActors(class's_NPCHostage',lesotages)
		lesotages.Destroy();

	foreach AllActors(class'TO_ConsoleTimer',ct)
		ct.Destroy();

	foreach AllActors(class's_OICW',oicw)
		oicw.Destroy();

    TerroScore=0;
    SFScore=0;
    if (TheFlag!=None)
    {
        if (TheFlag.Carrier!=None)
        {
            ResetAmbientToPlayer(TheFlag.Carrier);
            TheFlag.Carrier.PlayerReplicationInfo.HasFlag=None;
            TheFlag.Carrier=None;
        }
        TheFlag.SetLocation(TheFlag.Home);
        TheFlag.GotoState('HomeBase');
    }
}

function Timer()
{
    local Pawn P;

	if (CurrentRound!=s_SWATGame(Level.Game).RoundNumber)
	{
		CurrentRound=s_SWATGame(Level.Game).RoundNumber;
		MyResetterActor();
	}

	if (s_SWATGame(Level.Game).GamePeriod==GP_RoundPlaying)
    {
    // Respawn Player
        if (bRespawnPlayer)
        {
            for (P=Level.PawnList;P!=None;P=P.nextPawn)
            {
                if ((P.IsA('s_Player_T')) && (P.IsInState('PlayerSpectating')))
                    RestartPlayer(P);
                if ((P.IsA('s_Bot')) && (s_Bot(P).PlayerReplicationInfo.bIsSpectator))
                    RestartPlayer(P);
            }
            DecrementeLesCompteurs();
        }

    // Score
        if ((TheFlag!=None) && (TheFlag.Carrier!=None) && (TheFlag.Carrier.PlayerReplicationInfo!=None))
            if (TheFlag.Carrier.PlayerReplicationInfo.Team==0) TerroScore++; else if (TheFlag.Carrier.PlayerReplicationInfo.Team==1) SFScore++;

    // Intercepte la fin du round
        if ((s_SWATGame(Level.Game).RoundStarted - s_SWATGame(Level.Game).RemainingTime >= (s_SWATGame(Level.Game).RoundDuration * 60)-1) && (TheFlag!=None))
        {
            if (TerroScore>SFScore)
            {
                BroadcastLocalizedMessage(class'KTF_Message',18);
                S_SWATGame(Level.Game).SetWinner(0);
                S_SWATGame(Level.Game).EndGame("Terrorists win the round");
            }
            else
            {
                if (TerroScore<SFScore)
                {
                    BroadcastLocalizedMessage(class'KTF_Message',19);
                    S_SWATGame(Level.Game).SetWinner(1);
                    S_SWATGame(Level.Game).EndGame("Special Forces win the round");
                }
                else
                {
                    BroadcastLocalizedMessage(class'KTF_Message',0);
                    S_SWATGame(Level.Game).SetWinner(2);
                    S_SWATGame(Level.Game).EndGame("Draw Game");
                }
            }
        }
    }
}

function DropFlag()
{
    ResetAmbientToPlayer(TheFlag.Carrier);
    TheFlag.Carrier.PlayerReplicationInfo.HasFlag=None;
    TheFlag.SetLocation(TheFlag.Carrier.Location);
    TheFlag.Carrier=None;
    TheFlag.GotoState('Dropped');
}

function ResetAmbientToPlayer(Pawn P)
{
    if (!bDoGlow) return;
	P.AmbientGlow=2;
	P.LightEffect=LE_None;
	P.LightRadius=0;
	P.LightType=LT_None;
	P.LightBrightness=0;
	P.LightSaturation=0;
	P.LightHue=0;
}

function byte NbInTeam(byte i,bool alive)
{
	local Pawn joueur;
	local byte j;

	for (joueur=Level.PawnList;joueur!=None;joueur=joueur.NextPawn)
	{
        if ((joueur.IsA('s_Player_T')) || (joueur.IsA('s_Bot')))
        {
            if ((joueur.PlayerReplicationInfo!=None) && (joueur.PlayerReplicationInfo.Team==i))
            {
                j++;
                if (s_Player_T(joueur)!=None)
                {
                    if ((s_Player_T(joueur).Health<=0) && (alive))
                        j--;
                }
                else
                {
                    if (s_Bot(joueur)!=None)
                        if ((s_Bot(joueur).Health<=0) && (alive))
                            j--;
                }
            }
        }
	}
	return j;
}

function ScoreKill(Pawn Killer, Pawn Other)
{
//    if (bRespawnPlayer) return;
    if ((NbInTeam(0,true)==0) || (NbInTeam(1,true)==0))
    {
            if (TerroScore>SFScore)
            {
                BroadcastLocalizedMessage(class'KTF_Message',18);
                S_SWATGame(Level.Game).SetWinner(0);
                S_SWATGame(Level.Game).EndGame("Terrorists win the round");
            }
            else
            {
                if (TerroScore<SFScore)
                {
                    BroadcastLocalizedMessage(class'KTF_Message',19);
                    S_SWATGame(Level.Game).SetWinner(1);
                    S_SWATGame(Level.Game).EndGame("Special Forces win the round");
                }
                else
                {
                    BroadcastLocalizedMessage(class'KTF_Message',0);
                    S_SWATGame(Level.Game).SetWinner(2);
                    S_SWATGame(Level.Game).EndGame("Draw Game");
                }
            }
    }
    if (Other!=None)
    {
        if (Other.PlayerReplicationInfo.HasFlag!=None)
            DropFlag();
    }
    if ((Other!=None) && ((Killer==None) || (Killer==Other)))
        s_SWATGame(Level.Game).AddMoney(Other,-1000);
	if (NextMutator!=None)
		NextMutator.ScoreKill(Killer, Other);
}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	if (Other.IsA('s_C4')) return false;
	if ((Other.IsA('s_PlayerCarcass')) && (bRemoveCarcass)) return false;
//	if ((Other.IsA('s_Player_T')) && (bCarrierCantFire)) GiveNewP(s_Player(Other));
    return true;
}

/*function GiveNewP(s_Player Other)
{
    local KTF_PZone no;

    no=Spawn(class'KTF_PZone');
    no.me=Other;
    Other.PZone.Destroy();
    Other.PZone=no;
}*/

function RestartPlayer(Pawn PawnLink)
{
    local s_player P;
	local TO_PRI TOPRI;
	local TO_BRI TOBRI;

		P = s_Player(PawnLink);

		if (!PawnLink.IsA('s_NPC'))
		{
			PawnLink.bFire=0;
			PawnLink.bAltFire=0;
			if (PawnLink.IsA('s_Bot'))
			{
				TOBRI=TO_BRI(Pawnlink.PlayerReplicationInfo);
				if (TOBRI!=None)
				{
					TOBRI.bEscaped=false;
					TOBRI.bIsSpectator=false;
				}
				else
					log("RestartRound - TOBRI == None");
                if (bShowEffectInvulnerable) GiveShieldEffect(PawnLink);
				s_Bot(PawnLink).bNotPlaying=false;
				s_Bot(PawnLink).O_Count=0;
                s_Bot(PawnLink).bDead=false;
                s_Bot(PawnLink).bDuck=0;
				s_SWATGame(Level.Game).RestartPlayer(PawnLink);
				s_Bot(PawnLink).SetOrders('Freelance',None,false);
				s_Bot(PawnLink).OrderObject=None;
				s_Bot(PawnLink).Objective='O_DoNothing';
				s_Bot(PawnLink).O_number=255;
				s_Bot(PawnLink).HostageFollowing=0;
				s_Bot(PawnLink).OldState='Attacking';
				s_Bot(PawnLink).GotoState('BotBuying');
			}
			else if (P!=None)
			{
				if (P.PlayerReplicationInfo.bWaitingPlayer)
					return;

				TOPRI=TO_PRI(Pawnlink.PlayerReplicationInfo);
				if (TOPRI!=None)
					TOPRI.bEscaped=false;
				else
					log("RestartRound - TOPRI == None");

				P.bNotPlaying=false;
				P.bAlreadyChangedTeam=false;
				P.bDuck=0;
                P.bDead=false;
				PawnLink.SetPhysics(PHYS_Walking);
				PawnLink.GotoState('PlayerWalking');
				AjouteID(P.PlayerReplicationInfo.PlayerID);
				if (bShowEffectInvulnerable) GiveShieldEffect(P);
				PawnLink.bBehindView=False;
				P.ViewPlayerNum(P.PlayerReplicationInfo.PlayerID);
				P.ViewTarget=None;
				PawnLink.GotoState('PlayerWalking');
				s_SWATGame(Level.Game).RestartPlayer(PawnLink);
			}
			else
				s_SWATGame(Level.Game).RestartPlayer(PawnLink);
		}
}

function GiveShieldEffect(Pawn aPlayer)
{
    local KTF_ShieldEffect tms;

    tms=Spawn(class'KTF_ShieldEffect',aPlayer,,aPlayer.Location,aPlayer.Rotation);
    tms.ic=SecGodMod;
    tms.Mesh=aPlayer.Mesh;
    tms.DrawScale=aPlayer.DrawScale;
    tms.ScaleGlow=1;
    if (aPlayer.PlayerReplicationInfo.Team==0) tms.texture=Texture'UnrealShare.Belt_fx.ShieldBelt.newRed';
    else tms.texture=Texture'UnrealShare.Belt_fx.ShieldBelt.newBlue';
}

function bool HandlePickupQuery(Pawn Other,Inventory item,out byte bAllowPickup)
{
    if (bCarrierCantFire)
    {
        if (Other!=None)
            if (Other.PlayerReplicationInfo!=None)
                if (Other.PlayerReplicationInfo.HasFlag!=None)
                    if (Item.IsA('s_Knife')) return false;
                    else
                    {
                        bAllowPickup=0;
                        return true;
                    }
    }
	if (NextMutator!=None)
		return NextMutator.HandlePickupQuery(Other,item,bAllowPickup);
	return false;
}

function MutatorTakeDamage(out int ActualDamage,Pawn Victim,Pawn InstigatedBy,out Vector HitLocation,out Vector Momentum,name DamageType)
{
    if (Victim!=None)
        if (Victim.IsA('S_Player_T'))
            if (RetourneCompteur(s_Player_T(Victim).PlayerReplicationInfo.PlayerID)>0)
                Victim.Health=Victim.Health+ActualDamage;
	if (NextDamageMutator!=None)
		NextDamageMutator.MutatorTakeDamage(ActualDamage,Victim,InstigatedBy,HitLocation,Momentum,DamageType);
}

function byte RetourneCompteur(int pid)
{
    local byte i;

    for (i=0;i<64;i++)
        if (IDCptIAR[i]==pid) return CptIAR[i];
    return 0;
}

function AjouteID(int pid)
{
    local byte i;

    for (i=0;i<64;i++)
        if (IDCptIAR[i]==0)
        {
            IDCptIAR[i]=pid;
            CptIAR[i]=SecGodMod;
        }
}

function DecrementeLesCompteurs()
{
    local byte i;

    for (i=0;i<64;i++)
    {
        if (CptIAR[i]>0)
            CptIAR[i]--;
        if ((CptIAR[i]==0) && (IDCptIAR[i]>0)) IDCptIAR[i]=0;
    }
}

defaultproperties
{
    bDoGlow=true
    MapName(0)="RapidWaters]["
    MapLocation(0)=(X=408,Y=-476,Z=52)
    MapName(1)="Scope "
    MapLocation(1)=(X=-406,Y=-489,Z=-336)
    MapName(2)="Blister"
    MapLocation(2)=(X=-3662,Y=-3053,Z=-141)
    MapName(3)="CIA"
    MapLocation(3)=(X=35,Y=-1283,Z=-3727)
    MapName(4)="TO-Crossfire"
    MapLocation(4)=(X=64,Y=656,Z=-896)
    MapName(5)="TO-Dragon"
    MapLocation(5)=(X=-496,Y=560,Z=-1483)
    MapName(6)="Deadly Drought"
    MapLocation(6)=(X=405,Y=477,Z=-27)
    MapName(7)="Eskero"
    MapLocation(7)=(X=1409,Y=194,Z=-384)
    MapName(8)="Forge"
    MapLocation(8)=(X=119,Y=-2419,Z=-683)
    MapName(9)="The Getaway"
    MapLocation(9)=(X=128,Y=176,Z=-1947)
    MapName(10)="Icy Breeze"
    MapLocation(10)=(X=-2434,Y=-102,Z=-1035)
    MapName(11)="Monastery"
    MapLocation(11)=(X=1957,Y=300,Z=-494)
    MapName(12)="Oilrig"
    MapLocation(12)=(X=-1857,Y=-769,Z=469)
    MapName(13)="Terrorist's Mansion"
    MapLocation(13)=(X=856,Y=1587,Z=0)
    MapName(14)="Thanassos"
    MapLocation(14)=(X=8,Y=-2360,Z=200)
    MapName(15)="Thunderball"
    MapLocation(15)=(X=4146,Y=1915,Z=-301)
    MapName(16)="Yarmouth Trainstation"
    MapLocation(16)=(X=1665,Y=-282,Z=-653)
    MapName(17)="Trooper ]["
    MapLocation(17)=(X=2058,Y=-838,Z=-267)
    MapName(18)="Assault on Verdon"
    MapLocation(18)=(X=-242,Y=-1208,Z=-91)
    MapName(19)="WinterRansom"
    MapLocation(19)=(X=-359,Y=-174,Z=-1101)
    MapName(20)="-2- Alpia"
    MapLocation(20)=(X=1136,Y=-160,Z=-971)
    MapName(21)="-2- Ambush"
    MapLocation(21)=(X=32,Y=-96,Z=-320)
    MapName(22)="-2- Arena"
    MapLocation(22)=(X=-598,Y=50,Z=-350)
    MapName(23)="-2- Bridge"
    MapLocation(23)=(X=160,Y=0,Z=-1296)
    MapName(24)="-2- Broken Faith"
    MapLocation(24)=(X=-27,Y=173,Z=-850)
    MapName(25)="-2- Chicago"
    MapLocation(25)=(X=4152,Y=-1446,Z=52)
    MapName(26)="-2- Chiesa"
    MapLocation(26)=(X=-318,Y=543,Z=-573)
    MapName(27)="-2- A Cold Day"
    MapLocation(27)=(X=-25,Y=-360,Z=-443)
    MapName(28)="-2- Crossmaglen"
    MapLocation(28)=(X=-83,Y=-696,Z=-493)
    MapName(29)="-2- Equinox"
    MapLocation(29)=(X=602,Y=-198,Z=-839)
    MapName(30)="-2- Slow Water"
    MapLocation(30)=(X=1869,Y=-512,Z=258)
    MapName(31)="-2- Toscana"
    MapLocation(31)=(X=40,Y=-684,Z=244)
    MapName(32)="-X- Belfast"
    MapLocation(32)=(X=248,Y=-364,Z=-391)
    bAlwaysRelevant=True
    bRespawnPlayer=True
    bCarrierCantFire=True
	bShowEffectInvulnerable=true
	bRemoveCarcass=true
	SecGodMod=5
}

