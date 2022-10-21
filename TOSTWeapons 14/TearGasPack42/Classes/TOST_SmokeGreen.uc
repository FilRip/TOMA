class TOST_SmokeGreen extends TO_SmokeLarge;

simulated function BeginPlay ()
{
	local int EffectDetail;

	EffectDetail=Class'TO_ConfigClass'.Default.FeedbackEffects;
	Velocity=vect(0.00,0.00,1.00) * RisingRate * FRand();
	Velocity.Y=(FRand() - 0.50) * MovingRate;
	Velocity.X=(FRand() - 0.50) * MovingRate;
	Texture=Texture'GreenSmoke';
	if ( EffectDetail == 0 )
	{
		HighSmokeRate=0.06;
		LowSmokeRate=0.15;
	}
	else
	{
		if ( EffectDetail == 1 )
		{
			HighSmokeRate=0.12;
			LowSmokeRate=0.27;
		}
		else
		{
			HighSmokeRate=0.25;
			LowSmokeRate=0.40;
		}
	}
	SetTimer(0.01,False);
}
