class TOMAFB extends s_GrenadeFB;

function ThrowGrenade ()
{
	local TOMAFBEffect G;
	local Vector StartTrace;

	local Vector X;
	local Vector Y;
	local Vector Z;
	local Pawn PawnOwner;
    local bool ok;

	PawnOwner=Pawn(Owner);
	Owner.MakeNoise(PawnOwner.SoundDampening);
	GetAxes(PawnOwner.ViewRotation,X,Y,Z);
	StartTrace=Owner.Location + CalcDrawOffset() + FireOffset.Y * Y + FireOffset.Z * Z;
	AdjustedAim=Pawn(Owner).AdjustAim(1000000.00,StartTrace,2 * aimerror,False,False);

    if (Owner.IsA('TOMAPlayer'))
        if (TOMAPlayer(Owner).NbSpecialNade>0)
            ok=true;
    if (Owner.IsA('TOMABot'))
        if (TOMABot(Owner).NbSpecialNade>0)
            ok=true;
    if (ok)
	{
		G=Spawn(Class'TOMAFBEffect',,,StartTrace,AdjustedAim);
		G.ExpTiming=5.00 - Power * 0.38;
		G.speed=700.00 + Power * 120;
		G.ThrowGrenade();
		GrenadeThrown();
	}
}

defaultproperties
{
	WeaponDescription="Classification: Freeze Monsters"
	PickupMessage="You picked up a Freeze Monsters grenade!"
	ItemName="Freeze Monsters"
	PlayerViewMesh=SkeletalMesh'TOModels.grenflashMesh'
	PickupViewMesh=LodMesh'TOModels.wgrenadeflash'
	ThirdPersonMesh=LodMesh'TOModels.wgrenadeflash'
	Price=800
}
