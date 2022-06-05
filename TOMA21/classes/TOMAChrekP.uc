class TOMAChrekP extends TournamentMale;

#exec OBJ LOAD FILE=..\Sounds\TOMASounds21.uax PACKAGE=TOMASounds21

function PlayDying(name DamageType, vector HitLoc)
{
	BaseEyeHeight = Default.BaseEyeHeight;
	PlayDyingSound();

	if ( DamageType == 'Suicided' )
	{
		PlayAnim('Dead8',, 0.1);
		return;
	}

	// check for head hit
	if ( (DamageType == 'Decapitated') && !class'GameInfo'.Default.bVeryLowGore )
	{
		PlayChrekDecap();
		return;
	}

	if ( FRand() < 0.15 )
	{
		PlayAnim('Dead2',,0.1);
		return;
	}

	// check for big hit
	if ( (Velocity.Z > 250) && (FRand() < 0.75) )
	{
		if ( FRand() < 0.5 )
			PlayAnim('Dead1',,0.1);
		else
			PlayAnim('Dead11',, 0.1);
		return;
	}

	// check for repeater death
	if ( (Health > -10) && ((DamageType == 'shot') || (DamageType == 'zapped')) )
	{
		PlayAnim('Dead9',, 0.1);
		return;
	}

	if ( (HitLoc.Z - Location.Z > 0.7 * CollisionHeight) && !class'GameInfo'.Default.bVeryLowGore )
	{
		if ( FRand() < 0.5 )
			PlayChrekDecap();
		else
			PlayAnim('Dead7',, 0.1);
		return;
	}

	if ( Region.Zone.bWaterZone || (FRand() < 0.5) ) //then hit in front or back
		PlayAnim('Dead3',, 0.1);
	else
		PlayAnim('Dead8',, 0.1);
}

function PlayChrekDecap()
{
	local carcass carc;

	PlayAnim('Dead4',, 0.1);
	if ( Level.NetMode != NM_Client )
	{
		carc = Spawn(class 'tomachrekhead',,, Location + CollisionHeight * vect(0,0,0.8), Rotation + rot(3000,0,16384) );
		if (carc != None)
		{
			carc.Initfor(self);
			carc.Velocity = Velocity + VSize(Velocity) * VRand();
			carc.Velocity.Z = FMax(carc.Velocity.Z, Velocity.Z);
		}
	}
}

defaultproperties
{
    Deaths(0)=sound'TOMASounds21.Monsters.chkdeath1'
    Deaths(1)=sound'TOMASounds21.Monsters.chkdeath2'
    Deaths(2)=sound'TOMASounds21.Monsters.chkdeath3'
    Deaths(3)=sound'TOMASounds21.Monsters.chkdeath4'
    Deaths(4)=sound'TOMASounds21.Monsters.chkdeath5'
    Deaths(5)=sound'TOMASounds21.Monsters.chkdeath6'
    drown=sound'TOMASounds21.Monsters.chkdrown'
    breathagain=sound'TOMASounds21.Monsters.chkgasp2'
    Footstep1=sound'TOMASounds21.Monsters.chkstep1'
    Footstep2=sound'TOMASounds21.Monsters.chkstep2'
    Footstep3=sound'TOMASounds21.Monsters.chkstep3'
    HitSound3=sound'TOMASounds21.Monsters.chkinjur3'
    HitSound4=sound'TOMASounds21.Monsters.chkinjur4'
    GaspSound=sound'TOMASounds21.Monsters.chkgasp'
    UWHit1=sound'TOMASounds21.Monsters.chkUWhit1'
    UWHit2=sound'TOMASounds21.Monsters.chkUWhit2'
    LandGrunt=sound'TOMASounds21.Monsters.chklandgrunt'
    CarcassType=Class'TOMAChrekCarcass'
    JumpSound=sound'TOMASounds21.Monsters.chkjump'
    SpecialMesh="Botpack.TrophyMale2"
    HitSound1=sound'TOMASounds21.Monsters.chkinjur1'
    HitSound2=sound'TOMASounds21.Monsters.chkinjur2'
    Land=sound'TOMASounds21.Monsters.chkland'
    Die=Sound'TOMASounds21.Monsters.chkdeath1'
    MenuName="Box Reserves"
    Mesh=LodMesh'Chrek'
}
