//=============================================================================
// TO_ProjectileSpawner
//
// 'Created' by EMH_Mark3
//
// This class spawns one or more projectiles on a given trajectory. You can
// set many parameters about the projectile and the ProjectileSpawner
// (See below for explainations)
//=============================================================================

class TO_ProjectileSpawner extends Effects;

var() class<Projectile> ProjectileType;		// Projectile Class

var() float		ProjectileDamage;						// Use -1 to use the projectile's default value
var() float		ProjectileMomentumTransfer;	// Use -1 to use the projectile's default value
var() float		ProjectileSpeed;						// Use 0 to use the projectile's default value
var() bool		bDeviate;										// Do the projectiles deviate ?
var() int			Deviation;									// If so, how much ?
var() sound		FireSound;									// Sound played when the projectile is fired
var() bool		bInfiniteProjectiles;				// Has infinite projectiles ?
var() int			NumProjectiles;							// Number of projectiles
var() bool		bAutomaticFire;							// Is triggered by a timer ?
var() int			RateOfFire;									// If so, at what rate ?

var	  int			remainingProjectiles;


///////////////////////////////////////
// BeginPlay 
///////////////////////////////////////

function BeginPlay()
{
	remainingProjectiles = NumProjectiles;
	if (bAutomaticFire)
		SetTimer(RateOfFire, True);
}


///////////////////////////////////////
// Timer 
///////////////////////////////////////

function Timer()
{
	if (!bInfiniteProjectiles)
	{
		if (remainingProjectiles > 0)
		{
			remainingProjectiles--;
			LaunchProjectile();
		}
	}

	else
		LaunchProjectile();
}


///////////////////////////////////////
// Trigger 
///////////////////////////////////////

function Trigger(actor Other, pawn EventInstigator)
{
	Timer();
}

  
///////////////////////////////////////
// LaunchProjectile 
///////////////////////////////////////

function LaunchProjectile()
{
	local rotator NewRot;
	local Projectile Projectile1;

	if (bDeviate)
	{
		NewRot.Pitch = Rotation.Pitch + (Deviation/2) - (Deviation * FRand());
		NewRot.Roll  = Rotation.Roll  + (Deviation/2) - (Deviation * FRand());
		NewRot.Yaw   = Rotation.Yaw   + (Deviation/2) - (Deviation * FRand());
	}
	else
		NewRot = Rotation;

	Projectile1 = Spawn(ProjectileType,,, Location+Vector(Rotation)*20, NewRot);
	
	if (ProjectileSpeed != 0)
		Projectile1.speed = ProjectileSpeed;

	if (ProjectileDamage > -1)
		Projectile1.damage = ProjectileDamage;

	if 	(ProjectileMomentumTransfer > -1)
		Projectile1.momentumtransfer = ProjectileMomentumTransfer;

	PlaySound(FireSound, SLOT_None, 4.0);
}


///////////////////////////////////////
// defaultproperties 
///////////////////////////////////////

defaultproperties
{
     ProjectileDamage=-1.000000
     ProjectileMomentumTransfer=-1.000000
     bInfiniteProjectiles=True
     NumProjectiles=5
     bAutomaticFire=True
     RateOfFire=5
     bHidden=True
     bDirectional=True
     DrawType=DT_Sprite
}
