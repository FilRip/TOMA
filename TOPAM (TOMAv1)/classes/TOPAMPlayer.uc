class TOPAMPlayer extends S_Player_T config(User);

simulated event Possess()
{
	local s_SWATLevelInfo SWLI;
	local TO_ScenarioInfoInternal SIint;
	local TournamentConsole C;
	local UWindowRootWindow Root;
	local string Message;
	local TO_ScenarioInfo localSI;
	local s_SWATLevelInfo localSWLI;

	UpdateURL("Class","s_SWAT.s_Player_T",True);
	UpdateURL("Skin","None",True);
	UpdateURL("Face","None",True);
	UpdateURL("Team","255",True);
	UpdateURL("Voice","None",True);

	if (Level.NetMode==NM_Client)
	{
		ServerNeverSwitchOnPickup(bNeverAutoSwitch);
		ServerSetHandedness(Handedness);
		UpdateWeaponPriorities();
	}
	ServerUpdateWeapons();
	bIsPlayer=True;
	DodgeClickTime=FMin(0.30,DodgeClickTime);
	EyeHeight=BaseEyeHeight;
	NetPriority=3;
	if ((Level.Game!=None) && (!Level.Game.IsA('s_SWATGame')))
	{
		StartWalk();
		if (Handedness==1)
			LoadLeftHand();
	}
/*	else
	{
		if ((Role==Role_Authority) && (Level.NetMode!=NM_Standalone))
			Spawn(Class'TO_Protect',self);
	}*/
	if (Level.NetMode==NM_Client)
	{
		ServerSetTaunt(bAutoTaunt);
		if ((Level.Game!=None) && (!Level.Game.IsA('s_SWATGame')))
			ServerSetInstantRocket(bInstantRocket);
	}

	if ( Role < Role_Authority )
	{
		ServerSetHideDeathMsg(bHideDeathMsg);
		ServerSetAutoReload(bAutomaticReload);
	}
	Bob=OriginalBob;

	FixMapProblems();
	if ((Level!=None) && (Level.Game!=None) && !Level.Game.IsA('s_SWATGame'))
		return;
	if (Level.NetMode!=NM_DedicatedServer)
	{
		Message="s_Player::Possess - " $ Class'TO_MenuBar'.Default.TOVersionText;
		Log(Message);
		if ((Player!=None) && (Player.Console!=None))
		{
			SetupRainGen();
			if (Level.bHighDetailMode)
				toggleraingen();
		}
	}
	if (PZone!=None)
		PZone.Destroy();
	PZone=Spawn(Class'TO_PZone',self);
	if (PZone!=None)
		PZone.Initialize();
	if (SI==None)
	{
		foreach AllActors(Class'TO_ScenarioInfo',SI)
			localSI=SI;
		SI=localSI;
	}
	if (Role<Role_Authority)
	{
		if (SI==None)
		{
			foreach AllActors(Class's_SWATLevelInfo',SWLI)
				localSWLI=SWLI;
			SWLI=localSWLI;
			if (SWLI!=None)
			{
				SIint=Spawn(Class'TO_ScenarioInfoInternal',self,,Location);
				if (SIint!=None)
				{
					SIint.ConvertActor(SWLI);
					SI=SIint;
				}
				else
					Log("s_Player - PostBeginPlay - ConvertSWLI - SI == None");
			}
			else
				Log("s_Player - PostBeginPlay - SWLI == None");
		}
	}
	if ((Player!=None) && (Player.Console==None) && (Role==Role_Authority))
		return;
	if ((myHUD!=None) && (s_HUD(myHUD)!=None) && (s_HUD(myHUD).UserInterface!=None))
	{
		s_HUD(myHUD).UserInterface.Destroy();
		s_HUD(myHUD).UserInterface=None;
	}
	bGUIActive=True;
	if (StartMenu!=None)
	{
		StartMenu.Close();
		StartMenu=None;
	}
	if ((Player!=None) && (Player.Console!=None))
		C=TournamentConsole(Player.Console);
	if (C.bShowSpeech)
		C.HideSpeech();
	if (C.Root==None)
	{
		Log("s_Player::Possess - C.Root == None - creating Root");
		C.CreateRootWindow(None);
	}
	else
	{
		if ((Level.Game!=None) && s_SWATGame(Level.Game).bSinglePlayer)
		{
			C.bQuickKeyEnable=True;
			C.LaunchUWindow();
			StartMenu=TOPAMAutoTeamSelect(C.Root.CreateWindow(Class'TOPAMAutoTeamSelect',0,0,C.Root.WinWidth,C.Root.WinHeight));
		}
		else
		{
			C.bQuickKeyEnable=True;
			C.LaunchUWindow();
			StartMenu=TOPAMTeamSelect(C.Root.CreateWindow(Class'TOPAMTeamSelect',0,0,C.Root.WinWidth,C.Root.WinHeight));
		}
	}
	if ((Player!=None) && (Player.Console!=None) && (TO_Console(Player.Console)!=None) && ((TO_Console(Player.Console).SpeechWindow==None) || !TO_Console(Player.Console).SpeechWindow.IsA('TOPAMSWATWindow')))
	{
		Root=WindowConsole(Player.Console).Root;
		TO_Console(Player.Console).SpeechWindow=SpeechWindow(Root.CreateWindow(Class'TOPAMSWATWindow',100,100,200,200));
		if (TO_Console(Player.Console).SpeechWindow==None)
		{
			Log("s_Player::Possess - Speechwindow == None");
			return;
		}
		TO_Console(Player.Console).SpeechWindow.bLeaveOnscreen=True;
		if (TO_Console(Player.Console).bShowSpeech)
		{
			Root.SetMousePos(0,132/768*Root.WinWidth);
			TO_Console(Player.Console).SpeechWindow.SlideInWindow();
		}
		else
			TO_Console(Player.Console).SpeechWindow.HideWindow();
	}
	else
		Log("s_Player::Possess - cannot replace speechwindow");
	if (StartMenu==None)
	{
		Log("s_Player::Possess - StartMenu == None");
	}
	GotoState('PlayerWaiting');
}

// TODO : Adapter les animations en fonction du models de monstre choisi

function TweenToWaiting(float tweentime)
{
	if ( (IsInState('PlayerSwimming')) || (Physics == PHYS_Swimming) )
	{
		BaseEyeHeight = 0.7 * Default.BaseEyeHeight; // 0.7
		if ( (Weapon == None) || (Weapon.Mass < 20) )
			TweenAnim('TreadSM', tweentime);
		else
			TweenAnim('TreadLG', tweentime);
	}
	else
	{
		BaseEyeHeight = Default.BaseEyeHeight;
		if ( (Weapon == None) || ((Weapon.Mass < 20) && (Weapon.Mass > 11)) )
			TweenAnim('StillSmFr', tweentime);
		else if (Weapon.Mass < 6)
			TweenAnim('StillKgSlash', tweentime);
		else if (Weapon.Mass < 11)
			TweenAnim('StillKgThrow', tweentime);
		else
			TweenAnim('StillLgFr', tweentime);
	}
}


function PlayAnimNicely(name AnimSeq)
{
	// Switches animations mid-streams if needed
	if ( AnimFrame < 0.5 )
		AnimSequence = AnimSeq;
	else
		PlayAnim(AnimSeq);
}

function PlayGrenadeThrow()
{
	if ( (IsInState('PlayerSwimming')) || (Physics == PHYS_Swimming) )
		return;

	if ( AnimSequence == 'WalkKG' )
		PlayAnimNicely('WalkKGThrow');
	else if ( AnimSequence == 'RunKG' )
		PlayAnimNicely('RunKGThrow');
	else if ( AnimSequence == 'DuckIdleKG' )
		PlayAnim('DuckIdleKGThrow');
	else if ( AnimSequence == 'DuckWlkKG' )
		PlayAnimNicely('DuckWlkKGThrow');
	else if ( (AnimSequence == 'StrafeLKG') || (AnimSequence == 'StrafeRKG') ) // We don't have strafe KG anims, so use running instead
		PlayAnimNicely('RunKGThrow');
	else if ( (GetAnimGroup(AnimSequence) == 'Waiting') || (GetAnimGroup(AnimSequence) == 'Gesture')
		&& (AnimSequence != 'TreadLG') && (AnimSequence != 'TreadSM') )
		PlayAnim('StillKGThrow', 1.5, 0.02);
}


function PlayWeaponReloading()
{
	if ( (IsInState('PlayerSwimming')) || (Physics == PHYS_Swimming) )
		return;

	if ( (GetAnimGroup(AnimSequence) == 'Waiting') || (GetAnimGroup(AnimSequence) == 'Gesture')
		&& (AnimSequence != 'TreadLG') && (AnimSequence != 'TreadSM') )
	{
		if ( (weapon!=none) && (Weapon.Mass < 20) )
			PlayAnim('CockGun');
		else
			PlayAnim('CockGunL');
	}
}


function PlayRecoil(float Rate)
{
	if ( (IsInState('PlayerSwimming')) || (Physics == PHYS_Swimming) )
		return;

	// Don't abuse too much on rate value
	Rate = Max(Min(Rate, 1.0), 0.3);

	if ( Weapon.bRapidFire )
	{
		if ( !IsAnimating() && (Physics == PHYS_Walking) )
		{
			if ( GetAnimGroup(AnimSequence) == 'Ducking' )
			{
				if ( Weapon.Mass < 20 )
					LoopAnim('DuckFireS', 0.02);
				else
					LoopAnim('DuckFireL', 0.02);
			}
			else
			{
				if ( Weapon.Mass < 20 )
					LoopAnim('StillSmFrRp', 0.02);
				else
					LoopAnim('StillLgFrRp', 0.02);
			}
		}
	}
	else if ( (AnimSequence == 'StillSmFr') || (AnimSequence == 'StillSmFrRp') )
		PlayAnim('StillSmFr', Rate, 0.02);
	else if ( (AnimSequence == 'StillLgFr') || (AnimSequence == 'StillLgFrRp') )
		PlayAnim('StillLgFr', Rate, 0.02);
	else if ( AnimSequence == 'StillKGSlash' )
		PlayAnim('StillKGSlash', Rate, 0.02);
	else if ( AnimSequence == 'StillKGThrow' )
		PlayAnim('StillKGThrow', Rate, 0.02);
	else if ( AnimSequence == 'DuckFireS' )
		PlayAnim('DuckFireS', Rate, 0.02);
	else if ( AnimSequence == 'DuckFireL' )
		PlayAnim('DuckFireL', Rate, 0.02);
	else if ( AnimSequence == 'DuckIdleKGSlash' )
		PlayAnim('DuckIdleKGSlash', Rate, 0.02);
	else if ( AnimSequence == 'DuckIdleKGThrow' )
		PlayAnim('DuckIdleKGThrow', Rate, 0.02);
}


function PlayFiring()
{
	local vector Dir;

	Dir = Normal(Acceleration);

	// Don't play firing animations when reloading
	//if ( (Weapon==None) || (Weapon.IsA('s_Weapon') && s_Weapon(Weapon).bReloadingWeapon) )
	//	return;

	// switch animation sequence mid-stream if needed
	if ( AnimSequence == 'RunLG' )
		AnimSequence = 'RunLGFR';
	else if ( AnimSequence == 'RunSM' )
		AnimSequence = 'RunSMFR';
	else if ( AnimSequence == 'RunKG' )
	{
		if ( Weapon.Mass < 6 )
			AnimSequence = 'RunKGSlash';
		else
			AnimSequence = 'RunKGThrow';
	}
	else if ( (AnimSequence == 'StrafeLKG') || (AnimSequence == 'StrafeRKG') )
	{
		// We don't have strafe slashing anims, so we blend the running ones.
		if ( Weapon.Mass < 6 )
			PlayAnim('RunKGSlash', 1.0, 0.2);
		else
			PlayAnim('RunKGThrow', 1.0, 0.2);
	}
	else if ( AnimSequence == 'WalkLG' )
		AnimSequence = 'WalkLGFR';
	else if ( AnimSequence == 'WalkSM' )
		AnimSequence = 'WalkSMFR';
	else if ( AnimSequence == 'WalkKG' )
	{
		if ( Weapon.Mass < 6 )
			AnimSequence = 'WalkKGSlash';
		else
			AnimSequence = 'WalkKGThrow';
	}
	else if ( AnimSequence == 'JumpSMFR' )
		TweenAnim('JumpSMFR', 0.03);
	else if ( AnimSequence == 'JumpLGFR' )
		TweenAnim('JumpLGFR', 0.03);
	else if ( AnimSequence == 'DuckWlkKG' )
	{
		if ( Weapon.Mass < 6 )
			AnimSequence = 'DuckWlkKGSlash';
		else
			AnimSequence = 'DuckWlkKGThrow';
	}
	else if ( AnimSequence == 'DuckWlkL' )
		AnimSequence = 'DuckWlkLFr';
	else if ( AnimSequence == 'DuckWlkS' )
		AnimSequence = 'DuckWlkSFr';
	else if ( AnimSequence == 'DuckIdleKG' )
	{
		if ( Weapon.Mass < 6 )
			AnimSequence = 'DuckIdleKGSlash';
		else
			AnimSequence = 'DuckIdleKGThrow';
	}
	else if ( AnimSequence == 'DuckIdleL' )
		AnimSequence = 'DuckFireL';
	else if ( AnimSequence == 'DuckIdleS' )
		AnimSequence = 'DuckFireS';
	else if ( (GetAnimGroup(AnimSequence) == 'Waiting') || (GetAnimGroup(AnimSequence) == 'Gesture')
		|| (GetAnimGroup(AnimSequence) == 'Ducking') && (AnimSequence != 'TreadLG') && (AnimSequence != 'TreadSM') && (Dir == Vect(0,0,0)) )
	{
		if ( Weapon.bRapidFire )
		{
			// Here we play still firing sequences
			if ( GetAnimGroup(AnimSequence) == 'Ducking' )
			{
				if ( Weapon.Mass < 20 )
					TweenAnim('DuckFireS', 0.02);
				else
					TweenAnim('DuckFireL', 0.02);
				return;
			}
			else
			{
				if ( Weapon.Mass < 20 )
					TweenAnim('StillSMFRRP', 0.02);
				else
					TweenAnim('StillLgFRRP', 0.02);
			}
		}
		else
		{
			// Here we play still firing sequences
			if ( GetAnimGroup(AnimSequence) == 'Ducking' )
			{
				//PlayAnim('DuckFireS');

				if ( Weapon.Mass < 6 )
					TweenAnim('DuckIdleKGSlash', 0.02);
				else if ( Weapon.Mass < 11 )
					TweenAnim('DuckIdleKGThrow', 0.02);
				else if ( Weapon.Mass < 20 )
					TweenAnim('DuckFireS', 0.02);
				else
					TweenAnim('DuckFireL', 0.02);
			}
			else
			{
				if ( Weapon.Mass < 6 )
					TweenAnim('StillKGSlash', 0.02);
				else if ( Weapon.Mass < 11 )
					TweenAnim('StillKGThrow', 0.02);
				else if ( Weapon.Mass < 20 )
					TweenAnim('StillSmFR', 0.02);
				else
					TweenAnim('StillLgFR', 0.02);
			}
		}
	}
}

function PlayWeaponSwitch(Weapon NewWeapon)
{
	// We're carrying a knife or grenade
	if ( (Weapon!=None) && (Weapon.Mass < 11) )
	{
		// New weapon is two handed
		if ( (NewWeapon != None) && (NewWeapon.Mass > 20) )
		{
			if ( (AnimSequence == 'RunKG') || (AnimSequence == 'RunKGSlash') || (AnimSequence == 'RunKGThrow') )
				AnimSequence = 'RunLG';
			else if ( (AnimSequence == 'WalkKG') || (AnimSequence == 'WalkKGSlash') || (AnimSequence == 'WalkKGThrow') )
				AnimSequence = 'WalkLG';
		 	else if ( AnimSequence == 'JumpSMFR' )
		 		AnimSequence = 'JumpLGFR';
			else if ( (AnimSequence == 'DuckWlkKG') ||(AnimSequence == 'DuckWlkKGSlash') || (AnimSequence == 'DuckWlkKGThrow') )
				AnimSequence = 'DuckWlkL';
			else if ( (AnimSequence == 'DuckIdleKG') ||(AnimSequence == 'DuckIdleKGSlash') || (AnimSequence == 'DuckIdleKGThrow') )
				AnimSequence = 'DuckIdleL';
		 	else if ( (AnimSequence == 'StillKGSlash') || (AnimSequence == 'StillKGThrow') )
		 		AnimSequence = 'StillLgFr';
			else if ( AnimSequence == 'AimDnKG' )
				AnimSequence = 'AimDnLg';
			else if ( AnimSequence == 'AimUpKG' )
				AnimSequence = 'AimUpLg';
			else if ( AnimSequence == 'Breath1KG' )
				AnimSequence = 'Breath1L';
		}
		// New weapon is single handed
		else if ( (NewWeapon == None) || (NewWeapon.Mass < 20) )
		{
			if ( (AnimSequence == 'RunKG') || (AnimSequence == 'RunKGSlash') || (AnimSequence == 'RunKGThrow') )
				AnimSequence = 'RunSm';
			else if ( (AnimSequence == 'WalkKG') || (AnimSequence == 'WalkKGSlash') || (AnimSequence == 'WalkKGThrow') )
				AnimSequence = 'WalkSm';
		 	else if ( AnimSequence == 'JumpLgFR' )
		 		AnimSequence = 'JumpSmFR';
			else if ( (AnimSequence == 'DuckWlkKG') ||(AnimSequence == 'DuckWlkKGSlash') || (AnimSequence == 'DuckWlkKGThrow') )
				AnimSequence = 'DuckWlkS';
			else if ( (AnimSequence == 'DuckIdleKG') ||(AnimSequence == 'DuckKGSlash') || (AnimSequence == 'DuckKGThrow') )
				AnimSequence = 'DuckIdleS';
		 	else if ( AnimSequence == 'StillKGSlash' || (AnimSequence == 'StillKGThrow') )
		 		AnimSequence = 'StillSmFr';
			else if ( AnimSequence == 'AimDnKG' )
				AnimSequence = 'AimDnSm';
			else if ( AnimSequence == 'AimUpKG' )
				AnimSequence = 'AimUpSm';
			else if ( AnimSequence == 'Breath1KG' )
				AnimSequence = 'Breath1';
		 }
	}
	// Weapon is single handed
	else if ( (Weapon == None) || (Weapon.Mass < 20) )
	{
		// New weapon is knife or grenade
		if ( (NewWeapon != None) && (NewWeapon.Mass < 11) )
		{
			if ( (AnimSequence == 'Run') || (AnimSequence == 'RunSM') || (AnimSequence == 'RunSMFR') )
				AnimSequence = 'RunKG';
			else if ( (AnimSequence == 'WalkSM') || (AnimSequence == 'WalkSMFR') )
				AnimSequence = 'WalkKG';
			else if ( AnimSequence == 'DuckWlkS' )
				AnimSequence = 'DuckWlkKG';
			else if ( AnimSequence == 'DuckIdleS' )
				AnimSequence = 'DuckIdleKG';
			else if ( AnimSequence == 'AimDnSm' )
				AnimSequence = 'AimDnKG';
			else if ( AnimSequence == 'AimUpSm' )
				AnimSequence = 'AimUpKG';
			else if ( (AnimSequence == 'Breath1') || (AnimSequence == 'Breath2') )
				AnimSequence = 'Breath1KG';
		}
		// New weapon is two handed
		else if ( (NewWeapon != None) && (NewWeapon.Mass > 20) )
		{
			if ( (AnimSequence == 'RunSM') || (AnimSequence == 'RunSMFR') )
				AnimSequence = 'RunLG';
			else if ( (AnimSequence == 'WalkSM') || (AnimSequence == 'WalkSMFR') )
				AnimSequence = 'WalkLG';
		 	else if ( AnimSequence == 'JumpSMFR' )
		 		AnimSequence = 'JumpLGFR';
			else if ( AnimSequence == 'DuckWlkL' )
				AnimSequence = 'DuckWlkS';
			else if ( AnimSequence == 'DuckIdleL' )
				AnimSequence = 'DuckIdleS';
		 	else if ( AnimSequence == 'StillSMFR' )
		 		AnimSequence = 'StillLgFR';
		 	else if ( AnimSequence == 'StillSMFRRP' )
		 		AnimSequence = 'StillLgFRRP';
			else if ( AnimSequence == 'AimDnSm' )
				AnimSequence = 'AimDnLg';
			else if ( AnimSequence == 'AimUpSm' )
				AnimSequence = 'AimUpLg';
			else if ( (AnimSequence == 'Breath1') || (AnimSequence == 'Breath2') )
				AnimSequence = 'Breath1L';
		 }
	}
	// Weapon is two handed
	else
	{
		// New weapon is knife or grenade
		if ( (NewWeapon != None) && (NewWeapon.Mass < 11) )
		{
			if ( (AnimSequence == 'RunLG') || (AnimSequence == 'RunLGFR') )
				AnimSequence = 'RunKG';
			else if ( (AnimSequence == 'WalkLG') || (AnimSequence == 'WalkLGFR') )
				AnimSequence = 'WalkKG';
			else if ( AnimSequence == 'DuckWlkL' )
				AnimSequence = 'DuckWlkKG';
			else if ( AnimSequence == 'DuckIdleL' )
				AnimSequence = 'DuckIdleKG';
			else if ( AnimSequence == 'AimDnLG' )
				AnimSequence = 'AimDnKG';
			else if ( AnimSequence == 'AimUpLG' )
				AnimSequence = 'AimUpKG';
			else if ( (AnimSequence == 'Breath1L') || (AnimSequence == 'Breath2L') )
				AnimSequence = 'Breath1KG';
		}
		// New weapon is single handed
		else if ( (NewWeapon == None) || (NewWeapon.Mass < 20) )
		{
			if ( (AnimSequence == 'RunLG') || (AnimSequence == 'RunLGFR') )
				AnimSequence = 'RunSM';
			else if ( (AnimSequence == 'WalkLG') || (AnimSequence == 'WalkLGFR') )
				AnimSequence = 'WalkSM';
	 		else if ( AnimSequence == 'JumpLGFR' )
	 			AnimSequence = 'JumpSMFR';
			else if ( AnimSequence == 'DuckWlkL' )
				AnimSequence = 'DuckWlkS';
			else if ( AnimSequence == 'DuckIdleL' )
				AnimSequence = 'DuckIdleS';
	 		else if (AnimSequence == 'StillLgFRRP')
	 			AnimSequence = 'StillSMFRRp';
	 		else if (AnimSequence == 'StillLgFR')
	 			AnimSequence = 'StillSMFR';
			else if ( AnimSequence == 'AimDnLg' )
				AnimSequence = 'AimDnSm';
			else if ( AnimSequence == 'AimUpLg' )
				AnimSequence = 'AimUpSm';
			else if ( (AnimSequence == 'Breath1L') || (AnimSequence == 'Breath2L') )
				AnimSequence = 'Breath1';
		}

	}
}

function PlayGutHit(float tweentime)
{
	if ( (AnimSequence == 'GutHit') || (AnimSequence == 'Dead2') )
	{
		if (FRand() < 0.5)
		{
			if ( (Weapon==None) || (Weapon.Mass<20) )
				TweenAnim('LeftHitS', tweentime);
			else
				TweenAnim('LeftHitL', tweentime);
		}
		else
		{
			if ( (Weapon==None) || (Weapon.Mass<20) )
				TweenAnim('RightHitS', tweentime);
			else
				TweenAnim('RightHitL', tweentime);
		}
	}
	else if ( FRand() < 0.6 )
		TweenAnim('GutHit', tweentime);
	else
		TweenAnim('Dead8', tweentime);

}

function PlayHeadHit(float tweentime)
{
	if ( (AnimSequence == 'HeadHit') || (AnimSequence == 'HeadHitL') || (AnimSequence == 'Dead4') )
		TweenAnim('GutHit', tweentime);
	else if ( FRand() < 0.6 )
	{
		if ( (Weapon==None) || (Weapon.Mass<20) )
			TweenAnim('HeadHit', tweentime);
		else
			TweenAnim('HeadHitL', tweentime);
	}
	else
		TweenAnim('Dead7', tweentime);
}

function PlayLeftHit(float tweentime)
{
	if ( (AnimSequence == 'LeftHitS') || (AnimSequence == 'LeftHitL') || (AnimSequence == 'Dead3') )
		TweenAnim('GutHit', tweentime);
	else if ( FRand() < 0.6 )
	{
		if ( (Weapon==None) || (Weapon.Mass<20) )
			TweenAnim('LeftHitS', tweentime);
		else
			TweenAnim('LeftHitL', tweentime);
	}
	else
		TweenAnim('Dead9', tweentime);
}

function PlayRightHit(float tweentime)
{
	if ( (AnimSequence == 'RightHitS') || (AnimSequence == 'RightHitL') || (AnimSequence == 'Dead5') )
		TweenAnim('GutHit', tweentime);
	else if ( FRand() < 0.6 )
	{
		if ( (Weapon==None) || (Weapon.Mass<20) )
			TweenAnim('RightHitS', tweentime);
		else
			TweenAnim('RightHitL', tweentime);
	}
	else
		TweenAnim('Dead1', tweentime);
}


function PlayInAir()
{
	local vector X,Y,Z, Dir;
	local float f, TweenTime;

	BaseEyeHeight =  0.7 * Default.BaseEyeHeight;

	if ( (GetAnimGroup(AnimSequence) == 'Landing') && !bLastJumpAlt )
	{
		GetAxes(Rotation, X,Y,Z);
		Dir = Normal(Acceleration);
		f = Dir dot Y;
		if ( f > 0.7 )
		{
			if ( (Weapon==None) || (Weapon.Mass<20) )
				TweenAnim('DodgeLSm', 0.35);
			else
				TweenAnim('DodgeLLg', 0.35);
		}
		else if ( f < -0.7 )
		{
			if ( (Weapon==None) || (Weapon.Mass<20) )
				TweenAnim('DodgeRSm', 0.35);
			else
				TweenAnim('DodgeRLg', 0.35);
		}
		else if ( Dir dot X > 0 )
		{
			if ( (Weapon==None) || (Weapon.Mass<20) )
				TweenAnim('DodgeFSm', 0.35);
			else
				TweenAnim('DodgeFLg', 0.35);
		}
		else
		{
			if ( (Weapon==None) || (Weapon.Mass<20) )
				TweenAnim('DodgeBSm', 0.35);
			else
				TweenAnim('DodgeBLg', 0.35);
		}
		bLastJumpAlt = true;
		return;
	}
	bLastJumpAlt = false;
	if ( GetAnimGroup(AnimSequence) == 'Jumping' )
	{
		if ( (Weapon == None) || (Weapon.Mass < 20) )
			TweenAnim('DuckWlkS', 2);
		else
			TweenAnim('DuckWlkL', 2);
		return;
	}
	else if ( GetAnimGroup(AnimSequence) == 'Ducking' )
		TweenTime = 2;
	else
		TweenTime = 0.7;

	if ( AnimSequence == 'StrafeL' )
	{
		if ( (Weapon==None) || (Weapon.Mass<20) )
			TweenAnim('DodgeRSm', TweenTime);
		else
			TweenAnim('DodgeRLg', TweenTime);
	}
	else if ( AnimSequence == 'StrafeR' )
	{
		if ( (Weapon==None) || (Weapon.Mass<20) )
			TweenAnim('DodgeLSm', TweenTime);
		else
			TweenAnim('DodgeLLg', TweenTime);
	}
	else if ( (AnimSequence == 'BackRun') || (AnimSequence == 'BackRunS') || (AnimSequence == 'BackRunKG')
		|| (AnimSequence == 'BackWalk') )
	{
		if ( (Weapon==None) || (Weapon.Mass<20) )
			TweenAnim('DodgeBSm', TweenTime);
		else
			TweenAnim('DodgeBLg', TweenTime);
	}
	else if ( (Weapon == None) || (Weapon.Mass < 20) )
		TweenAnim('JumpSMFR', TweenTime);
	else
		TweenAnim('JumpLGFR', TweenTime);
}


// remove Cockgun
function PlayWaiting()
{
	local name newAnim;

	if ( Mesh == None )
		return;

	if ( bIsTyping )
	{
		PlayChatting();
		return;
	}

	if ( (Weapon!=None) && (Weapon.IsA('s_Weapon') && s_Weapon(Weapon).bReloadingWeapon) )
	{
		// Don't play anim twice in a row
		if ( (AnimSequence != 'CockGun') && (AnimSequence != 'CockGunL') )
		{
			s_Weapon(Weapon).bReloadingWeapon = false; // play only once
			PlayWeaponReloading();
			return;
		}
	}

	if ( (IsInState('PlayerSwimming')) || (Physics == PHYS_Swimming) )
	{
		BaseEyeHeight = 0.7 * Default.BaseEyeHeight;
		if ( (Weapon == None) || (Weapon.Mass < 20) )
			LoopAnim('TreadSM');
		else
			LoopAnim('TreadLG');
	}
	else
	{
		BaseEyeHeight = Default.BaseEyeHeight;
		ViewRotation.Pitch = ViewRotation.Pitch & 65535;
		if ( (ViewRotation.Pitch > RotationRate.Pitch)
			&& (ViewRotation.Pitch < 65536 - RotationRate.Pitch) )
		{
			if ( ViewRotation.Pitch < 32768 )
			{
				if ( (Weapon!=None) && (Weapon.Mass < 11) )
					TweenAnim('AimUpKG', 0.3);
				else if ( (Weapon == None) || (Weapon.Mass < 20) )
					TweenAnim('AimUpSm', 0.3);
				else
					TweenAnim('AimUpLg', 0.3);
			}
			else
			{
				if ( (Weapon!=None) && (Weapon.Mass < 11) )
					TweenAnim('AimDnKG', 0.3);
				else if ( (Weapon == None) || (Weapon.Mass < 20) )
					TweenAnim('AimDnSm', 0.3);
				else
					TweenAnim('AimDnLg', 0.3);
			}
		}
		else if ( (Weapon != None) && Weapon.bPointing )
		{
			if ( Weapon.bRapidFire && ((bFire != 0) || (bAltFire != 0)) )
			{
				if ( Weapon.Mass < 20 )
					LoopAnim('StillSmFrRP');
				else
					LoopAnim('StillLgFrRP');
			}
			else if ( Weapon.Mass < 6 )
				TweenAnim('StillKGSlash', 0.3);
			else if ( Weapon.Mass < 11 )
				TweenAnim('StillKGThrow', 0.3);
			else if ( Weapon.Mass < 20 )
				TweenAnim('StillSmFr', 0.3);
			else
				TweenAnim('StillLgFr', 0.3);
		}
		else
		{
			if ( (Weapon != None) && (Weapon.Mass < 11) )
			{
				newAnim = 'Breath1KG';
			}
			else if ( (Weapon == None) || (Weapon.Mass < 20) )
			{
				if ( (FRand() < 0.75) && ((AnimSequence == 'Breath1') || (AnimSequence == 'Breath2')) )
					newAnim = AnimSequence;
				else if ( FRand() < 0.5 )
					newAnim = 'Breath1';
				else
					newAnim = 'Breath2';
			}
			else
			{
				if ( (FRand() < 0.75) && ((AnimSequence == 'Breath1L') || (AnimSequence == 'Breath2L')) )
					newAnim = AnimSequence;
				else if ( FRand() < 0.5 )
					newAnim = 'Breath1L';
				else
					newAnim = 'Breath2L';
			}

			if ( AnimSequence == newAnim )
				LoopAnim(newAnim, 0.4 + 0.4 * FRand());
			else
				PlayAnim(newAnim, 0.4 + 0.4 * FRand(), 0.25);
		}
	}
}


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
		PlayDecap();
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
			PlayDecap();
		else
			PlayAnim('Dead7',, 0.1);
		return;
	}

	if ( Region.Zone.bWaterZone || (FRand() < 0.5) ) //then hit in front or back
		PlayAnim('Dead3',, 0.1);
	else
		PlayAnim('Dead8',, 0.1);
}

function PlayDecap()
{
	local carcass carc;

	PlayAnim('Dead4',, 0.1);
	/*if ( Level.NetMode != NM_Client )
	{
		carc = Spawn(class 'UT_HeadMale',,, Location + CollisionHeight * vect(0,0,0.8), Rotation + rot(3000,0,16384) );
		if (carc != None)
		{
			carc.Initfor(self);
			carc.Velocity = Velocity + VSize(Velocity) * VRand();
			carc.Velocity.Z = FMax(carc.Velocity.Z, Velocity.Z);
		}
	}*/
}



///////////////////////////////////////
// PlayLanded
///////////////////////////////////////

function PlayLanded(float impactVel)
{
	impactVel = impactVel/JumpZ;
	impactVel = 0.1 * impactVel * impactVel;
	BaseEyeHeight = Default.BaseEyeHeight;

	if ( impactVel > 0.40 )
		PlayOwnedSound(LandGrunt, SLOT_Talk, FMin(5, impactVel),false, 1200, FRand()*0.4+0.8);
	if ( !FootRegion.Zone.bWaterZone && (impactVel > 0.01) )
		PlayOwnedSound(Land, SLOT_Interact, FClamp(4 * impactVel,0.5,5), false,1000, 1.0);
	if ( (impactVel > 0.06) || (GetAnimGroup(AnimSequence) == 'Jumping') || (GetAnimGroup(AnimSequence) == 'Ducking') )
	{
		if ( (Weapon == None) || (Weapon.Mass < 20) )
			TweenAnim('LandSMFR', 0.12);
		else
			TweenAnim('LandLGFR', 0.12);
	}
	else if ( !IsAnimating() )
	{
		if ( GetAnimGroup(AnimSequence) == 'TakeHit' )
		{
			SetPhysics(PHYS_Walking);
			AnimEnd();
		}
		else
		{
			if ( (Weapon == None) || (Weapon.Mass < 20) )
				TweenAnim('LandSMFR', 0.12);
			else
				TweenAnim('LandLGFR', 0.12);
		}
	}
}


// Changing Strafe anims to support one handed and 2 handed weapons

function TweenToRunning(float tweentime)
{
	local vector X,Y,Z, Dir;

	if ( mesh == None )
		return;

	BaseEyeHeight = Default.BaseEyeHeight;
	if ( bIsWalking )
	{
		TweenToWalking(0.1);
		return;
	}

	GetAxes(Rotation, X,Y,Z);
	Dir = Normal(Acceleration);
	if ( (Dir Dot X < 0.75) && (Dir != vect(0,0,0)) )
	{
		// strafing or backing up
		if ( (Weapon==None) || (Weapon.Mass < 11) )
		{
			if ( Dir Dot X < -0.75 )
				PlayAnim('BackRunKG', 0.9, tweentime);
			else if ( Dir Dot Y > 0 )
				PlayAnim('StrafeRKG', 0.9, tweentime);
			else
				PlayAnim('StrafeLKG', 0.9, tweentime);
		}
		else if ( Weapon.Mass < 20 )
		{
			if ( Dir Dot X < -0.75 )
				PlayAnim('BackRunS', 0.9, tweentime);
			else if ( Dir Dot Y > 0 )
				PlayAnim('StrafeSmR', 0.9, tweentime);
			else
				PlayAnim('StrafeSmL', 0.9, tweentime);
		}
		else
		{
			if ( Dir Dot X < -0.75 )
				PlayAnim('BackRun', 0.9, tweentime);
			else if ( Dir Dot Y > 0 )
				PlayAnim('StrafeR', 0.9, tweentime);
			else
				PlayAnim('StrafeL', 0.9, tweentime);
		}
	}
	else if ( Weapon == None )
		PlayAnim('Run', 0.9, tweentime);
	else if ( Weapon.bPointing )
	{
		if ( Weapon.Mass < 11 )
			PlayAnim('RunKG', 0.9, tweentime);
		else if (Weapon.Mass < 20)
			PlayAnim('RunSMFR', 0.9, tweentime);
		else
			PlayAnim('RunLGFR', 0.9, tweentime);
	}
	else
	{
		if ( Weapon.Mass < 11 )
			PlayAnim('RunKG', 0.9, tweentime);
		else if (Weapon.Mass < 20)
			PlayAnim('RunSM', 0.9, tweentime);
		else
			PlayAnim('RunLG', 0.9, tweentime);
	}
}

function PlayRunning()
{
	local vector X,Y,Z, Dir;

	BaseEyeHeight = Default.BaseEyeHeight;

	// determine facing direction
	GetAxes(Rotation, X,Y,Z);
	Dir = Normal(Acceleration);
	if ( (Dir Dot X < 0.75) && (Dir != vect(0,0,0)) )
	{
		// strafing or backing up
		if ( (Weapon==None) || (Weapon.Mass < 11) )
		{
			if ( Dir Dot X < -0.75 )
				LoopAnim('BackRunKG');
			else if ( Dir Dot Y > 0 )
				LoopAnim('StrafeRKG');
			else
				LoopAnim('StrafeLKG');
		}
		else if (Weapon.Mass < 20)
		{
			if ( Dir Dot X < -0.75 )
				LoopAnim('BackRunS');
			else if ( Dir Dot Y > 0 )
				LoopAnim('StrafeSmR');
			else
				LoopAnim('StrafeSmL');
		}
		else
		{
			if ( Dir Dot X < -0.75 )
				LoopAnim('BackRun');
			else if ( Dir Dot Y > 0 )
				LoopAnim('StrafeR');
			else
				LoopAnim('StrafeL');
		}
	}
	else if ( Weapon == None )
		LoopAnim('Run');
	else if ( Weapon.bPointing )
	{
		if (Weapon.Mass < 11)
			LoopAnim('RunKG');
		else if (Weapon.Mass < 20)
			LoopAnim('RunSMFR');
		else
			LoopAnim('RunLGFR');
	}
	else
	{
		if ( Weapon.Mass < 11 )
			LoopAnim('RunKG');
		else if (Weapon.Mass < 20)
			LoopAnim('RunSM');
		else
			LoopAnim('RunLG');
	}
}


function PlayDuck()
{
	local vector Dir;

	Dir = Normal(Acceleration);
	BaseEyeHeight = 0;

	if ( Dir == vect(0,0,0) )
	{   /* Onion - fix players not ducking while firing
		if ( (Weapon!=None) && (Weapon.bPointing) )
		{
			return;
		}
		else
		{*/
			if ( Weapon.Mass < 11 )
				TweenAnim('DuckIdleKG', 0.25);
			else if ( Weapon.Mass < 20 )
				TweenAnim('DuckIdleS', 0.25);
			else
				TweenAnim('DuckIdleL', 0.25);
		//}
	}
	else
	{
		/* Onion - fix playes not ducking while firing
		if ( (Weapon!=None) && (Weapon.bPointing) )
		{
			return;
		}
		else
		{   */
			if ( (Weapon != None) && (Weapon.Mass < 11) )
				TweenAnim('DuckWlkKG', 0.25);
			else if ( (Weapon == None) || (Weapon.Mass < 20) )
				TweenAnim('DuckWlkS', 0.25);
			else
				TweenAnim('DuckWlkL', 0.25);
		//}
	}
}


function PlayCrawling()
{
	local vector Dir;

	Dir = Normal(Acceleration);
	BaseEyeHeight = 0;

	if ( Dir == vect(0,0,0) )
	{
		if ( (Weapon!=None) && (Weapon.bPointing) )
		{
			if ( Weapon.Mass < 6 )
				LoopAnim('DuckIdleKGSlash');
			else if ( Weapon.Mass < 11 )
				LoopAnim('DuckIdleKGThrow');
			else if ( Weapon.Mass < 20 )
				LoopAnim('DuckFireS');
			else
				LoopAnim('DuckFireL');
		}
		else
		{
			if ( Weapon.Mass < 6 )
				LoopAnim('DuckIdleKG');
			else if ( Weapon.Mass < 20 )
				LoopAnim('DuckIdleS');
			else
				LoopAnim('DuckIdleL');
		}
	}
	else
	{
		if ( (Weapon!=None) && (Weapon.bPointing) )
		{
			if ( Weapon.Mass < 6 )
				LoopAnim('DuckWlkKGSlash');
			else if ( Weapon.Mass < 11 )
				LoopAnim('DuckWlkKGThrow');
			else if ( Weapon.Mass < 20 )
				LoopAnim('DuckWlkSFr');
			else
				LoopAnim('DuckWlkLFr');
		}
		else
		{
			if ( (Weapon != None) && (Weapon.Mass < 11) )
				LoopAnim('DuckWlkKG');
			else if ( (Weapon == None) || (Weapon.Mass < 20) )
				LoopAnim('DuckWlkS');
			else
				LoopAnim('DuckWlkL');
		}
	}
}

function TweenToWalking(float tweentime)
{
	BaseEyeHeight = Default.BaseEyeHeight;
	if (Weapon == None)
		TweenAnim('Walk', tweentime);
	else if ( Weapon.bPointing || (CarriedDecoration != None) )
	{
		if (Weapon.Mass < 11)
			TweenAnim('WalkKG', tweentime);
		else if (Weapon.Mass < 20)
			TweenAnim('WalkSMFR', tweentime);
		else
			TweenAnim('WalkLGFR', tweentime);
	}
	else
	{
		if (Weapon.Mass < 11)
			TweenAnim('WalkKG', tweentime);
		else if (Weapon.Mass < 20)
			TweenAnim('WalkSM', tweentime);
		else
			TweenAnim('WalkLG', tweentime);
	}
}


function PlayWalking()
{
	BaseEyeHeight = Default.BaseEyeHeight;
	if (Weapon == None)
		LoopAnim('Walk');
	else if ( Weapon.bPointing || (CarriedDecoration != None) )
	{
		if (Weapon.Mass < 11)
			LoopAnim('WalkKG');
		else if (Weapon.Mass < 20)
			LoopAnim('WalkSMFR');
		else
			LoopAnim('WalkLGFR');
	}
	else
	{
		if (Weapon.Mass < 11)
			LoopAnim('WalkKG');
		else if (Weapon.Mass < 20)
			LoopAnim('WalkSM');
		else
			LoopAnim('WalkLG');
	}
}


function PlayTurning()
{
	BaseEyeHeight = Default.BaseEyeHeight;
	if ( (Weapon == None) || (Weapon.Mass < 20) )
		PlayAnim('TurnSM', 0.3, 0.3);
	else
		PlayAnim('TurnLG', 0.3, 0.3);
}


function PlayRising()
{
	BaseEyeHeight = 0.4 * Default.BaseEyeHeight;
	if ( (Weapon!=None) && (weapon.mass<11) )
		TweenAnim('DuckWlkKG', 0.7);
	else if ( (weapon==none) || (weapon.mass<20) )
		TweenAnim('DuckWlkS', 0.7);
	else
		TweenAnim('DuckWlkL', 0.7);
}

defaultproperties
{
}
