class TOSTWeaponNoRecoilBug extends TOSTWeapon;

simulated function PlaySelect ()
{
	if ( !hasanim('Select') )
		Mesh=PlayerViewMesh;
	super.PlaySelect();
}

//do not sell empty clips as remaining clips... trying to fix unfinite ammo at buy zone
//bug: if u sell a gun after emptying a clip, u ll receive money as for a full clipS
//
//this fix has a probs. U may buy new clip if last one is not full... :(
//1 fct for selling should be added (getRemainingfullclips)
simulated function int GetRemainingClips (bool Mode)
{
	if ( bAltMode == Mode )
	{
		if ( clipAmmo == clipSize )
			return RemainingClip;
		else return RemainingClip - 1;
	}
	else
	{
		if ( BackupAmmo == BackupClipSize )
			return BackupClip;
		else return BackupClip - 1;
	}
}

simulated function bool ClientFire (float Value)
{
	if ( s_bplayer(owner) != none && s_bplayer(owner).IsInState('PreRound') )
	{
		return false;
	}
	else return super.ClientFire(Value);
}

function Fire (float Value)
{
	if ( s_SWATGame(Level.Game).GamePeriod!=GP_PreRound )
		super.Fire(Value);
}
