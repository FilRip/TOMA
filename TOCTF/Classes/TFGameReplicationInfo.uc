class TFGameReplicationInfo extends s_GameReplicationInfo;

var TFFlags TheFlags[2];

replication
{
	reliable if (Role==ROLE_Authority)
		TheFlags;
}

defaultproperties
{
}

