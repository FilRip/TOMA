//=============================================================================
// TO_DMMessage
//=============================================================================
//
// Tactical Ops
// - http://www.planetunreal.com/tacticalops
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen and Benoit "JAH" Delayen
//=============================================================================

class TO_DMMessage extends DeathMatchMessage;


///////////////////////////////////////
// GetString
///////////////////////////////////////
// Suppress sudden death overtime message
static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	if (Switch == 0)
		return "Time Limit! Playing LAST round!";
	else
		return Super.GetString(Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
}


///////////////////////////////////////
// defaultproperties
///////////////////////////////////////

defaultproperties
{
     OvertimeMessage=""
}
