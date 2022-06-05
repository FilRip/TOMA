class VIPTO_GameReplicationInfo expands SpawnNotify;

var int idduvip;

replication
{
	reliable if (Role==ROLE_Authority)
		idduvip;
}

defaultproperties
{
	NetUpdateFrequency=1
	bNetTemporary=False
}
