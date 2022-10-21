class KTF_Message extends s_MessageRoundWinner;

var localized string SFWin,TerroWin;

static function string GetString(optional int Switch,optional PlayerReplicationInfo RelatedPRI_1,optional PlayerReplicationInfo RelatedPRI_2,optional Object OptionalObject)
{
    switch (Switch)
    {
        case 18:
            return default.TerroWin;
            break;
        case 19:
            return default.SFWin;
            break;
    }
}

defaultproperties
{
    TerroWin="Terrorists have the best time"
    SFWin="Special Forces have the best time"
}

