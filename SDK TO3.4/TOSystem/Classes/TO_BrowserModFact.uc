class TO_BrowserModFact extends UBrowserGSpyFact;

var() config string GameMode;
var() config string GameType;
var() config float Ping;
var() config bool bCompatibleServersOnly;
var() config int MinPlayers;
var() config int MaxPing;

function Query (optional bool bBySuperset, optional bool bInitial)
{
}
