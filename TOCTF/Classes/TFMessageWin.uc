class TFMessageWin extends s_MessageRoundWinner;

var localized string AllFlagsCaptured;

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
    if (Switch==18) return default.AllFlagsCaptured;
}

defaultproperties
{
    AllFlagsCaptured="Limit of captured flags per round reach"
}

