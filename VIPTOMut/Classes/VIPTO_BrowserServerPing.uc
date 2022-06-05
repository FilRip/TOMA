Class VIPTO_BrowserServerPing extends TO_BrowserServerPing config(VIPMut);

var() config string NameOfMutator;
var bool mutatornow;
var string textinfo;

state GetInfo
{
	event ReceivedText(IpAddr Addr, string Text)
	{
		local string Temp;
		local float ElapsedTime;
		if (!mutatornow)
		{
			textinfo=text;
			// Make sure this packet really is for us.
			Temp = IpAddrToString(Addr);
			if(Server.IP != Left(Temp, InStr(Temp, ":")))
				return;

			ValidateServer();
			ElapsedTime = (Level.TimeSeconds - RequestSentTime) * Level.TimeDilation;
			Server.Ping = Max(1000*ElapsedTime - (0.5*LastDelta) - 10, 4); // subtract avg client and server frametime from ping.
			if(!Server.bKeepDescription)
				Server.HostName = Server.IP;
			Server.GamePort = 0;
			Server.MapName = "";
			Server.MapTitle = "";
			Server.MapDisplayName = "";
			Server.GameType = "";
			Server.GameMode = "";
			Server.NumPlayers = 0;
			Server.MaxPlayers = 0;
			Server.GameVer = 0;
			Server.MinNetVer = 0;

			Temp = ParseReply(Text, "hostname");
			if(Temp != "" && !Server.bKeepDescription)
				Server.HostName = Temp;

			Temp = ParseReply(Text, "hostport");
			if(Temp != "")
				Server.GamePort = Int(Temp);

			Temp = ParseReply(Text, "mapname");
			if(Temp != "")
				Server.MapName = Temp;

			Temp = ParseReply(Text, "maptitle");
			if(Temp != "")
			{
				Server.MapTitle = Temp;
				Server.MapDisplayName = Server.MapTitle;
				if(Server.MapTitle == "" || Server.MapTitle ~= "Untitled" || bUseMapName)
					Server.MapDisplayName = Server.MapName;
			}
		
			Temp = ParseReply(Text, "gametype");
			if(Temp != "")
				Server.GameType = Temp;
	
			Temp = ParseReply(Text, "numplayers");
			if(Temp != "")
				Server.NumPlayers = Int(Temp);

			Temp = ParseReply(Text, "maxplayers");
			if(Temp != "")
				Server.MaxPlayers = Int(Temp);
	
			Temp = ParseReply(Text, "gamemode");
			if(Temp != "")
				Server.GameMode = Temp;

			Temp = ParseReply(Text, "gamever");
			if(Temp != "")
				Server.GameVer = Int(Temp);

			Temp = ParseReply(Text, "minnetver");
			if(Temp != "")
				Server.MinNetVer = Int(Temp);

			mutatornow=true;
			SendText(ServerIPAddr,"\\status\\");
			RequestSentTime = Level.TimeSeconds;
			SetTimer(PingTimeout + FRand(),False);
		}
		else
		{
			if (instr(text,NameOfMutator)==-1)
			{
				Server.HostName="Server incompatible, not a "$NameOfMutator$" server";
				Server.Ping = 9999;
				Server.GamePort = 0;
				Server.MapName = "";
				Server.MapDisplayName = "";
				Server.MapTitle = "";
				Server.GameType = "";
				Server.GameMode = "";
				Server.NumPlayers = 0;
				Server.MaxPlayers = 0;
			}
			if( Server.DecodeServerProperties(Textinfo) )
			{
				Server.PingDone(bInitial, bJustThisServer, True, bNoSort);
				Disable('Tick');
			}
		}
	}

	event Tick(Float DeltaTime)
	{
		LastDelta = DeltaTime;
	}

	event Timer()
	{
		ValidateServer();
		if(AttemptNumber < PingAttempts)
		{
			Log("Ping Timeout from "$Server.IP$".  Attempt "$AttemptNumber);
			AttemptNumber++;
			GotoState(QueryState);
		}
		else
		{
			Log("Ping Timeout from "$Server.IP$" Giving Up");

			Server.Ping = 9999;
			Server.GamePort = 0;
			Server.MapName = "";
			Server.MapDisplayName = "";
			Server.MapTitle = "";
			Server.GameType = "";
			Server.GameMode = "";
			Server.NumPlayers = 0;
			Server.MaxPlayers = 0;

			Disable('Tick');

			Server.PingDone(bInitial, bJustThisServer, False, bNoSort);
		}
	}

Begin:
	mutatornow=false;
	Enable('Tick');
	SendText( ServerIPAddr, "\\info\\" );
	RequestSentTime = Level.TimeSeconds;
	SetTimer(PingTimeout + FRand(), False);
}

defaultproperties
{
	NameOfMutator="Escort the VIP"
}
