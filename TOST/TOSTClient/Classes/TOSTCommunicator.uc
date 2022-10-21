// $Id: TOSTCommunicator.uc 519 2004-04-01 23:43:40Z stark $
//----------------------------------------------------------------------------
// Project : TOST
// File    : TOSTCommunicator.uc
// Version : 1.0
// Author  : BugBunny
//----------------------------------------------------------------------------

class TOSTCommunicator expands ReplicationInfo;

// Client & Server
var	PlayerPawn		MyPlayer;

// Server
var TOSTClient		Client;
var	bool			WelcomeSoundPlayed;

// Client
var int				StartUserTab;
var int				CountUserTab;
var string			CltActorClasses;
var string			CltGUITabs;
var	TOSTWeaponRenamer	WR;

var string			Tabs[255];

var int				SemiAdmin;

var private bool	bBiggerLaserDot;

var	TOSTClientMapHandler	MapHandler;
var TOSTGUIMaster			GUIMaster;

replication
{
    // Server->Client
   	reliable if (ROLE == ROLE_Authority && !bDemoRecording)
		AddHistoryMessage, LoadClientStuff;

    // Client->Server
	reliable if ( Role < ROLE_Authority )
		SendInitData;
}

// startup code
simulated event PostNetBeginPlay ()
{
	super.PostNetBeginPlay();
	if ( (Level.NetMode == NM_Client && ROLE < ROLE_SimulatedProxy) || (!bNetOwner))
		return;
	GotoState('ClientInit');
}

// SERVER

function	SendInitData()
{
	LoadClientStuff(Client.CltActors, Client.GUITabs);
	Client.RequestMapData(MyPlayer);
}

// CLIENT

// * ClientInit - find the player and attach HUD mutator
simulated state ClientInit
{
	simulated function WaitForPlayer()
	{
		local	PlayerPawn 			P;

		if ( MyPlayer == None)
		{
			foreach AllActors(class'PlayerPawn', P)
			{
				if (P.Player != None)
				{
					MyPlayer = P;
					break;
				}
			}
		} else {
			if (MyPlayer.myHUD != none && s_HUD(MyPlayer.myHUD).UserInterface != none)
			{
				MapHandler = spawn(class'TOSTClientMapHandler', self);
				MapHandler.Master = self;
				GUIMaster = spawn(class'TOSTGUIMaster', self);
				GUIMaster.Master = self;
				GUIMaster.Mgr = s_HUD(MyPlayer.myHUD).UserInterface;

				WR = spawn(class'TOSTWeaponRenamer', self);
				WR.Rename();

				// DE Fix:
				if (MyPlayer.Player.IsA('WINDOWSVIEWPORT') &&
				Caps(MyPlayer.ConsoleCommand("getcurrentrenderdevice"))=="OPENGLDRV.OPENGLRENDERDEVICE")
				{
					log("Bigger Laserdot for Windows OpenGL", 'TOSTCommunicator');
					bBiggerLaserDot = true;
				}

				SendInitData();
				GotoState('');
			}
		}
	}
begin:
	while(true)
	{
		WaitForPlayer();
		Sleep(0.000001);
	}
}

// * FindGUITab - find registered tab
simulated function	int	FindGUITab(string TabName)
{
	local	int	i;

	for (i=0; i<ArrayCount(Tabs); i++)
	{
		if (Caps(Tabs[i]) == Caps(TabName))
			return i;
	}
	return -1;
}

// * LoadGUITab - load/register GUI tab dynamically
simulated function	LoadGUITab(string ClassStr)
{
	local 	class<TOSTGUIBaseTab>	TC;
	local	TOSTGUIBaseTab			Tab;
	local	TO_GUIBaseMgr			Mgr;
	local	byte					OldTab;
	local	TOSTClientPiece			CC;

    if (s_HUD(MyPlayer.MyHUD) == none)
    	return;

   	TC = class<TOSTGUIBaseTab>(DynamicLoadObject(ClassStr, class'Class', true));
   	if (TC != none)
   	{
   		Mgr = s_HUD(MyPlayer.MyHUD).UserInterface;
		OldTab = Mgr.CurrentTab;
	   	Mgr.TOUI_Tool_AddTab(StartUserTab+CountUserTab, TC);
	   	Mgr.CurrentTab = StartUserTab+CountUserTab;
	   	Tab = TOSTGUIBaseTab(Mgr.GetCurrentTab());
	   	Mgr.CurrentTab = OldTab;
	   	Tab.Master = self;
	   	Tabs[StartUserTab+CountUserTab] = Tab.TabName;
		log("Loading : "$Tab.TabName, 'TOST');
		if (Tab.TabCommClass != none)
		{
			CC = spawn(Tab.TabCommClass, self);
			if (CC != none)
			{
				Tab.TabComm = CC;
				CC.MasterTab = Tab;
			} else {
				log("Failed to load comm module for tab : "$Tab.TabCommClass, 'TOST');
			}
		}

	   	CountUserTab++;
	} else {
		log("Failed to load : "$ClassStr, 'TOST');
	}
}

// * LoadComponent - load component dynamically
simulated function	LoadComponent(string ClassStr)
{
	local 	Actor			A;
	local 	class<Actor>	AC;
	local	SpawnNotify		SN;

   	AC = class<Actor>(DynamicLoadObject(ClassStr, class'Class', true));
	A = Spawn(AC, MyPlayer);
	if (A != None)
	{
		log("Loading : "$ClassStr, 'TOST');
		if (A.IsA('TOSTHUDMutator'))
		{
			TOSTHUDMutator(A).MyHUD = ChallengeHUD(MyPlayer.myHUD);
			TOSTHUDMutator(A).MyPlayer = MyPlayer;
			TOSTHUDMutator(A).Master = self;
			TOSTHUDMutator(A).Init();
		}
	} else {
		log("Failed to load : "$ClassStr, 'TOST');
	}
}

// * AttachComponents - spawn and attach components
simulated function	AttachComponents()
{
	local	string			s;
	local	int				i;


    s = CltActorClasses;
    i = InStr(s, ";");
    while (i != -1)
    {
    	LoadComponent(Left(s, i));
		s = Mid(s, i+1);
		i = InStr(s, ";");
    }
    if (s != "")
	    LoadComponent(s);

    s = CltGUITabs;
    i = InStr(s, ";");
    while (i != -1)
    {
    	LoadGUITab(Left(s, i));
		s = Mid(s, i+1);
		i = InStr(s, ";");
    }
    if (s != "")
	    LoadGUITab(s);
}

// * LoadClientStuff - set list of client actors/tabs to be used
simulated function	LoadClientStuff(string CltActors, string CltTabs)
{
	CltActorClasses = CltActors;
	CltGUITabs = CltTabs;
	if (!IsInState('ClientInit'))
		AttachComponents();
}

// * AddHistoryMessage - add message to the console history
simulated function	AddHistoryMessage(string Msg)
{
	MyPlayer.Player.Console.AddString(Msg);
}

simulated function bool CheckForLaserDotFix()
{
	return bBiggerLaserDot;
}

defaultproperties
{
	bAlwaysRelevant=False
	bAlwaysTick=True
	RemoteRole=ROLE_SimulatedProxy
	NetPriority=2.000000

	StartUserTab=50

	bHidden=True
}

