class TO_TriggerCycle extends TO_Logic;

var() name Events[8];
var int numEvents;
var int curEvent;

function BeginPlay ()
{
}

auto state() IsResetableActor
{
	function Trigger (Actor Other, Pawn EventInstigator)
	{
	}
	
}
