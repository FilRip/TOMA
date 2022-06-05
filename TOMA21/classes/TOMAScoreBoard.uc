Class TOMAScoreBoard extends TO_GUITabScores;

simulated final function TOMAScoreboard_Tool_UpdatePlayerlist()
{
	local int i, j, max, SF, Terror;
	local int team;
	local PlayerReplicationInfo pri;
	local PlayerPawn owner;
	local byte offset;
	
	PlayerCount=0;
	for (i=0;i<32;i++)
		PlayerList[i]=None;
	
	SpecCount=0;

	for (i=0;i<32;i++)
	{
		if (OwnerPlayerPawn.GameReplicationInfo.PRIArray[i]!=None)
		{
			pri=OwnerPlayerPawn.GameReplicationInfo.PRIArray[i];
			team=pri.Team;
			if (/*(pri.PlayerID!=0) && */(team<2 || team==255))
			{
				PlayerList[PlayerCount]=pri;
				PlayerCount++;
				if (team==0) SF++; else if (team==1) Terror++; else SpecCount++;
			}
		}
	}
	
	if (Terror>SF) TeamMaxPlayerCount=Terror; else TeamMaxPlayerCount=SF;	

	for (i=0;i<PlayerCount;i++)
	{
		max = i;
		for (j=i+1;j<PlayerCount;j++)
			if (TOScoreboard_Tool_ComparePlayer(j,max))
				max=j;

		pri=PlayerList[max];
		PlayerList[max]=PlayerList[i];
		PlayerList[i]=pri;
	}
}

simulated function Paint (Canvas Canvas, float x, float y)
{
	local byte listoffset;
	local byte vislines;
	local float ypos;
	local int i;
	if (!bDraw)
		return;

	if (OwnerHud.bDrawBackground)
		Super.Paint(Canvas,x,y);

	Canvas.Style=OwnerInterface.ERenderStyle.STY_Normal;
	MyY=0;

	if (Canvas.ClipY>=600)
	{
		TOScoreboard_DrawTeamstats(Canvas);
		TOScoreboard_DrawTableHeader(Canvas);
		TOMAScoreboard_Tool_UpdatePlayerlist();
		TOScoreboard_DrawPlayerList(Canvas);
	}
	else
	{
		Canvas.Style=OwnerInterface.ERenderStyle.STY_Normal;
		TOScoreboard_DrawTeamstats2(Canvas);
		ypos=Top+SpaceTitle[Resolution];
		TOScoreboard_DrawTable(Canvas,ypos);
		TOMAScoreboard_Tool_UpdatePlayerlist();
    		OwnerInterface.Design.SetScoreboardFont(Canvas);
		for (i=0;i<PlayerCount;i++)
		{
			ypos+=OwnerInterface.Design.LineHeight;
			TOScoreboard_DrawPlayer2(Canvas,PlayerList[i],ypos);
		}
	
		for (i=0;i<32;i++)
			PlayerList[i]=None;
	}
}

defaultproperties
{
}
