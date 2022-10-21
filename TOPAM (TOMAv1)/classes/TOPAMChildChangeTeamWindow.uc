class TOPAMChildChangeTeamWindow extends s_ChildChangeTeamWindow;

function Notify(UWindowWindow B, byte E)
{
	local int i;
	local ammo ammotype;

	switch (E)
	{
		case DE_DoubleClick:
		case DE_Click:
			GetPlayerOwner().PlaySound(sound'SpeechWindowClick',SLOT_Interact);
			switch (B)
			{
				case OptionButtons[0]:
					SetButtonTextures(SpeechButton(B).Type, False,True);
					HideChildren();
					CurrentType=SpeechButton(B).Type;
					SpeechChild=SpeechWindow(ParentWindow.CreateWindow(class'TOPAM.TOPAMChildTerroristTeam',100,100,100,100));
					SpeechChild.FadeIn();
					break;
				case OptionButtons[1]:
					SetButtonTextures(SpeechButton(B).Type, False,True);
					HideChildren();
					CurrentType=SpeechButton(B).Type;
					SpeechChild=SpeechWindow(ParentWindow.CreateWindow(class's_SWAT.s_ChildSWATTeam',100,100,100,100));
					SpeechChild.FadeIn();
					break;
			}
			if (B==TopButton)
			{
				if (NumOptions>8)
				{
					if (OptionOffset>0)
						OptionOffset--;
				}
			}
			if (B==BottomButton)
			{
				if (NumOptions>8)
				{
					if (NumOptions-OptionOffset>8)
						OptionOffset++;
				}
			}
			break;
	}
}

defaultproperties
{
}

