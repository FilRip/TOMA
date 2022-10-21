//================================================================================
// TOST_ProjSmokeGren.
//================================================================================
class TOST_ProjSmokeGren extends TO_ProjSmokeGren;

simulated function ProcessTouch (Actor Other, Vector HitLocation)
{
	if ( bBlowWhenTouch && (Other != Level) && ((Other != Instigator) || bCanHitOwner) )
	{
		Explosion(HitLocation - Other.Location);
	}
	else
	{
		if ( bBounce )
		{
			if (  !bCanHitOwner && (Other == Instigator) )
			{
				return;
			}
			Other.TakeDamage(4,Instigator,HitLocation,Velocity,'Explosion');
			HitWall(Normal(HitLocation - Other.Location),Other);
			ReplicateHit();
		}
	}
}

function ReplicateHit()
{
	local rotator velorot;
	local TOST_ProjSmokeGren g;

	if ( role == 4 )
	{//spawn new nade client side
		velorot.pitch = Velocity.X;
		velorot.yaw = Velocity.Y;
		velorot.roll = Velocity.Z;
		g = spawn(class,,,Location,velorot);
		g.ExpTiming = ExpTiming-(TimePassed+0.30);
		g.LifeSpan = LifeSpan;
		g.Instigator = Instigator;
		g.hited();
		destroy();
	}
}

final simulated function Hited()
{
	Velocity.X = Rotation.pitch;
	Velocity.Y = Rotation.yaw;
	Velocity.Z = Rotation.roll;

	if ( Level.bHighDetailMode &&  !Level.bDropDetail )
	{
		SmokeRate=0.05;
	}
	else
	{
		SmokeRate=0.15;
	}
	if ( Role == 4 )
	{
		MaxSpeed=2000.00;
		RandSpin(50000.00);
		bCanHitOwner=True;
		ColTiming=LifeSpan;
		if ( bNoSmoke )
		{
			Disable('Tick');
		}
		if ( self.IsA('TOST_ProjSmokeGren') && bServerTiming )
		{
			SetTimer(ExpTiming,False);
		}
		else
		{
			if ( bServerTiming )
			{
				SetTimer(0.30,True);
			}
		}
	}
}
