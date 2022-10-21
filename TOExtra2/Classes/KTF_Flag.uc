class KTF_Flag extends Decoration;

#EXEC OBJ LOAD NAME=TOExtraTex FILE=..\Textures\TOExtraTex.utx PACKAGE=TOExtraTex

var vector Home;
var Pawn Carrier;
var bool bDoGlow;
var byte WhatTeam;
var bool bRemoveWeapons;
var Inventory Inv;
var KeepTheFlag mutowner;

replication
{
	reliable if (Role==ROLE_Authority)
        Carrier,WhatTeam;
}

function Landed(vector HitNormall)
{
}

event FellOutOfWorld()
{
	SetLocation(Home);
	GotoState('HomeBase');
}

function Teleported()
{
    mutowner.DropFlag();
}

function PlaySoundToAll(sound s)
{
	local s_Player_T aPlayer;

	foreach allactors(class's_Player_T',aPlayer)
		if (aPlayer!=None)
			aPlayer.ClientPlaySound(s,,true);
}

state Carrying
{
	function Touch(Actor Other)
	{
	}

    function Tick(float deltatime)
    {
    }

begin:
    WhatTeam=Carrier.PlayerReplicationInfo.Team;
//	Enable('Tick');
	bCollideWorld=false;
	SetPhysics(PHYS_None);
	SetCollision(false,false,false);
	bHidden=true;
	if (bRemoveWeapons)
	{
    	for (inv=Carrier.Inventory;Inv!=None;Inv=Inv.Inventory)
            if ((Inv.IsA('S_Weapon')) && (Inv.Class!=Class's_Knife') && (Inv.Class!=Class'TO_Binocs'))
                s_SWATGame(Level.Game).AddMoney(Carrier,S_Weapon(Inv).price);
    	for (inv=Carrier.Inventory;Inv!=None;Inv=Inv.Inventory)
            if ((Inv.IsA('S_Weapon')) && (Inv.Class!=Class's_Knife') && (Inv.Class!=Class'TO_Binocs'))
                Inv.Destroy();
        Carrier.SwitchToBestWeapon();
	}
}

function SetAmbientToPlayer(Pawn P)
{
    if (!bDoGlow) return;
	P.AmbientGlow=255;
	P.LightEffect=LE_NonIncidence;
	P.LightRadius=5;
	P.LightType=LT_Steady;
	P.LightBrightness=255;
	P.LightSaturation=127;
	P.LightHue=32;
}

auto state HomeBase
{
	function Touch(Actor Other)
	{
		local Pawn P;

		P=Pawn(Other);
		if ((P!=None) && (P.bIsPlayer))
		{
        	if ((P.PlayerReplicationInfo==None) || (P.PlayerReplicationInfo.bIsSpectator) || (P.PlayerReplicationInfo.bWaitingPlayer))
                return;
			if (P.Health>0)
			{
                P.PlayerReplicationInfo.HasFlag=self;
                Carrier=P;
                bHidden=true;
                SetAmbientToPlayer(Pawn(Other));
                GotoState('Carrying');
                PlaySoundToAll(Sound'TFModelsF.flagtaken');
            }
		}
	}

	function BeginState()
	{
        WhatTeam=2;
		bHidden=false;
		bCollideWorld=true;
		SetCollision(true,false,false);
		Velocity.Z=300;
		SetPhysics(PHYS_Falling);
		if (Carrier!=None) Carrier.PlayerReplicationInfo.HasFlag=None;
		Carrier=None;
	}
}

state Dropped
{
	function Touch(Actor Other)
	{
		local Pawn P;

		P=Pawn(Other);
		if ((P!=None) && (P.bIsPlayer))
		{
        	if ((P.PlayerReplicationInfo==None) || (P.PlayerReplicationInfo.bIsSpectator) || (P.PlayerReplicationInfo.bWaitingPlayer))
                return;
			if (P.Health>0)
			{
                P.PlayerReplicationInfo.HasFlag=self;
                Carrier=P;
                bHidden=true;
                SetAmbientToPlayer(Pawn(Other));
                GotoState('Carrying');
                PlaySoundToAll(Sound'TFModelsF.flagtaken');
            }
		}
	}

	function BeginState()
	{
        WhatTeam=2;
		bHidden=false;
		bCollideWorld=true;
		SetCollision(true,false,false);
		Velocity.Z=300;
		SetPhysics(PHYS_Falling);
		if (Carrier!=None) Carrier.PlayerReplicationInfo.HasFlag=None;
		Carrier=None;
	}
}

function PostBeginPlay()
{
	local rotator rp;

	Super.PostBeginPlay();
	LoopAnim('pflag');
	rp.Pitch=0;
	rp.Yaw=0;
	rp.Roll=-7000;
	SetRotation(rp);
}

defaultproperties
{
	Mesh=TFModelsF.pflag
	DrawType=DT_Mesh
	Skin=TOExtraTex.TOAoTFlag
	bStatic=False
	DrawScale=0.6
	CollisionRadius=48
	CollisionHeight=30
	bCollideActors=True
	bCollideWorld=True
	LightType=LT_Steady
	LightEffect=LE_NonIncidence
	LightBrightness=255
	LightRadius=6
	Mass=30
	Buoyancy=20
    bAlwaysRelevant=True
    NetPriority=3.000000
    LightHue=32
}
