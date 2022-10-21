//=============================================================================
// s_PlayerCarcass
//=============================================================================
//
// Tactical Ops -- an Unreal Tournament modification
// -- http://www.planetunreal.com/tacticalops
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen and Benoit "JAH" Delayen
//=============================================================================

class s_PlayerCarcass extends TMaleBody;

 
///////////////////////////////////////
// SpawnHead
///////////////////////////////////////

function SpawnHead()
{
	local carcass carc;

	carc = Spawn(class's_PlayerHead');
	if ( carc != None )
		carc.Initfor(self);
}

///////////////////////////////////////
// Initfor
///////////////////////////////////////

function Initfor(actor Other)
{
	local int i;

	Super.InitFor(Other);

	for ( i=0; i<6; i++ )
		if (Pawn(Other).MultiSkins[i]!=None)
			Multiskins[i] = Pawn(Other).MultiSkins[i];	
	
	SetCollisionSize(Other.CollisionRadius + 4, CollisionHeight);
	if ( !SetLocation(Location) )
		SetCollisionSize(CollisionRadius - 4, CollisionHeight);
}


function AnimEnd()
{
	Super(UTHumanCarcass).AnimEnd();
	/*
	local name NewAnim;

	if ( AnimSequence == 'Dead9' )
		bJerking = true;

	if ( !bJerking )
		Super.AnimEnd();
	else if ( (Level.TimeSeconds - LastHit < 0.2) && (FRand() > 0.02) )
	{
		NewAnim = Jerks[Rand(4)];
		if ( NewAnim == AnimSequence )
		{
			if ( NewAnim == Jerks[0] )
				NewAnim = Jerks[1];
			else
				NewAnim = Jerks[0];
		}
		TweenAnim(NewAnim, 0.15);
	}
	else
	{
		bJerking = false;
		PlayAnim('Dead9B', 1.1, 0.1);
	}
	*/
}


///////////////////////////////////////
// defaultproperties
///////////////////////////////////////

defaultproperties
{
     MasterReplacement=Class's_SWAT.s_PlayerMasterChunks'
     ReducedHeightFactor=0.230000
     CollisionHeight=12.000000
}
