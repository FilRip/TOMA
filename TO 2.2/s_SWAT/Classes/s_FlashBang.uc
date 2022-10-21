//=============================================================================
// s_FlashBang
//=============================================================================
//
// Tactical Ops 
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen and Benoit "JAH" Delayen
//=============================================================================

class s_FlashBang extends s_GrenadeAway;


///////////////////////////////////////
// BeginPlay
///////////////////////////////////////

simulated function BeginPlay()
{
	local	Texture	GrenadeSkin;

	GrenadeSkin = Texture(DynamicLoadObject("TOModels.gren_flash", class'Texture'));
	MultiSkins[1] = GrenadeSkin;	

	Super.BeginPlay();
}


///////////////////////////////////////
// Explosion
///////////////////////////////////////
 
simulated function Explosion(vector HitLocation)
{
	local s_Player P;
	local int i;
	local	ut_SpriteSmokePuff	s;
	local	TO_GrenadeExplosion	expl;

	bHidden = true;

	expl = spawn(class'TO_ExplFlash',,,HitLocation);
/*	expl.LightHue = 160;
  expl.LightSaturation = 200;
	expl.Scale = 0.1;*/
	//expl.RemoteRole = ROLE_None;
	
	foreach VisibleActors(class's_Player', P)
	{
		if (!P.bNotPlaying && VSize(P.Location - Location) < 7200)
			P.SetBlindTime(15.0 * (1.0 - VSize(Location - P.Location) / 7200));
		i++;
		if ( i>150 )
			break;
	}

	if ( Level.NetMode != NM_DedicatedServer )
	{
		s = Spawn(class'ut_SpriteSmokePuff');
		s.DrawScale = 2.0 + 0.5* FRand(); 
		//s.RemoteRole = ROLE_None;
	}

	//spawn(class's_ExplosionSmall',,,Location);	
	Destroy();
}


///////////////////////////////////////
// defaultproperties 
///////////////////////////////////////

defaultproperties
{
     ImpactPitch=1.200000
}
