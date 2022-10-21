//=============================================================================
// s_SWATPathNode
//=============================================================================
//
// Tactical Ops
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen and Benoit "JAH" Delayen
//=============================================================================

class s_SWATPathNode extends NavigationPoint;
  
var(SWAT_NP)	name						NextNP[8];
var(SWAT_NP)	float						PauseTime;
var(SWAT_NP)	bool						bLastOne;

// Internal
var						s_SWATPathNode	NextNavPoint[8];


///////////////////////////////////////
// PreBeginPlay 
///////////////////////////////////////

function PreBeginPlay()
{
	local	int							i, j;
	local	s_SWATPathNode	SPN;

	//log("s_SWATPathNode - PreBeginPlay");
	j = 0;
	for (i = 0; i < 8; i++)
	{
		//find the patrol point with the tag specified by Nextpatrol
		if (NextNP[i] != '')
		{
			foreach AllActors(class 's_SWATPathNode', SPN)
				if (SPN.Tag == NextNP[i] && SPN != Self)
				{
					//log("Found s_SWATPathNode: "$NextNP[i]);
					NextNavPoint[j] = SPN;
					j++;
					break;
				}
		}
	}
	
	Super.PreBeginPlay();
}

 
///////////////////////////////////////
// defaultproperties 
///////////////////////////////////////

defaultproperties
{
     bDirectional=True
     Texture=Texture'TODatas.Engine.SWATPathNode'
}
