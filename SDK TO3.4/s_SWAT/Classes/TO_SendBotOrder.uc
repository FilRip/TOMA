class TO_SendBotOrder extends TacticalOpsMapActors;

var() ETeams SendTo;
var() name Target;
var() name ObjectiveType;
var() bool bLeadersOnly;
var() float DesiredAssignment;
var Actor ActorTarget;

function PreBeginPlay ()
{
}

function Trigger (Actor Other, Pawn EventInstigator)
{
}
