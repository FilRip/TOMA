//=============================================================================
// UdpServerQuery2
//
// This is a temporary hack fix. For versions 432 - 436
//=============================================================================
class TOSTServerQuery extends UdpServerQuery config;

function string GetInfo ()
{
	local	TOSTServerMutator	TOST;
	local	TOSTPiece			Piece;
	local	string				ResultSet;

	// Find TOST ServerMutator
	foreach AllActors(class'TOSTServerMutator',TOST)
	{
		if (TOST.IsA('TOSTServerMutator')) break;
	}

	ResultSet = "\\hostname\\" $ Level.Game.GameReplicationInfo.ServerName;
	ResultSet = ResultSet $ "\\hostport\\"			$ string(Level.Game.GetServerPort());
	ResultSet = ResultSet $ "\\maptitle\\"			$ Level.Title;
	ResultSet = ResultSet $ "\\mapname\\"			$ Left(string(Level),InStr(string(Level),"."));
	ResultSet = ResultSet $ "\\numplayers\\"		$ string(Level.Game.NumPlayers);
	ResultSet = ResultSet $ "\\maxplayers\\"		$ string(Level.Game.MaxPlayers);
	ResultSet = ResultSet $ "\\gamemode\\"			$ "openplaying";
	ResultSet = ResultSet $ "\\gamever\\"			$ Level.EngineVersion;

	if ( (MinNetVer >= int(Level.MinNetVersion)) && (MinNetVer <= int(Level.EngineVersion)) )
		ResultSet = ResultSet $ "\\minnetver\\"		$ string(MinNetVer);
	else
		ResultSet = ResultSet $ "\\minnetver\\"		$ Level.MinNetVersion;

	if ( GetItemName(string(Level.Game.Class)) == "s_SWATGame" )
		ResultSet = ResultSet $ "\\gametype\\"		$ "TO340";
	else
		ResultSet = ResultSet $ "\\gametype\\"		$ GetItemName(string(Level.Game.Class));

	// Get TOST Version
	if (TOST != none)
		ResultSet = ResultSet $ "\\tostver\\"		$ Mid(TOST.TOSTVersion, InStr(TOST.TOSTVersion, " ") + 1);

	// Get CWMode and Oudated var from TOSTServerTools
	Piece = TOST.GetPieceByName("TOST Server Tools");
	if (Piece != none)
		ResultSet = ResultSet $ "\\cwmode\\"		$ Piece.GetPropertyText("CWMode");

	if (Piece != none && Piece.GetPropertyText("OldVersionWarning") != "")
		ResultSet = ResultSet $ "\\outdated\\"		$ "true";

	// Get NoTPAction
	Piece = TOST.GetPieceByName("TOST TOP2 Support");
	if (Piece != none)
		ResultSet = ResultSet $ "\\notpaction\\"	$ Piece.GetPropertyText("NoTPAction");

	ResultSet = ResultSet $ Level.Game.GetInfo();

	//log("SEND SERVERQUERY:"@ResultSet);
	return ResultSet;
}

// Return a string of information on a player.
function string GetPlayer( PlayerPawn P, int PlayerNum )
{
	local	string	ResultSet;
	local	TO_PRI	PRI;
	local	int		pos;

	PRI = TO_PRI(P.PlayerReplicationInfo);

	// PlayerName (strip '\' chars
	ResultSet = "\\player_"$PlayerNum$"\\";
	for (pos=0;pos<Len(PRI.PlayerName);pos++)
	{
		if (Asc(Mid(PRI.PlayerName, pos, 1)) != 92)
			ResultSet = ResultSet $ Mid(PRI.PlayerName, pos, 1);
	}

	// Frags
	ResultSet = ResultSet$"\\frags_"$PlayerNum$"\\"$int(PRI.Score);

	// Deaths
	ResultSet = ResultSet$"\\deaths_"$PlayerNum$"\\"$int(PRI.Deaths);

	// HPScore
	ResultSet = ResultSet$"\\score_"$PlayerNum$"\\"$(PRI.InflictedDmg/10);

	// TOPStatus
	ResultSet = ResultSet$"\\topstatus_"$PlayerNum$"\\"$PRI.TOPStatus;

	// Ping
	ResultSet = ResultSet$"\\ping_"$PlayerNum$"\\"$int(P.ConsoleCommand("GETPING"));

	// Team
	ResultSet = ResultSet$"\\team_"$PlayerNum$"\\"$PRI.Team;

	// class
	ResultSet = ResultSet$"\\mesh_"$PlayerNum$"\\"$P.Menuname;

	// Skin
	if(P.IsA('s_Player'))
	{
		ResultSet = ResultSet$"\\skin_"$PlayerNum$"\\"$class'TO_ModelHandler'.static.GetModelName(s_Player(P).PlayerModel);
	}
	//log("SERVERQUERY-GETPLAYER:"@ResultSet);
	return ResultSet;
}

// Send data for each player
function bool SendPlayers(IpAddr Addr, int QueryNum, out int PacketNum, int bFinalPacket)
{
	local Pawn P;
	local int i,z;
	local bool Result, SendResult;

	Result = false;

	P = Level.PawnList;

	if(P == None)
		return False;

	while( i < Level.Game.NumPlayers )
	{
		if (P.IsA('PlayerPawn') && P.bIsPlayer)
		{
			if( i==Level.Game.NumPlayers-1 && bFinalPacket==1)
				SendResult = SendQueryPacket(Addr, GetPlayer(PlayerPawn(P), i), QueryNum, PacketNum, 1);
			else
				SendResult = SendQueryPacket(Addr, GetPlayer(PlayerPawn(P), i), QueryNum, PacketNum, 0);
			Result = SendResult || Result;
			i++;
		}
		P = P.nextPawn;
		if(z++ > 32)
			break;
	}
	return Result;
}

// return a string of miscellaneous information.
// Game specific information, user defined data, custom parameters for the command line.
function string GetRules()
{
	local string ResultSet;

	ResultSet = Level.Game.GetRules();

	// Admin's Name
	if( Level.Game.GameReplicationInfo.AdminName != "" )
		ResultSet = ResultSet$"\\AdminName\\"$Level.Game.GameReplicationInfo.AdminName;

	// Admin's Email
	if( Level.Game.GameReplicationInfo.AdminEmail != "" )
		ResultSet = ResultSet$"\\AdminEMail\\"$Level.Game.GameReplicationInfo.AdminEmail;

	//hack fix to add mutators to query BDB
	if(Level.Game.EnabledMutators != "" && (InStr(ResultSet,"mutators") == -1))
		ResultSet = ResultSet $ "\\mutators\\"$Level.Game.EnabledMutators;

	//log("SERVERQUERY-GETRULES:"@ResultSet);
	return ResultSet;
}

defaultproperties
{
}
