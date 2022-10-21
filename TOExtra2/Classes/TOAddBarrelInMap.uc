class TOAddBarrelInMap extends Mutator;

var int RoundResetted;
var() config bool bRemoveOlderBarrels;
var() config int NbMaxBarrel;
var() config int DamageToExplode;
var() config int DelayBeforeExplosion;

function PostBeginPlay()
{
    super.PostBeginPlay();
    SetTimer(1,true);
}

function Timer()
{
    if (s_SWATGame(Level.Game).GamePeriod==GP_PreRound)
        if (s_SWATGame(Level.Game).RoundNumber!=RoundResetted)
        {
            RoundResetted=s_SWATGame(Level.Game).RoundNumber;
            SetupBarrel();
        }
}

function SetupBarrel()
{
    local PathNode PN;
    local int curb;
    local TOBarrel NewBarrel;

    if (bRemoveOlderBarrels)
        foreach AllActors(class'TOBarrel',NewBarrel)
            NewBarrel.Destroy();

    foreach AllActors(class'PathNode',PN)
    {
        if (curb==nbmaxbarrel) break;
        if (Rand(2)==1)
        {
            NewBarrel=Spawn(Class'TOBarrel',,,PN.Location);
            curb++;
            if (DamageToExplode!=0) NewBarrel.Health=DamageToExplode;
            NewBarrel.TimeBeforeExplode=DelayBeforeExplosion;
        }
    }
}

defaultproperties
{
    NbMaxBarrel=16
    DamageToExplode=40
    DelayBeforeExplosion=1
    bRemoveOlderBarrels=True
}

