class TOBulletTime expands Mutator;

var() config int TimeOfBullet;
var() config int EverySec;
var int internalcounter;
var bool underbt;
var() config bool EnableBulletTime;

event Destroyed()
{
	SetBullet(1);
	Super.Destroy();
}

function PreBeginPlay()
{
	if (EnableBulletTime)
	{
		internalcounter=0;
		underbt=false;
		setbullet(1);
		settimer(1,true);
	}
}

function SetBullet(int i)
{
	s_SWATGame(Level.Game).SetGameSpeed(i);
}

function PlaySoundToAll()
{
	local S_Player_T joueur;

	foreach AllActors(class'S_Player_T',joueur)
		joueur.ClientPlaySound(Sound'TOExtraModels.sonbt');
}

function Timer()
{
	if (EnableBulletTime)
	{
		if (S_SWATGame(Level.Game).GamePeriod==GP_RoundPlaying)
		{
			internalcounter++;
			if (underbt)
			{
				if (internalcounter==TimeOfBullet)
				{
					Level.Game.BroadcastMessage("BulletTime OFF");
					internalcounter=0;
					SetBullet(1);
					underbt=false;
				} else
				PlaySoundToAll();
			}
			else
			{
				if (internalcounter==EverySec)
				{
					Level.Game.BroadcastMessage("BulletTime ON");
					internalcounter=0;
					SetBullet(0.5);
					underbt=true;
					PlaySoundToAll();
				}
			}
		}
		if (S_SWATGame(Level.Game).GamePeriod==GP_PostMatch) SetBullet(1);
	}
}

defaultproperties
{
	TimeOfBullet=5
	EverySec=60
}
