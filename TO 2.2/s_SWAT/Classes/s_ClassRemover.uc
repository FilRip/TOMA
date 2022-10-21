//=============================================================================
// s_ClassRemover
//=============================================================================
//
// Tactical Ops
// - http://www.planetunreal.com/tacticalops
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen and Benoit "JAH" Delayen
//=============================================================================

class s_ClassRemover expands Actor;

var() name	Actor[32];	// actors being removed
 

///////////////////////////////////////
// BeginPlay
///////////////////////////////////////

function BeginPlay()
{
	local Actor					replaced, replacer, foundActor;
	local class<actor>	ReplacedClass, ReplacerClass;
	local int						i;
	local int						j;
	local vector				X,Y,Z;
	
	foreach AllActors(class'Actor', foundActor)
	{
		for(i = 0; i < 32; i++)
			if (Actor[i] != '' && foundActor.IsA(Actor[i]))
			{
				if (foundActor.IsA('Inventory'))
				{
					if (Inventory(foundActor).IsInState('Pickup') || !Inventory(foundActor).bHeldItem )
						if(!replaced.Destroy())
							log("ERROR! Could not destroy "$replaced);
				}
				else 				
					if(!replaced.Destroy())
						log("ERROR! Could not destroy "$replaced);
			}
	}
	/*
	for(i = 0; i < 32; i++)
		if (Actor[i] != '')
		{
			ReplacedClass = class<actor>(DynamicLoadObject( ReplacedActor[i], class'Class' ));
			if (ReplacedClass != None)
			{
				foreach AllActors(ReplacedClass, foundActor)
				{
					if (foundActor.class != ReplacedClass)
						continue;
						
					replaced = foundActor;
											
					if ((replaced.IsA('Inventory')) && ( Inventory(replaced).IsInState('Pickup') || !Inventory(replaced).bHeldItem ) )					
						if(!replaced.Destroy())
							log("ERROR! Could not destroy "$replaced);
				}
			}
		}
	*/
	Destroy();
}

  
///////////////////////////////////////
// defaultproperties
///////////////////////////////////////

defaultproperties
{
     Actor(0)='
     Actor(1)='
     Actor(2)='
     Actor(3)='
     Actor(4)='
     Actor(5)='
     Actor(6)='
     Actor(7)='
     Actor(8)='
     Actor(9)='
     Actor(10)='
     Actor(12)='
     Actor(13)='
     Actor(14)='
     Actor(15)='
     Actor(16)='
}
