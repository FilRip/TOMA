class TMSayMessage extends s_SayMessage;

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
	if (RelatedPRI_1==None)
		return;

	if ((RelatedPRI_2!=None) && (RelatedPRI_1==RelatedPRI_2)) Canvas.DrawColor=default.GreenColor; else Canvas.DrawColor=default.GreyColor;
	Canvas.DrawText(RelatedPRI_1.PlayerName$": ", false);
	Canvas.SetPos(Canvas.CurX,Canvas.CurY-YL);
	if ((RelatedPRI_2!=None) && (RelatedPRI_1==RelatedPRI_2)) Canvas.DrawColor=default.GreenColor; else Canvas.DrawColor=default.GreyColor;
	Canvas.DrawText(MessageString, false );
}

defaultproperties
{
}

