class TOST_C4 extends TOSTGrenade abstract;

var bool bPlanted;
var bool bCanPlant;
var Class<TOST_ExplosiveC4> ExplosiveC4Class;
var texture PlayerViewSkin, WorldViewSkin;

replication
{
	reliable if ( Role == 4 )
		ForceClientFinish;
}

simulated function Tick (float DeltaTime)
{
	Super.Tick(DeltaTime);
	if ( owner == none )
	{
		MultiSkins[0]=WorldViewSkin;
	}
	else MultiSkins[0]=PlayerViewSkin;
}

function bool canSetBomb(out vector HitLocation, out vector HitNormal)
{
	local s_BPlayer P;
	local Vector StartPosition, EndPosition;

	P=s_BPlayer(Owner);
	if (P == None)
	{
		return false;
	}
	StartPosition=P.Location + vect(0.00,0.00,0.50) * P.BaseEyeHeight;
	EndPosition=StartPosition + vector(P.ViewRotation) * 10000;
	if (Trace(HitLocation,HitNormal,EndPosition,StartPosition,True) != Level)
		return false;

	if (Abs(VSize(StartPosition - HitLocation)) > 60)
		return false;

	return true;
}

function float RateSelf (out int bUseAltMode)
{
	return -10.00;
}

function float SwitchPriority ()
{
	return -10.00;
}

event float BotDesireability (Pawn Bot)
{
	if ( Bot.IsA('s_bot') )
	{
		return 0.00;
	}
	else
	{
		return Super.BotDesireability(Bot);
	}
}

event Destroyed ()
{
	AmbientSound=None;
	Super.Destroyed();
}

function Fire (float Value)
{
	if ( PlayerPawn(Owner) == None )
	{
		Pawn(Owner).SwitchToBestWeapon();
		return;
	}
	PlayFiring();
	GotoState('ServerArmingBomb');
	bCanPlant=True;
	ClientForceFire();
}

simulated function bool ClientFire (float Value)
{
	return False;
}

simulated function ForceClientFire ()
{
	if ( Level.NetMode == 3 )
	{
		PlayFiring();
		GotoState('ClientArmingBomb');
	}
}

function ClientForceFire ()
{
	if ( bCanPlant )
	{
		bCanPlant=False;
		TournamentPlayer(Owner).SendFire(self);
	}
}

simulated function PlayFiring ()
{
	PlayAnim('Fire',0.30);
}

simulated function PlayC4Arming ()
{
	PlayWeaponSound(Sound'bomb_set_seq');
}

state ClientArmingBomb
{
	ignores s_ReloadW, ChangeFireMode;

	simulated function bool ClientFire (float Value)
	{
		return False;
	}

	simulated function Tick (float DeltaTime)
	{
		Super.Tick(DeltaTime);
		if ( (Pawn(Owner) == None) || (Pawn(Owner).bFire == 0) )
		{
			AmbientSound=None;
			PlayIdleAnim();
			GotoState('None');
		}
	}

	simulated function AnimEnd ()
	{
		AmbientSound=None;
		Pawn(Owner).bFire=0;
		PlayIdleAnim();
		GotoState('None');
	}

	simulated function EndState ()
	{
		AmbientSound=None;
	}

}

state ServerArmingBomb
{
	ignores  s_ReloadW, ChangeFireMode;

	function Fire (float F)
	{
	}

	simulated function Tick (float DeltaTime)
	{
		Super.Tick(DeltaTime);
		if (!s_SWATGame(Level.Game).IsRoundPeriodPlaying() && ( owner == none ))
			Destroy();
		if ( (Pawn(Owner) == None) || (Pawn(Owner).bFire == 0) )
		{
			AmbientSound=None;
			Finish();
		}
	}

	simulated function AnimEnd ()
	{
		Pawn(Owner).bFire=0;
		AmbientSound=None;
		bNoDrop=True;
		PlaceC4();
	}

	simulated function EndState ()
	{
		AmbientSound=None;
	}

Begin:
	Sleep(0.00);
}

simulated function ForceClientFinish ()
{
	AmbientSound=None;
	PlayIdleAnim();
	GotoState('None');
}

simulated function PlayIdleAnim ()
{
	if ( Mesh == PickupViewMesh )
	{
		return;
	}
	if ( (FRand() > 0.98) && (AnimSequence != 'Idle1') )
	{
		PlayAnim('Idle1',0.15);
	}
	else
	{
		LoopAnim('Idle',0.20,0.30);
	}
}

function PlaceC4 ()
{
	local Pawn PawnOwner;
	local TOST_ExplosiveC4 c4;
	local int tmp;
	local s_SWATGame SG;
	local rotator C4Rot;
	local vector HitLocation, HitNormal;

	SG=s_SWATGame(Level.Game);
	if ( ((SG != None) &&  !SG.IsRoundPeriodPlaying()) || !canSetBomb(HitLocation, HitNormal) )
	{
		AmbientSound=None;
		Finish();
		return;
	}
	PawnOwner=Pawn(Owner);

	C4Rot = rotator(HitNormal);
	if ( abs(HitNormal.Z) == 1 )
		C4Rot.Yaw += Owner.Rotation.Yaw;

	c4=Spawn(ExplosiveC4Class,self,,HitLocation,C4Rot);

	if ( c4 != none )
	{
		PlaySound(Sound'bomb_plant',SLOT_None);
		pawn(owner).sendglobalmessage(none,'other',1,10.00);
		bPlanted=True;
		PawnOwner.bFire=0;
		PawnOwner.SwitchToBestWeapon();
		PawnOwner.ChangedWeapon();
	}
	else
	{
		AmbientSound=None;
		Finish();
	}
}

simulated function InstantExplode(pawn inst)
{
	local TOST_GrenadeExplosion expl;
	local ShockWave sW;

	if (Role!=4)
	{
		Destroy();
		return;
	}
	sW=Spawn(Class'TOST_C4ShockWave',,,Location);
	sW.instigator=inst;
	expl=Spawn(Class'TOST_GrenadeExplosion',,,Location);
	expl.scale=2;
	expl.Instigator=inst;
	Destroy();
}

state byebye
{
	begin:
		destroy();
}

defaultproperties
{
    bUseClip=False
    MaxClip=0
    ClipInc=0
    ClipPrice=0
    MaxDamage=60.00
    RoundPerMin=100
    BotAimError=0.80
    PlayerAimError=500.00
    bHasMultiSkins=True
    ArmsNb=3
    WeaponID=5
    WeaponClass=5
    WeaponWeight=2.00
    aReloadWeapon=(AnimSeq=Reload, AnimRate=1.00)
    MaxRange=2150.00
    InstFlash=-0.20
    InstFog=(X=325.00, Y=225.00, Z=95.00)
    PickupAmmoCount=30
    bMeleeWeapon=True
    FiringSpeed=1.50
    MyDamageType=shot
    shakemag=200.00
    shakevert=4.00
    AIRating=0.25
    RefireRate=0.80
    AltRefireRate=0.87
    SelectSound=Sound'TODatas.Weapons.Bomb_Select'
    DeathMessage="%k riddled %o full of holes with the %w."
    NameColor=(R=200, G=200, B=255, A=0)
    FlashY=0.10
    FlashO=0.01
    FlashC=0.04
    FlashLength=0.01
    FlashS=128
    AutoSwitchPriority=10
    InventoryGroup=5
	PlayerViewOffset=(X=230.000000,Y=150.000000,Z=-280.000000)
    PlayerViewScale=0.13
    MaxDesireability=3.00
    PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
    Icon=None
    bHidden=True
    CollisionRadius=20.00
    CollisionHeight=3.00
    Mass=10.00
	MaxNadeMode=0
	MinNadeMode=0
}

