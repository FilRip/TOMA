//================================================================================
// TOST_ProjgasGren.
//================================================================================
class TOST_ProjGasGren extends TOST_ProjSmokeGren;

var int gastime;
var TOSTPiece Piece;

simulated function BeginPlay ()
{
	Super.BeginPlay();
	gastime=120;
	SetTimer(4.00,False);
	Enable('Timer');
}

function HurtEffect ()
{
	local PlayerPawn P;

	foreach VisibleCollidingActors(class 'PlayerPawn', P, gastime, Location)
	{
		if ( P.Health > 0 )
		{
			Piece.params.param6 = p;
			Piece.sendClientMessage(554);
		}
	}
}

simulated function Timer ()
{
	gastime += 19;
	if ( bExploded && !bHitWater )
	{
		if ( Level.NetMode != 1 )
		{
			Spawn(Class'TOST_SmokeGreen',,,Location + vect(0.00,0.00,2.00));
			if ( Level.bDropDetail ||  !Level.bHighDetailMode )
			{
				SetTimer(1.50 + FRand() * 0.50,False);
			}
			else
			{
				SetTimer(1.00 + FRand() * 0.20,False);
			}
			return;
		}
	}
	else
	{
		Super.Timer();
	}
	if ( Level.NetMode != 3 )
	{
		HurtEffect();
	}
	SetTimer(1.50,False);
}

defaultproperties
{
    bServerTiming=True
    ImpactPitch=0.50
    LifeSpan=34.00
    AmbientSound=Sound'TODatas.Weapons.SmokeGrenSound'
    Mesh=LodMesh'TearGas'
    SoundRadius=64
    SoundVolume=20
}

