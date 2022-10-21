class MA_SoundBox extends Actor;

var Actor SoundPlayer;
var bool bRain;

#exec OBJ LOAD FILE=..\Sounds\AmbOutside.uax PACKAGE=AmbOutside
#exec OBJ LOAD FILE=..\TacticalOps\Sounds\TOsoundpack.uax PACKAGE=TOsoundpack

function SetAmbientSound (byte Num)
{
	switch (Num)
	{
		case 0:
		AmbientSound=Sound'Waterfall';
		bRain=True;
		break;
		case 1:
		AmbientSound=Sound'cricket2';
	}
	SoundVolume=255;
}

event Tick (float Delta)
{
	if (PlayerPawn(Owner).ViewTarget == None )
	{
		SoundPlayer=Owner;
	}
	else
	{
		SoundPlayer=PlayerPawn(Owner).ViewTarget;
	}
	
	SetLocation(SoundPlayer.Location);
	
	if ( bRain )
	{
		if ( FastTrace(Location,Location + 600*vect(0,0,1)) && SoundVolume < 255 )
		{
			SoundVolume++;
		}
		else if ( SoundVolume > 128 )
		{
			SoundVolume--;
		}
	}
}

function MAplaySound (byte Num)
{
	local Sound Sound;

	switch (Num)
	{
		Case 0:
			Sound=Sound'lightn1a';
			break;
		Case 1:
			Sound=Sound'lightn2a';
			break;
		Case 2:
			Sound=Sound'lightn3a';
			break;
		Case 3:
			Sound=Sound'lightn4a';
			break;
		Case 4:
			Sound=Sound'lightn5a';
			break;
	}
	ViewerPlaySound(Sound);
}

function ViewerPlaySound (Sound Sound)
{
	SoundPlayer.SoundVolume=255;
	SoundPlayer.PlaySound(Sound,SLOT_None,32.00);
	SoundPlayer.PlaySound(Sound,SLOT_Interface,32.00);
	SoundPlayer.PlaySound(Sound,SLOT_Misc,32.00);
	SoundPlayer.PlaySound(Sound,SLOT_Talk,32.00);
}

defaultproperties
{
    bHidden=True
}
