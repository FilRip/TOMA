//----------------------------------------------------------------------------
// Project : TOST
// File    : TOSTInputHook.uc
// Version : 1.0
// Author  : BugBunny
//----------------------------------------------------------------------------
// Version	Changes
// 1.0		+ first release
//----------------------------------------------------------------------------

class	TOSTInputHook extends Actor;

var private TOSTInputHook	Next;

simulated function	AddHook(TOSTInputHook IH)
{
	if (Next != none)
		Next.AddHook(IH);
	else
		Next = IH;
}

simulated function	ProcessInput(TOSTPlayer P, float DeltaTime)
{
	if (Next != none)
		Next.ProcessInput(P, DeltaTime);
}

simulated function	ProcessCanvas(TOSTPlayer P, Canvas C)
{
	if (Next != none)
		Next.ProcessCanvas(P, C);
}

defaultproperties
{
	bHidden=true
}
