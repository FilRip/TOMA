//----------------------------------------------------------------------------
// Project : TOST
// File    : TOSTPlayer.uc
// Version : 1.0
// Author  : BugBunny
//----------------------------------------------------------------------------
// Version	Changes
// 1.0		+ first release
//----------------------------------------------------------------------------

class TOSTPlayer extends s_Player_T;

var	private	TOSTInputHook	MyIH;

simulated function	SetInputHook(TOSTInputHook	IH)
{
	if (IH != none)
	{
		if (MyIH == none)
			MyIH = IH;
		else
			MyIH.AddHook(IH);
	}
}

exec function	Grab()
{
}

event PlayerInput( float DeltaTime )
{
	if (MyIH != none)
		MyIH.ProcessInput(self, DeltaTime);
	super.PlayerInput(DeltaTime);
}

simulated event RenderOverlays( canvas Canvas )
{
	if ( Weapon != None )
		Weapon.RenderOverlays(Canvas);

	if ( myHUD != None )
		myHUD.RenderOverlays(Canvas);

	if ( myIH != none )
		myIH.ProcessCanvas(self, Canvas);
}

defaultproperties
{
}
