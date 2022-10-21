class TFCTFMessageActualCarrier extends LocalMessagePlus;

var localized string YouHaveFlagString;
var localized string EnemyHasFlagString;
var localized string MemberHasFlagString;
var color TerroColor, SFColor;

static function color GetColor(optional int Switch,optional PlayerReplicationInfo RelatedPRI_1,optional PlayerReplicationInfo RelatedPRI_2)
{
	if ((Switch==0) || (Switch==2))
		return Default.SFColor;
	else
		return Default.TerroColor;
}

static function float GetOffset(int Switch, float YL, float ClipY )
{
	if ((Switch==0) || (Switch==2))
		return ClipY-YL*2-0.0833*ClipY;
	else
		return ClipY-YL*3-0.0833*ClipY;
}

static function string GetString(optional int Switch,optional PlayerReplicationInfo RelatedPRI_1,optional PlayerReplicationInfo RelatedPRI_2,optional Object OptionalObject)
{
	switch (Switch)
	{
		case 0:
			return Default.YouHaveFlagString;
			break;
		case 1:
			return Default.EnemyHasFlagString;
			break;
		case 2:
		    return default.MemberHasFlagString;
	}
	return "";
}

defaultproperties
{
     YouHaveFlagString="You have the flag, return to base!"
     EnemyHasFlagString="The enemy has your flag, recover it!"
     MemberHasFlagString="Opposite flag already taken!"
     TerroColor=(R=255,G=0,B=0)
     SFColor=(R=0,G=0,B=255)
     FontSize=1
     bIsSpecial=True
     bIsConsoleMessage=False
     bFadeMessage=True
     Lifetime=1
     DrawColor=(R=0,G=128,B=0)
     YPos=196
     bCenter=True
}
