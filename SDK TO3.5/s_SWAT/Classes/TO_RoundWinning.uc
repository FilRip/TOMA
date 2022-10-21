class TO_RoundWinning extends TacticalOpsMapActors;

enum ETeams {
	ET_Terrorists,
	ET_SpecialForces,
	ET_Both
};
var ETeams winner;
var int WinAmount;

function Trigger (Actor Other, Pawn EventInstigator)
{
}


defaultproperties
{
}

