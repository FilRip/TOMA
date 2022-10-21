//----------------------------------------------------------------------------
// Project : TOST
// File    : TOSTGrenade.uc
// Version : 0.5
// Author  : BugBunny/Shag
//----------------------------------------------------------------------------
// Version	Changes
// 0.5		+ first release
//----------------------------------------------------------------------------

class TOSTGrenade extends TOSTWeapon;

var	bool	bCanHold, bGrenadeReady, bDrawGauge;
var	float	Power;

var float	MaxPower;
var int		DefSpeed, MultSpeed;
var float	FuseTime, ReduceFuse, DropFuse;

var	class<s_GrenadeAway>	NadeAwayClass;

var localized string LS_ThrowingRange;

replication
{
	// Server -> client
	reliable if ( (Role == ROLE_Authority) && bNetOwner)
		Power;
}

function float RateSelf( out int bUseAltMode )
{
	local float EnemyDist;
	local bool bRetreating;
	local Pawn P;

	if ( bNoDrop )
		return 0.0;

	bUseAltMode = 0;
	P = Pawn(Owner);

	if ( (P == None) || (P.Enemy == None) )
		return 0;

	EnemyDist = VSize(P.Enemy.Location - Owner.Location);
	if ( (EnemyDist < 750) && P.IsA('Bot') && Bot(P).bNovice && (P.Skill <= 2) && !P.Enemy.IsA('Bot') && (s_Knife(P.Enemy.Weapon) != None) )
		return FClamp(300/(EnemyDist + 1), 0.6, 0.75);

	if ( EnemyDist > 400 )
		return 0.1;
	if ( (P.Weapon != self) && (EnemyDist < 120) )
		return 0.25;

	return ( FMin(0.8, 81/(EnemyDist + 1)) );
}

function float SwitchPriority()
{
	if ( PlayerPawn(Owner) != None )
		return -10.0;

	return Super.SwitchPriority();
}

function Fire(float Value)
{
	if ( PlayerPawn(Owner) == None )
	{
		Pawn(Owner).SwitchToBestWeapon();
		return;
	}

	PlayFiring();
	GotoState('ServerHoldGrenade');
}

simulated function bool ClientFire( float Value )
{
	if ( Level.NetMode == NM_Client )
	{
		PlayFiring();
		GotoState('ClientHoldGrenade');
	}
}

simulated function PlayFiring()
{
	Power = 0.0;
	bDrawGauge = true;

	PlayAnim('THROWS', 0.5);
}

simulated function PlayIdleAnim()
{
	if ( Mesh == PickupViewMesh )
		return;

	if ( (FRand() > 0.98) && (AnimSequence != 'idle1') )
		PlayAnim('idle1', 0.3);
	else
		LoopAnim('idle',0.2, 0.3);
}

simulated function PlayEndThrow()
{
	bDrawGauge = false;
	bGrenadeReady = false;

	PlaySynchedAnim('THROWE', 0.6, 0.02);

	if ( Role == Role_Authority )
	{
		bPointing = true;
		if (Owner.IsA('s_Player_T'))
		{
			s_Player_T(Owner).PlayGrenadeThrow();
		}
		else if (Owner.IsA('s_BotBase'))
		{
			s_BotBase(Owner).PlayGrenadeThrow();
		}
	}
}

simulated function MNthrow()
{
	if ( (PlayerPawn(Owner) != None) && ((Level.NetMode == NM_Standalone)
		|| ( (PlayerPawn(Owner).Player != None) && PlayerPawn(Owner).Player.IsA('ViewPort'))) )
	{
		PlayerPawn(Owner).ShakeView(ShakeTime, ShakeMag, ShakeVert);
	}

	if ( Role == Role_Authority )
		ThrowGrenade();
}

state ClientHoldGrenade
{
	ignores ChangeFireMode, s_ReloadW;

	simulated function bool ClientFire(float Value) { return false; }

	simulated function Tick( float DeltaTime )
	{
		Super.Tick( DeltaTime );

		if ( Pawn(Owner).bFire == 1 )
		{
			if ( Power < MaxPower )
				Power += DeltaTime * 2.0;
			else if ( Power != MaxPower )
				Power = MaxPower;
		}

		if ( Pawn(Owner).bAltFire == 1 )
			Power = 0.0001;

		// Holding sequence aborted
		if ( bGrenadeReady && (Pawn(Owner).bFire == 0) )
		{
			PlayEndThrow();
			GotoState('ClientThrowGrenade');
		}
	}

	simulated function AnimEnd()
	{
		bGrenadeReady = true;
		LoopAnim('THROWM',0.2, 0.3);
	}

	simulated function BeginState()
	{
		bGrenadeReady = false;
		Power = 0.0;
	}
}

state ServerHoldGrenade
{
	ignores ChangeFireMode, s_ReloadW;

	function Fire(float F) {}

	function Tick( float DeltaTime )
	{
		Super.Tick( DeltaTime );

		if ( Pawn(Owner).bFire == 1 )
		{
			if ( Power < MaxPower )
				Power += DeltaTime * 2.0;
			else if ( Power != MaxPower )
				Power = MaxPower;
		}

		if ( Pawn(Owner).bAltFire == 1 )
			Power = 0.0001;

		// Arming sequence aborted
		if ( bGrenadeReady && (Pawn(Owner).bFire == 0) )
		{
			bNoDrop = true;
			PlayEndThrow();
			GotoState('ServerThrowingGrenade');
		}
	}

	function AnimEnd()
	{
		bGrenadeReady = true;
	}

	function DropFrom(vector StartLocation)
	{
		if (bGrenadeReady)
		{
			DropGrenade();
			FinishGrenade();
		}
		else
			Super.DropFrom( StartLocation );
	}

	function BeginState()
	{
		bGrenadeReady = false;
	}

	function EndState()
	{
		bGrenadeReady = false;
	}
Begin:
	Sleep(0.0);
}

state ClientThrowGrenade
{
	ignores ChangeFireMode, s_ReloadW;
}

state ServerThrowingGrenade
{
	ignores ChangeFireMode, s_ReloadW;

	function Fire(float F) {}

	function AnimEnd()
	{
		bPointing = false;
		FinishGrenade();
	}

Begin:
	Sleep(0.0);
}

function BotThrowGrenade()
{
	if ( Bot(Owner).Enemy == None )
		Power = MaxPower;
	else
		Power = FClamp(VSize(Bot(Owner).Enemy.Location-Location)/250, 1.0, 4.5);

	bNoDrop = true;
	PlayEndThrow();
	GotoState('ServerThrowingGrenade');
}

simulated function ThrowGrenade()
{
	local s_GrenadeAway g;
	local vector StartTrace, X, Y, Z;
	local Pawn PawnOwner;

	PawnOwner = Pawn(Owner);
	Owner.MakeNoise(PawnOwner.SoundDampening);
	GetAxes(PawnOwner.ViewRotation, X, Y, Z);

	StartTrace =  Owner.Location + TOCalcDrawOffset() + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z;
	AdjustedAim = pawn(owner).AdjustAim(1000000, StartTrace, 2 * AimError, false, false);
	g = Spawn(NadeAwayClass,,, StartTrace, AdjustedAim);
	g.ExpTiming = FuseTime - Power * ReduceFuse;
	g.Speed = DefSpeed + Power * MultSpeed;
	g.ThrowGrenade();

	GrenadeThrown();
}

simulated function DropGrenade()
{
	local s_GrenadeAway g;
	local vector StartTrace, X, Y, Z;
	local Pawn PawnOwner;

	PawnOwner = Pawn(Owner);
	Owner.MakeNoise(PawnOwner.SoundDampening);
	GetAxes(PawnOwner.ViewRotation, X, Y, Z);

	StartTrace =  Owner.Location + TOCalcDrawOffset() + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z;
	AdjustedAim = pawn(owner).AdjustAim(1000000, StartTrace, 2 * AimError, false, false);
	G = Spawn(NadeAwayClass,,, StartTrace, AdjustedAim);
	G.ExpTiming = DropFuse;
	G.Speed = 0;
	G.ThrowGrenade();

	GrenadeThrown();
}

function GrenadeThrown()
{
	local	Pawn	PawnOwner;

	PawnOwner = Pawn(Owner);
	if ( PawnOwner == None )
		return;

	PawnOwner.PlaySound(class<TO_VoicePack>(PawnOwner.PlayerReplicationInfo.VoiceType).default.OtherSound[2], Slot_Talk, 128.0, true);
}

simulated event RenderOverlays( Canvas Canvas )
{
	local float		scale;
	local	float		XO, YO, X, Y, XL, YL, BarWidth;
	local	ChallengeHUD	daHUD;

	Super.RenderOverlays(Canvas);

	if ( (PlayerPawn(Owner) == None) || (Pawn(Owner).bFire == 0) || (Power == 0.0) )
		return;

	if ( PlayerPawn(Owner).myHUD != None )
		daHUD = ChallengeHUD(PlayerPawn(Owner).myHUD);

	if ( (daHUD == None) || (Canvas == None) )
	{
		log("TO_Grenade::RenderOverlays - HUD == None || Canvas == None");
		return;
	}

	Scale = daHUD.Scale;

	Canvas.bNoSmooth = false;
	Canvas.Style = Style;
	Canvas.DrawColor = daHUD.HUDColor;

	if ( daHUD.MyFonts != None )
		Canvas.Font = daHUD.MyFonts.GetMediumFont( Canvas.ClipX );
	else
		log("TO_Grenade::RenderOverlays - HUD.MyFonts == None");

	XO = Canvas.ClipX / 2;
	YO = Canvas.ClipY * 3 / 4;
	BarWidth = 372;
	X = BarWidth * Scale;

	Canvas.SetPos(XO - X, YO);
	Canvas.DrawText(LS_ThrowingRange, false);
	Canvas.StrLen("test", XL, YL);

	// Draw Gauge
	Canvas.SetPos(XO - X, YO + YL * 1.5);
	Canvas.DrawTile(Texture'TODatas.GaugeStart', Scale * 8 , Scale * 32, 0, 0, 8, 32);

	Canvas.SetPos(XO - X + Scale * 8, YO + YL * 1.5);
	Canvas.DrawTile(Texture'TODatas.GaugeMid', X * 2 - Scale * 16, Scale * 32, 0, 0, 8, 32);

	Canvas.SetPos(XO + X - Scale * 8, YO + YL * 1.5);
	Canvas.DrawTile(Texture'TODatas.GaugeEnd', Scale * 8 , Scale * 32, 0, 0, 8, 32);

	// Draw progress bar
	Canvas.SetPos(XO - X + Scale * 8, YO + YL * 1.5);
	Canvas.DrawTile(Texture'TODatas.GaugeBar', (X  - Scale * 8) * Power / 2.0, Scale * 32, 0, 0, 8, 32);

	Canvas.Style = 1;
}

function FinishGrenade()
{
	local Pawn PawnOwner;

	PawnOwner = Pawn(Owner);
	PawnOwner.bFire = 0;

	if(s_BPlayer(PawnOwner) != none && s_BPlayer(PawnOwner).bSwitchToLastWeapon)
		s_BPlayer(PawnOwner).SwitchToLastWeapon(true);
	else
		PawnOwner.SwitchToBestWeapon();

	PawnOwner.ChangedWeapon();
	Destroy();
}

defaultproperties
{
	MaxPower=4.0
	DefSpeed=700
	MultSpeed=120
	FuseTime=4.5
	DropFuse=2.0
	ReduceFuse=0.375

	LS_ThrowingRange="Throwing range"
	WeaponDescription="Classification: HE Grenade"

	MaxDesireability=3.0000
	MaxDamage=60.000000
	bUseClip=false
	MaxClip=0
	ClipInc=0
	RoundPerMin=100
	Price=500
	ClipPrice=0
	BotAimError=0.800000
	PlayerAimError=500.00000
	WeaponID=3
	WeaponClass=5
	WeaponWeight=4.0
	aReloadWeapon=(AnimSeq=Reload)
	MaxRange=120.000000
	InstFlash=-0.200000
	InstFog=(X=325.000000,Y=225.000000,Z=95.000000)
	PickupAmmoCount=30
	bMeleeWeapon=True
	FiringSpeed=1.500000
	MyDamageType=shot
	shakemag=250.0
	shaketime=0.3
	shakevert=6.0
	AIRating=0.250000
	RefireRate=0.800000
	AltRefireRate=0.870000
	NameColor=(R=200,G=200)
	FlashY=0.100000
	FlashO=0.008000
	FlashC=0.035000
	FlashLength=0.010000
	FlashS=128

	PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
	bHidden=True
	bNoSmooth=False
	CollisionRadius=20.000000
	CollisionHeight=8.000000
	Mass=10.0
	bHasMultiSkins=true
	ArmsNb=3

	FireSound=Sound'TODatas.Weapons.couteau2'
	SelectSound=Sound'TODatas.Weapons.Grenade_Select'
	AutoSwitchPriority=3
	InventoryGroup=5
	PickupMessage="You picked up a HE Grenade!"
	ItemName="HE Grenade"
	Mesh=LodMesh'TOModels.wgrenadeHE'

	NadeAwayClass=class's_GrenadeAway'
}
