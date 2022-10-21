//=============================================================================
// TO_BrowserModLink
//=============================================================================
//
// Tactical Ops
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen
//=============================================================================

class TO_BrowserModLink extends UBrowserGSpyLink;

var string GameType;


///////////////////////////////////////
// FoundSecretState
///////////////////////////////////////

state FoundSecretState 
{
Begin:
	Enable('Tick');
	SendBufferedData("\\list\\\\gamename\\"$GameName$"\\gametype\\"$GameType$"\\final\\");
	WaitFor("ip\\", 30, NextIP);
}


///////////////////////////////////////
// defaultproperties
///////////////////////////////////////

defaultproperties
{
}
