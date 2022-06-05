Class VIPTO_ChildSWATTeam extends s_ChildSWATTeam;

function int CountSWATPlayers()
{
	local int Num;
	local int i;

	num=0;
	for(i=0;i<19;i++)
		if ((Class'TOPModels.TO_ModelHandler'.static.IsASFModel(i)) && (i!=19) && (i!=20))
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
	WinTop=(196/768*YMod)+(32/768*YMod)*(CurrentType);
	WinLeft=512/1024*XMod;
	WinWidth=256/1024*XMod;
	WinHeight=(32/768*YMod)*(MinOptions+2);
	SetButtonTextures(0,True,False);
}

defaultproperties
{
}
