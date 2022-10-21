class TOAddTranslocator extends mutator;

/*var int CurrentRound;

function PreBeginPlay()
{
    super.PreBeginPlay();
    SetTimer(1,true);
}

function AddWeapons()
{
    local Pawn P;

    for (P=Level.PawnList;P!=None;P=P.NextPawn)
        if ((P.IsA('s_Player_T')) || (P.IsA('s_Bot')))
            s_SWATGame(Level.Game).GiveWeapon(P,"TOExtra2.TOExtraTranslocator");
}*/

function ModifyPlayer(Pawn Other)
{
    s_SWATGame(Level.Game).GiveWeapon(Other,"TOExtra2.TOExtraTranslocator");
}

/*function Timer()
{
    if ((s_SWATGame(Level.Game).GamePeriod==GP_PreRound) && (s_SWATGame(Level.Game).RoundNumber!=CurrentRound))
    {
        CurrentRound=s_SWATGame(Level.Game).RoundNumber;
        AddWeapons();
    }
}*/

defaultproperties
{
}

