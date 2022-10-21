//=============================================================================
// s_MoneyPickUp
//=============================================================================
//
// Tactical Ops -- an Unreal Tournament modification
// -- http://www.planetunreal.com/tacticalops
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen and Benoit "JAH" Delayen
//=============================================================================

class s_MoneyPickUp extends TournamentPickup;


var()		int		Amount;


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
		if ( ( Other.IsA('s_Player') && !(s_Player(Other).bNotPlaying) ) || ( Other.IsA('s_Bot') && !s_Bot(Other).bNotPlaying ) )
		{
			if (Level.Game != None)
			{
				s_SWATGame(Level.Game).AddMoney(Pawn(Other), Amount);
			}
		}
		else
			return;

		if ( PickupMessageClass == None )
			Pawn(Other).ClientMessage(PickupMessage$Amount, 'Pickup');
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
     Amount=300
     bAmbientGlow=False
     PickupMessage="You found some money!"
     RespawnTime=3.000000
     PickupViewMesh=LodMesh'TOModels.mny1'
     MaxDesireability=0.300000
     PickupSound=Sound'TODatas.Misc.buyammo'
     Physics=PHYS_Falling
     Mesh=LodMesh'TOModels.mny1'
     AmbientGlow=0
     CollisionRadius=10.000000
     CollisionHeight=10.000000
     bCollideWorld=True
}
