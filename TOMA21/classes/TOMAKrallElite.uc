//=============================================================================
// KrallElite.
//=============================================================================
class TOMAKrallElite extends TOMAKrall;

function PreBeginPlay()
{
	Super.PreBeginPlay();
	bCanDuck = true;
}

function PlayMeleeAttack()
{
	local float decision;

	decision = FRand();
	if (!bSpearToss)
		decision *= 0.65;
	if (decision < 0.22)
		PlayAnim('Strike1');
 	else if (decision < 0.44)
   		PlayAnim('Strike2');
 	else if (decision < 0.65)
 		PlayAnim('Strike3');
 	else
 		PlayAnim('Throw');
}

defaultproperties
{
     StrikeDamage=28
     ThrowDamage=38
     PoundDamage=28
     MinDuckTime=5
     bLeadTarget=True
     RangedProjectile=Class'UnrealI.EliteKrallBolt'
     ProjectileSpeed=880
     bCanStrafe=True
     Health=200
     UnderWaterTime=-1
     Skill=1
     Skin=Texture'UnrealI.Skins.ekrall'
     NameOfMonster="KrallElite"
	MoneyDroped=300
	sshot1="TOMATex21.Sshot.KrallElite"
}
