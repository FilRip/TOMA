//=============================================================================
// s_Knife
//=============================================================================
//
// Tactical Ops
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen and Benoit "JAH" Delayen
//=============================================================================

class s_Knife extends s_Weapon;

var		byte		BloodFrame, CurrentFrame;
var		bool		bThrow;


///////////////////////////////////////
// replication 
///////////////////////////////////////

replication 
{
//	reliable if (Role==ROLE_Authority && bNetOwner)
//		bThrow;

	// Functions server calls on clients
	reliable if( Role == ROLE_Authority)
		UpdateBloodSkin, ForceModeChange;
}


///////////////////////////////////////
// BotDesireability 
///////////////////////////////////////

event float BotDesireability(Pawn Bot)
{
	return -2;
}


///////////////////////////////////////
// RateSelf 
///////////////////////////////////////

function float RateSelf( out int bUseAltMode )
{
	local float EnemyDist;
	local bool bRetreating;
	local Pawn P;

	bUseAltMode = 0;
	P = Pawn(Owner);

	if ( (P == None) || (P.Enemy == None) )
		return -5.0;

	EnemyDist = VSize(P.Enemy.Location - Owner.Location);

	if ( EnemyDist > 150 )
		return -5.0;

	if ( (P.Weapon != self) && (EnemyDist < 120) && (P.IsA('s_Bot') && s_Bot(P).bneedammo) )
		return P.Skill;

	//if ( (EnemyDist < 750) && P.IsA('Bot') && Bot(P).bNovice && (P.Skill <= 2) && !P.Enemy.IsA('Bot') && (s_Knife(P.Enemy.Weapon) != None) )
	//	return FClamp(150/(EnemyDist + 1), 0.1, 0.7);

	return ( FMin(0.5, 50/(EnemyDist + 1)) );
}


///////////////////////////////////////
// SuggestAttackStyle 
///////////////////////////////////////

function float SuggestAttackStyle()
{
	local float EnemyDist;
	local	pawn	P;

	P = Pawn(Owner);
	if ( (P == None) || (P.Enemy == None) )
		return 0;

	EnemyDist = VSize(P.Enemy.Location - Owner.Location);

	//if (Owner.IsA('s_Bot') && s_Bot(Owner).bneedammo)
	//	return 5.0;

	if (EnemyDist < 120)
		return  P.Skill;

	return 0.0;
}
 

///////////////////////////////////////
// SuggestDefenseStyle 
///////////////////////////////////////

function float SuggestDefenseStyle()
{
	return -2.0;
}


///////////////////////////////////////
// SwitchPriority
///////////////////////////////////////

function float SwitchPriority()
{
	local	 Pawn P;

	P = Pawn(Owner);

	if ( P == None )
		return 0;

	if ( Bot(Owner) == None )
		return Super.SwitchPriority();

	if ( (P.Enemy == None) || (VSize(P.Enemy.Location - P.Location) > 160) )
		return -5.0;
	else 
		return Super.SwitchPriority();
}


///////////////////////////////////////
// UpdateBloodSkin
///////////////////////////////////////

simulated function UpdateBloodSkin(byte BFrame)
{
	local Texture NewSkin;

	NewSkin = Texture(DynamicLoadObject("TOModels.JBlade"$BFrame, class'Texture'));

	MultiSkins[1] = NewSkin;
	CurrentFrame = BFrame;
}


///////////////////////////////////////
// CheckBlood
///////////////////////////////////////

function CheckBlood()
{
	if ( BloodFrame > 3 )
		return;

	BloodFrame++;
	if ( (BloodFrame > 1) && (CurrentFrame != 1) )
		UpdateBloodSkin(1);
	else if ( (BloodFrame > 3) && (CurrentFrame != 2) )
		UpdateBloodSkin(2);
}


///////////////////////////////////////
// Fire
///////////////////////////////////////

function Fire(float Value)
{
	//log("s_Knife::Fire");
	//ClientForceFire();
	ClientFire(Value);
	GotoState('ServerSlash');
}


///////////////////////////////////////
// AltFire
///////////////////////////////////////

function AltFire( float Value )
{
	if ( bThrow )
		return;

	//log("s_Knife::AltFire");

	ClientAltFire(Value);
	GotoState('ServerCleanBlade');
}	


///////////////////////////////////////
// ClientFire
///////////////////////////////////////

simulated function bool ClientFire( float Value )
{
	//log("s_Knife::ClientFire");

	PlayFiring();
	if ( Level.NetMode == NM_Client )
		GotoState('ClientSlash');

	return true;
}


///////////////////////////////////////
// ClientAltFire
///////////////////////////////////////

simulated function bool ClientAltFire( float Value )
{
	if ( bThrow )
		return false;

	//log("s_Knife::ClientAltFire");
	PlayCleaning();
	
	if ( Level.NetMode == NM_Client )
		GotoState('ClientCleanBlade');

	return true;
}


///////////////////////////////////////
// ChangeFireMode
///////////////////////////////////////

simulated function ChangeFireMode()
{
	// Force server to be da king for fire mode changing
	if ( Role < Role_Authority )
		return;

	if ( !bUseFireModes )
		return;

	//log("s_Knife::ChangeFireMode");

	if ( DoChangeFireMode() )
	{
		ForceModeChange();
		PlayChangeFireMode();
		GotoState('ServerChangeFireMode');
	}
} 


///////////////////////////////////////
// ForceModeChange
///////////////////////////////////////

simulated function ForceModeChange()
{
	if ( Role == Role_Authority )
		return;

	//log("s_Knife::ForceModeChange");

	DoChangeFireMode();
	PlayChangeFireMode();
	GotoState('ClientChangeFireMode');
}


///////////////////////////////////////
// DoChangeFireMode
///////////////////////////////////////

simulated function bool DoChangeFireMode()
{
//	local	byte	msg;
//	log("s_Knife::DoChangeFireMode");

	//	bNeedFix = true;

/*	// client
	if ( Role < Role_Authority )
	{
		if ( (ClipAmmo == 1) && bThrow )
			return false;
		return true;
	}
*/
	// only 1 knife
	if ( ClipAmmo == 1 )
	{
		// display message "need more knives"
		if ( Owner.IsA('s_BPlayer') && (Role == Role_Authority) )
			Pawn(Owner).ReceiveLocalizedMessage(class's_WeaponMessages', 7 );

		// if was throwing, switch back to slashing
		if ( bThrow )
		{
			bThrow = !bThrow;
			return true;
		}
		return false;
	}

	if ( Owner.IsA('s_BPlayer') && (Role == Role_Authority) )
	{
		if ( bThrow )
			Pawn(Owner).ReceiveLocalizedMessage(class's_WeaponMessages', 5);
		else
			Pawn(Owner).ReceiveLocalizedMessage(class's_WeaponMessages', 6);
	}

	bThrow = !bThrow;

	return true;
}


///////////////////////////////////////
// ForceStillFrame
///////////////////////////////////////

simulated function ForceStillFrame()
{
	TweenToStill();

	if ( bThrow )
		PlayAnim('FixT', 0.5, 0.1);
	else
		PlayAnim('Fix', 0.5, 0.1);
}


///////////////////////////////////////
// TweenToStill
///////////////////////////////////////

simulated function TweenToStill()
{
	//TweenAnim('IDLE', 0.1);

	if ( bThrow )
		PlayAnim('FixT', 0.1);
	else
		PlayAnim('Fix', 0.1);
}


///////////////////////////////////////
// PlayChangeFireMode
///////////////////////////////////////

simulated function PlayChangeFireMode()
{
	//log("s_Knife::PlayChangeFireMode");
	Super.PlayChangeFireMode();

	if ( !bThrow )
		PlaySynchedAnim('SwitchT', 0.7, 0.1);
	else
		PlaySynchedAnim('Switch', 0.7, 0.1);
}


///////////////////////////////////////
// PlayIdleAnim 
///////////////////////////////////////

simulated function PlayIdleAnim()
{
	if ( Mesh == PickupViewMesh )
		return;

	if ( bThrow )
	{
		if ( (FRand() > 0.98) && (AnimSequence != 'idle1T') ) 
			PlayAnim('idle1T', 0.2);
		else 
			PlayAnim('idleT', 0.1);
	}
	else
	{
		if ( (FRand() > 0.98) && (AnimSequence != 'idle1') ) 
			PlayAnim('idle1', 0.2);
		else 
			PlayAnim('idle', 0.1);
	}
}


///////////////////////////////////////
// PlaySelect
///////////////////////////////////////

simulated function PlaySelect()
{
	bForceFire = false;
	bForceAltFire = false;
	bCanClientFire = false;
	if ( !IsAnimating() )
	{
		if (bThrow)
		{
			if (AnimSequence != 'SelectT' )
				PlayAnim('SelectT', 0.3, 0.1);
		}
		else
		{
			if (AnimSequence != 'Select' )
				PlayAnim('Select', 0.3, 0.1);
		}
	}

	Owner.PlaySound(SelectSound, SLOT_Misc, Pawn(Owner).SoundDampening);	
}


///////////////////////////////////////
// TweenDown
///////////////////////////////////////

simulated function TweenDown()
{
	if ( bThrow )
		PlayAnim('DownT', 3.0, 0.1);
	else
		PlayAnim('Down', 3.0, 0.1);
}


///////////////////////////////////////
// PlayCleaning 
///////////////////////////////////////

simulated function PlayCleaning()
{	
	PlaySynchedAnim('Clean', 1.0, 0.1);	
}


///////////////////////////////////////
// PlayFiring 
///////////////////////////////////////

simulated function PlayFiring()
{
	local	float t;
	
	//log("s_Knife::PlayFiring");
	t = FRand();

	if ( !bThrow )
	{
		if ( t < 0.50 )
			PlaySynchedAnim('SLASH1', 0.7, 0.1);
		else /*if ( t < 0.66 )*/
			PlaySynchedAnim('SLASH2', 0.7, 0.1);
		//else
		//	PlayAnim('Stab', 1.0);

		//Owner.PlaySound(FireSound, SLOT_None, Pawn(Owner).SoundDampening * 20.0);
		PlayOwnedSound(FireSound, SLOT_None, Pawn(Owner).SoundDampening * 20.0);
	}
	else
	{
		PlaySynchedAnim('Throw', 0.6, 0.1);
		//Owner.PlaySound(FireSound, SLOT_None, Pawn(Owner).SoundDampening * 20.0);
		PlayOwnedSound(FireSound, SLOT_None, Pawn(Owner).SoundDampening * 20.0);
	}
}


///////////////////////////////////////
// TraceFire
///////////////////////////////////////

function TraceFire( float Accuracy )
{
  local vector HitLocation, HitNormal, StartTrace, EndTrace, X,Y,Z, AimDir;
	local actor Other;
	local Vector Start;
	local UT_Shellcase s;
	local vector realLoc;
	local Pawn PawnOwner;

	PawnOwner = Pawn(Owner);

	Owner.MakeNoise(PawnOwner.SoundDampening);
	GetAxes(PawnOwner.ViewRotation, X, Y, Z);

	Start = Owner.Location + CalcDrawOffset();

	if ( Owner.IsA('s_BPlayer') )
	{
		StartTrace =  Start + FireOffset.Y * Y + FireOffset.Z * Z;
		AdjustedAim = pawn(owner).AdjustAim(1000000, Start, 2 * AimError, False, False);	
		EndTrace = Owner.Location + (10 + MaxRange) * vector(AdjustedAim); 

		FireBullet(StartTrace, EndTrace, X);
	}
	else
	{
		StartTrace =  Start + FireOffset.Y * Y + FireOffset.Z * Z;
		AdjustedAim = pawn(owner).AdjustAim(1000000, Start, 2 * AimError, False, False);	
		EndTrace = Owner.Location + (10 + MaxRange) * vector(AdjustedAim); 
		AimDir = (EndTrace - StartTrace) / VSize(EndTrace - StartTrace);

		FireBullet(StartTrace, EndTrace, AimDir);
	}
}


///////////////////////////////////////
// FireBullet
///////////////////////////////////////

function FireBullet(vector StartTrace, vector EndTrace, vector aimdir)
{
	local	vector				HitLocation, HitNormal, extent/*, X, Y, Z, OldLocation, TempLocation*/;
	local	actor					Other, LastHit;
	local	Pawn					PawnOwner;
	local	int						i;
	local	bool					bReduceSFX;
	local	float					SmokeDS, length, Damage;
	local	ut_SpriteSmokePuff		s;

	if (s_SWATGame(Level.Game) != None)
		bReduceSFX = s_SWATGame(Level.Game).bReduceSFX;
	else
		bReduceSFX = true;
	
	SmokeDS = 0.6 + MaxWallPiercing / 24;
	PawnOwner = Pawn(Owner);

	//GetAxes(PawnOwner.ViewRotation, X, Y, Z);

	extent = Vect(4,4,4);
	Other = Trace(HitLocation, HitNormal, EndTrace, StartTrace, true, extent);
	length = VSize(HitLocation - StartTrace);
	if (Other == None || length > MaxRange || length == 0.0)
		return;

	if ( Role == ROLE_Authority )
	{
		if ( (length < 33) && IsBehind(PawnOwner, Pawn(Other)) )
			Other.TakeDamage(200, instigator, HitLocation, MaxDamage * AimDir, 'Decapitated');
		else
			Other.TakeDamage(MaxDamage * (MaxRange * 0.2 / length), instigator, HitLocation, MaxDamage * 50 * AimDir, 'shot');


		if ( Other.bIsPawn )
		{
			Other.PlaySound(Sound'KnifePlayer', SLOT_None);
			CheckBlood();
		}
		else
		{
			Owner.PlaySound(Sound'knifewall', SLOT_None);

			if ( !bReduceSFX || (FRand() < 0.25) ) 
			{
				s = Spawn(class'ut_SpriteSmokePuff', self, , HitLocation, rotator(HitNormal));
				s.DrawScale = SmokeDS * FRand() * 0.5;
				s.RemoteRole = ROLE_None;
			}
		}
	} 
}


///////////////////////////////////////
// IsBehind
///////////////////////////////////////

function bool IsBehind(Pawn Me, Pawn Target)
{
	local vector X,Y,Z,X1,Y1,Z1;

	if ( Target == None )
		return false;

	GetAxes(Me.ViewRotation, X, Y, Z);
	GetAxes(Target.ViewRotation, X1, Y1, Z1);
	if ( (((Me.Location - Target.Location) dot X) < 0) && ((X1 dot X) > 0 ) )
		return true;

	return false;
}


///////////////////////////////////////
// ClientSlash
///////////////////////////////////////

state ClientSlash
{
	ignores ChangeFireMode, s_ReloadW;

	simulated function bool ClientFire( float Value ) { return false; }
	simulated function bool ClientAltFire( float Value ) { return false; }

	simulated function AnimEnd()
	{
		//log("s_Knife::ClientSlash::AnimEnd");
		PlayIdleAnim();
		GotoState('');
	}

	simulated function SlashHit()
	{
		if ( (PlayerPawn(Owner) != None) 
			&& ((Level.NetMode == NM_Standalone) || PlayerPawn(Owner).Player.IsA('ViewPort')) )
		{
			PlayerPawn(Owner).ShakeView(ShakeTime, ShakeMag, ShakeVert);
		}
	}

	function ThrowKnife()
	{	
		if ( (PlayerPawn(Owner) != None) 
			&& ((Level.NetMode == NM_Standalone) || PlayerPawn(Owner).Player.IsA('ViewPort')) )
		{
			PlayerPawn(Owner).ShakeView(ShakeTime, ShakeMag, ShakeVert);
		}
	}

//Begin:
	//log("s_Knife::ClientSlash::Begin");
}


///////////////////////////////////////
// ServerSlash
///////////////////////////////////////

state ServerSlash
{
	ignores Fire, AltFire, s_ReloadW;

	function ChangeFireMode() {}

	function SlashHit()
	{
		// Aiming error

		if ( (PlayerPawn(Owner) != None) 
			&& ((Level.NetMode == NM_Standalone) || PlayerPawn(Owner).Player.IsA('ViewPort')) )
		{
			PlayerPawn(Owner).ShakeView(ShakeTime, ShakeMag, ShakeVert);
		}

		if ( Bot(Owner) != None )
		{
			if ( Bot(Owner).bNovice )
				// range from (novice) x2.5 -> x1.0
				AimError = BotAimError * ( ( 5.0 - Bot(Owner).Skill ) / 2.0 ); 
			else
				// range from x1.0 -> x0.5 (godlike)
				AimError = (3.0 * BotAimError) / (Bot(Owner).Skill + 3.0); 
		}
		else
			AimError = BotAimError * 3.0;		

		if (Owner.IsA('s_NPCHostage') )
			AimError *= 1 + 2 * FRand();

		// extent = Vect(4,4,4); // to make it easier to aim
		if ( Owner.IsA('s_BPlayer') )
			TraceFire(0.0);
		else if ( Owner.IsA('Bot') )
			TraceFire(BotAimError);
	}

	function ThrowKnife()
	{	
		local s_ThrowingKnife k;
		local vector StartTrace, X, Y, Z;
		local Pawn PawnOwner;

		if ( (PlayerPawn(Owner) != None) 
			&& ((Level.NetMode == NM_Standalone) || PlayerPawn(Owner).Player.IsA('ViewPort')) )
		{
			PlayerPawn(Owner).ShakeView(ShakeTime, ShakeMag, ShakeVert);
		}


		if ( ClipAmmo > 1 )
		{
			ClipAmmo--;
			PawnOwner = Pawn(Owner);
			Owner.MakeNoise(PawnOwner.SoundDampening);
			GetAxes(PawnOwner.ViewRotation, X, Y, Z);
			
			StartTrace =  Owner.Location + CalcDrawOffset() + FireOffset.Y * Y + FireOffset.Z * Z;
			AdjustedAim = pawn(owner).AdjustAim(1000000, StartTrace, 2 * AimError, False, False);	
			k = Spawn(class's_ThrowingKnife',,, StartTrace, AdjustedAim);
			k.speed = 1000;
			k.Owner = PawnOwner;

			// New knife has clean blade!
			if ( BloodFrame > 0 )
			{
				BloodFrame = 0;
				UpdateBloodSkin(0);
			}
		}
	}

	function AnimEnd()
	{
		//log("s_Knife::ServerSlash::AnimEnd");
		if ( bThrow && (ClipAmmo == 1) )
		{
			//log("s_Knife::ServerSlash::AnimEnd - ChangeFireMode - bThrow:"@bThrow);
			Global.ChangeFireMode();
			//log("s_Knife::ServerSlash::AnimEnd - ForceModeChange - bThrow:"@bThrow);
			
			//ForceModeChange();
			//log("s_Knife::ServerSlash::AnimEnd - finished");
		}
		else
			finish();
	}


Begin:
	//log("s_Knife::ServerSlash::Begin");	
	Sleep(0.0);	
}


///////////////////////////////////////
// ServerCleanBlade
///////////////////////////////////////

state ServerCleanBlade
{
	ignores Fire, AltFire, s_ReloadW, ChangeFireMode;

	function fCleanBlade()
	{
		BloodFrame = 0;
		UpdateBloodSkin(0);
	}

	function AnimEnd()
	{
		finish();
	}

Begin:

		Sleep(0.0);	
}


///////////////////////////////////////
// ClientCleanBlade
///////////////////////////////////////

state ClientCleanBlade
{
	ignores s_ReloadW, ChangeFireMode;

	simulated function bool ClientFire( float Value ) { return false; }
	simulated function bool ClientAltFire( float Value ) { return false; }
/*
	simulated function EndState()
	{
		
		//GotoState('');
	}
*/
	simulated function AnimEnd()
	{
		PlayIdleAnim();
		GotoState('');
	}
}


///////////////////////////////////////
// ServerChangeFireMode
///////////////////////////////////////

state ServerChangeFireMode
{
	ignores Fire, AltFire, s_ReloadW, ChangeFireMode;

//	function Fire(float Value) {}
//	function AltFire(float Value) {}

	simulated function AnimEnd()
	{
		//log("s_Knife::ServerChangeFireMode::AnimEnd - bThrow:"@bThrow);
		finish();
	}

Begin:
	//log("s_Knife::ServerChangeFireMode::Begin");
	Sleep(0.0);	
}


///////////////////////////////////////
// ClientChangeFireMode
///////////////////////////////////////

state ClientChangeFireMode
{
	ignores s_ReloadW, ChangeFireMode;

	simulated function bool ClientFire( float Value ) { return false; }
	simulated function bool ClientAltFire( float Value ) { return false; }
/*
	simulated function EndState()
	{
		
		GotoState('');
	}
*/
	simulated function AnimEnd()
	{
		//log("s_Knife::ClientChangeFireMode::AnimEnd - bThrow:"@bThrow);
		PlayIdleAnim();
		GotoState('');
	}

//Begin:
//	log("s_Knife::ClientChangeFireMode::Begin");
}


///////////////////////////////////////
// defaultproperties 
///////////////////////////////////////

defaultproperties
{
     MaxDamage=60.000000
     bUseClip=False
     clipSize=7
     clipAmmo=1
     MaxClip=0
     ClipInc=0
     RoundPerMin=100
     price=200
     ClipPrice=100
     BotAimError=0.800000
     PlayerAimError=500.000000
     bHasMultiSkins=True
     ArmsNb=2
     WeaponID=2
     WeaponWeight=2.000000
     MaxRange=120.000000
     bUseFireModes=True
     WeaponDescription="Classification: Combat Knife"
     PickupAmmoCount=30
     bCanThrow=False
     bMeleeWeapon=True
     bRapidFire=True
     FiringSpeed=1.500000
     FireOffset=(Y=10.000000,Z=-4.000000)
     MyDamageType=shot
     shakemag=200.000000
     shakevert=4.000000
     FireSound=Sound'TODatas.Weapons.couteau2'
     SelectSound=Sound'TODatas.Weapons.couteausorti'
     DeathMessage="%k riddled %o full of holes with the %w."
     AutoSwitchPriority=2
     PickupMessage="You picked up a Combat Knife !"
     ItemName="CombatKnife"
     PlayerViewOffset=(X=420.000000,Y=125.000000,Z=-140.000000)
     PlayerViewMesh=LodMesh'TOModels.sknife'
     PlayerViewScale=0.110000
     PickupViewMesh=LodMesh'TOModels.pknife'
     ThirdPersonMesh=LodMesh'TOModels.wknife'
     PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
     bHidden=True
     CollisionRadius=20.000000
     CollisionHeight=3.000000
     Mass=15.000000
}
