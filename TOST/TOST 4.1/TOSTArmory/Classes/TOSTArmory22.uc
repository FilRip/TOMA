//----------------------------------------------------------------------------
// Project : TOST
// File    : TOSTArmory22.uc
// Version : 0.5
// Author  : BugBunny
//----------------------------------------------------------------------------
// Version	Changes
// 0.5		+ first release
//----------------------------------------------------------------------------

class TOSTArmory22 expands TOSTArmoryConfig;

defaultproperties
{
    GameMods=(SniperSwimAimError=0.0,ZoomAimErrorMod=-0.2,CrouchAimErrorMod=-0.15,MoveAimErrorMod=0.2,SwimAimErrorMod=0.0,DmgRangeMod=0.0,TerrDefWeapon=class'TOSTWeapons.TOST_Glock',SwatDefWeapon=class'TOSTWeapons.TOST_Beretta')

	// Glock
	Weapon(0)=(WeaponClass="TOSTWeapons.TOST_Glock",Teams=1,Price=400,RPM=240,Damage=50.0,MaxRange=1440.0,AimError=0.11,HRecoil=10.0,VRecoil=250.0,ClipPrice=15,ClipSize=13,ClipMax=5,AltClipPrice=0,AltClipSize=0,AltClipMax=0,AltRPM=0,AltHRecoil=0.0,AltVRecoil=0.0,Weight=2.0)
	// Berreta
	Weapon(1)=(WeaponClass="TOSTWeapons.TOST_Beretta",Teams=2,Price=500,RPM=300,Damage=50.0,MaxRange=1440.0,AimError=0.10,HRecoil=5.0,VRecoil=300.0,ClipPrice=15,ClipSize=15,ClipMax=4,AltClipPrice=0,AltClipSize=0,AltClipMax=0,AltRPM=0,AltHRecoil=0.0,AltVRecoil=0.0,Weight=5.0)
	// Desert Eagle
	Weapon(2)=(WeaponClass="TOSTWeapons.TOST_DEagle",Teams=3,Price=700,RPM=200,Damage=68.0,MaxRange=1920.0,AimError=0.12,HRecoil=2.0,VRecoil=450.0,ClipPrice=25,ClipSize=7,ClipMax=7,AltClipPrice=0,AltClipSize=0,AltClipMax=0,AltRPM=0,AltHRecoil=0.0,AltVRecoil=0.0,Weight=5.0)
	// Raging Bull
	Weapon(3)=(WeaponClass="",Teams=0,Price=0,RPM=0,Damage=0.0,MaxRange=0.0,AimError=0.0,HRecoil=0.0,VRecoil=0.0,ClipPrice=0,ClipSize=0,ClipMax=0,AltClipPrice=0,AltClipSize=0,AltClipMax=0,AltRPM=0,AltHRecoil=0.0,AltVRecoil=0.0,Weight=0)
	// HK SMG 2
	Weapon(4)=(WeaponClass="",Teams=0,Price=0,RPM=0,Damage=0.0,MaxRange=0.0,AimError=0.0,HRecoil=0.0,VRecoil=0.0,ClipPrice=0,ClipSize=0,ClipMax=0,AltClipPrice=0,AltClipSize=0,AltClipMax=0,AltRPM=0,AltHRecoil=0.0,AltVRecoil=0.0,Weight=0)
	// Mac 10
	Weapon(5)=(WeaponClass="TOSTWeapons.TOST_MAC10",Teams=1,Price=1000,RPM=1000,Damage=15.0,MaxRange=1440.0,AimError=0.16,HRecoil=30.0,VRecoil=50.0,ClipPrice=30,ClipSize=32,ClipMax=6,AltClipPrice=0,AltClipSize=0,AltClipMax=0,AltRPM=0,AltHRecoil=0.0,AltVRecoil=0.0,Weight=6.0)
	// HK MP5 Navy
	Weapon(6)=(WeaponClass="TOSTWeapons.TOST_MP5N",Teams=2,Price=1500,RPM=800,Damage=21.0,MaxRange=1920.0,AimError=0.13,HRecoil=20.0,VRecoil=75.0,ClipPrice=50,ClipSize=30,ClipMax=5,AltClipPrice=0,AltClipSize=0,AltClipMax=0,AltRPM=0,AltHRecoil=0.0,AltVRecoil=0.0,Weight=15.0)
	// HK MP5k PDW
	Weapon(7)=(WeaponClass="TOSTWeapons.TOST_MP5KPDW",Teams=1,Price=1600,RPM=850,Damage=20.0,MaxRange=1920.0,AimError=0.13,HRecoil=20.0,VRecoil=60.0,ClipPrice=40,ClipSize=30,ClipMax=5,AltClipPrice=0,AltClipSize=0,AltClipMax=0,AltRPM=0,AltHRecoil=0.0,AltVRecoil=0.0,Weight=15.0)
	// Mossberg
	Weapon(8)=(WeaponClass="TOSTWeapons.TOST_Mossberg",Teams=1,Price=1500,RPM=80,Damage=16.0,MaxRange=1200.0,AimError=0.25,HRecoil=1.0,VRecoil=1000.0,ClipPrice=40,ClipSize=8,ClipMax=48,AltClipPrice=0,AltClipSize=0,AltClipMax=0,AltRPM=0,AltHRecoil=0.0,AltVRecoil=0.0,Weight=15.0)
	// M3 Benelli
	Weapon(9)=(WeaponClass="TOSTWeapons.TOST_M3",Teams=2,Price=2000,RPM=110,Damage=18.0,MaxRange=1440.0,AimError=0.25,HRecoil=10.0,VRecoil=500.0,ClipPrice=40,ClipSize=8,ClipMax=40,AltClipPrice=0,AltClipSize=0,AltClipMax=0,AltRPM=0,AltHRecoil=0.0,AltVRecoil=0.0,Weight=15.0)
	// Saiga
	Weapon(10)=(WeaponClass="TOSTWeapons.TOST_Saiga",Teams=1,Price=2800,RPM=140,Damage=18.0,MaxRange=1440.0,AimError=0.25,HRecoil=10.0,VRecoil=500.0,ClipPrice=40,ClipSize=7,ClipMax=4,AltClipPrice=0,AltClipSize=0,AltClipMax=0,AltRPM=0,AltHRecoil=0.0,AltVRecoil=0.0,Weight=15.0)
	// Ak47
	Weapon(11)=(WeaponClass="TOSTWeapons.TOST_Ak47",Teams=1,Price=3200,RPM=700,Damage=30.0,MaxRange=4800.0,AimError=0.3,HRecoil=10.0,VRecoil=100.0,ClipPrice=40,ClipSize=30,ClipMax=4,AltClipPrice=0,AltClipSize=0,AltClipMax=0,AltRPM=0,AltHRecoil=0.0,AltVRecoil=0.0,Weight=15.0)
	// M4A1
	Weapon(12)=(WeaponClass="",Teams=0,Price=0,RPM=0,Damage=0.0,MaxRange=0.0,AimError=0.0,HRecoil=0.0,VRecoil=0.0,ClipPrice=0,ClipSize=0,ClipMax=0,AltClipPrice=0,AltClipSize=0,AltClipMax=0,AltRPM=0,AltHRecoil=0.0,AltVRecoil=0.0,Weight=0)
	// M16
	Weapon(13)=(WeaponClass="TOSTWeapons.TOST_M16",Teams=3,Price=3850,RPM=240,Damage=60.0,MaxRange=14400.0,AimError=0.5,HRecoil=2.0,VRecoil=280.0,ClipPrice=50,ClipSize=20,ClipMax=4,AltClipPrice=0,AltClipSize=0,AltClipMax=0,AltRPM=0,AltHRecoil=0.0,AltVRecoil=0.0,Weight=20.0)
	// Sig
	Weapon(14)=(WeaponClass="",Teams=0,Price=0,RPM=0,Damage=0.0,MaxRange=0.0,AimError=0.0,HRecoil=0.0,VRecoil=0.0,ClipPrice=0,ClipSize=0,ClipMax=0,AltClipPrice=0,AltClipSize=0,AltClipMax=0,AltRPM=0,AltHRecoil=0.0,AltVRecoil=0.0,Weight=0)
	// HK33
	Weapon(15)=(WeaponClass="TOSTWeapons.TOST_HK33",Teams=1,Price=4500,RPM=700,Damage=35.0,MaxRange=9600.0,AimError=0.42,HRecoil=5.0,VRecoil=80.0,ClipPrice=40,ClipSize=30,ClipMax=4,AltClipPrice=0,AltClipSize=0,AltClipMax=0,AltRPM=0,AltHRecoil=0.0,AltVRecoil=0.0,Weight=15.0)
	// PSG1
	Weapon(16)=(WeaponClass="TOSTWeapons.TOST_PSG1",Teams=3,Price=4350,RPM=90,Damage=125.0,MaxRange=14400.0,AimError=1.7,HRecoil=20.0,VRecoil=750.0,ClipPrice=15,ClipSize=5,ClipMax=4,AltClipPrice=0,AltClipSize=0,AltClipMax=0,AltRPM=0,AltHRecoil=0.0,AltVRecoil=0.0,Weight=25.0)
	// PH85
	Weapon(17)=(WeaponClass="TOSTWeapons.TOST_p85",Teams=1,Price=8500,RPM=45,Damage=200.0,MaxRange=16800.0,AimError=1.6,HRecoil=40.0,VRecoil=400.0,ClipPrice=15,ClipSize=10,ClipMax=4,AltClipPrice=0,AltClipSize=0,AltClipMax=0,AltRPM=0,AltHRecoil=0.0,AltVRecoil=0.0,Weight=25.0)
	// M4m203
	Weapon(18)=(WeaponClass="TOSTWeapons.TOST_M4m203",Teams=2,Price=11000,RPM=600,Damage=37.0,MaxRange=7200.0,AimError=0.35,HRecoil=5.0,VRecoil=80.0,ClipPrice=50,ClipSize=30,ClipMax=6,AltClipPrice=300,AltClipSize=1,AltClipMax=4,AltRPM=0,AltHRecoil=0.0,AltVRecoil=0.0,Weight=25.0)
	// M60
	Weapon(19)=(WeaponClass="",Teams=0,Price=0,RPM=0,Damage=0.0,MaxRange=0.0,AimError=0.0,HRecoil=0.0,VRecoil=0.0,ClipPrice=0,ClipSize=0,ClipMax=0,AltClipPrice=0,AltClipSize=0,AltClipMax=0,AltRPM=0,AltHRecoil=0.0,AltVRecoil=0.0,Weight=0)
	// OICW
	Weapon(20)=(WeaponClass="TOSTWeapons.TOST_OICW",Teams=0,Price=15000,RPM=600,Damage=40.0,MaxRange=12000.0,AimError=0.5,HRecoil=5.0,VRecoil=80.0,ClipPrice=50,ClipSize=25,ClipMax=6,AltClipPrice=300,AltClipSize=5,AltClipMax=2,AltRPM=0,AltHRecoil=0.0,AltVRecoil=0.0,Weight=25.0)
	// HE Grenade
	Weapon(21)=(WeaponClass="TOSTWeapons.TOST_Grenade",Teams=3,Price=500,RPM=100,Damage=60.0,MaxRange=0.0,AimError=500.0,HRecoil=0.0,VRecoil=0.0,ClipPrice=0,ClipSize=0,ClipMax=0,AltClipPrice=0,AltClipSize=0,AltClipMax=0,AltRPM=0,AltHRecoil=0.0,AltVRecoil=0.0,Weight=4.0)
	// Concussion Grenade
	Weapon(22)=(WeaponClass="TOSTWeapons.TOST_GrenadeConc",Teams=3,Price=300,RPM=100,Damage=60.0,MaxRange=0.0,AimError=500.0,HRecoil=0.0,VRecoil=0.0,ClipPrice=0,ClipSize=0,ClipMax=0,AltClipPrice=0,AltClipSize=0,AltClipMax=0,AltRPM=0,AltHRecoil=0.0,AltVRecoil=0.0,Weight=4.0)
	// Flashbang
	Weapon(23)=(WeaponClass="TOSTWeapons.TOST_GrenadeFB",Teams=3,Price=400,RPM=100,Damage=0.0,MaxRange=0.0,AimError=500.0,HRecoil=0.0,VRecoil=0.0,ClipPrice=0,ClipSize=0,ClipMax=0,AltClipPrice=0,AltClipSize=0,AltClipMax=0,AltRPM=0,AltHRecoil=0.0,AltVRecoil=0.0,Weight=4.0)
	// Smoke Grenade
	Weapon(24)=(WeaponClass="TOSTWeapons.TOST_GrenadeSmoke",Teams=3,Price=450,RPM=100,Damage=0.0,MaxRange=0.0,AimError=500.0,HRecoil=0.0,VRecoil=0.0,ClipPrice=0,ClipSize=0,ClipMax=0,AltClipPrice=0,AltClipSize=0,AltClipMax=0,AltRPM=0,AltHRecoil=0.0,AltVRecoil=0.0,Weight=4.0)
	// Knife
	Weapon(25)=(WeaponClass="TOSTWeapons.TOST_Knife",Teams=3,Price=200,RPM=100,Damage=60.0,MaxRange=120.0,AimError=500.0,HRecoil=0.0,VRecoil=0.0,ClipPrice=100,ClipSize=7,ClipMax=0,AltClipPrice=0,AltClipSize=0,AltClipMax=0,AltRPM=0,AltHRecoil=0.0,AltVRecoil=0.0,Weight=2.0)
	Weapon(26)=(WeaponClass="",Teams=0,Price=0,RPM=0,Damage=0.0,MaxRange=0.0,AimError=0.0,HRecoil=0.0,VRecoil=0.0,ClipPrice=0,ClipSize=0,ClipMax=0,AltClipPrice=0,AltClipSize=0,AltClipMax=0,AltRPM=0,AltHRecoil=0.0,AltVRecoil=0.0,Weight=0)
	Weapon(27)=(WeaponClass="",Teams=0,Price=0,RPM=0,Damage=0.0,MaxRange=0.0,AimError=0.0,HRecoil=0.0,VRecoil=0.0,ClipPrice=0,ClipSize=0,ClipMax=0,AltClipPrice=0,AltClipSize=0,AltClipMax=0,AltRPM=0,AltHRecoil=0.0,AltVRecoil=0.0,Weight=0)
	Weapon(28)=(WeaponClass="",Teams=0,Price=0,RPM=0,Damage=0.0,MaxRange=0.0,AimError=0.0,HRecoil=0.0,VRecoil=0.0,ClipPrice=0,ClipSize=0,ClipMax=0,AltClipPrice=0,AltClipSize=0,AltClipMax=0,AltRPM=0,AltHRecoil=0.0,AltVRecoil=0.0,Weight=0)
	Weapon(29)=(WeaponClass="",Teams=0,Price=0,RPM=0,Damage=0.0,MaxRange=0.0,AimError=0.0,HRecoil=0.0,VRecoil=0.0,ClipPrice=0,ClipSize=0,ClipMax=0,AltClipPrice=0,AltClipSize=0,AltClipMax=0,AltRPM=0,AltHRecoil=0.0,AltVRecoil=0.0,Weight=0)
	Weapon(30)=(WeaponClass="",Teams=0,Price=0,RPM=0,Damage=0.0,MaxRange=0.0,AimError=0.0,HRecoil=0.0,VRecoil=0.0,ClipPrice=0,ClipSize=0,ClipMax=0,AltClipPrice=0,AltClipSize=0,AltClipMax=0,AltRPM=0,AltHRecoil=0.0,AltVRecoil=0.0,Weight=0)
	Weapon(31)=(WeaponClass="",Teams=0,Price=0,RPM=0,Damage=0.0,MaxRange=0.0,AimError=0.0,HRecoil=0.0,VRecoil=0.0,ClipPrice=0,ClipSize=0,ClipMax=0,AltClipPrice=0,AltClipSize=0,AltClipMax=0,AltRPM=0,AltHRecoil=0.0,AltVRecoil=0.0,Weight=0)

	NewWeapons(0)=(WeaponName="Desert Eagle",WeaponClass="TOSTWeapons.TOST_DEagle",BotDesirability=0.5,WeaponTeams=3,BuymenuScale=2.0)
	NewWeapons(1)=(WeaponName="Ingram MAC 10",WeaponClass="TOSTWeapons.TOST_MAC10",BotDesirability=0.6,WeaponTeams=1,BuymenuScale=1.8)
	NewWeapons(2)=(WeaponName="MP5 Navy",WeaponClass="TOSTWeapons.TOST_MP5N",BotDesirability=0.5,WeaponTeams=1,BuymenuScale=1.8)
	NewWeapons(3)=(WeaponName="Mossberg",WeaponClass="TOSTWeapons.TOST_Mossberg",BotDesirability=0.3,WeaponTeams=1,BuymenuScale=1.3)
	NewWeapons(4)=(WeaponName="M3 Benelli",WeaponClass="TOSTWeapons.TOST_M3",BotDesirability=0.3,WeaponTeams=2,BuymenuScale=1.3)
	NewWeapons(5)=(WeaponName="AK 47",WeaponClass="TOSTWeapons.TOST_Ak47",BotDesirability=0.5,WeaponTeams=1,BuymenuScale=1.2)
	NewWeapons(6)=(WeaponName="FAMAS",WeaponClass="TOSTWeapons.TOSTFAMAS",BotDesirability=0.5,WeaponTeams=2,BuymenuScale=1.0)
	NewWeapons(7)=(WeaponName="Steyr Aug",WeaponClass="TOSTWeapons.TOSTSteyrAug",BotDesirability=0.4,WeaponTeams=2,BuymenuScale=1.0)
	NewWeapons(8)=(WeaponName="M16A2",WeaponClass="TOSTWeapons.TOST_M16",BotDesirability=0.45,WeaponTeams=3,BuymenuScale=1.0)
	NewWeapons(9)=(WeaponName="HK 33",WeaponClass="TOSTWeapons.TOST_HK33",BotDesirability=0.45,WeaponTeams=2,BuymenuScale=1.3)
	NewWeapons(10)=(WeaponName="PSG 1",WeaponClass="TOSTWeapons.TOST_PSG1",BotDesirability=0.1,WeaponTeams=3,BuymenuScale=1.0)
	NewWeapons(11)=(WeaponName="HE Grenade",WeaponClass="TOSTWeapons.TOST_Grenade",BotDesirability=0.17,WeaponTeams=3,BuymenuScale=2.0)
	NewWeapons(12)=(WeaponName="FlashBang",WeaponClass="TOSTWeapons.TOST_GrenadeFB",BotDesirability=0.09,WeaponTeams=3,BuymenuScale=2.0)
	NewWeapons(13)=(WeaponName="Conc. Grenade",WeaponClass="TOSTWeapons.TOST_GrenadeConc",BotDesirability=0.13,WeaponTeams=3,BuymenuScale=2.0)
	NewWeapons(14)=(WeaponName="Parker-Hale 85",WeaponClass="TOSTWeapons.TOST_p85",BotDesirability=0.1,WeaponTeams=2,BuymenuScale=1.0)
	NewWeapons(15)=(WeaponName="Saiga 12",WeaponClass="TOSTWeapons.TOST_Saiga",BotDesirability=0.45,WeaponTeams=1,BuymenuScale=1.2)
	NewWeapons(16)=(WeaponName="MP5 SD",WeaponClass="TOSTWeapons.TOST_MP5KPDW",BotDesirability=0.6,WeaponTeams=2,BuymenuScale=1.5)
	NewWeapons(17)=(WeaponName="Beretta 92F",WeaponClass="TOSTWeapons.TOST_Beretta",BotDesirability=0.1,WeaponTeams=2,BuymenuScale=1.7)
	NewWeapons(18)=(WeaponName="Smoke Grenade",WeaponClass="TOSTWeapons.TOST_GrenadeSmoke",BotDesirability=0.1,WeaponTeams=3,BuymenuScale=2.0)
	NewWeapons(19)=(WeaponName="M4A2m203",WeaponClass="TOSTWeapons.TOST_M4m203",BotDesirability=0.5,WeaponTeams=2,BuymenuScale=1.25)
	NewWeapons(20)=(WeaponName="Glock 21",WeaponClass="TOSTWeapons.TOST_Glock",BotDesirability=0.1,WeaponTeams=1,BuymenuScale=2.0)
	NewWeapons(21)=(WeaponName="",WeaponClass="",BotDesirability=0.0,WeaponTeams=2,BuymenuScale=0.0)
	NewWeapons(22)=(WeaponName="",WeaponClass="",BotDesirability=0.0,WeaponTeams=0,BuymenuScale=0.0)
	NewWeapons(23)=(WeaponName="",WeaponClass="",BotDesirability=0.0,WeaponTeams=2,BuymenuScale=0.0)
	NewWeapons(24)=(WeaponName="",WeaponClass="",BotDesirability=0.0,WeaponTeams=0,BuymenuScale=0.0)
	NewWeapons(25)=(WeaponName="",WeaponClass="",BotDesirability=0.0,WeaponTeams=0,BuymenuScale=0.0)
	NewWeapons(26)=(WeaponName="",WeaponClass="",BotDesirability=0.0,WeaponTeams=0,BuymenuScale=0.0)
	NewWeapons(27)=(WeaponName="",WeaponClass="",BotDesirability=0.0,WeaponTeams=0,BuymenuScale=0.0)
	NewWeapons(28)=(WeaponName="",WeaponClass="",BotDesirability=0.0,WeaponTeams=0,BuymenuScale=0.0)
	NewWeapons(29)=(WeaponName="",WeaponClass="",BotDesirability=0.0,WeaponTeams=0,BuymenuScale=0.0)
	NewWeapons(30)=(WeaponName="",WeaponClass="",BotDesirability=0.0,WeaponTeams=0,BuymenuScale=0.0)
	NewWeapons(31)=(WeaponName="",WeaponClass="",BotDesirability=0.0,WeaponTeams=0,BuymenuScale=0.0)
}
