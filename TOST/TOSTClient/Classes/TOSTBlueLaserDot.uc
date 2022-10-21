// $Id: TOSTBlueLaserDot.uc 533 2004-04-05 03:38:49Z stark $
//----------------------------------------------------------------------------
// Project : TOST
// File    : TOSTBlueLaserDot.uc
// Version : 1.0
// Author  : BugBunny/Stark
//----------------------------------------------------------------------------

class TOSTBlueLaserDot expands SpawnNotify;

#exec TEXTURE IMPORT NAME=BlueDot FILE=Textures\LaserDot.PCX    MIPS=OFF FLAGS=2
#exec texture IMPORT NAME=BigDot  FILE=Textures\LaserDotBig40.PCX MIPS=OFF FLAGS=2

var	s_Player			Player;
var TOSTHudExtension	HudExt;
var TOSTCommunicator	TC;

simulated event Actor SpawnNotification(Actor A)
{
	if (Player == none)
		foreach AllActors(class's_Player', Player)
		{
			if (Player.Player != None)
				break;
		}
		foreach AllActors(class'TOSTCommunicator', TC)
			break;

	if (s_HUD(Player.MyHUD).bColorBlind)
		A.Texture=Texture'BlueDot';
	else if (TC!=None && TC.CheckForLaserDotFix())
		A.Texture=Texture'BigDot';
	else
		A.Texture=Texture'TODatas.Engine.LaserDot';

	return A;
}

defaultproperties
{
	bHidden=True
	ActorClass=Class's_LaserDot'
}

