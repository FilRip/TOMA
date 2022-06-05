class VIPTO_Message extends s_MessageRoundWinner;

var localized string vipkilledbyterro;
var localized string vipkilledbybodyguard;
var localized string vipkilledhimself;
var localized string vipfailedtoescape;
var localized string viphasescaped;
var localized string LeVIPStr;

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
    switch (switch)
    {
        case 18:return default.LeVIPStr$" "$RelatedPRI_1.PlayerName$" "$default.vipkilledbyterro;
                break;
        case 19:return default.LeVIPStr$" "$RelatedPRI_1.PlayerName$" "$default.vipkilledbybodyguard;
                break;
        case 20:return default.LeVIPStr$" "$RelatedPRI_1.PlayerName$" "$default.vipkilledhimself;
                break;
        case 21:return default.LeVIPStr$" "$RelatedPRI_1.PlayerName$" "$default.vipfailedtoescape;
                break;
        case 22:return default.LeVIPStr$" "$RelatedPRI_1.PlayerName$" "$default.viphasescaped;
                break;
    }
}

defaultproperties
{
	VIPKilledByTerro="was killed by a Terrorist"
	VIPKilledByBodyguard="was killed by a Bodyguard"
	VIPKilledHimself="was killed himself"
	VIPHasEscaped="has escaped !"
	VIPFailedToEscape="failed to escape !"
	LeVIPStr="The VIP"
}

