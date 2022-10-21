class TOST_FlashBang extends TOST_GrenadeAway;

simulated function Explosion (Vector HitLocation)
{
	local S_Player P;
	local int i;
	local int Angle;
	local UT_SpriteSmokePuff S;
	local float dist;
	local float Percent;
	local Vector ViewPoint;
	local Vector tmp;
	local Rotator ViewAngle;

	bHidden=True;
	Spawn(Class'TO_ExplFlash',,,HitLocation);
	foreach RadiusActors(Class'S_Player',P,7000.00)
	{
		i++;
		if ( i > 50 )
		{
			goto JL017F;
		}
		ViewPoint=P.Location;
		ViewPoint.Z += P.BaseEyeHeight;
		if (  !P.bNotPlaying && FastTrace(ViewPoint,Location + vect(0.00,0.00,8.00)) )
		{
			ViewAngle=P.ViewRotation - rotator(P.Location - Location);
			Angle=Abs((ViewAngle.Yaw & 65535) / 182 - 180);
			dist=VSize(P.Location - Location);
			if ( dist < 300 )
			{
				P.SetBlindTime(10.00);
			}
			else
			{
				Percent=10.00 - Angle / 45.00;
				P.SetBlindTime(Percent * (1.00 - dist / 7200.00));
			}
		}
JL017F:
	}
	if ( Level.NetMode != 1 )
	{
		S=Spawn(Class'UT_SpriteSmokePuff');
		S.DrawScale=2.00 + 0.50 * FRand();
		S.RemoteRole=ROLE_None;
	}
	Destroy();
}

defaultproperties
{
    ImpactPitch=1.20
    Mesh=LodMesh'TOModels.wgrenadeflash'
}

