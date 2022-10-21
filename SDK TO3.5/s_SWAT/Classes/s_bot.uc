class s_bot extends s_botbase;

var name Objective;
var byte O_number;
var bool bNotPlaying;
var byte HostageFollowing;
var Inventory TempInv;
var TO_ConsoleTimer CurrentCT;
var int money;
var name OldState;
var bool bDoNotDisturb;
var byte Eidx;
var byte HelmetCharge;
var byte VestCharge;
var byte LegsCharge;
var bool bSpecialItem;
var name LastObjective;
var s_ExplosiveC4 CurrentC4;
var bool bNeedAmmo;
var byte byteClimbDir;
var byte LastO_number;
var bool bDead;
var s_PRI TOPRI;
var s_Evidence Evidence;
var bool bGrenadeAvail;
var byte CountCheck;
var s_SpecialItem SpecialItemClass;
var Actor LastOrderObject;
var byte O_Count;
var byte PlayerModel;
var float BlindTime;
var int MaxFallHeight;

function TakeDamage (int Damage, Pawn instigatedBy, Vector HitLocation, Vector Momentum, name DamageType)
{
}

function RoundEnded ()
{
}

function PlantC4Bomb ()
{
}

function ClearZone ()
{
}

function SetZone (s_ZoneControlPoint Zone)
{
}

function UnTouch (Actor Other)
{
}

function Touch (Actor Other)
{
}

state Alarm
{
	function SeePlayer (Actor SeenPlayer)
	{
	}

}

state BotDefusingC4Explosive
{
	function EndState ()
	{
	}

	function BeginState ()
	{
	}

	function RoundEnded ()
	{
	}

	function EnemyAcquired ()
	{
	}

	function TakeDamage (int Damage, Pawn instigatedBy, Vector HitLocation, Vector Momentum, name DamageType)
	{
	}

}

function DefuseC4 (s_ExplosiveC4 c4)
{
}

state BotPlantingC4Bomb
{
	function EndState ()
	{
	}

	function BeginState ()
	{
	}

	function RoundEnded ()
	{
	}

	function AnimEnd ()
	{
	}

	function EnemyAcquired ()
	{
	}

	function PlantC4Bomb ()
	{
	}

	function TakeDamage (int Damage, Pawn instigatedBy, Vector HitLocation, Vector Momentum, name DamageType)
	{
	}

}

state BotActivateTO_ConsoleTimer
{
	function EndState ()
	{
	}

	function BeginState ()
	{
	}

	function RoundEnded ()
	{
	}

	function EnemyAcquired ()
	{
	}

	function TakeDamage (int Damage, Pawn instigatedBy, Vector HitLocation, Vector Momentum, name DamageType)
	{
	}

}

function UseConsoleTimer (TO_ConsoleTimer ct)
{
}

function bool BotBuyAmmo (Weapon W)
{
}

function bool BotGetWeapon (byte WeaponClass)
{
}

function bool CanBuyWeaponClass (int classn)
{
}

function BotBuyWeapons ()
{
}

state BotBuying
{
	function AnimEnd ()
	{
	}

	function BeginState ()
	{
	}

	function EnemyAcquired ()
	{
	}

	function TakeDamage (int Damage, Pawn instigatedBy, Vector HitLocation, Vector Momentum, name DamageType)
	{
	}

}

function LetsGetLoaded ()
{
}

function ResetLastObj ()
{
}

function UseVent (bool Exit)
{
}

state Defending
{
	function EndState ()
	{
	}

	function SeePlayer (Actor SeenPlayer)
	{
	}

}

function bool CheckWeaponAmmo (S_Weapon W)
{
}

function bool SwitchToBestWeaponEx ()
{
}

function FireWeapon ()
{
}

event UpdateEyeHeight (float DeltaTime)
{
}

simulated function CalculateWeight ()
{
}

function Bump (Actor Other)
{
}

function bool CloseToPointMan (Pawn Other)
{
}

function SetOrders (name NewOrders, Pawn OrderGiver, optional bool bNoAck)
{
}

state PreRound
{
	function AnimEnd ()
	{
	}

	function EndState ()
	{
	}

	function BeginState ()
	{
	}

	function TakeDamage (int Damage, Pawn instigatedBy, Vector HitLocation, Vector Momentum, name DamageType)
	{
	}

}

function ShareWith (Pawn Other)
{
}

function bool SetEnemy (Pawn NewEnemy)
{
}

function SeeNPC (Actor SeenPlayer)
{
}

function Escape ()
{
}

simulated event Destroyed ()
{
}

simulated function PostBeginPlay ()
{
}

function SendVoiceMessage (PlayerReplicationInfo Sender, PlayerReplicationInfo Recipient, name MessageType, byte MessageID, name broadcasttype)
{
}


defaultproperties
{
}

