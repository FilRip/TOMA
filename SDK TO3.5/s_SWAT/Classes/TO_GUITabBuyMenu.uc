class TO_GUITabBuyMenu extends TO_GUIBaseTab;

var TO_GUIImageListbox BoxSpecialitems;
var TO_GUIBaseUpDown AmmoBox;
var TO_GUITextListbox BoxPistols;
var TO_GUITextListbox BoxSub;
var TO_GUITextListbox BoxRifles;
var TO_GUITextListbox BoxGrenades;
struct SWeaponClips
{
	var int Primary;
	var int secondary;
}
var SWeaponClips clips;
struct SWeaponClips
{
	var int Primary;
	var int secondary;
}
var SWeaponClips SelectedClips;
var int NumAmmoBoxes;
enum ETOBuymenuHasItem {
	HAS_NO,
	HAS_YES
};
var ETOBuymenuHasItem Item;
var int ItemId;
var int MeshId;
var TO_GUIBaseButton ButtonCancel;
var TO_GUIBaseButton ButtonRestore;
var S_Weapon MeshClass;
var TO_GUIBaseButton ButtonBuy;
var int ItemPrice;
var byte SortedWeapons;
var TO_MeshActor MeshActor;
var byte NumSortedWeapons;
enum ETOBuymenuHasItem {
	HAS_NO,
	HAS_YES
};
var ETOBuymenuHasItem Weapon;
var int MaxAmmoBoxes;
var int MeshFrame;
var float MeshboxWidth;
var float MeshboxLeft;
var int RemainingMoney;
var float MeshboxTop;
var bool bDrawCursor;
struct SWeaponClips
{
	var int Primary;
	var int secondary;
}
var SWeaponClips LastClips;
var int Knives;
enum ETOBuymenuHasItem {
	HAS_NO,
	HAS_YES
};
var ETOBuymenuHasItem LastWeapon;
var Rotator MeshRotator;
var float MeshboxHeight;
var float MeshScale;
enum ETOBuymenuHasItem {
	HAS_NO,
	HAS_YES
};
var ETOBuymenuHasItem LastItem;
var int LastKnives;
var int Capital;

final simulated function int WishAmmo (int Weapon, bool primaryAmmo)
{
}

final simulated function int TOBuymenu_Tool_GetSelectedWeaponPrice (TO_GUITextListbox List)
{
}

final simulated function TOBuymenu_Tool_ListInventory (TO_GUITextListbox List, byte WeapClass)
{
}

final simulated function TOBuymenu_RefreshInventory ()
{
}

final simulated function bool TOBuymenu_GetPlayerCapital ()
{
}

final simulated function TOBuymenu_Tool_ListAmmo (TO_GUITextListbox List)
{
}

function TOBuymenu_Init (Canvas Canvas)
{
}

final simulated function TOBuymenu_DrawMoney (Canvas Canvas)
{
}

final simulated function TOBuymenu_DrawItemmesh (Canvas Canvas)
{
}

function TOBuymenu_DrawIteminfo (Canvas Canvas)
{
}

final simulated function TOBuymenu_DrawIteminfoS (Canvas Canvas)
{
}

final simulated function TOBuymenu_CalcInventory ()
{
}

final simulated function TOBuymenu_Tool_ListSpecialitems ()
{
}

final simulated function SendEquipmentWish ()
{
}

simulated function Created ()
{
}

simulated function Close (optional bool bByParent)
{
}

function Tick (float Delta)
{
}

simulated function BeforePaint (Canvas Canvas, float X, float Y)
{
}

simulated function Paint (Canvas Canvas, float X, float Y)
{
}

simulated function Notify (UWindowDialogControl control, byte Event)
{
}

simulated function KeyDown (int Key, float X, float Y)
{
}

function WindowEvent (WinMessage Msg, Canvas C, float X, float Y, int Key)
{
}

simulated function OwnerTick (float Delta)
{
}

simulated function BeforeShow ()
{
}

simulated function BeforeHide ()
{
}

simulated function bool TOBuymenu_Tool_ShouldWeaponBeHidden (string WeaponString)
{
}

simulated function bool TOBuymenu_Tool_ShouldWeaponBeShown (string WeaponString)
{
}


defaultproperties
{
}

