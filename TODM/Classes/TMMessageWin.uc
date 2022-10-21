class TMMessageWin extends s_MessageRoundWinner;

var localized string LimitFragsReach;

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
    if (Switch==18) return default.LimitFragsReach$RelatedPRI_1.PlayerName;
}

defaultproperties
{
    LimitFragsReach="Limit of frags per round reach by "
}

