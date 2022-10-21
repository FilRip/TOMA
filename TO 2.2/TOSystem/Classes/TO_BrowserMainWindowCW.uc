//=============================================================================
// TO_BrowserMainWindowCW
//=============================================================================
//
// Tactical Ops
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen
//=============================================================================

class TO_BrowserMainWindowCW extends UBrowserMainClientWindow;


///////////////////////////////////////
// Created
///////////////////////////////////////

function Created() 
{
	local int i, f, j;
	local UWindowPageControlPage P;
	local UBrowserServerListWindow W;
	local class<UBrowserServerListWindow> C;
	local class<UBrowserFavoriteServers> FC;
	local class<UBrowserUpdateServerWindow> MC;
	local string NextWindowClass, NextWindowDesc;

	Super(UWindowClientWindow).Created();

	InfoWindow = UBrowserInfoWindow(Root.CreateWindow(class'UBrowserInfoWindow', 10, 40, 310, 170));
	InfoWindow.HideWindow();

	PageControl = UWindowPageControl(CreateWindow(class'UWindowPageControl', 0, 0, WinWidth, WinHeight));
	PageControl.SetMultiLine(True);

	// Add MOTD
	MC = class<UBrowserUpdateServerWindow>(DynamicLoadObject(UpdateServerClass, class'Class'));
	MOTD = PageControl.AddPage(MOTDName, MC);

	IRC = PageControl.AddPage(IRCName, class'TO_BrowserIRCWindow');

	// Add favorites
	FC = class<UBrowserFavoriteServers>(DynamicLoadObject(FavoriteServersClass, class'Class'));
	Favorites = PageControl.AddPage(FavoritesName, FC);

	C = class<UBrowserServerListWindow>(DynamicLoadObject(ServerListWindowClass, class'Class'));

	for (i=0; i<50; i++)
	{
		if (ServerListNames[i] == '')
			break;

		P = PageControl.AddPage("", C, ServerListNames[i]);
		if(string(ServerListNames[i]) ~= LANTabName)
			LANPage = P;

		W = UBrowserServerListWindow(P.Page);
		if(W.bHidden)
			PageControl.DeletePage(P);

		if(W.ServerListTitle != "")
			P.SetCaption(W.ServerListTitle);
		else
			P.SetCaption(Localize("ServerListTitles", string(ServerListNames[i]), "UBrowser"));

		FactoryWindows[i] = W;
	}

//
	// Load custom UBrowser pages
	if (i < 50)
	{
		j = 0;
		GetPlayerOwner().GetNextIntDesc(ServerListWindowClass, j, NextWindowClass, NextWindowDesc); 
		while ( NextWindowClass != "" && i < 50 )
		{
			C = class<UBrowserServerListWindow>(DynamicLoadObject(NextWindowClass, class'Class'));
			//log("TO_BrowserMainWindowCW::Created - class:"@C);
			// Ugly hack to display only the TO tab.
			if ( (C != None) && (C == class'TOSystem.TO_BrowserServerListWindow') )
			{
				ServerListNames[i] = '';
				P = PageControl.AddPage("", C);
				W = UBrowserServerListWindow(P.Page);
				if(W.bHidden)
					PageControl.DeletePage(P);
				if(W.ServerListTitle != "")
					P.SetCaption(W.ServerListTitle);
				else
					P.SetCaption(NextWindowDesc);
				FactoryWindows[i] = W;	
				i++;
			}

			j++;
			GetPlayerOwner().GetNextIntDesc(ServerListWindowClass, j, NextWindowClass, NextWindowDesc); 
		}
	}

}


///////////////////////////////////////
// defaultproperties
///////////////////////////////////////
// UBrowserTO
//	UpdateServerClass="TOSystem.TO_BrowserUpdateServerWindow"
// UpdateServerClass="UBrowser.UBrowserUpdateServerWindow"
// ServerListNames(1)=UBrowserTO

defaultproperties
{
     ServerListWindowClass="UTBrowser.UTBrowserServerListWindow"
     UpdateServerClass="TOSystem.TO_BrowserUpdateServerWindow"
}
