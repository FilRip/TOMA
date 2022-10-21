class NADE_GrenadeFB extends s_GrenadeFB;

var byte nadetimer;

function Beginplay ()
{
nadetimer=5;
super.beginplay();
}

function AltFire (float Value)
{
	if ( PlayerPawn(Owner) == None )
	{
		Pawn(Owner).SwitchToBestWeapon();
		return;
	}
	If (Nadetimer == 7)
		Nadetimer = 5;
	else If (Nadetimer == 5)
		Nadetimer = 3;
	else
		Nadetimer = 7;
	s_player(owner).clientmessage ("Nade timing seconds set to " $ nadetimer-1);
}

function ThrowGrenade ()
{
	local s_GrenadeAway G;
	local Vector StartTrace;
	local Vector X;
	local Vector Y;
	local Vector Z;
	local Pawn PawnOwner;

	PawnOwner=Pawn(Owner);
	Owner.MakeNoise(PawnOwner.SoundDampening);
	GetAxes(PawnOwner.ViewRotation,X,Y,Z);
	StartTrace=Owner.Location + TOCalcDrawOffset() + FireOffset.Y * Y + FireOffset.Z * Z;
	AdjustedAim=Pawn(Owner).AdjustAim(1000000.00,StartTrace,2 * aimerror,False,False);
	G=Spawn(Class's_FlashBang',,,StartTrace,AdjustedAim);
	G.ExpTiming=nadetimer - Power * 0.38;
	G.LifeSpan=Nadetimer+1;
	G.speed=700.00 + Power * 120;
	G.ThrowGrenade();
	GrenadeThrown();
}
