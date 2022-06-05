Class TOMAConcGrenade extends s_GrenadeConc;

function ThrowGrenade()
{	
	local s_GrenadeAway g;
	local vector StartTrace,X,Y,Z;
	local Pawn PawnOwner;

	PawnOwner=Pawn(Owner);
	Owner.MakeNoise(PawnOwner.SoundDampening);
	GetAxes(PawnOwner.ViewRotation,X,Y,Z);
	
	StartTrace=Owner.Location+TOCalcDrawOffset()+FireOffset.Y*Y+FireOffset.Z*Z;
	AdjustedAim=pawn(owner).AdjustAim(1000000,StartTrace,2*AimError,False,False);	
	g=Spawn(class'TOMAConcussion',,,StartTrace,AdjustedAim);
	g.ExpTiming=4.5-Power*0.375;
	g.speed=700+Power*120;
	g.ThrowGrenade();

	GrenadeThrown();
}

defaultproperties
{
}
