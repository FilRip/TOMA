class TOMAMessage extends s_MessageRoundWinner;

var localized string YouWin;
var localized string RageModeText;
var localized string BeatRecord;
var localized string NoMoreNade;

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	switch (Switch)
	{
	   case 18:return default.YouWin;
	   case 19:return RelatedPRI_1.PlayerName$" "$default.RageModeText;
	   case 20:return default.BeatRecord;
	   case 21:return default.NoMoreNade;
    }
	return Default.WinMessage[Switch];
}

defaultproperties
{
    YouWin="Special Forces win against monsters"
    RageModeText="is in RageMode!"
    BeatRecord="You have beaten your personal record"
    NoMoreNade="You can't throw more special nades, limit exceed"
}

