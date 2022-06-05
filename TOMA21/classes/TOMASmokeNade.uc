class TOMASmokeNade extends TO_GrenadeSmoke config(TOMA);

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
    if (Owner.IsA('TOMAPlayer'))
        if (TOMAPlayer(Owner).NbSpecialNade>0)
            ok=true;
    if (Owner.IsA('TOMABot'))
        if (TOMABot(Owner).NbSpecialNade>0)
            ok=true;
    if (ok)
	{
		Owner.MakeNoise(PawnOwner.SoundDampening);
		GetAxes(PawnOwner.ViewRotation,X,Y,Z);
		StartTrace=Owner.Location + CalcDrawOffset() + FireOffset.Y * Y + FireOffset.Z * Z;
		AdjustedAim=Pawn(Owner).AdjustAim(1000000.00,StartTrace,2 * aimerror,False,False);
		G=Spawn(Class'TOMAProjSmokeGren',,,StartTrace,AdjustedAim);
		G.ExpTiming=5.00 - Power * 0.38;
		G.speed=700.00 + Power * 120;
		G.ThrowGrenade();
	}
}

defaultproperties
{
	price=800
	WeaponDescription="Classification: Attract Monsters"
	PickupMessage="You picked up an Attract Monsters grenade!"
	ItemName="Attract Monsters"
	PlayerViewMesh=SkeletalMesh'TOModels.grensmokeMesh'
	PickupViewMesh=LodMesh'TOModels.wgrenadesmoke'
	ThirdPersonMesh=LodMesh'TOModels.wgrenadesmoke'
}
