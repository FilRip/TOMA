//=============================================================================
// s_Weapon
//=============================================================================
//
// Tactical Ops
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen and Benoit "JAH" Delayen
//=============================================================================

class s_Weapon extends TournamentWeapon
			config
			abstract;

var()	float		MaxDamage;			// Max damage weapon can afflict
var()	bool		bUseAmmo;				// Weapon uses Ammo ? (to remove)
var() bool		bUseClip;				// Weapon uses clips ? 
var() byte		clipSize;				// Default clip capacity
var() byte		clipAmmo, BackClipAmmo;	// Remaining bullets in the current clip
var() byte    RemainingClip;  // Clips left
var()	byte		MaxClip;				// Maximum clip capacity
var		byte		ClipInc;				// clip Inc when buying ammo
var()	int			RoundPerMin;		// Fire rate
var		float		FirePause;			// in between fire shots.
var()	bool		bTracingBullets;// Uses tracing bullets !
var()	byte		TraceFrequency;	// TracingBullets frequency
var()	byte		TraceShotCount;			
var() int		  Price;					// Weapon price
var()	int			ClipPrice;
var()	bool		bNoDrop;				// Can weapon be dropped? (otherwise be destroyed)
var		bool		bShowWeaponLight;
var		bool		bSingleFireBasedROF;

var		bool		bReloadingWeapon;
//var		float		ReloadDuration;

var()	float		BotAimError;			// weapon aim error for bots
var()	float		PlayerAimError;		// weapon aim error for player (not used, see below)

// Player recoil
//var		bool		bRecoil;      // internal
var() float 	VRecoil;			// Vertical recoil
var() float 	HRecoil;			// Horizontal recoil
var() float 	RecoilMultiplier;		// 
var 	float 	RecoilVal;			// 
var		byte		ShotCount;		// Shots fired since trigger pulled
//var		bool		bTRecoil;     // Timer recoil
var		float		rPower;				// Recoil power

var		bool		bZeroAccuracy; // Perfect accuracy (where crosshair is)
var		bool		bStaticAimError; // Accuracy not affected by movements

var		bool		bHasMultiSkins;
var		byte		ArmsNb;					// Skin number for the arms (dynamic skinning)

var		byte		WeaponID;
var		byte		WeaponClass;
var		float		WeaponWeight;
// 1 : misc weapons and items
// 2 : pistols
// 3 : Sub machine guns / shotguns
// 4 : rifles / Heavy machine guns
// 5 : grenades
// 0 : C4

//var		bool		bOldZoomType;		// Handling zoom
var		byte		zoom_mode;
//, Old_mode;

// Animation.
struct s_WAnimation
{
	var()	name	AnimSeq;
	var()	float	AnimRate;
//	var()	sound	AsscSound;
//	var() int		SoundAmp;
};

var(s_WAnimation)	s_WAnimation	aReloadWeapon;

var	sound	EmptyClipSound;

// s_Projectile
var		float		MaxWallPiercing;
var		float		MaxRange;			
var		float		ProjectileSpeed;
var   bool    bHeavyWallHit;



// Fire modes
var		float		rofmultiplier;
var		byte		BurstRoundnb;		// Number of bullets to fire in burst mode
var		byte		BurstRoundCount;

enum EFireModes
{
	FM_None,				// Not a fire mode
	FM_SingleFire,	// Press [Fire] to fire each bullet
	FM_BurstFire,		// Press [Fire] to fire [BurstRoundnb] bullets
	FM_FullAuto,		// Hold [Fire] 
};

var	EFireModes	FireModes[5]; // Current weapon fire modes
var	byte				CurrentFireMode;
var bool				bUseFireModes;
//var	float				ChangeFireModeDuration;

// Muzzle flashs
var     int     MuzFrame;
var     float   MuzLastTime, MuzScale;
var     int     MuzX, MuzY;
var     int     MuzRadius;

// ShellCase
var		bool		bUseShellCase, bNeedFix;
var		int			numShellCase, maxShellCase;
var		string  ShellCaseType;
var		vector	ShellEjectOffset;


///////////////////////////////////////
// replication 
///////////////////////////////////////

replication 
{
	// Server send to client 
	reliable if ( (Role == ROLE_Authority) && bNetOwner && bUseClip)
		RemainingClip;

	reliable if ( Role==ROLE_Authority && bNetOwner)
		ClipAmmo;

	reliable if ( Role == ROLE_Authority )
		CurrentFireMode;

  // Functions clients can call (for Extra-Keys)
  reliable if ( Role < ROLE_Authority )
		ForceServerFire;

	// Functions server calls on clients
	reliable if ( Role == ROLE_Authority )
		ForceStillFrame /*, ForceClientReloadWeapon, ClientForceFire*/;
}


// Disabled functions
//function setHand(float Hand) {}
function AltFire(float F) {}
simulated function bool ClientAltFire( float Value ) { return false; }


function setHand(float Hand)
{
	if ( Hand == 2 )
	{
		PlayerViewOffset.Y = 0;
		FireOffset.Y = 0;
		bHideWeapon = true;
		return;
	}
	else
		bHideWeapon = false;

	PlayerViewOffset.X = Default.PlayerViewOffset.X;
	PlayerViewOffset.Y = Default.PlayerViewOffset.Y;// * Hand;
	PlayerViewOffset.Z = Default.PlayerViewOffset.Z;

	//PlayerViewOffset *= 100; //scale since network passes vector components as ints
	FireOffset.Y = Default.FireOffset.Y;
}


///////////////////////////////////////
// SetSkins
///////////////////////////////////////
// Dynamically assigns skins to weapons

function SetSkins()
{
	if ( (Owner==None) || (Pawn(Owner)==None) || (Pawn(Owner).PlayerReplicationInfo==None) 
		|| (!Level.Game.IsA('s_SWATGame')) )
		return;

	// Set correct team color (arms skin)
	if ( bHasMultiSkins && (Mesh == PlayerViewMesh) )
	{
		if ( Pawn(Owner).PlayerReplicationInfo.Team == 0 )
			MultiSkins[ArmsNb] = Texture(DynamicLoadObject("TOModels.arms_t", class'Texture'));
		else
			MultiSkins[ArmsNb] = Texture(DynamicLoadObject("TOModels.arms_sf", class'Texture'));
	}
}


///////////////////////////////////////
// ForceStillFrame
///////////////////////////////////////

simulated function ForceStillFrame()
{
	TweenToStill();

	PlayAnim('Fix', 2.0, 0.1);

	SetSkins();
	if ( Role < Role_Authority )
		GotoState('');
	else
		GotoState('idle');
}


///////////////////////////////////////
// RenderOverlays
///////////////////////////////////////

simulated event RenderOverlays( canvas Canvas )
{
	local rotator NewRot;
	local bool bPlayerOwner;
	local int Hand;
	local PlayerPawn PlayerOwner;
	local float Scale;

	if ( bHideWeapon || (Owner == None) )
		return;

	PlayerOwner = PlayerPawn(Owner);

	if ( PlayerOwner != None )
	{
		if ( PlayerOwner.DesiredFOV != PlayerOwner.DefaultFOV )
			return;
		bPlayerOwner = true;
		Hand = PlayerOwner.Handedness;

		if ( (Level.NetMode == NM_Client) && (Hand == 2) )
		{
			bHideWeapon = true;
			return;
		}
	}

	if ( !bPlayerOwner || (PlayerOwner.Player == None) )
		Pawn(Owner).WalkBob = vect(0,0,0);

	if ( (bMuzzleFlash > 0) && bDrawMuzzleFlash && Level.bHighDetailMode && (MFTexture != None) )
	{
		if ( !bSetFlashTime )
		{
			bSetFlashTime = true;
			FlashTime = Level.TimeSeconds + FlashLength;
		}
		else if ( FlashTime < Level.TimeSeconds )
			bMuzzleFlash = 0;

		if ( bMuzzleFlash > 0 )
		{
			// New muzzle flash
			Scale = Canvas.ClipX / 1024;
		
			Canvas.SetPos( (MuzX - MuzRadius*MuzScale) * Scale, (MuzY - MuzRadius*MuzScale) * Scale);
			Canvas.Style = 3;
			Canvas.DrawIcon(MFTexture, MuzScale * Scale);
			Canvas.Style = 1;
		}
	}
	else
		bSetFlashTime = false;

	SetLocation( Owner.Location + CalcDrawOffset() );
	NewRot = Pawn(Owner).ViewRotation;

	if ( Hand == 0 )
		newRot.Roll = -2 * Default.Rotation.Roll;
	else
		newRot.Roll = Default.Rotation.Roll * Hand;

	setRotation(newRot);
	Canvas.DrawActor(self, false);
}


///////////////////////////////////////
// PostRender
///////////////////////////////////////

simulated function PostRender( canvas Canvas )
{
	Super.PostRender(Canvas);

	if ( (s_BPlayer(Owner) != None) && s_BPlayer(Owner).bHideCrosshairs )
		bOwnsCrosshair = true;
	else
		bOwnsCrosshair = false;
}


///////////////////////////////////////
// ValidReloadOwner
///////////////////////////////////////

final function bool ValidReloadOwner()
{
	// Bot
	if ( PlayerPawn(Owner) == None )
		return true;

	// Player with autoreload feature
	if ( Owner.IsA('s_BPlayer') && s_BPlayer(Owner).bAutomaticReload )
		return true;

	return false;
}


///////////////////////////////////////
// Fire
///////////////////////////////////////

function Fire(float Value)
{
	//log("s_Weapon::Fire");

	if ( bUseClip )
	{
		if ( clipammo > 0 )
		{
			//bCanClientFire = true;
			bPointing = true;
			//ClientForceFire();
			ClientFire(Value);
			GotoState('sServerFire');
		}
		else 
		{
			// No ammo left
			if ( EmptyClipSound != None )
				PlayOwnedSound(EmptyClipSound, SLOT_None, Pawn(Owner).SoundDampening);

			// AutoReload
			if ( (RemainingClip > 0) && ValidReloadOwner() )
			{
				//ForceClientReloadWeapon();
				s_ReloadW();
			}
		}
	}
	else
	{	
		//bCanClientFire = true;
		bPointing = true;
		//ClientForceFire();
		ClientFire(Value);
		GotoState('sServerFire');
	}
}


///////////////////////////////////////
// ClientFire
///////////////////////////////////////

simulated function bool ClientFire( float Value )
{
	if ( bUseClip && (clipammo < 1) )
	{
		// No ammo left
		if ( EmptyClipSound != None )
			PlayOwnedSound(EmptyClipSound, SLOT_None, Pawn(Owner).SoundDampening);

		return false;
	}
	//log("s_Weapon::ClientFire");

	if (Owner.IsA('s_BPlayer') && s_BPlayer(Owner).bSZoom && (FireModes[CurrentFireMode] == FM_FullAuto) )
		rofmultiplier = 120.0;
	else
		rofmultiplier = 60.0;

	ShotCount = 1;
	BurstRoundCount = 1;
	PlayFiring();
	if ( Level.NetMode == NM_Client )
		GotoState('sClientFire');

	return true;
}


///////////////////////////////////////
// ClientForceFire
///////////////////////////////////////
// Forces player to fire. From server to client.

function ClientForceFire()
{
	//log("s_Weapon::clientforcefire");
	if ( TournamentPlayer(Owner) != None )
		TournamentPlayer(Owner).SendFire(self);

	/*
	if ( Role == Role_Authority )
		return;

	ClientFire( 0.0 );
	*/
}

simulated function ForceClientFire()
{
	//log("s_Weapon::ForceClientFire - s:"@GetStateName());
	ClientFire(0);
}


///////////////////////////////////////
// GenerateBullet
///////////////////////////////////////

function GenerateBullet()
{
	local	s_SWATGame	SG;
	
	// Enhance to support UT GameTypes
	SG = s_SWATGame(Level.Game);

	if ( UseAmmo(1) ) 
	{
		FiringEffects();

		if ( SG != None && SG.bEnableBallistics )
			TraceFireBallistics(AimError);
		else
			TraceFire(AimError);
	}
}


///////////////////////////////////////
// SetAimError
///////////////////////////////////////

function SetAimError()
{
	local	float	cvel, accmultiplier;

	// Aiming error
	if ( Owner.IsA('s_BPlayer') )
	{
		if ( bZeroAccuracy && s_BPlayer(Owner).bSZoom && (VSize(Owner.Velocity) < 20) )
			AimError = 0.0;
		else 
		{
			AimError = PlayerAimError;

			if ( bStaticAimError )
				return;

			accmultiplier = 1.0;

			// Zooming
			if ( s_BPlayer(Owner).bSZoom && (bZeroAccuracy || (VSize(Owner.Velocity) < 20)) )
				accmultiplier -= 0.20;

			// Crouching
			if ( s_BPlayer(Owner).bIsCrouching )
				accmultiplier -= 0.1;

			// Moving
			cvel = Abs(VSize(s_BPlayer(Owner).Velocity));
			if ( cvel < 20 )
				accmultiplier -= 0.2;
			else if ( cvel > 150 )
				accmultiplier += 0.2;

			AimError *= accmultiplier;
		}
	}
	else if ( Bot(Owner) != None )
	{
		if ( Bot(Owner).bNovice )
			// range from (novice) x3.0 -> x1.5
			AimError = BotAimError * ( 3.0 - Bot(Owner).Skill * 0.5 ); 
		else
			// range from x1.5 -> x0.5 (godlike)
			AimError = (1.5 * BotAimError) / ((Bot(Owner).Skill/1.5) + 1.0); 
/*	
		if ( Bot(Owner).bNovice )
			// range from (novice) x2.5 -> x1.0
			AimError = BotAimError * ( ( 5.0 - Bot(Owner).Skill ) / 2.0 ); 
		else
			// range from x1.0 -> x0.5 (godlike)
			AimError = (3.0 * BotAimError) / (Bot(Owner).Skill + 3.0); 
*/
	}
	else
		AimError = BotAimError * 3.0;		

	if ( Owner.IsA('s_NPCHostage') )
		AimError *= 1 + FRand();
}


///////////////////////////////////////
// HasHighROF
///////////////////////////////////////

final function bool HasHighROF()
{
	return ( (FireModes[CurrentFireMode] != FM_SingleFire) && (RoundPerMin > 599) );
}


///////////////////////////////////////
// FiringEffects
///////////////////////////////////////

function FiringEffects()
{
	local vector X,Y,Z, Start;
	local Pawn PawnOwner;

	PawnOwner = Pawn(Owner);

	Owner.MakeNoise(PawnOwner.SoundDampening);
	GetAxes(PawnOwner.ViewRotation,X,Y,Z);

	if ( bShowWeaponLight && !HasHighROF() )
	{
		Start = Owner.Location + CalcDrawOffset();
		spawn(class'WeaponLight', self, '', Start + 20.0 * X, rot(0,0,0) );	
	}

	if ( bUseShellCase )
		SpawnShellCase(X, Y, Z);
}


///////////////////////////////////////
// SpawnShellCase
///////////////////////////////////////

final function SpawnShellCase(Vector X, Vector Y, Vector Z)
{
	local s_Shellcase s;
	local class<s_ShellCase> SCclass;
	local	bool		bReduceSFX;

	//log("s_Weapon::SpawnShellCase");

	if (s_SWATGame(Level.Game) != None)
		bReduceSFX = s_SWATGame(Level.Game).bReduceSFX;
	else
		bReduceSFX = true;

	if ( bReduceSFX && HasHighROF() )
	{
		numShellCase++;
		if ( numShellCase < maxShellCase )
			return;

		numShellCase = 0;
	}

	SCclass = class<s_ShellCase>(DynamicLoadObject(ShellCaseType, class'Class'));

	if ( SCclass == None )
	{
		log("s_Weapon::SpawnShellCase - SCclass == None");
		return;
	}

	s = spawn(SCclass,, '', Owner.Location + CalcDrawOffset() + ShellEjectOffset.X * X + ShellEjectOffset.Y * Y + ShellEjectOffset.Z * Z);

	//s = Spawn(class's_ShellCase',, '', Owner.Location + CalcDrawOffset() + 30 * X + (2.8 * FireOffset.Y+5.0) * Y - Z * 1);
	if ( s != None ) 
		s.Eject(((FRand()*0.3+0.4)*X + (FRand()*0.2-0.4)*Y + (FRand()*0.3+1.0) * Z)*160);              	
}


///////////////////////////////////////
// PlayFiring 
///////////////////////////////////////

simulated function PlayFiring()
{
	//log("s_Weapon::PlayFiring - clipammo:"@clipammo@"- RemainingClip:"@RemainingClip);

	if ( (PlayerPawn(Owner) != None) 
		&& ((Level.NetMode == NM_Standalone) || PlayerPawn(Owner).Player.IsA('ViewPort')) )
	{
		//if ( InstFlash != 0.0 )
		//	PlayerPawn(Owner).ClientInstantFlash( InstFlash, InstFog);
		PlayerPawn(Owner).ShakeView(ShakeTime, ShakeMag, ShakeVert);

		// recoil
		if ( s_BPlayer(Owner) != None )
			s_BPlayer(Owner).bDoRecoil = true;
	}

	if ( Affector != None )
		Affector.FireEffect();

	//AmbientGlow = 200;
/*
	if ( Role == Role_Authority )
	{
		if ( !bRapidFire && (FiringSpeed > 0) )
			Pawn(Owner).PlayRecoil(FiringSpeed);
	}
*/
	bMuzzleFlash++;

	// Burst firing musn't act like auto firing!
	if ( (FireModes[CurrentFireMode] == FM_BurstFire) && (BurstRoundCount == BurstRoundnb) )
		rofmultiplier = 300.0;
	
	/*if ( AnimSequence != 'Fire' || !IsAnimating())*/
	if ( HasAnim('Fire') )
	{
		if ( RoundPerMin != 0 )
			PlaySynchedAnim('Fire', rofmultiplier / RoundPerMin, 0.01);
		else
			PlayAnim('Fire', 2.0, 0.01);
	}

	// AmbientLoop
//	log("s_Weapon::PlayFiring - bUseFireModes:"@bUseFireModes@"FireModes[CurrentFireMode]:"@FireModes[CurrentFireMode]@"Misc1Sound:"@Misc1Sound);
/*
	if ( bUseFireModes && (FireModes[CurrentFireMode] == FM_FullAuto) && (Misc1Sound != None) )
	{
		// play nothing!
	}
	else if ( FireSound != None )
		PlayOwnedSound(FireSound, SLOT_None, 255);
*/
}


///////////////////////////////////////
// PlaySynchedAnim 
///////////////////////////////////////

final simulated function PlaySynchedAnim(name AnimName, float DesiredTime, float DesiredTween)
{
	local	float	ratio;

	//log("s_Weapon::PlaySynchedAnim - desiredtime:"@DesiredTime);
	if ( HasAnim(AnimName) )
	{
		PlayAnim(AnimName, 1, 0);
		ratio = ((1.0 - AnimFrame) / (AnimRate)) / DesiredTime;
		//log("s_Weapon::PlaySynchedAnim - ratio:"@ratio@"- AnimFrame:"@AnimFrame@"- AnimRate:"@AnimRate);
		PlayAnim(AnimName, ratio, DesiredTween);
	}
}


///////////////////////////////////////
// Finish 
///////////////////////////////////////

function Finish()
{
	//log("s_Weapon::Finish");

	bSteadyFlash3rd = false;
	bMuzzleFlash = 0;

	if ( bChangeWeapon )
	{
		GotoState('DownWeapon');
		return;
	}

	if ( PlayerPawn(Owner) == None )
	{
		if ( bUseClip && (ClipAmmo < 1) && (RemainingClip < 1) )
		{
			Pawn(Owner).StopFiring();
			Pawn(Owner).SwitchToBestWeapon();
			if ( bChangeWeapon )
				GotoState('DownWeapon');
		}
		else
		{
			Pawn(Owner).StopFiring();
			GotoState('Idle');
		}
		return;
	}

/*	if ( bNeedFix )
	{
		GotoState('ForceIdle');
		bNeedFix = false;
		ForceStillFrame();
	}
	else
*/
		GotoState('Idle');
}


///////////////////////////////////////
// TraceFireBallistics
///////////////////////////////////////

function TraceFireBallistics( float Accuracy )
{
  local vector StartTrace, EndTrace, X,Y,Z, AimDir;
	local Pawn PawnOwner;

	Accuracy = AimError;

	//log("s_Weapon - TraceFire");
	PawnOwner = Pawn(Owner);

	GetAxes(PawnOwner.ViewRotation,X,Y,Z);

	if ( Owner.IsA('s_BPlayer') )
	{
		StartTrace = Owner.Location + CalcDrawOffset() /*+ Instigator.Eyeheight * Z + X*/;
		AdjustedAim = PawnOwner.AdjustAim(1000000, StartTrace, AimError, False, False);	
		EndTrace = StartTrace + Accuracy * (FRand() - 0.5 )* Y * 1000 + Accuracy * (FRand() - 0.5 ) * Z * 1000;
		X = vector(AdjustedAim);
		EndTrace += (MaxRange * X);

		if ( bTracingBullets && TraceFrequency > 0)
		{
			TraceShotCount++;
			if (TraceShotCount >= TraceFrequency )
			{
				TraceShotCount = 0;
				Spawn(class's_TracingBullet', Self,, StartTrace, rotator(EndTrace - StartTrace));
			}
			else
				Spawn(class's_Projectile', Self,, StartTrace, rotator(EndTrace - StartTrace));
		}
		else
			Spawn(class's_Projectile', Self,, StartTrace, rotator(EndTrace - StartTrace));
	}
	else
	{
	/*
		GetAxes(PawnOwner.ViewRotation,X,Y,Z);
	StartTrace = Owner.Location + CalcDrawOffset() + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z; 
	AdjustedAim = PawnOwner.AdjustAim(1000000, StartTrace, 2*AimError, False, False);	
	EndTrace = StartTrace + Accuracy * (FRand() - 0.5 )* Y * 1000
		+ Accuracy * (FRand() - 0.5 ) * Z * 1000;
	X = vector(AdjustedAim);
	EndTrace += (10000 * X); 
	Other = PawnOwner.TraceShot(HitLocation,HitNormal,EndTrace,StartTrace);
	ProcessTraceHit(Other, HitLocation, HitNormal, X,Y,Z);
	*/
		StartTrace = Owner.Location + CalcDrawOffset() + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z; 
		AdjustedAim = PawnOwner.AdjustAim(1000000, StartTrace, AimError, False, False);	
		EndTrace = StartTrace + Accuracy * (FRand() - 0.5 )* Y * 1000 + Accuracy * (FRand() - 0.5 ) * Z * 1000;
		X = vector(AdjustedAim) / VSize(vector(AdjustedAim));
		EndTrace += (MaxRange * X); 

		if ( bTracingBullets && TraceFrequency > 0)
		{
			TraceShotCount++;
			if (TraceShotCount >= TraceFrequency )
			{
				TraceShotCount = 0;
				Spawn(class's_TracingBullet', Self,, StartTrace, rotator(EndTrace - StartTrace));
			}
			else
				Spawn(class's_Projectile', Self,, StartTrace, rotator(EndTrace - StartTrace));
		}
		else
			Spawn(class's_Projectile', Self,, StartTrace, rotator(EndTrace - StartTrace));
	}

}


///////////////////////////////////////
// TraceFire
///////////////////////////////////////

function TraceFire( float Accuracy )
{
  local vector StartTrace, EndTrace, X,Y,Z, AimDir;
	local Pawn PawnOwner;

	Accuracy = AimError;

	//log("s_Weapon::TraceFire - Accuracy:"@Accuracy);
	PawnOwner = Pawn(Owner);

	GetAxes(PawnOwner.ViewRotation, X, Y, Z);

	if ( Owner.IsA('s_BPlayer') )
	{
		StartTrace = Owner.Location + CalcDrawOffset() /*+ Instigator.Eyeheight * Z + X*/;
		AdjustedAim = PawnOwner.AdjustAim(1000000, StartTrace, AimError, False, False);	
		EndTrace = StartTrace + Accuracy * (FRand() - 0.5 ) * Y * 1000 + Accuracy * (FRand() - 0.5 ) * Z * 1000;
		X = vector(AdjustedAim) / VSize(vector(AdjustedAim));
		EndTrace += (MaxRange * X);
		//log("s_Weapon::TraceFire - StartTrace:"@StartTrace@"- EndTrace:"@EndTrace);

		FireBulletInstantHit(StartTrace, EndTrace, X);
	}
	else
	{
		StartTrace = Owner.Location + CalcDrawOffset() + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z; 
		AdjustedAim = PawnOwner.AdjustAim(1000000, StartTrace, AimError, False, False);	
		EndTrace = StartTrace + Accuracy * (FRand() - 0.5 )* Y * 1000 + Accuracy * (FRand() - 0.5 ) * Z * 1000;
		X = vector(AdjustedAim) / VSize(vector(AdjustedAim));
		EndTrace += (MaxRange * X); 
		AimDir = (EndTrace - StartTrace) / VSize(EndTrace - StartTrace);

		FireBulletInstantHit(StartTrace, EndTrace, AimDir);
	}

}
/*
function TraceFire( float Accuracy )
{
	local vector HitLocation, HitNormal, StartTrace, EndTrace, X,Y,Z;
	local actor Other;
	local Pawn PawnOwner;

	PawnOwner = Pawn(Owner);

	Owner.MakeNoise(PawnOwner.SoundDampening);
	GetAxes(PawnOwner.ViewRotation,X,Y,Z);
	StartTrace = Owner.Location + CalcDrawOffset() + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z; 
	AdjustedAim = PawnOwner.AdjustAim(1000000, StartTrace, 2*AimError, False, False);	
	EndTrace = StartTrace + Accuracy * (FRand() - 0.5 )* Y * 1000
		+ Accuracy * (FRand() - 0.5 ) * Z * 1000;
	X = vector(AdjustedAim);
	EndTrace += (10000 * X); 
	Other = PawnOwner.TraceShot(HitLocation,HitNormal,EndTrace,StartTrace);
	ProcessTraceHit(Other, HitLocation, HitNormal, X,Y,Z);
}*/

///////////////////////////////////////
// FireBulletInstantHit
///////////////////////////////////////

function FireBulletInstantHit(vector StartTrace, vector EndTrace, vector aimdir)
{
	local vector	HitLocation, HitNormal, X,Y,Z, OldLocation, TempLocation;
	local actor		Other;
	local Pawn		PawnOwner;
	local float		SmokeDS, Range, Damage, length;
	local	int			i;
	local	bool		bReduceSFX;
	local ut_SpriteSmokePuff s;
/*
	if (s_SWATGame(Level.Game) != None)
		bReduceSFX = s_SWATGame(Level.Game).bReduceSFX;
	else
	{
		bReduceSFX = true;
	}
*/
	SmokeDS = 0.6 + MaxWallPiercing / 24.0;
	Damage = MaxDamage;
	Range = MaxRange;

	PawnOwner = Pawn(Owner);

	GetAxes(PawnOwner.ViewRotation, X, Y, Z);

	Other = Trace(HitLocation, HitNormal, EndTrace, StartTrace, true);
	length = VSize(HitLocation - StartTrace);
	if ( (Other == None) || (length > MaxRange) )
		return;

	// Hit something
//	if ( Role == ROLE_Authority )
//	{
		Damage = Damage * ( (MaxRange - length / 2) / MaxRange );
		MakeNoise(Damage / 100);
		Other.TakeDamage(MaxDamage, instigator, HitLocation, Damage * 50 * AimDir, 'shot');
		//Other.TakeDamage(Damage, instigator, HitLocation, (Damage / 10 ) * AimDir, 'shot');

		if ( Other.bIsPawn )
		{
			Other.PlaySound(Sound'balle_PlayerHit', SLOT_None);
		}
		else
		{
			// wall hit
			if ( Other == Level )
			{
				if ( bHeavyWallHit )
					Other = Spawn(class'TO_HeavyWallHitEffect', self, , HitLocation, rotator(HitNormal));
				else
					Other = Spawn(class'TO_LightWallHitEffect', self, , HitLocation, rotator(HitNormal));
/*
				if ( Other != None )
				{
					if ( Frand() < 0.66 )
						Other.PlaySound(Sound'balle_hitwall1', SLOT_None);
					else
						Other.PlaySound(Sound'balle_hitwall2', SLOT_None);
				}
*/
			}
/*
			if ( !Level.bDropDetail && (!bReduceSFX || FRand() < 0.33) )
			{
				s = Spawn(class'ut_SpriteSmokePuff', self, , HitLocation, rotator(HitNormal));
				s.DrawScale = SmokeDS * FRand();
				s.RemoteRole = ROLE_None;
			}
*/
		}
//	} 
}


///////////////////////////////////////
// FireBullet
///////////////////////////////////////

function FireBullet(vector StartTrace, vector EndTrace, vector aimdir)
{
	local vector	HitLocation, HitNormal, X,Y,Z, OldLocation, TempLocation;
	local actor		Other, LastHit;
	local Pawn		PawnOwner;
	local float		Penetration, PenetratedDistance, SmokeDS, Range, Damage, length;
	local	int			i;
	local	bool		bReduceSFX;
	local ut_SpriteSmokePuff s;

	if (s_SWATGame(Level.Game) != None)
		bReduceSFX = s_SWATGame(Level.Game).bReduceSFX;
	else
	{
		bReduceSFX = true;
		//log("s_Weapon - FireBullet - SG == None !!");
	}

	SmokeDS = 0.6 + MaxWallPiercing / 24;
	Damage = MaxDamage;
	Range = MaxRange;

	PawnOwner = Pawn(Owner);

	GetAxes(PawnOwner.ViewRotation, X, Y, Z);

//	Penetration = MaxWallPiercing;
	LastHit = None;
	Other = Trace(HitLocation, HitNormal, EndTrace, StartTrace, true);
	length = VSize(HitLocation - StartTrace);
	if (Other == None || length > MaxRange)
		return;
//	while (i < 20  &&  Penetration > 0 && Other != None && Other != Owner)
//	{
//		i++;

/*		if ( (Other != Level && LastHit == Other) || (Other.IsA('s_Player') && s_Player(Other).bDead) || (Other.IsA('s_Bot') && s_Bot(Other).bDead) )
		{
			StartTrace = HitLocation + Other.CollisionRadius * AimDir;
			EndTrace = StartTrace + Range * AimDir;
			Other = Trace(HitLocation, HitNormal, EndTrace, StartTrace, true);
//			continue;
		} */

		// Hit something
		LastHit = Other;
		if ( Role == ROLE_Authority )
		{
			//Damage = Damage * (length / MaxRange);
			MakeNoise(Damage / 100);
			Other.TakeDamage(MaxDamage, instigator, HitLocation, Damage * 50 * AimDir, 'shot');
			//Other.TakeDamage(MaxDamage, instigator, HitLocation, (MaxDamage / 10 ) * AimDir, 'shot');

			if (Other.bIsPawn )
			{
				Other.PlaySound(Sound'balle_PlayerHit', SLOT_None);
			}
			else
			{
				// wall hit
				if (Other == Level)
				{
//					if (!bReduceSFX || FRand() < 0.5)
//					{
						if (bHeavyWallHit)
							Spawn(class'UT_HeavyWallHitEffect', self, , HitLocation, rotator(HitNormal));
						else
							Spawn(class'UT_LightWallHitEffect', self, , HitLocation, rotator(HitNormal));
//					}
/*
					if ( 	bHeavyWallHit && ((!bReduceSFX && FRand()<0.25) || FRand()<0.1))
						Spawn(class'UT_HeavyWallHitEffect', self, , Location, rotator(HitNormal));
					else
						Spawn(class'UT_LightWallHitEffect', self, , Location, rotator(HitNormal));
*/			}
				/*
				if (FRand() < 0.5)
					Other.PlaySound(Sound 'balle_hitwall1',, 4.0,,100);
				else
					Other.PlaySound(Sound 'balle_hitwall2',, 4.0,,100);
				*/
				if (!Level.bDropDetail && (!bReduceSFX || FRand() < 0.50))
				{
					s = Spawn(class'ut_SpriteSmokePuff', self, , HitLocation, rotator(HitNormal));
					s.DrawScale = SmokeDS * FRand();
					s.RemoteRole = ROLE_None;
				}
			}

		} 

		// Penetration
/*		OldLocation = HitLocation;
		TempLocation = HitLocation + AimDir * Penetration;
		Other = Trace(HitLocation, HitNormal, OldLocation, TempLocation, true);
		PenetratedDistance = VSize(OldLocation  - HitLocation);
		if ( PenetratedDistance > 0.3 && PenetratedDistance < Penetration && Other == LastHit)
		{

			if (Other.IsA('Pawn') )
			{
				//Other.PlaySound(Sound'balle_PlayerHit', SLOT_None);
				Penetration -= PenetratedDistance / 3.0;
			}
			else
			{
				// Back wall hit
				Penetration -= PenetratedDistance / 2.0;

				Spawn(class'UT_LightWallHitEffect', self, , Location, rotator(HitNormal));
*/				/*if (FRand() < 0.5)
					PlaySound(Sound 'balle_hitwall1',, 4.0,,100);
				else
					PlaySound(Sound 'balle_hitwall2',, 4.0,,100); */

/*				if (!bReduceSFX || (bReduceSFX && FRand() < 0.25) ) 
				{
					s = Spawn(class'ut_SpriteSmokePuff', self, , HitLocation, rotator(HitNormal));
					s.DrawScale = SmokeDS * FRand();
					s.RemoteRole = ROLE_None;
				}

			}
			
			StartTrace = HitLocation;
			EndTrace = StartTrace + MaxRange * AimDir;
			Other = Trace(HitLocation, HitNormal, EndTrace, StartTrace, true);
		}
		else
		{
			Penetration = 0;
			i = 50;
			break;
		}

	}
*/
}


///////////////////////////////////////
// Recoil
///////////////////////////////////////

final simulated function Recoil()
{
	local float				RecoilYaw;
	local	PlayerPawn	PO;
	local	float				VH, VV;
	local	vector			v;

	//return;

	if ( PlayerPawn(Owner) == None /*|| Level.NetMode == NM_DedicatedServer*/) 
		return;

	//log("recoil");

	PO = PlayerPawn(Owner);
	
	// Tweak Player aiming
	v = PO.Velocity;
	v.z = 0;

	VV = 1 + Abs(PO.Velocity.Z) / 150.0;
	VH = 1 + VSize(V) / 200.0;
 
	RecoilVal = 1.0;
	//RecoilVal += RecoilVal * VSize(PO.Velocity) / 300;

	if ( (Shotcount < 2) || (rPower == 0) )
		rPower = 0.8;

	if ( PO.bPressedJump )
		RecoilVal = 1.0 +  FRand();

  if ( !((PO.ViewRotation.Pitch > 17000) && (PO.ViewRotation.Pitch < 48000)) )
    PO.ViewRotation.Pitch += RecoilVal * VRecoil * rPower * VV;

	if ( (HRecoil > 0.0) && (ShotCount > 0) )
	{
		RecoilYaw = FRand();
		if (RecoilYaw > 0.5)
      PO.ViewRotation.Yaw += RecoilVal * HRecoil * rPower * VH;
		else
      PO.ViewRotation.Yaw -= RecoilVal * HRecoil * rPower * VH;
	}

	if ( rPower < 1.5 )
		rPower += 0.2;
}


///////////////////////////////////////
// Active
///////////////////////////////////////

state Active
{
	ignores animend;

	function BeginState()
	{
		//log("s_Weapon::Active::BeginState");
		SetSkins();
		Super.BeginState();
	}

Begin:
	SetSkins();
	FinishAnim();
	if ( bChangeWeapon )
		GotoState('DownWeapon');

	bWeaponUp = true;
	PlayPostSelect();
	FinishAnim();
	//bCanClientFire = true;

	if ( !Owner.IsA('PlayerPawn') && bUseClip && (clipammo < 1) && ValidReloadOwner())
	{
		if ( RemainingClip > 0 )
		{
			//ForceClientReloadWeapon();
			s_ReloadW(); 
		}
	}
	else if ( (Level.Netmode != NM_Standalone) && Owner.IsA('TournamentPlayer')
		&& (PlayerPawn(Owner).Player != None) && !PlayerPawn(Owner).Player.IsA('ViewPort') )
	{
		if ( !bChangeWeapon )
			TournamentPlayer(Owner).UpdateRealWeapon(self);
	} 

	Finish();
}


///////////////////////////////////////
// ClientActive
///////////////////////////////////////

State ClientActive
{
	
	simulated function ForceClientFire()
	{
		//log("s_Weapon::ClientActive::ForceClientFire");
		Global.ClientFire(0);
	}

	simulated function ForceClientAltFire()
	{
		//Global.ClientAltFire(0);
	}
	
	simulated function bool ClientFire(float Value)
	{
		//bForceFire = true;
		//return bForceFire;
		return false;
	}

	simulated function bool ClientAltFire(float Value)
	{
		//bForceAltFire = true;
		//return bForceAltFire;
		return false;
	}

	simulated function AnimEnd()
	{
		if ( Owner == None )
		{
			Global.AnimEnd();
			GotoState('');
		}
		else if ( Owner.IsA('TournamentPlayer') 
			&& (TournamentPlayer(Owner).ClientPending != None) )
			GotoState('ClientDown');
		else if ( bWeaponUp )
		{
			/*if ( (bForceFire || (PlayerPawn(Owner).bFire != 0)) && Global.ClientFire(0) )
				return;
			else if ( (bForceAltFire || (PlayerPawn(Owner).bAltFire != 0)) && Global.ClientAltFire(0) )
				return;
			*/
			PlayIdleAnim();
			GotoState('');
		}
		else
		{
			PlayPostSelect();
			bWeaponUp = true;
		}
	}

	simulated function BeginState()
	{
		SetSkins();
		bForceFire = false;
		bForceAltFire = false;
		bWeaponUp = false;
		PlaySelect();
		if ( (Level.NetMode != NM_DedicatedServer) && (s_BPlayer(Owner) != None) && s_BPlayer(Owner).bSZoom )
			s_BPlayer(Owner).ToggleSZoom();
	}

	simulated function EndState()
	{
		bForceFire = false;
		bForceAltFire = false;
	}
}


simulated function PlayPostSelect()
{
	if (Owner.IsA('s_Player'))
		s_Player(Owner).CalculateWeight();
	else if (Owner.IsA('s_Bot'))
		s_Bot(Owner).CalculateWeight();
	else if (Owner.IsA('s_NPC'))
		s_NPC(Owner).CalculateWeight();

	if ( (Level.NetMode != NM_DedicatedServer) && (s_BPlayer(Owner) != None) && s_BPlayer(Owner).bSZoom )
		s_BPlayer(Owner).ToggleSZoom();

	if ( Level.NetMode == NM_Client )
	{
		if ( PlayerPawn(Owner).bFire != 0 )
		{
			ForceServerFire();
			Global.ClientFire(0);
			return;
		}
		//else if ( (PlayerPawn(Owner).bAltFire != 0)) && Global.ClientAltFire(0) )
		//	return;

		GotoState('');
		AnimEnd();
	}
}


final function ForceServerFire()
{
	Fire(0);
}


///////////////////////////////////////
// Idle
///////////////////////////////////////

state Idle
{
	function AnimEnd()
	{
		//PlayIdleAnim();
		ForceIdleFrame();
	}

	function Timer()
	{
		PlayIdleAnim();
		SetTimer(10 + 5*FRand(), true);
	}

	function EndState()
	{
		//log("s_Weapon::Idle::EndState");

		SetTimer(0, false);
		Super.EndState();
	}
 
	function bool PutDown()
	{
		GotoState('DownWeapon');
		return true;
	}

	function BeginState()
	{
		//log("s_Weapon::Idle::BeginState");

		ForceIdleFrame();
		SetTimer(1.0, true);
	}

	Begin:
	if ( bUseFireModes && (FireModes[CurrentFireMode] == FM_FullAuto) )
	{
		// Fire
		if ( Pawn(Owner).bFire != 0 )
		{	 
			if ( bUseClip )
			{
				if ( ClipAmmo > 0 ) 
				{
					//bCanClientFire = true;
					//
					ClientForceFire();
					Global.Fire(0.0);
				}
				else 
				{
					// No ammo left
					if ( EmptyClipSound != None )
						PlayOwnedSound(EmptyClipSound, SLOT_None, Pawn(Owner).SoundDampening);
				
					// Auto reload
					if ( (RemainingClip > 0) && ValidReloadOwner() )
					{
						//ForceClientReloadWeapon();
						s_ReloadW();
					}
					else if ( !Owner.IsA('s_BPlayer') ) 
						Pawn(Owner).SwitchToBestWeapon();  //Goto Weapon that has Ammo
				}
			}
			else
			{
				//bCanClientFire = true;
				ClientForceFire();
				Global.Fire(0.0);
			}
		}

		// AltFire
		//if ( Pawn(Owner).bAltFire != 0 ) 
		//	Global.AltFire(0.0);
	}

	//PlayIdleAnim();
	bPointing = false;

	if ( !Owner.IsA('s_BPlayer') && bUseClip && (ClipAmmo < 1) && ValidReloadOwner() )
	{ 
		if ( RemainingClip > 0 )
		{ 
			//ForceClientReloadWeapon();
			s_ReloadW();
		}
		else 
			Pawn(Owner).SwitchToBestWeapon();  //Goto Weapon that has Ammo
	}
	//ForceIdleFrame();
	//Disable('AnimEnd');	
}


///////////////////////////////////////
// PlayIdleAnim
///////////////////////////////////////

simulated function PlayIdleAnim()
{
	PlayAnim('idle', 1.0, 0.5);
}


///////////////////////////////////////
// ForceIdleFrame
///////////////////////////////////////

simulated function ForceIdleFrame()
{
	//PlayIdleAnim();
	PlayIdleAnim();
}


///////////////////////////////////////
// UseAmmo
///////////////////////////////////////

function bool UseAmmo(int n)
{
	// Bot needs ammo?!
	if ( (s_Bot(Owner) != None) && (RemainingClip <= 0.1 * MaxClip) 
		&& !s_Bot(Owner).IsInState('BotBuying') && s_Bot(Owner).Objective != 'O_FindClosestBuyPoint')
	{
		//log("Bot needs ammo ! "$Owner);
		s_Bot(Owner).bNeedAmmo = true;
	}

	if ( bUseClip && (clipammo >= n) )
	{
		ClipAmmo -= n;
		return true;
	}
	else
		return false;
}


///////////////////////////////////////
// ForceClientReloadWeapon
///////////////////////////////////////
// Force reloading
function ForceClientReloadWeapon()
{
	//log("s_Weapon::ForceClientReloadWeapon");

	if ( Owner.IsA('s_BPlayer') )
		s_BPlayer(Owner).ClientReloadW();
/*
	if ( Role == Role_Authority )
		return;

	

//	PlayReloadWeapon();

//	GotoState('ClientReloadWeapon');
	s_ReloadW();
*/
}


///////////////////////////////////////
// s_ReloadW
///////////////////////////////////////

simulated function s_ReloadW()
{
	if ( !bUseClip )
		return;
/*	if ( bUseClip )
	{
		if ( (ClipAmmo != ClipSize) && (RemainingClip > 0) )
			GotoState('ReloadWeapon');
	}
*/
	//log("s_Weapon::s_ReloadW");

	PlayReloadWeapon();

	if ( Role == Role_Authority )
	{
		ForceClientReloadWeapon();
		GotoState('ServerReloadWeapon');
	}
	else
		GotoState('ClientReloadWeapon');
}


///////////////////////////////////////
// sReloadWeapon
///////////////////////////////////////

function sReloadWeapon()
{
	if ( bUseClip && (RemainingClip > 0) )
	{
		//log("s_Weapon::sReloadWeapon");

		//bNeedFix = true;
		clipammo = clipsize;
		RemainingClip--;

		// Bots can attack again.
		if ( Bot(Owner) != None )
			Bot(Owner).bReadyToAttack = true;
	}
}


///////////////////////////////////////
// PlayReloadWeapon
///////////////////////////////////////

simulated function PlayReloadWeapon()
{
	//log("s_Weapon::PlayReloadWeapon");

	if ( (aReloadWeapon.AnimSeq != '') && HasAnim(aReloadWeapon.AnimSeq) )
		PlayAnim(aReloadWeapon.AnimSeq, aReloadWeapon.AnimRate);

//	if ( aReloadWeapon.AsscSound != None )
//		PlayOwnedSound(aReloadWeapon.AsscSound, SLOT_None, 255);
}


///////////////////////////////////////
// ChangeFireMode
///////////////////////////////////////

simulated function ChangeFireMode()
{
	//log("s_Weapon::ChangeFireMode");

//	if ( !bUseFireModes )
//		return;

	if ( DoChangeFireMode() )
	{
		PlayChangeFireMode();
	}
} 


///////////////////////////////////////
// DoChangeFireMode
///////////////////////////////////////

simulated function bool DoChangeFireMode()
{
	local	EFireModes	CurrentMode, OldMode;

	//log("s_Weapon::DoChangeFireMode");

	OldMode = FireModes[CurrentFireMode];
	CurrentFireMode++;
	if ( FireModes[CurrentFireMode] == FM_None )
		CurrentFireMode = 0;

	CurrentMode = FireModes[CurrentFireMode];

	if ( OldMode == CurrentMode )
	{
		//log("s_Weapon::DoChangeFireMode - Same mode, exit");
		return false;
	}

	//bNeedFix = true;

	switch ( CurrentMode )
	{
		case FM_SingleFire	:	// Semi Auto
								//log("s_Weapon::DoChangeFireMode - FM_SingleFire");
								if ( bSingleFireBasedROF )
									RoundPerMin = Default.RoundPerMin;
								else
									RoundPerMin = Default.RoundPerMin * 0.50;

								if ( bTracingBullets )
									TraceFrequency = 1;
								
								BurstRoundnb = 1;
								BurstRoundCount = 1;
								FirePause = 0.3;
								RecoilMultiplier = Default.RecoilMultiplier * 0.80;
								VRecoil = Default.VRecoil * 0.80;
								HRecoil = Default.HRecoil * 0.80;
								break;

		case FM_BurstFire	:		// (3 round burst fire)
								//log("s_Weapon::DoChangeFireMode - FM_BurstFire");
								if ( bSingleFireBasedROF )
									RoundPerMin = Default.RoundPerMin * 2.00;
								else
									RoundPerMin = Default.RoundPerMin * 1.00;
								
								if ( bTracingBullets )
									TraceFrequency = 3;
								
								BurstRoundnb = 3;
								BurstRoundCount = 1;
								FirePause = 0.5;
								RecoilMultiplier = Default.RecoilMultiplier * 1.5;
								VRecoil = Default.VRecoil * 1.1;
								HRecoil = Default.HRecoil * 1.25;
								break;

		case FM_FullAuto :
		default :
								//log("s_Weapon::DoChangeFireMode - FM_FullAuto");
								if ( bSingleFireBasedROF )
									RoundPerMin = Default.RoundPerMin * 2.00;
								else
									RoundPerMin = Default.RoundPerMin;
								
								//bTracingBullets = true;
								if ( bTracingBullets )
									TraceFrequency = Default.TraceFrequency;
								BurstRoundnb = 0;
								FirePause = 0.0;
								RecoilMultiplier = Default.RecoilMultiplier;
								VRecoil = Default.VRecoil;
								HRecoil = Default.HRecoil;
								break;
	}

	if ( Owner.IsA('s_BPlayer') && (Role == Role_Authority) )
		Pawn(Owner).ReceiveLocalizedMessage(class's_WeaponMessages', int(CurrentMode) );

	return true;
}


///////////////////////////////////////
// PlayChangeFireMode
///////////////////////////////////////

simulated function PlayChangeFireMode()
{
	PlaySound(Sound'swfiremde', SLOT_None);
}


///////////////////////////////////////
// BotDesireability 
///////////////////////////////////////

event float BotDesireability(Pawn Bot)
{
	local	Inventory	Inv;

	if ( Bot == None )
		return 0.0;

	if ( Bot.Inventory == None )
			return MaxDesireability * 2.0;
/*
	if (!Level.Game.IsA('s_SWATGame'))
		return MaxDesireability;
*/
	if ( Bot.IsA('s_NPC') )
		return 0.0;

	else if ( Bot.IsA('s_Bot') )
	{
		for( Inv = Bot.Inventory; Inv != None; Inv = Inv.Inventory )
		{	 
			if ( Inv.IsA('s_Weapon') && (s_Weapon(Inv).WeaponClass == WeaponClass) )
			{
				if ( Inv.Class == Class )
				{ 
					if ( s_Weapon(Inv).bUseClip && (s_Weapon(Inv).RemainingClip < s_Weapon(Inv).MaxClip) )
						return MaxDesireability;
					else
						return 0.0;
				}
				else if ( Level.Game.IsA('s_SWATGame') )
					return 0.0;
			}
		}
		return MaxDesireability;
	}

	return Super.BotDesireability(Bot);
}


///////////////////////////////////////
// SpawnCopy
///////////////////////////////////////
// Either give this inventory to player Other, or spawn a copy
// and give it to the player Other, setting up original to be respawned.
// Also add Ammo to Other's inventory if it doesn't already exist
//
function inventory SpawnCopy( pawn Other )
{
	local inventory Copy;
	local Weapon newWeapon;

	if ( Level.Game.ShouldRespawn(self) )
	{
		Copy = spawn(Class,Other,,,rot(0,0,0));
		Copy.Tag           = Tag;
		Copy.Event         = Event;
		if ( !bWeaponStay )
			GotoState('Sleeping');
	}
	else
		Copy = self;

	Copy.RespawnTime = 0.0;
	Copy.bHeldItem = true;
	Copy.bTossedOut = false;
	Copy.GiveTo( Other );
	newWeapon = Weapon(Copy);
	newWeapon.Instigator = Other;
	newWeapon.GiveAmmo(Other);
	newWeapon.SetSwitchPriority(Other);
	//if ( !Other.bNeverSwitchOnPickup )
	if ( !Other.IsA('s_BPlayer') )
		newWeapon.WeaponSet(Other);
	newWeapon.AmbientGlow = 0;
	return newWeapon;
}


///////////////////////////////////////
// DropFrom
///////////////////////////////////////

function DropFrom(vector StartLocation)
{
	// Cannot drop weapon, destroy it instead!
	if ( bNoDrop )
	{
		//log("s_Weapon::DropFrom - bNoDrop - Destroying weapon!");
		return;
		//Destroy();
	}

	// Fix UT bug
	bTossedOut = true;
	bHeldItem = false;

	AIRating = Default.AIRating;
/*
	log("s_Weapon - DropFrom");
	if (!Pawn(Owner).DeleteInventory( Self ) )
		log("s_Weapon - DropFrom - Couldn't delete from inventory.");
*/
	Super.DropFrom( StartLocation );
}


///////////////////////////////////////
// TweenToStill
///////////////////////////////////////

simulated function TweenToStill()
{
	TweenAnim('IDLE', 0.1);
}


///////////////////////////////////////
// Pickup
///////////////////////////////////////

auto state Pickup
{
	ignores Fire, AltFire, s_ReloadW/*, ChangeFireMode*/;

	singular function ZoneChange( ZoneInfo NewZone )
	{
		local float splashsize;
		local actor splash;

		if( NewZone != None && NewZone.bWaterZone && !Region.Zone.bWaterZone ) 
		{
			splashSize = 0.000025 * Mass * (250 - 0.5 * Velocity.Z);
			if ( NewZone.EntrySound != None )
				PlaySound(NewZone.EntrySound, SLOT_Interact, splashSize);
			if ( NewZone.EntryActor != None )
			{
				splash = Spawn(NewZone.EntryActor); 
				if ( splash != None )
					splash.DrawScale = 2 * splashSize;
			}
		}
	}

	// Validate touch, and if valid trigger event.
	function bool ValidTouch( actor Other )
	{
		local Actor A;

		if ( Other.IsA('s_NPC') && !s_NPC(Other).bCanUseWeapon )
			return false;

		if( Other.bIsPawn && Pawn(Other).bIsPlayer && (Pawn(Other).Health > 0) && Level.Game.PickupQuery(Pawn(Other), self) )
		{
			if( Event != '' )
				foreach AllActors( class 'Actor', A, Event )
					A.Trigger( Other, Other.Instigator );
			return true;
		}
		return false;
	}
		
	// When touched by an actor.
	function Touch( actor Other )
	{
/*		if (Pawn(Other) != None && Pawn(Other).MoveTarget == self )
			Pawn(Other).MoveTimer = -1.0;	

		if (s_Bot(Other) != None && s_Bot(Other).OrderObject == Self)
			s_Bot(Other).OrderObject = None;
*/
		// If touched by a player pawn, let him pick this up.
		if( ValidTouch(Other) )
		{
			if (Level.Game.LocalLog != None)
				Level.Game.LocalLog.LogPickup(Self, Pawn(Other));
			if (Level.Game.WorldLog != None)
				Level.Game.WorldLog.LogPickup(Self, Pawn(Other));
			
			SpawnCopy(Pawn(Other));
			
			if ( PickupMessageClass == None )
				Pawn(Other).ClientMessage(PickupMessage, 'Pickup');
			else
				Pawn(Other).ReceiveLocalizedMessage( PickupMessageClass, 0, None, None, Self.Class );
			
			PlaySound (PickupSound);		

			if (Other.IsA('s_Bot'))
				WeaponSet(s_Bot(Other));

			if ( Level.Game.Difficulty > 1 )
				Other.MakeNoise(0.1 * Level.Game.Difficulty);
			if ( Pawn(Other).MoveTarget == self )
				Pawn(Other).MoveTimer = -1.0;	
			if (Other.IsA('s_NPC'))
				s_NPC(Other).WhatToDoNext('','');
			return;
		}

		if (Pawn(Other) != None && Pawn(Other).MoveTarget == self )
			Pawn(Other).MoveTimer = -1.0;	
/*		
		if ( !Level.Game.IsA('s_SWATGame') && bTossedOut && (Other.Class == Class) )
//				&& Inventory(Other).bTossedOut )
				Destroy();
*/
	}

	// Landed on ground.
	function Landed(Vector HitNormal)
	{
		local rotator newRot;
		newRot = Rotation;
		newRot.pitch = 0;
		SetRotation(newRot);
		SetTimer(2.0, false);
	}

	// Make sure no pawn already touching (while touch was disabled in sleep).
	function CheckTouching()
	{
		local int i;

		bSleepTouch = false;
		for ( i=0; i<4; i++ )
			if ( (Touching[i] != None) && Touching[i].IsA('Pawn') )
				Touch(Touching[i]);
	}

	function Timer()
	{
		if ( RemoteRole != ROLE_SimulatedProxy )
		{
			NetPriority = 1.4;
			RemoteRole = ROLE_SimulatedProxy;
			if ( bHeldItem )
			{
				if ( bTossedOut )
					SetTimer(15.0, false);
				else
					SetTimer(40.0, false);
			}
			return;
		}

		if ( bHeldItem )
		{
			//if (  (FRand() < 0.1) || !PlayerCanSeeMe() )
			//	Destroy();
			//else
				SetTimer(3.0, true);
		}
	}

	function BeginState()
	{
		BecomePickup();
		bCollideWorld = true;
		if ( bHeldItem )
			SetTimer(30, false);
		else if ( Level.bStartup )
		{
			bAlwaysRelevant = true;
			NetUpdateFrequency = 8;
		}
	}

	function EndState()
	{
		bCollideWorld = false;
		bSleepTouch = false;
	}

Begin:
	BecomePickup();

Dropped:
/*	if( bAmbientGlow )
		AmbientGlow=255;*/
	if( bSleepTouch )
		CheckTouching();
}


///////////////////////////////////////
// ClientPutDown
///////////////////////////////////////

simulated function ClientPutDown(weapon NextWeapon)
{
	if ( (Level.NetMode != NM_DedicatedServer) && (s_BPlayer(Owner) != None) && s_BPlayer(Owner).bSZoom )
		s_BPlayer(Owner).ToggleSZoom();

	Super.ClientPutDown(NextWeapon);
}


State ClientDown
{
	simulated function BeginState()
	{
		if ( (Level.NetMode != NM_DedicatedServer) && (s_BPlayer(Owner) != None) && s_BPlayer(Owner).bSZoom )
			s_BPlayer(Owner).ToggleSZoom();

		Disable('Tick');
	}
}

///////////////////////////////////////
// DownWeapon
///////////////////////////////////////

State DownWeapon
{
ignores Fire, AltFire, AnimEnd;

	function BeginState()
	{
		if ( (Level.NetMode != NM_DedicatedServer) && (s_BPlayer(Owner) != None) && s_BPlayer(Owner).bSZoom )
			s_BPlayer(Owner).ToggleSZoom();

		bChangeWeapon = false;
		bMuzzleFlash = 0;
		Pawn(Owner).ClientPutDown(self, Pawn(Owner).PendingWeapon);
		//bCanClientFire = false;

		// Weight check
		if (Owner.IsA('s_Player'))
			s_Player(Owner).CalculateWeight();
		else if (Owner.IsA('s_Bot'))
			s_Bot(Owner).CalculateWeight();
		else if (Owner.IsA('s_NPC'))
			s_NPC(Owner).CalculateWeight();
	}

Begin:
	TweenDown();
	FinishAnim();
	Pawn(Owner).ChangedWeapon();
}


///////////////////////////////////////
// RecommendWeapon
///////////////////////////////////////

function Weapon RecommendWeapon( out float rating, out int bUseAltMode )
{
	local Weapon Recommended;
	local float oldRating, oldFiring;
	local int oldMode;

	if ( Owner.IsA('PlayerPawn') )
		rating = SwitchPriority();
	else
	{
		rating = RateSelf(bUseAltMode);
		if ( (self == Pawn(Owner).Weapon) && (Pawn(Owner).Enemy != None) && Self.WeaponClass != 0)
		{
			if ( !(bUseAmmo && (clipammo == 0) && (remainingclip == 0)) )
				rating += 0.21; // tend to stick with same weapon
		}
	}
	if ( inventory != None )
	{
		Recommended = inventory.RecommendWeapon(oldRating, oldMode);
		if ( (Recommended != None) && (oldRating > rating) )
		{
			rating = oldRating;
			bUseAltMode = oldMode;
			return Recommended;
		}
	}
	return self;
}


///////////////////////////////////////
// RateSelf
///////////////////////////////////////

function float RateSelf( out int bUseAltMode )
{
	if ( (ClipAmmo <= 0) && (RemainingClip == 0) )
		return -2;

	bUseAltMode = 0;

	return AIRating;
}


///////////////////////////////////////
// SwitchPriority
///////////////////////////////////////

function float SwitchPriority()
{
	if ( bUseClip && (ClipAmmo == 0) && (RemainingClip == 0) )
		return -5;
	else return Super.SwitchPriority();
}


///////////////////////////////////////
// BecomeItem
///////////////////////////////////////

simulated function BecomeItem()
{
	LifeSpan = 0.0;
	Super.BecomeItem();
}


///////////////////////////////////////
// ServerReloadWeapon
///////////////////////////////////////

state ServerReloadWeapon
{
	ignores s_ReloadW, ChangeFireMode;

	function Fire(float F) {}
	function AltFire(float F) {}

	function BeginState()
	{
		//log("s_Weapon::ServerReloadWeapon::BeginState");
		bCanThrow = false;
		bReloadingWeapon = true;
		//bCanClientFire = false;

		if ( (Level.NetMode != NM_DedicatedServer) && (s_BPlayer(Owner) != None) && s_BPlayer(Owner).bSZoom )
			s_BPlayer(Owner).ToggleSZoom();

		sReloadWeapon();
	}

	function EndState()
	{
		bCanThrow = true;
		bReloadingWeapon = false;
	}

	function AnimEnd()
	{
		//log("s_Weapon::ServerReloadWeapon::AnimEnd");

		bReloadingWeapon = false;
		//bCanClientFire = true;

		finish();
	}

Begin:
	sleep(0.0);
}


///////////////////////////////////////
// ClientReloadWeapon
///////////////////////////////////////

state ClientReloadWeapon
{
	ignores s_ReloadW, ChangeFireMode;

	simulated function ForceClientFire()
	{
		//log("s_Weapon::ClientReloadWeapon::ForceClientFire");
		Global.ClientFire(0);
	}

	simulated function bool ClientFire( float Value ) { return false; }
	simulated function bool ClientAltFire( float Value ) { return false; }

	simulated function BeginState()
	{
		//log("s_Weapon::ClientReloadWeapon::BeginState");
		
		bReloadingWeapon = true;

		if ( (s_BPlayer(Owner) != None) && s_BPlayer(Owner).bSZoom )
			s_BPlayer(Owner).ToggleSZoom();
	}

	simulated function EndState()
	{
		bReloadingWeapon = false;
	}

	simulated function AnimEnd()
	{
		//log("s_Weapon::ClientReloadWeapon::AnimEnd");
		
		bReloadingWeapon = false;

		if ( Owner == None )
			return;

		// Here to make sure Lag does not disable client firing animations
		//bCanClientFire = true;
		if ( (Pawn(Owner).bFire != 0) && bUseFireModes && (FireModes[CurrentFireMode] == FM_FullAuto) )
		{
			if ( bUseClip )
			{
				if ( ClipAmmo > 0 ) 
					ForceClientFire();
				else 
				{
					// No ammo left
					if ( EmptyClipSound != None )
						PlayOwnedSound(EmptyClipSound, SLOT_None, Pawn(Owner).SoundDampening);
				}
			}
			else
				ForceClientFire();
		}
		else
		{
			PlayIdleAnim();
			GotoState('');
		}
	}

}


///////////////////////////////////////
// ForceIdle
///////////////////////////////////////

state ForceIdle
{
//	ignores all;

Begin:
	sleep(0.1);
	bNeedFix = false;
	PlayIdleAnim();
	//AnimSequence='Idle';
	FinishAnim();
	Finish();
}


///////////////////////////////////////
// PlayAmbientSound
///////////////////////////////////////

final simulated function PlayAmbientSound()
{
	AmbientSound = Misc1Sound;
}


///////////////////////////////////////
// PlayAmbientFinal
///////////////////////////////////////

final Simulated function PlayAmbientFinal()
{
	AmbientSound = None;
	
	// Avoid replicating this one online.
	if ( (Level.NetMode == NM_StandAlone) || (Role < Role_Authority) )
	{
		if ( Misc2Sound != None )
			PlayOwnedSound(Misc2Sound, SLOT_None, 255);
	}
}


///////////////////////////////////////
// PlayWeaponSound
///////////////////////////////////////

final simulated function PlayWeaponSound(Sound daSound)
{
	//log("s_Weapon::PlayWeaponSound"@daSound);
/*
	if ( (Role == Role_Authority) && (s_SWATGame(Level.Game).LocalPlayer != None) )
	{
		//log("s_Weapon::PlayWeaponSound - ClientHearSound");
		s_SWATGame(Level.Game).LocalPlayer.ClientHearSound(Owner, 0, daSound, Owner.location, Vect(400.0, 0.0, 100.0)); 
	}
	else if ( Level.NetMode != NM_DedicatedServer )	
	{
		//log("s_Weapon::PlayWeaponSound - PlaySound");
		PlaySound(daSound, SLOT_None, 4.0);
	}
	*/
	
	//if ( Role == Role_Authority )
	//	PlaySound(daSound, SLOT_None, 4.0);
	if ( Level.NetMode != NM_DedicatedServer )
		PlayOwnedSound(daSound, SLOT_None, 255);
}


///////////////////////////////////////
// AnimFire
///////////////////////////////////////

final simulated function AnimFire()
{
	//log("s_Weapon::AnimFire");
	//log("ShotCount:"@ShotCount);

	if ( FireModes[CurrentFireMode] == FM_SingleFire || ShotCount == 1 )
	{
		if ( Level.NetMode != NM_DedicatedServer )
			PlayOwnedSound(FireSound, SLOT_None, 255);
	}
	else
	{
		PlayOwnedSound(FireSound, SLOT_None, 255);
	}
		//PlayWeaponSound(FireSound);
}


///////////////////////////////////////
// sServerFire
///////////////////////////////////////

state sServerFire
{
	ignores s_ReloadW, ChangeFireMode;

	function Fire(float F) {}
	function AltFire(float F) {}
/*
	function Tick( float DeltaTime )
	{
		if ( Owner == None ) 
			AmbientSound = None;
	}
*/
	function BeginState()
	{
		//if ( bUseFireModes && (FireModes[CurrentFireMode] == FM_FullAuto) && (Misc1Sound != None) )
		//	PlayAmbientSound();

		//log("s_Weapon::sServerFire::BeginState");
		
		SetAimError();

		BurstRoundCount = 1;
		ShotCount = 1;

		if ( bShowWeaponLight && HasHighROF() )
		{
			bSteadyFlash3rd = true;
			LightType = LT_Steady;
		}

		DoFire();
	}	

	function DoFire()
	{
		//log("s_Weapon::sServerFire::DoFire");
		ShotCount++;
		if ( bShowWeaponLight )
			FlashCount++;

		GenerateBullet();
		//CheckVisibility();
	}

	function EndState()
	{
		//log("s_Weapon::sServerFire::EndState");
		
		//if ( AmbientSound != None )
		//	PlayAmbientFinal();

		OldFlashCount = FlashCount;
		bSteadyFlash3rd = false;
		LightType = LT_None;
		ShotCount = 1;
		rPower = 0.8;
	}

	function AnimEnd()
	{
		//log("s_Weapon::sServerFire::AnimEnd");

		// Single fire
		if ( !bUseFireModes || (FireModes[CurrentFireMode] == FM_SingleFire) )
		{
			//log("s_Weapon::sServerFire::AnimEnd - FM_SingleFire break");
			
			//bNeedFix = true;
			finish();
			return;
		}

		// Burst fire
		if ( BurstRoundnb > 0 )
		{
			BurstRoundCount++;
			if ( BurstRoundCount > BurstRoundnb )
			{
				//log("s_Weapon::sServerFire::AnimEnd - Burst break");
				
				//BurstRoundCount = 1;				
				//bNeedFix = true;
				//FinishAnim();
				finish();
				return;
			}
		}

		// repeat firing
		if ( (ClipAmmo > 0) && ( (FireModes[CurrentFireMode] == FM_BurstFire) 
			|| ( (FireModes[CurrentFireMode] == FM_FullAuto) && (Owner != None) && (Pawn(Owner).bFire != 0)) ))
		{
			//log("s_Weapon::sServerFire::AnimEnd - AutoFire continue");
			
			PlayFiring();
			DoFire();
		}
		else
		{
			//log("s_Weapon::sServerFire::AnimEnd - no fire mode specific break");
			
			//bNeedFix = true;
			finish();
		}
	}

Begin:
	//log("s_Weapon::sServerFire::Begin");
	Sleep(0.0);	
}


///////////////////////////////////////
// sClientFire
///////////////////////////////////////

state sClientFire
{
	ignores ChangeFireMode;

	simulated function bool ClientFire( float Value ) 
	{ //log("s_Weapon::sClientFire::ClientFire - return false!"); 
		return false; }

	simulated function bool ClientAltFire( float Value ) 
	{ //log("s_Weapon::sClientFire::ClientAltFire - return false!"); 
		return false; }

/*	
	simulated function s_ReloadW() { 
		//log("s_Weapon::sClientFire::s_ReloadW"); 
	}
*/
/*
	simulated function ForceClientReloadWeapon()
	{
		if ( Role == Role_Authority )
			return;

		//log("s_Weapon::sClientFire::ForceClientReloadWeapon - calling Global.s_ReloadW();");
		Global.s_ReloadW();
	}
*/
	simulated function BeginState()
	{
		//log("s_Weapon::sClientFire::BeginState");
		BackClipAmmo = ClipAmmo-1;
		//if ( bUseFireModes && (FireModes[CurrentFireMode] == FM_FullAuto) && (Misc1Sound != None) )
		//	PlayAmbientSound();
	}

	simulated function EndState()
	{
		//log("s_Weapon::sClientFire::EndState");

		rPower = 0.8;
		//if ( AmbientSound != None )
		//	PlayAmbientFinal();
	}

	simulated function AnimEnd()
	{
		//log("s_Weapon::sClientFire::AnimEnd");
		//log("BurstRoundnb:"@BurstRoundnb@"BurstRoundCount:"@BurstRoundCount);

		// Single fire
		if ( !bUseFireModes || (FireModes[CurrentFireMode] == FM_SingleFire) )
		{
			//log("s_Weapon::sClientFire::AnimEnd - FM_SingleFire break");
			
			PlayIdleAnim();
			GotoState('');
			return;
		}

		// Burst fire
		if ( BurstRoundnb > 0 )
		{
			BurstRoundCount++;
			if ( BurstRoundCount > BurstRoundnb )
			{
				//log("s_Weapon::sClientFire::AnimEnd - Burst break");
				BurstRoundCount = 1;	
				PlayIdleAnim();
				GotoState('');
				return;
			}
		}

		// repeat firing
		if ( (BackClipAmmo > 0) && ( (FireModes[CurrentFireMode] == FM_BurstFire) 
			|| ( (FireModes[CurrentFireMode] == FM_FullAuto) && (Owner != None) && (Pawn(Owner).bFire != 0)) ))
		{
			//log("s_Weapon::sClientFire::AnimEnd - AutoFire continue");
			
			PlayFiring();
			ShotCount++;
			BackClipAmmo--;
		}
		else
		{
			//log("s_Weapon::sClientFire::AnimEnd - no fire mode specific break");
			
			PlayIdleAnim();
			GotoState('');
		}
	}
}


///////////////////////////////////////
// defaultproperties
///////////////////////////////////////
//  MaxModes=2
//  Modes(1)=(Type=1)
// bOwnsCrosshair=true

defaultproperties
{
     MaxDamage=50.000000
     bUseAmmo=True
     bUseClip=True
     RemainingClip=2
     MaxClip=10
     ClipInc=1
     price=100
     ClipPrice=50
     bShowWeaponLight=True
     BotAimError=1.000000
     PlayerAimError=0.800000
     VRecoil=200.000000
     HRecoil=0.650000
     RecoilMultiplier=0.010000
     aReloadWeapon=(AnimRate=1.000000)
     EmptyClipSound=Sound'TODatas.Weapons.Empty2'
     MaxWallPiercing=48.000000
     MaxRange=4800.000000
     ProjectileSpeed=20000.000000
     bHeavyWallHit=True
     MuzScale=1.000000
     MuzX=700
     MuzY=500
     MuzRadius=128
     bUseShellCase=True
     maxShellCase=3
     ShellCaseType="s_SWAT.s_ShellCase"
     ShellEjectOffset=(X=20.000000,Y=5.000000,Z=-5.000000)
     ProjectileClass=Class's_SWAT.s_Projectile'
     bAmbientGlow=False
     AmbientGlow=0
     bNoSmooth=False
     SoundRadius=96
     SoundVolume=255
     LightBrightness=255
     LightHue=28
     LightSaturation=32
     LightRadius=6
}
