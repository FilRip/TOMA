//=============================================================================
// TO_ExplosionChain.
// Created by EMH_Mark3
// 
// Permits 'Respawning' ExplosionChains (ExplosionChain that can be triggered
// more than once)
// WARNING: You MUST set the RespawnTime property correctly !
//=============================================================================
class TO_ExplosionChain expands ExplosionChain;

var(TO_ExplosionChain) int	RespawnTime;	// Time after witch the ExplosionChain respawns.
												// Warning ! Setting this too low could result in
												// infinite looping explosions !!
  
///////////////////////////////////////
// Exploding 
///////////////////////////////////////

state Exploding
{
	ignores TakeDamage;

	function Timer()
	{
		local UT_SpriteBallExplosion f;
		
		bExploding = true;
 		HurtRadius(damage, Damage+100, 'Explosion', MomentumTransfer, Location);
 		f = spawn(class'UT_SpriteBallExplosion',,,Location + vect(0,0,1)*16,rot(16384,0,0)); 
 		f.DrawScale = (Damage/100+0.4+FRand()*0.5)*Size;
		bExploding = false;
		GotoState('Waiting');
	}
	
	function BeginState()
	{
		bExploding = True;
		SetTimer(DelayTime+FRand() * DelayTime * 2, false);
	}

}


///////////////////////////////////////
// Waiting 
///////////////////////////////////////

state Waiting
{
	ignores TakeDamage;

	function Timer()
	{
		GotoState('');
	}	

	function BeginState()
	{
		if (RespawnTime == 0)
			SetTimer(5, False);
		else
			SetTimer(RespawnTime, False);
	}
}


///////////////////////////////////////
// defaultproperties 
///////////////////////////////////////

defaultproperties
{
     RespawnTime=5
}
