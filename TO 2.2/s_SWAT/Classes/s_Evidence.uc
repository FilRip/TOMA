//=============================================================================
// s_Evidence
//=============================================================================
//
// Tactical Ops -- an Unreal Tournament modification
// -- http://www.planetunreal.com/tacticalops
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen and Benoit "JAH" Delayen
//=============================================================================

class s_Evidence extends TournamentPickup
	abstract;


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
		if (Other.IsA('s_Player') && !(s_Player(Other).bDead))
		{
			s_Player(Other).Evidence[s_Player(Other).Eidx] = Class;
			s_Player(Other).Eidx = s_Player(Other).Eidx + 1;
			if (s_Player(Other).Eidx > 9)
				s_Player(Other).Eidx = 9;
		}
		else if (Other.IsA('s_Bot')  && !(s_Bot(Other).bDead))
		{
			s_Bot(Other).Evidence[s_Bot(Other).Eidx] = Class;
			s_Bot(Other).Eidx = s_Bot(Other).Eidx + 1;
			if (s_Bot(Other).Eidx > 9)
				s_Bot(Other).Eidx = 9;
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
	return MaxDesireability;
}
 

///////////////////////////////////////
// defaultproperties 
///////////////////////////////////////

defaultproperties
{
     bAmbientGlow=False
     PickupMessage="You found an evidence."
     RespawnTime=3.000000
     MaxDesireability=0.300000
     PickupSound=Sound'TODatas.Misc.buyammo'
     Physics=PHYS_Falling
     AmbientGlow=0
     bCollideWorld=True
}
