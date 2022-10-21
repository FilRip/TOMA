class AssaultChildTerroristTeam extends s_ChildTerroristTeam;

function int CountTerroristPlayers ()
{
	local int Num;
	local int i;

	for (i=0;i<32;i++)
	{
		if ((Class'TO_ModelHandler'.static.IsATerrModel(i)) && (Class'AssaultModelHandler'.static.ReturnClassName(i)!="") /*&& (AssaultGameReplicationInfo(GetPlayerOwner().GameReplicationInfo).PlaceInClass(Class'AssaultModelHandler'.Default.PClass[i],1)>0)*/)
		{
			Playernumber[Num]=i;
			Num++;
		}
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
	XMod=4.00 * W;
	YMod=3.00 * H;
	CurrentType=SpeechWindow(ParentWindow).CurrentType;
	NumOptions=CountTerroristPlayers();
	Super.Created();
	for (i=0;i<NumOptions;i++)
		OptionButtons[i].Text=Class'TOAS.AssaultModelHandler'.static.ReturnClassName(Playernumber[i])$Class'TO_ModelHandler'.Default.ModelName[Playernumber[i]];
	TopButton.OverTexture=Texture'OrdersTopArrow';
	TopButton.UpTexture=Texture'OrdersTopArrow';
	TopButton.DownTexture=Texture'OrdersTopArrow';
	TopButton.WinLeft=0.00;
	BottomButton.OverTexture=Texture'OrdersBtmArrow';
	BottomButton.UpTexture=Texture'OrdersBtmArrow';
	BottomButton.DownTexture=Texture'OrdersBtmArrow';
	BottomButton.WinLeft=0.00;
	MinOptions=Min(8,NumOptions);
	WinTop=(196/768*YMod)+(32/768*YMod)*(CurrentType-1);
	WinLeft=512/1024*XMod;
	WinWidth=256/1024*XMod;
	WinHeight=(32/768*YMod)*(MinOptions + 2);
	SetButtonTextures(0,True,False);
}

defaultproperties
{
}
