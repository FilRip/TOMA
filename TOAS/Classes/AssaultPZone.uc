class AssaultPZone extends TO_PZone;

simulated function tick(float delta)
{
	local AssaultGameReplicationInfo GRI;

	Super.Tick(delta);

	GRI=AssaultGameReplicationInfo(zzSP.GameReplicationInfo);
	if ((GRI.RoundStarted - GRI.RemainingTime>GRI.LimitBuyTime) && (GRI.LimitBuyTime>0))
		zzSP.bInBuyZone=false;
	if (GRI.bPreRound) zzSP.bInBuyZone=true;
}

defaultproperties
{
}
