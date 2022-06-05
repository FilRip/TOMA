class TOMAbugp extends TournamentMale;

function TweenToWaiting (float TweenTime)
{
	if ( IsInState('PlayerSwimming') || (Physics == 3) )
	{
		BaseEyeHeight=0.70 * Default.BaseEyeHeight;
		if ( (Weapon == None) || (Weapon.Mass < 20) )
		{
			TweenAnim('TreadSm',TweenTime);
		}
		else
		{
			TweenAnim('TreadLg',TweenTime);
		}
	}
	else
	{
		BaseEyeHeight=Default.BaseEyeHeight;
		if ( (Weapon == None) || (Weapon.Mass < 20) )
		{
			TweenAnim('Breath1',TweenTime);
		}
		else
		{
			TweenAnim('Breath2',TweenTime);
		}
	}
}

defaultproperties
{
    MenuName="bug"
    Mesh=LodMesh'TOMAModels21.bug'
}

