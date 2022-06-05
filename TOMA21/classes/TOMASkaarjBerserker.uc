//=============================================================================
// SkaarjBerserker.
//=============================================================================
class TOMASkaarjBerserker extends TOMASkaarjWarrior;

function WhatToDoNext(name LikelyState, name LikelyLabel)
{
	local Pawn aPawn;

	aPawn = Level.PawnList;
	while ( aPawn != None )
	{
		if ( (aPawn.IsA('PlayerPawn') || aPawn.IsA('ScriptedPawn'))
			&& (VSize(Location - aPawn.Location) < 500)
			&& CanSee(aPawn) )
		{
			if ( SetEnemy(aPawn) )
			{
				GotoState('Attacking');
				return;
			}
		}
		aPawn = aPawn.nextPawn;
	}

	Super.WhatToDoNext(LikelyState, LikelyLabel);
}

defaultproperties
{
     LungeDamage=40
     SpinDamage=40
     ClawDamage=20
     VoicePitch=0.3
     Aggressiveness=0.8
     Health=320
     Skill=1
     CombatStyle=1
     Skin=Texture'UnrealI.Skins.Skaarjw2'
     DrawScale=1.2
     Fatness=150
     CollisionHeight=56
     Mass=180
     Buoyancy=180
     RotationRate=(Yaw=50000)
     NameOfMonster="SkaarjBerserker"
	MoneyDroped=400
	sshot1="TOMATex21.Sshot.SkaarjBerserker"
}
