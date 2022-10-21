// $Id: TOSTClient.uc 549 2004-04-11 11:43:20Z stark $
//----------------------------------------------------------------------------
// Project : TOST
// File    : TOSTClient.uc
// Version : 1.1
// Author  : BugBunny/Stark
//----------------------------------------------------------------------------

class TOSTClient expands TOSTPiece config;

var	class<Inventory>	CommanderClasses[5];

var	TOSTCommunicator	Comm[32];
var string				CltActors;
var string				GUITabs;
var string				TOPVersion;

var config string		CustomLogoTexture;
var config int			CustomLogoHeight;
var config string		ServerText[4];
var config string		WelcomeSound;

var	TOSTWeaponRenamer	WR;

function		RegisterClientActor(string ActorClass)
{
	if (CltActors == "")
		CltActors = ActorClass;
	else
		CltActors = CltActors$";"$ActorClass;
}

function		RegisterGUITab(string Tab)
{
	if (GUITabs == "")
		GUITabs = Tab;
	else
		GUITabs = GUITabs$";"$Tab;
}

function		RegisterCommander(string CmdrClass)
{
	local	int	i;

	while (i<ArrayCount(CommanderClasses) && CommanderClasses[i] != none)
		i++;
	if (CommanderClasses[i] != none)
	{
		XLog("Warning: Already"@ArrayCount(CommanderClasses)@"commander classes installed, ignoring "$CmdrClass);
		return;
	}

	CommanderClasses[i] = class<Inventory>(DynamicLoadObject(CmdrClass, class'Class', true));
}

function	AttachCommander(Pawn Other)
{
	local Inventory Inv;
	local int i;

	if (Other != None && Other.IsA('PlayerPawn'))
	{
		Inv = Other.FindInventoryType(class'TOSTCommander');
		if ( Inv == None )
		{
			Inv = Spawn(class'TOSTCommander', Other);
			if( Inv != None )
			{
				Inv.GiveTo(Other);
				Inv.bHeldItem = True;
			}
			for (i=0; i<ArrayCount(CommanderClasses); i++)
				if (CommanderClasses[i] != none)
				{
					Inv = Spawn(CommanderClasses[i], Other);
					if( Inv != None )
					{
						Inv.GiveTo(Other);
						Inv.bHeldItem = True;
					}
				}
		}
	}
}

function	Tick(float Delta)
{
	local	int	i;

	for (i=0; i<32; i++)
	{
		if (Comm[i] != none)
			AttachCommander(Comm[i].MyPlayer);
	}
}

function	TriggerRename()
{
	if (WR != none)
		WR.Rename();
}

function	RequestMapData(PlayerPawn Player)
{
	Params.Param6 = Player;
	SendMessage(154);
}

function	ClientPlaySound(PlayerPawn Player, string MySound, optional int PID)
{
	Params.Param1 = 3;
	Params.Param2 = PID;
	Params.Param6 = Player;
	Params.Param4 = MySound;
	SendClientMessage(121);
}

function	PlayExtraSound(string MySound, int PID, optional int SenderID)
{
	local	PlayerPawn	MyPlayer;
	local	int			i;

	if (PID != 0)
	{
		MyPlayer = FindPlayerByID(PID);
		if (MyPlayer != None)
			ClientPlaySound(MyPlayer, MySound, SenderID);
	} else {
		for (i=0; i<32; i++)
		{
			if (Comm[i] != none)
				ClientPlaySound(Comm[i].MyPlayer, MySound, SenderID);
		}
	}
}

function 	GetLogoInformation(PlayerPawn Player, int ID)
{
	local	int		i;

	if (ID == 0)
	{
		ClientPlaySound(Player, WelcomeSound, 0);
		i = TOST.FindPlayerIndex(Player);
		if (i != -1)
			Comm[i].WelcomeSoundPlayed = true;

		// TOST Logo
		Params.Param1 = 0;
		Params.Param6 = Player;
		Params.Param5 = false;

		Params.Param2 = 0;
		Params.Param4 = TOST.TOSTVersion;
		SendClientMessage(130);

		if (TOPVersion != "")
		{
			Params.Param2 = 7;
			Params.Param4 = TOPVersion;
			SendClientMessage(130);
		}

		Params.Param2 = 6;
		Params.Param4 = String(CustomLogoHeight);
		SendClientMessage(130);

		Params.Param2 = 1;
		Params.Param4 = CustomLogoTexture;
		Params.Param5 = (ServerText[0] == "");
		SendClientMessage(130);

		if (ServerText[0] != "")
		{
			Params.Param2 = 2;
			Params.Param4 = ServerText[0];
			Params.Param5 = (ServerText[1] == "");
			SendClientMessage(130);
			if (ServerText[1] != "")
			{
				Params.Param2 = 3;
				Params.Param4 = ServerText[1];
				Params.Param5 = (ServerText[2] == "");
				SendClientMessage(130);
				if (ServerText[2] != "")
				{
					Params.Param2 = 4;
					Params.Param4 = ServerText[2];
					Params.Param5 = (ServerText[3] == "");
					SendClientMessage(130);
					if (ServerText[3] != "")
					{
						Params.Param2 = 5;
						Params.Param4 = ServerText[3];
						Params.Param5 = true;
						SendClientMessage(130);
					}
				}
			}
		}
	}
}

// - EVENT HANDLING

function 		EventInit()
{
	local	TOSTPiece			P;

	RegisterClientActor(PackageName$".TOSTHUDExtension");
	RegisterClientActor(PackageName$".TOSTHUDTOSTLogo");
	RegisterClientActor(PackageName$".TOSTBlueLaserDot");

	RegisterGUITab(PackageName$".TOSTGUIAdminTab");
	RegisterGUITab(PackageName$".TOSTGUIGameTab");
	RegisterGUITab(PackageName$".TOSTGUIVoteTab");

	WR = spawn(class'TOSTWeaponRenamer', self);
	WR.Rename();

	P = TOST.GetPieceByName("TOST TOP3 Support");
	if (P != none)
	{
		// Check for misconfigured tp
		TOPVersion = P.GetPropertyText("AdminWarning");

		// Display tp version if everything is ok
		if ( TOPVersion == "")
			TOPVersion = "supporting TOProtect Build "$P.GetPropertyText("TOPVersion");
	}

	P = TOST.GetPieceByName("TOST Protect");
	if (P == none)
		TOPVersion = "NO CHEAT PROTECTION RUNNING!";

	super.EventInit();
}

function 		EventPlayerConnect(Pawn Player)
{
	local	int		i;

	i = TOST.FindPlayerIndex(PlayerPawn(Player));
	if (i != -1 && Comm[i] == none)
	{
		Comm[i]= Spawn(class'TOSTCommunicator', Player);
		Comm[i].MyPlayer = PlayerPawn(Player);
		Comm[i].Client = self;
	}

	super.EventPlayerConnect(Player);
}

function 		EventPlayerDisconnect(Pawn Player)
{
	local	int		i;

	i = TOST.FindPlayerIndex(PlayerPawn(Player));
	if (i != -1)
		Comm[i].Destroy();

	super.EventPlayerDisconnect(Player);
}

function 		EventModifyPlayer(Pawn Other)
{
	AttachCommander(Other);
	super.EventModifyPlayer(Other);
}

function bool	EventNotifyPlayer(TOSTPiece Sender, int MsgType, PlayerPawn Player, string Msg)
{
	local	int		i;

	switch (MsgType)
	{
		// display normal (chat area)
		case 0 :	return super.EventNotifyPlayer(Sender, MsgType, Player, Msg);
					break;
		case 1 :	if (!super.EventNotifyPlayer(Sender, MsgType, Player, Msg))
					{
						i = TOST.FindPlayerIndex(Player);
						if (i != -1)
						{
							if (Comm[i].WelcomeSoundPlayed)
							{
								Params.Param6 = Player;
								Params.Param4 = Sender.PieceName$":"@Msg;
								SendClientMessage(120);
							} else {
								Comm[i].AddHistoryMessage(Sender.PieceName$":"@Msg);
							}
						}
					}
					return true;
					break;
		case 2 :	if (!super.EventNotifyPlayer(Sender, MsgType, Player, Msg))
					{
						i = TOST.FindPlayerIndex(Player);
						if (i != -1)
							Comm[i].AddHistoryMessage(Sender.PieceName$":"@Msg);
					}
					return true;
					break;
	}
	return	super.EventNotifyPlayer(Sender, MsgType, Player, Msg);
}

// ** MESSAGE HANDLING

function bool	EventCheckClearance(TOSTPiece Sender, PlayerPawn Player, int MsgType, out int Allowed)
{
	// allow GetLogoInformation for everyone
	if (MsgType == BaseMessage+2)
	{
		Allowed = 1;
		return true;
	}
	return super.EventCheckClearance(Sender, Player, MsgType, Allowed);
}

function	EventMessage(TOSTPiece Sender, int MsgIndex)
{
	switch (MsgIndex)
	{
		// RegisterClientActor
		case BaseMessage+0	:   RegisterClientActor(Sender.Params.Param4);
								break;
		// RegisterGUITab
		case BaseMessage+1	:   RegisterGUITab(Sender.Params.Param4);
								break;
		// GetLogoInformation
		case BaseMessage+2	:   GetLogoInformation(Sender.Params.Param6, Sender.Params.Param1);
								break;
		// PlayExtraSound
		case BaseMessage+3	:   PlayExtraSound(Sender.Params.Param4, Sender.Params.Param1);
								break;
		// RegisterCommander :
		case BaseMessage+4	:	RegisterCommander(Sender.Params.Param4);
								break;
		// TriggerRename :
		case BaseMessage+5	:	TriggerRename();
								break;
		// GetMessageName
		case 203			:	TranslateMessage(Sender);
								break;
	}
	Super.EventMessage(Sender, MsgIndex);
}

function	TranslateMessage(TOSTPiece Sender)
{
	switch (Sender.Params.Param1)
	{
		case BaseMessage+3  : Sender.Params.Param4 = "PlayExtraSound"; break;

		default : break;
	}
}

defaultproperties
{
	PieceName="TOST Client"
	PieceVersion="1.2.6.0"
	ServerOnly=false

	CltActors=""
	GUITabs=""

	CustomLogoTexture=""
	CustomLogoHeight=0
	ServerText(0)=""
	ServerText(1)=""
	ServerText(2)=""
	ServerText(3)=""

	WelcomeSound=""

	BaseMessage=160
}
