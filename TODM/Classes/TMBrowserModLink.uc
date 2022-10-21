class TMBrowserModLink expands UBrowserGSpyLink transient;

var string GameType;

state FoundSecretState
{
Begin:
	Enable('Tick');
	SendBufferedData("\\list\\gamename\\" $ GameName $ "\\gametype\\" $ GameType $ "\\final\\");
	WaitFor("ip\\",30.00,3);
}

