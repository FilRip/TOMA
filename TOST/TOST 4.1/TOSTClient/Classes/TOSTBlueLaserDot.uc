//----------------------------------------------------------------------------
// Project : TOST
// File    : TOSTBlueLaserDot.uc
// Version : 1.0
// Author  : BugBunny
//----------------------------------------------------------------------------
// Version	Changes
// 1.0		+ first public release
//----------------------------------------------------------------------------

class TOSTBlueLaserDot expands SpawnNotify;

#exec TEXTURE IMPORT NAME=BlueDot FILE=Textures\LaserDot.PCX MIPS=OFF FLAGS=2

var	s_Player	Player;

simulated event Actor SpawnNotification(Actor A)
{
	if (Player == none)
		foreach AllActors(class's_Player', Player)
		{
			if (Player.Player != None)
				break;
		}

	if (s_HUD(Player.MyHUD).bColorBlind)
		A.Texture=Texture'BlueDot';
	else
		A.Texture=Texture'TODatas.Engine.LaserDot';

	return A;
}

defaultproperties
{
	bHidden=True
	ActorClass=Class's_LaserDot'
}

