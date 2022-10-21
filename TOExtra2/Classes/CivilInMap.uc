class CivilInMap extends Mutator;

var int CurrentNbCivil;
var() config int NbCivil;
var int RoundResetted;

function SetupCivil()
{
	local PathNode Dest;
	local NavigationPoint StartSpot;
	local bot Hostage;
	local TOExtraCivil Hostag;
	local int i;

    foreach AllActors(class'TOExtraCivil',Hostag)
    {
        Hostag.bIsPlayer=false;
        Hostag.PlayerReplicationInfo.Destroy();
        Hostag.Destroy();
    }
	CurrentNbCivil=0;

	foreach AllActors(class'PathNode',Dest)
	{
	   i=Rand(2);
		if (CurrentNbCivil==NbCivil)
			break;

		if ((Dest!=None) && (i==0))
		{
			StartSpot=Dest;
			Hostage=SpawnCivil(StartSpot);
			Hostag=TOExtraCivil(Hostage);
			if (Hostag!=None)
				CurrentNbCivil++;
		}
	}
}

final function bot SpawnCivil(NavigationPoint StartSpot)
{
	local bot NewBot;
	local int BotN;
	local Pawn P;

	// Try to spawn the bot.
	NewBot = Spawn(class'TOExtraCivil',,,StartSpot.Location,StartSpot.Rotation);

	if ( NewBot != None )
	{
		// Set the player's ID.
		NewBot.PlayerReplicationInfo.PlayerID=Level.Game.CurrentID++;

		NewBot.PlayerReplicationInfo.Team=3;
		CHIndividualize(NewBot,BotN,CurrentNbCivil);
		NewBot.ViewRotation=StartSpot.Rotation;

		NewBot.bJumpy=false;
		NewBot.CombatStyle=-1.0;
		NewBot.StrafingAbility=-0.5000;
		NewBot.BaseAlertness=0.000000;
		NewBot.CampingRate=0.50000;
		NewBot.AirControl=s_SWATGame(Level.Game).AirControl;

		if ((Level.NetMode!=NM_Standalone) && (s_SWATGame(Level.Game).bNetReady || s_SWATGame(Level.Game).bRequireReady))
		{
			// replicate skins
			for ( P=Level.PawnList; P!=None; P=P.NextPawn )
				if ( P.bIsPlayer && (P.PlayerReplicationInfo != None) && P.PlayerReplicationInfo.bWaitingPlayer && P.IsA('PlayerPawn') )
				{
					if ( NewBot.bIsMultiSkinned )
						PlayerPawn(P).ClientReplicateSkins(NewBot.MultiSkins[0], NewBot.MultiSkins[1], NewBot.MultiSkins[2], NewBot.MultiSkins[3]);
					else
						PlayerPawn(P).ClientReplicateSkins(NewBot.Skin);
				}
		}
	}

	return NewBot;
}

function CHIndividualize(bot NewBot, int n, int NumBots)
{
	local			int   v, num;

	v = Clamp(n,0,8);

	n = Clamp(n,0,31);

	num=class'TOPModels.TO_ModelHandler'.static.GetRandomHostageModel(NewBot);
	NewBot.Mesh=class'TOPModels.TO_ModelHandler'.default.ModelMesh[num];
	NewBot.static.SetMultiSkin(NewBot,"","",num);

	Level.Game.ChangeName(NewBot,"Civil"$NumBots,false);

	NewBot.InitializeSkill(10);

	NewBot.Accuracy=1;
	NewBot.CombatStyle=NewBot.Default.CombatStyle+0.7*1;
	NewBot.BaseAggressiveness=0.5*(NewBot.Default.Aggressiveness+NewBot.CombatStyle);
	NewBot.BaseAlertness=1;
	NewBot.CampingRate=1;
	NewBot.bJumpy=(1!=0);
	NewBot.StrafingAbility=1;
}

function PreBeginPlay()
{
    super.PreBeginPlay();
    SetTimer(1,true);
}

function Timer()
{
    if (s_SWATGame(Level.Game).GamePeriod==GP_PreRound)
        if (s_SWATGame(Level.Game).RoundNumber!=RoundResetted)
        {
            RoundResetted=s_SWATGame(Level.Game).RoundNumber;
            SetupCivil();
        }
}

function bool HandlePickupQuery(Pawn Other, Inventory item, out byte bAllowPickup)
{
    if (Other.IsA('TOExtraCivil'))
    {
		bAllowPickup=0;
		return true;
	}
	if (NextMutator!=None)
		return NextMutator.HandlePickupQuery(Other,item,bAllowPickup);
}

function Mutate(string MutateString, PlayerPawn Sender)
{
	if (NextMutator!=None)
		NextMutator.Mutate(MutateString,Sender);
}

function ScoreKill(Pawn Killer, Pawn Other)
{
    if ((Killer!=None) && (Other!=None) && (Other.IsA('TOExtraCivil')))
        s_SWATGame(Level.Game).AddMoney(Killer,-s_SWATGame(Level.Game).KillPrice-300);
}

defaultproperties
{
    NbCivil=15
}

