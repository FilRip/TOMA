class TO_KnifePickup extends TournamentPickup;

simulated function PostBeginPlay ()
{
}

function BecomeItem ()
{
}

auto state Pickup
{
	function Touch (Actor Other)
	{
	}
	
	simulated function Landed (Vector HitNormal)
	{
	}
	
}

event float BotDesireability (Pawn Bot)
{
}
