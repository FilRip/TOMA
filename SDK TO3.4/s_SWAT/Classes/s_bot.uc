class s_bot extends s_botbase;

var s_PRI TOPRI;
var TO_PZone PZone;
var bool bDead;
var bool bNotPlaying;
var bool bSpecialItem;
var Class<s_SpecialItem> SpecialItemClass;
var Class<s_Evidence> Evidence[10];
var byte Eidx;
var byte O_number;
var byte LastO_number;
var name Objective;
var name LastObjective;
var Actor LastOrderObject;
var byte O_Count;
var TO_ConsoleTimer CurrentCT;
var s_ExplosiveC4 CurrentC4;
var bool bDoNotDisturb;
var byte PlayerModel;
var byte HelmetCharge;
var byte VestCharge;
var byte LegsCharge;
var int money;
var bool bNeedAmmo;
var bool bGrenadeAvail;
var float BlindTime;
var name OldState;
var Inventory TempInv;
var int MaxFallHeight;
var byte HostageFollowing;
var byte CountCheck;
var byte byteClimbDir;

function SendVoiceMessage (PlayerReplicationInfo Sender, PlayerReplicationInfo Recipient, name MessageType, byte MessageID, name broadcasttype)
{
}

simulated function PostBeginPlay ()
{
}

simulated event Destroyed ()
{
}

function RoundEnded ()
{
}

function Escape ()
{
}

function SeeNPC (Actor SeenPlayer)
{
}

function bool SetEnemy (Pawn NewEnemy)
{
}

function ShareWith (Pawn Other)
{
}

state PreRound
{
	function BeginState ()
	{
	}
	
	function EndState ()
	{
	}
	
	function AnimEnd ()
	{
	}
Begin:
}

function SetOrders (name NewOrders, Pawn OrderGiver, optional bool bNoAck)
{
}

function bool CloseToPointMan (Pawn Other)
{
}

function TakeDamage (int Damage, Pawn instigatedBy, Vector HitLocation, Vector Momentum, name DamageType)
{
}

function Bump (Actor Other)
{
}

simulated function CalculateWeight ()
{
}

event UpdateEyeHeight (float DeltaTime)
{
}

function FireWeapon ()
{
}

function bool SwitchToBestWeaponEx ()
{
}

function bool CheckWeaponAmmo (S_Weapon W)
{
}

state Defending
{
	function SeePlayer (Actor SeenPlayer)
	{
	}
	
	function EndState ()
	{
	}
	
Attack:
Begin:
Finished:
}

function UseVent (bool Exit)
{
}

function ResetLastObj ()
{
}

function LetsGetLoaded ()
{
}

state BotBuying
{
	function TakeDamage (int Damage, Pawn instigatedBy, Vector HitLocation, Vector Momentum, name DamageType)
	{
	}
	
	function EnemyAcquired ()
	{
	}
	
	function BeginState ()
	{
	}
	
	function AnimEnd ()
	{
	}
	
Begin:
}

function BotBuyWeapons ()
{
}

function bool CanBuyWeaponClass (int classn)
{
}

function bool BotGetWeapon (byte WeaponClass)
{
}

function bool BotBuyAmmo (Weapon W)
{
}

function UseConsoleTimer (TO_ConsoleTimer ct)
{
}

state BotActivateTO_ConsoleTimer
{
	function TakeDamage (int Damage, Pawn instigatedBy, Vector HitLocation, Vector Momentum, name DamageType)
	{
	}
	
	function EnemyAcquired ()
	{
	}
	
	function RoundEnded ()
	{
	}
	
	function BeginState ()
	{
	}
	
	function EndState ()
	{
	}
	
Begin:
}

function PlantC4Bomb ()
{
}

state BotPlantingC4Bomb
{
	function TakeDamage (int Damage, Pawn instigatedBy, Vector HitLocation, Vector Momentum, name DamageType)
	{
	}
	
	function PlantC4Bomb ()
	{
	}
	
	function EnemyAcquired ()
	{
	}
	
	function AnimEnd ()
	{
	}
	
	function RoundEnded ()
	{
	}
	
	function BeginState ()
	{
	}
	
	function EndState ()
	{
	}
	
Begin:
}

function DefuseC4 (s_ExplosiveC4 c4)
{
}

state BotDefusingC4Explosive
{
	function TakeDamage (int Damage, Pawn instigatedBy, Vector HitLocation, Vector Momentum, name DamageType)
	{
	}
	
	function EnemyAcquired ()
	{
	}
	
	function RoundEnded ()
	{
	}
	
	function BeginState ()
	{
	}
	
	function EndState ()
	{
	}
	
Begin:
}

state Alarm
{
	function SeePlayer (Actor SeenPlayer)
	{
	}
	
Attack:
Moving:
Begin:
End:
}
