//=============================================================================
// TO_BlockingPath
//
// Created by EMH_Mark3
//
// When trigged, this PathNode will 'Close', preventing the bots (and hostages)
// from going trought it.
//=============================================================================
// Todo:
// reset ExtraCost to 0 everyround.

class TO_BlockingPath expands NavigationPoint;
  

///////////////////////////////////////
// Trigger 
///////////////////////////////////////

function Trigger( actor Other, pawn EventInstigator )
{
	ExtraCost = 100000000;
}


///////////////////////////////////////
// defaultproperties 
///////////////////////////////////////

defaultproperties
{
}
