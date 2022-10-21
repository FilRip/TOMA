class TOST_ExplosiveC4 extends s_ExplosiveC4 abstract;

var string C4Class;
var int Strength;
var bool CanBeShooted;

simulated event TakeDamage( int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, name DamageType)
{
	if ( !CanBeShooted )
		return;
	Strength -= Damage;
	if ( Strength <= 0 )
		InstantExplode(EventInstigator);
}

simulated function BeginPlay()
{
	local Actor OldOwner;
	if ( Level.NetMode == 1 )
	{
		OldOwner = Owner;
		setowner(Owner.Owner);
		OldOwner.GoToState('byebye');
	}
	bBeingActivated=false;
}

simulated function Destroyed()
{
	if ( (defusedBy != none) && (s_player(defusedby) != none) )
		s_player(defusedby).UseReleaseServer(false,true);
}

simulated function InstantExplode(pawn inst)
{
	local TOST_GrenadeExplosion expl;
	local ShockWave sW;

	if ((Role!=4)||(!IsRoundPeriodPlaying()))
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

simulated function C4Explode()
{
	local TOST_GrenadeExplosion expl;
	local ShockWave sW;
	local int i;

	if ((Role!=4)||(!IsRoundPeriodPlaying()))
	{
		Destroy();
		return;
	}
	sW=Spawn(Class'TOST_C4ShockWave',,,Location);
	sW.instigator=pawn(owner);
	expl=Spawn(Class'TOST_GrenadeExplosion',,,Location);
	expl.scale=2;
	expl.Instigator=pawn(owner);
	bExploded=True;
	SetTimer(2.00,False);
}

function bool IsRelevant(Actor Other)
{
	local Pawn P;

	P = Pawn(Other);

	if ( (P != None) && (P.PlayerReplicationInfo != None) )
		return true;
	return false;
}

function C4Complete()
{

	if(SoundCompleted != None)
		PlaySound(SoundCompleted,SLOT_None,4.00);
	bBeingActivated = false;

	if ( (Pawn(DefusedBy).findinventorytype(Class<Actor>(DynamicLoadObject("s_SWAT.s_C4",Class'Class'))) == none)
	&& (Pawn(DefusedBy).findinventorytype(Class<Actor>(DynamicLoadObject("TOSTWeapons42.TOST_Grenade",Class'Class'))) == none)
	&& (Pawn(DefusedBy).findinventorytype(Class<Actor>(DynamicLoadObject("TOSTWeapons42.TOST_GrenadeConc",Class'Class'))) == none)
	&& (Pawn(DefusedBy).findinventorytype(Class<Actor>(DynamicLoadObject("TOSTWeapons42.TOST_GrenadeFB",Class'Class'))) == none)
	&& (Pawn(DefusedBy).findinventorytype(Class<Actor>(DynamicLoadObject("TOSTWeapons42.TOST_GrenadeSmoke",Class'Class'))) == none)
	&& (Pawn(DefusedBy).findinventorytype(Class<Actor>(DynamicLoadObject("C4Pack42.TOST_C4Lazer",Class'Class'))) == none)
	&& (Pawn(DefusedBy).findinventorytype(Class<Actor>(DynamicLoadObject("C4Pack42.TOST_C4Timer",Class'Class'))) == none) )
		s_SWATGame(Level.Game).GiveWeapon(Pawn(DefusedBy),C4Class);
	Destroy();
}

defaultproperties
{
	Strength=100
	C4Duration=5.00
	C4RadiusRange=80
	Mass=0
	Physics=PHYS_Flying
	CollisionRadius=12.0
	CollisionHeight=12.0
}
