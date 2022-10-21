//----------------------------------------------------------------------------
// Project : TOST
// File    : TOSTArmory.uc
// Version : 0.5
// Author  : BugBunny
//----------------------------------------------------------------------------
// Version	Changes
// 0.5		+ first release
//----------------------------------------------------------------------------

class TOSTArmory expands TOSTPiece config;

var config		string	ConfigClass;

var	bool				CWMode;

var	TOSTClientArmory	CA[32];
var	TOSTArmoryConfig	Cfg;

function	AdjustWeapon(int Index)
{
 	local	class<actor>	NewClass;
 	local	string	WeaponClass;

	WeaponClass = Cfg.GetWeaponClass(Index);
 	if (WeaponClass == "")
 		return;

	NewClass = class<actor>( DynamicLoadObject( WeaponClass, class'Class', true ) );
	if (class<s_Weapon>(NewClass) != None)
		Cfg.SetWeaponData(Index, class<s_Weapon>(NewClass));
}

// * ADD WEAPONS STUFF

function	AddWeapon(int Index)
{
	Cfg.AddWeapon(Index);
}

function	ClearAllWeapons()
{
	local	int	i;

	class'TOModels.TO_WeaponsHandler'.ResetConfig();
	for (i=0; i<32; i++)
		class'TOModels.TO_WeaponsHandler'.default.WeaponStr[i]="";
	class'TOModels.TO_WeaponsHandler'.default.NumWeapons=0;
}

// * EVENT HANDLING

function	EventPostInit()
{
	local	int				i;
 	local	class<actor>	NewClass;

	NewClass = class<actor>( DynamicLoadObject(ConfigClass, class'Class', true ) );
	if (class<TOSTArmoryConfig>(NewClass) != none && !CWMode)
		Cfg = TOSTArmoryConfig(Spawn(NewClass, self));
	else
		Cfg = Spawn(class'TOSTArmory340', self);
	XLog("Loaded Armory Setup : "$string(Cfg.Class));

	ClearAllWeapons();
	for (i=0; i<32; i++)
		AddWeapon(i);
	for (i=0; i<32; i++)
		AdjustWeapon(i);

	Cfg.ReplaceDefWeapon();

	// Trigger WeaponRenamer
	SendMessage(165);

	super.EventPostInit();
}

function 		EventPlayerConnect(Pawn Player)
{
	local	int		i;

	i = TOST.FindPlayerIndex(PlayerPawn(Player));
	if (i != -1 && CA[i] == none)
	{
		CA[i]= Spawn(class'TOSTClientArmory', Player);
		CA[i].MyPlayer = PlayerPawn(Player);
		CA[i].Armory = self;

		Cfg.OnPlayerConnect(PlayerPawn(Player));
	}

	super.EventPlayerConnect(Player);
}

function 		EventPlayerDisconnect(Pawn Player)
{
	local	int		i;

	i = TOST.FindPlayerIndex(PlayerPawn(Player));
	if (i != -1)
		CA[i].Destroy();

	super.EventPlayerDisconnect(Player);
}



// * MESSAGE HANDLING

function	EventMessage(TOSTPiece Sender, int MsgIndex)
{
	switch (MsgIndex)
	{
		// CWMode
		case 117			:	CWMode = Sender.Params.Param5;
								break;
/*		// GetValue
		case 120 			:	GetValue(Sender.Params.Param6, Sender, Sender.Params.Param1);
								break;
		// SetValue
		case 121 			:	SetValue(Sender.Params.Param6, Sender.Params.Param1, Sender.Params.Param2, Sender.Params.Param3, Sender.Params.Param4, Sender.Params.Param5);
								break;
		// GetSettings
		case 143 			:	GetSettings(Sender);
								break;
*/
	}
	super.EventMessage(Sender, MsgIndex);
}


defaultproperties
{
	PieceName="TOST Armory"
	PieceVersion="0.5.0.0"
	PieceOrder=110			// need to be after TOST Server Tools because of CW mode propagation
	ServerOnly=false

	CountDown=0
	BaseMessage=170

	ConfigClass="TOSTArmory.TOSTArmory340"
}
