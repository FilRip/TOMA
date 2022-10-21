//=============================================================================
// s_SWATWindow
//=============================================================================
//
// Tactical Ops -- an Unreal Tournament modification
// -- http://www.planetunreal.com/tacticalops
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen and Benoit "JAH" Delayen
//=============================================================================

class s_SWATWindow extends SpeechWindow;
 
var	int	Option1, Option2;	// Various options to send to childs.

var s_NPCHostage	TargetHostage;
//var	SpeechWindow	SpeechChildH, SpeechChildT, SpeechChildS, SpeechChildW;

///////////////////////////////////////
// Created
///////////////////////////////////////

function Created()
{
	local int W, H;
	local float XWidth, YHeight, XMod, YMod, XPos, YPos, YOffset, BottomTop;
	local color TextColor;
	local int i;

	bAlwaysOnTop = True;
	bLeaveOnScreen = True;

//	Super.Created();

	W = Root.WinWidth / 4;
	H = W;

	if(W > 256 || H > 256)
	{
		W = 256;
		H = 256;
	}

	XMod = 4*W;
	YMod = 3*H;

	WinTop = 0;
	WinLeft = 0;
	WinWidth = Root.WinWidth;
	WinHeight = Root.WinHeight;

	TopButton = SpeechButton(CreateWindow(class'SpeechButton', 100, 100, 100, 100));
	TopButton.NotifyWindow = Self;
	TopButton.Text = WindowTitle;
	TopButton.MyFont = class'UTLadderStub'.Static.GetStubClass().Static.GetBigFont(Root);
	TopButton.TextColor.R = 255;
	TopButton.TextColor.G = 255;
	TopButton.TextColor.B = 255;
	TopButton.XOffset = 20.0/1024.0 * XMod;
	TopButton.FadeFactor = 1.0;
	TopButton.bDisabled = True;
	TopButton.DisabledTexture = TopTexture;
	TopButton.bStretched = True;
	for (i=0; i<NumOptions; i++)
	{
		OptionButtons[i] = SpeechButton(CreateWindow(ButtonClass, 100, 100, 100, 100));
		OptionButtons[i].NotifyWindow = Self;
		OptionButtons[i].Text = Options[i];
		OptionButtons[i].MyFont = class'UTLadderStub'.Static.GetStubClass().Static.GetBigFont(Root);
		OptionButtons[i].bLeftJustify = True;
		OptionButtons[i].TextColor.R = 255;
		OptionButtons[i].TextColor.G = 255;
		OptionButtons[i].TextColor.B = 255;
		OptionButtons[i].XOffset = 20.0/1024.0 * XMod;
		OptionButtons[i].FadeFactor = 1.0;
		OptionButtons[i].bHighlightButton = True;
		OptionButtons[i].OverTexture = texture'AW_OrdersMid';
		OptionButtons[i].UpTexture = texture'AW_OrdersMid';
		OptionButtons[i].DownTexture = texture'AW_OrdersMid';
		/*OptionButtons[i].OverTexture = texture's_Button';
		OptionButtons[i].UpTexture = texture's_Button';
		OptionButtons[i].DownTexture = texture's_Button';*/
		OptionButtons[i].Type = i;
		OptionButtons[i].bStretched = True;
	}
	BottomButton = SpeechButton(CreateWindow(class'SpeechButton', 100, 100, 100, 100));
	BottomButton.NotifyWindow = Self;
	BottomButton.MyFont = class'UTLadderStub'.Static.GetStubClass().Static.GetBigFont(Root);
	BottomButton.TextColor.R = 255;
	BottomButton.TextColor.G = 255;
	BottomButton.TextColor.B = 255;
	BottomButton.XOffset = 20.0/1024.0 * XMod;
	BottomButton.FadeFactor = 1.0;
	BottomButton.bDisabled = True;
	BottomButton.DisabledTexture = BottomTexture;
	BottomButton.bStretched = True;
}


///////////////////////////////////////
// SetButtonTextures
///////////////////////////////////////

/*function SetButtonTextures(int i, optional bool bLeft, optional bool bRight, optional bool bPreserve)
{
	local int j;

	for (j=0; j<NumOptions; j++)
	{
		if (j == i)
		{
			if (bLeft && bRight)
			{
				OptionButtons[j].OverTexture = texture's_ButtonS';
				OptionButtons[j].UpTexture = texture's_ButtonS';
				OptionButtons[j].DownTexture = texture's_ButtonS';
			} else if (bRight) {
				OptionButtons[j].OverTexture = texture's_ButtonS';
				OptionButtons[j].UpTexture = texture's_ButtonS';
				OptionButtons[j].DownTexture = texture's_ButtonS';
			} else if (bLeft) {
				OptionButtons[j].OverTexture = texture's_ButtonS';
				OptionButtons[j].UpTexture = texture's_ButtonS';
				OptionButtons[j].DownTexture = texture's_ButtonS';
			}
		} else {
			if (bPreserve && j == 0)
			{
				// Do nothing.
			} else {
				OptionButtons[j].OverTexture = texture's_Button';
				OptionButtons[j].UpTexture = texture's_Button';
				OptionButtons[j].DownTexture = texture's_Button';
			}
		}
	}
}*/


///////////////////////////////////////
// Notify
///////////////////////////////////////

function Notify(UWindowWindow B, byte E)
{
	local int W, H;
	local float XWidth, YHeight, XMod, YMod, XPos, YPos, YOffset, BottomTop;
	local color TextColor;
	local int i;
	local PlayerReplicationInfo	PRI;

	W = Root.WinWidth / 4;
	H = W;

	if(W > 256 || H > 256)
	{
		W = 256;
		H = 256;
	}

	XMod = 4*W;
	YMod = 3*H;

	PRI = GetPlayerOwner().PlayerReplicationInfo;

	switch (E)
	{
		case DE_Click:
			switch (B)
			{
				case OptionButtons[0]:
					if ( (!s_Player(GetPlayerOwner()).bNotPlaying) && (s_Player(GetPlayerOwner()).IsInBuyZone()) )
					{
						GetPlayerOwner().PlaySound(sound'SpeechWindowClick', SLOT_Interact);
						SetButtonTextures(SpeechButton(B).Type, False, True);
						HideChildren();
						CurrentType = SpeechButton(B).Type;
						SpeechChild = SpeechWindow(CreateWindow(class's_SWAT.s_ChildWeaponClass', 100, 100, 100, 100));
						SpeechChild.FadeIn();
					}
					break;

				case OptionButtons[1]:
					if ( (!s_Player(GetPlayerOwner()).bNotPlaying) && (s_Player(GetPlayerOwner()).IsInBuyZone()) )
					{
						GetPlayerOwner().PlaySound(sound'SpeechWindowClick', SLOT_Interact);
						SetButtonTextures(SpeechButton(B).Type, False, True);
						HideChildren();
						CurrentType = SpeechButton(B).Type;
						SpeechChild = SpeechWindow(CreateWindow(class's_SWAT.s_ChildAmmoWindow', 100, 100, 100, 100));
						SpeechChild.FadeIn();
					}
					break;

				case OptionButtons[2]:
					if ( (!s_Player(GetPlayerOwner()).bNotPlaying) && (s_Player(GetPlayerOwner()).IsInBuyZone()) )
					{
						GetPlayerOwner().PlaySound(sound'SpeechWindowClick', SLOT_Interact);
						SetButtonTextures(SpeechButton(B).Type, False, True);
						HideChildren();
						CurrentType = SpeechButton(B).Type;
						SpeechChild = SpeechWindow(CreateWindow(class's_SWAT.s_ChildItemWindow', 100, 100, 100, 100));
						SpeechChild.FadeIn();
					}
					break;

				case OptionButtons[3]:
					if (!s_Player(GetPlayerOwner()).bNotPlaying)
					{
						GetPlayerOwner().PlaySound(sound'SpeechWindowClick', SLOT_Interact);
						SetButtonTextures(SpeechButton(B).Type, False, True);
						HideChildren();
						CurrentType = SpeechButton(B).Type;
						SpeechChild = SpeechWindow(CreateWindow(class's_SWAT.s_ChildHostageWindow', 100, 100, 100, 100));
						SpeechChild.FadeIn();
					}
					break;

				case OptionButtons[4]:
					if (!s_Player(GetPlayerOwner()).bNotPlaying)
					{
						GetPlayerOwner().PlaySound(sound'SpeechWindowClick', SLOT_Interact);
						SetButtonTextures(SpeechButton(B).Type, False, True);
						HideChildren();
						CurrentType = SpeechButton(B).Type;
						SpeechChild = SpeechWindow(CreateWindow(class'TO_PhysicalChildWindow', 100, 100, 100, 100));
						SpeechChild.FadeIn();
					}
					break;

				case OptionButtons[5]:
					GetPlayerOwner().PlaySound(sound'SpeechWindowClick', SLOT_Interact);
					SetButtonTextures(SpeechButton(B).Type, False, True);
					HideChildren();
					CurrentType = SpeechButton(B).Type;
					SpeechChild = SpeechWindow(CreateWindow(class's_SWAT.s_ChildChangeTeamWindow', 100, 100, 100, 100));
					SpeechChild.FadeIn();
					break;

				case OptionButtons[6]:
					if (!s_Player(GetPlayerOwner()).bNotPlaying)
					{
						GetPlayerOwner().PlaySound(sound'SpeechWindowClick', SLOT_Interact);
						SetButtonTextures(SpeechButton(B).Type, False, True);
						HideChildren();
						CurrentType = SpeechButton(B).Type;
						SpeechChild = SpeechWindow(CreateWindow(class'TO_OrdersChildWindow', 100, 100, 100, 100));
						SpeechChild.FadeIn();
						TO_OrdersChildWindow(SpeechChild).TargetPRI = IdentifyTarget;
					}
					break;	

				case OptionButtons[7]:
					if (!s_Player(GetPlayerOwner()).bNotPlaying)
					{
						GetPlayerOwner().PlaySound(sound'SpeechWindowClick', SLOT_Interact);
						SetButtonTextures(SpeechButton(B).Type, False, True);
						HideChildren();
						CurrentType = SpeechButton(B).Type;
						SpeechChild = SpeechWindow(CreateWindow(class's_ChildOrdersWindow', 100, 100, 100, 100));
						SpeechChild.FadeIn();
						OrdersChildWindow(SpeechChild).TargetPRI = IdentifyTarget;
					}
					break;
			}
			break;
	}
}
 

///////////////////////////////////////
// SlideInWindow
///////////////////////////////////////

function SlideInWindow()
{
	local int W, H;
	local float XWidth, YHeight, XMod, YMod, XPos, YPos, YOffset, BottomTop;
	local color TextColor;
	local int i;

	W = Root.WinWidth / 4;
	H = W;

	if(W > 256 || H > 256)
	{
		W = 256;
		H = 256;
	}

	XMod = 4*W;
	YMod = 3*H;

	s_Player(GetPlayerOwner()).bActionWindow = true;
	XOffset = -256.0/1024.0 * XMod;
	bSlideIn = true;
	bSlideOut = false;
	if (SpeechChild != None)
		SpeechChild.FadeOut();

	ShowWindow();

/*	if (SpeechChildH != None)
		SpeechChildH.FadeOut();
	if (SpeechChildT != None)
		SpeechChildT.FadeOut();
	if (SpeechChildS != None)
		SpeechChildS.FadeOut();
	if (SpeechChildW != None)
		SpeechChildW.FadeOut();
	*/

	IdentifyTarget = None;
//	NumOptions = Default.NumOptions - 1;
//	OptionButtons[NumOptions].HideWindow();
	if (GetPlayerOwner().MyHUD.IsA('ChallengeHUD'))
	{
		if (( ChallengeHUD(GetPlayerOwner().MyHUD).IdentifyTarget != None ) &&
			( ChallengeHUD(GetPlayerOwner().MyHUD).IdentifyTarget.Team == GetPlayerOwner().PlayerReplicationInfo.Team ) &&
			( ChallengeHUD(GetPlayerOwner().MyHUD).IdentifyFadeTime > 2.0 ))
		{
			IdentifyTarget = ChallengeHUD(GetPlayerOwner().MyHUD).IdentifyTarget;
//			NumOptions = Default.NumOptions;
//			OptionButtons[Default.NumOptions - 1].ShowWindow();
		}
	}

}


///////////////////////////////////////
// SlideOutWindow
///////////////////////////////////////

function SlideOutWindow()
{
	s_Player(GetPlayerOwner()).bActionWindow = false;

	Super.SlideOutWindow();
	/*
	SetButtonTextures(-1, False, False);
	XOffset = 0;
	s_Player(GetPlayerOwner()).bActionWindow = false;
	bSlideOut = true;
	bSlideIn = false;
	if (SpeechChild != None)
		SpeechChild.FadeOut();
		*/
/*	if (SpeechChildH != None)
		SpeechChildH.FadeOut();
	if (SpeechChildT != None)
		SpeechChildT.FadeOut();
	if (SpeechChildS != None)
		SpeechChildS.FadeOut();
	if (SpeechChildW != None)
		SpeechChildW.FadeOut();
	*/
}


///////////////////////////////////////
// Tick
///////////////////////////////////////

function Tick(float Delta)
{
	local int W, H;
	local float XWidth, YHeight, XMod, YMod, XPos, YPos, YOffset, BottomTop;
	local color TextColor;
	local int i;

	W = Root.WinWidth / 4;
	H = W;

	if(W > 256 || H > 256)
	{
		W = 256;
		H = 256;
	}

	XMod = 4*W;
	YMod = 3*H;

	if (bSlideIn)
	{
		XOffset = 0;
		bSlideIn = False;
	}

	if (bSlideOut)
	{
		XOffset = -256.0/1024.0 * XMod;
		bSlideOut = False;
		if (NextSiblingWindow == None)
		{
			HideWindow();
			Root.Console.CloseUWindow();
			Root.Console.bQuickKeyEnable = False;
		} 
		else
			HideWindow();
	}

	if (bFadeIn)
	{
		FadeFactor += Delta * 1000;
		if (FadeFactor > 100)
		{
			FadeFactor = 100;
			bFadeIn = False;
		}  
	}

	if (bFadeOut)
	{
		FadeFactor -= Delta * 1000;
		if (FadeFactor <= 0)
		{
			FadeFactor = 0;
			bFadeOut = False;
			HideWindow();
		}
	}
}


function HideWindow()
{
	Super.HideWindow();

	if (SpeechChild != None)
		SpeechChild.HideWindow();
}

function FadeOut()
{
	FadeFactor = 100;
	bFadeOut = True;
	if (SpeechChild != None)
	{
		SpeechChild.FadeOut();
		SpeechChild.HideWindow();
	}
	//SpeechChild = None;
	CurrentKey = -1;
}


function SetButtonTextures(int i, optional bool bLeft, optional bool bRight, optional bool bPreserve)
{
	local int j;

	for (j=0; j<NumOptions; j++)
	{
		if (j == i)
		{
			if (bLeft && bRight)
			{
				OptionButtons[j].OverTexture = texture'AW_OrdersMidLR';
				OptionButtons[j].UpTexture = texture'AW_OrdersMidLR';
				OptionButtons[j].DownTexture = texture'AW_OrdersMidLR';
			} 
			else if (bRight) 
			{
				OptionButtons[j].OverTexture = texture'AW_OrdersMidR';
				OptionButtons[j].UpTexture = texture'AW_OrdersMidR';
				OptionButtons[j].DownTexture = texture'AW_OrdersMidR';
			} 
			else if (bLeft) 
			{
				OptionButtons[j].OverTexture = texture'AW_OrdersMidL';
				OptionButtons[j].UpTexture = texture'AW_OrdersMidL';
				OptionButtons[j].DownTexture = texture'AW_OrdersMidL';
			}
		} 
		else 
		{
			if (bPreserve && j == 0)
			{
				// Do nothing.
			} 
			else 
			{
				OptionButtons[j].OverTexture = texture'AW_OrdersMid';
				OptionButtons[j].UpTexture = texture'AW_OrdersMid';
				OptionButtons[j].DownTexture = texture'AW_OrdersMid';
			}
		}
	}
}

/*  ButtonClass=Class'UTMenu.SpeechButton'
   TopTexture=Texture's_SWAT.Skins.s_OrdersTop'
   BottomTexture=Texture's_SWAT.Skins.s_OrdersBtm'*/

///////////////////////////////////////
// defaultproperties
///////////////////////////////////////
//Options(7)="Order This Bot"

defaultproperties
{
     Options(0)="Buy Weapon"
     Options(1)="Buy Ammo"
     Options(2)="Buy Item"
     Options(3)="Hostage"
     Options(4)="Gesture"
     Options(5)="Change Team"
     Options(6)="Orders"
     Options(7)="<---->"
     NumOptions=6
     TopTexture=Texture'TODatas.Skins.AW_OrdersTop'
     BottomTexture=Texture'TODatas.Skins.AW_OrdersBtm'
     WindowTitle=""
}
