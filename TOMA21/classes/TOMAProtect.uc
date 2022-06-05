class TOMAProtect extends Actor;

var PlayerPawn PP;
var bool bool1;
var bool bool2;
var int count1;
var int count2;

replication
{
	reliable if (Role<Role_Authority)
		fonction5,fonction4;
}

simulated function PostBeginPlay()
{
	SetTimer(10.00+FRand(),False);
	count2=0;
	count1=0;
}

simulated function Timer()
{
	if (Owner==None)
	{
		Destroy();
		return;
	}
	if (!bool1)
	{
		bool1=True;
		PP=PlayerPawn(Owner);
		if (fonction1())
		{
			bool2=True;
			SetTimer(10.00+FRand(),True);
		}
		else
		{
			SetTimer(10.00+FRand(),True);
		}
		return;
	}
	if (bool2)
	{
		fonction3();
	}
	if (Role==Role_Authority)
	{
		count2++;
		if (count2>5)
		{
			if (count1<1)
			{
				fonction5("CheckMeChecks missing!! (Cheater?)");
			}
			else
			{
				count2=0;
				count1=0;
			}
		}
	}
}

final simulated function bool fonction1()
{
	return (PP.Player!=None) && (PP.Player.Console!=None);
}

/*final simulated function fonction2()
{
	local Actor A;

	foreach AllActors(Class'Actor',A)
	{
		if (InStr(Caps(string(A)),Caps("Elf"))>=0)
		{
			fonction5("Illegal actor:" @ Caps(string(A)));
			return;
		}
	}
}*/

final simulated function fonction3 ()
{
	if ( bool(PP.ConsoleCommand("get ini:Engine.Engine.ViewportManager NoLighting")) )
	{
		PP.ConsoleCommand("set ini:Engine.Engine.ViewportManager NoLighting false");
	}
	if ( InStr(string(PP.Player.Console),"TO_Console") < 0 )
	{
		fonction5("Illegal Console (cheater?)" @ string(PP.Player.Console));
		return;
	}
	if ( InStr(string(TournamentConsole(PP.Player.Console).Root),"TO_RootWindow") < 0 )
	{
		fonction5("Illegal RootWindow (cheater?)" @ string(TournamentConsole(PP.Player.Console).Root));
		return;
	}
	if ( InStr(string(PP.myHUD),"TOMAHud") < 0 )
	{
		fonction5("Illegal HUD (cheater?)" @ string(PP.myHUD));
		return;
	}
	fonction4(PP.Player.Console.Class,TournamentConsole(PP.Player.Console).Root.Class,PP.myHUD.Class);
}

final function fonction4(Class<Console> MyConsole,Class<UWindowRootWindow> myRootWindow,Class<HUD> myHUD)
{
	local string StrConsole;
	local string StrRoot;
	local string StrHUD;

	StrConsole=string(MyConsole);
	StrRoot=string(myRootWindow);
	StrHUD=string(myHUD);
	if (!(StrConsole~="TOPModels.TO_Console"))
	{
		fonction5("Illegal Console (cheater?)" @ StrConsole);
		return;
	}
	if (!(StrRoot~="TOSystem.TO_RootWindow"))
	{
		fonction5("Illegal RootWindow (cheater?)" @ StrRoot);
		return;
	}
	if (!(StrHUD~="TOMA21.TOMAHud"))
	{
		fonction5("Illegal HUD (cheater?)" @ StrHUD);
		return;
	}
	count1++;
}

final function fonction5 (string why)
{
	if (PP.IsA('TO_SysPlayer'))
	{
		TO_SysPlayer(PP).ForceTempKickBan(why);
	}
	else
	{
		PP.Destroy();
	}
}

defaultproperties
{
    bHidden=True
    bAlwaysRelevant=True
    bAlwaysTick=True
    RemoteRole=ROLE_SimulatedProxy
    DrawType=0
    Texture=None
}

