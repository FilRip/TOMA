//=============================================================================
// s_SpecialItem
//=============================================================================
//
// Tactical Ops -- an Unreal Tournament modification
// -- http://www.planetunreal.com/tacticalops
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen and Benoit "JAH" Delayen
//=============================================================================

class s_SpecialItem extends TournamentPickup;


var		float		Weight;


///////////////////////////////////////
// BecomeItem 
///////////////////////////////////////

function BecomeItem()
{
	local Bot B;
	local Pawn P;

	Super(Pickup).BecomeItem();

	if ( Instigator.IsA('Bot') || Level.Game.bTeamGame || !Level.Game.IsA('TO_DeathMatchPlus')
		|| TO_DeathMatchPlus(Level.Game).bNoviceMode
		|| (TO_DeathMatchPlus(Level.Game).NumBots > 4) )
		return;

	// let high skill bots hear pickup if close enough
	for ( P=Level.PawnList; P!=None; P=P.NextPawn )
	{
		B = Bot(p);
		if ( (B != None)
			&& (VSize(B.Location - Instigator.Location) < 800 + 100 * B.Skill) )
		{
			B.HearPickup(Instigator);
			return;
		}
	}
}


///////////////////////////////////////
// Pickup 
///////////////////////////////////////

auto state Pickup
{	
	function Touch( actor Other )
	{
		if ( Other.IsA('s_Player') && !s_Player(Other).bDead )
		{
			if (s_Player(Other).bSpecialItem == true)
				return;

			s_Player(Other).SpecialItemClass = Class;
			s_Player(Other).bSpecialItem = true;
			s_Player(Other).CalculateWeight();
		}
		else if ( Other.IsA('s_Bot') && !s_Bot(Other).bDead )
		{
			if (s_Bot(Other).bSpecialItem == true)
			{
				if (s_Bot(Other).OrderObject == Self)
					s_Bot(Other).OrderObject = None;
				return;
			}
 
			s_Bot(Other).SpecialItemClass = Class;
			s_Bot(Other).bSpecialItem = true;
			s_Bot(Other).CalculateWeight();
		}
		else
			return;

		if ( PickupMessageClass == None )
			Pawn(Other).ClientMessage(PickupMessage, 'Pickup');
		else
			Pawn(Other).ReceiveLocalizedMessage( PickupMessageClass, 0, None, None, Self.Class );

		PlaySound (PickupSound, ,2.0);
		Destroy();
	}
}


///////////////////////////////////////
// BotDesireability 
///////////////////////////////////////

event float BotDesireability(Pawn Bot)
{
	if (Bot.IsA('s_NPC'))
		return 0.0;
	else if (Bot.IsA('s_Bot') && s_Bot(Bot).bSpecialItem == true)
		return 0.0;
	else
		return MaxDesireability;
}

 
// PickupViewMesh=LodMesh's_SWAT.mny1'
// PickupViewMesh=LodMesh's_SWAT.hk-sl8'
///////////////////////////////////////
// defaultproperties 
///////////////////////////////////////

defaultproperties
{
     Weight=30.000000
     bAmbientGlow=False
     PickupMessage="You found some money!"
     RespawnTime=3.000000
     MaxDesireability=0.700000
     PickupSound=Sound'TODatas.Misc.buyammo'
     Physics=PHYS_Falling
     AmbientGlow=0
     CollisionRadius=10.000000
     CollisionHeight=10.000000
     bCollideWorld=True
}
