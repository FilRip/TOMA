//=============================================================================
// TO_BrowserIRCWindow
//=============================================================================
//
// Tactical Ops
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen
//=============================================================================

class TO_BrowserIRCWindow expands UWindowPageWindow;

var UWindowPageControl			PageControl;
var TO_BrowserIRCSystemPage	SystemPage;

var localized string SystemName;


///////////////////////////////////////
// Created
///////////////////////////////////////

function Created()
{
	Super.Created();

	PageControl = UWindowPageControl(CreateWindow(class'UWindowPageControl', 0, 0, WinWidth, WinHeight));
	PageControl.SetMultiLine(True);
	PageControl.bSelectNearestTabOnRemove = True;
	SystemPage = TO_BrowserIRCSystemPage(PageControl.AddPage(SystemName, class'TO_BrowserIRCSystemPage').Page);
	SystemPage.PageParent = PageControl;
}


///////////////////////////////////////
// defaultproperties
///////////////////////////////////////

function Resized()
{
	PageControl.SetSize(WinWidth, WinHeight);
}


///////////////////////////////////////
// BeforePaint
///////////////////////////////////////

function BeforePaint(Canvas C, float X, float Y)
{
	local UBrowserMainWindow W;
	Super.BeforePaint(C, X, Y);

	W = UBrowserMainWindow(GetParent(class'UBrowserMainWindow'));
	W.DefaultStatusBarText("");
	SystemPage.IRCVisible();
}


///////////////////////////////////////
// WindowHidden
///////////////////////////////////////

function WindowHidden()
{
	Super.WindowHidden();
	SystemPage.IRCClosed();
}


///////////////////////////////////////
// Close
///////////////////////////////////////

function Close(optional bool bByParent)
{
	Super.Close(bByParent);
	if(bByParent)
		SystemPage.IRCClosed();
}


///////////////////////////////////////
// defaultproperties
///////////////////////////////////////

defaultproperties
{
     SystemName="System"
}
