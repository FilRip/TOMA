class TOMAC4 extends s_C4;

var class<TOMAExplosiveC4> ExplosiveC4Class;

function Fire(float Value)
{
	if (PlayerPawn(Owner)==None)
	{
		Pawn(Owner).SwitchToBestWeapon();
		return;
	}
	OriginalLocation=Owner.Location;
	PlayFiring();
	GotoState('ServerArmingBomb');
	bCanPlant=True;
	ClientForceFire();
}

function PlaceC4()
{
	local Pawn PawnOwner;
	local TOMAExplosiveC4 c4;
	local TOMAMod TG;
	local TO_PRI TOPRI;
	local TO_BRI TOBRI;
	local PlayerReplicationInfo PRI;

	TG=TOMAMod(Level.Game);
	if ((TG!=None) && (!TG.IsRoundPeriodPlaying()))
		return;
	bPlanted=True;
	PawnOwner=Pawn(Owner);
	PawnOwner.bFire=0;
	PawnOwner.SwitchToBestWeapon();
	PawnOwner.ChangedWeapon();
	c4=Spawn(ExplosiveC4Class,,,OriginalLocation);
	c4.PlayerInstigator=Pawn(Owner);
	c4.bPlantedInBombingSpot=True;
	c4.PlaySound(Sound'TODatas.Weapons.bomb_plant',SLOT_None);
//	TG.SendGlobalBotObjective(c4,1,1,'O_DefuseC4',False);
	if ((TG!=None) && (PawnOwner!=None))
	{
		if (PawnOwner.PlayerReplicationInfo!=None)
		{
			TOPRI=TO_PRI(PawnOwner.PlayerReplicationInfo);
			TOBRI=TO_BRI(PawnOwner.PlayerReplicationInfo);
			if (TOPRI!=None)
			{
				TOPRI.bHasBomb=False;
				PRI=TOPRI;
			}
			else
			{
				if (TOBRI!=None)
				{
					TOBRI.bHasBomb=False;
					PRI=TOBRI;
				}
			}
		}
		TG.bBombPlanted=True;
		if (TG.bSinglePlayer)
			TG.C4Planted(OriginalLocation,c4);
		TG.BroadcastLocalizedMessage(Class's_MessageRoundWinner',12,PRI);
		if (Pawn(Owner)!=None)
			Pawn(Owner).SendGlobalMessage(None,'Other',1,10);
	}
	Destroy();
}

state ServerArmingBomb
{
	ignores ChangeFireMode, s_ReloadW;

	function Fire(float F)
	{
	}

	simulated function Tick(float DeltaTime)
	{
		Super.Tick(DeltaTime);

		if ((Pawn(Owner)==None) || (Pawn(Owner).bFire==0))
		{
			AmbientSound=None;
			Finish();
		}
		if ((s_Player(Owner)!=none) && ((Pawn(Owner).bDuck!=1) || (Abs(Pawn(Owner).Velocity.z)>10)))
		{
			AmbientSound=None;
			Finish();
		}
	}

	simulated function AnimEnd()
	{
		Pawn(Owner).bFire=0;
		AmbientSound=None;
		bNoDrop=true;
		PlaceC4();
	}

	simulated function EndState()
	{
		AmbientSound=None;
	}
Begin:
	Sleep(0);
}

function DropBomb(bool bmessage)
{
	Local Pawn P;
	local TO_PRI TOPRI;
	local TO_BRI TOBRI;
	local s_SWATGame SG;
	local PlayerReplicationInfo PRI;

	SG=s_SWATGame(Level.game);
	P=Pawn(Owner);

	//log("s_C4 - DropBomb");

	if ((P!=None) && (P.PlayerReplicationInfo!=None))
	{
		TOPRI=TO_PRI(P.PlayerReplicationInfo);
		TOBRI=TO_BRI(P.PlayerReplicationInfo);

		if (TOPRI!=None)
		{
			TOPRI.bHasBomb=false;
			PRI=TOPRI;
		}
		else if (TOBRI!=None)
		{
			TOBRI.bHasBomb=false;
			PRI=TOBRI;
		}
	}

	if (SG.IsRoundPeriodPlaying())
	{
		if (bMessage)
		{
/*			if (SG!=None)
				SG.BroadcastLocalizedMessage(class's_MessageRoundWinner',11,PRI);*/

			// Tell Ts to pickup C4
//			SG.SendGlobalBotObjective(Self,1,0,'O_GotoLocation',false);
			SG.bBombDropped=true;
		}
	}
}

function bool IsInBombingSpot()
{
	return true;
}

defaultproperties
{
	WeaponClass=5
	InventoryGroup=5
	ExplosiveC4Class=Class'TOMAExplosiveC4'
	Price=10000
	ItemName="C4 Explosive"
}
