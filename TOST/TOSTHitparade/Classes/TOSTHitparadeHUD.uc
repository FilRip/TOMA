// $Id: TOSTHitparadeHUD.uc 405 2004-01-11 20:02:16Z stark $
//----------------------------------------------------------------------------
// Project : TOSTPiece hitparade
// Author  : [BB]Stark <stark@bbclan.de>
//----------------------------------------------------------------------------

class TOSThitparadeHUD expands TOSTHUDMutator config (TOSTUser);

const MaxLines=32;
var			bool	bEnabled;
var			String	AttLines[32], VicLines[32], pStatLines[32], gStatLines[32];
var config	int		AttackerColorR, AttackerColorG, AttackerColorB;
var config	int		VictimColorR, VictimColorG, VictimColorB;
var config	int		PersonalStatsR, PersonalStatsG, PersonalStatsB;
var config	int		GameStatsR, GameStatsG, GameStatsB;
var	config	int		HUDDisplayTime;
var config	bool	bShowStats;
var         int     ANum, VNum, PNum, GNum;
var         float   Yoffset;

simulated function	Init()
{
	super.Init();
	SaveConfig();
}

simulated 	function	PostRender(Canvas C)
{
	if (bEnabled
        && bShowStats
        && !s_HUD(MyHUD).UserInterface.Visible() )
	{
		drawAtt(C);
		drawVic(C);
		drawPstats(C);
		drawGstats(C);
	}

	if (NextHUDMutator != None && NextHUDMutator != Self)
		NextHUDMutator.PostRender(C);
}

simulated	function	resetHUD()
{
	local int i;
	for (i=0;i<MaxLines;i++)
	{
		AttLines[i] = "";
		VicLines[i] = "";
		pStatLines[i] = "";
		gStatLines[i] = "";
	}

	ANum = 0;
	VNum = 0;
	PNum = 0;
	GNum = 0;
}

simulated function	toggleHUD()
{
	bEnabled = !bEnabled;
}


simulated	function	addAttLine (string L)
{
	local int i;

	for (i=0;i<MaxLines;i++)
	{
		if (AttLines[i]=="")
		{
			AttLines[i] = L;
			ANum++;
			break;
		}
	}
}

simulated	function	addVicLine (string L)
{
	local int i;

	for (i=0;i<MaxLines;i++)
	{
		if (VicLines[i]=="")
		{
			VicLines[i] = L;
			VNum++;
			break;
		}
	}
}

simulated	function	addPstatLine (string L)
{
	local int i;

	for (i=0;i<MaxLines;i++)
	{
		if (pStatLines[i]=="")
		{
			pStatLines[i] = L;
			PNum++;
			break;
		}
	}
}

simulated	function	addGstatLine (string L)
{
	local int i;

	for (i=0;i<MaxLines;i++)
	{
		if (gStatLines[i]=="")
		{
			gStatLines[i] = L;
			GNum++;
			break;
		}
	}
}

simulated 	function 	drawAtt (Canvas C)
{
	local int i, MyX, MyY;

	C.Style = ERenderStyle.STY_Normal;
	C.Font = MyHud.MyFonts.GetSmallestFont(C.ClipX);
	MyX = (C.ClipX * 0.55);
	//MyY = (C.ClipY * 0.50);
    MyY = C.ClipY - Max(VNum, ANum)*15 - C.ClipY/Yoffset;
	C.setPos(myX, MyY);

	C.DrawColor.R = AttackerColorR;
	C.DrawColor.G = AttackerColorG;
	C.DrawColor.B = AttackerColorB;

	for (i=0;i<MaxLines;i++)
	{
		C.setPos(myX, MyY);
		C.DrawText(AttLines[i]);
		MyY+=15;
	}
}

simulated 	function 	drawVic (Canvas C)
{
	local int i, MyX, MyY;

	C.Style = ERenderStyle.STY_Normal;
	C.Font = MyHud.MyFonts.GetSmallestFont(C.ClipX);
	MyX = (115);
	//MyY = (C.ClipY * 0.50);
    MyY = C.ClipY - Max(VNum, ANum)*15 - C.ClipY/Yoffset;
	C.setPos(myX, MyY);

	C.DrawColor.R = VictimColorR;
	C.DrawColor.G = VictimColorG;
	C.DrawColor.B = VictimColorB;

	for (i=0;i<MaxLines;i++)
	{
		C.setPos(myX, MyY);
		C.DrawText(VicLines[i]);
		MyY+=15;
	}
}

simulated 	function 	drawPstats (Canvas C)
{
	local int i, MyX, MyY;

	C.Style = ERenderStyle.STY_Normal;
	C.Font = MyHud.MyFonts.GetSmallestFont(C.ClipX);
	MyX = (115);
    MyY = C.ClipY - Max(VNum, ANum)*15 - Max(PNum, GNum)*15 - 30 - C.ClipY/Yoffset;
	C.setPos(myX, MyY);

	C.DrawColor.R = PersonalStatsR;
	C.DrawColor.G = PersonalStatsG;
	C.DrawColor.B = PersonalStatsB;

	for (i=0; i<MaxLines;i++)
	{
		C.setPos(myX, MyY);
		C.DrawText(pStatLines[i]);
		MyY+=15;
	}
}

simulated 	function 	drawGstats (Canvas C)
{
	local int i, MyX, MyY;

	C.Style = ERenderStyle.STY_Normal;
	C.Font = MyHud.MyFonts.GetSmallestFont(C.ClipX);
	MyX = (C.ClipX * 0.55);
    MyY = C.ClipY - Max(VNum, ANum)*15 - Max(PNum, GNum)*15 - 30 - C.ClipY/Yoffset;
	C.setPos(myX, MyY);

	C.DrawColor.R = GameStatsR;
	C.DrawColor.G = GameStatsG;
	C.DrawColor.B = GameStatsB;

	for (i=0;i<MaxLines;i++)
	{
		C.setPos(myX, MyY);
		C.DrawText(gStatLines[i]);
		MyY+=15;
	}
}

function fadeOutTimer()
{
	setTimer(HUDDisplayTime, false);
}

function Timer()
{
	bEnabled = false;
}

defaultproperties
{
	bHidden=true
	CommClass=class'TOSThitparadeHUDComm'
	AttackerColorR=200
	AttackerColorG=100
	AttackerColorB=100
	VictimColorR=100
	VictimColorG=200
	VictimColorB=100
	PersonalStatsR=255
	PersonalStatsG=255
	PersonalStatsB=255
	GameStatsR=255
	GameStatsG=255
	GameStatsB=255
	HUDDisplayTime=10
	bShowStats=true
	Yoffset=6.5
}
