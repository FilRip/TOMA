class TFBrowserModFact expands UBrowserGSpyFact;

// Nb Change for different game=2

var() config string GameMode;
var() config string GameType;
var() config float Ping;
var() config bool bCompatibleServersOnly;
var() config int MinPlayers;
var() config int MaxPing;

function Query (optional bool bBySuperset, optional bool bInitial)
{
	Super(UBrowserServerListFactory).Query(bBySuperset,bInitial);
// To change
	Link=GetPlayerOwner().GetEntryLevel().Spawn(Class'TFBrowserModLink');
// To change
	TFBrowserModLink(Link).GameType=GameType;
	Link.MasterServerAddress=MasterServerAddress;
	Link.MasterServerTCPPort=MasterServerTCPPort;
	Link.Region=Region;
	Link.MasterServerTimeout=MasterServerTimeout;
	Link.GameName=GameName;
	Link.OwnerFactory=self;
	Link.Start();
}

defaultproperties
{
    GameType="TFMod"
}
