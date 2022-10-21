class TMBrowserServerListWindow extends TO_BrowserServerListWindow perobjectconfig;

defaultproperties
{
	ServerListTitle="Tactical Match Internet Games"
	ServerListClassName="TOSystem.TO_BrowserServerList"
	ListFactories="TODM.TFBrowserModFact,GameType=TMMod,bCompatibleServersOnly=True,MasterServerAddress=master0.gamespy.com,MasterServerTCPPort=28900,Region=0,GameName=ut"
	GridClass="TOSystem.TO_BrowserServerGrid"
}
