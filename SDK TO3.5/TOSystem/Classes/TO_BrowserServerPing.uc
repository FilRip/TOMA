class TO_BrowserServerPing extends UBrowser.UBrowserServerPing;

var bool bFailed;

static function string Trim (coerce string S)
{
}

static function string RTrim (coerce string S)
{
}

static function string LTrim (coerce string S)
{
}

function bool ValidPlayerServer ()
{
}

function bool ValidServerName ()
{
}

function bool ValidMapName ()
{
}

function bool ValidIP ()
{
}

state GetInfo
{
	event Timer ()
	{
	}

	event Tick (float DeltaTime)
	{
	}

	function ReceivedText (IpAddr Addr, string Text)
	{
	}

}

state GetStatus
{
	event Timer ()
	{
	}

	event ReceivedText (IpAddr Addr, string Text)
	{
	}

}

function string LocalizeTeam (string TeamNum)
{
}

function string LocalizeBoolValue (string Value)
{
}


defaultproperties
{
}

