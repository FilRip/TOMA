//=============================================================================
// TO_BrowserUpdateServerLink
//=============================================================================
//
// Tactical Ops
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen
//=============================================================================

class TO_BrowserUpdateServerLink expands UTBrowserUpdateServerLink;

var string TO_UpdateServerAddress;


///////////////////////////////////////
// SetupURIs
///////////////////////////////////////

function SetupURIs()
{
	if( class'GameInfo'.default.DemoBuild != 0 )
	{
		MaxURI = 3;
		URIs[3] = "/UpdateServer/utdemomotd"$Level.EngineVersion$".html";
		URIs[2] = "/UpdateServer/utdemomotdfallback.html";
		URIs[1] = "/UpdateServer/utdemomasterserver.txt";
		URIs[0] = "/UpdateServer/utdemoircserver.txt";
	}
	else
	{
		MaxURI = 3;
		// /client/index.htm
		URIs[3] = "/index.htm";
		URIs[2] = "/UpdateServer/utmotdfallback.html";
		URIs[1] = "/UpdateServer/utmasterserver.txt";
		URIs[0] = "/UpdateServer/utircserver.txt";
	}
}


///////////////////////////////////////
// BrowseCurrentURI
///////////////////////////////////////

function BrowseCurrentURI()
{
	if (CurrentURI == 3)
		UpdateServerAddress = TO_UpdateServerAddress;
	else
		UpdateServerAddress = default.UpdateServerAddress;

	Super.BrowseCurrentURI();
}


///////////////////////////////////////
// defaultproperties
///////////////////////////////////////
// http://www.tactical-ops.to/client/index.htm
// http://utbrowser.tactical-ops.to
// www.tactical-ops.to

defaultproperties
{
     TO_UpdateServerAddress="utbrowser.tactical-ops.to"
}
