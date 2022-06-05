Class VIPTO_ChildChangeTeamWindow extends s_ChildChangeTeamWindow;

function Created ()
{
	local int i;
	local int W;
	local int H;
	local float XMod;
	local float YMod;

	W=Root.WinWidth/4;
	H=W;
	if ((W>256) || (H>256))
	{
		W=256;
		H=256;
	}
	XMod=4*W;
	YMod=3*H;
	CurrentType=SpeechWindow(ParentWindow).CurrentType;
	NumOptions=2;
	Super(s_SWATWindow).Created();
	for(i=0;i<NumOptions;i++)
		OptionButtons[i].Text=TeamName[i];
	TopButton.OverTexture=Texture'OrdersTopArrow';
	TopButton.UpTexture=Texture'OrdersTopArrow';
	TopButton.DownTexture=Texture'OrdersTopArrow';
	TopButton.WinLeft=0;
	BottomButton.OverTexture=Texture'OrdersBtmArrow';
	BottomButton.UpTexture=Texture'OrdersBtmArrow';
	BottomButton.DownTexture=Texture'OrdersBtmArrow';
	BottomButton.WinLeft=0;
	MinOptions=Min(8,NumOptions);
	WinTop=(196/768*YMod)+(32/768*YMod)*(CurrentType-1);
	WinLeft=256/1024*XMod;
	WinWidth=256/1024*XMod;
	WinHeight=(32/768*YMod)*(MinOptions+2);
	SetButtonTextures(0,True,False);
}

function Notify (UWindowWindow B, byte E)
{
	local int i;
	local Ammo AmmoType;

	switch (E)
	{
		case 11:
		case 2:
		GetPlayerOwner().PlaySound(Sound'SpeechWindowClick',SLOT_Interact);
		switch (B)
		{
			case OptionButtons[1]:
			SetButtonTextures(SpeechButton(B).Type,False,True);
			HideChildren();
			CurrentType=SpeechButton(B).Type;
			SpeechChild=SpeechWindow(ParentWindow.CreateWindow(Class'VIPTO_ChildSWATTeam',100,100,100,100));
			SpeechChild.FadeIn();
			break;
			case OptionButtons[0]:
			SetButtonTextures(SpeechButton(B).Type,False,True);
			HideChildren();
			CurrentType=SpeechButton(B).Type;
			SpeechChild=SpeechWindow(ParentWindow.CreateWindow(Class's_ChildTerroristTeam',100.00,100.00,100.00,100.00));
			SpeechChild.FadeIn();
			break;
			default:
		}
		if (B==TopButton)
			if (NumOptions>8)
				if (OptionOffset>0)
					OptionOffset--;
		if (B==BottomButton)
			if (NumOptions>8)
				if (NumOptions-OptionOffset>8)
					OptionOffset++;
		break;
		default:
	}
}

defaultproperties
{
}
