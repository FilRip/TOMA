class TOExtra22Hostage extends s_NPCHostage_M2;

function name GetStillAnim()
{
	if ( bIsFree )
		return 'HostageStandBreath';
	else
		return 'HostageNealBreath';
}

function TweenToRunning(float tweentime)
{
	local name newAnim;

	if ( Physics == PHYS_Swimming )
	{
		if ( (vector(Rotation) Dot Acceleration) > 0 )
			TweenToSwimming(tweentime);
		else
			TweenToWaiting(tweentime);
		return;
	}

	BaseEyeHeight = Default.BaseEyeHeight;

	if ( Weapon == None )
		newAnim = 'HostageRun';
	else if ( Weapon.bPointing )
	{
		if ( Weapon.Mass < 6 )
			newAnim = 'RunKGSlash';
		if ( Weapon.Mass < 11 )
			newAnim = 'RunKGThrow';
		else if (Weapon.Mass < 20)
			newAnim = 'RunSMFR';
		else
			newAnim = 'RunLGFR';
	}
	else
	{
		if ( Weapon.Mass < 11 )
			newAnim = 'RunKG';
		else if (Weapon.Mass < 20)
			newAnim = 'RunSM';
		else
			newAnim = 'RunLG';
	}

	if ( (newAnim == AnimSequence) && (Acceleration != vect(0,0,0)) && IsAnimating() )
		return;
	TweenAnim(newAnim, tweentime);
}

defaultproperties
{
}

