class TOGiantSoldiers extends Mutator;

var int CurrentRound;

function PreBeginPlay()
{
    super.PreBeginPlay();
    SetTimer(1,true);
}

function Timer()
{
    if ((s_SWATGame(Level.Game).GamePeriod==GP_PreRound) && (s_SWATGame(Level.Game).RoundNumber!=CurrentRound))
    {
        CurrentRound=s_SWATGame(Level.Game).RoundNumber;
        SetNewSize();
    }
}

function SetNewSize()
{
    local Pawn P;

    for (P=Level.PawnList;P!=None;P=P.NextPawn)
        if ((P.IsA('s_Bot')) || (P.IsA('s_NPCHostage')))
            P.SetCollisionSize(P.CollisionRadius,80);
}

function ModifyLogin(out Class<PlayerPawn> SpawnClass,out string Portal,out string Options)
{
	if (SpawnClass==Class'S_Player_T')
		SpawnClass=Class'TOGiantSoldiersPlayers';
	if (NextMutator!=None)
		NextMutator.ModifyLogin(SpawnClass,Portal,Options);
}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
    if ((Other.IsA('s_Bot')) || (Other.IsA('s_NPC')))
    {
        Other.DrawScale=2.000000;
        Other.SetCollisionSize(Other.CollisionRadius,80);
    }
    return true;
}

defaultproperties
{
}

