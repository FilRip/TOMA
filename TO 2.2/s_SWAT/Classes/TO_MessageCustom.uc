//=============================================================================
// TO_MessageCustom
//=============================================================================
//
// Tactical Ops
// - http://www.planetunreal.com/tacticalops
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen and Benoit "JAH" Delayen
//=============================================================================
 
class TO_MessageCustom expands CriticalEventPlus;


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
	if ( OptionalObject == None )
		return "";

	if ( OptionalObject.IsA('TO_RoundWinning') )
		return TO_RoundWinning(OptionalObject).WinningMessage;

	if ( OptionalObject.IsA('TO_MessageDisplay') )
		return TO_MessageDisplay(OptionalObject).Message;

	if ( OptionalObject.IsA('TO_ScenarioInfo') )
		return TO_ScenarioInfo(OptionalObject).DefaultLooseMessage;

	return "";
}


///////////////////////////////////////
// GetOffset
///////////////////////////////////////

static function float GetOffset(int Switch, float YL, float ClipY )
{
	return (ClipY / 3);
}


///////////////////////////////////////
// defaultproperties
///////////////////////////////////////

defaultproperties
{
     FontSize=2
     bBeep=False
     DrawColor=(R=255,G=255)
}
