//=============================================================================
// LesserBrute.
//=============================================================================
class TOMALesserBrute extends TOMABrute;

function PlayRunning()
{
	if (Focus == Destination)
	{
		LoopAnim('Walk', -1.3/GroundSpeed,,0.4);
		return;
	}	

	LoopAnim('Walk', StrafeAdjust(),,0.3);
}

function PlayWalking()
{
	LoopAnim('Walk', -1.3/GroundSpeed,,0.4);
}

function PlayMovingAttack()
{
	PlayAnim('WalkFire', 1.3);
}

function GoBerserk()
{
	bLongBerserk = false;
	if ( bBerserk || ((Health < 0.75 * Default.Health) && (FRand() < 0.7)) )
		bBerserk = true;
	else 
		bBerserk = false;
	if ( bBerserk )
	{
		AccelRate = 4 * AccelRate;
		GroundSpeed = (2.1 + 0.2 * skill) * Default.GroundSpeed;
	}
}

state TacticalMove
{
ignores SeePlayer, HearNoise;

	function AnimEnd()
	{
		If ( bBerserk )
			LoopAnim('Charge', -1.1/GroundSpeed,,0.5);
		else
			PlayCombatMove();
	}
			
	function BeginState()
	{
		GoBerserk();
		Super.BeginState();
	}

	function EndState()
	{
		if ( bBerserk )
		{
			GroundSpeed = Default.GroundSpeed;
			AccelRate = Default.AccelRate;
		}
		Super.EndState();
	}
}

defaultproperties
{
     WhipDamage=14
     CarcassType=Class'UnrealShare.LesserBruteCarcass'
     RefireRate=0.2
     GroundSpeed=130
     AccelRate=400
     Health=180
     ReducedDamageType=None
     ReducedDamagePct=0
     Skin=Texture'UnrealShare.Skins.Brute3'
     DrawScale=0.8
     Fatness=110
     CollisionRadius=42
     CollisionHeight=42
     Mass=250
     Buoyancy=240
     NameOfMonster="LesserBrute"
	MoneyDroped=300
	sshot1=""
}
