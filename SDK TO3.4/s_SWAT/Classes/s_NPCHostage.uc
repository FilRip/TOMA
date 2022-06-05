class s_NPCHostage extends s_NPC;

var Pawn Followed;
var bool bCloseEnough;
var TournamentWeapon FoundWeapon;
var bool bIsFree;
var int LastDistressCall;

function WhatToDoNext (name LikelyState, name LikelyLabel)
{
}

function UpdateStatus ()
{
}

function TakeDamage (int Damage, Pawn instigatedBy, Vector HitLocation, Vector Momentum, name DamageType)
{
}

function EAttitude AttitudeTo (Pawn Other)
{
}

function SetOrders (name NewOrders, Pawn OrderGiver, optional bool bNoAck)
{
}

function bool PickLocalInventory (float MaxDist, float MinDistraction)
{
}

function PlayRescueLock ()
{
}

function PlayRescueEscort ()
{
}

function PlayThreatLock ()
{
}

function PlayThreatEscort ()
{
}

function PlayScream ()
{
}

function PlayComplainSound ()
{
}

function bool SwitchToBestWeapon ()
{
}

function Rescued ()
{
}

function SetFall ()
{
}

function PlayDyingSound ()
{
}
