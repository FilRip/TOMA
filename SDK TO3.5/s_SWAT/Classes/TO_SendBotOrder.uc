class TO_SendBotOrder extends TacticalOpsMapActors;

var Actor ActorTarget;
var name Target;
enum ETeams {
	ET_Terrorists,
	ET_SpecialForces,
	ET_Both
};
var ETeams SendTo;
var name ObjectiveType;
var bool bLeadersOnly;
var float DesiredAssignment;

function PreBeginPlay ()
{
}

function Trigger (Actor Other, Pawn EventInstigator)
{
}


defaultproperties
{
}

