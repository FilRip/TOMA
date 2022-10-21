//=============================================================================
// s_GrenadeFB
//=============================================================================
//
// Tactical Ops
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen and Benoit "JAH" Delayen
//=============================================================================

class s_GrenadeFB extends TO_Grenade;
 

///////////////////////////////////////
// SetSkins
///////////////////////////////////////

function SetSkins()
{
	MultiSkins[1] = Texture(DynamicLoadObject("TOModels.gren_flash", class'Texture'));

	Super.SetSkins();
}


///////////////////////////////////////
// ThrowGrenade
///////////////////////////////////////

function ThrowGrenade()
{	
	local s_GrenadeAway g;
	local vector StartTrace, X, Y, Z;
	local Pawn PawnOwner;

	PawnOwner = Pawn(Owner);
	Owner.MakeNoise(PawnOwner.SoundDampening);
	GetAxes(PawnOwner.ViewRotation, X, Y, Z);
	
	StartTrace =  Owner.Location + CalcDrawOffset() + FireOffset.Y * Y + FireOffset.Z * Z;
	AdjustedAim = pawn(owner).AdjustAim(1000000, StartTrace, 2 * AimError, False, False);	
	g = Spawn(class's_FlashBang',,, StartTrace, AdjustedAim);
	g.ExpTiming = 5.0 - Power * 0.375;
	g.speed = 700 + Power * 120;
	g.ThrowGrenade();
/*
	if (!Level.Game.IsA('s_SWATGame'))
		return;

	if (Owner.IsA('s_BPlayer'))
	{
		if (FRand()<0.5)
			s_SWATGame(Level.Game).s_PlayDynamicTeamSound(21, s_BPlayer(Owner).GetVoiceType(), Pawn(Owner).PlayerReplicationInfo.Team,, Pawn(Owner).PlayerReplicationInfo);
		else
			s_SWATGame(Level.Game).s_PlayDynamicTeamSound(22, s_BPlayer(Owner).GetVoiceType(), Pawn(Owner).PlayerReplicationInfo.Team,, Pawn(Owner).PlayerReplicationInfo);
	}
	else if (Owner.IsA('s_Bot'))
	{
		if (FRand()<0.5)
			s_SWATGame(Level.Game).s_PlayDynamicTeamSound(21, s_Bot(Owner).GetVoiceType(), Pawn(Owner).PlayerReplicationInfo.Team,, Pawn(Owner).PlayerReplicationInfo);
		else
			s_SWATGame(Level.Game).s_PlayDynamicTeamSound(22, s_Bot(Owner).GetVoiceType(), Pawn(Owner).PlayerReplicationInfo.Team,, Pawn(Owner).PlayerReplicationInfo);
	}
*/
}


///////////////////////////////////////
// defaultproperties 
///////////////////////////////////////

defaultproperties
{
     price=400
     WeaponDescription="Classification: Flashbang"
     PickupMessage="You picked up a Flashbang!"
     ItemName="Flashbang"
}
