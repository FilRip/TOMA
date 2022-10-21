//----------------------------------------------------------------------------
// Project : TOST
// File    : TOSTMapHandling.uc
// Version : 1.1
// Author  : BugBunny
//----------------------------------------------------------------------------
// Version	Changes
// 0.5		+ first release
// 0.6		+ first beta release
// 1.0		+ first public release
// 1.1		# adjusted to TO 340
//----------------------------------------------------------------------------

class TOSTMapHandling expands TOSTPiece config;

var() config bool	NextMap;              		// NextMap Handling - not compatible with MapVote
var() config bool	MapVote;					// activate map vote
var() config int	MapVoteMode;				// 0 = all maps on server, 1 = only maps on cycle
var() config int	MapNoReplay;				// how many maps maps are not allowed to be voted again for
var() config float	MapVotePercentage;			// Votes (%) needed for a end of game map switch
var() config float	MapVotePercentageInGame;	// Votes (%) needed for a in game map switch
var() config int	VoteTime;					// Time [s] to vote
var() config int	NextMapMessageInterval;		// How much time between NextMapMessages ("Next Map will be...")
var() config int    NoVoteAction;               // Where to look for next map if nobody voted? 0 = all maps on Server, 1 = only MapList from ini

// NextMap
var string	NextMapCycle;		// next map to be played in cycle
var string	NextMapChosen;		// next map chosen by an admin
var string	NextMapVoted;		// next map chosen by players
var float	LastNextMapMessage;
var int		SkipCountDown;
var bool	MapSkip;

// map managment
var string	MapList[255];		// map list
var int		MapCount;			// how many maps ?
var string	MapLines[30];		// "compressed" map list
var int		MapLineCount;		// "compressed" map list count

// map vote managment
var int		MapVotes[255];		// map vote count
var string	VotedMap[32];
var int		PlayerCount;
var int		MapVoteCountDown;
var	bool	AdjustedEndTime;
var	bool	AutoMapVote;

// * NormalizeMapName - make sure .unr is presend
function string	NormalizeMapName(string Map)
{
	if ( Right(Map,4) ~= ".unr" )
		return Map;
	else
		return (Map$".unr");
}

// * GetNextMapInCycle - return next map in cycle
function string GetNextMapInCycle()
{
	local MapList	MyList;
	local string	CurrentMap, Map;
	local int		i, MapNum;

	// get next map in cycle
	MyList = spawn(class's_SWAT.s_MapList');
	MapNum = MyList.MapNum;
	CurrentMap = Caps(Level.GetLocalURL());
	CurrentMap = Left(CurrentMap, InStr(CurrentMap, "?"));
	CurrentMap = Mid(CurrentMap, InStr(CurrentMap, "/")+1);
	CurrentMap = NormalizeMapName(CurrentMap);
	for ( i=0; i<ArrayCount(MyList.Maps); i++ )
	{
		Map = NormalizeMapName(MyList.Maps[i]);
		if ( Caps(Map) ~= CurrentMap)
		{
			MapNum = i;
			break;
		}
	}

	MapNum++;
	while ( MapNum < ArrayCount(MyList.Maps) - 1 && ((MyList.Maps[MapNum] == "") || (MyList.Maps[MapNum] ~= CurrentMap)))
		MapNum++;
	if ( MapNum >= ArrayCount(MyList.Maps) - 1 )
		MapNum = 0;

	MyList.MapNum = MapNum;
	MyList.SaveConfig();

	CurrentMap = MyList.Maps[MapNum];
	MyList.Destroy();

	return CurrentMap;
}

// * LoadMapList - find all avaiable maps on server
function LoadMapList()
{
	local string		FirstMap, NextMap, MapName, MapStor;
	local int 			i, j, h, step, CountStor;
  	local bool 			Flag;
  	local s_MapList		MyList;
  	local TOSTMapMemory MapMem;

	NextMap = Level.GetMapName("TO", "", 0);
  	FirstMap = NextMap;
	MapLineCount = 1;
	Flag = false;

	MapCount=0;
	MyList = spawn(class's_SWAT.s_MapList');
	MapMem = spawn(class'TOSTMapMemory');

  	// LoadMapList
  	while(!(FirstMap ~= NextMap) || (!Flag))
  	{
  		Flag=true;
  		//check listindex
  		if(MapCount == 250)
		{
			XLog("Map list size exceeded - more than 250 maps found.");
			break;
		}

		// remove ".unr"
		i = InStr(Caps(NextMap), ".UNR");
		if(i != -1)
			MapName = Left(NextMap, i);

   		// add to list
  		MapList[MapCount] = MapName;

  		// allowed for mapvote ?
  		switch (MapVoteMode)
  		{
  			case 0 :	// all maps allowed
  						MapVotes[MapCount] = 0;
  						break;
  			case 1 :	// only maps in cycle allowed
  						MapVotes[MapCount] = -1;
						for ( i=0; i<ArrayCount(MyList.Maps); i++ )
						{
							if ( (Caps(MapName) == Caps(MyList.Maps[i])) || (Caps(MapName$".UNR") == Caps(MyList.Maps[i])) )
							{
								MapVotes[MapCount] = 0;
								break;
							}
						}
						break;
		}
		if (MapVotes[MapCount] == 0 && MapMem.IsInList(MapName, MapNoReplay))
			MapVotes[MapCount] = -1;

	  	MapCount++;

		NextMap = Level.GetMapName("TO", NextMap, 1);
	}
	MapMem.Destroy();
	MyList.Destroy();

	// shell sort maplist
  	for( h=0; (3*h+1)<MapCount-1; h=3*h+1 );
  	for( h=h; h>0; h=(h-1)/3 )
  	{
    	for(j=h; j<MapCount; j++ )
    	{
	   		MapStor=MapList[j];
    		CountStor=MapVotes[j];
    		i=j-h;
    		while( i>=0 && MapList[i]>MapStor )
    		{
    			MapList[i+h] = MapList[i];
    			MapVotes[i+h] = MapVotes[i];
    			i -= h;
    		}
			MapList[i+h] = MapStor;
			MapVotes[i+h] = CountStor;
		}
	}

	// add to compressed list
	for(i=0;i<MapCount;i++)
	{
		if (MapLineCount < 30) {
			if (Len(MapList[i]) + 4 + Len(MapLines[MapLineCount-1]) > 250) {
				MapLineCount++;
				MapLines[MapLineCount-1] = MapVotes[i]$"%"$MapList[i];
			} else {
				if (MapLines[MapLineCount-1] != "")
					MapLines[MapLineCount-1] = MapLines[MapLineCount-1]$";"$MapVotes[i]$"%"$MapList[i];
				else
					MapLines[MapLineCount-1] = MapVotes[i]$"%"$MapList[i];
			}
		} else {
			XLog("compressed map list size exceeded.");
			break;
		}
	}
}

// * FindMapIndex - find index for map in the list
function	int 	FindMapIndex(string Map)
{
	local	int i;

	if (Map == "")
		return -1;

	for (i=0; i<MapCount; i++)
	{
		if (Caps(NormalizeMapName(Map)) == Caps(NormalizeMapName(MapList[i])))
			return i;
	}
	return -1;
}

// * GetNextMap - get map that will be played next
function		GetNextMap(PlayerPawn Player)
{
	if (NextMapChosen == "") {
		if (MapVote) {
			if (NextMapVoted == "")
				NotifyPlayer(1, Player, "mapvote is enabled");
			else
				NotifyPlayer(1, Player, NextMapVoted@"[MapVote]");
		} else {
			NotifyPlayer(1, Player, NextMapCycle@"[Cycle]");
		}
	} else {
		NotifyPlayer(1, Player, NextMapChosen@"[Admin]");
	}
}

// * SetNextMap - set next map to be played
function		SetNextMap(string Map, PlayerPawn Player)
{
	if (!NextMap)
	{
		NotifyPlayer(1, Player, "Next Map feature is not active !");
		return;
	}

	if (Caps(NormalizeMapName(NextMapChosen)) == Caps(NormalizeMapName(Map)))
	{
		NotifyPlayer(1, Player, "Map already is chosen as next map");
		return;
	}

	if (Map != "" && FindMapIndex(Map) == -1)
	{
		NotifyPlayer(1, Player, "Map"@Map@"is not avaiable on the server");
		return;
	}

	NextMapChosen = Map;
    if (NextMapChosen == "") {
		NotifyAll(1, "Admin reactivated the map cycle - next map is "$NextMapCycle);
	} else {
		NotifyAll(1, Player.PlayerReplicationInfo.PlayerName@"set next map :"$NextMapChosen);
	}
}

// * SwitchMap - perform map travel
function		SwitchMap()
{
	if (NextMapChosen != "") {
		Level.ServerTravel(NextMapChosen $ "?game=s_SWAT.s_SWATGame", false);
	} else {
		if  (NextMapVoted != "")
			Level.ServerTravel(NextMapVoted $ "?game=s_SWAT.s_SWATGame", false);
		else
			Level.ServerTravel(NextMapCycle $ "?game=s_SWAT.s_SWATGame", false);
	}
}

// * SkipMap
function		SkipMap()
{
	MapSkip = true;
	SkipCountDown = 2;
	BroadcastClientMessage(110);
	if (NextMapChosen == "")
		NextMapChosen = NextMapCycle;
}

// * BroadCastNextMap - tell players about upcoming map
function		BroadcastNextMap()
{
	if (!NextMap)
		return;
	if (NextMapChosen == "") {
		if (MapVote) {
			if (NextMapVoted != "")
				NotifyAll(1, "Upcoming map is"@NextMapVoted@"[MapVote]");
		} else {
			NotifyAll(1, "Upcoming map is"@NextMapCycle@"[Cycle]");
		}
	} else {
		NotifyAll(1, "Upcoming map is"@NextMapChosen@"[Admin]");
	}
}

// ** MAP VOTE

// * MapVoteCalculate - sum up votes and create an update list
function	MapVoteCalculate()
{
	local	int 	i, j, MapVoteListCount;
	local	int 	OldMapVote[250];
	local	string  MapVoteList[4];

	// reset
	for (i=0; i<MapCount; i++)
	{
		OldMapVote[i] = MapVotes[i];
		if (MapVotes[i] > 0)
			MapVotes[i] = 0;
	}

	PlayerCount = 0;
	// count
	for (i=0; i<32; i++)
	{
		if (TOST.PlayerPresent(i))
		{
			PlayerCount++;
			j = FindMapIndex(VotedMap[i]);
			if (j != -1 && MapVotes[j] > -1)
				MapVotes[j] = MapVotes[j]+1;
		}
	}

	// check for updates
	MapVoteListCount = 0;
	for (i=0; i<MapCount; i++)
	{
		if (OldMapVote[i] != MapVotes[i])
		{
			if (Len(MapList[i]) + 4 + Len(MapVoteList[MapVoteListCount]) > 250) {
				MapVoteListCount++;
				MapVoteList[MapVoteListCount] = MapVotes[i]$"%"$MapList[i];
			} else {
				if (MapVoteList[MapVoteListCount] != "")
					MapVoteList[MapVoteListCount] = MapVoteList[MapVoteListCount]$";"$MapVotes[i]$"%"$MapList[i];
				else
					MapVoteList[MapVoteListCount] = MapVotes[i]$"%"$MapList[i];
			}
		}
	}

	// send updates to players
	for (j=0; j<=MapVoteListCount; j++)
	{
		Params.Param4 = MapVoteList[j];
		BroadcastClientMessage(104);
	}
}

function	MapVoteSelectBest(bool TimeOut)
{
	local	int		i, j, MaxVotes, MaxCount;
	local	string	MapVoted;
	local   s_MapList sMapList;

	if (NextMapVoted != "")
		return;

	MapVoteCalculate();

	NextMapVoted = "";
	MapVoteCountDown = 0;

	MaxVotes = 0;
	MaxCount = 0;
	for (i=0; i<MapCount; i++)
	{
		if (MaxVotes == MapVotes[i])
			MaxCount++;
		if (MaxVotes < MapVotes[i])
		{
			MaxVotes = MapVotes[i];
			MaxCount = 1;
			MapVoted = MapList[i];
		}
	}

	if (MaxVotes > PlayerCount * MapVotePercentageInGame) {
		ProcessMapVote(MapVoted);
	} else {
		if (MaxVotes > PlayerCount * MapVotePercentage && TO_DeathMatchPlus(Level.Game).EndTime > 0)
			ProcessMapVote(MapVoted);
	}

	if (TimeOut) {
		if (MaxVotes == 0) {
			if (NoVoteAction == 0)
                ProcessMapVote(MapList[Rand(MapCount)]);
		    else
                ProcessMapVote(GetNextMapInCycle());
		} else {
			if (MaxCount == 1) {
				ProcessMapVote(MapVoted);
			} else {
				j = Rand(MaxCount);
				for (i=0; i<MapCount; i++)
				{
					if (MapVotes[i] == MaxVotes)
					{
						if (j == 0)
						{
							ProcessMapVote(MapList[i]);
							break;
						} else {
							j--;
						}
					}
				}
			}
		}
	}
}

function	ProcessMapVote(string Map)
{
	local	TOSTMapMemory	MapMem;
	local	int	i;

	if (Map == "" || NextMapVoted != "")
		return;

	NextMapVoted = Map;
	NotifyAll(1, Map$" won the vote");
	MapVoteCountDown = 5;

	MapMem = spawn(class'TOSTMapMemory');
	MapMem.AddMap(Map);
	MapMem.Destroy();

	BroadcastClientMessage(110);
}

function	VoteMap(string Map, PlayerPawn Player)
{
	local	int	i;

	if (!MapVote)
	{
		NotifyPlayer(1, Player, "MapVote feature is deactivated");
		return;
	}

	i = TOST.FindPlayerIndex(Player);
	if (i != -1)
	{
		if (Caps(NormalizeMapName(Map)) != VotedMap[i] && FindMapIndex(Map) != -1)
		{
			VotedMap[i] = Caps(NormalizeMapName(Map));
			NotifyAll(1, Player.PlayerReplicationInfo.PlayerName@"voted for"@Map);
		}
	}
}

function	GetMapList(PlayerPawn Player)
{
	local	int		i;

	Params.Param6 = Player;
	for (i=0; i<MapLineCount; i++)
	{
		Params.Param4 = MapLines[i];
		SendClientMessage(103);
	}
}

// * SETTINGS

function		GetSettings(TOSTPiece Sender)
{
	local int	Bits;

	Bits = 0;
	if (NextMap)
		Bits += 1;
	if (MapVote)
		Bits += 2;

	Params.Param4 = String(Bits);
	SendAnswerMessage(Sender, 143);
}

function		SetSettings(TOSTPiece Sender, string Settings)
{
	local	int			i, j;
	local	string		s;

	s = Settings;
	if (s != "")
	{
		j = InStr(s, ";");
		if (j != -1)
		{
			i = int(Left(s, j));
			s = Mid(s, j+1);
		} else {
			i = int(s);
			s = "";
		}

		NextMap = ((i & 1) == 1);
		MapVote = ((i & 2) == 2);
	}
	SaveConfig();
}

function	GetValue(PlayerPawn	Player, TOSTPiece Sender, int Index)
{
	Params.Param6 = Player;
	Params.Param1 = Index;
	switch (Index)
	{
		case 117 :	Params.Param5 = NextMap;
					break;
		case 118 :	Params.Param5 = MapVote;
					break;
		case 119 :	Params.Param2 = int((MapVotePercentageInGame*100) + 0.01); // fix for rounding error at 0.53
					break;
		case 120 :	Params.Param2 = int((MapVotePercentage*100) + 0.01); // fix for rounding error at 0.53
					break;
		case 121 :	Params.Param2 = MapVoteMode;
					break;
		case 122 :	Params.Param2 = VoteTime;
					break;
		case 123 :	Params.Param2 = MapNoReplay;
					break;
	}
	if (Index >= 117 && Index <= 123)
	{
		if (Player != None)
			SendClientMessage(100);
		else
			SendAnswerMessage(Sender, 120);
	}
}

function	SetValue(PlayerPawn Player, int Index, int i, float f, string s, bool b)
{
	switch (Index)
	{
		case 117 :	NextMap = b;
					break;
		case 118 :	MapVote = b;
					break;
		case 119 :	MapVotePercentageInGame = float(i)/100.0;
					break;
		case 120 :	MapVotePercentage = float(i)/100.0;
					break;
		case 121 :	MapVoteMode = i;
					break;
		case 122 :	VoteTime = i;
					break;
		case 123 :	MapNoReplay = i;
					break;
	}
	SaveConfig();
}

// ** EVENT HANDLING

function 		EventPlayerDisconnect(Pawn Player)
{
	local	int		i;

	i = TOST.FindPlayerIndex(PlayerPawn(Player));
	if (i != -1)
		VotedMap[i] = "";

	super.EventPlayerDisconnect(Player);
}

function		EventInit()
{
	NextMapCycle = GetNextMapInCycle();
	LastNextMapMessage = Level.TimeSeconds;
	LoadMapList();
	super.EventInit();
}

function bool	EventBeforeEndGame()
{
	local	bool		NormalEnd;
	local	s_SWATGame	SG;

	SG = s_SWATGame(Level.Game);
	NormalEnd = ((SG.RoundLimit > 0) && (SG.RoundNumber == SG.RoundLimit)) || ((SG.TimeLimit > 0) && (SG.RemainingTime <= 0));

	TO_DeathMatchPlus(Level.Game).bDontRestart = (NextMap || MapVote) && NormalEnd;

	return super.EventBeforeEndGame();
}

function int	EventTimer()
{
	local	bool		NormalEnd;
	local	s_SWATGame	SG;

	SG = s_SWATGame(Level.Game);
	NormalEnd = ((SG.RoundLimit > 0) && (SG.RoundNumber == SG.RoundLimit)) || ((SG.TimeLimit > 0) && (SG.RemainingTime <= 0));

	// NextMap Message Handling
	if (NextMap && NextMapMessageInterval > 0 && Level.TimeSeconds - LastNextMapMessage > NextMapMessageInterval)
	{
		BroadcastNextMap();
		LastNextMapMessage = Level.TimeSeconds;
	}

	// SkipMap
	if (MapSkip)
	{
		SkipCountDown--;
		if (SkipCountDown < 1)
			SwitchMap();
	}

	// NextMap / MapVote Handling
	if(NextMap && (!MapVote || NextMapChosen != ""))
	{
		if (TO_DeathMatchPlus(Level.Game).EndTime > 0 && Level.TimeSeconds > TO_DeathMatchPlus(Level.Game).EndTime + TO_DeathMatchPlus(Level.Game).TO_RestartWait )
			SwitchMap();
	} else {
		if (MapVote)
		{
			if (NextMapVoted != "")
			{
				if (MapVoteCountDown > 0)
				{
					MapVoteCountDown--;
				} else
					SwitchMap();
			} else {
				if (NormalEnd)
				{
					if (TO_DeathMatchPlus(Level.Game).EndTime > 0 && !AdjustedEndTime)
					{
						AdjustedEndTime = true;
	  				    TO_DeathMatchPlus(Level.Game).EndTime = TO_DeathMatchPlus(Level.Game).EndTime + VoteTime + 10 + TO_DeathMatchPlus(Level.Game).TO_RestartWait;
					}
					if (TO_DeathMatchPlus(Level.Game).EndTime > 0 && !AutoMapVote && Level.TimeSeconds > TO_DeathMatchPlus(Level.Game).EndTime - VoteTime - 10)
					{
						AutoMapVote = true;
						Params.Param4 = "TOST VoteTab";
						Params.Param5 = true;
						BroadcastClientMessage(112);
					}
					if (TO_DeathMatchPlus(Level.Game).EndTime > 0 && Level.TimeSeconds > TO_DeathMatchPlus(Level.Game).EndTime - 13)
					{
						MapVoteSelectBest(true);	// MapVote TimeOut
					} else {
						MapVoteSelectBest(false);
					}
				} else {
					MapVoteSelectBest(false);
				}
			}
		}
	}
	return 0;
}

// ** MESSAGE HANDLING

function bool	EventCheckClearance(TOSTPiece Sender, PlayerPawn Player, int MsgType, out int Allowed)
{
	// allow GetNextMap and VoteMap for everyone
	if (MsgType == BaseMessage+0 || MsgType == BaseMessage+2)
	{
		Allowed = 1;
		return true;
	}

	// allow reading values
	if (MsgType == 120 && (Sender.Params.Param1 >= 117 && Sender.Params.Param1 <= 123))
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
		// GetNextMap
		case BaseMessage+0 :	GetNextMap(Sender.Params.Param6);
								break;
		// SetNextMap
		case BaseMessage+1 :	SetNextMap(Sender.Params.Param4, Sender.Params.Param6);
								break;
		// VoteMap
		case BaseMessage+2 :	VoteMap(Sender.Params.Param4, Sender.Params.Param6);
								break;
		// SkipMap
		case BaseMessage+3 :	SkipMap();
								break;
		// GetMapList
		case BaseMessage+4 :	GetMapList(Sender.Params.Param6);
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
		// GetMessageName
		case 203			:	TranslateMessage(Sender);
								break;
	}
	super.EventMessage(Sender, MsgIndex);
}

function		EventAnswerMessage(TOSTPiece Sender, int MsgIndex)
{
	switch (MsgIndex)
	{
		// SetSettings - report back error messages
		case 144 			:	SetSettings(Sender, Sender.Params.Param4);
								break;
	}
}

function	TranslateMessage(TOSTPiece Sender)
{
	switch (Sender.Params.Param1)
	{
		case BaseMessage+0  : Sender.Params.Param4 = "GetNextMap"; break;
		case BaseMessage+1  : Sender.Params.Param4 = "SetNextMap"; break;
		case BaseMessage+2  : Sender.Params.Param4 = "VoteMap"; break;
		case BaseMessage+3  : Sender.Params.Param4 = "SkipMap"; break;

		case 120			:
		case 121			: TranslateValueMessage(Sender); break;
		default : break;
	}
}

function	TranslateValueMessage(TOSTPiece Sender)
{
	switch (Sender.Params.Param2)
	{
		case 117 :	Sender.Params.Param4 = "NextMap"; break;
		case 118 :	Sender.Params.Param4 = "Map Vote"; break;
		case 119 :	Sender.Params.Param4 = "MapVotePercentage (InGame)"; break;
		case 120 :	Sender.Params.Param4 = "MapVotePercentage (EndGame)"; break;
		case 121 :	Sender.Params.Param4 = "MapVote Mode"; break;
		case 122 :	Sender.Params.Param4 = "MapVote TimeLimit"; break;
		case 123 :	Sender.Params.Param4 = "MapVote NoReplayMap"; break;
	}
}

defaultproperties
{
	bHidden=True

	PieceName="TOST Map Handling"
	PieceVersion="1.1.0.0"
	ServerOnly=true

	CountDown=0

	NextMap=true
	MapVote=false
	MapVoteMode=1
	MapNoReplay=5
	MapVotePercentage=0.5
	MapVotePercentageInGame=0.66
	VoteTime=30
	NextMapMessageInterval=1800
	NoVoteAction=1
	BaseMessage=150
}
