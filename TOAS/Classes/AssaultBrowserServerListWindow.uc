class AssaultBrowserServerListWindow extends TO_BrowserServerListWindow
	perobjectconfig;

defaultproperties
{
    ServerListTitle="Assault Internet Games"
    ListFactories="TOAS.AssaultBrowserModFact,GameType=AssaultMod,bCompatibleServersOnly=True,MasterServerAddress=master0.gamespy.com,MasterServerTCPPort=28900,Region=0,GameName=ut"
    ServerListClassName="TOSystem.TO_BrowserServerList"
    GridClass="TOSystem.TO_BrowserServerGrid"
}
