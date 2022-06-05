class VIPTO extends Mutator;

var VIPTO_GameReplicationInfo repl;
var int doneforround;
var bool initforthisround;
var int idvip;
var bool isavipmap;
var bool alreadyundercheck;
var int resetterround;
var() config bool BodyGuardCantKillVIP;
var bool DebugOn;
var() config bool bAddBotSupport;
var bool siredefined;
var() config bool bFixMutatorReplicationBug;
var() config bool bDoGlowOnVIP;
var() config bool bMAFullForVIP;

function ResetAmbientToPlayer(Pawn P)
{
    if (!bDoGlowOnVIP) return;
	P.AmbientGlow=2;
	P.LightEffect=LE_None;
	P.LightRadius=0;
	P.LightType=LT_None;
	P.LightBrightness=0;
	P.LightSaturation=0;
	P.LightHue=0;
}

function SetAmbientToPlayer(Pawn P)
{
    if (!bDoGlowOnVIP) return;
	P.AmbientGlow=255;
	P.LightEffect=LE_NonIncidence;
	P.LightRadius=5;
	P.LightType=LT_Steady;
	P.LightBrightness=255;
	P.LightSaturation=127;
	P.LightHue=255;
}

function PreBeginPlay()
{
	SetTimer(1,true);
	repl=Spawn(class'VIPTO_GameReplicationInfo');
	doneforround=0;
	Spawn(class'VIPTO_VIPSkins');
	AddVIPSkins();
	idvip=-1;
	doneforround=-1;
	repl.idduvip=0;
	resetterround=-1;
	if (left(Level.Title,4)=="VIP-") isavipmap=true; else isavipmap=false;
}

function PostBeginPlay()
{
	if (BodyGuardCantKillVIP) Level.Game.RegisterDamageMutator(Self);
}

/*function SendMessageTOAllPlayers(string msg)
{
	local PlayerPawn P;

	foreach AllActors(class'PlayerPawn',P)
	{
		P.ClearProgressMessages();
		P.SetProgressTime(4);
		P.SetProgressMessage(Msg,0);
	}
}*/

function byte NbInTeam(byte i,bool alive)
{
	local Pawn joueur;
	local byte j;

	for (joueur=Level.PawnList;joueur!=None;joueur=joueur.NextPawn)
	{
        if ((joueur.IsA('VIPTO_Player')) || (joueur.IsA('s_bot')))
        {
            if (joueur.PlayerReplicationInfo.Team==i)
            {
                j++;
                if (VIPTO_Player(joueur)!=None)
                {
                    if ((vipto_player(joueur).bDead) && (alive))
                        j--;
                }
                else
                {
                    if (s_bot(joueur)!=None)
                        if ((s_bot(joueur).bDead) && (alive))
                            j--;
                }
            }
        }
	}
	return j;
}

function CreateEscapeZone(s_ZoneControlPoint szcp)
{
	local VIPTO_EscapeZone newone;

	newone=Spawn(class'VIPTOMut.VIPTO_EscapeZone',,,szcp.Location);
	if (newone!=None)
	{
		newone.SetCollisionSize(szcp.CollisionRadius,szcp.CollisionHeight);
		if (DebugOn) Log("Escape zone created");
	}
	else if (DebugOn) Log("Unable to create escape zone");
}

simulated function AddVIPSkins()
{
	Class'TO_ModelHandler'.Default.Skin0[19]="VIPTOTex.Skins.VIP1Tex0";
	Class'TO_ModelHandler'.Default.Skin1[19]="VIPTOTex.Skins.VIP1Tex1";
	Class'TO_ModelHandler'.Default.Skin2[19]="VIPTOTex.Skins.VIP1Tex2";
	Class'TO_ModelHandler'.Default.Skin3[19]="VIPTOTex.Skins.VIP1Tex3";
	Class'TO_ModelHandler'.Default.Skin4[19]="VIPTOTex.Skins.VIP1Tex4";
	Class'TO_ModelHandler'.Default.ModelMesh[19]=Class'TO_ModelHandler'.Default.ModelMesh[13];
	Class'TO_ModelHandler'.Default.ModelName[19]="VIP 1";
	Class'TO_ModelHandler'.Default.ModelType[19]=MT_SpecialForces;
	Class'TO_ModelHandler'.Default.Skin0[20]="VIPTOTex.Skins.VIP2Tex0";
	Class'TO_ModelHandler'.Default.Skin1[20]="VIPTOTex.Skins.VIP2Tex1";
	Class'TO_ModelHandler'.Default.Skin2[20]="VIPTOTex.Skins.VIP2Tex2";
	Class'TO_ModelHandler'.Default.Skin3[20]="VIPTOTex.Skins.VIP2Tex3";
	Class'TO_ModelHandler'.Default.Skin4[20]="VIPTOTex.Skins.VIP2Tex4";
	Class'TO_ModelHandler'.Default.ModelMesh[20]=Class'TO_ModelHandler'.Default.ModelMesh[13];
	Class'TO_ModelHandler'.Default.ModelName[20]="VIP 2";
	Class'TO_ModelHandler'.Default.ModelType[20]=MT_SpecialForces;
}

function SaveInventory(VIPTO_Player joueur)
{
	local Inventory Inv;

	for (inv=joueur.Inventory;Inv!=None;Inv=Inv.Inventory)
	{
		if ((Inv.IsA('S_Weapon')) && (Inv.Class!=Class's_C4') && (Inv.Class!=Class's_OICW') && (Inv.Class!=Class's_Knife') && (Inv.Class!=Class'TO_Binocs'))
		{
			s_SWATGame(Level.Game).AddMoney(joueur,S_Weapon(Inv).price);
			if (DebugOn) Log("Arme " $ Inv.Class $ " du VIP vendu");
		}
		joueur.SwitchToBestWeapon();
	}
	for (inv=joueur.Inventory;Inv!=None;Inv=Inv.Inventory)
		if ((Inv.IsA('S_Weapon')) && (Inv.Class!=Class's_C4') && (Inv.Class!=Class's_OICW') && (Inv.Class!=Class's_Knife') && (Inv.Class!=Class'TO_Binocs'))
			Inv.Destroy();

	s_SWATGame(Level.Game).GiveWeapon(joueur,"s_swat.s_deagle");
	for (inv=joueur.Inventory;Inv!=None;Inv=Inv.Inventory)
		if (Inv.IsA('s_deagle')) S_DEagle(Inv).SetRemainingAmmo(7,7,false);
	joueur.VestCharge=100;
	joueur.HelmetCharge=100;
	joueur.LegsCharge=100;
	joueur.CalculateWeight();
	if ((joueur.IsA('VIPTOMA_Player')) && (bMAFullForVIP))
    {
        joueur.bHasNV=true;
        VIPTOMA_Player(joueur).GlowSticksOwned=25;
    }
	if (DebugOn) log("New inventory set to VIP");
}

function ChoiceAVip()
{
	local VIPTO_Player vp;
	local bool yaunvip;

Redone:
    if (NbPlayerInSF()==0)
    {
    	alreadyundercheck=false;
        return;
    }
	if (DebugOn) Log("Check who can be VIP");
	foreach AllActors(class'VIPTO_Player',vp)
		if (vp.PlayerReplicationInfo.Team==1)
			if (!vp.havealreadybevip)
			{
				vp.previousskin=vp.PlayerModel;
				vp.havealreadybevip=true;
				vp.Health=150;
				vp.bAlreadyChangedTeam=False;
				SaveInventory(vp);
				vp.previousskin=vp.PlayerModel;
				vp.s_changeteam(19+rand(2),1,false);
				repl.idduvip=vp.PlayerReplicationInfo.PlayerID;
				idvip=vp.PlayerReplicationInfo.PlayerID;
				TO_PRI(vp.PlayerReplicationInfo).bEscaped=true;
				yaunvip=true;
				vp.isvip=true;
				SetAmbientToPlayer(vp);
				doneforround=s_SWATGame(Level.Game).RoundNumber;
				if (DebugOn) Log("For round n° " $ string(doneforround) $ " , the VIP is : " $ vp.PlayerReplicationinfo.PlayerName);
				break;
			}
	if (!yaunvip)
	{
		foreach AllActors(class'VIPTO_Player',vp)
			vp.havealreadybevip=false;
		if (DebugOn) Log("Every SF has been VIP, restart from the first SF");
		goto Redone;
	}
	alreadyundercheck=false;
}

function RemovePreviousVIP()
{
	local VIPTO_Player joueur;

	if (DebugOn) Log("Remove the VIP, for new round, new VIP");
	if (idvip!=-1)
	{
		foreach allactors(class'VIPTO_Player',joueur)
			if ((joueur.PlayerReplicationInfo.PlayerID==idvip) && (joueur.PlayerReplicationInfo.Team==1))
			{
				TO_PRI(joueur.PlayerReplicationInfo).bEscaped=false;
				joueur.isvip=false;
				joueur.Health=100;
            	if ((joueur.IsA('VIPTOMA_Player')) && (bMAFullForVIP))
                {
                    joueur.bHasNV=false;
                    VIPTOMA_Player(joueur).GlowSticksOwned=5;
                }
				joueur.balreadychangedteam=false;
				joueur.s_changeteam(joueur.previousskin,1,false);
				joueur.balreadychangedteam=false;
				SetAmbientToPlayer(joueur);
				if (DebugOn) Log(joueur.PlayerReplicationInfo.PlayerName $ " is no more VIP now");
			}
		idvip=-1;
		repl.idduvip=0;
	}
}

function byte NbPlayerInSF()
{
    local VIPTO_Player j;
    local byte i;

    foreach AllActors(class'VIPTO_Player',j)
        if ((j.PlayerReplicationInfo!=None) && (j.PlayerReplicationInfo.Team==1)) i++;
    return i;
}

function Timer()
{
	if (resetterround!=s_SWATGame(Level.Game).RoundNumber)
	{
		resetterround=s_SWATGame(Level.Game).RoundNumber;
		MyResetterActor();
	}

	if ((s_GameReplicationInfo(Level.Game.GameReplicationInfo).bPreRound) && (!alreadyundercheck))
	{
        if (bAddBotSupport) CheckBotSkin();
		alreadyundercheck=true;
		if ((doneforround!=s_SWATGame(Level.Game).RoundNumber) && (NbInTeam(1,false)>0))
		{
			if (idvip!=-1) RemovePreviousVIP();
			ChoiceAVip();
		} else alreadyundercheck=false;
	}
	else if ((s_SWATGame(Level.Game).GamePeriod==GP_RoundPlaying) && (s_SWATGame(Level.Game).RoundStarted - s_SWATGame(Level.Game).RemainingTime >= (s_SWATGame(Level.Game).RoundDuration * 60)-1))
	        {
	            if (RetourneReplVIP()!=None)
	            {
					BroadcastLocalizedMessage(class'VIPTO_Message',21,RetourneReplVIP().PlayerReplicationInfo);
					S_SWATGame(Level.Game).SetWinner(0);
					S_SWATGame(Level.Game).EndGame("Terrorists win the round");
				}
	        }

	if ((idvip>-1) && (RetourneReplVIP()!=None) && (RetourneReplVIP().vipescaped))
	{
		RetourneReplVIP().vipescaped=false;
//		SendMessageToAllPlayers(class'VIPTO_Player'.default.VIPHasEscaped);
        BroadcastLocalizedMessage(class'VIPTO_Message',22,RetourneReplVIP().PlayerReplicationInfo);
	}

// do not end round when all terrorists are dead
//	s_SWATGame(Level.Game).bBombPlanted=true;
// Do not give bomb (work only on first round)
//	s_SWATGame(Level.Game).bBombGiven=true;
}

function CheckBotSkin()
{
    local Pawn P;
    local bool nono;

    for (p=Level.PawnList;P!=None;p=p.NextPawn)
        if (p.IsA('s_botmcounterterrorist1'))
            if ((s_bot(p).PlayerModel==19) || (s_bot(p).PlayerModel==20))
            {
                nono=true;
                while (nono)
                {
                    s_bot(P).PlayerModel=class'TO_ModelHandler'.static.GetRandomSFModel(P);
                    if ((s_bot(P).PlayerModel==19) || (s_bot(p).PlayerModel==20)) nono=true; else nono=false;
                }
            }
}

function MyResetterActor()
{
	local s_NPCHostage lesotages;
	local VIPTO_EscapeZone vez;
	local TO_ConsoleTimer CT;
    local s_OICW oicw;

	foreach AllActors(class's_NPCHostage',lesotages)
		lesotages.Destroy();

	foreach AllActors(class'TO_ConsoleTimer',ct)
		ct.bActive=false;

	foreach AllActors(class's_OICW',oicw)
		oicw.Destroy();

	foreach AllActors(class'VIPTO_EscapeZone',vez)
		vez.Enable('Touch');
}

function VIPTO_Player RetourneReplVIP()
{
    local Pawn p;

    for (p=Level.PawnList;p!=None;p=p.NextPawn)
		if ((p.PlayerReplicationInfo!=None) && (p.PlayerReplicationInfo.PlayerID==idvip)) return VIPTO_Player(p);
	return none;
}

function ModifyLogin(out Class<PlayerPawn> SpawnClass,out string Portal,out string Options)
{
	if (SpawnClass==Class'S_Player_T')
		SpawnClass=Class'VIPTO_Player';
	if (NextMutator!=None)
		NextMutator.ModifyLogin(SpawnClass,Portal,Options);
}

function ScoreKill(Pawn Killer, Pawn Other)
{
	if (Other!=None)
		if (Other.IsA('VIPTO_Player'))
			if (VIPTO_Player(Other).isvip)
			{
				if ((Killer==None) || (!Killer.IsA('Pawn')))
				{
//					SendMessageToAllPlayers(class'VIPTO_Player'.default.LeVIPStr $ class'VIPTO_Player'.default.VIPKilledHimself);
                    BroadcastLocalizedMessage(class'VIPTO_Message',20,Other.PlayerReplicationInfo);
				}
				else
				{
					if (Killer.PlayerReplicationInfo!=None)
					{
						if (Killer.PlayerReplicationInfo.Team==0)
						{
//							SendMessageToAllPlayers(class'VIPTO_Player'.default.LeVIPStr $ class'VIPTO_Player'.default.VIPKilledByTerro);
                            BroadcastLocalizedMessage(class'VIPTO_Message',18,Other.PlayerReplicationInfo);
						}
						else
						{
//							SendMessageToAllPlayers(class'VIPTO_Player'.default.LeVIPStr $ class'VIPTO_Player'.default.VIPKilledByBodyguard);
                            BroadcastLocalizedMessage(class'VIPTO_Message',19,Other.PlayerReplicationInfo);
						}
					}
				}
				if (nbinteam(1,true)>0)
				{
					S_SWATGame(Level.Game).SetWinner(0);
					S_SWATGame(Level.Game).EndGame("Terrorists win the round");
				}
			}
	// call the next mutator if exist
	if (NextMutator!=None)
		NextMutator.ScoreKill(Killer,Other);
}

/*function CreateBuyZone(s_ZoneControlPoint Other)
{
    local s_ZoneControlPoint second;

    second=Spawn(class'VIPTO_ZoneControlPoint',,,Other.Location);
    second.OwnedTeam=1-Other.OwnedTeam;
    second.bBuyPoint=true;
    second.SetCollisionSize(Other.CollisionRadius,Other.CollisionHeight);
}*/

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	if (!isavipmap)
	{
		if (Other.IsA('PlayerStart'))
			PlayerStart(Other).TeamNumber=1-PlayerStart(Other).TeamNumber;
//		if (Other.IsA('s_NPCStartPoint')) return false;
//		if (Other.IsA('s_NPCHostage')) return false;
		if (Other.IsA('s_C4')) return false;
		if (Other.IsA('s_OICW')) return false;
		if (Other.IsA('TO_ConsoleTimer')) return false;
		if (Other.IsA('s_ZoneControlPoint'))
		{
//			if (!s_ZoneControlPoint(Other).bBuyPoint)
			if ((s_ZoneControlPoint(Other).bRescuePoint) || (s_ZoneControlPoint(Other).bEscapeZone) || (s_ZoneControlPoint(Other).bBombingZone)) CreateEscapeZone(s_ZoneControlPoint(Other));
			if (s_ZoneControlPoint(Other).bEscapeZone) s_ZoneControlPoint(Other).bEscapeZone=false;
			if (s_ZoneControlPoint(Other).bBombingZone) s_ZoneControlPoint(Other).bBombingZone=false;
			if (s_ZoneControlPoint(Other).bRescuePoint) s_ZoneControlPoint(Other).bRescuePoint=false;
/*			if (s_ZoneControlPoint(Other).bBuyPoint)
            {
                CreateBuyZone(s_ZoneControlPoint(Other));
                return false;
            }*/
		}
/*		if ((Other.IsA('TO_ScenarioInfo')) && (!Other.IsA('VIPTO_ScenarioInfo')))
		{
			TO_ScenarioInfo(Other).DefaultLooser=ET_SpecialForces;
			TO_ScenarioInfo(Other).DefaultLooseMessage=class'VIPTO_Message'.Default.VIPFailedToEscape;
			TO_ScenarioInfo(Other).WinAmount=1000;
			TO_ScenarioInfo(Other).bSFAttitudeOffensive=true;
			TO_ScenarioInfo(Other).bTerrAttitudeOffensive=true;
			Spawn(class'VIPTO_ScenarioInfo');
			if (DebugOn) Log("Scenario replaced");
		}*/
	}
//	bSuperRelevant=0;
	return true;
}

function MutatorTakeDamage(out int ActualDamage,Pawn Victim,Pawn InstigatedBy,out Vector HitLocation,out Vector Momentum,name DamageType)
{
	if (BodyGuardCantKillVIP)
		if (Victim.IsA('VIPTO_Player'))
			if (VIPTO_Player(Victim).isvip)
				if (InstigatedBy.IsA('VIPTO_Player'))
					if (InstigatedBy.PlayerReplicationInfo.Team==1) Victim.Health+=ActualDamage;
	if (NextDamageMutator!=None)
		NextDamageMutator.MutatorTakeDamage( ActualDamage, Victim, InstigatedBy, HitLocation, Momentum, DamageType );
}

function Tick(float delta)
{
    // FIX UT436 mutator replication bugs (slow)
	if (bFixMutatorReplicationBug) s_SWATGame(level.Game).EnabledMutators="";
}

function bool HandlePickupQuery(Pawn Other,Inventory item,out byte bAllowPickup)
{
	if (Other.IsA('VIPTO_Player'))
	{
		if (VIPTO_Player(Other).isvip)
		{
			if ((Item.IsA('s_Knife')) || (Item.IsA('s_DEagle'))) return false;
				else
				{
					bAllowPickup=0;
					return true;
				}
		}
	}
	if (NextMutator!=None)
		return NextMutator.HandlePickupQuery(Other,item,bAllowPickup);
	return false;
}

defaultproperties
{
	BodyGuardCantKillVIP=false
	DebugOn=False
	bAddBotSupport=true
	bFixMutatorReplicationBug=false
	bDoGlowOnVIP=false
	bMAFullForVIP=true
}
