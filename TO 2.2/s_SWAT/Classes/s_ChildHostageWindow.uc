//=============================================================================
// s_ChildHostageWindow
//=============================================================================
//
// Tactical Ops -- an Unreal Tournament modification
// -- http://www.planetunreal.com/tacticalops
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen and Benoit "JAH" Delayen
//=============================================================================

class s_ChildHostageWindow expands s_SWATWindow;
 
var							int						OptionOffset;
var							int						MinOptions;
var							string				HostageName[30];
var							s_NPCHostage	Hostage[30];
var							int						NumHostage;
var							bool					bCreate;
var							int						decal;
var							s_Player			sP;

/*
///////////////////////////////////////
// GetNearbyHosties
///////////////////////////////////////

simulated function GetNearbyHosties()
{
	local	Pawn	P;
	local	s_NPCHostage	H;
	local	int	i;

	NumHostage = 0;

	for (P=sP.Level.PawnList; P!=None; P=P.NextPawn)
	{
		i++;
		if (i > 100)
			break;
		H = s_NPCHostage(P);
		if ( (H != None) && (H.Health > 0) && (VSize(H.location - sP.location) < 256.0) )
		{
			NumHostage++;
			if ( H.PlayerReplicationInfo != None )
				HostageName[NumHostage] = H.PlayerReplicationInfo.PlayerName;
			Hostage[NumHostage] = H;
		}

	}

	Hostage[NumHostage+1] = None;
}
*/

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

	if (W > 256 || H > 256)
	{
		W = 256;
		H = 256;
	}

	XMod = 4*W;
	YMod = 3*H;

	CurrentType = SpeechWindow(ParentWindow).CurrentType;

	sP = s_Player(GetPlayerOwner());
	sP.GetNearByHostage(HostageName, Hostage, NumHostage);
	//GetNearbyHosties();

	bCreate=true;

	
	if (NumHostage==0)
	{
		bCreate=false;
		NumOptions=1;
		HostageName[0]="No Hostage Found";
	}
	else if (NumHostage==1)
	{
		decal=1;
		NumOptions=1;
	}
	else
	{
		NumOptions=NumHostage+1;
		HostageName[0]="Rescue All";
		decal=0;
	}

	Super.Created();

	for (i=0; i<NumOptions; i++)
	{
		OptionButtons[i].Text = HostageName[i+decal];
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


///////////////////////////////////////
// Notify
///////////////////////////////////////

function Notify(UWindowWindow B, byte E)
{
	local int i;
	local int k;
	local s_SWATGame SG;
	local ammo ammotype;

	switch (E)
	{
		case DE_DoubleClick:
		case DE_Click:
			GetPlayerOwner().PlaySound(sound'SpeechWindowClick', SLOT_Interact);
			for (i=0; i<NumOptions; i++)
			{
				if (B == OptionButtons[i] && (sP.Health>0) && bCreate )
				{
					if ( (i==0) && (decal==0) )
						for (k=0; k<NumHostage; k++)
						{
							if ( Hostage[k+1] != None && Hostage[k+1].Health>0 )
								s_Player(GetPlayerOwner()).RescueHostage(Hostage[k+1]);
							/*Hostage[k+1].Followed = GetPlayerOwner();
							Hostage[k+1].SetOrders('Follow',GetPlayerOwner());*/
						}
					else
					{
						if ( Hostage[i+1] != None && Hostage[i+1].Health>0 )
						{
							if (Hostage[i+1].Weapon!=None)
							{
								s_SWATWindow(ParentWindow).TargetHostage=Hostage[i+1];
								SetButtonTextures(SpeechButton(B).Type, False, True);
								HideChildren();

								//log("creating sub window");
								CurrentType = SpeechButton(B).Type;
								SpeechChild = SpeechWindow(ParentWindow.CreateWindow(class's_SWAT.s_ChildHostageSubWindow', 100, 100, 100, 100));
								SpeechChild.FadeIn();
							}
							else
							{
								s_Player(GetPlayerOwner()).RescueHostage(Hostage[i+1]);
							/*	Hostage[i+1].Followed = GetPlayerOwner();
								Hostage[i+1].SetOrders('Follow',GetPlayerOwner());*/
							}
						}
					}
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


function HideWindow()
{
	Super.HideWindow();
	cleararray();
}

function FadeOut()
{
	Super.FadeOut();
	cleararray();
}


function	cleararray()
{
	local	int		i;

	for (i=0; i < 30; i++)
		Hostage[i] = None;
}

///////////////////////////////////////
// defaultproperties
///////////////////////////////////////

defaultproperties
{
     TopTexture=Texture'TODatas.Skins.AW_OrdersTop2'
}
