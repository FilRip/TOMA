class TOMAExplosiveC4 extends s_ExplosiveC4;

var Pawn PlayerInstigator;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	CDSpeed=1;
	MaxCount=5;
	CountDown=(MaxCount+0.7)*3;
	ChangeCount=0;
	SetTimer(CDSpeed,false);
}

function C4Complete()
{
	local Actor A;
	local TOMAMod TG;

	if (SoundCompleted!=None)
		PlaySound(SoundCompleted,SLOT_None,4);

	bBeingActivated=false;

	TG=TOMAMod(Level.Game);
	if (TG!=None)
		TG.TOMAC4Defused(DefusedBy);
	else
		log("s_ExplosiveC4 - C4Complete - SW == None");

	Destroy();
}

simulated function C4Explode()
{
	local TO_GrenadeExplosion expl;
	local TOMAC4ShockWave SW;
	local int i;

	if ((Role!=Role_Authority) || (!IsRoundPeriodPlaying()))
	{
		destroy();
		return;
	}

	CurrentBombingZone=None;
	for (i=0;i<4;i++)
	{
		if ((Touching[i]!=None) && (Touching[i].IsA('s_ZoneControlPoint')) && (s_ZoneControlPoint(Touching[i]).bBombingZone))
		{
			CurrentBombingZone=Touching[i];
			break;
		}
	}

// Prevent SF to win/loose
	s_SWATGame(Level.Game).bC4Explodes=true;

	SW=spawn(class'TOMAC4ShockWave',,,Location);
	SW.C4Instigator=PlayerInstigator;
	SW.Instigator=PlayerInstigator;

	expl=spawn(class'TO_GrenadeExplosion',,,Location);
	expl.Scale=4.0;
	expl.Instigator=PlayerInstigator;

	bExploded=true;
	SetTimer(2.0,false);
}

simulated function Timer()
{
	local s_SWATGame SG;

	if (Role==Role_Authority)
	{
		SG=s_SWATGame(Level.Game);

		if (bExploded)
		{
			if (SG!=None)
			{
				TOMAMod(SG).TOMAC4Exploded(bPlantedInBombingSpot,CurrentBombingZone);
			}
			else
				log("s_ExplosiveC4 - Timer - SG == None");

			Destroy();
			return;
		}

		if ((CountDown<11.0) && (!bToldToLeave))
		{
//			SG.SendGlobalBotObjective(None,0.8,2,'O_GoHome',false);
			bToldToLeave=true;
		}
	}

	Count++;
	if (Count>=MaxCount)
	{
		if (ChangeCount==2)
			C4Explode();
		else
		{
			Count=0;
			CDSpeed/=2.0;
			MaxCount*=2.0;
			ChangeCount++;

/*			if ((ChangeCount<2) && (Role==Role_Authority))
				SG.SendGlobalBotObjective(Self,1.0,1,'O_DefuseC4',false);*/
		}
	}

	if (Level.NetMode!=NM_DedicatedServer)
	{
		if (CountDown<5.0)
			playsound(Sound'UTMenu.SpeechWindowClick',SLOT_Misc,1.0,,4096.0*3.0, 1.25);
		else
			playsound(Sound'UTMenu.SpeechWindowClick',SLOT_Misc,1.0,,4096.0*3.0, 1.10);
	}
	SetTimer(CDSpeed,false);
}

defaultproperties
{
}
