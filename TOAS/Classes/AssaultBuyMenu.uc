//
// FilRip
//
// New BuyMenu tab of the HUD
// To add support of display only weapons of the player class owner
//

Class AssaultBuyMenu extends TO_GUITabBuyMenu;

simulated function Paint (Canvas Canvas, float x, float y)
{
	if (!bDraw)
	{
		return;
	}

	// background
	if (OwnerHud.bDrawBackground)
	{
		super(TO_GUIBaseTab).Paint(Canvas, x, y);
	}

//	TOBuymenu_DrawMoney(Canvas);
	TOBuymenu_DrawItemmesh(Canvas);
	if (MeshId >= 0)
	{
		TOBuymenu_DrawIteminfo(Canvas);
	}
	else if (ItemId >= 0)
	{
		TOBuymenu_DrawIteminfoS(Canvas);
	}
}

// Prepare the menu, display buttons, etc...
simulated function BeforePaint (Canvas Canvas, float X, float Y)
{
	local int wid;
	local int iid;

	if (!bInitialized)
	{
		Super(TO_GUIBaseTab).BeforePaint(Canvas,X,Y);
		TOBuymenu_Init(Canvas);
	}
	else
		Super(TO_GUIBaseTab).BeforePaint(Canvas,X,Y);
	if (bDraw)
	{
		ButtonRestore.ShowWindow();
		ButtonBuy.ShowWindow();
		ButtonCancel.ShowWindow();
	}
	if (!TOBuymenu_GetPlayerCapital())
		AssaultTOBuymenu_RefreshInventory();
	TOBuymenu_CalcInventory();
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
			MeshClass=Class<S_Weapon>(DynamicLoadObject(Class'TO_WeaponsHandler'.Default.WeaponStr[MeshId],Class'Class'));
			MeshScale=Class'AssaultWeaponsHandler'.Default.BuymenuScale[MeshId];
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

// What to do when click on an interact stuff of the menu
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
						W=Class<S_Weapon>(DynamicLoadObject(Class'TO_WeaponsHandler'.Default.WeaponStr[WeaponID],Class'Class'));
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
						AssaultTOBuymenu_RefreshInventory();
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
								TOBuymenu_GetPlayerCapital();
//								TOBuymenu_SetPlayerInventory();
				                SendEquipmentWish();
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
	TOBuymenu_GetPlayerCapital();
	AssaultTOBuymenu_RefreshInventory();
}

simulated function AssaultTOBuymenu_RefreshInventory ()
{
	local int i;

    if (class'AssaultModelHandler'.default.PClass[OwnerPlayer.PlayerModel]==3)
    {
        AssaultTOBuymenu_Tool_ListInventory(BoxPistols,1);
        AssaultTOBuymenu_Tool_ListInventory(BoxSub,2);
    }
    else
    {
        AssaultTOBuymenu_Tool_ListInventory(BoxSub,1);
        AssaultTOBuymenu_Tool_AddInventory(BoxSub,2);
        BoxPistols.HideWindow();
	}
    AssaultTOBuymenu_Tool_ListInventory(BoxRifles,3);
    AssaultTOBuymenu_Tool_ListInventory(BoxGrenades,5);
	AmmoBox[0].Value=S_Weapon(OwnerPlayer.FindInventoryType(Class's_Knife')).clipAmmo;
	for (i=0;i<32;i++)
	{
		SelectedClips[i].Primary=-1;
		SelectedClips[i].secondary=-1;
	}
	TOBuymenu_Tool_ListSpecialitems();
}

simulated function AssaultTOBuymenu_Tool_ListInventory (TO_GUITextListbox List, byte WeapClass)
{
	local int i;
	local int Id;
	local bool B;
	local Class<S_Weapon> W;

	Capital=20000;
	List.Clear();
	for (i=0;i<NumSortedWeapons;i++)
	{
		Id=SortedWeapons[i];
		W=Class<S_Weapon>(DynamicLoadObject(Class'TO_WeaponsHandler'.Default.WeaponStr[Id],Class'Class'));
		if (W.Default.price>Capital)
			break;
		else
		{
			if (TOBuymenu_Tool_ShouldWeaponBeHidden(Class'AssaultWeaponsHandler'.Default.WeaponStr[Id]))
				continue;
			if (W.Default.WeaponClass==WeapClass)
			{
				B=Weapon[Id]==1;
				if ((B) || (Class'AssaultWeaponsHandler'.static.IsTeamMatch(OwnerPlayer,Id)) || (TOBuymenu_Tool_ShouldWeaponBeShown(Class'TO_WeaponsHandler'.Default.WeaponStr[Id])))
					if (class'AssaultWeaponsHandler'.static.IsClassMatch(OwnerPlayer,id))
						List.AddItem(Class'TO_WeaponsHandler'.Default.WeaponName[Id],"$" $ string(W.Default.price),Id,B);
			}
		}
	}
}

simulated function AssaultTOBuymenu_Tool_AddInventory (TO_GUITextListbox List, byte WeapClass)
{
	local int i;
	local int Id;
	local bool B;
	local Class<S_Weapon> W;

	Capital=20000;
	for (i=0;i<NumSortedWeapons;i++)
	{
		Id=SortedWeapons[i];
		W=Class<S_Weapon>(DynamicLoadObject(Class'TO_WeaponsHandler'.Default.WeaponStr[Id],Class'Class'));
		if (W.Default.price>Capital)
			break;
		else
		{
			if (TOBuymenu_Tool_ShouldWeaponBeHidden(Class'AssaultWeaponsHandler'.Default.WeaponStr[Id]))
				continue;
			if (W.Default.WeaponClass==WeapClass)
			{
				B=Weapon[Id]==1;
				if ((B) || (Class'AssaultWeaponsHandler'.static.IsTeamMatch(OwnerPlayer,Id)) || (TOBuymenu_Tool_ShouldWeaponBeShown(Class'TO_WeaponsHandler'.Default.WeaponStr[Id])))
					if (class'AssaultWeaponsHandler'.static.IsClassMatch(OwnerPlayer,id))
						List.AddItem(Class'TO_WeaponsHandler'.Default.WeaponName[Id],"$" $ string(W.Default.price),Id,B);
			}
		}
	}
}

defaultproperties
{
}
