//=============================================================================
// s_ChildChangeTeamWindow
//=============================================================================
//
// Tactical Ops -- an Unreal Tournament modification
// -- http://www.planetunreal.com/tacticalops
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen and Benoit "JAH" Delayen
//=============================================================================

class s_ChildChangeTeamWindow expands s_SWATWindow;

 
var		int			OptionOffset;
var		int			MinOptions;

var		string	TeamName[2];



///////////////////////////////////////
// Created
///////////////////////////////////////

function Created()
{
	local int i;
	local int W, H;
	local float XMod, YMod;

	W = Root.WinWidth / 4;
	H = W;

	if(W > 256 || H > 256)
	{
		W = 256;
		H = 256;
	}

	XMod = 4*W;
	YMod = 3*H;

	CurrentType = SpeechWindow(ParentWindow).CurrentType;

	NumOptions = 2;

	Super.Created();

	for (i=0; i<NumOptions; i++)
	{
		OptionButtons[i].Text = TeamName[i];
	}

	TopButton.OverTexture = texture'OrdersTopArrow';
	TopButton.UpTexture = texture'OrdersTopArrow';
	TopButton.DownTexture = texture'OrdersTopArrow';
	TopButton.WinLeft = 0;
	BottomButton.OverTexture = texture'OrdersBtmArrow';
	BottomButton.UpTexture = texture'OrdersBtmArrow';
	BottomButton.DownTexture = texture'OrdersBtmArrow';
	BottomButton.WinLeft = 0;

	MinOptions = Min(8,NumOptions);

	WinTop = (196.0/768.0 * YMod) + (32.0/768.0 * YMod)*(CurrentType-1);
	WinLeft = 256.0/1024.0 * XMod;
	WinWidth = 256.0/1024.0 * XMod;
	WinHeight = (32.0/768.0 * YMod)*(MinOptions+2);

	SetButtonTextures(0, True, False);
}


///////////////////////////////////////
// BeforePaint
///////////////////////////////////////

function BeforePaint(Canvas C, float X, float Y)
{
	local int W, H;
	local float XWidth, YHeight, XMod, YMod, XPos, YPos, YOffset, BottomTop, XL, YL;
	local color TextColor;
	local int i;

	Super(NotifyWindow).BeforePaint(C, X, Y);

	W = Root.WinWidth / 4;
	H = W;

	if(W > 256 || H > 256)
	{
		W = 256;
		H = 256;
	}

	XMod = 4*W;
	YMod = 3*H;

	XWidth = 256.0/1024.0 * XMod;
	YHeight = 32.0/768.0 * YMod;

	TopButton.SetSize(XWidth, YHeight);
	TopButton.WinTop = 0;
	TopButton.MyFont = class'UTLadderStub'.Static.GetBigFont(Root);
	if (OptionOffset > 0)
		TopButton.bDisabled = False;
	else
		TopButton.bDisabled = True;

	for(i=0; i<OptionOffset; i++)
	{
		OptionButtons[i].HideWindow();
	}
	for(i=OptionOffset; i<MinOptions+OptionOffset; i++)
	{
		OptionButtons[i].ShowWindow();
		OptionButtons[i].SetSize(XWidth, YHeight);
		OptionButtons[i].WinLeft = 0;
		OptionButtons[i].WinTop = (32.0/768.0*YMod)*(i+1-OptionOffset);
	}
	for(i=MinOptions+OptionOffset; i<NumOptions; i++)
	{
		OptionButtons[i].HideWindow();
	}

	BottomButton.SetSize(XWidth, YHeight);
	BottomButton.WinTop = (32.0/768.0*YMod)*(MinOptions+1);
	BottomButton.MyFont = class'UTLadderStub'.Static.GetBigFont(Root);
	if (NumOptions > MinOptions+OptionOffset)
		BottomButton.bDisabled = False;
	else
		BottomButton.bDisabled = True;
}


///////////////////////////////////////
// Paint
///////////////////////////////////////

function Paint(Canvas C, float X, float Y)
{
	local int i;

	Super.Paint(C, X, Y);

	// Text
	for(i=0; i<NumOptions; i++)
	{
		OptionButtons[i].FadeFactor = FadeFactor/100;
	}
}

/*
///////////////////////////////////////
// FadeOut
///////////////////////////////////////

function FadeOut()
{
	Super.FadeOut();

	if (SpeechChildT != None)
		SpeechChildT.FadeOut();
	if (SpeechChildS != None)
		SpeechChildS.FadeOut();

	SpeechChildT = None;
	SpeechChildS = None;
			
}
*/
/*
///////////////////////////////////////
// HideWindow
///////////////////////////////////////

function HideWindow()
{
	Super.HideWindow();

	if (SpeechChildT != None)
		SpeechChildT.HideWindow();
	if (SpeechChildS != None)
		SpeechChildS.HideWindow();
}
*/

///////////////////////////////////////
// Notify
///////////////////////////////////////

function Notify(UWindowWindow B, byte E)
{
	local int i;
	local ammo ammotype;

	switch (E)
	{
		case DE_DoubleClick:
		case DE_Click:
			GetPlayerOwner().PlaySound(sound'SpeechWindowClick', SLOT_Interact);
			switch (B)
			{
				case OptionButtons[0]:
					//log("Changing Team *******************");
					//s_Player(GetPlayerOwner()).s_ChangeTeam(i);
					
					SetButtonTextures(SpeechButton(B).Type, False, True);
					HideChildren();
					//if (SpeechChildS != None)
					//	SpeechChildS.HideWindow();
					CurrentType = SpeechButton(B).Type;
					SpeechChild = SpeechWindow(ParentWindow.CreateWindow(class's_SWAT.s_ChildTerroristTeam', 100, 100, 100, 100));
					SpeechChild.FadeIn();
					break;
				case OptionButtons[1]:
					//log("Changing Team *******************");
					//s_Player(GetPlayerOwner()).s_ChangeTeam(i);
					SetButtonTextures(SpeechButton(B).Type, False, True);
					HideChildren();
					//if (SpeechChildT != None)
					//	SpeechChildT.HideWindow();
					CurrentType = SpeechButton(B).Type;
					SpeechChild = SpeechWindow(ParentWindow.CreateWindow(class's_SWAT.s_ChildSWATTeam', 100, 100, 100, 100));
					SpeechChild.FadeIn();
					break;
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


 		
///////////////////////////////////////
// defaultproperties
///////////////////////////////////////

defaultproperties
{
     TeamName(0)="Terrorists"
     TeamName(1)="Special Forces"
     TopTexture=Texture'TODatas.Skins.AW_OrdersTop2'
}