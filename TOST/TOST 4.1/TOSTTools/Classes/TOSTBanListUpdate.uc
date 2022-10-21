//----------------------------------------------------------------------------
// Project : TOST
// File    : TOSTBanListUpdate.uc
// Version : 0.5
// Author  : BugBunny
//----------------------------------------------------------------------------
// Version	Changes
// 0.5		+ First Release
//----------------------------------------------------------------------------

class TOSTBanListUpdate extends TCPLink;

var string Hostname;
var int Port;
var string Request;

var private string buffer;

var TOSTBanList	Master;

function CheckForUpdate()
{
	Resolve(Hostname);
}

event ResolveFailed()
{
	log("Error: resolving "$Hostname$" failed", 'TOPUpdate');
}

event Resolved( IpAddr Addr )
{
	Addr.Port = Port;
	BindPort();
	ReceiveMode = RMODE_Event;
	LinkMode = MODE_Line;
	Open(Addr);
}

event Opened()
{
	buffer = "";
	SendText("GET "$Request$" HTTP/1.0");
	SendText("Host: "$Hostname);
	SendText("Connection: close");
	SendText("User-agent: TOSTTOOLS");
	SendText("");
}

event ReceivedLine(string Line)
{
	Buffer = Buffer$Line;
}

function	string	GetLine(out string Rest)
{
	local	string	Line;
	local	int		i;

	i = InStr(Rest, Chr(10));
	if (i != -1)
	{
		Line = Left(Rest, i);
		Rest = Mid(Rest, i+1);
	} else {
		Line = Rest;
		Rest = "";
	}
	i = InStr(Line, Chr(13));
	while (i != -1)
	{
		Line = Left(Line, i)$Mid(Line, i+1);
		i = InStr(Line, Chr(13));
	}
	return Line;
}

event Closed()
{
	local	string	Line;

	Line = GetLine(Buffer);
	if (InStr(Line, "200") == -1)
	{
		log("Warning : Result : "$Line, 'TOSTBanListUpdate');
		Destroy();
		return;
	}
	// get past header
	while (Line != "")
	{
		Line = GetLine(Buffer);
	}
	// parse versions
	Line = GetLine(Buffer);
	while (Line != "")
	{
		Master.AddIP(Line, 1, 0, true);
		Line = GetLine(Buffer);
	}
	Destroy();
}

defaultproperties
{
	bHidden=true

	Hostname="banlist.djemma-el-fna.de"
	Port=80
	Request="http://banlist.djemma-el-fna.de/index.php"
}
