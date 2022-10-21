//=============================================================================
// s_TeamMessage
//=============================================================================
//
// Tactical Ops
// - http://www.planetunreal.com/tacticalops
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen and Benoit "JAH" Delayen
//=============================================================================

class s_TeamMessage expands StringMessagePlus;
 
var	Color	TeamColor[2], GreyColor;

///////////////////////////////////////
// RenderComplexMessage
///////////////////////////////////////

static function RenderComplexMessage( 
	Canvas Canvas, 
	out float XL,
	out float YL,
	optional string MessageString,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	local string LocationName;

	if (RelatedPRI_1 == None)
		return;

	Canvas.DrawColor = GetTeamColor(RelatedPRI_1);
	Canvas.DrawText( RelatedPRI_1.PlayerName$" ", False );
	Canvas.SetPos( Canvas.CurX, Canvas.CurY - YL );
	if ( RelatedPRI_1.PlayerLocation != None )
		LocationName = RelatedPRI_1.PlayerLocation.LocationName;
	else if ( RelatedPRI_1.PlayerZone != None )
		Locationname = RelatedPRI_1.PlayerZone.ZoneName;

	if (LocationName != "")
	{
		Canvas.DrawColor = Default.CyanColor;
		Canvas.DrawText( " ("$LocationName$"):", False );
	}
	else
		Canvas.DrawText( ": ", False );
	Canvas.SetPos( Canvas.CurX, Canvas.CurY - YL );
	Canvas.DrawColor = Default.LightGreenColor;
	Canvas.DrawText( MessageString, False );
}


///////////////////////////////////////
// AssembleString
///////////////////////////////////////

static function string AssembleString(
	HUD myHUD,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional String MessageString
	)
{
	local string LocationName;

	if (RelatedPRI_1 == None)
		return "";
	if ( RelatedPRI_1.PlayerLocation != None )
		LocationName = RelatedPRI_1.PlayerLocation.LocationName;
	else if ( RelatedPRI_1.PlayerZone != None )
		Locationname = RelatedPRI_1.PlayerZone.ZoneName;
	if ( Locationname == "" )
		return RelatedPRI_1.PlayerName$" "$": "$MessageString;
	else
		return RelatedPRI_1.PlayerName$"  ("$LocationName$"): "$MessageString;
}


///////////////////////////////////////
// GetTeamColor
///////////////////////////////////////

static function Color GetTeamColor(PlayerReplicationInfo PRI)
{
	local	Byte i;

	if (PRI == None)
		return Default.GreenColor;

	i = PRI.team;

	if (PRI.bIsSpectator)
		return Default.GreyColor;

	if (i < 2)
		return Default.TeamColor[i];

	return Default.GreenColor;
}
 

///////////////////////////////////////
// defaultproperties
///////////////////////////////////////

defaultproperties
{
     TeamColor(0)=(R=255)
     TeamColor(1)=(G=128,B=255)
     GreyColor=(R=128,G=128,B=128)
     bComplexString=True
     DrawColor=(R=0,B=0)
}
