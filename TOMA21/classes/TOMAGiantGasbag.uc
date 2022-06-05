//=============================================================================
// GiantGasbag.
//=============================================================================
class TOMAGiantGasbag extends TOMAGasbag;

function SpawnBelch()
{
	local TOMAGasbag G;
	local vector X,Y,Z, projStart;
	local actor P;

	GetAxes(Rotation,X,Y,Z);
	projStart = Location + 0.5 * CollisionRadius * X - 0.3 * CollisionHeight * Z;
	if ((numChildren>1) || (FRand()>0.2))
	{
		P = spawn(RangedProjectile,self,'',projStart,AdjustAim(ProjectileSpeed,projStart,400,bLeadTarget,bWarnTarget));
		if (P!=None)
			P.DrawScale*=2;
	}
	else
	{
        TOMAMod(Level.Game).nbmonstres++;
		G=spawn(class'TOMA21.TOMAGasbag',,'',projStart+(0.6*CollisionRadius+class'TOMA21.TOMAGasbag'.Default.CollisionRadius)*X);
		if (G!=None)
		{
			G.Health*=TOMAMod(Level.Game).HealthMult;
			G.ParentBag=self;
			numChildren++;
		}
	}
}

defaultproperties
{
     PunchDamage=40
     PoundDamage=65
     Health=600
     CombatStyle=0.5
     DrawScale=3
     CollisionRadius=160
     CollisionHeight=108
     NameOfMonster="GiantGasBag"
	MoneyDroped=400
	sshot1="TOMATex21.Sshot.GiantGasbag"
}
