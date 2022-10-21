//=============================================================================
// s_ChildAmmoWindow
//=============================================================================
//
// Tactical Ops -- an Unreal Tournament modification
// -- http://www.planetunreal.com/tacticalops
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen and Benoit "JAH" Delayen
//=============================================================================

class s_ChildAmmoWindow expands s_SWATWindow;


var							int						OptionOffset;
var							int						MinOptions;

var							string				s_weaponsname[45];
var							string				s_weaponclassname[45];
//var localized		string				s_Ammo[30];
var							int						PrimaryWeapon[11];
var							s_Weapon			Weap[11];
var							int						NumPrimary;


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

	GetPrimaryWeapons();

	NumOptions = NumPrimary+1;

	Super.Created();

	for (i=0; i<NumPrimary; i++)
	{
		OptionButtons[i].Text = s_WeaponClassName[PrimaryWeapon[i]];
	}

	// Knives hack
	OptionButtons[NumPrimary].Text="$100 Knives x6";

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
	local s_SWATGame SG;
	local ammo ammotype;

	switch (E)
	{
		case DE_DoubleClick:
		case DE_Click:
			GetPlayerOwner().PlaySound(sound'SpeechWindowClick', SLOT_Interact);
			for (i=0; i<NumPrimary; i++)
				if ( (B == OptionButtons[i]) && (Weap[i]!=None) )
					s_Player(GetPlayerOwner()).BuyAmmo(Weap[i]);

			if (B == OptionButtons[NumPrimary])
				s_Player(GetPlayerOwner()).BuyKnives();

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
// GetPrimaryWeapons
///////////////////////////////////////

function GetPrimaryWeapons()
{
	local int				i, k;
	local s_Weapon	W;
	local inventory Inv;
	local bool			bIsUsed;
	local int				temp;
/*
	for (i=0; i < 11; i++)
	{
		PrimaryWeapon[NumPrimary] = 0;
		Weap[NumPrimary] = None;
	}
	//log("GetPrimaryWeapons - enterring");
*/
	for ( Inv=GetPlayerOwner().Inventory; Inv!=None; Inv=Inv.Inventory )
	{
		if (Inv.IsA('s_Weapon') && s_Weapon(Inv).bUseClip)
		{
			W = s_Weapon(Inv);
			//bIsUsed = false;
			temp = W.WeaponID;
/*
			if (temp >=40)
				log("GetPrimaryWeapons - Weapon: "$W$" - WeaponID: "$temp);

			if (NumPrimary >= 11)
				log("GetPrimaryWeapons - NumPrimary: "$NumPrimary);
*/
			//log("GetPrimaryWeapons - Weapon: "$W$" - WeaponID: "$temp$" - s_weaponclassName[temp]"$s_weaponclassName[temp]);
			if ( /*(!bIsUsed) && */(s_weaponclassName[temp] != "") )
			{
				PrimaryWeapon[NumPrimary] = W.WeaponID;
				Weap[NumPrimary] = W;
				NumPrimary++;
			}
		}
		i++;
		if ( i > 100 )
			break; // can occasionally get temporary loops in netplay
	}
}

/* 
///////////////////////////////////////
// BuyAmmo
///////////////////////////////////////

function BuyAmmo( int ammoclassint )
{
	s_Player(GetPlayerOwner()).BuyAmmo(Weap[ammoclassint]);
}
*/ 
	
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

	for (i=0; i < 11; i++)
		Weap[i] = None;
}


///////////////////////////////////////
// defaultproperties
///////////////////////////////////////
// s_weaponclassname(31)="($50) Colt M4 x30"

defaultproperties
{
     s_weaponclassname(11)="C1 $25 .50 Mag x7"
     s_weaponclassname(12)="C1 $15 .45ACP x13"
     s_weaponclassname(13)="C1 $15 9mm x15"
     s_weaponclassname(20)="C2 $50 9mm x30"
     s_weaponclassname(21)="C2 $30 .45mm x32"
     s_weaponclassname(22)="C2 $40 Shells x8"
     s_weaponclassname(23)="C2 $40 Shells x8"
     s_weaponclassname(24)="C2 $40 Shells x7"
     s_weaponclassname(25)="C2 $40 9mm x30"
     s_weaponclassname(30)="C3 $50 7.62mm x20"
     s_weaponclassname(32)="C3 $50 5.56mm x25"
     s_weaponclassname(33)="C3 $40 7.62mm x30"
     s_weaponclassname(34)="C3 $40 7.62mm x20"
     s_weaponclassname(35)="C3 $20 7.62mm x5"
     s_weaponclassname(36)="C3 $15 7.62mm x10"
     s_weaponclassname(37)="C3 $50 5.56mm x30"
     s_weaponclassname(39)="C3 $40 5.56mm x25"
     s_weaponclassname(40)="C3 $40 5.56mm x25"
     TopTexture=Texture'TODatas.Skins.AW_OrdersTop2'
}
