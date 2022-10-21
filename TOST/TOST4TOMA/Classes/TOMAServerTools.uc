class TOMAServerTools extends TOSTServerTools;

function EventTakeDamage( out int ActualDamage, Pawn Victim, Pawn InstigatedBy, out Vector HitLocation, out vector Momentum, name DamageType)
{
	local 	int 	i;
	local 	Pawn 	P;
	local	int		rnd;
    local string addme;

	// fix hossies kill score
	if (Victim != none && Victim.IsA('s_NPCHostage') && ActualDamage >= (Victim.Health - ActualDamage))
	{
		if ( ActualDamage >= Victim.Health)
		{
			if ( ActualDamage > Victim.Mass )
				i = ActualDamage + Victim.Health;
			else
				i = ActualDamage;
		} else {
			i = 2*ActualDamage - Victim.Health;
		}

		if (instigatedBy.IsA('s_Player') && instigatedBy.PlayerReplicationInfo != none)
		{
			TO_PRI(instigatedBy.PlayerReplicationInfo).InflictedDmg -= i;
		} else {
			if (instigatedBy.IsA('s_Bot') && instigatedBy.PlayerReplicationInfo != none)
			{
				TO_BRI(instigatedBy.PlayerReplicationInfo).InflictedDmg -= i;
			}
		}
	}

	if (!(InstigatedBy == none || Victim == none || instigatedBy.PlayerReplicationInfo == none || (InstigatedBy.PlayerReplicationInfo.PlayerName == "Player" && InstigatedBy.PlayerReplicationInfo.PlayerID == 0)))
	{
		if (instigatedBy != none && Victim.IsA('s_Player') && Victim.Health-ActualDamage <= 0)
		{
			// TOStats support
// TODO : Do not work on TOMA
/*			if(DamageType == 'explosion')
				TOST.LogHook.LogEventString(TOST.LogHook.GetTimeStamp()$Chr(9)$"killwid"$Chr(9)$InstigatedBy.PlayerReplicationInfo.PlayerID$Chr(9)$"3"$Chr(9)$Victim.PlayerReplicationInfo.PlayerID$Chr(9)$s_Weapon(Victim.Weapon).WeaponID);
			else
				TOST.LogHook.LogEventString(TOST.LogHook.GetTimeStamp()$Chr(9)$"killwid"$Chr(9)$InstigatedBy.PlayerReplicationInfo.PlayerID$Chr(9)$s_Weapon(InstigatedBy.Weapon).WeaponID$Chr(9)$Victim.PlayerReplicationInfo.PlayerID$Chr(9)$s_Weapon(Victim.Weapon).WeaponID);
*/
			// HP Message
			if( HPMessage && Victim.PlayerReplicationInfo != none)
			{
				if(InstigatedBy == Victim) {
					// suicide
					NotifyPlayer(1, PlayerPawn(Victim), "You committed suicide!");
				}
				else if(InstigatedBy.PlayerReplicationInfo.Team == Victim.PlayerReplicationInfo.Team)
				{
					if(DamageType == 'explosion')
						NotifyPlayer(1, PlayerPawn(Victim), InstigatedBy.PlayerReplicationInfo.PlayerName $ " (" $	GetHPArmor(instigatedBy) $ ") teamkilled you with a nade!");
					else
						NotifyPlayer(1, PlayerPawn(Victim), InstigatedBy.PlayerReplicationInfo.PlayerName $ " (" $	GetHPArmor(instigatedBy) $ ") teamkilled you" $ GetWeapon(instigatedBy) $ "!");
					NotifyRest(1, PlayerPawn(Victim), InstigatedBy.PlayerReplicationInfo.PlayerName $" (PID: "$InstigatedBy.PlayerReplicationInfo.PlayerID$") teamkilled "$Victim.PlayerReplicationInfo.PlayerName);
				} else {
					if(DamageType == 'explosion')
						NotifyPlayer(1, PlayerPawn(Victim), InstigatedBy.PlayerReplicationInfo.PlayerName $ " (" $ GetHPArmor(instigatedBy) $ ") killed you with a nade!");
					else
					{
                        if ( (InstigatedBy.Weapon==none) || (!InstigatedBy.Weapon.IsA('s_Weapon')) )
                        {
                            if (InstigatedBy.IsA('TOMAPupae')) addme="with its teeth";
                            if (InstigatedBy.IsA('TOMACow')) addme="with his head";
                            if (InstigatedBy.IsA('TOMANali')) addme="with his energy aura";
                            if (InstigatedBy.IsA('TOMAKrall')) addme="with his magic stick";
                            if (InstigatedBy.IsA('TOMASlith')) addme="with his poison";
                            if (InstigatedBy.IsA('TOMAWarlord')) addme="with his rocket";
                            if (InstigatedBy.IsA('TOMABrute')) addme="with his double gun";
                            if (InstigatedBy.IsA('TOMATitan')) addme="with his rock";
                            if ( (InstigatedBy.IsA('TOMAFly')) || (InstigatedBy.IsA('TOMAManta')) ) addme="with his dart";
                            if (InstigatedBy.IsA('TOMAGasbag')) addme="with his venom";
                            if (InstigatedBy.IsA('TOMAMercenary')) addme="with his incredible weapon";
                            if (InstigatedBy.IsA('TOMATentacle')) addme="with his pile";
						  NotifyPlayer(1, PlayerPawn(Victim), InstigatedBy.PlayerReplicationInfo.PlayerName $ " (" $ GetHPArmor(instigatedBy) $ ") killed you " $ addme $ "!");
                        }
                        else
                        {
                            NotifyPlayer(1, PlayerPawn(Victim), InstigatedBy.PlayerReplicationInfo.PlayerName $ " (" $ GetHPArmor(instigatedBy) $ ") killed you" $ GetWeapon(instigatedBy) $ "!");
                        }
					}
				}
			}

			// TK Handling
			if(InstigatedBy.PlayerReplicationInfo.Team == Victim.PlayerReplicationInfo.Team && instigatedBy != Victim && s_GameReplicationInfo(Level.Game.GameReplicationInfo).RoundStarted - s_GameReplicationInfo(Level.Game.GameReplicationInfo).RemainingTime < 15 && s_GameReplicationInfo(Level.Game.GameReplicationInfo).FriendlyFireScale > 0 && ActualDamage > 0)
				NotifyAll(1, InstigatedBy.PlayerReplicationInfo.PlayerName $" (PID: "$InstigatedBy.PlayerReplicationInfo.PlayerID$") shot at "$Victim.PlayerReplicationInfo.PlayerName);
		}
	}

	super(TOSTPiece).EventTakeDamage(ActualDamage, Victim, InstigatedBy, HitLocation, Momentum, DamageType );

	if (PlayerPawn(Victim) != none && Victim.Health > ActualDamage)
	{
		rnd = FClamp(ActualDamage, 20, 60);
		if ( damageType == 'Burned' )
			PlayerPawn(Victim).ClientInstantFlash( (1+0.009375) * rnd, -rnd * vect(16.41, 11.719, 4.6875));
		else if ( damageType == 'Corroded' )
			PlayerPawn(Victim).ClientInstantFlash( (1+0.01171875) * rnd, -rnd * vect(9.375, 14.0625, 4.6875));
		else if ( damageType == 'Drowned' )
			PlayerPawn(Victim).ClientInstantFlash( 0.390, -vect(312.5,468.75,468.75));
		else
			PlayerPawn(Victim).ClientInstantFlash( 0.019 * rnd, -rnd * vect(26.5, 4.5, 4.5));
	}
}

defaultproperties
{
}

