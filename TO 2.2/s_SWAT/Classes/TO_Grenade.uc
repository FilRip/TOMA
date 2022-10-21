//=============================================================================
// TO_Grenade
//=============================================================================
//
// Tactical Ops
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen and Benoit "JAH" Delayen
//=============================================================================

class TO_Grenade extends s_Weapon;
 
var	bool	bGrenadeReady, bDrawGauge;
var	float	Power;

/*
///////////////////////////////////////
// replication 
///////////////////////////////////////

replication 
{
 // Functions clients can call (for Extra-Keys)
  reliable if ( Role < ROLE_Authority )
		FinishGrenade;
}
*/

///////////////////////////////////////
// SwitchPriority
///////////////////////////////////////

function float SwitchPriority()
{
	if ( bNoDrop )
		return 0.0;

	return Super.SwitchPriority();
}


///////////////////////////////////////
// RateSelf 
///////////////////////////////////////

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


///////////////////////////////////////
// SuggestAttackStyle 
///////////////////////////////////////

function float SuggestAttackStyle()
{
	return (5.0 * FRand());
}


///////////////////////////////////////
// SuggestDefenseStyle 
///////////////////////////////////////

function float SuggestDefenseStyle()
{
	return (10.0);
	
}


///////////////////////////////////////
// PlayIdleAnim 
///////////////////////////////////////

simulated function PlayIdleAnim()
{
	if ( Mesh == PickupViewMesh )
		return;

	if ( (FRand() > 0.98) && (AnimSequence != 'idle1') ) 
		PlayAnim('idle1', 0.15);
	else 
		LoopAnim('idle',0.2, 0.3);
}

/*
///////////////////////////////////////
// s_PlayFiring 
///////////////////////////////////////

simulated function s_PlayFiring()
{	
	PlayAnim('THROW', 1.0);
}
*/

///////////////////////////////////////
// PlayStartThrow
///////////////////////////////////////

simulated function PlayStartThrow()
{
	//log("TO_Grenade::PlayStartThrow");
	Power = 0.0;
	bDrawGauge = true;

	PlayAnim('THROWS', 1.0);
}


///////////////////////////////////////
// PlayEndThrow
///////////////////////////////////////

simulated function PlayEndThrow()
{
	//log("TO_Grenade::PlayEndThrow");
	bDrawGauge = false;
	bGrenadeReady = false;

	PlayAnim('THROWE', 1.5);
}


///////////////////////////////////////
// MNthrow
///////////////////////////////////////

simulated function MNthrow()
{
	//log("TO_Grenade::MNthrow");
	if ( (PlayerPawn(Owner) != None) && ((Level.NetMode == NM_Standalone) 
		|| ( (PlayerPawn(Owner).Player != None) && PlayerPawn(Owner).Player.IsA('ViewPort'))) )
	{
		PlayerPawn(Owner).ShakeView(ShakeTime, ShakeMag, ShakeVert);
	}

	if ( Role == Role_Authority )
		ThrowGrenade();
}


///////////////////////////////////////
// Fire
///////////////////////////////////////

function Fire(float Value)
{
	//log("TO_Grenade::Fire");
	bPointing = true;
	ClientFire( Value );
	GotoState('ServerHoldGrenade');
}


///////////////////////////////////////
// ClientFire
///////////////////////////////////////

simulated function bool ClientFire( float Value )
{
	//if ( !bCanClientFire )
	//	return false;

	//log("TO_Grenade::ClientFire");
	PlayStartThrow();

	//if ( Level.NetMode != NM_DedicatedServer )
	if ( Role < Role_Authority )
		GotoState('ClientHoldGrenade');

	return true;
}


///////////////////////////////////////
// ClientHoldGrenade
///////////////////////////////////////

state ClientHoldGrenade
{
	ignores ChangeFireMode, s_ReloadW;


	simulated function bool ClientFire(float Value) {	return false; }

	simulated function Tick( float DeltaTime )
	{
		Super.Tick( DeltaTime );

		if ( Pawn(Owner).bFire == 1 )
		{
			if ( Power < 4.0 )
				Power += DeltaTime * 2.0;
			else if ( Power != 4.0 )
				Power = 4.0;
		}
		
		if ( Pawn(Owner).bAltFire == 1 )
			Power = 0;

		// Holding sequence aborted
		if ( bGrenadeReady && (Pawn(Owner).bFire == 0) )
		{
			//log("ClientHoldGrenade - PlayEndThrow");
			PlayEndThrow();
			GotoState('ClientThrowGrenade');
		}
	}

	simulated function AnimEnd()
	{
		//log("TO_Grenade::ClientHoldGrenade::AnimEnd");
		bGrenadeReady = true;
		LoopAnim('THROWM',0.2, 0.3);
	}

	simulated function BeingState() 
	{
		//log("TO_Grenade::ClientHoldGrenade::BeingState");
		bGrenadeReady = false; 
	}
}


///////////////////////////////////////
// ServerHoldGrenade
///////////////////////////////////////

state ServerHoldGrenade
{
	ignores Fire, ChangeFireMode, s_ReloadW;

	function Tick( float DeltaTime )
	{
		Super.Tick( DeltaTime );

		if ( Pawn(Owner).bFire == 1 )
		{
			if ( Power < 4.0 )
				Power += DeltaTime * 2.0;
			else if ( Power != 4.0 )
				Power = 4.0;
		}

		if ( Pawn(Owner).bAltFire == 1 )
			Power = 0;

		// Arming sequence aborted
		if ( bGrenadeReady && (Pawn(Owner).bFire == 0) )
		{
			bNoDrop = true;
			PlayEndThrow();
			GotoState('ServerThrowGrenade');
		}
	}

	function AnimEnd() 
	{ 
		//log("TO_Grenade::ServerHoldGrenade::AnimEnd");
		bGrenadeReady = true; 
	}

	function BeginState() 
	{ 
		//log("TO_Grenade::ServerHoldGrenade::BeginState");
		bGrenadeReady = false; 
	}

	function EndState() 
	{ 
		//log("TO_Grenade::ServerHoldGrenade::EndState"@GetStateName());
		bGrenadeReady = false; 
	}
Begin:

	//log("TO_Grenade::ServerHoldGrenade::Begin");
	Sleep(0.0);
}



///////////////////////////////////////
// ClientThrowGrenade
///////////////////////////////////////

state ClientThrowGrenade
{
	ignores Fire, ChangeFireMode, s_ReloadW;
/*
	simulated function AnimEnd()
	{
		//log("TO_Grenade::ClientThrowGrenade::AnimEnd");
		//FinishGrenade();
		//PlayIdleAnim();
		//GotoState('');
		//FinishGrenade();
	}
*/
}


///////////////////////////////////////
// ServerThrowGrenade
///////////////////////////////////////

state ServerThrowGrenade
{
	ignores Fire, ChangeFireMode, s_ReloadW;

	function AnimEnd()
	{
		//log("TO_Grenade::ServerThrowGrenade::AnimEnd");
		FinishGrenade();
	}

Begin:
	//log("TO_Grenade::ServerThrowGrenade::Begin");
	Sleep(0.0);
		
}


///////////////////////////////////////
// ThrowGrenade
///////////////////////////////////////

simulated function ThrowGrenade()
{	
	local s_GrenadeAway g;
	local vector StartTrace, X, Y, Z;
	local Pawn PawnOwner;

	//log("TO_Grenade::ThrowGrenade");

	PawnOwner = Pawn(Owner);
	Owner.MakeNoise(PawnOwner.SoundDampening);
	GetAxes(PawnOwner.ViewRotation, X, Y, Z);
	
	StartTrace =  Owner.Location + CalcDrawOffset() + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z; 
	AdjustedAim = pawn(owner).AdjustAim(1000000, StartTrace, 2 * AimError, False, False);	
	g = Spawn(class's_GrenadeAway',,, StartTrace, AdjustedAim);
	//g.RemoteRole = Role_None;
	//g.Ignition( 4.0 );
	//log("TO_Grenade - ThrowGrenade - Speed:"@1300 + Power*50);
	g.ExpTiming = 5.0 - Power * 0.375;
	g.speed = 700 + Power * 120;
	g.ThrowGrenade();
/*
	if (!Level.Game.IsA('s_SWATGame'))
		return;

	if (Owner.IsA('s_BPlayer'))
	{
		if (FRand()<0.5)
			s_SWATGame(Level.Game).s_PlayDynamicTeamSound(19, s_BPlayer(Owner).GetVoiceType(), Pawn(Owner).PlayerReplicationInfo.Team,, Pawn(Owner).PlayerReplicationInfo);
		else
			s_SWATGame(Level.Game).s_PlayDynamicTeamSound(20, s_BPlayer(Owner).GetVoiceType(), Pawn(Owner).PlayerReplicationInfo.Team,, Pawn(Owner).PlayerReplicationInfo);
	}
	else if (Owner.IsA('s_Bot'))
	{
		if (FRand()<0.5)
			s_SWATGame(Level.Game).s_PlayDynamicTeamSound(19, s_Bot(Owner).GetVoiceType(), Pawn(Owner).PlayerReplicationInfo.Team,, Pawn(Owner).PlayerReplicationInfo);
		else
			s_SWATGame(Level.Game).s_PlayDynamicTeamSound(20, s_Bot(Owner).GetVoiceType(), Pawn(Owner).PlayerReplicationInfo.Team,, Pawn(Owner).PlayerReplicationInfo);
	}
*/
}


///////////////////////////////////////
// DrawGrenadeGauge
///////////////////////////////////////

simulated event RenderOverlays( Canvas Canvas )
{
	local float		scale;
	local	float		XO, YO, X, Y, XL, YL, BarWidth;
	local	ChallengeHUD	daHUD;

	Super.RenderOverlays(Canvas);

	if ( (PlayerPawn(Owner) == None) || (Pawn(Owner).bFire == 0) || !bDrawGauge || (Power == 0.0) )
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
	Canvas.DrawText("Throwing range", false);
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

/*
	if (PlayerPawn(Owner)!=None && PlayerPawn(Owner).myHUD!=None)
		scale=s_HUD(PlayerPawn(Owner).myHUD).scale;
	else
		scale=1;

	Y = Canvas.ClipY - 120 * Scale;
	X = Canvas.ClipX - 176 * Scale;

	Canvas.Style=3;

	Canvas.SetPos(X, Y);
	Canvas.DrawTile(Texture'grenadeg', 64*Scale*power, 16*Scale, 0, 0, 64.0*power, 16.0);

	Canvas.Style=1;
*/
}


///////////////////////////////////////
// FinishGrenade
///////////////////////////////////////

function FinishGrenade()
{
	local Pawn PawnOwner;

	//log("TO_Grenade::FinishGrenade");
	//ThrowGrenade( power );

	PawnOwner = Pawn(Owner);
	PawnOwner.SwitchToBestWeapon();

	GotoState('DownGrenade');
}


///////////////////////////////////////
// DownGrenade 
///////////////////////////////////////

State DownGrenade
{
ignores Fire, AltFire;

	function bool PutDown()
	{
		Pawn(Owner).ClientPutDown(self, Pawn(Owner).PendingWeapon);
		return true; //just keep putting it down
	}

	function BeginState()
	{
		bChangeWeapon = false;
		bMuzzleFlash = 0;
		Pawn(Owner).ClientPutDown(self, Pawn(Owner).PendingWeapon);
	}

Begin:
	//log("TO_Grenade::DownGrenade::Begin");
	//TweenDown();
	//sleep(1.0);
	
	//FinishAnim();
	Pawn(Owner).ChangedWeapon();
	destroy();
	
}


///////////////////////////////////////
// defaultproperties 
///////////////////////////////////////

//FireOffset=(Y=-10.000000,Z=-4.000000)

defaultproperties
{
     MaxDamage=60.000000
     bUseClip=False
     MaxClip=0
     ClipInc=0
     RoundPerMin=100
     price=500
     ClipPrice=0
     BotAimError=0.800000
     PlayerAimError=500.000000
     bHasMultiSkins=True
     ArmsNb=2
     WeaponID=3
     WeaponClass=5
     WeaponWeight=4.000000
     MaxRange=120.000000
     WeaponDescription="Classification: HE Grenade"
     InstFlash=-0.200000
     InstFog=(X=325.000000,Y=225.000000,Z=95.000000)
     PickupAmmoCount=30
     bMeleeWeapon=True
     FiringSpeed=1.500000
     FireOffset=(X=5.000000,Y=8.000000,Z=-6.000000)
     MyDamageType=shot
     shakemag=250.000000
     shaketime=0.300000
     shakevert=6.000000
     AIRating=0.250000
     RefireRate=0.800000
     AltRefireRate=0.870000
     FireSound=Sound'TODatas.Weapons.couteau2'
     SelectSound=Sound'TODatas.Weapons.couteausorti'
     DeathMessage="%k riddled %o full of holes with the %w."
     NameColor=(R=200,G=200)
     FlashY=0.100000
     FlashO=0.008000
     FlashC=0.035000
     FlashLength=0.010000
     FlashS=128
     AutoSwitchPriority=3
     InventoryGroup=5
     PickupMessage="You picked up a HE Grenade!"
     ItemName="HE Grenade"
     PlayerViewOffset=(X=380.000000,Y=130.000000,Z=-110.000000)
     PlayerViewMesh=LodMesh'TOModels.Grenade'
     PlayerViewScale=0.090000
     PickupViewMesh=LodMesh'TOModels.wgrenade'
     ThirdPersonMesh=LodMesh'TOModels.wgrenade'
     PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
     bHidden=True
     Mesh=LodMesh'TOModels.wgrenade'
     CollisionRadius=20.000000
     CollisionHeight=8.000000
     Mass=15.000000
}
