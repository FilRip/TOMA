class TOMABrowserServerListWindow extends TO_BrowserServerListWindow;

defaultproperties
{
	ServerListTitle="TOMA Internet Games"
	ServerListClassName="TOSystem.TO_BrowserServerList"
	ListFactories="TOMA21.TOMABrowserModFact,GameType=TOMAMod,bCompatibleServersOnly=True,MasterServerAddress=master0.gamespy.com,MasterServerTCPPort=28900,Region=0,GameName=ut"
	GridClass="TOSystem.TO_BrowserServerGrid"
}
