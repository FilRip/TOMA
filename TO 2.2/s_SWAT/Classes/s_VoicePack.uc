//=============================================================================
// s_VoicePack
//=============================================================================
//
// Tactical Ops
// - http://www.planetunreal.com/tacticalops
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen and Benoit "JAH" Delayen
//=============================================================================
 
class s_VoicePack extends ChallengeVoicePack;
 
static function string GetOrderString(int i, string GameType )
{
	if ( i > 9 )
		return ""; //high index order strings are alternates to the base orders 
	if (i == 2)
	{
		if (GameType == "Capture the Flag" || GameType == "Tactical Ops" )
		{
			if ( Default.OrderAbbrev[10] != "" )
				return Default.OrderAbbrev[10];
			else
				return Default.OrderString[10];
		} else if (GameType == "Domination") {
			if ( Default.OrderAbbrev[11] != "" )
				return Default.OrderAbbrev[11];
			else
				return Default.OrderString[11];
		}
	}

	if ( Default.OrderAbbrev[i] != "" )
		return Default.OrderAbbrev[i];

	return Default.OrderString[i];
}

defaultproperties
{
}
