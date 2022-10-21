//----------------------------------------------------------------------------
// Project : TOST
// File    : TOSTFlashbang.uc
// Version : 1.2
// Author  : BugBunny
//----------------------------------------------------------------------------

class TOSTFlashBang extends s_GrenadeAway;

simulated function BeginPlay()
{
	local	Texture	GrenadeSkin;

	GrenadeSkin = Texture(DynamicLoadObject("TOModels.gren_flash", class'Texture'));
	MultiSkins[1] = GrenadeSkin;	

	Super.BeginPlay();
}

simulated function Explosion(vector zzHitLocation)
{
	local s_Player zzP;
	local int zzi;
	local ut_SpriteSmokePuff	zzs;
	local TO_GrenadeExplosion	zzexpl;

	bHidden = true;

	zzexpl = spawn(class'TO_ExplFlash',,,zzHitLocation);
	if (ROLE == ROLE_Authority) {
		foreach VisibleActors(class's_Player', zzP)
		{
			if (!zzP.bNotPlaying && VSize(zzP.Location - Location) < 7200)
				zzP.SetBlindTime(15.0 * (1.0 - VSize(Location - zzP.Location) / 7200));
			zzi++;
			if ( zzi>150 )
				break;
		}
	}

	if ( Level.NetMode != NM_DedicatedServer )
	{
		zzs = Spawn(class'ut_SpriteSmokePuff');
		zzs.DrawScale = 2.0 + 0.5* FRand(); 
	}

	Destroy();
}

defaultproperties
{
     ImpactPitch=1.200000
}
