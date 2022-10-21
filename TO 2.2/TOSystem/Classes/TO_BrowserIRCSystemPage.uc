//=============================================================================
// TO_BrowserIRCSystemPage
//=============================================================================
//
// Tactical Ops
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen
//=============================================================================

class TO_BrowserIRCSystemPage expands UBrowserIRCSystemPage;


///////////////////////////////////////
// Created
///////////////////////////////////////

function Created()
{
	Super(UBrowserIRCPageBase).Created();
/*
	if (Splitter != None)
		Splitter.Close();

	if (SetupClient != None)
		SetupClient.Close();
*/
	Splitter = UWindowVSplitter(CreateWindow(class'UWindowVSplitter', 0, 0, WinWidth, WinHeight));
	SetupClient = UBrowserIRCSetupClient(Splitter.CreateWindow(class'TO_BrowserIRCSetupClient', 0, 0, WinWidth, WinHeight, Self));

	TextArea.SetParent(Splitter);
	Splitter.TopClientWindow = SetupClient;
	Splitter.BottomClientWindow = TextArea;
	Splitter.SplitPos = 45;
	Splitter.MaxSplitPos = 45;
	Splitter.MinWinHeight = 0;
	Splitter.bSizable = True;
	Splitter.bBottomGrow = True;

	Setup();
}

defaultproperties
{
}
