//=============================================================================
// TO_DamageMover.
// Created by EMH_Mark3
//
// Permits movers to have 'Health points'. When the mover's health points are
// depleated, the mover is trigged.
//=============================================================================
// Todo:
// reset RemainingHealth to MoverHealth everyround.

class TO_DamageMover expands Mover;

var(TO_DamageMover) int			MoverHealth;			// Number of 'Health points' the mover has
var									int			RemainingHealth;		// Number of remaining 'Health points'
  

///////////////////////////////////////
// PostBeginPlay 
///////////////////////////////////////

function PostBeginPlay()
{
	RemainingHealth = MoverHealth;		
	Super.PostBeginPlay();
}


///////////////////////////////////////
// TakeDamage 
///////////////////////////////////////
// When damaged
function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, name damageType)
{
	RemainingHealth = RemainingHealth - Damage;

	if ( RemainingHealth <= 0 ) 
	{
		self.Trigger(self, instigatedBy);
		if (!bTriggerOnceOnly) 
			RemainingHealth = MoverHealth;
	}
}


///////////////////////////////////////
// defaultproperties 
///////////////////////////////////////

defaultproperties
{
     MoverHealth=100
}
