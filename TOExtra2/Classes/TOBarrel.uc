class TOBarrel extends Actor;

var() int Health;
var int TimeBeforeExplode;
var Pawn Who;

event TakeDamage(int Damage,Pawn EventInstigator,vector HitLocation,vector Momentum,name DamageType)
{
    Health-=Damage;
    if (Health<=0)
    {
        Who=EventInstigator;
        if (TimeBeforeExplode==0) ExplodeNow(); else SetTimer(TimeBeforeExplode,false);
    }
}

function Timer()
{
    ExplodeNow();
}

function ExplodeNow()
{
    local TOBarrelExplode be;

    be=Spawn(class'TOBarrelExplode',,,Location);
    be.Instigator=Who;
    Destroy();
}

defaultproperties
{
    DrawType=DT_Mesh
    mesh=Mesh'Barrel3M'
    DrawScale=0.250000
    Physics=PHYS_Falling
    bCollideActors=True
    bCollideWorld=True
    bBlockActors=True
    bBlockPlayers=True
    bProjTarget=True
    CollisionRadius=20.000000
    CollisionHeight=30.000000
    Health=40
}

