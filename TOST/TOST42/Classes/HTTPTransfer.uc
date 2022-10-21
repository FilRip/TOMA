//----------------------------------------------------------------------------
// Project   : TOSTExtraTools
// File      : HTTPUpload.uc
// Version   : 105
// Author    : Dildog
//$Last Edit : 22-10-2003 18:01:42$
//----------------------------------------------------------------------------
//	Version	Changes
//	102		+ First public beta
//	103		+ return result
//	104		+ return on error
//	105		+ Added HTTP_GET
//----------------------------------------------------------------------------

class HTTPTransfer extends TCPLink;

const VERSION = "105";

enum eMethod
{
	HTTP_NONE,
	HTTP_GET,
	HTTP_POST
};

var			eMethod	Method;
var 		string	HostName;
var 		string	Request;
var 		int 	Port;

var			bool	bTransferFailed;
var			string	ResponseName[255];
var			string	ResponseValue[255];

var private	string	Data;
var private	string	Buffer;

var TOSTPiece		Master;

//----------------------------------------------------------------------------
// Some functions called by owner to set/get data
//----------------------------------------------------------------------------
function AttatchFile(string Filename, string NewData)
{
	Master.dLog("HTTPUpload: Attatching '"$Filename$"'");
	Data = Data $ "--AaB03x" $ Chr(13) $ Chr(10);
	Data = Data $ "Content-disposition: form-data; name=\""$Filename$"\"; filename=\""$Filename$".dat\"" $ Chr(13) $ Chr(10);
	Data = Data $ "Content-Type: text/plain" $ Chr(13) $ Chr(10);
	Data = Data $ Chr(13) $ Chr(10);
	Data = Data $ NewData $ Chr(13) $ Chr(10);
}

function Connect() {
	if (Method != HTTP_NONE && HostName != "" && Request != "" && Port != 0)
	{
		Master.dLog("HTTPUpload: Connecting to"@Hostname@"using"@Method);
		bTransferFailed = false;
		Resolve(Hostname);
	}
	else
	{
		Master.dLog("HTTPUpload: Failed to connect to"@Hostname@"using"@Method);
		bTransferFailed = true;
		Master.EventAnswerMessage(none, -1);
	}
}

function string GetValue(string Key)
{
	local int		i;
	local string	Value;

	for(i=0;i<arraycount(ResponseName);i++)
	{
		//if (ResponseName[i] ~= "")
		//	return "";
		if (ResponseName[i] ~= Key)
			return ResponseValue[i];
	}
	return "";

}

//----------------------------------------------------------------------------
// TcpLink Events/Functions
//----------------------------------------------------------------------------
event ResolveFailed()
{
	Master.dLog("HTTPUpload: Error, resolve failed");
	bTransferFailed = true;
	Master.EventAnswerMessage(none, -1);
}

event Resolved(IpAddr Addr)
{
	Master.dLog("HTTPUpload: Resolved");
	Addr.Port = Port;
	BindPort();
	ReceiveMode = RMODE_Event;
	LinkMode = MODE_Line;
	Open(Addr);
}

event Opened()
{
	local int		i;

	Buffer = "";

	if (Method == HTTP_GET)
	{
		Master.dLog("HTTPUpload: Opened, Send 'GET "$Request$" HTTP/1.0'");
		SendText("GET "$Request$" HTTP/1.0");
		SendText("Host: "$Hostname);
		SendText("User-agent: HTTPUPLOAD "$VERSION$" @ UT"$Level.EngineVersion);
		SendText("Connection: close");
		SendText("");
	}
	else if (Method == HTTP_POST)
	{
		Master.dLog("HTTPUpload: Opened, Send 'POST "$Request$" HTTP/1.0'");
		SendText("POST "$Request$" HTTP/1.0");
		SendText("Host: "$Hostname);
		SendText("User-agent: HTTPUPLOAD 105 @ UT"$Level.EngineVersion);
		SendText("Content-type: multipart/form-data, boundary=AaB03x");
		SendText("Content-length: "$Len(Data));
		SendText("Connection: close");
		SendText("");
		while ( Data != "" )
		{
			i = InStr(Data, Chr(13) $ Chr(10));
			SendText( Mid(Data,0,i) );
			Data = Mid(Data,i+2);
		}
		SendText("--AaB03x--");
	}
	Data = "";
}

event ReceivedLine( string Line )
{
	Buffer = Buffer$Line;
}

function string	GetLine(out string Rest)
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
	local	int		i,j;

	Line = GetLine(Buffer);
	if (InStr(Line, "200") == -1)
	{
		Master.dLog("HTTPUpload: Closed, Warning: "$Line);
		bTransferFailed = true;
		Master.EventAnswerMessage(none, -1);
		return;
	}
	// get past header
	while (Line != "")
	{
		Line = GetLine(Buffer);
	}
	// parse versions
	for(i=0;i<arraycount(ResponseName);i++)
	{
		Line = GetLine(Buffer);
		j = InStr(Line, "=");
		if (j == -1)
		{
			ResponseValue[i] = Line;
		}
		else {
			ResponseName[i] = Left(Line, j);
			ResponseValue[i] = Mid(Line, j+1, Len(Line)-1);
		}
	}
	Master.dLog("HTTPUpload: Closed");
	Master.EventAnswerMessage(none, -1);
}

//----------------------------------------------------------------------------
// defaultproperties
//----------------------------------------------------------------------------
defaultproperties
{
	Method=HTTP_NONE
	port=80
}
