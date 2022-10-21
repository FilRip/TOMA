//=============================================================================
// s_ChildWeaponWindow
//=============================================================================
//
// Tactical Ops -- an Unreal Tournament modification
// -- http://www.planetunreal.com/tacticalops
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen and Benoit "JAH" Delayen
//=============================================================================

class s_ChildHostageSubWindow expands s_SWATWindow;
 
 
var							int			OptionOffset;
var							int			MinOptions;
var							string	TheName;

var							s_NPCHostage	CurrentHostage;

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

	if (ParentWindow.IsA('s_SWATWindow'))
		CurrentHostage=s_SWATWindow(ParentWindow).TargetHostage;
	else
		log("parent fucked up");

	if ( CurrentHostage!=None && CurrentHostage.Weapon!=None )
		NumOptions = 2;
	else  
		NumOptions = 1;

	log("NumOptions    = "$Numoptions);

	
	Super.Created();

	if (NumOptions>0)
	{
		if (GetPlayerOwner().PlayerReplicationInfo.Team==0)
			OptionButtons[0].text="Capture Hostage";
		else
			OptionButtons[0].text="Rescue Hostage";
		OptionButtons[1].text="Drop Weapon";
	}
	/*for (i=0; i<NumOptions; i++)
	{
		OptionButtons[i].Text = TheName[i];
	}*/

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
	WinLeft = 512.0/1024.0 * XMod;
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


///////////////////////////////////////
// Notify
///////////////////////////////////////

function Notify(UWindowWindow B, byte E)
{
	local int i;
	local s_player PL;
	local int price;

	switch (E)
	{
		case DE_DoubleClick:
		case DE_Click:
			GetPlayerOwner().PlaySound(sound'SpeechWindowClick', SLOT_Interact);
			for (i=0; i<NumOptions; i++)
			{
				if (B == OptionButtons[i])
				{
					if (i==0 && GetPlayerOwner().Health>0 && CurrentHostage!=None && CurrentHostage.health > 0)
					{
						s_Player(GetPlayerOwner()).RescueHostage(CurrentHostage);
						/*CurrentHostage.Followed=GetPlayerOwner();
						CurrentHostage.SetOrders('Follow', GetPlayerOwner());*/
					}
					else if (i==1 && GetPlayerOwner().Health>0 && CurrentHostage!=None && CurrentHostage.health > 0)
						if ( CurrentHostage.CanTossWeaponTo(GetPlayerOwner()) )
							CurrentHostage.TossWeapon();
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

/*
///////////////////////////////////////
// FadeOut
///////////////////////////////////////

function FadeOut()
{
	Super.FadeOut();

	if (SpeechChildH != None)
		SpeechChildH.FadeOut();
	
	SpeechChildH = None;
}
*/

///////////////////////////////////////
// defaultproperties
///////////////////////////////////////

defaultproperties
{
     TopTexture=Texture'TODatas.Skins.AW_OrdersTop2'
}
