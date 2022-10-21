class TGAS_GrenadeGas extends TO_GrenadeSmoke;
 
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
	g = Spawn(class'TGAS_ProjgasGren',owner,, StartTrace, AdjustedAim);
	g.ExpTiming = 5.0 - Power * 0.375;
	g.speed = 700 + Power * 120;
  	G.ThrowGrenade();
}

defaultproperties
{
    price=500
    WeaponDescription="Classification: Teargas Grenade"
    PickupMessage="You picked up a Teargas Grenade!"
    ItemName="Teargas Grenade"
}
