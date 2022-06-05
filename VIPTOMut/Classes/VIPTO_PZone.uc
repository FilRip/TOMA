class VIPTO_PZone extends TO_PZone;

simulated function tick(float delta)
{
	Super.Tick(delta);
	if (VIPTO_Player(zzSP).isvip) zzSP.bInBuyZone=false;
}

simulated function Timer ()
{
	if ( check1() )
	{
		SetTimer(zzFrequency * 2.00,False);
		return;
	}

	check2();
	SetTimer(zzFrequency,False);
}

final simulated function bool check1()
{
	if (Owner==None)
	{
		Destroy();
		return True;
	}
	if (zzP.PlayerReplicationInfo==None)
		return True;
	if ((zzbPlayer) && ((zzsP.PlayerReplicationInfo.bIsSpectator) || (zzsP.PlayerReplicationInfo.bWaitingPlayer) || (zzsP.bNotPlaying)))
		return True;
	else
		if ((zzbBot) && (zzB.PlayerReplicationInfo.bIsSpectator))
			return True;
	return False;
}

final simulated function check2()
{
	local int zzi;
	local bool zzbClimbingLadder;

	zzbCheck=!zzbCheck;
	ClearPZone();
	zzbClimbingLadder=False;
	for(zzi=0;zzi<4;zzi++)
	{
		if ( zzP.Touching[zzi] != None )
			if ( zzP.Touching[zzi].IsA('s_ZoneControlPoint') )
				VIPSetZone(s_ZoneControlPoint(zzP.Touching[zzi]));
			else
				if ( zzbPlayer && (zzP.Touching[zzi].IsA('TO_Ladder') || zzP.Touching[zzi].IsA('s_Ladder')) )
					zzbClimbingLadder=True;
	}
	if ((zzbPlayer) && (Role==ROLE_Authority))
	{
		if (!zzbClimbingLadder)
		{
			if (zzsP.GetStateName()=='Climbing')
			{
				if (zzsP.Region.Zone.bWaterZone)
				{
					zzsP.SetPhysics(PHYS_Swimming);
					zzsP.GotoState('PlayerSwimming');
				}
				else
					zzsP.GotoState('PlayerWalking');
				zzsP.CalculateWeight();
			}
			else
			{
				if ((zzsP.GetStateName()=='PlayerWalking') && (zzsP.Physics==PHYS_Flying))
				{
					zzsP.SetPhysics(PHYS_Falling);
					zzsP.CalculateWeight();
				}
			}
		}
	}
	if ((zzbPlayer) && (Role==ROLE_Authority))
	{
		if (zzbCheck)
			checkTheskins();
		else
			if ((zzbPlayer) && (zzsP.PlayerReplicationInfo.Team>2))
				MoveAway("Illegal Team detected!");
	}
}

final simulated function CheckTheSkins()
{
	local bool zzB;

	if (Class'TO_ModelHandler'.static.CheckTeamModel(zzsP,zzsP.PlayerModel))
	{
		zzB=string(zzsP.MultiSkins[0])~=Class'TO_ModelHandler'.Default.Skin0[zzsP.PlayerModel];
		zzB=zzB && (string(zzsP.MultiSkins[1])~=Class'TO_ModelHandler'.Default.Skin1[zzsP.PlayerModel]);
		zzB=zzB && (string(zzsP.MultiSkins[2])~=Class'TO_ModelHandler'.Default.Skin2[zzsP.PlayerModel]);
		zzB=zzB && (string(zzsP.MultiSkins[3])~=Class'TO_ModelHandler'.Default.Skin3[zzsP.PlayerModel]);
		zzB=zzB && (string(zzsP.MultiSkins[4])~=Class'TO_ModelHandler'.Default.Skin4[zzsP.PlayerModel]);
		if (!zzB)
			if (!VIPTO_Player(zzsp).isvip) MoveAway("Illegal skin detected!");
			else
			{
				if ((zzsp.PlayerModel!=19) && (zzsp.PlayerModel!=20)) MoveAway("Illegal skin detected!");
			}
	}
	else
		if (!VIPTO_Player(zzsp).isvip) MoveAway("Illegal model detected!"); else if ((zzsp.PlayerModel!=19) && (zzsp.PlayerModel!=20)) MoveAway("Illegal model detected!");
}

final simulated function VIPSetZone(s_ZoneControlPoint Zone)
{
	local	s_SWATGame	SG;

	if ( zzbPlayer && !zzsP.PlayerReplicationInfo.bIsSpectator )
	{
		//log("TO_PZone::SetZone - Player");
		zzsP.bInRescueZone = zzsP.bInRescueZone || Zone.bRescuePoint;
		zzsP.bInBombingZone = zzsP.bInBombingZone || Zone.bBombingZone;
		if ( Zone.bEscapeZone )
		{
			//log("TO_PZone::SetZone - bEscapeZone");
			zzsP.bInEscapeZone = zzsP.bInEscapeZone || Zone.bEscapeZone;
			if ( (Level.NetMode != NM_Client) && (zzsP.PlayerReplicationInfo.team == Zone.OwnedTeam) ) //Role == Role_Authority )
				zzsP.Escape();
		}
		if ( zzsP.PlayerReplicationInfo.team == 1-Zone.OwnedTeam )
		{
			zzsP.bInBuyZone = zzsP.bInBuyZone || Zone.bBuyPoint;
			zzsP.bInHomeBase = zzsP.bInHomeBase || Zone.bHomeBase;
		}
	}
	else if ( Level.NetMode != NM_Client ) //Role == Role_Authority )
	{
		if ( zzbBot && !zzB.bNotPlaying )
		{
			if ( Zone.bRescuePoint )
				zzB.bInRescueZone = zzB.bInRescueZone || Zone.bRescuePoint;

			zzB.bInHostageHidingPlace = zzB.bInHostageHidingPlace || Zone.bHostageHidingPlace;
			zzB.bInBombingZone = zzB.bInBombingZone || Zone.bBombingZone;
			if ( Zone.bBombingZone )
				zzB.PlantC4Bomb();

			if ( zzB.PlayerReplicationInfo.team == Zone.OwnedTeam )
			{
				zzB.bInBuyZone = zzB.bInBuyZone || Zone.bBuyPoint;
				zzB.bInHomeBase = zzB.bInHomeBase || Zone.bHomeBase;

				if ( Zone.bEscapeZone )
				{
					zzB.bInEscapeZone = zzB.bInEscapeZone || Zone.bEscapeZone;
					zzB.Escape();
				}
			}
		}
		else if ( zzbNPC )
		{
			zzNPC.bInHostageHidingPlace = Zone.bHostageHidingPlace;

			if ( Zone.bRescuePoint )
			{
				if ( (zzNPC.Followed != None) && (s_Bot(zzNPC.Followed) != None) )
				{
					if ( s_Bot(zzNPC.Followed).HostageFollowing > 0 )
						s_Bot(zzNPC.Followed).HostageFollowing--;

					SG = s_SWATGame(Level.Game);

					if ( (s_Bot(zzNPC.Followed).HostageFollowing < 1) && (SG != None) )
						SG.ClearBotObjective(s_Bot(zzNPC.Followed));
				}

				zzNPC.Rescued();
			}
		}
	}
}

final function MoveAway(string zzReason)
{
	zzsP.ForceTempKickBan(zzReason);
}

defaultproperties
{
}
