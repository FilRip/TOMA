class TOMAGameReplicationInfo extends s_GameReplicationInfo;

var int nbmonstersinmap,nbmonsterstokill;
var string nameofmonster;

var bool NewWeapons;
var bool TerroristsWeapons;
var int numlevel;
var bool bFixBuyZone;
var bool bInfiniteTime;
var int SecBeforeRespawnPlayer;
var bool bAllowRadar;
var bool bRespawnPlayer,bEnableMagic;

replication
{
	reliable if (Role==ROLE_Authority)
		nbmonstersinmap,nbmonsterstokill,nameofmonster,
		numlevel,bFixBuyZone,bAllowRadar,
		NewWeapons,TerroristsWeapons,bInfiniteTime,SecBeforeRespawnPlayer,bRespawnPlayer,bEnableMagic;
}

simulated function Timer()
{
	local PlayerReplicationInfo PRI;
	local int i, FragAcc;

	if ( Level.NetMode == NM_Client )
	{
		if ( (Level.TimeSeconds - SecondCount) >= (1.0/Level.TimeDilation) )
		{
			ElapsedTime++;
			if ( RemainingMinute != 0 )
			{
				RemainingTime = RemainingMinute;
				RemainingMinute = 0;
			}
			if ( /*(RemainingTime > 0) &&*/ !bStopCountDown )
				RemainingTime--;
			SecondCount += Level.TimeDilation;
		}
	}

	for (i=0; i<32; i++)
		PRIArray[i] = None;
	i=0;
	foreach AllActors(class'PlayerReplicationInfo', PRI)
	{
		if ((i<32) && (!PRI.IsA('TOMAMonstersReplicationInfo')))
			PRIArray[i++] = PRI;
	}

	// Update various information.
	UpdateTimer = 0;
	for (i=0; i<32; i++)
		if (PRIArray[i] != None)
			FragAcc += PRIArray[i].Score;
	SumFrags = FragAcc;

	if ( Level.Game != None )
		NumPlayers = Level.Game.NumPlayers;
}

defaultproperties
{
}
