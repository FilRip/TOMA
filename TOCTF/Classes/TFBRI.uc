class TFBRI extends TO_BRI;

var bool bHasFlag;

replication
{
	reliable if (Role==ROLE_Authority)
	   bHasFlag;
}

defaultproperties
{
}
