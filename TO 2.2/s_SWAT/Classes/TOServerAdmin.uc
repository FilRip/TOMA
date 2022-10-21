//=============================================================================
// TOServerAdmin
//=============================================================================
//
// Tactical Ops
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen and Benoit "JAH" Delayen
//=============================================================================

class TOServerAdmin expands UTServerAdmin config;


///////////////////////////////////////
// QueryCurrentPlayers
///////////////////////////////////////

function QueryCurrentPlayers(WebRequest Request, WebResponse Response)
{
	local string Sort, PlayerListSubst, TempStr;
	local ListItem PlayerList, TempItem;
	local Pawn P;
	local int i, PawnCount, j;
	local string IP;
	
	Sort = Request.GetVariable("Sort", "Name");
	
	for (P=Level.PawnList; P!=None; P=P.NextPawn)
	{
		if(		PlayerPawn(P) != None 
			&&	P.PlayerReplicationInfo != None
			&&	NetConnection(PlayerPawn(P).Player) != None)
		{
			if(Request.GetVariable("BanPlayer"$string(P.PlayerReplicationInfo.PlayerID)) != "")
			{
				IP = PlayerPawn(P).GetPlayerNetworkAddress();
				if(Level.Game.CheckIPPolicy(IP))
				{
					IP = Left(IP, InStr(IP, ":"));
					Log("Adding IP Ban for: "$IP);
					for(j=0;j<50;j++)
						if(Level.Game.IPPolicies[j] == "")
							break;
					if(j < 50)
						Level.Game.IPPolicies[j] = "DENY,"$IP;
					Level.Game.SaveConfig();
				}
				P.Destroy();
			}
			else
			{
				if(Request.GetVariable("KickPlayer"$string(P.PlayerReplicationInfo.PlayerID)) != "")
					P.Destroy();
			}
		}
	}

	if (Request.GetVariable("SetMinPlayers", "") != "")
	{
		if ( DeathMatchPlus(Level.Game) != None )
			DeathMatchPlus(Level.Game).MinPlayers = Min(Max(int(Request.GetVariable("MinPlayers", String(0))), 0), 16);
		else if ( TO_DeathMatchPlus(Level.Game) != None )
			TO_DeathMatchPlus(Level.Game).MinPlayers = Min(Max(int(Request.GetVariable("MinPlayers", String(0))), 0), 16);

		Level.Game.SaveConfig();
	}
	
	for (P=Level.PawnList; P!=None; P=P.NextPawn) {
		if (P.bIsPlayer && !P.bDeleteMe && UTServerAdminSpectator(P) == None) {
			PawnCount++;
			TempItem = new(None) class'ListItem';

			if (P.PlayerReplicationInfo.bIsABot) {
				TempItem.Data = "<tr><td width=\"1%\" colspan=2>&nbsp;</td>";
				TempStr = "&nbsp;(Bot)";
			}
			else {
				TempItem.Data = "<tr><td width=\"1%\"><div align=\"center\"><input type=\"checkbox\" name=\"KickPlayer"$P.PlayerReplicationInfo.PlayerID$"\" value=\"kick\"></div></td><td width=\"1%\"><div align=\"center\"><input type=\"checkbox\" name=\"BanPlayer"$P.PlayerReplicationInfo.PlayerID$"\" value=\"ban\"></div></td>";
				if (P.PlayerReplicationInfo.bIsSpectator)
					TempStr = "&nbsp;(Spectator)";
				else
					TempStr = "";
			}
			if(PlayerPawn(P) != None)
			{
				IP = PlayerPawn(P).GetPlayerNetworkAddress();
				IP = Left(IP, InStr(IP, ":"));
			}
			else
				IP = "";
			TempItem.Data = TempItem.Data$"<td><div align=\"left\">"$P.PlayerReplicationInfo.PlayerName$TempStr$"</div></td><td width=\"1%\"><div align=\"center\">"$P.PlayerReplicationInfo.TeamName$"&nbsp;</div></td><td width=\"1%\"><div align=\"center\">"$P.PlayerReplicationInfo.Ping$"</div></td><td width=\"1%\"><div align=\"center\">"$int(P.PlayerReplicationInfo.Score)$"</div></td><td width=\"1%\"><div align=\"center\">"$IP$"</div></td></tr>";
			
			switch (Sort) {
				case "Name":
					TempItem.Tag = P.PlayerReplicationInfo.PlayerName; break;
				case "Team":
					TempItem.Tag = PadLeft(P.PlayerReplicationInfo.TeamName, 2, "0"); break;
				case "Ping":
					TempItem.Tag = PadLeft(String(P.PlayerReplicationInfo.Ping), 4, "0"); break;
				default:
					TempItem.Tag = PadLeft(String(int(P.PlayerReplicationInfo.Score)), 3, "0"); break;
				}
			if (PlayerList == None)
				PlayerList = TempItem;
			else
				PlayerList.AddSortedElement(PlayerList, TempItem);
		}
	}
	if (PawnCount > 0) {
		if (Sort ~= "Score")
			for (TempItem=PlayerList; TempItem!=None; TempItem=TempItem.Next)
				PlayerListSubst = TempItem.Data$PlayerListSubst;
			
		else
			for (TempItem=PlayerList; TempItem!=None; TempItem=TempItem.Next)
				PlayerListSubst = PlayerListSubst$TempItem.Data;
	}
	else
		PlayerListSubst = "<tr align=\"center\"><td colspan=\"5\">** No Players Connected **</td></tr>";

	Response.Subst("PlayerList", PlayerListSubst);
	Response.Subst("CurrentGame", Level.Game.GameReplicationInfo.GameName$" in "$Level.Title);
	Response.Subst("PostAction", CurrentPlayersPage);
	Response.Subst("Sort", Sort);

	if ( DeathMatchPlus(Level.Game) != None )
		Response.Subst("MinPlayers", String(DeathMatchPlus(Level.Game).MinPlayers));
	else if ( TO_DeathMatchPlus(Level.Game) != None )
		Response.Subst("MinPlayers", String(TO_DeathMatchPlus(Level.Game).MinPlayers));

	Response.IncludeUHTM(CurrentPlayersPage$".uhtm");
}


///////////////////////////////////////
// QueryCurrentGame
///////////////////////////////////////

function QueryCurrentGame(WebRequest Request, WebResponse Response)
{
	local ListItem ExcludeMaps, IncludeMaps;
	local class<DeathMatchPlus> NewClass;
	local class<TO_DeathMatchPlus> NewClass2;
	local string NewGameType;
	
	if ( Request.GetVariable("SwitchGameTypeAndMap", "") != "" ) 
	{
		Level.ServerTravel(Request.GetVariable("MapSelect")$"?game="$Request.GetVariable("GameTypeSelect")$"?mutator="$UsedMutators(), false);
		Response.Subst("Title", "Please Wait");
		Response.Subst("Message", "The server is now switching to map '"$Request.GetVariable("MapSelect")$"' and game type '"$Request.GetVariable("GameTypeSelect")$"'.  Please allow 10-15 seconds while the server changes levels.");
		Response.IncludeUHTM(MessageUHTM);
	}
	else if ( Request.GetVariable("SwitchGameType", "") != "" ) 
	{
		NewGameType = Request.GetVariable("GameTypeSelect");
		NewClass = class<DeathMatchPlus>(DynamicLoadObject(NewGameType, class'Class'));
		NewClass2 = class<TO_DeathMatchPlus>(DynamicLoadObject(NewGameType, class'Class'));
		
		if ( NewClass != None )
		{
			ReloadExcludeMaps(ExcludeMaps, NewGameType);
			ReloadIncludeMaps(ExcludeMaps, IncludeMaps, NewGameType);

			Response.Subst("GameTypeButton", "");
			Response.Subst("MapButton", "<input type=\"submit\" name=\"SwitchGameTypeAndMap\" value=\"Switch\">");
			Response.Subst("GameTypeSelect", NewClass.default.GameName$"<input type=\"hidden\" name=\"GameTypeSelect\" value=\""$NewGameType$"\">");
			Response.Subst("MapSelect", GenerateMapListSelect(IncludeMaps));
			Response.Subst("PostAction", CurrentGamePage);
			Response.IncludeUHTM(CurrentGamePage$".uhtm");
		}
		else if ( NewClass2 != None )
		{
			ReloadExcludeMaps(ExcludeMaps, NewGameType);
			ReloadIncludeMaps(ExcludeMaps, IncludeMaps, NewGameType);

			Response.Subst("GameTypeButton", "");
			Response.Subst("MapButton", "<input type=\"submit\" name=\"SwitchGameTypeAndMap\" value=\"Switch\">");
			Response.Subst("GameTypeSelect", NewClass2.default.GameName$"<input type=\"hidden\" name=\"GameTypeSelect\" value=\""$NewGameType$"\">");
			Response.Subst("MapSelect", GenerateMapListSelect(IncludeMaps));
			Response.Subst("PostAction", CurrentGamePage);
			Response.IncludeUHTM(CurrentGamePage$".uhtm");
		}
	}
	else if ( Request.GetVariable("SwitchMap", "") != "" ) 
	{
		Level.ServerTravel(Request.GetVariable("MapSelect")$"?game="$Level.Game.Class$"?mutator="$UsedMutators(), false);
		Response.Subst("Title", "Please Wait");
		Response.Subst("Message", "The server is now switching to map '"$Request.GetVariable("MapSelect")$"'.    Please allow 10-15 seconds while the server changes levels.");
		Response.IncludeUHTM(MessageUHTM);

	}
	else 
	{
		ReloadExcludeMaps(ExcludeMaps, String(Level.Game.Class));
		ReloadIncludeMaps(ExcludeMaps, IncludeMaps, String(Level.Game.Class));

		Response.Subst("GameTypeButton", "<input type=\"submit\" name=\"SwitchGameType\" value=\"Switch\">");
		Response.Subst("MapButton", "<input type=\"submit\" name=\"SwitchMap\" value=\"Switch\">");
		Response.Subst("GameTypeSelect", "<select name=\"GameTypeSelect\">"$GenerateGameTypeOptions(String(Level.Game.Class))$"</select>");
		Response.Subst("MapSelect", GenerateMapListSelect(IncludeMaps, Left(string(Level), InStr(string(Level), "."))$".unr") );
		Response.Subst("PostAction", CurrentGamePage);
		Response.IncludeUHTM(CurrentGamePage$".uhtm");
	}
}


///////////////////////////////////////
// QueryDefaultsRules
///////////////////////////////////////

function QueryDefaultsRules(WebRequest Request, WebResponse Response)
{
	local String GameType, FragName, FragLimit, TimeLimit, MaxTeams, FriendlyFire, PlayersBalanceTeams, ForceRespawn;
	local String MaxPlayers, MaxSpectators, WeaponsStay, Tournament;
	local	String bMirrorDamage, bExplosionsFF, bAllowGhostCam, RoundDuration, PreRoundDuration;
	local class<GameInfo> GameClass;
	local	bool	bUT;
	
	GameType = Request.GetVariable("GameType", GameTypeList.Data);
	GameClass = class<GameInfo>(DynamicLoadObject(GameType, class'Class'));
	bUT = class<DeathMatchPlus>(GameClass) != None;

	if ( bUT )
		MaxPlayers = Request.GetVariable("MaxPlayers", String(class<DeathMatchPlus>(GameClass).Default.MaxPlayers));
	else
		MaxPlayers = Request.GetVariable("MaxPlayers", String(class<TO_DeathMatchPlus>(GameClass).Default.MaxPlayers));

	MaxPlayers = String(max(int(MaxPlayers), 0));

	if ( bUT )
		class<DeathMatchPlus>(GameClass).Default.MaxPlayers = int(MaxPlayers);
	else
		class<TO_DeathMatchPlus>(GameClass).Default.MaxPlayers = int(MaxPlayers);

	Response.Subst("MaxPlayers", MaxPlayers);
	
	if ( bUT )
		MaxSpectators = Request.GetVariable("MaxSpectators", String(class<DeathMatchPlus>(GameClass).Default.MaxSpectators));
	else
		MaxSpectators = Request.GetVariable("MaxSpectators", String(class<TO_DeathMatchPlus>(GameClass).Default.MaxSpectators));

	MaxSpectators = String(max(int(MaxSpectators), 0));
	
	if ( bUT )
		class<DeathMatchPlus>(GameClass).Default.MaxSpectators = int(MaxSpectators);
	else
		class<TO_DeathMatchPlus>(GameClass).Default.MaxSpectators = int(MaxSpectators);
	
	Response.Subst("MaxSpectators", MaxSpectators);
	
	if ( bUT )
	{
		WeaponsStay = String(class<DeathMatchPlus>(GameClass).Default.bMultiWeaponStay);
		Tournament = String(class<DeathMatchPlus>(GameClass).Default.bTournament);

		if(	class<TeamGamePlus>(GameClass) != None )
			PlayersBalanceTeams = String(class<TeamGamePlus>(GameClass).Default.bPlayersBalanceTeams);
	
		if(	class<LastManStanding>(GameClass) == None )
			ForceRespawn = String(class<DeathMatchPlus>(GameClass).Default.bForceRespawn);
			
		if (Request.GetVariable("Apply", "") != "") {		
			if(	class<TeamGamePlus>(GameClass) != None )
			{
				PlayersBalanceTeams = Request.GetVariable("PlayersBalanceTeams", "false");
				class<TeamGamePlus>(GameClass).Default.bPlayersBalanceTeams = PlayersBalanceTeams ~= "true";
			}

			if(	class<LastManStanding>(GameClass) == None )
			{
				ForceRespawn = Request.GetVariable("ForceRespawn", "false");
				class<DeathMatchPlus>(GameClass).Default.bForceRespawn = bool(ForceRespawn);
			}

			WeaponsStay = Request.GetVariable("WeaponsStay", "false");
			class<DeathMatchPlus>(GameClass).Default.bMultiWeaponStay = bool(WeaponsStay);

			Tournament = Request.GetVariable("Tournament", "false");
			class<DeathMatchPlus>(GameClass).Default.bTournament = bool(Tournament);
		}

		if (WeaponsStay ~= "true") {
			Response.Subst("WeaponsStay", " checked");
		}
		if (Tournament ~= "true") {
			Response.Subst("Tournament", " checked");
		}
		if(	class<LastManStanding>(GameClass) == None )
		{
			if (ForceRespawn ~= "true")
				ForceRespawn = " checked";
			else
				ForceRespawn = "";
			Response.Subst("ForceRespawnSubst", "<tr><td>Force Respawn</td><td width=\"1%\"><input type=\"checkbox\" name=\"ForceRespawn\" value=\"true\""$ForceRespawn$"></td></tr>");
		}
	}
	else
	{ // bMirrorDamage, bExplosionsFF, bAllowGhostCam

		if(	class<s_SWATGame>(GameClass) != None )
		{
			bMirrorDamage = String(class<s_SWATGame>(GameClass).Default.bMirrorDamage);
			bExplosionsFF = String(class<s_SWATGame>(GameClass).Default.bExplosionsFF);
			bAllowGhostCam = String(class<s_SWATGame>(GameClass).Default.bAllowGhostCam);
		}

		if (	class<TO_TeamGamePlus>(GameClass) != None )
			PlayersBalanceTeams = String(class<TO_TeamGamePlus>(GameClass).Default.bPlayersBalanceTeams);
				
		if (Request.GetVariable("Apply", "") != "") 
		{		
			if(	class<TO_TeamGamePlus>(GameClass) != None )
			{
				PlayersBalanceTeams = Request.GetVariable("PlayersBalanceTeams", "false");
				class<TO_TeamGamePlus>(GameClass).Default.bPlayersBalanceTeams = PlayersBalanceTeams ~= "true";
			}

			if(	class<s_SWATGame>(GameClass) != None )
			{
				bMirrorDamage = Request.GetVariable("bMirrorDamage", "false");
				class<s_SWATGame>(GameClass).Default.bMirrorDamage = bool(bMirrorDamage);

				bExplosionsFF = Request.GetVariable("bExplosionsFF", "false");
				class<s_SWATGame>(GameClass).Default.bExplosionsFF = bool(bExplosionsFF);

				bAllowGhostCam = Request.GetVariable("bAllowGhostCam", "false");
				class<s_SWATGame>(GameClass).Default.bAllowGhostCam = bool(bAllowGhostCam);
			}
		}

		if (bMirrorDamage ~= "true") 
			Response.Subst("bMirrorDamage", " checked");

		if (bExplosionsFF ~= "true") 
			Response.Subst("bExplosionsFF", " checked");

		if (bAllowGhostCam ~= "true") 
			Response.Subst("bAllowGhostCam", " checked");
	}

	if ( bUT )
	{
		if (	class<TeamGamePlus>(GameClass) != None )
		{
			if (PlayersBalanceTeams ~= "true")
				PlayersBalanceTeams = " checked";
			else
				PlayersBalanceTeams = "";
			Response.Subst("BalanceSubst", "<tr><td>Force Balanced Teams</td><td width=\"1%\"><input type=\"checkbox\" name=\"PlayersBalanceTeams\" value=\"true\""$PlayersBalanceTeams$"></td></tr>");
		}

		if (class<DeathMatchPlus>(GameClass) != None && class<Assault>(GameClass) == None) 
		{
	  	if (class<TeamGamePlus>(GameClass) != None) 
			{
		   	FragLimit = Request.GetVariable("FragLimit", String(class<TeamGamePlus>(GameClass).Default.GoalTeamScore));
			 	FragLimit = String(max(int(FragLimit), 0));
				class<TeamGamePlus>(GameClass).Default.GoalTeamScore = float(FragLimit);
				FragName = "Max Team Score";
			}
			else 
			{
			 	FragLimit = Request.GetVariable("FragLimit", String(class<DeathMatchPlus>(GameClass).Default.FragLimit));
    		FragLimit = String(max(int(FragLimit), 0));
    		class<DeathMatchPlus>(GameClass).Default.FragLimit = float(FragLimit);
    		FragName = "Frag Limit";
			}
    	
			Response.Subst("FragSubst", "<tr><td>"$FragName$"</td><td width=\"1%\"><input type=\"text\" name=\"FragLimit\" maxlength=\"3\" size=\"3\" value=\""$FragLimit$"\"></td></tr>");

			if (class<LastManStanding>(GameClass) == None)
			{
    		TimeLimit = Request.GetVariable("TimeLimit", String(class<DeathMatchPlus>(GameClass).Default.TimeLimit));
    		TimeLimit = String(max(int(TimeLimit), 0));
				Response.Subst("TimeLimitSubst", "<tr><td>Time Limit</td><td width=\"1%\"><input type=\"text\" name=\"TimeLimit\" maxlength=\"3\" size=\"3\" value=\""$TimeLimit$"\"></td></tr>");
				class<DeathMatchPlus>(GameClass).Default.TimeLimit = float(TimeLimit);
			}
		}
		
		if(	class<TeamGamePlus>(GameClass) != None && !ClassIsChildOf( GameClass, class'CTFGame' ) &&
			!ClassIsChildOf( GameClass, class'Assault' ) ) 
		{
  		MaxTeams = Request.GetVariable("MaxTeams", String(class<TeamGamePlus>(GameClass).Default.MaxTeams));
  		MaxTeams = String(max(int(MaxTeams), 0));
  		class<TeamGamePlus>(GameClass).Default.MaxTeams = Min(Max(int(MaxTeams), 2), 4);
			Response.Subst("TeamSubst", "<tr><td>Max Teams</td><td width=\"1%\"><input type=\"text\" name=\"MaxTeams\" maxlength=\"2\" size=\"2\" value="$MaxTeams$"></td><td></tr>");
		}
		
		if (class<TeamGamePlus>(GameClass) != None) 
		{
  		FriendlyFire = Request.GetVariable("FriendlyFire", String(class<TeamGamePlus>(GameClass).Default.FriendlyFireScale * 100));
			FriendlyFire = String(min(max(int(FriendlyFire), 0), 100));
  		class<TeamGamePlus>(GameClass).Default.FriendlyFireScale = float(FriendlyFire)/100.0;
			Response.Subst("FriendlyFireSubst", "<tr><td>Friendly Fire: [0-100]%</td><td width=\"1%\"><input type=\"text\" name=\"FriendlyFire\" maxlength=\"3\" size=\"3\" value=\""$FriendlyFire$"\"></td></tr>");
		}
	}
	else
	{
		if (class<TO_DeathMatchPlus>(GameClass) != None)
		{
    	TimeLimit = Request.GetVariable("TimeLimit", String(class<TO_DeathMatchPlus>(GameClass).Default.TimeLimit));
    	TimeLimit = String(max(int(TimeLimit), 0));
			Response.Subst("TimeLimitSubst", "<tr><td>Time Limit</td><td width=\"1%\"><input type=\"text\" name=\"TimeLimit\" maxlength=\"3\" size=\"3\" value=\""$TimeLimit$"\"></td></tr>");
			class<TO_DeathMatchPlus>(GameClass).Default.TimeLimit = float(TimeLimit);
		}

		if (	class<TO_TeamGamePlus>(GameClass) != None )
		{
			if (PlayersBalanceTeams ~= "true")
				PlayersBalanceTeams = " checked";
			else
				PlayersBalanceTeams = "";
			Response.Subst("BalanceSubst", "<tr><td>Force Balanced Teams</td><td width=\"1%\"><input type=\"checkbox\" name=\"PlayersBalanceTeams\" value=\"true\""$PlayersBalanceTeams$"></td></tr>");

  		MaxTeams = Request.GetVariable("MaxTeams", String(class<TO_TeamGamePlus>(GameClass).Default.MaxTeams));
  		MaxTeams = String(max(int(MaxTeams), 0));
  		class<TO_TeamGamePlus>(GameClass).Default.MaxTeams = Min(Max(int(MaxTeams), 2), 4);
			Response.Subst("TeamSubst", "<tr><td>Max Teams</td><td width=\"1%\"><input type=\"text\" name=\"MaxTeams\" maxlength=\"2\" size=\"2\" value="$MaxTeams$"></td><td></tr>");

			FriendlyFire = Request.GetVariable("FriendlyFire", String(class<TO_TeamGamePlus>(GameClass).Default.FriendlyFireScale * 100));
			FriendlyFire = String(min(max(int(FriendlyFire), 0), 100));
  		class<TO_TeamGamePlus>(GameClass).Default.FriendlyFireScale = float(FriendlyFire)/100.0;
			Response.Subst("FriendlyFireSubst", "<tr><td>Friendly Fire: [0-100]%</td><td width=\"1%\"><input type=\"text\" name=\"FriendlyFire\" maxlength=\"3\" size=\"3\" value=\""$FriendlyFire$"\"></td></tr>");
		}

		// bMirrorDamage, bExplosionsFF, bAllowGhostCam, RoundDuration, PreRoundDuration

		if (class<s_SWATGame>(GameClass) != None) 
		{
  		RoundDuration = Request.GetVariable("RoundDuration", String(class<s_SWATGame>(GameClass).Default.RoundDuration));
			RoundDuration = String(max(int(RoundDuration), 0));
  		class<s_SWATGame>(GameClass).Default.RoundDuration = int(RoundDuration);
			Response.Subst("RoundDurationSubst", "<tr><td>RoundDuration: </td><td width=\"1%\"><input type=\"text\" name=\"RoundDuration\" maxlength=\"3\" size=\"3\" value=\""$RoundDuration$"\"></td></tr>");

  		PreRoundDuration = Request.GetVariable("PreRoundDuration", String(class<s_SWATGame>(GameClass).Default.PreRoundDuration1));
			PreRoundDuration = String(max(int(PreRoundDuration), 0));
  		class<s_SWATGame>(GameClass).Default.PreRoundDuration1 = int(PreRoundDuration);
			Response.Subst("PreRoundDurationSubst", "<tr><td>PreRoundDuration: </td><td width=\"1%\"><input type=\"text\" name=\"PreRoundDuration\" maxlength=\"3\" size=\"3\" value=\""$PreRoundDuration$"\"></td></tr>");
		}

	}

	Response.Subst("PostAction", DefaultsRulesPage);
  Response.Subst("GameType", GameType);
  Response.IncludeUHTM(DefaultsRulesPage$".uhtm");
	Response.ClearSubst();
	
	GameClass.Static.StaticSaveConfig();
}


///////////////////////////////////////
// QueryDefaultsSettings
///////////////////////////////////////

function QueryDefaultsSettings(WebRequest Request, WebResponse Response)
{
	local String GameType, UseTranslocator, bEnableBallistics;
	local class<GameInfo> GameClass;
	local int GameStyle, GameSpeed, AirControl;
	local	bool	bUT;
	
	GameType = Request.GetVariable("GameType", GameTypeList.Data);
	GameClass = class<GameInfo>(DynamicLoadObject(GameType, class'Class'));
	bUT = class<DeathMatchPlus>(GameClass) != None;

	if ( bUT && class<DeathMatchPlus>(GameClass).Default.bMegaSpeed == true )
		GameStyle = 1;
	else if ( !bUT && class<TO_DeathMatchPlus>(GameClass).Default.bMegaSpeed == true )
		GameStyle = 1;

	if ( bUT && class<DeathMatchPlus>(GameClass).Default.bHardCoreMode == true )
		GameStyle += 1;
	else if ( !bUT && class<TO_DeathMatchPlus>(GameClass).Default.bHardCoreMode == true )
		GameStyle += 1;

	switch ( Request.GetVariable("GameStyle", String(GameStyle)) ) 
	{
	case "0":
		if ( bUT )
		{
			class<DeathMatchPlus>(GameClass).Default.bMegaSpeed = false;
			class<DeathMatchPlus>(GameClass).Default.bHardCoreMode = false;
		}
		else
		{
			class<TO_DeathMatchPlus>(GameClass).Default.bMegaSpeed = false;
			class<TO_DeathMatchPlus>(GameClass).Default.bHardCoreMode = false;
		}
		Response.Subst("Normal", " selected"); break;
		break;

	case "1":
		if ( bUT )
		{
			class<DeathMatchPlus>(GameClass).Default.bMegaSpeed = false;
			class<DeathMatchPlus>(GameClass).Default.bHardCoreMode = true;
		}
		else
		{
			class<TO_DeathMatchPlus>(GameClass).Default.bMegaSpeed = false;
			class<TO_DeathMatchPlus>(GameClass).Default.bHardCoreMode = true;
		}
		Response.Subst("HardCore", " selected"); break;

	case "2":
		if ( bUT )
		{
			class<DeathMatchPlus>(GameClass).Default.bMegaSpeed = true;
			class<DeathMatchPlus>(GameClass).Default.bHardCoreMode = true;
		}
		else
		{
			class<TO_DeathMatchPlus>(GameClass).Default.bMegaSpeed = true;
			class<TO_DeathMatchPlus>(GameClass).Default.bHardCoreMode = true;
		}
		Response.Subst("Turbo", " selected"); break;
	}

	if ( bUT )
	{
		GameSpeed = class<DeathMatchPlus>(GameClass).Default.GameSpeed * 100.0;
		AirControl = class<DeathMatchPlus>(GameClass).Default.AirControl * 100.0;
		UseTranslocator = String(class<DeathMatchPlus>(GameClass).Default.bUseTranslocator);
	}
	else
	{
		GameSpeed = class<TO_DeathMatchPlus>(GameClass).Default.GameSpeed * 100.0;
		AirControl = class<TO_DeathMatchPlus>(GameClass).Default.AirControl * 100.0;
		bEnableBallistics = String(class<s_SWATGame>(GameClass).Default.bEnableBallistics);
	}

	if (Request.GetVariable("Apply", "") != "" ) 
	{
		GameSpeed = min(max(int(Request.GetVariable("GameSpeed", String(GameSpeed))), 10), 200);
		AirControl = min(max(int(Request.GetVariable("AirControl", String(AirControl))), 0), 100);
		bEnableBallistics = Request.GetVariable("bEnableBallistics", "false");

		if ( bUT )
		{
			class<DeathMatchPlus>(GameClass).Default.GameSpeed = GameSpeed / 100.0;
			class<DeathMatchPlus>(GameClass).Default.AirControl = AirControl / 100.0;
			class<DeathMatchPlus>(GameClass).Default.bUseTranslocator = bool(UseTranslocator);
		}
		else
		{
			class<TO_DeathMatchPlus>(GameClass).Default.GameSpeed = GameSpeed / 100.0;
			class<TO_DeathMatchPlus>(GameClass).Default.AirControl = AirControl / 100.0;
			class<s_SWATGame>(GameClass).Default.bEnableBallistics = bool(bEnableBallistics);
		}
	}
	
	Response.Subst("GameSpeed", String(GameSpeed));
	Response.Subst("AirControl", String(AirControl));
	if (UseTranslocator ~= "true")
		Response.Subst("UseTranslocator", " checked");
	
	if (bEnableBallistics ~= "true")
		Response.Subst("bEnableBallistics", " checked");

	Response.Subst("PostAction", DefaultsSettingsPage);
	Response.Subst("GameType", GameType);
	Response.IncludeUHTM(DefaultsSettingsPage$".uhtm");
	Response.ClearSubst();
	
	GameClass.Static.StaticSaveConfig();
}


///////////////////////////////////////
// QueryDefaultsBots
///////////////////////////////////////

function QueryDefaultsBots(WebRequest Request, WebResponse Response)
{
	local String GameType, AutoAdjustSkill, RandomOrder, BalanceTeams, DumbDown;
	local class<GameInfo> GameClass;
	local class<ChallengeBotInfo> BotConfig;
	local int BotDifficulty, MinPlayers;
	local	bool	bUT;
	
	GameType = Request.GetVariable("GameType", GameTypeList.Data);
	GameClass = class<GameInfo>(DynamicLoadObject(GameType, class'Class'));
	bUT = class<DeathMatchPlus>(GameClass) != None;	

	if ( bUT )
		BotConfig = class<DeathMatchPlus>(GameClass).Default.BotConfigType;
	else
		BotConfig = class<s_SWATGame>(GameClass).Default.BotConfigType;

	if (Request.GetVariable("Apply", "") != "") 
	{
		BotDifficulty = int(Request.GetVariable("BotDifficulty", String(BotDifficulty)));
		BotConfig.Default.Difficulty = BotDifficulty;
		
		MinPlayers = min(max(int(Request.GetVariable("MinPlayers", String(MinPlayers))), 0), 16);
	
		if ( bUT )
			class<DeathMatchPlus>(GameClass).Default.MinPlayers = MinPlayers;
		else
			class<TO_DeathMatchPlus>(GameClass).Default.MinPlayers = MinPlayers;

		AutoAdjustSkill = Request.GetVariable("AutoAdjustSkill", "false");
		BotConfig.Default.bAdjustSkill = bool(AutoAdjustSkill);

		RandomOrder = Request.GetVariable("RandomOrder", "false");
		BotConfig.Default.bRandomOrder = bool(RandomOrder);

		if ( bUT )
		{
			if (class<TeamGamePlus>(GameClass) != None) 
			{
				BalanceTeams = Request.GetVariable("BalanceTeams", "false");
				class<TeamGamePlus>(GameClass).Default.bBalanceTeams = bool(BalanceTeams);

				if (class<Domination>(GameClass) != None) 
				{
					DumbDown = Request.GetVariable("DumbDown", "true");
					class<Domination>(GameClass).Default.bDumbDown = bool(Dumbdown);
				}
			}
		}
		else
		{
			if ( class<TO_TeamGamePlus>(GameClass) != None) 
			{
				BalanceTeams = Request.GetVariable("BalanceTeams", "false");
				class<TO_TeamGamePlus>(GameClass).Default.bBalanceTeams = bool(BalanceTeams);
			}
		}

		BotConfig.Static.StaticSaveConfig();
		GameClass.Static.StaticSaveConfig();
	}

	BotDifficulty = BotConfig.Default.Difficulty;

	if ( bUT )
		MinPlayers = class<DeathMatchPlus>(GameClass).Default.MinPlayers;
	else
		MinPlayers = class<TO_DeathMatchPlus>(GameClass).Default.MinPlayers;
	
	AutoAdjustSkill = String(BotConfig.Default.bAdjustSkill);
	RandomOrder = String(BotConfig.Default.bRandomOrder);
	
	if ( bUT )
	{
		if (class<TeamGamePlus>(GameClass) != None)
			BalanceTeams = String(class<TeamGamePlus>(GameClass).Default.bBalanceTeams);

		if (class<Domination>(GameClass) != None)
			DumbDown = String(class<Domination>(GameClass).Default.bDumbDown);
	}
	else
	{
		if (class<TO_TeamGamePlus>(GameClass) != None)
			BalanceTeams = String(class<TO_TeamGamePlus>(GameClass).Default.bBalanceTeams);
	}

	Response.Subst("BotDifficulty"$BotDifficulty, " selected");
	Response.Subst("MinPlayers", String(MinPlayers));
	
	if (AutoAdjustSkill ~= "true")
		Response.Subst("AutoAdjustSkill", " checked");
	if (RandomOrder ~= "true")
		Response.Subst("RandomOrder", " checked");

	if ( bUT )
	{
		if (class<TeamGamePlus>(GameClass) != None) 
		{
			if (BalanceTeams ~= "true")
				BalanceTeams = " checked";
			else
				BalanceTeams = "";
			Response.Subst("BalanceSubst", "<tr><td>Bots Balance Teams</td><td width=\"1%\"><input type=\"checkbox\" name=\"BalanceTeams\" value=\"true\""$BalanceTeams$"></td></tr>");

			if (class<Domination>(GameClass) != None) 
			{
				if (DumbDown ~= "false")
					DumbDown = " checked";
				else
					DumbDown = "";
				Response.Subst("DumbDownSubst", "<tr><td>Enhanced AI</td><td width=\"1%\"><input type=\"checkbox\" name=\"DumbDown\" value=\"false\""$DumbDown$"></td></tr>");
			}
		}
	}
	else
	{
		if ( class<TO_TeamGamePlus>(GameClass) != None ) 
		{
			if (BalanceTeams ~= "true")
				BalanceTeams = " checked";
			else
				BalanceTeams = "";
			Response.Subst("BalanceSubst", "<tr><td>Bots Balance Teams</td><td width=\"1%\"><input type=\"checkbox\" name=\"BalanceTeams\" value=\"true\""$BalanceTeams$"></td></tr>");
		}
	}

	Response.Subst("PostAction", DefaultsBotsPage);
	Response.Subst("GameType", GameType);
	Response.IncludeUHTM(DefaultsBotsPage$".uhtm");
	Response.ClearSubst();
}


///////////////////////////////////////
// defaultproperties
///////////////////////////////////////

defaultproperties
{
     DefaultsRulesPage="TO_defaults_rules"
     DefaultsSettingsPage="TO_defaults_settings"
}
