//----------------------------------------------------------------------------
// Project   : TOST
// File      : TOSTMapMemory.uc
// Version   : 1.0
// Author    : BugBunny
//$Last Edit : 30-09-2003 21:20:31$
//----------------------------------------------------------------------------
// Version	Changes
// 0.5		+ first release
// 0.6		+ first beta release
// 1.0		+ first public release
//----------------------------------------------------------------------------

class TOSTMapMemory expands Actor config;

var() config string	LastMaps[250];

function AddMap(string Map)
{
	local	int i;
	for(i=249; i>0; i--)
		LastMaps[i] = LastMaps[i-1];
	LastMaps[0]=Map;
	SaveConfig();
}

function bool IsInList(string Map, int Max)
{
	local	int i;
	for(i=0; i<Max; i++)
	{
		if (Map ~= LastMaps[i])
			return true;
	}
	return	false;
}

defaultproperties
{
	bHidden=true
}

