class TGAS_PlyNotify expands SpawnNotify;
var TGAS_Main tgmut;

simulated event Spawned ()
{
	local TGAS_Player p;

	foreach AllActors(Class'TGAS_Player',P)
	{
		SpawnNotification(P);
	}
}

function PreBeginPlay ()
{
	bAlwaysRelevant=True;
}

simulated event Actor SpawnNotification (Actor Actor)
{
  local TGAS_PlyReplInfo p;

//  log ("Teargas mutator - spawning TRI");
  p=Spawn(Class'teargas3.TGAS_PlyReplInfo',actor);
  TGAS_player(actor).TRI = p;
  TGAS_player(actor).TGmut = TGmut;
//  TGAS_player(actor).setupclient();
  return actor;
}

defaultproperties
{
    ActorClass=Class'TGAS_Player'
}
