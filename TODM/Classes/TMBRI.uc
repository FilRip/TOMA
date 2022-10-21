class TMBRI extends TO_BRI;

var int CurrentScore;
var int NbRound;

replication
{
    reliable if (Role==Role_Authority)
        CurrentScore,NbRound;
}

