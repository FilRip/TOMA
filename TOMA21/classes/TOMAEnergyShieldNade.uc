class TOMAEnergyShieldNade extends s_GrenadeConc;

function ThrowGrenade ()
{
	local s_GrenadeAway G;
	local Vector StartTrace;
	local Vector X;
	local Vector Y;
	local Vector Z;
	local Pawn PawnOwner;
    local bool ok;

	PawnOwner=Pawn(Owner);

    if (PawnOwner.IsA('TOMAPlayer'))
        if (TOMAPlayer(Owner).NbSpecialNade>0)
            ok=true;
    if (PawnOwner.IsA('TOMABot'))
        if (TOMABot(Owner).NbSpecialNade>0)
            ok=true;
    if (Ok)
	{
		Owner.MakeNoise(PawnOwner.SoundDampening);
		GetAxes(PawnOwner.ViewRotation,X,Y,Z);
		StartTrace=Owner.Location + CalcDrawOffset() + FireOffset.Y * Y + FireOffset.Z * Z;
		AdjustedAim=Pawn(Owner).AdjustAim(1000000.00,StartTrace,2 * aimerror,False,False);
		G=Spawn(Class'TOMAMakeShield',,,StartTrace,AdjustedAim);
		G.ExpTiming=5.00 - Power * 0.38;
		G.speed=700.00 + Power * 120;
		G.ThrowGrenade();
		GrenadeThrown();
	}
}

defaultproperties
{
	price=800
	WeaponDescription="Classification: Energy Shield grenade"
	PickupMessage="You picked up an Energy Shield grenade!"
	ItemName="Energy Shield Grenade"
}
