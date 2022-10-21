// $Id: TOSTHUDMutator.uc 487 2004-03-07 14:29:51Z dildog $
//----------------------------------------------------------------------------
// Project : TOST
// File    : TOSTHUDMutator.uc
// Version : 1.0
// Author  : BugBunny
//----------------------------------------------------------------------------

class TOSTHUDMutator expands Mutator;

var	ChallengeHUD		MyHUD;
var PlayerPawn			MyPlayer;
var	TOSTCommunicator	Master;

var class<TOSTClientPiece>	CommClass;
var	TOSTClientPiece		Comm;

// - standard functions

simulated event Destroyed()
{
	local	Mutator		Prev, Next;

	if (MyHUD != none)
	{
		if (MyHUD.HUDMutator == self)
			MyHUD.HUDMutator = NextHUDMutator;
		else
		{
			Prev = MyHUD.HUDMutator;
			Next = Prev.NextHUDMutator;
			while (Next != none && Next != self)
			{
				Prev = Next;
				Next = Next.NextHUDMutator;
			}
			if (Next == self)
				Prev.NextHUDMutator = Next.NextHUDMutator;
		}
	}

	if (Comm != none)
		Comm.Destroy();

	super.Destroyed();
}

simulated event PostRender(canvas C)
{
	if (NextHUDMutator != none)
		NextHUDMutator.PostRender(C);
}

simulated function	Init()
{
	RegisterHUDMutator();
	if (CommClass != none)
	{
		Comm = Spawn(CommClass, self);
		Comm.Master = self;
	}
}

defaultproperties
{
	bHidden=true
}
