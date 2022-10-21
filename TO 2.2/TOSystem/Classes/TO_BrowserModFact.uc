//=============================================================================
// TO_BrowserModFact
//=============================================================================
//
// Tactical Ops
// - http://www.tactical-ops.to
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen
//=============================================================================

class TO_BrowserModFact extends UBrowserGSpyFact;

// Config
var() config string		GameMode;
var() config string		GameType;
var() config float		Ping;
var() config bool		bCompatibleServersOnly;
var() config int		MinPlayers;
var() config int		MaxPing;


///////////////////////////////////////
// Query
///////////////////////////////////////

function Query(optional bool bBySuperset, optional bool bInitial)
{
	Super(UBrowserServerListFactory).Query(bBySuperset, bInitial);

	Link = GetPlayerOwner().GetEntryLevel().Spawn(class'TO_BrowserModLink');
	TO_BrowserModLink(Link).GameType = GameType;
	Link.MasterServerAddress = MasterServerAddress;
	Link.MasterServerTCPPort = MasterServerTCPPort;
	Link.Region = Region;
	Link.MasterServerTimeout = MasterServerTimeout;
	Link.GameName = GameName;
	Link.OwnerFactory = Self;
	Link.Start();
}


///////////////////////////////////////
// defaultproperties
///////////////////////////////////////

defaultproperties
{
     GameType="s_SWATGame"
}
