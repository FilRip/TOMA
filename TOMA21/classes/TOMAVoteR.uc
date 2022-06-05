class TOMAVoteR extends ReplicationInfo;

var byte VoteM[64];
var byte VoteS;

replication
{
    reliable if (Role==Role_Authority)
        VoteM,VoteS;
}

defaultproperties
{
    bHidden=true
    NetUpdateFrequency=1.000000
    RemoteRole=ROLE_SimulatedProxy
    NetPriority=3.000000
}

