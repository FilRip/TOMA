class TMDeathMatchMessage extends DeathMatchMessage;

static function string GetString(optional int Switch,optional PlayerReplicationInfo RelatedPRI_1,optional PlayerReplicationInfo RelatedPRI_2,optional Object OptionalObject)
{
	switch (Switch)
	{
		case 0:
			return Default.OverTimeMessage;
			break;
		case 1:
			if (RelatedPRI_1==None)
				return "";

			return RelatedPRI_1.PlayerName$class'GameInfo'.Default.EnteredMessage;
			break;
		case 2:
			if (RelatedPRI_1==None)
				return "";

			return RelatedPRI_1.OldName@Default.GlobalNameChange@RelatedPRI_1.PlayerName;
			break;
		case 3:
			if (RelatedPRI_1==None)
				return "";
			if (OptionalObject==None)
				return "";

			return RelatedPRI_1.PlayerName@Default.NewTeamMessage;//@TeamInfo(OptionalObject).TeamName$Default.NewTeamMessageTrailer;
			break;
		case 4:
			if (RelatedPRI_1==None)
				return "";

			return RelatedPRI_1.PlayerName$class'GameInfo'.Default.LeftMessage;
			break;
	}
	return "";
}

defaultproperties
{
     NewTeamMessage="entered the arena"
}

