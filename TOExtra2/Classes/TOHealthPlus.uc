class TOHealthPlus extends mutator;

var int CurrentRound;
var() config int NewDefaultHealth;

function PreBeginPlay()
{
    super.PreBeginPlay();
    SetTimer(1,true);
}

function SetNewHealth()
{
    local Pawn P;

    for (P=Level.PawnList;P!=None;P=P.NextPawn)
        if ((P.IsA('s_Player_T')) || (P.IsA('s_Bot')))
            P.Health=NewDefaultHealth;
}

function Timer()
{
    if ((s_SWATGame(Level.Game).GamePeriod==GP_PreRound) && (s_SWATGame(Level.Game).RoundNumber!=CurrentRound))
    {
        CurrentRound=s_SWATGame(Level.Game).RoundNumber;
        SetNewHealth();
    }
}

defaultproperties
{
}

