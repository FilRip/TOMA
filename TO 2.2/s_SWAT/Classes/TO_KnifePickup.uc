//=============================================================================
// TO_KnifePickup.
//
// Tactical Ops 
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen
// Created by Mathieu 'EMH_Mark3' Mallet
//=============================================================================

class TO_KnifePickup expands TournamentPickup;


///////////////////////////////////////
// BecomeItem 
///////////////////////////////////////
simulated function PostBeginPlay()
{
	self.PrePivot.z = -3.2;
	self.PrePivot.y = -4;
}


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
		local byte		clipSize;
		local byte 		clipAmmo;
		local s_Bplayer 	player;
		local s_Bot		bot;
		local s_knife	knife;

		if (Other.IsA('s_BPlayer') && !(s_Player(Other).bDead))
		{
			player = s_Bplayer(Other);
			if (player != None) {
				knife = s_Knife(player.FindInventoryType(Class's_Knife'));
				if (knife != None)
					if (knife.clipAmmo < knife.clipSize)
						knife.clipAmmo++;
					else
						return;
			}

		}
		else if (Other.IsA('s_Bot')  && !(s_Bot(Other).bDead))
		{
			bot = s_Bot(Other);
			if (bot != None) {
				knife = s_Knife(bot.FindInventoryType(Class's_Knife'));
				if (knife != None)
					if (knife.clipAmmo < knife.clipSize)
						knife.clipAmmo++;
					else
						return;
			}

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
	
	simulated function Landed( vector HitNormal )
	{
		self.SetCollisionSize(10,10);
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
     PickupMessage="Picked up a knife."
     PlayerViewMesh=LodMesh'TOModels.tknife'
     PickupViewMesh=LodMesh'TOModels.tknife'
     ThirdPersonMesh=LodMesh'TOModels.tknife'
     MaxDesireability=0.200000
     PickupSound=Sound'TODatas.Misc.buyammo'
     Physics=PHYS_Falling
     LifeSpan=140.000000
     Mesh=LodMesh'TOModels.tknife'
     DrawScale=1.020000
     AmbientGlow=0
     CollisionRadius=20.000000
     CollisionHeight=15.000000
     bCollideWorld=True
}
