class TOMAFBEffect extends s_FlashBang config(TOMA);

var() float RayOfAction;
var() config localized string FreezeText;

simulated function Explosion (Vector HitLocation)
{
	local TOMAScriptedPawn P;
	local float dist;

	bHidden=True;

	Spawn(Class'TO_ExplFlash',,,HitLocation);
	foreach AllActors(Class'TOMAScriptedPawn',P)
	{
		if (P.PlayerReplicationInfo!=None)
		{
			dist=VSize(P.Location-Location);
			if (dist<RayOfAction)
			{
//				Level.Game.BroadcastMessage(P.PlayerReplicationInfo.PlayerName $ " "$FreezeText);
				P.GotoState('Freezed');
			}
		}
	}
	Destroy();
}

defaultproperties
{
	RayOfAction=1024
	FreezeText="Freezed"
}
