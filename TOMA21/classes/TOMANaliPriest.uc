//=============================================================================
// NaliPriest.
//=============================================================================
class TOMANaliPriest extends TOMANali;

state FadeOut
{
	ignores HitWall, EnemyNotVisible, HearNoise, SeePlayer;

	function TakeDamage(int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, name damageType)
	{
		Global.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
		if (health<=0)
			return;
		if (NextState=='TakeHit')
		{
			NextState='Attacking';
			NextLabel='Begin';
			GotoState('TakeHit');
		}
		else if (Enemy!=None)
			GotoState('Attacking');
	}

	function Tick(float DeltaTime)
	{
	}

	function BeginState()
	{
		bFading = false;
		Disable('Tick');
	}

	function EndState()
	{
		bUnlit = false;
		Style = STY_Normal;
		ScaleGlow = 1.0;
		fatness = Default.fatness;
	}

	function Timer()
	{
		cptbe++;
		if (cptbe>=TimeToShockWave)
		{
			Spawn(class'TOMAGreaterShockWave',,,self.location);
			cptbe=0;
		}
		GotoState('Roaming');
	}
Begin:
	Acceleration = Vect(0,0,0);
	if ( NearWall(100) )
	{
		PlayTurning();
		TurnTo(Focus);
	}
	Enable('Tick');
	PlayAnim('Levitate', 0.3, 1.0);
	FinishAnim();
	PlayAnim('Levitate', 0.3);
	FinishAnim();
	LoopAnim('Levitate', 0.3);
	SetTimer(1,true);
}

defaultproperties
{
	Skin=Texture'UnrealShare.Skins.JNali2'
	NameOfMonster="NaliPriest"
	sshot1="TOMATex21.Sshot.NaliPriest"
}
