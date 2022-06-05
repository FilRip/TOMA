class TOMAPredator extends TOMAPupae;

var(Sounds) sound Footstep;
var(Sounds) sound Footstep2;

simulated function PlayFootStep()
{
	local sound step;
	local float decision;

	if ( FootRegion.Zone.bWaterZone )
	{
		PlaySound(sound'LSplash',SLOT_Interact,1,false,1500.0,1.0);
		return;
	}

	decision=FRand();
	if (decision<0.5)
		step=Footstep;
	else
		step=Footstep2;

	PlaySound(step,SLOT_Interact,2.2,false,1000.0,1.0);
}

defaultproperties
{
    JumpZ=20
    mesh=LodMesh'TOMAModels21.Predator'
    texture=None
    Skin=None
    Bite=Sound'TOMASounds21.Predator.bite'
    Die=sound'TOMASounds21.Predator.Die'
    Fear=sound'TOMASounds21.Predator.fear1'
     HitSound1=sound'TOMASounds21.Predator.Hurt1'
     HitSound2=sound'TOMASounds21.Predator.Hurt2'
     Stab=sound'TOMASounds21.Predator.Idle'
     FootStep=sound'TOMASounds21.Predator.step1'
     FootStep2=Sound'TOMASounds21.Predator.step2'
}

