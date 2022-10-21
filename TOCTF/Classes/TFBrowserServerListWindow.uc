class TFBrowserServerListWindow extends TO_BrowserServerListWindow perobjectconfig;

defaultproperties
{
	ServerListTitle="Tactical Flags Internet Games"
	ServerListClassName="TOSystem.TO_BrowserServerList"
	ListFactories="TOCTF.TFBrowserModFact,GameType=TFMod,bCompatibleServersOnly=True,MasterServerAddress=master0.gamespy.com,MasterServerTCPPort=28900,Region=0,GameName=ut"
	GridClass="TOSystem.TO_BrowserServerGrid"
}
