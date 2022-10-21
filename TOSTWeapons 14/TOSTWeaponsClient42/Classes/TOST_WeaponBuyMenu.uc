class TOST_WeaponBuyMenu extends TO_GUITabBuyMenu;

#exec texture IMPORT NAME=TGASgasmask FILE=Textures\BuyMenu\TGASgasmask.bmp MIPS=off FLAGS=2

var() TOSTWeaponsClient Client;

var int MyItemPrice[6];
var localized string MyTextDescItems[6];

simulated function Close (optional bool bByParent)
{
	BoxSpecialitems.Close();
	BoxRifles.Close();
	Super.Close(bByParent);
}

simulated function Created()
{
	Super.Created();

	BoxRifles.Close();
	BoxRifles=TOSTWeaponsListbox(CreateWindow(Class'TOSTWeaponsListbox',0.00,0.00,WinWidth,WinHeight));
	BoxRifles.Label=TextBoxRifles;
	BoxRifles.OwnerTab=self;

	BoxSpecialitems.Close();
	BoxSpecialitems=TOSTItemListBox(CreateWindow(Class'TOSTItemListBox',0.00,0.00,WinWidth,WinHeight));
	BoxSpecialitems.OwnerTab=self;
	BoxSpecialitems.bMultiselect=True;
}
/*
simulated function BeforePaint (Canvas Canvas, float X, float Y)
{
	Super.BeforePaint(Canvas,X,Y);

	if ( bInitialized )
	{
		if ( client.WeaponTeam[28] == 0 )
			TOSTItemListBox(BoxSpecialitems).showNormal();
		else TOSTItemListBox(BoxSpecialitems).showAdvanced();

		if ( BoxSpecialitems.numitems < 5 )
			BoxSpecialitems.AddItem(Texture'TGASgasmask',5,Client.bHasgasmask);
	}

	if ( BoxSpecialitems.IsSelectedByData(5) )
	{
		Capital+=800;
		if ( !Client.bHasgasmask )
		{
			RemainingMoney-=800;
		}
	}
	else if ( !BoxSpecialitems.IsSelectedByData(5) && Client.bHasgasmask )
	{
		RemainingMoney+=800;
	}
}*/

simulated function Notify (UWindowDialogControl control, byte Event)
{
	if ( control == ButtonBuy )
	{
		if ( Event == 2 )
		{
			if ( RemainingMoney >= 0 )
				Client.BuyGasmask(BoxSpecialitems.IsSelectedByData(5));
			TOSTBuymenu_GetPlayerCapital();
			SendEquipmentWish();
		}
		else
		{
			if ( Event == 8 )
			{
				Hint=TextHintBuybutton;
				AltHint="";
			}
			else
			{
				if ( Event == 9 )
				{
					Hint=TextHintDefault;
					AltHint=TextHintDefaultAlt;
				}
			}
		}
	}/*
	if ( control == ButtonBuy && event == 2 && RemainingMoney >= 0 )
	{
		Client.BuyGasmask(BoxSpecialitems.IsSelectedByData(5));
	}*/

	else Super.Notify(control,Event);
}

simulated function Paint (Canvas Canvas, float X, float Y)
{
	if (  !bDraw )
	{
		return;
	}
	if ( OwnerHUD.bDrawBackground )
	{
		super(TO_GUIBaseTab).Paint(Canvas,X,Y);
	}
	My_DrawMoney(Canvas);
	TOBuymenu_DrawItemmesh(Canvas);
	if ( MeshId >= 0 )
	{
		My_DrawIteminfo(Canvas);
	}
	else
	{
		if ( ItemId >= 0 )
		{
			My_DrawIteminfoS(Canvas);
		}
	}
}

final simulated function My_DrawMoney (Canvas Canvas)
{
	local float X;
	local float Y;
	local float lh;
	local int price;

	Canvas.Style=1;
	OwnerInterface.Design.SetScoreboardFont(Canvas);
	lh=OwnerInterface.Design.LineHeight;
	X=Left + Padding[Resolution];
	Y=Top + Padding[Resolution];
	Canvas.DrawColor=OwnerInterface.Design.ColorWhite;
	Canvas.SetPos(X,Y);
	Canvas.DrawText(TextMoneyCash,True);
	Canvas.SetPos(X,Y + 3.50 * lh);
	Canvas.DrawText(TextMoneyPrice,True);
	Canvas.SetPos(X,Y + 7 * lh);
	Canvas.DrawText(TextMoneyRest,True);
	OwnerInterface.Design.SetHeadlineFont(Canvas);
	if ( RemainingMoney < 0 )
	{
		Canvas.DrawColor=OwnerInterface.Design.ColorHitlocation * 2 * OwnerHUD.TutIconBlink;
	}
	else
	{
		Canvas.DrawColor=OwnerInterface.Design.ColorTeam[OwnerPlayer.PlayerReplicationInfo.Team];
	}
	Canvas.SetPos(X + 1.50 * SpaceTitle[Resolution],Y);
	Canvas.DrawText("$" $ string(RemainingMoney),True);
	if ( MeshId >= 0 )
	{
		price=MeshClass.Default.price;
	}
	else
	{
		if ( ItemId >= 0 )
		{
			price=MyItemPrice[ItemId];
		}
		else
		{
			return;
		}
	}
	Canvas.SetPos(X + 1.50 * SpaceTitle[Resolution],Y + 3.50 * lh);
	Canvas.DrawText("$" $ string(price),True);
	if ( RemainingMoney - price < 0 )
	{
		Canvas.DrawColor=OwnerInterface.Design.ColorHitlocation * 2 * OwnerHUD.TutIconBlink;
	}
	else
	{
		Canvas.DrawColor=OwnerInterface.Design.ColorTeam[OwnerPlayer.PlayerReplicationInfo.Team];
	}
	Canvas.SetPos(X + 1.50 * SpaceTitle[Resolution],Y + 7 * lh);
	Canvas.DrawText("$" $ string(RemainingMoney - price),True);
}

final simulated function My_DrawIteminfo (Canvas Canvas)
{
	local float X;
	local float Y;
	local float oldorigx;
	local float OldClipX;
	local int Chars;

	if ( MeshId < 0 )
	{
		return;
	}
	X=MeshboxLeft + Padding[Resolution];
	Y=MeshboxTop + Padding[Resolution];
	OwnerInterface.Design.SetScoreboardFont(Canvas);
	Canvas.DrawColor=OwnerInterface.Design.ColorWhite;
	Canvas.SetPos(X,Y);
	Canvas.DrawText(TextInfoRange @ string(int(MeshClass.Default.MaxRange / 42.65)) @ TextInfoUMeters,True);
	Y += OwnerInterface.Design.LineHeight;
	Canvas.SetPos(X,Y);
	Canvas.DrawText(TextInfoRPM @ string(MeshClass.Default.RoundPerMin),True);
	Y += OwnerInterface.Design.LineHeight;
	Canvas.SetPos(X,Y);
	Canvas.DrawText(TextInfoClipsize $ "/" $ TextInfoNumclips @ string(MeshClass.Default.clipSize) $ "/" $ string(MeshClass.Default.MaxClip),True);
	oldorigx=Canvas.OrgX;
	OldClipX=Canvas.ClipX;
	Canvas.OrgX=X;
	Canvas.ClipX=X + 2 * MeshboxWidth - Padding[Resolution];
	Y += 2 * OwnerInterface.Design.LineHeight;
	X=Len(MeshClass.Default.WeaponDescription);
	Chars=Min(X,MeshFrame);
	Canvas.SetPos(0.00,Y);
	if ( bDrawCursor && (Chars < X) )
	{
		if ( Chars <= 16 )
			Canvas.DrawTextClipped(OwnerInterface.Left(MeshClass.Default.WeaponDescription,Chars) $ "_",False);
		else {
			Canvas.DrawTextClipped(OwnerInterface.Left(MeshClass.Default.WeaponDescription,16),False);
			Canvas.SetPos(0.00,Y + OwnerInterface.Design.LineHeight);
			Canvas.DrawTextClipped(OwnerInterface.mid(MeshClass.Default.WeaponDescription,16,Chars-16) $ "_",False);
		}

	}
	else
	{
		if ( Chars <= 16 )
			Canvas.DrawTextClipped(OwnerInterface.Left(MeshClass.Default.WeaponDescription,Chars),False);
		else {
			Canvas.DrawTextClipped(OwnerInterface.Left(MeshClass.Default.WeaponDescription,16),False);
			Canvas.SetPos(0.00,Y + OwnerInterface.Design.LineHeight);
			Canvas.DrawTextClipped(OwnerInterface.mid(MeshClass.Default.WeaponDescription,16,Chars-16),False);
		}
	}
	Canvas.ClipX=OldClipX;
	Canvas.OrgX=oldorigx;
}

final simulated function My_DrawIteminfoS (Canvas Canvas)
{
	local float oldorigx;
	local float OldClipX;
	local int L;
	local int Chars;

	if ( ItemId < 0 )
	{
		return;
	}
	oldorigx=Canvas.OrgX;
	OldClipX=Canvas.ClipX;
	Canvas.OrgX=MeshboxLeft + Padding[Resolution];
	Canvas.ClipX=MeshboxLeft + MeshboxWidth - Padding[Resolution];
	L=Len(myTextDescItems[ItemId]);
	Chars=Min(L,MeshFrame);
	Canvas.SetPos(0.00,MeshboxTop + Padding[Resolution]);
	if ( bDrawCursor && (Chars < L) )
	{
		Canvas.DrawTextClipped(OwnerInterface.Left(myTextDescItems[ItemId],Chars) $ "_",False);
	}
	else
	{
		Canvas.DrawTextClipped(OwnerInterface.Left(myTextDescItems[ItemId],Chars),False);
	}
	Canvas.ClipX=OldClipX;
	Canvas.OrgX=oldorigx;
}
/*
final simulated function TOSTBuymenu_CalcInventory ()
{
	local int WeaponID;
	local int total;
	local int i;
	local Class<S_Weapon> W;

	total=0;
	W=Class<s_Knife>(DynamicLoadObject("s_Swat.s_Knife",Class'Class'));
	total += AmmoBox[0].Value * W.Default.ClipPrice / W.Default.clipSize;
	total += TOBuymenu_Tool_GetSelectedWeaponPrice(BoxPistols);
	total += TOBuymenu_Tool_GetSelectedWeaponPrice(BoxSub);
	total += TOBuymenu_Tool_GetSelectedWeaponPrice(BoxRifles);
	total += TOBuymenu_Tool_GetSelectedWeaponPrice(BoxGrenades);
	NumAmmoBoxes=1;
	TOBuymenu_Tool_ListAmmo(BoxPistols);
	TOBuymenu_Tool_ListAmmo(BoxSub);
	TOBuymenu_Tool_ListAmmo(BoxRifles);
	i=1;
	while ( i < NumAmmoBoxes )
	{
		WeaponID=AmmoBox[i].Data;
		if ( WeaponID >= 0 )
		{
			W=Class<S_Weapon>(DynamicLoadObject(Class'TO_WeaponsHandler'.Default.WeaponStr[WeaponID],Class'Class'));
			total += AmmoBox[i].Value * W.Default.ClipPrice;
		}
		else
		{
			W=Class<S_Weapon>(DynamicLoadObject(Class'TO_WeaponsHandler'.Default.WeaponStr[ -WeaponID],Class'Class'));
			total += AmmoBox[i].Value * W.Default.BackupClipPrice;
		}
		AmmoBox[i].ShowWindow();
		i++;
	}
	i=NumAmmoBoxes;
	while ( i < MaxAmmoBoxes )
	{
		AmmoBox[i].Value=0;
		AmmoBox[i].HideWindow();
		i++;
	}
	if ( BoxSpecialitems.IsSelectedByData(2) )
	{
		total += ItemPrice[2];
	}
	if ( BoxSpecialitems.IsSelectedByData(3) )
	{
		total += ItemPrice[3];
	}
	if ( BoxSpecialitems.IsSelectedByData(4) )
	{
		total += ItemPrice[4];
	}
	if ( BoxSpecialitems.IsSelectedByData(1) )
	{
		total += ItemPrice[1];
	}
	RemainingMoney=Capital - total;
}
*/

simulated function BeforePaint (Canvas Canvas, float X, float Y)
{
	local int wid;
	local int iid;

	if (  !bInitialized )
	{
		super(TO_GUIBaseTab).BeforePaint(Canvas,X,Y);
		TOBuymenu_Init(Canvas);
	}
	else
	{
		super(TO_GUIBaseTab).BeforePaint(Canvas,X,Y);
		if ( client.WeaponTeam[28] == 0 )
			TOSTItemListBox(BoxSpecialitems).showNormal();
		else TOSTItemListBox(BoxSpecialitems).showAdvanced();

		if ( BoxSpecialitems.numitems < 5 )
			BoxSpecialitems.AddItem(Texture'TGASgasmask',5,Client.bHasgasmask);
	}
	if ( bDraw )
	{
		ButtonRestore.ShowWindow();
		ButtonBuy.ShowWindow();
		ButtonCancel.ShowWindow();
	}
	if (  !TOSTBuymenu_GetPlayerCapital() )
	{
		TOBuymenu_RefreshInventory();
	}
	TOBuymenu_CalcInventory();
	wid=-1;
	iid=-1;
	if ( BoxPistols.MouseoverIndex != 31 )
	{
		wid=BoxPistols.GetData(BoxPistols.MouseoverIndex);
	}
	else
	{
		if ( BoxSub.MouseoverIndex != 31 )
		{
			wid=BoxSub.GetData(BoxSub.MouseoverIndex);
		}
		else
		{
			if ( BoxRifles.MouseoverIndex != 31 )
			{
				wid=BoxRifles.GetData(BoxRifles.MouseoverIndex);
			}
			else
			{
				if ( BoxGrenades.MouseoverIndex != 31 )
				{
					wid=BoxGrenades.GetData(BoxGrenades.MouseoverIndex);
				}
				else
				{
					if ( BoxSpecialitems.MouseoverIndex != 31 )
					{
						iid=BoxSpecialitems.GetData(BoxSpecialitems.MouseoverIndex);
					}
				}
			}
		}
	}
	if ( wid >= 0 )
	{
		if ( wid != MeshId )
		{
			MeshId=wid;
			ItemId=-1;
			MeshClass=Class<S_Weapon>(DynamicLoadObject(Class'TO_WeaponsHandler'.Default.WeaponStr[MeshId],Class'Class'));
			MeshScale=Class'TO_WeaponsHandler'.Default.BuymenuScale[MeshId];
			MeshActor.Mesh=MeshClass.Default.ThirdPersonMesh;
			MeshFrame=0;
		}
	}
	else
	{
		if ( iid >= 0 )
		{
			if ( iid != ItemId )
			{
				ItemId=iid;
				MeshId=-1;
				MeshFrame=0;
			}
		}
		else
		{
			MeshId=-1;
			ItemId=-1;
		}
	}
	if ( BoxSpecialitems.IsSelectedByData(5) )
	{
		Capital+=800;
		if ( !Client.bHasgasmask )
		{
			RemainingMoney-=800;
		}
	}
	else if ( !BoxSpecialitems.IsSelectedByData(5) && Client.bHasgasmask )
	{
		RemainingMoney+=800;
	}
}

simulated function BeforeShow ()
{
	TOSTBuymenu_GetPlayerCapital();
	TOBuymenu_RefreshInventory();
}

final simulated function bool TOSTBuymenu_GetPlayerCapital ()
{
	local Inventory Inv;
	local S_Weapon W;
	local int i;
	local int Id;
	local int extramoney;

	i=0;
	while ( i < 32 )
	{
		LastWeapon[i]=Weapon[i];
		LastClips[i].Primary=clips[i].Primary;
		LastClips[i].secondary=clips[i].secondary;
		Weapon[i]=HAS_NO;
		clips[i].Primary=0;
		clips[i].secondary=0;
		i++;
	}
	i=0;
	while ( i < 5 )
	{
		LastItem[i]=Item[i];
		Item[i]=HAS_NO;
		i++;
	}
	LastKnives=Knives;
	i=0;
	extramoney=0;
	Inv=OwnerPlayer.Inventory;
	while ( Inv != none && i < 100)
	{
		if ( Inv.IsA('S_Weapon') )
		{
			Id=client.GetIdByClass(string(Inv.Class));
			if ( Id > -1 )
			{
				W=S_Weapon(Inv);
				Weapon[Id]=HAS_YES;
				if ( W.bAltMode == false )
				{
					clips[Id].Primary=W.RemainingClip;
					clips[Id].secondary=W.BackupClip;
				}
				else
				{
					clips[Id].secondary=W.RemainingClip;
					clips[Id].Primary=W.BackupClip;
				}
				extramoney += W.Default.price + clips[Id].Primary * W.Default.ClipPrice + clips[Id].secondary * W.Default.BackupClipPrice;
			}
		}
		i++;
		Inv=Inv.Inventory;
	}
	if ( OwnerPlayer.HelmetCharge == 100 )
	{
		Item[2]=HAS_YES;
		extramoney += ItemPrice[2];
	}
	if ( OwnerPlayer.VestCharge == 100 )
	{
		Item[3]=HAS_YES;
		extramoney += ItemPrice[3];
	}
	if ( OwnerPlayer.LegsCharge == 100 )
	{
		Item[4]=HAS_YES;
		extramoney += ItemPrice[4];
	}
	if ( OwnerPlayer.bHasNV )
	{
		Item[1]=HAS_YES;
		extramoney += ItemPrice[1];
	}
	W=S_Weapon(OwnerPlayer.FindInventoryType(Class's_Knife'));
	Knives=W.clipAmmo;
	extramoney += Knives * W.ClipPrice / W.clipSize;
	Capital=OwnerPlayer.money + extramoney;
	i=0;
	while ( i < 32 )
	{
		if ( (Weapon[i] != LastWeapon[i]) || (clips[i].Primary != LastClips[i].Primary) || (clips[i].secondary != LastClips[i].secondary) )
		{
			return False;
		}
		i++;
	}
	i=0;
	while ( i < 5 )
	{
		if ( Item[i] != LastItem[i] )
		{
			return False;
		}
		i++;
	}
	if ( Knives != LastKnives )
	{
		return False;
	}
	return True;
}

defaultproperties
{
    MyItemPrice(0)=-1
    MyItemPrice(1)=400
    MyItemPrice(2)=250
    MyItemPrice(3)=350
    MyItemPrice(4)=300
    MyItemPrice(5)=800
    MyTextDescItems(0)="these are knives"
    MyTextDescItems(1)="this is nightvision"
    MyTextDescItems(2)="this is a helmet"
    MyTextDescItems(3)="this is a vest"
    MyTextDescItems(4)="these are pads"
    MyTextDescItems(5)="this is a gasmask"
}
