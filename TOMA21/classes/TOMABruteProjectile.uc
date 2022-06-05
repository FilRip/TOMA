class TOMABruteProjectile extends BruteProjectile;

auto state Flying
{
	simulated function Timer()
	{
		local SpriteSmokePuff bs;

		if (Level.NetMode!=NM_DedicatedServer)
		{
			bs = Spawn(class'SpriteSmokePuff');
			bs.RemoteRole = ROLE_None;
		}
		SetTimer(TimerDelay,True);
		TimerDelay += 0.01;
	}

	simulated function ProcessTouch (Actor Other, Vector HitLocation)
	{
		if (Other != instigator)
			Explode(HitLocation,Vect(0,0,0));
	}

	function BlowUp(vector HitLocation)
	{
		if (Instigator!=None)
        {
            HurtRadius(damage,50+instigator.skill*45,'exploded',MomentumTransfer,HitLocation);
            MakeNoise(1.0);
            if (ImpactSound!=None) PlaySound(ImpactSound);
        } else destroy();
	}

	simulated function Explode(vector HitLocation, vector HitNormal)
	{
		local SpriteBallExplosion s;

		BlowUp(HitLocation);
		s = spawn(class 'SpriteBallExplosion',,'',HitLocation+HitNormal*10 );
		s.RemoteRole = ROLE_None;
		Destroy();
	}

	simulated function AnimEnd()
	{
		LoopAnim('Flying');
		Disable('AnimEnd');
	}

	function SetUp()
	{
		PlaySound(SpawnSound);
		Velocity = Vector(Rotation) * speed;
		if ( ScriptedPawn(Instigator) != None )
		{
			Speed = ScriptedPawn(Instigator).ProjectileSpeed;
			if ( Instigator.IsA('LesserBrute') )
				Damage *= 0.7;
		}
	}

	simulated function BeginState()
	{
		if ( Level.NetMode != NM_DedicatedServer )
		{
			PlayAnim('Ignite',0.5);
			if (Level.bHighDetailMode) TimerDelay = 0.03;
			else TimerDelay = 5.0;;
			Timer();
		}
		SetUp();
	}

Begin:
	Sleep(7.0);
	Explode(Location,vect(0,0,0));
}

defaultproperties
{
}

