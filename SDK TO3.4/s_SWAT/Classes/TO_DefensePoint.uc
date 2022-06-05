class TO_DefensePoint extends s_SWATPathNode;

var() float pausetime;
var() bool Duck;
var bool bUsed;
var s_bot BotUsing;
var bool bLeaving;

state IsResetableActor
{
	function BeginState ()
	{
	}
}
