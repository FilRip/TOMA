class TOMAChildSWATTeam extends s_ChildSWATTeam;

function int CountSWATPlayers()
{
	local int Num;
	local int i;

	num=0;
	for(i=0;i<32;i++)
		if ((Class'TOPModels.TO_ModelHandler'.default.ModelName[i]!="") && (Class'TOPModels.TO_ModelHandler'.default.ModelType[i]!=MT_Hostage))
		{
			Playernumber[Num]=i;
			Num++;
		}

	return Num;
}

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
	NumOptions=CountSWATPlayers();
	Super(s_SWATWindow).Created();
	for(i=0;i<NumOptions;i++)
		OptionButtons[i].Text=Class'TOPModels.TO_ModelHandler'.static.GetModelName(Playernumber[i]);
	TopButton.OverTexture=Texture'OrdersTopArrow';
	TopButton.UpTexture=Texture'OrdersTopArrow';
	TopButton.DownTexture=Texture'OrdersTopArrow';
	TopButton.WinLeft=0;
	BottomButton.OverTexture=Texture'OrdersBtmArrow';
	BottomButton.UpTexture=Texture'OrdersBtmArrow';
	BottomButton.DownTexture=Texture'OrdersBtmArrow';
	BottomButton.WinLeft=0;
	MinOptions=Min(8,NumOptions);
	WinTop=(196/768*YMod)+(32/768*YMod)*CurrentType;
	WinLeft=512/1024*XMod;
	WinWidth=256/1024*XMod;
	WinHeight=(32/768*YMod)*(MinOptions+2);
	SetButtonTextures(0,True,False);
}

function Notify(UWindowWindow B, byte E)
{
	local int i;
	local ammo ammotype;

	switch (E)
	{
		case DE_DoubleClick:
		case DE_Click:
			GetPlayerOwner().PlaySound(sound'SpeechWindowClick', SLOT_Interact);
			for (i=0;i<NumOptions;i++)
			{
				if (B == OptionButtons[i])
				{
					s_Player(GetPlayerOwner()).s_ChangeTeam(Playernumber[i], 1, false);
				}
			}
			if (B == TopButton)
			{
				if (NumOptions > 8)
				{
					if (OptionOffset > 0)
						OptionOffset--;
				}
			}
			if (B == BottomButton)
			{
				if (NumOptions > 8)
				{
					if (NumOptions - OptionOffset > 8)
						OptionOffset++;
				}
			}
			break;
	}
}

defaultproperties
{
}
