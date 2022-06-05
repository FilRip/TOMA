class TOMABuyMenu extends TO_GUITabBuyMenu;

var bool bAlreadyInit;
var TO_GUIBaseUpdown AmmoBox[6];

simulated function Created ()
{
	local int			i, j, min;
	local byte			b;


	super(TO_GUIBaseTab).Created();

	Title = TextBuymenuTitle;

	// weapons
	BoxSpecialitems = TO_GUIImageListbox(CreateWindow(class'TO_GUIImageListbox', 0, 0, WinWidth, WinHeight));
	BoxSpecialitems.OwnerTab = self;
	BoxSpecialitems.bMultiselect = true;

	BoxPistols = TO_GUITextListbox(CreateWindow(class'TO_GUITextListbox', 0, 0, WinWidth, WinHeight));
	BoxPistols.Label = TextBoxPistols;
	BoxPistols.OwnerTab = self;

	BoxSub = TO_GUITextListbox(CreateWindow(class'TO_GUITextListbox', 0, 0, WinWidth, WinHeight));
	BoxSub.Label = TextBoxSub;
	BoxSub.OwnerTab = self;

	BoxRifles = TO_GUITextListbox(CreateWindow(class'TO_GUITextListbox', 0, 0, WinWidth, WinHeight));
	BoxRifles.Label = TextBoxRifles;
	BoxRifles.OwnerTab = self;

	BoxGrenades = TO_GUITextListbox(CreateWindow(class'TO_GUITextListbox', 0, 0, WinWidth, WinHeight));
	BoxGrenades.Label = TextBoxGrenades;
	BoxGrenades.OwnerTab = self;

	// mesh
	MeshActor = GetEntryLevel().Spawn(class'TO_MeshActor', GetEntryLevel());
	MeshRotator = rot(0, 0, 0);

	// ammo
	for (i=0; i < MaxAmmoBoxes; i++)
	{
		AmmoBox[i] = TO_GUIBaseUpdown(CreateWindow(class'TO_GUIBaseUpdown', 0, 0, WinWidth, WinHeight));
		AmmoBox[i].Label = "bleh";
		AmmoBox[i].OwnerTab = self;
		AmmoBox[i].HideWindow();
	}
	AmmoBox[0].Data = -1;
	AmmoBox[0].Label = TextBoxKnifes;
	AmmoBox[0].MinValue = 1;
	AmmoBox[0].MaxValue = class<s_Knife>(DynamicLoadObject("s_Swat.s_Knife", class'Class' )).default.clipSize;
	AmmoBox[0].ShowWindow();
	NumAmmoBoxes=1;
	for (i=0; i < 32; i++)
	{
		Weapon[i] = HAS_NO;
		LastWeapon[i] = HAS_NO;
		SelectedClips[i].Primary = SCL_NONE;
		SelectedClips[i].Secondary = SCL_NONE;
	}

	// butttons
	ButtonBuy = TO_GUIBaseButton(CreateWindow(class'TO_GUIBaseButton', 0, 0, WinWidth, WinHeight));
	ButtonBuy.Text = TextButtonBuy;
	ButtonBuy.OwnerTab = self;

	ButtonRestore = TO_GUIBaseButton(CreateWindow(class'TO_GUIBaseButton', 0, 0, WinWidth, WinHeight));
	ButtonRestore.Text = TextButtonRestore;
	ButtonRestore.OwnerTab = self;

	ButtonCancel = TO_GUIBaseButton(CreateWindow(class'TO_GUIBaseButton', 0, 0, WinWidth, WinHeight));
	ButtonCancel.Text = TextButtonCancel;
	ButtonCancel.OwnerTab = self;

	// fill sorted weapon list
	NumSortedWeapons = 0;
	for (i = 0; i < 32; i++)
	{
		if (class'TOModels.TO_WeaponsHandler'.default.WeaponStr[i] != "")
		{
			SortedWeapons[NumSortedWeapons] = i;
			NumSortedWeapons++;
		}
	}

	// pre-sort weapon list by price
	for (i=0; i < NumSortedWeapons; i++)
	{
		min = i;
		for (j = i+1; j < NumSortedWeapons; j++)
		{
			if (class<s_Weapon>(DynamicLoadObject(class'TO_WeaponsHandler'.default.WeaponStr[SortedWeapons[j]], class'Class')).default.Price <
				class<s_Weapon>(DynamicLoadObject(class'TO_WeaponsHandler'.default.WeaponStr[SortedWeapons[min]], class'Class')).default.Price)
			{
				min = j;
			}
		}

		b = SortedWeapons[i];
		SortedWeapons[i] = SortedWeapons[min];
		SortedWeapons[min] = b;
	}
}

simulated function InitNewWeapons()
{
	local int i,j,Min;
	local byte B;

	if (TOMAGameReplicationInfo(OwnerPlayer.GameReplicationInfo).NewWeapons)
	{
		NumSortedWeapons=0;
		for (i=0;i<32;i++)
			if (Class'TOMAWeaponsHandler'.Default.WeaponStr[i]!="")
			{
				SortedWeapons[NumSortedWeapons]=i;
				NumSortedWeapons++;
			}
		for (i=0;i<NumSortedWeapons;i++)
		{
			Min=i;
			j=i+1;
			while (j<NumSortedWeapons)
			{
				if (Class<S_Weapon>(DynamicLoadObject(Class'TOMAWeaponsHandler'.Default.WeaponStr[SortedWeapons[j]],Class'Class')).Default.price<Class<S_Weapon>(DynamicLoadObject(Class'TOMAWeaponsHandler'.Default.WeaponStr[SortedWeapons[Min]],Class'Class')).Default.price)
					Min=j;
				j++;
			}
			B=SortedWeapons[i];
			SortedWeapons[i]=SortedWeapons[Min];
			SortedWeapons[Min]=B;
		}
	}
	bAlreadyInit=true;
}

simulated function BeforePaint (Canvas Canvas, float X, float Y)
{
	local int wid;
	local int iid;

	if (!bInitialized)
	{
		Super(TO_GUIBaseTab).BeforePaint(Canvas,X,Y);
		TOMABuymenu_Init(Canvas);
	}
	else
		Super(TO_GUIBaseTab).BeforePaint(Canvas,X,Y);
	if (bDraw)
	{
		ButtonRestore.ShowWindow();
		ButtonBuy.ShowWindow();
		ButtonCancel.ShowWindow();
	}
	if (!TOMABuymenu_GetPlayerCapital())
		TOMATOBuymenu_RefreshInventory();
	TOMABuymenu_CalcInventory();
	wid=-1;
	iid=-1;
	if (BoxPistols.MouseoverIndex!=BoxPistols.LBIT_NONE)
		wid=BoxPistols.GetData(BoxPistols.MouseoverIndex);
	else
		if (BoxSub.MouseoverIndex!=BoxSub.LBIT_NONE)
			wid=BoxSub.GetData(BoxSub.MouseoverIndex);
		else
			if (BoxRifles.MouseoverIndex!=BoxRifles.LBIT_NONE)
				wid=BoxRifles.GetData(BoxRifles.MouseoverIndex);
			else
				if (BoxGrenades.MouseoverIndex!=BoxGrenades.LBIT_NONE)
					wid=BoxGrenades.GetData(BoxGrenades.MouseoverIndex);
				else
					if (BoxSpecialitems.MouseoverIndex!=BoxSpecialitems.LBIT_NONE)
						iid=BoxSpecialitems.GetData(BoxSpecialitems.MouseoverIndex);
	if (wid>=0)
	{
		if (wid!=MeshId)
		{
			MeshId=wid;
			ItemId=-1;
			if (TOMAGameReplicationInfo(OwnerPlayer.GameReplicationInfo).NewWeapons)
			{
				MeshClass=Class<S_Weapon>(DynamicLoadObject(Class'TOMAWeaponsHandler'.Default.WeaponStr[MeshId],Class'Class'));
				MeshScale=Class'TOMAWeaponsHandler'.Default.BuymenuScale[MeshId];
			}
			else
			{
				MeshClass=Class<S_Weapon>(DynamicLoadObject(Class'TO_WeaponsHandler'.Default.WeaponStr[MeshId],Class'Class'));
				MeshScale=Class'TO_WeaponsHandler'.Default.BuymenuScale[MeshId];
			}
			MeshActor.Mesh=MeshClass.Default.ThirdPersonMesh;
			MeshFrame=0;
		}
	}
	else
	{
		if (iid>=0)
		{
			if (iid!=ItemId)
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
}

simulated function Notify (UWindowDialogControl control, byte Event)
{
	local int WeaponID;
	local int i;
	local Class<S_Weapon> W;

	if (control==BoxSpecialitems)
	{
		if (Event==DE_MouseMove)
		{
			if (BoxSpecialitems.IsGroupedByIndex(BoxSpecialitems.MouseoverIndex))
			{
				Hint=TextHintSpecial;
				AltHint=TextHintSpecialAlt;
			}
			else
			{
				Hint=TextHintSpecial;
				AltHint="";
			}
		}
		else
		{
			if (Event==DE_MouseLeave)
			{
				Hint=TextHintDefault;
				AltHint=TextHintDefaultAlt;
			}
		}
	}
	else
	{
		if (control.IsA('TO_GUIBaseListBox'))
		{
			if (Event==DE_DoubleClick)
			{
				i=TO_GUIBaseListBox(control).DoubleclickIndex;
				if (TO_GUIBaseListBox(control).IsSelectedByIndex(i))
				{
					WeaponID=TO_GUIBaseListBox(control).GetData(i);
					if (WeaponID!=-1)
					{
						if (TOMAGameReplicationInfo(OwnerPlayer.GameReplicationInfo).NewWeapons) W=Class<S_Weapon>(DynamicLoadObject(Class'TOMAWeaponsHandler'.Default.WeaponStr[WeaponID],Class'Class')); else W=Class<S_Weapon>(DynamicLoadObject(Class'TO_WeaponsHandler'.Default.WeaponStr[WeaponID],Class'Class'));
						SelectedClips[WeaponID].Primary=W.Default.MaxClip;
						SelectedClips[WeaponID].secondary=W.Default.BackupMaxClip;
					}
				}
			}
			else
			{
				if (Event==DE_MouseMove)
				{
					Hint=TextHintWeapon;
					AltHint=TextHintWeaponAlt;
				}
				else
				{
					if (Event==DE_MouseLeave)
					{
						Hint=TextHintDefault;
						AltHint=TextHintDefaultAlt;
					}
				}
			}
		}
		else
		{
			if (control.IsA('TO_GUIBaseUpDown'))
			{
				if ((Event==DE_Click) || (Event==DE_DoubleClick))
				{
					WeaponID=TO_GUIBaseUpDown(control).Data;
					if (WeaponID>=0)
						SelectedClips[WeaponID].Primary=TO_GUIBaseUpDown(control).Value;
					else
						SelectedClips[-WeaponID].secondary=TO_GUIBaseUpDown(control).Value;
				}
				else
				{
					if (Event==DE_MouseMove)
					{
						if (control==AmmoBox[0])
						{
							Hint=TextHintKnives;
							AltHint=TextHintKnivesAlt;
						}
						else
						{
							Hint=TextHintAmmo;
							AltHint=TextHintAmmoAlt;
						}
					}
					else
					{
						if (Event==DE_MouseLeave)
						{
							Hint=TextHintDefault;
							AltHint=TextHintDefaultAlt;
						}
					}
				}
			}
			else
			{
				if (control==ButtonRestore)
				{
					if (Event==DE_Click)
					{
						OwnerPlayer.PlaySound(Sound'equip_nvg',SLOT_None);
						TOMATOBuymenu_RefreshInventory();
					}
					else
					{
						if (Event==DE_MouseMove)
						{
							Hint=TextHintRestorebutton;
							AltHint="";
						}
						else
						{
							if (Event==DE_MouseLeave)
							{
								Hint=TextHintDefault;
								AltHint=TextHintDefaultAlt;
							}
						}
					}
				}
				else
				{
					if (control==ButtonBuy)
					{
						if (Event==DE_Click)
						{
							if (RemainingMoney<0)
								OwnerPlayer.PlaySound(Sound'hithelmet',SLOT_None);
							else
							{
								TOMABuymenu_GetPlayerCapital();
//								TOMABuymenu_SetPlayerInventory();
				                SendWeaponsToBuy();
								OwnerPlayer.PlaySound(Sound'Kevlar',SLOT_None);
								OwnerInterface.Hide();
							}
						}
						else
						{
							if (Event==DE_MouseMove)
							{
								Hint=TextHintBuybutton;
								AltHint="";
							}
							else
							{
								if (Event==DE_MouseLeave)
								{
									Hint=TextHintDefault;
									AltHint=TextHintDefaultAlt;
								}
							}
						}
					}
					else
					{
						if (control==ButtonCancel)
						{
							if (Event==DE_Click)
								OwnerInterface.Hide();
						}
					}
				}
			}
		}
	}
}

simulated function BeforeShow ()
{
	if (!bAlreadyInit) InitNewWeapons();
	TOMABuymenu_GetPlayerCapital();
	TOMATOBuymenu_RefreshInventory();
}

simulated function TOMATOBuymenu_RefreshInventory ()
{
	local int i;

	TOMABuymenu_Tool_ListInventory(BoxPistols,WCL_PISTOL);
	TOMABuymenu_Tool_ListInventory(BoxSub,WCL_SMG);
	TOMABuymenu_Tool_ListInventory(BoxRifles,WCL_RIFLE);
	TOMABuymenu_Tool_ListInventory(BoxGrenades,WCL_GRENADE);
	AmmoBox[0].Value=S_Weapon(OwnerPlayer.FindInventoryType(Class's_Knife')).clipAmmo;
	for (i=0;i<32;i++)
	{
		SelectedClips[i].Primary=SCL_NONE;
		SelectedClips[i].secondary=SCL_NONE;
	}
	TOBuymenu_Tool_ListSpecialitems();
}

simulated function TOMABuymenu_Tool_ListInventory (TO_GUITextListbox List, byte WeapClass)
{
	local int i;
	local int Id;
	local bool B;
	local Class<S_Weapon> W;

	List.Clear();
	for (i=0;i<NumSortedWeapons;i++)
	{
		Id=SortedWeapons[i];
		if (TOMAGameReplicationInfo(OwnerPlayer.GameReplicationInfo).NewWeapons) W=Class<S_Weapon>(DynamicLoadObject(Class'TOMAWeaponsHandler'.Default.WeaponStr[Id],Class'Class')); else W=Class<S_Weapon>(DynamicLoadObject(Class'TO_WeaponsHandler'.Default.WeaponStr[Id],Class'Class'));
		if (W.Default.price>Capital)
			break;
		else
		{
			if (W.Default.WeaponClass==WeapClass)
			{
				B=Weapon[Id]==HAS_YES;
				if (!Class'TOMAWeaponsHandler'.static.IsTeamMatch(OwnerPlayer,Id))
				{
					if (TOMAGameReplicationInfo(OwnerPlayer.GameReplicationInfo).TerroristsWeapons)
						List.AddItem(Class'TO_WeaponsHandler'.Default.WeaponName[Id],"$" $ string(W.Default.price),Id,B);
				} else
				{
					if (TOMAGameReplicationInfo(OwnerPlayer.GameReplicationInfo).NewWeapons)
						List.AddItem(Class'TOMAWeaponsHandler'.Default.WeaponName[Id],"$" $ string(W.Default.price),Id,B);
					else
						List.AddItem(Class'TO_WeaponsHandler'.Default.WeaponName[Id],"$" $ string(W.Default.price),Id,B);
				}
			}
		}
	}
}

final simulated function TOMABuymenu_CalcInventory()
{
	local int WeaponID;
	local int total;
	local int i;
	local Class<S_Weapon> W;

	total=0;
	W=Class<s_Knife>(DynamicLoadObject("s_Swat.s_Knife",Class'Class'));
	total+=AmmoBox[0].Value*W.Default.ClipPrice/W.Default.clipSize;
	total+=TOMABuymenu_Tool_GetSelectedWeaponPrice(BoxPistols);
	total+=TOMABuymenu_Tool_GetSelectedWeaponPrice(BoxSub);
	total+=TOMABuymenu_Tool_GetSelectedWeaponPrice(BoxRifles);
	total+=TOMABuymenu_Tool_GetSelectedWeaponPrice(BoxGrenades);
	NumAmmoBoxes=1;
	TOMABuymenu_Tool_ListAmmo(BoxPistols);
	TOMABuymenu_Tool_ListAmmo(BoxSub);
	TOMABuymenu_Tool_ListAmmo(BoxRifles);
	TOMABuymenu_Tool_ListAmmo(BoxGrenades);
	for (i=1;i<NumAmmoBoxes;i++)
	{
		WeaponID=AmmoBox[i].Data;
		if (WeaponID>=0)
		{
			if (TOMAGameReplicationInfo(OwnerPlayer.GameReplicationInfo).NewWeapons) W=Class<S_Weapon>(DynamicLoadObject(Class'TOMAWeaponsHandler'.Default.WeaponStr[WeaponID],Class'Class')); else W=Class<S_Weapon>(DynamicLoadObject(Class'TO_WeaponsHandler'.Default.WeaponStr[WeaponID],Class'Class'));
			total+=AmmoBox[i].Value*W.Default.ClipPrice;
		}
		else
		{
			if (TOMAGameReplicationInfo(OwnerPlayer.GameReplicationInfo).NewWeapons) W=Class<S_Weapon>(DynamicLoadObject(Class'TOMAWeaponsHandler'.Default.WeaponStr[-WeaponID],Class'Class')); else W=Class<S_Weapon>(DynamicLoadObject(Class'TO_WeaponsHandler'.Default.WeaponStr[-WeaponID],Class'Class'));
			total+=AmmoBox[i].Value*W.Default.BackupClipPrice;
		}
		AmmoBox[i].ShowWindow();
	}
	i=NumAmmoBoxes;
	while (i<MaxAmmoBoxes)
	{
		AmmoBox[i].Value=0;
		AmmoBox[i].HideWindow();
		i++;
	}
	if (BoxSpecialitems.IsSelectedByData(2))
		total+=ItemPrice[2];
	if (BoxSpecialitems.IsSelectedByData(3))
		total+=ItemPrice[3];
	if (BoxSpecialitems.IsSelectedByData(4))
		total+=ItemPrice[4];
	if (BoxSpecialitems.IsSelectedByData(1))
		total+=ItemPrice[1];
	RemainingMoney=Capital-total;
}

final simulated function int TOMABuymenu_Tool_GetSelectedWeaponPrice (TO_GUITextListbox List)
{
	local int Id;
	local Class<S_Weapon> W;

	Id=List.GetData(List.GetSelected());
	if (Id!=-1)
	{
		if (TOMAGameReplicationInfo(OwnerPlayer.GameReplicationInfo).NewWeapons)
		{
			W=Class<S_Weapon>(DynamicLoadObject(Class'TOMAWeaponsHandler'.Default.WeaponStr[Id],Class'Class'));
			return W.Default.price;
		}
		else
		{
			W=Class<S_Weapon>(DynamicLoadObject(Class'TO_WeaponsHandler'.Default.WeaponStr[Id],Class'Class'));
			return W.Default.price;
		}
	}
	return 0;
}

final simulated function bool TOMABuymenu_GetPlayerCapital()
{
	local Inventory Inv;
	local S_Weapon W;
	local int i;
	local int Id;
	local int extramoney;

	for (i=0;i<32;i++)
	{
		LastWeapon[i]=Weapon[i];
		LastClips[i].Primary=clips[i].Primary;
		LastClips[i].secondary=clips[i].secondary;
		Weapon[i]=HAS_NO;
		clips[i].Primary=0;
		clips[i].secondary=0;
	}
	for (i=0;i<5;i++)
	{
		LastItem[i]=Item[i];
		Item[i]=HAS_NO;
	}
	LastKnives=Knives;
	i=0;
	extramoney=0;
	for(Inv=OwnerPlayer.Inventory;Inv!=None;Inv=Inv.Inventory)
	{
		if (Inv.IsA('S_Weapon'))
		{
			if (TOMAGameReplicationInfo(OwnerPlayer.GameReplicationInfo).NewWeapons) Id=Class'TOMAWeaponsHandler'.static.GetIdByClass(string(Inv.Class)); else Id=Class'TO_WeaponsHandler'.static.GetIdByClass(string(Inv.Class));
			if (Id>-1)
			{
				W=S_Weapon(Inv);
				Weapon[Id]=HAS_YES;
				clips[Id].Primary=W.GetRemainingClips(False);
				clips[Id].secondary=W.GetRemainingClips(True);
				extramoney+=W.Default.price+clips[Id].Primary*W.Default.ClipPrice+clips[Id].secondary*W.Default.BackupClipPrice;
			}
		}
		if (++i>100)
			break;
	}
	if (OwnerPlayer.HelmetCharge==100)
	{
		Item[2]=HAS_YES;
		extramoney+=ItemPrice[2];
	}
	if (OwnerPlayer.VestCharge==100)
	{
		Item[3]=HAS_YES;
		extramoney+=ItemPrice[3];
	}
	if (OwnerPlayer.LegsCharge==100)
	{
		Item[4]=HAS_YES;
		extramoney+=ItemPrice[4];
	}
	if (OwnerPlayer.bHasNV)
	{
		Item[1]=HAS_YES;
		extramoney+=ItemPrice[1];
	}
	W=S_Weapon(OwnerPlayer.FindInventoryType(Class's_Knife'));
	Knives=W.clipAmmo;
	extramoney+=Knives*W.ClipPrice/W.clipSize;
	Capital=OwnerPlayer.money+extramoney;
	for (i=0;i<32;i++)
	{
		if ((Weapon[i]!=LastWeapon[i]) || (clips[i].Primary!=LastClips[i].Primary) || (clips[i].secondary!=LastClips[i].secondary))
			return False;
	}
	for (i=0;i<5;i++)
		if (Item[i]!=LastItem[i])
			return False;
	if (Knives!=LastKnives)
		return False;
	return True;
}

final simulated function TOMABuymenu_Tool_ListAmmo(TO_GUITextListbox List)
{
	local int Id;
	local Class<S_Weapon> W;
	local TO_GUIBaseUpDown box;

	if (NumAmmoBoxes>=MaxAmmoBoxes)
		return;
	Id=List.GetData(List.GetSelected());
	if (Id==-1)
		return;
	if (TOMAGameReplicationInfo(OwnerPlayer.GameReplicationInfo).NewWeapons) W=Class<S_Weapon>(DynamicLoadObject(Class'TOMAWeaponsHandler'.Default.WeaponStr[Id],Class'Class')); else W=Class<S_Weapon>(DynamicLoadObject(Class'TO_WeaponsHandler'.Default.WeaponStr[Id],Class'Class'));
	if ((W.Default.MaxClip>0) && (!W.IsA('TO_Grenade')))
	{
		box=AmmoBox[NumAmmoBoxes];
		if (WinWidth>=800)
			box.Label=W.Default.AmmoName @ "x" $ string(W.Default.clipSize);
		else
			box.Label=W.Default.AmmoName;
		box.MaxValue=W.Default.MaxClip;
		box.MinValue=0;
		box.IncValue=W.Default.ClipInc;
		box.Data=Id;
		if (SelectedClips[Id].Primary!=-1)
			box.Value=SelectedClips[Id].Primary;
		else
			box.Value=clips[Id].Primary;
		NumAmmoBoxes++;
	}
	if ((W.Default.BackupMaxClip>0) && (NumAmmoBoxes<MaxAmmoBoxes) && (!W.IsA('TO_Grenade')))
	{
		box=AmmoBox[NumAmmoBoxes];
		if (WinWidth>=800)
			box.Label=W.Default.BackupAmmoName @ "x" $ string(W.Default.BackupClipSize);
		else
			box.Label=W.Default.BackupAmmoName;
		box.MaxValue=W.Default.BackupMaxClip;
		box.MinValue=0;
		box.IncValue=1;
		box.Data= -Id;
		if (SelectedClips[Id].secondary!=-1)
			box.Value=SelectedClips[Id].secondary;
		else
			box.Value=clips[Id].secondary;
		NumAmmoBoxes++;
	}
}

simulated final function TOMABuymenu_Init(Canvas Canvas)
{
	local float l,w,t,w2,w4;
	local int i,buttonoffset;

    buttonoffset=50*Resolution;
	w=Width*0.25-Padding[Resolution];
	l=int(Width*0.125);
	w2=int(w*0.5);
	w4=int(w*0.4);

	BoxSpecialitems.WinLeft=Left+Width-Padding[Resolution]-w4;
	BoxSpecialitems.WinTop=Top+Padding[Resolution];
	BoxSpecialitems.SetWidth(Canvas,w4);

	t=Top+6*Padding[Resolution]-32-2+BoxSpecialitems.WinHeight;

	BoxPistols.WinLeft=Left+l-w2;
	BoxPistols.WinTop=t-10;
	BoxPistols.SetWidth(Canvas,w);
	BoxPistols.ClientHeight=BoxPistols.ClientHeight+40;
	BoxPistols.NumVisItems=12;

	BoxSub.WinLeft=Left+3*l-w2;
	BoxSub.WinTop=t-10;
	BoxSub.SetWidth(Canvas,w);
	BoxSub.ClientHeight=BoxSub.ClientHeight+50;
	BoxSub.NumVisItems=12;

	BoxRifles.WinLeft=Left+5*l-w2;
	BoxRifles.WinTop=t-10;
	BoxRifles.SetWidth(Canvas,w);
	BoxRifles.ClientHeight=BoxRifles.ClientHeight+50;
	BoxRifles.NumVisItems=12;

	BoxGrenades.WinLeft=Left+7*l-w2;
	BoxGrenades.WinTop=t-10;
	BoxGrenades.SetWidth(Canvas,w);
	BoxGrenades.ClientHeight=BoxGrenades.ClientHeight+50;
	BoxGrenades.NumVisItems=12;

	ButtonBuy.WinTop=300;
	ButtonBuy.SetWidth(Canvas,(w-Padding[Resolution])/2);
	ButtonBuy.WinLeft=Canvas.ClipX-ButtonBuy.WinWidth;

	ButtonRestore.WinTop=350;
	ButtonRestore.SetWidth(Canvas,(w-Padding[Resolution])/2);
	ButtonRestore.WinLeft=Canvas.ClipX-ButtonRestore.WinWidth;

	ButtonCancel.WinTop=400;
	ButtonCancel.SetWidth(Canvas,(w-Padding[Resolution])/2);
	ButtonCancel.WinLeft=Canvas.ClipX-ButtonCancel.WinWidth;

	MeshboxHeight=BoxSpecialitems.WinHeight-2;
	MeshboxWidth=int(0.5*Width);
	MeshboxLeft=BoxSpecialitems.WinLeft-Padding[Resolution]-MeshboxWidth;
	MeshboxTop=Top+Padding[Resolution];

	for (i=0;i<MaxAmmoBoxes;i++)
	{
		AmmoBox[i].WinLeft=10;//Left+(i+1)*Padding[Resolution]+i*w4;
		AmmoBox[i].WinTop=90+((60+(20*Resolution))*i);//Top+int(0.8125*Height)+Padding[Resolution];
		AmmoBox[i].SetWidth(Canvas,w4);
	}
}

final simulated function SendWeaponsToBuy()
{
	local s_Weapon W;
	local int i,WeaponID;

	i=0;

    OwnerPlayer.Equip.Flags=0;
	OwnerPlayer.Equip.Weapon2=0;
	OwnerPlayer.Equip.Weapon3=0;
	OwnerPlayer.Equip.Weapon4=0;
	OwnerPlayer.Equip.Weapon5=0;
	OwnerPlayer.Equip.Ammo=0;
	OwnerPlayer.Equip.BackupAmmo=0;

	i=BoxPistols.GetSelected();
	if (i!=-1)
	{
		WeaponID=BoxPistols.GetData(i);
		OwnerPlayer.Equip.Weapon2=WeaponID;
		OwnerPlayer.Equip.Ammo=OwnerPlayer.Equip.Ammo | (TOMAWishAmmo(WeaponID,true) & 255);
		OwnerPlayer.Equip.BackupAmmo=OwnerPlayer.Equip.BackupAmmo | (TOMAWishAmmo(WeaponID,false) & 255);
	}

	i=BoxSub.GetSelected();
	if (i!=-1)
	{
		WeaponID=BoxSub.GetData(i);
		OwnerPlayer.Equip.Weapon3=WeaponID;
		OwnerPlayer.Equip.Ammo=OwnerPlayer.Equip.Ammo | ((TOMAWishAmmo(WeaponID,true) & 255) << 8);
		OwnerPlayer.Equip.BackupAmmo=OwnerPlayer.Equip.BackupAmmo | ((TOMAWishAmmo(WeaponID,false) & 255) << 8);
	}

	i=BoxRifles.GetSelected();
	if (i!=-1)
	{
		WeaponID=BoxRifles.GetData(i);
		OwnerPlayer.Equip.Weapon4=WeaponID;
		OwnerPlayer.Equip.Ammo=OwnerPlayer.Equip.Ammo | ((TOMAWishAmmo(WeaponID,true) & 255) << 16);
		OwnerPlayer.Equip.BackupAmmo=OwnerPlayer.Equip.BackupAmmo | ((TOMAWishAmmo(WeaponID,false) & 255) << 16);
	}

	i=BoxGrenades.GetSelected();
	if (i!=-1)
	{
		WeaponID=BoxGrenades.GetData(i);
		OwnerPlayer.Equip.Weapon5=WeaponID;
		TOMAPlayer(OwnerPlayer).MoreAmmo=TOMAWishAmmo(WeaponID,true);
		TOMAPlayer(OwnerPlayer).MoreBackupAmmo=TOMAWishAmmo(WeaponID,false);
	}

	if (BoxSpecialitems.IsSelectedByData(ICL_HELMET))
	{
		OwnerPlayer.Equip.Flags=OwnerPlayer.Equip.Flags | 128;
	}
	if (BoxSpecialitems.IsSelectedByData(ICL_VEST))
	{
		OwnerPlayer.Equip.Flags=OwnerPlayer.Equip.Flags | 64;
	}
	if (BoxSpecialitems.IsSelectedByData(ICL_PADS))
	{
		OwnerPlayer.Equip.Flags=OwnerPlayer.Equip.Flags | 32;
	}
	if (BoxSpecialitems.IsSelectedByData(ICL_NIGHTVISION))
	{
		OwnerPlayer.Equip.Flags=OwnerPlayer.Equip.Flags | 16;
	}

	OwnerPlayer.Equip.Flags=OwnerPlayer.Equip.Flags | (AmmoBox[0].Value & 7);
	TOMAPlayer(OwnerPlayer).BuyOnServer(OwnerPlayer.Equip,TOMAPlayer(OwnerPlayer).MoreAmmo,TOMAPlayer(OwnerPlayer).MoreBackupAmmo);
}

final simulated function int TOMAWishAmmo(int Weapon,bool primaryAmmo)
{
	local int i,id;

    if ((Weapon!=12) && (Weapon!=13) && (Weapon!=14) && (Weapon!=19) && (Weapon!=28) && (Weapon!=29))
    {
	for (i=1;i<NumAmmoBoxes;i++)
	{
        if (AmmoBox[i]!=None)
        {
    		id=AmmoBox[i].Data;
            // correct ammo box ?
            if ((id == Weapon && primaryAmmo) || (-id == Weapon && !primaryAmmo))
            {
                return AmmoBox[i].Value;
            }
        }
	}
    }
	return 0;
}

defaultproperties
{
    MaxAmmoBoxes=6
}

