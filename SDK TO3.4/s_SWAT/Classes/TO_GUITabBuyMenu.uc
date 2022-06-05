class TO_GUITabBuyMenu extends TO_GUIBaseTab;

struct SWeaponClips
{
	var int Primary;
	var int secondary;
};

enum ETOBuymenuHasItem {
	HAS_NO,
	HAS_YES
};

const SCL_NONE=-1;
const ICL_PADS=4;
const ICL_VEST=3;
const ICL_HELMET=2;
const ICL_NIGHTVISION=1;
const ICL_KNIFES=0;
const WCL_RIFLE=3;
const WCL_SMG=2;
const WCL_PISTOL=1;
const WCL_GRENADE=5;

var float MeshboxHeight;
var float MeshboxWidth;
var float MeshboxLeft;
var float MeshboxTop;
var Class<S_Weapon> MeshClass;
var TO_MeshActor MeshActor;
var Rotator MeshRotator;
var float MeshScale;
var int MeshId;
var int ItemId;
var int MeshFrame;
var bool bDrawCursor;
var TO_GUIImageListbox BoxSpecialitems;
var TO_GUITextListbox BoxPistols;
var TO_GUITextListbox BoxSub;
var TO_GUITextListbox BoxRifles;
var TO_GUITextListbox BoxGrenades;
var TO_GUIBaseUpDown AmmoBox[5];
var int NumAmmoBoxes;
var int MaxAmmoBoxes;
var TO_GUIBaseButton ButtonBuy;
var TO_GUIBaseButton ButtonRestore;
var TO_GUIBaseButton ButtonCancel;
var ETOBuymenuHasItem Weapon[32];
var ETOBuymenuHasItem LastWeapon[32];
var ETOBuymenuHasItem Item[5];
var ETOBuymenuHasItem LastItem[5];
var SWeaponClips clips[32];
var SWeaponClips LastClips[32];
var SWeaponClips SelectedClips[32];
var int Knives;
var int LastKnives;
var int Capital;
var int RemainingMoney;
var int ItemPrice[5];
var byte SortedWeapons[32];
var byte NumSortedWeapons;
var localized string TextBuymenuTitle;
var localized string TextMoneyCash;
var localized string TextMoneyPrice;
var localized string TextMoneyRest;
var localized string TextBoxPistols;
var localized string TextBoxSub;
var localized string TextBoxRifles;
var localized string TextBoxGrenades;
var localized string TextBoxKnifes;
var localized string TextInfoRange;
var localized string TextInfoClipsize;
var localized string TextInfoNumclips;
var localized string TextInfoRPM;
var localized string TextInfoUMeters;
var localized string TextButtonBuy;
var localized string TextButtonRestore;
var localized string TextButtonCancel;
var localized string TextDescItems[5];
var localized string TextHintDefault;
var localized string TextHintDefaultAlt;
var localized string TextHintSpecial;
var localized string TextHintSpecialAlt;
var localized string TextHintKnives;
var localized string TextHintKnivesAlt;
var localized string TextHintAmmo;
var localized string TextHintAmmoAlt;
var localized string TextHintWeapon;
var localized string TextHintWeaponAlt;
var localized string TextHintBuybutton;
var localized string TextHintRestorebutton;
var localized string TextHintCancelbutton;
var localized string AmmoName[45];

simulated function Created ()
{
}

simulated function Close (optional bool bByParent)
{
}

simulated function Tick (float Delta)
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

final simulated function TOBuymenu_Init (Canvas Canvas)
{
}

final simulated function TOBuymenu_DrawMoney (Canvas Canvas)
{
}

final simulated function TOBuymenu_DrawItemmesh (Canvas Canvas)
{
}

final simulated function TOBuymenu_DrawIteminfo (Canvas Canvas)
{
}

final simulated function TOBuymenu_DrawIteminfoS (Canvas Canvas)
{
}

final simulated function TOBuymenu_RefreshInventory ()
{
}

final simulated function TOBuymenu_CalcInventory ()
{
}

final simulated function bool TOBuymenu_GetPlayerCapital ()
{
}

final simulated function TOBuymenu_Tool_ListInventory (TO_GUITextListbox List, byte WeapClass)
{
}

final simulated function TOBuymenu_Tool_ListAmmo (TO_GUITextListbox List)
{
}

final simulated function TOBuymenu_Tool_ListSpecialitems ()
{
}

final simulated function int TOBuymenu_Tool_GetSelectedWeaponPrice (TO_GUITextListbox List)
{
}

simulated function bool TOBuymenu_Tool_ShouldWeaponBeHidden (string WeaponString)
{
}

simulated function bool TOBuymenu_Tool_ShouldWeaponBeShown (string WeaponString)
{
}

final simulated function int WishAmmo (int Weapon, bool primaryAmmo)
{
}

final simulated function SendEquipmentWish ()
{
}
