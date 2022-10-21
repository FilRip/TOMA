//=============================================================================
// s_MessageVote
//=============================================================================
//
// Tactical Ops
// - http://www.planetunreal.com/tacticalops
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen and Benoit "JAH" Delayen
//=============================================================================

class  s_MessageVote expands s_MessageObjective;

var	byte	DefaultFontSize;


///////////////////////////////////////
// GetString
///////////////////////////////////////

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	//Default.FontSize = Default.DefaultFontSize;
	//return Default.WinMessage[Switch];
	switch (Switch)
	{
		// Vote
		case 0 :	//Default.FontSize = 2; 
							return RelatedPRI_1.PlayerName$" voted "$RelatedPRI_2.PlayerName$" out";

		case 1 : return RelatedPRI_1.PlayerName$" has been banned during the whole map!";

		// IDLEManager
		case 2 : return "TO IDLEManager - in 10 seconds, you will be killed!";
		case 3 : return "TO IDLEManager - in 10 seconds, you will be kicked from the server!";
		case 4 : return "TO IDLEManager - in 5 seconds, you will be killed!";
		case 5 : return "TO IDLEManager - in 5 seconds, you will be kicked from the server!";

		// Vote again..
		case 6 : return "VOTE SYSTEM - ALL votes are being reset";

		// Only 1 team change per round!
		case 7 : return "Only 1 team change per round allowed!";

		// Hacked console
		case 8 : return "Hacked console detected! Player destroyed!";
		case 9 : return "Hacked console detected!"@RelatedPRI_1.PlayerName@"kicked from the server!";
	}

	return "";
}


///////////////////////////////////////
// GetOffset
///////////////////////////////////////

static function float GetOffset(int Switch, float YL, float ClipY )
{
	return (ClipY / 7);
}


///////////////////////////////////////
// defaultproperties
///////////////////////////////////////

defaultproperties
{
     FontSize=4
     bBeep=True
}
