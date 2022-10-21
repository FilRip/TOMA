class TFCTFMessage extends CriticalEventPlus;

var localized string ReturnBlue, ReturnRed;
var localized string ReturnedBlue, ReturnedRed;
var localized string CaptureBlue, CaptureRed;
var localized string DroppedBlue, DroppedRed;
var localized string HasBlue,HasRed;

static function string GetString(optional int Switch,optional PlayerReplicationInfo RelatedPRI_1,optional PlayerReplicationInfo RelatedPRI_2,optional Object OptionalObject)
{
	switch (Switch)
	{
		// Captured the flag.
		case 0:
			if (RelatedPRI_1 == None)
				return "";

			if ( RelatedPRI_1.Team == 0 )
				return RelatedPRI_1.PlayerName@Default.CaptureRed;
			else
				return RelatedPRI_1.PlayerName@Default.CaptureBlue;
			break;

		// Returned the flag.
		case 1:
			if ( CTFFlag(OptionalObject) == None )
				return "";
			if (RelatedPRI_1 == None)
			{
				if ( CTFFlag(OptionalObject).Team == 0 )
					return Default.ReturnedRed;
				else
					return Default.ReturnedBlue;
			}
			if ( CTFFlag(OptionalObject).Team == 0 )
				return RelatedPRI_1.PlayerName@Default.ReturnRed;
			else
				return RelatedPRI_1.PlayerName@Default.ReturnBlue;
			break;

		// Dropped the flag.
		case 2:
			if (RelatedPRI_1 == None)
				return "";
			if ( TeamInfo(OptionalObject) == None )
				return "";

			if ( TeamInfo(OptionalObject).TeamIndex == 0 )
				return RelatedPRI_1.PlayerName@Default.DroppedRed;
			else
				return RelatedPRI_1.PlayerName@Default.DroppedBlue;
			break;

		// Was returned.
		case 3:
			if ( TeamInfo(OptionalObject) == None )
				return "";

			if ( TeamInfo(OptionalObject).TeamIndex == 0 )
				return Default.ReturnedRed;
			else
				return Default.ReturnedBlue;
			break;

		// Has the flag.
		case 4:
			if (RelatedPRI_1 == None)
				return "";
			if ( TeamInfo(OptionalObject) == None )
				return "";

			if ( TeamInfo(OptionalObject).TeamIndex == 0 )
				return RelatedPRI_1.PlayerName@Default.HasRed;
			else
				return RelatedPRI_1.PlayerName@Default.HasBlue;
			break;

		// Auto send home.
		case 5:
			if ( TeamInfo(OptionalObject) == None )
				return "";

			if ( TeamInfo(OptionalObject).TeamIndex == 0 )
				return Default.ReturnedRed;
			else
				return Default.ReturnedBlue;
			break;

		// Pickup
		case 6:
			if (RelatedPRI_1 == None)
				return "";
			if ( TeamInfo(OptionalObject) == None )
				return "";

			if ( TeamInfo(OptionalObject).TeamIndex == 0 )
				return RelatedPRI_1.PlayerName@Default.HasRed;
			else
				return RelatedPRI_1.PlayerName@Default.HasBlue;
			break;
	}
	return "";
}

defaultproperties
{
     ReturnBlue="returns the Special Forces flag!"
     ReturnRed="returns the Terrorists flag!"
     ReturnedBlue="The Special Forces' flag was returned!"
     ReturnedRed="The Terrorist's flag was returned!"
     CaptureRed="Special Forces flag captured! The Terrorists score!"
     CaptureBlue="Terrorists flag captured! The Special Forces score!"
     DroppedBlue="dropped the Special Forces flag!"
     DroppedRed="dropped the Terrorists flag!"
     HasBlue="has the Special Forces flag!"
     HasRed="has the Terrorists flag!"
     LifeTime=5
}

