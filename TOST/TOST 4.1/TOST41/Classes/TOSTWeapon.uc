//----------------------------------------------------------------------------
// Project : TOST
// File    : TOSTWeapon.uc
// Version : 0.5
// Author  : BugBunny/Shag
//----------------------------------------------------------------------------
// Version	Changes
// 0.5		+ first release
//----------------------------------------------------------------------------

class TOSTWeapon extends s_Weapon config abstract;

#exec OBJ LOAD FILE=..\Textures\TOST4TexSolid.utx PACKAGE=TOST4TexSolid

#exec OBJ LOAD FILE=..\Textures\TOST4TexTrans.utx PACKAGE=TOST4TexTrans

var() float 	AltVRecoil;			// alternative vertical recoil
var() float 	AltHRecoil;			// alternative horizontal recoil
var() int		AltRoundPerMin;		// alternative RPM

var() float		SniperSwimAimError;	// aim error with snipers while swimming
var() float		ZoomAimErrorMod;	// aim error modifier while zooming
var() float		CrouchAimErrorMod;	// aim error modifier while crouching
var() float		MoveAimErrorMod;	// aim error modifier while moving : walking (-)/running (+)
var() float		SwimAimErrorMod;	// aim error modifier while swimming

var() float		DmgRangeMod;		// reduce damage after given range (percentage of MaxRange)

var() texture	SolidTex;
var() texture	TransTex;

function SetAimError()
{
	local	float	cvel, accmultiplier;

	// Aiming error
	if ( Owner.IsA('s_BPlayer') )
	{
		if ( bZeroAccuracy && s_BPlayer(Owner).bSZoom && (VSize(Owner.Velocity) < 20) )
		{

			// Swimming
			if ( (s_BPlayer(Owner).IsInState('PlayerSwimming')) || (s_BPlayer(Owner).Physics == PHYS_Swimming) )
			{
				AimError = SniperSwimAimError;
			} else {
				AimError = 0.0001;
			}
		} else {
			AimError = PlayerAimError;

			if ( bStaticAimError )
				return;

			accmultiplier = 1.0;

			// Zooming
			if ( s_BPlayer(Owner).bSZoom && (bZeroAccuracy || (VSize(Owner.Velocity) < 20)) )
				accmultiplier += ZoomAimErrorMod;

			// Crouching
			if ( s_BPlayer(Owner).bIsCrouching )
				accmultiplier += CrouchAimErrorMod;

			// Moving
			cvel = Abs(VSize(s_BPlayer(Owner).Velocity));
			if ( cvel < 20 )
				accmultiplier -= MoveAimErrorMod;
			else if ( cvel > 150 )
				accmultiplier += MoveAimErrorMod;

			// Swimming
			if ( (s_BPlayer(Owner).IsInState('PlayerSwimming')) || (s_BPlayer(Owner).Physics == PHYS_Swimming) )
			{
				accmultiplier += SwimAimErrorMod;
			}

			// using single shot / burst mode
			if ( FireModes[0]== FM_FullAuto && CurrentFireMode != 0 )
			{
				if (FireModes[1]== FM_BurstFire && CurrentFireMode == 1)
					accmultiplier -= 0.25;
				else
					accmultiplier -= 0.35;
			}

			AimError *= accmultiplier;
		}
	}
	else if ( Bot(Owner) != None )
	{
		if ( Bot(Owner).bNovice )
		{
			// range from (novice) x2.0 -> x1.0
			if ( Bot(Owner).Skill < 2)
				AimError = PlayerAimError * 2.0;
			else
				AimError = PlayerAimError * 1.66;
		}
		else
		{
			if ( Bot(Owner).Skill < 2)
				AimError = PlayerAimError * 1.33;
			else
				AimError = PlayerAimError * 1.0;
		}
	}
	else
		AimError = BotAimError * 3.0;

	if ( Owner.IsA('s_NPCHostage') )
		AimError *= 1 + FRand();
}


function FireBulletInstantHit(vector StartTrace, vector EndTrace, vector aimdir)
{
	local vector	HitLocation, HitNormal;
	local actor		Other;
	local float		Range, Damage, length;

	Other = Trace(HitLocation, HitNormal, EndTrace, StartTrace, true);
	length = VSize(HitLocation - StartTrace);

	if ( (Other == None) || (length > MaxRange) )
		return;

	Damage = MaxDamage * ((MaxRange - length*DmgRangeMod) / MaxRange);
	MakeNoise(Damage / 100.0);
	Other.TakeDamage(Damage, instigator, HitLocation, Damage * 50.0 * AimDir, 'shot');

	if ( !Other.bIsPawn && ( (Other==Level) || Other.IsA('BlockAll')
		|| (Other.bProjTarget || (Other.bBlockActors && Other.bBlockPlayers)) ) )
	{
		if ( HasHighRof() && ((ShotCount%3) != 1) )
			Spawn(class'TO_BulletImpactMedium', self, , HitLocation+HitNormal, rotator(HitNormal));
		else
			Spawn(class'TO_BulletImpact', self, , HitLocation+HitNormal, rotator(HitNormal));
	}
}


function FireBulletInstantHitLow(vector StartTrace, vector EndTrace, vector aimdir)
{
	local vector	HitLocation, HitNormal;
	local actor		Other;
	local float		Range, Damage, length;

	Other = Trace(HitLocation, HitNormal, EndTrace, StartTrace, true);
	length = VSize(HitLocation - StartTrace);

	if ( (Other == None) || (length > MaxRange) )
		return;

	Damage = MaxDamage * ( (MaxRange - length*DmgRangeMod) / MaxRange );
	MakeNoise(Damage / 100.0);
	Other.TakeDamage(Damage, instigator, HitLocation, Damage * 50.0 * AimDir, 'shot');

	if ( !Other.bIsPawn && ( (Other==Level) || Other.IsA('BlockAll')
		|| (Other.bProjTarget || (Other.bBlockActors && Other.bBlockPlayers)) ) )
	{
		Spawn(class'TO_BulletImpactLow', self, , HitLocation+HitNormal, rotator(HitNormal));
	}
}

simulated function bool DoChangeFireMode()
{
	local	EFireModes	CurrentMode, OldMode;

	OldMode = FireModes[CurrentFireMode];
	CurrentFireMode++;
	if ( FireModes[CurrentFireMode] == FM_None )
		CurrentFireMode = 0;

	CurrentMode = FireModes[CurrentFireMode];

	if ( OldMode == CurrentMode )
	{
		return false;
	}

	switch ( CurrentMode )
	{
		case FM_SingleFire	:	// Semi Auto
								if ( bSingleFireBasedROF )
								{
									RoundPerMin = Default.RoundPerMin;
									VRecoil = Default.VRecoil;
									HRecoil = Default.HRecoil;
									RecoilMultiplier = Default.RecoilMultiplier;
									FirePause = Default.FirePause;
								}
								else
								{
									RoundPerMin = Default.RoundPerMin * 0.50;
									VRecoil = Default.VRecoil * 0.80;
									HRecoil = Default.HRecoil * 0.80;
									RecoilMultiplier = Default.RecoilMultiplier * 0.80;
									FirePause = 0.3;
								}

								if ( bTracingBullets )
									TraceFrequency = 1;

								BurstRoundnb = 1;
								BurstRoundCount = 1;
								break;

		case FM_BurstFire	:	// (3 round burst fire)
								if ( bSingleFireBasedROF )
									RoundPerMin = Default.RoundPerMin * 2.00;
								else
									RoundPerMin = Default.RoundPerMin;

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
								if ( bSingleFireBasedROF )
									RoundPerMin = Default.RoundPerMin * 2.00;
								else
									RoundPerMin = Default.RoundPerMin;

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

defaultproperties
{
	AltVRecoil=200.0
	AltHRecoil=0.65
	AltRoundPerMin=100

	SniperSwimAimError=0.5
	ZoomAimErrorMod=-0.2
	CrouchAimErrorMod=-0.15
	MoveAimErrorMod=0.2
	SwimAimErrorMod=0.4
	DmgRangeMod=0.33
}
