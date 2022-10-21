class TMPRI extends TO_PRI;

var int CurrentScore;
var int NbRound;

replication
{
    reliable if (Role==Role_Authority)
        CurrentScore,NbRound;
}

