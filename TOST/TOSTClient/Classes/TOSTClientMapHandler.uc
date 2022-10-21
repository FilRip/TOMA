// $Id: TOSTClientMapHandler.uc 487 2004-03-07 14:29:51Z dildog $
//----------------------------------------------------------------------------
// Project : TOST
// File    : TOSTClientMapHandler.uc
// Version : 1.0
// Author  : BugBunny
//----------------------------------------------------------------------------

class TOSTClientMapHandler extends TOSTClientPiece;

var	bool	MapUpdate;
var int		MapCount;
var string	Map[255];
var	int		MapVote[255];
var string	MyMapVote;

// * AddMaps - add maps to map list
simulated function AddMaps(string CompMapList)
{
	local string 	Maps, s;
	local int 		i, j;

	if (CompMapList == "")
		return;

	Maps = CompMapList;

	i = InStr(Maps, ";");
	while (i != -1)
	{
		s = Left(Maps, i);
		j = InStr(s, "%");
		MapVote[MapCount] = int(Left(s, j));
		Map[MapCount++] = Right(s, Len(s) - j - 1);
		Maps = Right(Maps, Len(Maps) - i - 1);
		i = InStr(Maps, ";");
	}
	j = InStr(Maps, "%");
	MapVote[MapCount] = int(Left(Maps, j));
	Map[MapCount++] = Right(Maps, Len(Maps) - j - 1);
}

// * UpdateMap - update vote count on given map
simulated function	UpdateMap(string MyMap, int Count)
{
	local	int	j;

	for (j=0; j < MapCount; j++)
	{
		if (Map[j] == MyMap)
		{
			MapVote[j] = Count;
			break;
		}
	}
}

// * UpdateMaps - update vote coutn for given maps
simulated function UpdateMaps(string CompMapList)
{
	local string 	Maps, s;
	local int 		i, j;

	if (CompMapList == "")
		return;

	MapUpdate = true;

	Maps = CompMapList;
	i = InStr(Maps, ";");
	while (i != -1)
	{
		s = Left(Maps, i);
		j = InStr(s, "%");
		UpdateMap(Right(s, Len(s) - j - 1), int(Left(s, j)));
		Maps = Right(Maps, Len(Maps) - i - 1);
		i = InStr(Maps, ";");
	}
	j = InStr(Maps, "%");
	UpdateMap(Right(Maps, Len(Maps) - j - 1), int(Left(Maps, j)));
}

simulated function string	GetMap(int i)
{
	return (Map[i]);
}

simulated function int		GetMapVoteCount(int i)
{
	return (MapVote[i]);
}


simulated function	EventMessage(int MsgIndex)
{
	switch (MsgIndex) {
		case 103 :	AddMaps(Handler.Params.Param4);
					break;
		case 104 :	UpdateMaps(Handler.Params.Param4);
					break;
	}
	super.EventMessage(MsgIndex);
}

defaultproperties
{
	bHidden=true
}

