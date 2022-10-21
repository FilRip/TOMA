//=============================================================================
// TO_BrowserMainWindowSC
//=============================================================================
//
// Tactical Ops
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen
//=============================================================================

class TO_BrowserMainWindowSC expands UBrowserMainWindow;


///////////////////////////////////////
// BeginPlay
///////////////////////////////////////

function BeginPlay()
{
	Super.BeginPlay();

	ClientClass = class'TO_BrowserMainWindowCW';
}


///////////////////////////////////////
// defaultproperties
///////////////////////////////////////

defaultproperties
{
     WindowTitleString="Tactical Ops Server Browser"
}
