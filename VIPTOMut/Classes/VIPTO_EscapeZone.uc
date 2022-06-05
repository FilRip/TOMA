class VIPTO_EscapeZone extends Actor;

function VIPEscaped(VIPTO_Player Other)
{
	if (Other!=None)
		if (!Other.bNotPlaying)
		{
			if (Other.Weapon!=None) Other.Weapon=None;
			Other.bNotPlaying=true;
			Other.PlayerReplicationInfo.bIsSpectator=True;
			Other.GotoState('PlayerSpectating');
			Other.Health=-1;
			if (Other.Flashlight!=None)
				Other.Flashlight.Destroy();
			Other.SetPhysics(PHYS_NOne);
		}
}

simulated event Touch(Actor Other)
{
	Super.Touch(Other);
	If (Other!=None)
		if (Other.IsA('VIPTO_Player'))
			if (VIPTO_Player(Other).isvip)
			{
				VIPEscaped(VIPTO_Player(Other));
				VIPTO_Player(Other).vipescaped=true;
				s_SWATGame(Level.Game).SetWinner(1);
				s_swatgame(Level.Game).EndGame("Special Forces win the round");
				Disable('Touch');
			}
}

defaultproperties
{
	bCollideActors=true
	bHidden=true
}
