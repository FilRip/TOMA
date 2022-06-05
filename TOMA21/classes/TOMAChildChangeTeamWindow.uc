Class TOMAChildChangeTeamWindow extends s_ChildChangeTeamWindow config(TOMA);

var() config localized string NameOfTeam;

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
	NumOptions=1;
	Super(s_SWATWindow).Created();
	OptionButtons[0].text=NameOfTeam;
	TopButton.OverTexture=Texture'OrdersTopArrow';
	TopButton.UpTexture=Texture'OrdersTopArrow';
	TopButton.DownTexture=Texture'OrdersTopArrow';
	TopButton.WinLeft=0;
	BottomButton.OverTexture=Texture'OrdersBtmArrow';
	BottomButton.UpTexture=Texture'OrdersBtmArrow';
	BottomButton.DownTexture=Texture'OrdersBtmArrow';
	BottomButton.WinLeft=0;
	MinOptions=Min(8,NumOptions);
	WinTop=(196/768*YMod)+(32/768*YMod)*(CurrentType-1)+50;
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
			case OptionButtons[0]:
			SetButtonTextures(SpeechButton(B).Type,False,True);
			HideChildren();
			CurrentType=SpeechButton(B).Type;
			SpeechChild=SpeechWindow(ParentWindow.CreateWindow(Class'TOMAChildSWATTeam',100,100,100,100));
			SpeechChild.FadeIn();
			break;
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
	NameOfTeam="Special Forces"
}
