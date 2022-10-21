//----------------------------------------------------------------------------
// Project : TOST
// File    : TOST_Knife.uc
// Version : 0.5
// Author  : BugBunny/Shag
//----------------------------------------------------------------------------
// Version	Changes
// 0.5		+ first release
//----------------------------------------------------------------------------

class TOST_Knife extends TOSTWeaponNoRecoilBug;

var		byte		BloodFrame, CurrentFrame;
var		bool		bThrow;

replication
{
	// Functions server calls on clients
	reliable if( Role == ROLE_Authority)
		UpdateBloodSkin, ForceModeChange;
}

event float BotDesireability(Pawn Bot)
{
	return -2;
}

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

	return ( FMin(0.5, 50/(EnemyDist + 1)) );
}

function float SuggestAttackStyle()
{
	local float EnemyDist;
	local	pawn	P;

	P = Pawn(Owner);
	if ( (P == None) || (P.Enemy == None) )
		return 0;

	EnemyDist = VSize(P.Enemy.Location - Owner.Location);

	if (EnemyDist < 120)
		return  P.Skill;

	return 0.0;
}

function float SuggestDefenseStyle()
{
	return -2.0;
}

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

simulated function UpdateBloodSkin(byte BFrame)
{
	local Texture NewSkin;

	NewSkin = Texture(DynamicLoadObject("TOModels.JBlade"$BFrame, class'Texture'));

	MultiSkins[0] = NewSkin;
	CurrentFrame = BFrame;
}

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

function Fire(float Value)
{
	bPointing = true;
	Pawn(Owner).PlayFiring();
	Pawn(Owner).PlayRecoil(600.0/RoundPerMin);
	ClientFire(Value);
	GotoState('ServerSlash');
}

function AltFire( float Value )
{
	if ( bThrow )
		return;

	ClientAltFire(Value);
	GotoState('ServerCleanBlade');
}

simulated function bool ClientFire( float Value )
{
	PlayFiring();
	if ( Level.NetMode == NM_Client )
		GotoState('ClientSlash');

	return true;
}

simulated function bool ClientAltFire( float Value )
{
	if ( bThrow )
		return false;

	PlayCleaning();

	if ( Level.NetMode == NM_Client )
		GotoState('ClientCleanBlade');

	return true;
}

simulated function ChangeFireMode()
{
	// Force server to be da king for fire mode changing
	if ( Role < Role_Authority )
		return;

	if ( !bUseFireModes )
		return;

	if ( DoChangeFireMode() )
	{
		ForceModeChange();
		PlayChangeFireMode();
		GotoState('ServerChangeFireMode');
	}
}

simulated function ForceModeChange()
{
	if ( Role == Role_Authority )
		return;

	DoChangeFireMode();
	PlayChangeFireMode();
	GotoState('ClientChangeFireMode');
}

simulated function bool DoChangeFireMode()
{
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

simulated function ForceStillFrame()
{
	TweenToStill();

	if ( bThrow )
		PlayAnim('FixT', 0.5, 0.1);
	else
		PlayAnim('Fix', 0.5, 0.1);

	SetSkins();
	if ( Role < Role_Authority )
		GotoState('');
	else
		GotoState('idle');
}

simulated function TweenToStill()
{
	if ( bThrow )
		PlayAnim('FixT', 0.1);
	else
		PlayAnim('Fix', 0.1);
}

simulated function PlayChangeFireMode()
{
	Super.PlayChangeFireMode();

	if ( !bThrow )
		PlaySynchedAnim('SwitchT', 0.7, 0.1);
	else
		PlaySynchedAnim('Switch', 0.7, 0.1);
}

simulated function PlayIdleAnim()
{
	if ( Mesh == PickupViewMesh )
		return;

	if ( bThrow )
	{
		/*if ( (FRand() > 0.98) && (AnimSequence != 'idle1T') )
			PlayAnim('idle1T', 0.2);
		else*/ //--> this is buggy no idle1t sequence
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

simulated function PlaySelect()
{
	bForceFire = false;
	bForceAltFire = false;
	bCanClientFire = false;

	if ( !IsAnimating() )
	{
		if ( bThrow )
		{
			if ( AnimSequence != 'SelectT' )
				PlayAnim('SelectT', 0.3, 0.1);
		}
		else
		{
			if ( AnimSequence != 'Select' )
				PlayAnim('Select', 0.3, 0.1);
		}
	}

	if ( !IsAnimating() || ((AnimSequence != 'Select') && (AnimSequence != 'SelectT')) )
	{// this fix the no recoil when fast pickup switch
		if ( s_Player(owner) != none )
			s_Player(owner).NextWeapon();
	}
	else Owner.PlaySound(SelectSound, SLOT_Misc, Pawn(Owner).SoundDampening);
}

simulated function TweenDown()
{
	if ( bThrow )
		PlayAnim('DownT', 3.0, 0.1);
	else
		PlayAnim('Down', 3.0, 0.1);
}

simulated function PlayCleaning()
{
	PlaySynchedAnim('Clean', 1.0, 0.1);
}

simulated function PlayFiring()
{
	local	float t;

	t = FRand();

	if ( !bThrow )
	{
		if ( t < 0.50 )
			PlaySynchedAnim('SLASH1', 0.7, 0.1);
		else
			PlaySynchedAnim('SLASH2', 0.7, 0.1);

		PlayOwnedSound(FireSound, SLOT_None, Pawn(Owner).SoundDampening * 20.0);
	}
	else
	{
		PlaySynchedAnim('Throw', 0.6, 0.1);
		PlayOwnedSound(FireSound, SLOT_None, Pawn(Owner).SoundDampening * 20.0);
	}
}

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

	Start = Owner.Location + TOCalcDrawOffset();

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

function FireBullet(vector StartTrace, vector EndTrace, vector aimdir)
{
	local	vector				HitLocation, HitNormal, extent;
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

	if (s_SWATGame(Level.Game) != None && s_SWATGame(Level.Game).bSinglePlayer && s_Player(PawnOwner) != None)
		s_SWATGame(Level.Game).IncrementPlayerShotsFired(PawnOwner);

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
			Other.TakeDamage(MaxDamage * (MaxRange * 0.2 / length), instigator, HitLocation, MaxDamage * 50 * AimDir, 'stab');


		if ( Other.bIsPawn )
		{
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

state ClientSlash
{
	ignores ChangeFireMode, s_ReloadW;

	simulated function bool ClientFire( float Value ) { return false; }
	simulated function bool ClientAltFire( float Value ) { return false; }

	simulated function AnimEnd()
	{
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
}

state ServerSlash
{
	ignores Fire, AltFire, s_ReloadW;

	function ChangeFireMode() {}

	function SlashHit()
	{
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

			StartTrace =  Owner.Location + TOCalcDrawOffset() + FireOffset.Y * Y + FireOffset.Z * Z;
			AdjustedAim = pawn(owner).AdjustAim(1000000, StartTrace, 2 * AimError, False, False);
			k = Spawn(class's_ThrowingKnife',,, StartTrace, AdjustedAim);
			k.speed = 1000;
			k.Owner = PawnOwner;

			if (s_SWATGame(Level.Game) != None && s_SWATGame(Level.Game).bSinglePlayer && s_Player(Owner) != None)
				s_SWATGame(Level.Game).IncrementPlayerShotsFired(s_Player(Owner));

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
		if ( bThrow && (ClipAmmo == 1) )
		{
			Global.ChangeFireMode();
		}
		else
			finish();
	}


Begin:
	Sleep(0.0);
}

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

state ClientCleanBlade
{
	ignores s_ReloadW, ChangeFireMode;

	simulated function bool ClientFire( float Value ) { return false; }
	simulated function bool ClientAltFire( float Value ) { return false; }

	simulated function AnimEnd()
	{
		PlayIdleAnim();
		GotoState('');
	}
}

state ServerChangeFireMode
{
	ignores Fire, AltFire, s_ReloadW, ChangeFireMode;

	simulated function AnimEnd()
	{
		finish();
	}

Begin:
	Sleep(0.0);
}

state ClientChangeFireMode
{
	ignores s_ReloadW, ChangeFireMode;

	simulated function bool ClientFire( float Value ) { return false; }
	simulated function bool ClientAltFire( float Value ) { return false; }

	simulated function AnimEnd()
	{
		PlayIdleAnim();
		GotoState('');
	}
}

defaultproperties
{
	WeaponWeight=2.00
	bCanThrow=false
	MaxDamage=200.0
	bUseClip=false
	bUseAmmo=true
	MaxClip=0
	ClipInc=0
	ClipAmmo=1
	ClipSize=7
	RoundPerMin=100
	Price=200
	ClipPrice=50
	BotAimError=0.800000
	PlayerAimError=250.000000 // 500

	WeaponID=2
	MaxRange=125.0
	WeaponDescription="Classification: Combat Knife"
	PickupAmmoCount=30
	bMeleeWeapon=true
	FiringSpeed=1.5
	MyDamageType=stab
	shakemag=200.0
	shakevert=4.0
	AIRating=0.1
	FireSound=Sound'TODatas.Weapons.couteau2'
	SelectSound=Sound'TODatas.Weapons.Knife_select'
	AutoSwitchPriority=2
	PickupMessage="You picked up a Combat Knife !"
	ItemName="Combat Knife"
	PlayerViewOffset=(X=220.000000,Y=150.000000,Z=-250.000000)
	PlayerViewMesh=SkeletalMesh'TOModels.knifeMesh'

	PlayerViewScale=0.125
	PickupViewMesh=LodMesh'TOModels.pknife'
	ThirdPersonMesh=LodMesh'TOModels.wknife'
	PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
	bHidden=true
	bNoSmooth=false
	CollisionRadius=20.000000
	CollisionHeight=3.000000
	Mass=5.000000

	bUseFireModes=true
	bHasMultiSkins=true
	ArmsNb=2

	SolidTex=texture'TOST4TexSolid.HUD.Knife'
	TransTex=texture'TOST4TexTrans.HUD.Knife'
}
