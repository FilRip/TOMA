Class TOPAMBrowserServerList extends TO_BrowserServerList;

function PingServer (bool bInitial, bool bJustThisServer, bool bNoSort)
{
	ServerPing=GetPlayerOwner().GetEntryLevel().Spawn(Class'TOPAMBrowserServerPing');
	ServerPing.Server=self;
	ServerPing.StartQuery('GetInfo',2);
	ServerPing.bInitial=bInitial;
	ServerPing.bJustThisServer=bJustThisServer;
	ServerPing.bNoSort=bNoSort;
	bPinging=True;
}

function ServerStatus ()
{
	ServerPing=GetPlayerOwner().GetEntryLevel().Spawn(Class'TOPAMBrowserServerPing');
	ServerPing.Server=self;
	ServerPing.StartQuery('GetStatus',2);
	bPinging=True;
}

function PingDone(bool bInitial, bool bJustThisServer, bool bSuccess, bool bNoSort)
{
	local UBrowserServerListWindow W;
	local UBrowserServerList OldSentinel;

	// Destroy the UdpLink
	if(ServerPing != None)
		ServerPing.Destroy();

	ServerPing = None;

	bPinging = False;
	bPingFailed = !bSuccess;
	bPinged = True;

	OldSentinel = UBrowserServerList(Sentinel);
	if(!bNoSort)
	{
		Remove();

		// Move to the ping list
		if(!bPingFailed || (OldSentinel != None && OldSentinel.Owner != None && OldSentinel.Owner.bShowFailedServers))
		{
			if (OldSentinel.Owner.PingedList != None)
				if (self.Ping!=9999)
					OldSentinel.Owner.PingedList.AppendItem(Self);
		}
	}
	else
	{
		if(OldSentinel != None && OldSentinel.Owner != None && OldSentinel != OldSentinel.Owner.PingedList)
			Log("Unsorted PingDone lost as it's not in ping list!");
	}

	if(Sentinel != None)
	{
		UBrowserServerList(Sentinel).bNeedUpdateCount = True;

		if(bInitial)
			ConsiderForSubsets();
	}

	if(!bJustThisServer)
		if(OldSentinel != None)
		{
			W = OldSentinel.Owner;

			if(W.bPingSuspend)
			{
				W.bPingResume = True;
				W.bPingResumeIntial = bInitial;
			}
			else
				OldSentinel.PingNext(bInitial, bNoSort);
		}
}

defaultproperties
{
}
