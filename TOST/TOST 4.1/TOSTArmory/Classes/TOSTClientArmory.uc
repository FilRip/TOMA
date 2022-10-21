//----------------------------------------------------------------------------
// Project : TOST
// File    : TOSTClientArmory.uc
// Version : 0.5
// Author  : BugBunny
//----------------------------------------------------------------------------
// Version	Changes
// 0.5		+ first release
//----------------------------------------------------------------------------

class TOSTClientArmory expands ReplicationInfo;

// Client & Server
var	PlayerPawn		MyPlayer;

// Server
var	TOSTArmory		Armory;

// Client
var	TOSTArmoryConfig	Cfg;
var	TO_GUIBaseMgr		Mgr;
var TOSTClientPiece		Connect;

replication
{
    // Server->Client
   	reliable if (ROLE == ROLE_Authority && !bDemoRecording)
		SetConfigClass, ClearAllWeapons;

    // Client->Server
	reliable if ( Role < ROLE_Authority )
		ClientReady;
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

// * ClientReady - signals server client is ready
function ClientReady()
{
	SetConfigClass(String(Armory.Cfg.Class));
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
			ClientReady();
			GotoState('');
		}
	}
begin:
	ClearAllWeapons();
	while(true)
	{
		WaitForPlayer();
		Sleep(0.000001);
	}
}

simulated	function	SetConfigClass(string ConfigClass)
{
	local	int				i;
 	local	class<actor>	NewClass;
 	local	TOSTWeaponRenamer	WR;

	NewClass = class<actor>( DynamicLoadObject(ConfigClass, class'Class', true) );
	if (class<TOSTArmoryConfig>(NewClass) != none)
		Cfg = TOSTArmoryConfig(Spawn(NewClass, self));
	else
		Cfg = Spawn(class'TOSTArmory340', self);
	Log("Loaded Armory Setup : "$string(Cfg.Class));

	for (i=0; i<32; i++)
		AddWeapon(i);
	for (i=0; i<32; i++)
		AdjustWeapon(i);

	foreach AllActors(class'TOSTWeaponRenamer', WR)
	{
		WR.Rename();
		break;
	}
}

simulated 	function	AdjustWeapon(int Index)
{
 	local	class<actor>	NewClass;
 	local	string	WeaponClass;

	WeaponClass = Cfg.GetWeaponClass(Index);
 	if (WeaponClass == "")
 		return;

	NewClass = class<actor>( DynamicLoadObject( WeaponClass, class'Class', true ) );
	if (class<s_Weapon>(NewClass) != None)
	{
		Cfg.SetWeaponData(Index, class<s_Weapon>(NewClass));
	}
}

simulated function	AddWeapon(int Index)
{
	Cfg.AddWeapon(Index);
}

simulated function	ClearAllWeapons()
{
	local	int	i;

	class'TOModels.TO_WeaponsHandler'.ResetConfig();
	for (i=0; i<32; i++)
		class'TOModels.TO_WeaponsHandler'.default.WeaponStr[i]="";
	class'TOModels.TO_WeaponsHandler'.default.NumWeapons=0;
}

defaultproperties
{
	bAlwaysRelevant=False
	bAlwaysTick=True
	RemoteRole=ROLE_SimulatedProxy
	NetPriority=1.000000

	bHidden=True
}

