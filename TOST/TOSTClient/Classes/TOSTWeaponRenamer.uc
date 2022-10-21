// $Id: TOSTWeaponRenamer.uc 487 2004-03-07 14:29:51Z dildog $
//----------------------------------------------------------------------------
// Project : TOST
// File    : TOSTWeaponRenamer.uc
// Version : 4.0
// Author  : BugBunny / MadOnion
//----------------------------------------------------------------------------

class TOSTWeaponRenamer expands Actor config(TOSTUser);

// User preferences
var config bool 	RenameWeapons;
var config string	WeaponClass[32];
var config string	AltWeaponClass[32];
var config string	WeaponDescription[32];
var config string	WeaponPickupMessage[32];
var config string	WeaponItemName[32];

simulated event		Destroyed()
{
	SaveConfig();
}

// WeaponRenamer
simulated function	RenameWeapon(string WeaponCls, string AltWeaponCls, string Desc, string Pickup, string ItemName)
{
	local class<actor>	NewClass;
	local int 			i, j;

	NewClass = class<actor>( DynamicLoadObject( WeaponCls, class'Class', True ) );
	if (class<TournamentWeapon>(NewClass) != None)
	{
		class<TournamentWeapon>(NewClass).default.WeaponDescription = Desc;
		class<TournamentWeapon>(NewClass).default.PickupMessage = Pickup;
		class<TournamentWeapon>(NewClass).default.ItemName = ItemName;
		j = class'TOModels.TO_WeaponsHandler'.default.NumWeapons;
		for (i=0; i<j; i++)
		{
			if (Caps(class'TOModels.TO_WeaponsHandler'.default.WeaponStr[i]) == Caps(WeaponCls))
				class'TOModels.TO_WeaponsHandler'.default.WeaponName[i] = ItemName;
		}
	}

	NewClass = class<actor>( DynamicLoadObject( AltWeaponCls, class'Class', true ) );
	if (class<TournamentWeapon>(NewClass) != None)
	{
		class<TournamentWeapon>(NewClass).default.WeaponDescription = Desc;
		class<TournamentWeapon>(NewClass).default.PickupMessage = Pickup;
		class<TournamentWeapon>(NewClass).default.ItemName = ItemName;
		j = class'TOModels.TO_WeaponsHandler'.default.NumWeapons;
		for (i=0; i<j; i++)
		{
			if (Caps(class'TOModels.TO_WeaponsHandler'.default.WeaponStr[i]) == Caps(AltWeaponCls))
				class'TOModels.TO_WeaponsHandler'.default.WeaponName[i] = ItemName;
		}
	}
}

simulated function	Rename()
{
	local int i;

	if (!RenameWeapons)
		return;
	for (i=0; i<ArrayCount(WeaponClass); i++)
	{
		if (WeaponClass[i] != "")
		{
			RenameWeapon(WeaponClass[i], AltWeaponClass[i], WeaponDescription[i], WeaponPickupMessage[i], WeaponItemName[i]);
		}
	}
}

DefaultProperties
{
	bHidden=true
   	RenameWeapons=True
	WeaponClass(0)="s_SWAT.s_DEagle"
	WeaponClass(1)="s_SWAT.s_Glock"
	WeaponClass(2)="s_SWAT.s_MAC10"
	WeaponClass(3)="s_SWAT.s_MP5N"
	WeaponClass(4)="s_SWAT.s_Mossberg"
	WeaponClass(5)="s_SWAT.s_M3"
	WeaponClass(6)="s_SWAT.s_Ak47"
	WeaponClass(7)="s_SWAT.TO_SteyrAug"
	WeaponClass(8)="s_SWAT.TO_M4A1"
	WeaponClass(9)="s_SWAT.TO_M16"
	WeaponClass(10)="s_SWAT.TO_HK33"
	WeaponClass(11)="s_SWAT.s_PSG1"
	WeaponClass(12)="s_SWAT.TO_Grenade"
	WeaponClass(13)="s_SWAT.s_GrenadeFB"
	WeaponClass(14)="s_SWAT.s_GrenadeConc"
	WeaponClass(15)="s_SWAT.s_p85"
	WeaponClass(16)="s_SWAT.TO_Saiga"
	WeaponClass(17)="s_SWAT.TO_MP5KPDW"
	WeaponClass(18)="s_SWAT.TO_Berreta"
	WeaponClass(19)="s_SWAT.TO_GrenadeSmoke"
	WeaponClass(20)="s_SWAT.TO_M4m203"
	WeaponClass(21)="s_SWAT.TO_HKSMG2"
	WeaponClass(22)="s_SWAT.TO_RagingBull"
	WeaponClass(23)="s_SWAT.TO_m60"
	WeaponClass(24)=
	WeaponClass(25)=
	WeaponClass(26)=
	WeaponClass(27)=
	WeaponClass(28)=
	WeaponClass(29)=
	WeaponClass(30)=
	WeaponClass(31)=
	AltWeaponClass(0)="TOSTWeapons.TOST_DEagle"
	AltWeaponClass(1)="TOSTWeapons.TOST_Glock"
	AltWeaponClass(2)="TOSTWeapons.TOST_MAC10"
	AltWeaponClass(3)="TOSTWeapons.TOST_MP5N"
	AltWeaponClass(4)="TOSTWeapons.TOST_Mossberg"
	AltWeaponClass(5)="TOSTWeapons.TOST_M3"
	AltWeaponClass(6)="TOSTWeapons.TOST_Ak47"
	AltWeaponClass(7)="TOSTWeapons.TOST_SteyrAug"
	AltWeaponClass(8)="TOSTWeapons.TOST_M4A1"
	AltWeaponClass(9)="TOSTWeapons.TOST_M16"
	AltWeaponClass(10)="TOSTWeapons.TOST_HK33"
	AltWeaponClass(11)="TOSTWeapons.TOST_PSG1"
	AltWeaponClass(12)="TOSTWeapons.TOST_Grenade"
	AltWeaponClass(13)="TOSTWeapons.TOST_GrenadeFB"
	AltWeaponClass(14)="TOSTWeapons.TOST_GrenadeConc"
	AltWeaponClass(15)="TOSTWeapons.TOST_p85"
	AltWeaponClass(16)="TOSTWeapons.TOST_Saiga"
	AltWeaponClass(17)="TOSTWeapons.TOST_MP5KPDW"
	AltWeaponClass(18)="TOSTWeapons.TOST_Berreta"
	AltWeaponClass(19)="TOSTWeapons.TOST_GrenadeSmoke"
	AltWeaponClass(20)="TOSTWeapons.TOST_M4m203"
	AltWeaponClass(21)="TOSTWeapons.TOST_HKSMG2"
	AltWeaponClass(22)="TOSTWeapons.TOST_RagingBull"
	AltWeaponClass(23)="TOSTWeapons.TOST_m60"
	AltWeaponClass(24)=
	AltWeaponClass(25)=
	AltWeaponClass(26)=
	AltWeaponClass(27)=
	AltWeaponClass(28)=
	AltWeaponClass(29)=
	AltWeaponClass(30)=
	AltWeaponClass(31)=
	WeaponItemname(0)="Desert Eagle"
	WeaponItemname(1)="Glock 21"
	WeaponItemname(2)="Ingram MAC 10"
	WeaponItemname(3)="MP5A2"
	WeaponItemname(4)="Mossberg Shotgun"
	WeaponItemname(5)="SPAS 12"
	WeaponItemname(6)="AK-47"
	WeaponItemname(7)="Sig 551"
	WeaponItemname(8)="M4A1"
	WeaponItemname(9)="M16A2"
	WeaponItemname(10)="HK 33"
	WeaponItemname(11)="MSG 90"
	WeaponItemname(12)="HE Grenade"
	WeaponItemname(13)="FlashBang"
	WeaponItemname(14)="Conc. Grenade"
	WeaponItemname(15)="Parker-Hale 85"
	WeaponItemname(16)="Saiga 12"
	WeaponItemname(17)="MP5 SD"
	WeaponItemname(18)="Beretta 92F"
	WeaponItemname(19)="Smoke Grenade"
	WeaponItemname(20)="M4A2m203"
	WeaponItemname(21)="SMG II"
	WeaponItemname(22)="Raging Bull"
	WeaponItemname(23)="M60"
	WeaponItemname(24)=
	WeaponItemname(25)=
	WeaponItemname(26)=
	WeaponItemname(27)=
	WeaponItemname(28)=
	WeaponItemname(29)=
	WeaponItemname(30)=
	WeaponItemname(31)=
	WeaponDescription(0)="Classification: Desert Eagle .50 w/ Laser Aim"
	WeaponDescription(1)="Classification: Glock 21 .45 ACP"
	WeaponDescription(2)="Classification: Ingram Mac 10 .45 ACP"
	WeaponDescription(3)="Classification: H&K MP5A2 Navy"
	WeaponDescription(4)="Classification: Mossberg Pump-Action Shotgun"
	WeaponDescription(5)="Classification: Spas-12 Semi-Automatic Shotgun"
	WeaponDescription(6)="Classification: Kalashnikov AK-47"
	WeaponDescription(7)="Classification: Sig 551 Commando Automatic Rifle"
	WeaponDescription(8)="Classification: Colt M4A1 w/ Adjustable Stock"
	WeaponDescription(9)="Classification: M16 A2 w/ Laser Aim"
	WeaponDescription(10)="Classification: H&K 33 A3 SG1 5.56mm w/ Scope"
	WeaponDescription(11)="Classification: MSG 90 Semi-Auto Sniper Rifle"
	WeaponDescription(12)="Classification: High Yield High Explosive Grenade"
	WeaponDescription(13)="Classification: Level 3 FlashBang Grenade"
	WeaponDescription(14)="Classification: M67 Low Yield Shrapnel Grenade"
	WeaponDescription(15)="Classification: Parker Hale 85 Bolt-Action Rifle"
	WeaponDescription(16)="Classification: Saiga 12s Automatic Shotgun"
	WeaponDescription(17)="Classification: H&K MP5 SD3 w/ Supressor"
	WeaponDescription(18)="Classification: Beretta 92F 9mm"
	WeaponDescription(19)="Classification: M83 Non-Toxic Smoke Grenade"
	WeaponDescription(20)="Classification: M4A2 w/ m203 Grenade Launcher"
	WeaponDescription(21)="Classification: H&K SMG II 9mm"
	WeaponDescription(22)="Classification: Casul .454 Raging Bull"
	WeaponDescription(23)="Classification: M60 E3 Machine Gun"
 	WeaponDescription(24)=
	WeaponDescription(25)=
	WeaponDescription(26)=
	WeaponDescription(27)=
	WeaponDescription(28)=
	WeaponDescription(29)=
	WeaponDescription(30)=
	WeaponDescription(31)=
	WeaponPickupMessage(0)="You picked up the Desert Eagle pistol!"
	WeaponPickupMessage(1)="You picked up the Glock 21 pistol!"
	WeaponPickupMessage(2)="You picked up the Ingram MAC 10 !"
	WeaponPickupMessage(3)="You picked up the MP5A2 !"
	WeaponPickupMessage(4)="You picked up the Mossberg shotgun!"
	WeaponPickupMessage(5)="You picked up the SPAS 12 shotgun!"
	WeaponPickupMessage(6)="You picked up the AK-47 !"
	WeaponPickupMessage(7)="You picked up the Sig 551 !"
	WeaponPickupMessage(8)="You picked up the M4A1 !"
	WeaponPickupMessage(9)="You picked up the M16A2 !"
	WeaponPickupMessage(10)="You picked up the HK 33 !"
	WeaponPickupMessage(11)="You picked up the MSG 90 !"
	WeaponPickupMessage(12)="You picked up a HE grenade!"
	WeaponPickupMessage(13)="You picked up a Flashbang !"
	WeaponPickupMessage(14)="You picked up a Concussion grenade!"
	WeaponPickupMessage(15)="You picked up the Parker-Hale 85 !"
	WeaponPickupMessage(16)="You picked up the Saiga 12 !"
	WeaponPickupMessage(17)="You picked up the MP5 SD !"
	WeaponPickupMessage(18)="You picked up the Beretta 92F pistol!"
	WeaponPickupMessage(19)="You picked up a Smoke grenade!"
	WeaponPickupMessage(20)="You picked up the M4A2m203 !"
	WeaponPickupMessage(21)="You picked up the SMG II !"
	WeaponPickupMessage(22)="You picked up the Raging Bull!"
	WeaponPickupMessage(23)="You picked up the M60 !"
	WeaponPickupMessage(24)=
	WeaponPickupMessage(25)=
	WeaponPickupMessage(26)=
	WeaponPickupMessage(27)=
	WeaponPickupMessage(28)=
	WeaponPickupMessage(29)=
	WeaponPickupMessage(30)=
	WeaponPickupMessage(31)=
}
