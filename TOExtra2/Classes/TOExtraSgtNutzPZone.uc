class TOExtraSgtNutzPZone extends TO_PZone;

simulated function Timer()
{
	if (check1())
	{
		SetTimer(zzFrequency*2,False);
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
		if (zzP.Touching[zzi]!=None)
			if (zzP.Touching[zzi].IsA('s_ZoneControlPoint'))
				SetZone(s_ZoneControlPoint(zzP.Touching[zzi]));
			else
				if ((zzbPlayer) && (zzP.Touching[zzi].IsA('TO_Ladder') || zzP.Touching[zzi].IsA('s_Ladder')) )
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
/*		zzB=string(zzsP.MultiSkins[0])~=Class'TO_ModelHandler'.Default.Skin0[zzsP.PlayerModel];
		zzB=zzB && (string(zzsP.MultiSkins[1])~=Class'TO_ModelHandler'.Default.Skin1[zzsP.PlayerModel]);
		zzB=zzB && (string(zzsP.MultiSkins[2])~=Class'TO_ModelHandler'.Default.Skin2[zzsP.PlayerModel]);
		zzB=zzB && (string(zzsP.MultiSkins[3])~=Class'TO_ModelHandler'.Default.Skin3[zzsP.PlayerModel]);
		zzB=zzB && (string(zzsP.MultiSkins[4])~=Class'TO_ModelHandler'.Default.Skin4[zzsP.PlayerModel]);
		if (!zzB)
			MoveAway("Illegal skin detected!");  */
	}
	else
		MoveAway("Illegal model detected!");
}

final function MoveAway(string zzReason)
{
	zzsP.ForceTempKickBan(zzReason);
}

defaultproperties
{
}
