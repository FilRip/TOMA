class TO_GiveMoney extends TO_Logic;

var bool Triggered;
var() int Amount;
var() bool bTriggerOnceOnly;
var() bool bSummon;

auto state() IsResetableActor
{
	function BeginPlay ()
	{
	}
	
	function Trigger (Actor Other, Pawn EventInstigator)
	{
	}
	
}
