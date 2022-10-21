Class TFPlayerReplicationInfo extends TO_PRI;

var bool bHasFlag;

replication
{
	reliable if (Role==ROLE_Authority)
	   bHasFlag;
}

defaultproperties
{
}
