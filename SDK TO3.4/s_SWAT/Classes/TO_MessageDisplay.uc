class TO_MessageDisplay extends TacticalOpsMapActors;

enum ESendTo
{
	EST_Terrorists,
	EST_SpecialForces,
	EST_Both
};

var() ESendTo SendMessageTo;
var() localized string Message;

function Trigger (Actor Other, Pawn EventInstigator)
{
}
