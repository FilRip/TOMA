//=============================================================================
// TO_Credits
//=============================================================================
//
// Tactical Ops
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen
//=============================================================================

class TO_Credits extends Info;


var	String	T[134]; // Text

var	float		ScrollSpeed, FadeDist, YSpace;
var	float		Scale, OldScale, OldClipY;

var	float		Y, Y1, XO, YL; // Coords
var	float		Start, Evol;
var	int			FirstLine;
var	Color		WhiteColor;
var	font		FontType;


///////////////////////////////////////
// Initialize
///////////////////////////////////////

function Initialize( float nX, float nY, float nX1, float nY1, font DaFont, float newFadeDist )
{
	Y = nY; Y1 = nY1;
	XO = (nX1 + nX) / 2.0;
	Start = Y1;
	FontType = DaFont;
	FadeDist = newFadeDist;

	OldClipY = 0.0;
	OldScale = 0.0;
	//FontType = Font(DynamicLoadObject("LadderFonts.UTLadder10", class'Font'));
}


///////////////////////////////////////
// Setup
///////////////////////////////////////

function Setup( Canvas C )
{
	local	float tmp;

	Scale = C.ClipX / 1024;

	if ( OldScale == 0.0 )
		OldScale = Scale;

	if ( OldClipY == 0.0 )
		OldClipY = C.ClipY;

	if ( Scale != OldScale )
	{
		tmp = C.ClipY / OldClipY;
		Y *= tmp; Y1 *= tmp;
		XO *= tmp; 
		if ( Start > Y1 )
			Start = Y1;
		FadeDist *= tmp;
	}
}


///////////////////////////////////////
// RenderCredits
///////////////////////////////////////

function RenderCredits( Canvas C )
{
	local	float		pos, XL;
	local	int			Line;

	//Setup(C);

	C.Font = FontType;
	pos = Start - Evol;
	Line = FirstLine;

	while ( (pos < Y1) && (T[Line] != "") )
	{
		if ( pos > Y )
		{
			if ( pos < (Y+FadeDist) )
				C.DrawColor = WhiteColor * ((pos-Y) / FadeDist); 
			else if ( pos > (Y1-FadeDist) )
				C.DrawColor = WhiteColor * ((y1-pos) / FadeDist);
			else
				C.DrawColor = WhiteColor;

			C.StrLen(T[Line], XL, YL);
			C.SetPos(XO - XL/2.0, pos);
			C.DrawText(T[Line], false);
		}

		Line++;
		pos += YL*YSpace;
	}
}


///////////////////////////////////////
// Tick
///////////////////////////////////////

function Tick( float DeltaTime )
{
	if ( Owner == None )
		Destroy();

	if ( Start > Y )
		Start -= ScrollSpeed*DeltaTime;
	else
	{
		Start = Y;
		Evol += ScrollSpeed*DeltaTime;

		// Next line
		if ( Evol >= YL*YSpace )
		{
			Evol -= YL*YSpace;
			FirstLine++;

			// Restart?
			if ( T[FirstLine] == "" )
			{
				FirstLine = 0;
				Start = Y1;
				Evol = 0.0;
			}
		}
	}
}


///////////////////////////////////////
// defaultproperties
///////////////////////////////////////

defaultproperties
{
     t(0)="Tactical-Ops :: Credits"
     t(1)=" "
     t(2)=" "
     t(3)=" "
     t(4)="Project Leader :: Laurent 'Shag' Delayen"
     t(5)=" "
     t(6)=" "
     t(7)=" "
     t(8)="Webmasters/Administration/PR :: Eric 'rojazz' Rojas"
     t(9)="Webmasters/Administration/PR :: Toby 'Macadoshis' Rees"
     t(10)=" "
     t(11)=" "
     t(12)=" "
     t(13)="Lead programmer :: Laurent 'Shag' Delayen"
     t(14)=" "
     t(15)=" "
     t(16)=" "
     t(17)="Additionnal programming :: Gerke 'j3rky' Preussner"
     t(18)="Additionnal programming :: Mathieu 'EMH_Mark3' Mallet"
     t(19)=" "
     t(20)=" "
     t(21)=" "
     t(22)="Lead Modeler :: Jack 'Warflyr' Davis"
     t(23)=" "
     t(24)=" "
     t(25)=" "
     t(26)="Modeling :: Deyan 'Cyborg' Ninov"
     t(27)="Modeling :: Kurt 'Apocalypse' Cadogan"
     t(28)="Modeling :: Martin 'GSSCP' Behrend"
     t(29)="Modeling :: Nikolai 'MINION' Gregory"
     t(30)=" "
     t(31)=" "
     t(32)=" "
     t(33)="Animating :: Jack 'Warflyr' Davis"
     t(34)=" "
     t(35)=" "
     t(36)=" "
     t(37)="Skinning :: Fredrik 'Svugg' Svegert"
     t(38)="Skinning :: Jack '§ixShooter' Luttig"
     t(39)="Skinning :: Martin 'GSSCP' Behrend"
     t(40)="Skinning :: T.L 'GaNjAmAn' Scheffer "
     t(41)=" "
     t(42)=" "
     t(43)=" "
     t(44)="Graphic Art :: Eric 'rojazz' Rojas"
     t(45)="Graphic Art :: Gerke 'j3rky' Preussner"
     t(46)="Graphic Art :: Jack 'Spinex' Gilson"
     t(47)="Graphic Art :: Laurent 'Shag' Delayen"
     t(48)="Graphic Art :: Toby 'Macadoshis' Rees"
     t(49)=" "
     t(50)=" "
     t(51)=" "
     t(52)="Sound artists :: Barry 'Barra' Abe"
     t(53)="Sound artists :: Jens 'Gonou' Nilsson"
     t(54)="Sound artists :: Jolan 'LineOut' Koks"
     t(55)=" "
     t(56)=" "
     t(57)=" "
     t(58)="Voice Casting and Directing :: Lani Minella"
     t(59)="Voice Casting and Directing :: Pro-Motions Production Company"
     t(60)=" "
     t(61)=" "
     t(62)=" "
     t(63)="Audio Production :: Rick Bowman"
     t(64)="Audio Production :: Lethal Sounds"
     t(65)=" "
     t(66)=" "
     t(67)=" "
     t(68)="Manual :: Toby 'Macadoshis' Rees"
     t(69)=" "
     t(70)=" "
     t(71)=" "
     t(72)="IRC Admin :: Alexc19 "
     t(73)=" "
     t(74)=" "
     t(75)=" "
     t(76)="Lead Map Designer :: Janis 'Flux' Bode"
     t(77)=" "
     t(78)=" "
     t(79)=" "
     t(80)="Map designers :: Jack 'Spinex' Gilson"
     t(81)="Map designers :: Frank 'r@yden' Petri"
     t(82)="Map designers :: Mathieu 'EMH_Mark3' Mallet"
     t(83)="Map designers :: Matthijs 'MatthijsM' Meerman"
     t(84)="Map designers :: Robin 'Nassau' Dowling"
     t(85)="Map designers :: Olivier 'Neuro' Chapuis"
     t(86)="Map designers :: Peter 'Andirez' Andries"
     t(87)="Map designers :: Rich 'Akuma' Eastwood"
     t(88)="Map designers :: Rogelio 'Desperado#2' Olguin"
     t(89)="Map designers :: T.L 'GaNjAmAn' Scheffer"
     t(90)="Map designers :: Tynan 'Dr.Crowbar' Sylvester"
     t(91)="Map designers :: Yordi 'revolver' Malawauw"
     t(92)=" "
     t(93)=" "
     t(94)=" "
     t(95)="Lead Beta Testers :: Dennis 'FoCuS' van Gilst"
     t(96)="Lead Beta Testers :: job"
     t(97)=" "
     t(98)=" "
     t(99)=" "
     t(100)="Windows Beta Testers :: babelfish"
     t(101)="Windows Beta Testers :: Carst 'TDO]Strac' Vaartjes"
     t(102)="Windows Beta Testers :: Christufa"
     t(103)="Windows Beta Testers :: Deyan 'Cyborg' Ninov"
     t(104)="Windows Beta Testers :: EXtReMiKeY"
     t(105)="Windows Beta Testers :: GingerBreadMan"
     t(106)="Windows Beta Testers :: Lauri 'White Lion' Hukari"
     t(107)="Windows Beta Testers :: MacMorty"
     t(108)="Windows Beta Testers :: Michael 'Jestah' Bantz"
     t(109)="Windows Beta Testers :: n0xiOu$"
     t(110)="Windows Beta Testers :: Olivier 'CoCoPRo' Voisin"
     t(111)="Windows Beta Testers :: Punisher"
     t(112)="Windows Beta Testers :: Schlauchi"
     t(113)="Windows Beta Testers :: Stephane 'Wasp' Burgaud-Braeme"
     t(114)="Windows Beta Testers :: Steve 'Steve_uk' Davies"
     t(115)="Windows Beta Testers :: TraXter"
     t(116)="Windows Beta Testers :: Timo 'Lumbo' Kuttenkeuler"
     t(117)="Windows Beta Testers :: Yuriy 'Predator' Kozachuk"
     t(118)=" "
     t(119)=" "
     t(120)=" "
     t(121)="Mac Beta Testers :: Kevin 'Mac_Jedi' Murphy"
     t(122)="Mac Beta Testers :: Mallard"
     t(123)="Mac Beta Testers :: Sebastien 'Indigo' Mougey"
     t(124)="Mac Beta Testers :: Taylor 'Fleek' Rudd"
     t(125)="Mac Beta Testers :: The McBain"
     t(126)=" "
     t(127)=" "
     t(128)=" "
     t(129)="Linux Beta Testers :: Jeroen '2Cool4-U' de Haas"
     t(130)="Linux Beta Testers :: Thomas 'Messias' Keil"
     t(131)="Linux Beta Testers :: Jammet"
     t(132)="Linux Beta Testers :: Headshoot"
     ScrollSpeed=25.000000
     FadeDist=15.000000
     YSpace=1.000000
     WhiteColor=(R=255,G=255,B=255)
     bAlwaysTick=True
     RemoteRole=ROLE_None
}
