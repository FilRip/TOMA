//
// FilRip
//
// New class for Bot, to add support of "buy only weapons of his class"
//
Class AssaultBot extends s_BotMCounterTerrorist1;

state BotBuying
{
//ignores SeePlayer;
ignores SeePlayer;

	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
							Vector momentum, name damageType)
	{
		Global.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
		if ( health <= 0 )
			return;
		SetEnemy(instigatedBy);
		if ( Enemy == None )
			return;
		if ( NextState == 'TakeHit' )
		{
			NextState = 'Attacking'; //default
			NextLabel = 'Begin';
			GotoState('TakeHit');
		}
		else if (health > 0)
			GotoState('Attacking');
	}

	function EnemyAcquired()
	{
		//GotoState('Acquisition');
	}

	function BeginState()
	{
		SpecialGoal = None;
		SpecialPause = 0.0;
		SetAlertness(-0.3);
		PlayWaiting();
	}

	function AnimEnd()
	{
		PlayWaiting();
	}


Begin:

	//Log("s_Bot::BotBuying - Begin -"@GetHumanName()@PlayerReplicationInfo.Team);
	Acceleration = vect(0,0,0);
	//TweenToFighter(0.2);
	//FinishAnim();
	//PlayTurning();
	//TurnToward(Target);
	//DesiredRotation = rot(0,0,0);
	//DesiredRotation.Yaw = Rotation.Yaw;
	//setRotation(DesiredRotation);
	//TweenToFighter(0.2);
	//FinishAnim();
	//PlayVictoryDance();
	//FinishAnim();
	//WhatToDoNext('Waiting','TurnFromWall');

	//Log("BotBuying - Entered");
	//Disable('AnimEnd');
	//PlayWaiting();
	Velocity *= 0.0;

	// Armor
	if (VestCharge < 50)
	{
		PlaySound(Sound'kevlar', SLOT_Misc);
//		Money-=400;
		VestCharge=100;
		sleep(0.17);
		MakeNoise(0.5);
	}
	if (HelmetCharge < 50)
	{
		PlaySound(Sound'kevlar', SLOT_Misc);
//		Money-=250;
		HelmetCharge=100;
		sleep(0.17);
		MakeNoise(0.5);
	}
	if ((LegsCharge < 50) && (FRand()<0.5) )
	{
		PlaySound(Sound'kevlar', SLOT_Misc);
//		Money-=300;
		LegsCharge=100;
		sleep(0.17);
		MakeNoise(0.5);
	}

	BotBuyWeapons();

	//finish();
	Objective = 'O_DoNothing';
	O_number = 255;
	OrderObject = None;

	bNeedAmmo = false;
	CountCheck = 0;
	for (TempInv=Inventory; TempInv != None; TempInv = TempInv.Inventory)
	{
		CountCheck++;
		if (CountCheck > 100)
			break;

		if ( (s_Weapon(TempInv) != None) && (s_Weapon(TempInv).bUseAmmo) )
			while( BotBuyAmmo(s_Weapon(TempInv)) )
			{
				// pause
				sleep(0.17);
				MakeNoise(0.5);
			}
	}

	//Enable('AnimEnd');

	GotoState(OldState);
}

// Function to call to force bot to choice a weapons of a class
function bool BotGetWeapon (byte WeaponClass)
{
	local Class<S_Weapon> W;
	local int i;

	for (i=0;i<=Class'AssaultWeaponsHandler'.Default.NumWeapons;i++)
	{
		if ((Class'AssaultWeaponsHandler'.Default.WeaponStr[i]!="") && (Class'AssaultWeaponsHandler'.static.IsTeamMatch(self,i)) && (class'AssaultWeaponsHandler'.static.IsClassMatch(self,i)) && (FRand()<Class'AssaultWeaponsHandler'.Default.BotDesirability[i]))
		{
			W=Class<S_Weapon>(DynamicLoadObject(Class'TO_WeaponsHandler'.Default.WeaponStr[i],Class'Class'));
			if ((FindInventoryType(W)==None) && (W.Default.WeaponClass==WeaponClass) /*&& (money>W.Default.price)*/)
			{
				AssaultMod(Level.Game).GiveWeapon(self,Class'TO_WeaponsHandler'.Default.WeaponStr[i]);
//				money-=W.Default.price;
				MakeNoise(0.75);
				return True;
			}
		}
	}
	return False;
}

defaultproperties
{
    PlayerReplicationInfoClass=class'AssaultBRI'
}
