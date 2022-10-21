// $Id: TOSTAnnouncer.uc 554 2004-04-11 15:18:51Z stark $
//----------------------------------------------------------------------------
//	Project	: TOST Announcer
//	File	: TOSTAnnouncer.uc
//	Version	: 0.1 (08/05/2003)
//	Author	: DiLDoG
//----------------------------------------------------------------------------
// 	Version	Changes
// 	0.1		+ Ported from AOTAnnouncer_102
//  0.2		+ "Killing spree ended by..." added
//			+ Fixed #WICKEDSICK!!!
//----------------------------------------------------------------------------

class TOSTAnnouncer extends TOSTPiece;

struct PlayerStruct {
	var int			Spawned;
	var int			Lastfrag;
	var int			RecentFrags;
	var int			AliveFrags;
};

var PlayerStruct	PlayerInfo[32];

var			bool	CWMode;
var			bool	bFirstblood;
var			color	MessageColor;

var config	bool	Enabled;
var config	int		SoundSlot;
var config	string	AnnouncerPackage;

//----------------------------------------------------------------------------
// Event Handling
//----------------------------------------------------------------------------
function EventInit() {
	bFirstblood = false;
	super.EventInit();
}

function EventGamePeriodChanged(int GP)
{
	local	int	i;

	// check for AdminReset -> reset player data
	if (GP==0 && s_SWATGame(Level.Game).RoundNumber==1)
	{
		for (i=0; i<32; i++)
		{
			PlayerInfo[i].Spawned = 0;
			PlayerInfo[i].Lastfrag = 0;
			PlayerInfo[i].RecentFrags = 0;
			PlayerInfo[i].AliveFrags = 0;
		}
	}
	super.EventGamePeriodChanged(GP);
}

function EventPlayerConnect(Pawn Player) {
	local	int		i;

	// Initialize the new player's info
	i = TOST.FindPlayerIndex(PlayerPawn(Player));
	if (i != -1) {
		PlayerInfo[i].Spawned = 0;
		PlayerInfo[i].Lastfrag = 0;
		PlayerInfo[i].RecentFrags = 0;
		PlayerInfo[i].AliveFrags = 0;
	}
	super.EventPlayerConnect(Player);
}

function EventPlayerDisconnect(Pawn Player) {
	local	int		i;

	// Reset the player's info
	i = TOST.FindPlayerIndex(PlayerPawn(Player));
	if (i != -1) {
		PlayerInfo[i].Spawned = -1;
		PlayerInfo[i].Lastfrag = -1;
		PlayerInfo[i].RecentFrags = -1;
		PlayerInfo[i].AliveFrags = -1;
	}
	super.EventPlayerDisconnect(Player);
}

function EventTeamChange(Pawn Other) {
	local int		i;

	// Set the players spawned value to current time
	i = TOST.FindPlayerIndex(PlayerPawn(Other));
	if (i != -1) {
		PlayerInfo[i].Spawned = Level.TimeSeconds;
	}
	super.EventTeamChange(Other);
}

function bool EventPreventDeath (Pawn Victim, Pawn instigatedBy, name DamageType, Vector HitLocation) {
	local string	KillerName;
	local string	OtherName;
	local int		i, j;

	// skip hossie kills
	if (Victim.IsA('s_NPCHostage') || !Enabled || CWMode)
		return super.EventPreventDeath(Victim, instigatedBy, DamageType, HitLocation);

	// Load player info
	if (instigatedBy != none)	KillerName = instigatedBy.PlayerReplicationInfo.PlayerName;
	if (Victim != none)			OtherName = Victim.PlayerReplicationInfo.PlayerName;

	// Get the player's tost index
	i = TOST.FindPlayerIndex(PlayerPawn(instigatedBy));
	j = TOST.FindPlayerIndex(PlayerPawn(Victim));

	// Update Player stats
	if(i != -1) {
		if(PlayerInfo[i].Lastfrag + 5 < Level.TimeSeconds) PlayerInfo[i].RecentFrags = 0;
		PlayerInfo[i].Lastfrag = Level.TimeSeconds;
		PlayerInfo[i].RecentFrags++;
		PlayerInfo[i].AliveFrags++;
	}
	if(j != -1) {
		if(PlayerInfo[j].AliveFrags >= 3 && instigatedBy != none) {
			SendTextMessage(OtherName$"'s killing spree was ended by"@KillerName);
		}
		PlayerInfo[j].RecentFrags = 0;
		PlayerInfo[j].AliveFrags = 0;
	}

	// Check for suicide
	if(instigatedBy==Victim || instigatedBy==none) {
		if(GetSuicideReason(DamageType) != "")
			SendTextMessage(OtherName@GetSuicideReason(DamageType));
	}

	// Check for Teamkill
	else if(instigatedBy.PlayerReplicationInfo.Team == Victim.PlayerReplicationInfo.Team) {
		SendTextMessage(KillerName@"teamkilled"@OtherName);
		SendTextMessage("#Teamkill!",instigatedBy);
		SendVoiceMessage("kill_teamkill",instigatedBy);
	}

	// Check for First blood
	else if(!bFirstblood) {
		SendTextMessage(KillerName@"draws first blood!");
		SendTextMessage("#FirstBlood!", instigatedBy);
		SendVoiceMessage("kill_firstblood", instigatedBy);
		bFirstblood = true;
	}

	// Check for spawnkill
	else if(j != -1 && (PlayerInfo[j].Spawned + 7.5) > Level.TimeSeconds) {
		SendTextMessage(KillerName@"spawnkilled"@OtherName);
		SendTextMessage("#SpawnKill!", instigatedBy);
		SendVoiceMessage("kill_spawnkill", instigatedBy);
	}

	// Check for doublekill
	else if(i != -1 && PlayerInfo[i].RecentFrags > 1) {
		SendTextMessage(GetMultiKillText(PlayerInfo[i].RecentFrags), instigatedBy);
		SendVoiceMessage(GetMultiKillVoice(PlayerInfo[i].RecentFrags), instigatedBy);
	}

	// Check for killing spree
	else if(i != -1 && GetSpreeText(PlayerInfo[i].AliveFrags) != "") {
		SendTextMessage(KillerName@"is"@GetSpreeText2(PlayerInfo[i].AliveFrags));
		SendTextMessage(GetSpreeText(PlayerInfo[i].AliveFrags), instigatedBy);
		SendVoiceMessage(GetSpreeVoice(PlayerInfo[i].AliveFrags), instigatedBy);
	}

	// Check for Headshot
	else if ((HitLocation.Z - Victim.Location.Z) > 28) {
		InstigatedBy.ReceiveLocalizedMessage( class'DecapitationMessage' );
		//SendTextMessage("#Headshot", InstigatedBy);
		SendVoiceMessage("kill_headshot", InstigatedBy);
	}

	return super.EventPreventDeath(Victim, instigatedBy, DamageType, HitLocation);
}


//----------------------------------------------------------------------------
// TOST Message Handling
//----------------------------------------------------------------------------
function EventMessage(TOSTPiece Sender, int MsgIndex)
{
	switch (MsgIndex)
	{
		// CWModeChanges
		case 117			:	CWMode = Sender.Params.Param5;
								break;
		// GetValue
		case 120 			:	GetValue(Sender.Params.Param6, Sender, Sender.Params.Param1);
								break;
		// SetValue
		case 121 			:	SetValue(Sender.Params.Param6, Sender.Params.Param1, Sender.Params.Param2, Sender.Params.Param3, Sender.Params.Param4, Sender.Params.Param5);
								break;
		// GetSettings
		case 143 			:	GetSettings(Sender);
								break;
	}
	super.EventMessage(Sender, MsgIndex);
}

function bool EventCheckClearance(TOSTPiece Sender, PlayerPawn Player, int MsgType, out int Allowed)
{
	// allow reading values
	if (MsgType == 120 && (Sender.Params.Param1 == 200))
	{
		Allowed = 1;
		return true;
	}

	return super.EventCheckClearance(Sender, Player, MsgType, Allowed);
}

function EventAnswerMessage(TOSTPiece Sender, int MsgIndex)
{
	switch (MsgIndex)
	{
		// SetSettings - report back error messages
		case 144 			:	SetSettings(Sender, Sender.Params.Param4);
								break;
	}
}


//----------------------------------------------------------------------------
// TOST Settings Handling
//----------------------------------------------------------------------------
function GetValue(PlayerPawn Player, TOSTPiece Sender, int Index)
{
	Params.Param1 = Index;
	Params.Param6 = Player;

	switch (Index)
	{
		case 200 :	Params.Param5 = Enabled;
				    break;
	}
	if (Index == 200)
	{
		if (Player != None)
			SendClientMessage(100);
		else
			SendAnswerMessage(Sender, 120);
	}
}

function SetValue(PlayerPawn Player, int Index, int i, float f, string s, bool b)
{
	switch (Index)
	{
		case 200 :	Enabled = b;
					break;
	}
	SaveConfig();
}

function GetSettings(TOSTPiece Sender)
{
	Params.Param4 = string(int(Enabled));
	SendAnswerMessage(Sender, 143);
}

function SetSettings(TOSTPiece Sender, string Settings)
{
	if (Settings != "")
	{
		Enabled = bool(Settings);
		SaveConfig();
	}
}


//----------------------------------------------------------------------------
// Player message functions
//----------------------------------------------------------------------------
function SendTextMessage(string Message, optional Pawn P) {
	if (P == none) {
		for (P=Level.PawnList; P!=None; P=P.nextPawn) {
			SendTextMessage(Message, P);
		}
		return;
	}
	if (!P.IsA('PlayerPawn')) return;
	if (left(Message,1) == "#") {
		PlayerPawn(P).ClearProgressMessages();
		PlayerPawn(P).SetProgressTime(4);
		PlayerPawn(P).SetProgressColor(MessageColor,0);
		PlayerPawn(P).SetProgressMessage(right(Message,len(Message)-1),0);
	}
	else {
		P.ClientMessage(Message);
	}
}

function SendVoiceMessage(string Message, optional Pawn P) {
	if (P == none) {
		for (P=Level.PawnList; P!=None; P=P.nextPawn) {
			SendVoiceMessage(Message, P);
		}
		return;
	}
	if (!P.IsA('PlayerPawn')) return;
	Params.Param1 = SoundSlot;
	Params.Param2 = 0;
	Params.Param6 = PlayerPawn(P);
	Params.Param4 = AnnouncerPackage$"."$Message;
	SendClientMessage(121);
}


//----------------------------------------------------------------------------
// Message functionsm
//----------------------------------------------------------------------------
function string GetSuicideReason(name DamageType) {
	switch DamageType {
		case 'Explosion':	return "blew himself up with a nade";
		case 'Fell':		return "fell to death";
		case 'Drowned':		return "drowned";
		case 'Hit':			return "got hit by a nade";
		default: 			return "";
	}
}

function string GetMultiKillText(int RecentFrags) {
	switch RecentFrags {
		case 2:				return "#Double Kill!";
		case 3:				return "#Multi Kill!";
		case 4:				return "#ULTRA KILL!!";
		case 5: 			return "#M O N S T E R  K I L L !!!";
		default:			return "#> > >  L U D I C R O U S  K I L L  < < <";
	}
}

function string GetMultiKillVoice(int RecentFrags) {
	switch RecentFrags {
		case 2:				return "kill_doublekill";
		case 3:				return "kill_multikill";
		case 4:				return "kill_ultrakill";
		case 5:				return "kill_monsterkill";
		default:			return "kill_ludicrouskill";
	}
}

function string GetSpreeText(int FragCount) {
	switch FragCount {
		case 4:				return "#Killing Spree";
		case 7:				return "#Rampage";
		case 10:			return "#Dominating";
		case 13:			return "#Unstoppable!";
		case 16:			return "#Godlike!!";
		case 20:			return "#WICKED SICK!!!";
		default:			return "";
	}
}

function string GetSpreeText2(int FragCount) {
	switch FragCount {
		case 4:				return "on Killing Spree";
		case 7:				return "on Rampage";
		case 10:			return "Dominating";
		case 13:			return "Unstoppable!";
		case 16:			return "Godlike!!";
		case 20:			return "WICKED SICK!!!";
		default:			return "";
	}
}

function string GetSpreeVoice(int FragCount) {
	switch FragCount {
		case 4:				return "state_killingspree";
		case 7:				return "state_rampage";
		case 10:			return "state_dominating";
		case 13:			return "state_unstoppable";
		case 16:			return "state_godlike";
		case 20:			return "state_whickedsick";
		default:			return "";
	}
}

//----------------------------------------------------------------------------
//  defaultproperties
//----------------------------------------------------------------------------
defaultproperties
{
    ServerOnly=true
	MessageColor=(R=255, G=0, B=0, A=0)
    Enabled=True
    AnnouncerPackage="Announcer2k3"
    PieceName="TOST Announcer"
    PieceVersion="0.4.7.0"
    PieceOrder=300
    BaseMessage=300
}
