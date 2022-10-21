//----------------------------------------------------------------------------
// Project : TOST
// File    : TOSTArmoryConfig.uc
// Version : 0.5
// Author  : BugBunny
//----------------------------------------------------------------------------
// Version	Changes
// 0.5		+ first release
//----------------------------------------------------------------------------

class TOSTArmoryConfig expands Info config;

struct GameMod {
	var float	SniperSwimAimError;
	var float	ZoomAimErrorMod;
	var float	CrouchAimErrorMod;
	var float	MoveAimErrorMod;
	var float	SwimAimErrorMod;
	var float	DmgRangeMod;
	var class<s_Weapon>	TerrDefWeapon;
	var class<s_Weapon>	SwatDefWeapon;
};
var config	GameMod		GameMods;

struct WeaponMod {
	var	string		WeaponClass;
	var	int			Teams;
	var int			Price;
	var int		    RPM;
	var float		Damage;
	var float       MaxRange;
	var float		AimError;
	var float		HRecoil;
	var float		VRecoil;
	var int			ClipPrice;
	var int			ClipSize;
	var int			ClipMax;
	var int			AltClipPrice;
	var int			AltClipSize;
	var int			AltClipMax;
	var int			AltRPM;
	var float		AltHRecoil;
	var float		AltVRecoil;
	var float		Weight;
};
var config	WeaponMod	Weapon[32];

struct NewWeapon {
	var string		WeaponName;
	var string		WeaponClass;
	var float		BotDesirability;
	var	int			WeaponTeams;
	var float		BuymenuScale;
};
var config	NewWeapon	NewWeapons[32];

simulated function	string	GetWeaponClass(int Index)
{
	return	Weapon[Index].WeaponClass;
}

simulated function	int	SetWeaponData(int Index, class<s_Weapon> NewClass)
{
	local	int		i, j;

	NewClass.default.Price = Weapon[Index].Price;
	NewClass.default.RoundPerMin = Weapon[Index].RPM;
	NewClass.default.MaxDamage = Weapon[Index].Damage;
	NewClass.default.MaxRange = Weapon[Index].MaxRange;
	NewClass.default.PlayerAimError = Weapon[Index].AimError;
	NewClass.default.BotAimError = Weapon[Index].AimError;
	NewClass.default.VRecoil = Weapon[Index].VRecoil;
	NewClass.default.HRecoil = Weapon[Index].HRecoil;
	NewClass.default.ClipPrice = Weapon[Index].ClipPrice;
	NewClass.default.ClipSize = Weapon[Index].ClipSize;
	if (class<s_Knife>(NewClass) == None)
		NewClass.default.ClipAmmo = Weapon[Index].ClipSize;
	NewClass.default.MaxClip = Weapon[Index].ClipMax;
	NewClass.default.BackupClipPrice = Weapon[Index].AltClipPrice;
	NewClass.default.BackupClipSize = Weapon[Index].AltClipSize;
	NewClass.default.BackupAmmo = Weapon[Index].AltClipSize;
	NewClass.default.BackupMaxClip = Weapon[Index].AltClipMax;
	NewClass.default.WeaponWeight = Weapon[Index].Weight;
	if (class<TOSTWeapon>(NewClass) != None)
	{
		class<TOSTWeapon>(NewClass).default.AltRoundPerMin = Weapon[Index].AltRPM;
		class<TOSTWeapon>(NewClass).default.AltHRecoil = Weapon[Index].AltHRecoil;
		class<TOSTWeapon>(NewClass).default.AltVRecoil = Weapon[Index].AltVRecoil;

		class<TOSTWeapon>(NewClass).default.SniperSwimAimError=GameMods.SniperSwimAimError;
		class<TOSTWeapon>(NewClass).default.ZoomAimErrorMod=GameMods.ZoomAimErrorMod;
		class<TOSTWeapon>(NewClass).default.CrouchAimErrorMod=GameMods.CrouchAimErrorMod;
		class<TOSTWeapon>(NewClass).default.MoveAimErrorMod=GameMods.MoveAimErrorMod;
		class<TOSTWeapon>(NewClass).default.SwimAimErrorMod=GameMods.SwimAimErrorMod;
		class<TOSTWeapon>(NewClass).default.DmgRangeMod=GameMods.DmgRangeMod;

	}
	j = class'TOModels.TO_WeaponsHandler'.default.NumWeapons;
	for (i=0; i<j; i++)
		if (Caps(class'TOModels.TO_WeaponsHandler'.default.WeaponStr[i]) == Caps(Weapon[Index].WeaponClass))
		{
			switch (Weapon[Index].Teams) {
				case 0 : class'TOModels.TO_WeaponsHandler'.default.WeaponTeam[i] = WT_None; break;
				case 1 : class'TOModels.TO_WeaponsHandler'.default.WeaponTeam[i] = WT_Terrorist; break;
				case 2 : class'TOModels.TO_WeaponsHandler'.default.WeaponTeam[i] = WT_SpecialForces; break;
				case 3 : class'TOModels.TO_WeaponsHandler'.default.WeaponTeam[i] = WT_Both; break;
			}
		}
}

simulated function	AddWeapon(int Index)
{
	local	int		i, j;

	if (NewWeapons[Index].WeaponClass == "")
		return;
	// check if already present
	j = class'TOModels.TO_WeaponsHandler'.default.NumWeapons;
	for (i=0; i<j; i++)
		if (Caps(class'TOModels.TO_WeaponsHandler'.default.WeaponStr[i]) == Caps(NewWeapons[Index].WeaponClass))
			return;
	// add weapon to the handler
	for (i=1; i<32; i++)
		if (class'TOModels.TO_WeaponsHandler'.default.WeaponStr[i] == "")
		{
			class'TOModels.TO_WeaponsHandler'.default.WeaponName[i] = NewWeapons[Index].WeaponName;
			class'TOModels.TO_WeaponsHandler'.default.WeaponStr[i] = NewWeapons[Index].WeaponClass;
			switch (NewWeapons[Index].WeaponTeams) {
				case 0 : class'TOModels.TO_WeaponsHandler'.default.WeaponTeam[i] = WT_None; break;
				case 1 : class'TOModels.TO_WeaponsHandler'.default.WeaponTeam[i] = WT_Terrorist; break;
				case 2 : class'TOModels.TO_WeaponsHandler'.default.WeaponTeam[i] = WT_SpecialForces; break;
				case 3 : class'TOModels.TO_WeaponsHandler'.default.WeaponTeam[i] = WT_Both; break;
			}
			class'TOModels.TO_WeaponsHandler'.default.BotDesirability[i] = NewWeapons[Index].BotDesirability;
			class'TOModels.TO_WeaponsHandler'.default.BuyMenuScale[i] = NewWeapons[Index].BuyMenuScale;
			class'TOModels.TO_WeaponsHandler'.default.NumWeapons = j+1;
			break;
		}
}

function	ReplaceDefWeapon()
{
	TO_GameBasics(Level.Game).DefTeamWeapon[0] = GameMods.TerrDefWeapon;
	TO_GameBasics(Level.Game).DefTeamWeapon[1] = GameMods.SwatDefWeapon;
}

function	OnPlayerConnect(PlayerPawn Player)
{
}

defaultproperties
{
	bHidden=true

    GameMods=(SniperSwimAimError=0.0,ZoomAimErrorMod=0.0,CrouchAimErrorMod=0.0,MoveAimErrorMod=0.0,SwimAimErrorMod=0.0,DmgRangeMod=0.0,TerrDefWeapon=none,SwatDefWeapon=none)

	Weapon(0)=(WeaponClass="",Teams=0,Price=0,RPM=0,Damage=0.0,MaxRange=0.0,AimError=0.0,HRecoil=0.0,VRecoil=0.0,ClipPrice=0,ClipSize=0,ClipMax=0,AltClipPrice=0,AltClipSize=0,AltClipMax=0,AltRPM=0,AltHRecoil=0.0,AltVRecoil=0.0,Weight=0.0)
	Weapon(1)=(WeaponClass="",Teams=0,Price=0,RPM=0,Damage=0.0,MaxRange=0.0,AimError=0.0,HRecoil=0.0,VRecoil=0.0,ClipPrice=0,ClipSize=0,ClipMax=0,AltClipPrice=0,AltClipSize=0,AltClipMax=0,AltRPM=0,AltHRecoil=0.0,AltVRecoil=0.0,Weight=0.0)
	Weapon(2)=(WeaponClass="",Teams=0,Price=0,RPM=0,Damage=0.0,MaxRange=0.0,AimError=0.0,HRecoil=0.0,VRecoil=0.0,ClipPrice=0,ClipSize=0,ClipMax=0,AltClipPrice=0,AltClipSize=0,AltClipMax=0,AltRPM=0,AltHRecoil=0.0,AltVRecoil=0.0,Weight=0.0)
	Weapon(3)=(WeaponClass="",Teams=0,Price=0,RPM=0,Damage=0.0,MaxRange=0.0,AimError=0.0,HRecoil=0.0,VRecoil=0.0,ClipPrice=0,ClipSize=0,ClipMax=0,AltClipPrice=0,AltClipSize=0,AltClipMax=0,AltRPM=0,AltHRecoil=0.0,AltVRecoil=0.0,Weight=0.0)
	Weapon(4)=(WeaponClass="",Teams=0,Price=0,RPM=0,Damage=0.0,MaxRange=0.0,AimError=0.0,HRecoil=0.0,VRecoil=0.0,ClipPrice=0,ClipSize=0,ClipMax=0,AltClipPrice=0,AltClipSize=0,AltClipMax=0,AltRPM=0,AltHRecoil=0.0,AltVRecoil=0.0,Weight=0.0)
	Weapon(5)=(WeaponClass="",Teams=0,Price=0,RPM=0,Damage=0.0,MaxRange=0.0,AimError=0.0,HRecoil=0.0,VRecoil=0.0,ClipPrice=0,ClipSize=0,ClipMax=0,AltClipPrice=0,AltClipSize=0,AltClipMax=0,AltRPM=0,AltHRecoil=0.0,AltVRecoil=0.0,Weight=0.0)
	Weapon(6)=(WeaponClass="",Teams=0,Price=0,RPM=0,Damage=0.0,MaxRange=0.0,AimError=0.0,HRecoil=0.0,VRecoil=0.0,ClipPrice=0,ClipSize=0,ClipMax=0,AltClipPrice=0,AltClipSize=0,AltClipMax=0,AltRPM=0,AltHRecoil=0.0,AltVRecoil=0.0,Weight=0.0)
	Weapon(7)=(WeaponClass="",Teams=0,Price=0,RPM=0,Damage=0.0,MaxRange=0.0,AimError=0.0,HRecoil=0.0,VRecoil=0.0,ClipPrice=0,ClipSize=0,ClipMax=0,AltClipPrice=0,AltClipSize=0,AltClipMax=0,AltRPM=0,AltHRecoil=0.0,AltVRecoil=0.0,Weight=0.0)
	Weapon(8)=(WeaponClass="",Teams=0,Price=0,RPM=0,Damage=0.0,MaxRange=0.0,AimError=0.0,HRecoil=0.0,VRecoil=0.0,ClipPrice=0,ClipSize=0,ClipMax=0,AltClipPrice=0,AltClipSize=0,AltClipMax=0,AltRPM=0,AltHRecoil=0.0,AltVRecoil=0.0,Weight=0.0)
	Weapon(9)=(WeaponClass="",Teams=0,Price=0,RPM=0,Damage=0.0,MaxRange=0.0,AimError=0.0,HRecoil=0.0,VRecoil=0.0,ClipPrice=0,ClipSize=0,ClipMax=0,AltClipPrice=0,AltClipSize=0,AltClipMax=0,AltRPM=0,AltHRecoil=0.0,AltVRecoil=0.0,Weight=0.0)
	Weapon(10)=(WeaponClass="",Teams=0,Price=0,RPM=0,Damage=0.0,MaxRange=0.0,AimError=0.0,HRecoil=0.0,VRecoil=0.0,ClipPrice=0,ClipSize=0,ClipMax=0,AltClipPrice=0,AltClipSize=0,AltClipMax=0,AltRPM=0,AltHRecoil=0.0,AltVRecoil=0.0,Weight=0.0)
	Weapon(11)=(WeaponClass="",Teams=0,Price=0,RPM=0,Damage=0.0,MaxRange=0.0,AimError=0.0,HRecoil=0.0,VRecoil=0.0,ClipPrice=0,ClipSize=0,ClipMax=0,AltClipPrice=0,AltClipSize=0,AltClipMax=0,AltRPM=0,AltHRecoil=0.0,AltVRecoil=0.0,Weight=0.0)
	Weapon(12)=(WeaponClass="",Teams=0,Price=0,RPM=0,Damage=0.0,MaxRange=0.0,AimError=0.0,HRecoil=0.0,VRecoil=0.0,ClipPrice=0,ClipSize=0,ClipMax=0,AltClipPrice=0,AltClipSize=0,AltClipMax=0,AltRPM=0,AltHRecoil=0.0,AltVRecoil=0.0,Weight=0.0)
	Weapon(13)=(WeaponClass="",Teams=0,Price=0,RPM=0,Damage=0.0,MaxRange=0.0,AimError=0.0,HRecoil=0.0,VRecoil=0.0,ClipPrice=0,ClipSize=0,ClipMax=0,AltClipPrice=0,AltClipSize=0,AltClipMax=0,AltRPM=0,AltHRecoil=0.0,AltVRecoil=0.0,Weight=0.0)
	Weapon(14)=(WeaponClass="",Teams=0,Price=0,RPM=0,Damage=0.0,MaxRange=0.0,AimError=0.0,HRecoil=0.0,VRecoil=0.0,ClipPrice=0,ClipSize=0,ClipMax=0,AltClipPrice=0,AltClipSize=0,AltClipMax=0,AltRPM=0,AltHRecoil=0.0,AltVRecoil=0.0,Weight=0.0)
	Weapon(15)=(WeaponClass="",Teams=0,Price=0,RPM=0,Damage=0.0,MaxRange=0.0,AimError=0.0,HRecoil=0.0,VRecoil=0.0,ClipPrice=0,ClipSize=0,ClipMax=0,AltClipPrice=0,AltClipSize=0,AltClipMax=0,AltRPM=0,AltHRecoil=0.0,AltVRecoil=0.0,Weight=0.0)
	Weapon(16)=(WeaponClass="",Teams=0,Price=0,RPM=0,Damage=0.0,MaxRange=0.0,AimError=0.0,HRecoil=0.0,VRecoil=0.0,ClipPrice=0,ClipSize=0,ClipMax=0,AltClipPrice=0,AltClipSize=0,AltClipMax=0,AltRPM=0,AltHRecoil=0.0,AltVRecoil=0.0,Weight=0.0)
	Weapon(17)=(WeaponClass="",Teams=0,Price=0,RPM=0,Damage=0.0,MaxRange=0.0,AimError=0.0,HRecoil=0.0,VRecoil=0.0,ClipPrice=0,ClipSize=0,ClipMax=0,AltClipPrice=0,AltClipSize=0,AltClipMax=0,AltRPM=0,AltHRecoil=0.0,AltVRecoil=0.0,Weight=0.0)
	Weapon(18)=(WeaponClass="",Teams=0,Price=0,RPM=0,Damage=0.0,MaxRange=0.0,AimError=0.0,HRecoil=0.0,VRecoil=0.0,ClipPrice=0,ClipSize=0,ClipMax=0,AltClipPrice=0,AltClipSize=0,AltClipMax=0,AltRPM=0,AltHRecoil=0.0,AltVRecoil=0.0,Weight=0.0)
	Weapon(19)=(WeaponClass="",Teams=0,Price=0,RPM=0,Damage=0.0,MaxRange=0.0,AimError=0.0,HRecoil=0.0,VRecoil=0.0,ClipPrice=0,ClipSize=0,ClipMax=0,AltClipPrice=0,AltClipSize=0,AltClipMax=0,AltRPM=0,AltHRecoil=0.0,AltVRecoil=0.0,Weight=0.0)
	Weapon(20)=(WeaponClass="",Teams=0,Price=0,RPM=0,Damage=0.0,MaxRange=0.0,AimError=0.0,HRecoil=0.0,VRecoil=0.0,ClipPrice=0,ClipSize=0,ClipMax=0,AltClipPrice=0,AltClipSize=0,AltClipMax=0,AltRPM=0,AltHRecoil=0.0,AltVRecoil=0.0,Weight=0.0)
	Weapon(21)=(WeaponClass="",Teams=0,Price=0,RPM=0,Damage=0.0,MaxRange=0.0,AimError=0.0,HRecoil=0.0,VRecoil=0.0,ClipPrice=0,ClipSize=0,ClipMax=0,AltClipPrice=0,AltClipSize=0,AltClipMax=0,AltRPM=0,AltHRecoil=0.0,AltVRecoil=0.0,Weight=0.0)
	Weapon(22)=(WeaponClass="",Teams=0,Price=0,RPM=0,Damage=0.0,MaxRange=0.0,AimError=0.0,HRecoil=0.0,VRecoil=0.0,ClipPrice=0,ClipSize=0,ClipMax=0,AltClipPrice=0,AltClipSize=0,AltClipMax=0,AltRPM=0,AltHRecoil=0.0,AltVRecoil=0.0,Weight=0.0)
	Weapon(23)=(WeaponClass="",Teams=0,Price=0,RPM=0,Damage=0.0,MaxRange=0.0,AimError=0.0,HRecoil=0.0,VRecoil=0.0,ClipPrice=0,ClipSize=0,ClipMax=0,AltClipPrice=0,AltClipSize=0,AltClipMax=0,AltRPM=0,AltHRecoil=0.0,AltVRecoil=0.0,Weight=0.0)
	Weapon(24)=(WeaponClass="",Teams=0,Price=0,RPM=0,Damage=0.0,MaxRange=0.0,AimError=0.0,HRecoil=0.0,VRecoil=0.0,ClipPrice=0,ClipSize=0,ClipMax=0,AltClipPrice=0,AltClipSize=0,AltClipMax=0,AltRPM=0,AltHRecoil=0.0,AltVRecoil=0.0,Weight=0.0)
	Weapon(25)=(WeaponClass="",Teams=0,Price=0,RPM=0,Damage=0.0,MaxRange=0.0,AimError=0.0,HRecoil=0.0,VRecoil=0.0,ClipPrice=0,ClipSize=0,ClipMax=0,AltClipPrice=0,AltClipSize=0,AltClipMax=0,AltRPM=0,AltHRecoil=0.0,AltVRecoil=0.0,Weight=0.0)
	Weapon(26)=(WeaponClass="",Teams=0,Price=0,RPM=0,Damage=0.0,MaxRange=0.0,AimError=0.0,HRecoil=0.0,VRecoil=0.0,ClipPrice=0,ClipSize=0,ClipMax=0,AltClipPrice=0,AltClipSize=0,AltClipMax=0,AltRPM=0,AltHRecoil=0.0,AltVRecoil=0.0,Weight=0.0)
	Weapon(27)=(WeaponClass="",Teams=0,Price=0,RPM=0,Damage=0.0,MaxRange=0.0,AimError=0.0,HRecoil=0.0,VRecoil=0.0,ClipPrice=0,ClipSize=0,ClipMax=0,AltClipPrice=0,AltClipSize=0,AltClipMax=0,AltRPM=0,AltHRecoil=0.0,AltVRecoil=0.0,Weight=0.0)
	Weapon(28)=(WeaponClass="",Teams=0,Price=0,RPM=0,Damage=0.0,MaxRange=0.0,AimError=0.0,HRecoil=0.0,VRecoil=0.0,ClipPrice=0,ClipSize=0,ClipMax=0,AltClipPrice=0,AltClipSize=0,AltClipMax=0,AltRPM=0,AltHRecoil=0.0,AltVRecoil=0.0,Weight=0.0)
	Weapon(29)=(WeaponClass="",Teams=0,Price=0,RPM=0,Damage=0.0,MaxRange=0.0,AimError=0.0,HRecoil=0.0,VRecoil=0.0,ClipPrice=0,ClipSize=0,ClipMax=0,AltClipPrice=0,AltClipSize=0,AltClipMax=0,AltRPM=0,AltHRecoil=0.0,AltVRecoil=0.0,Weight=0.0)
	Weapon(30)=(WeaponClass="",Teams=0,Price=0,RPM=0,Damage=0.0,MaxRange=0.0,AimError=0.0,HRecoil=0.0,VRecoil=0.0,ClipPrice=0,ClipSize=0,ClipMax=0,AltClipPrice=0,AltClipSize=0,AltClipMax=0,AltRPM=0,AltHRecoil=0.0,AltVRecoil=0.0,Weight=0.0)
	Weapon(31)=(WeaponClass="",Teams=0,Price=0,RPM=0,Damage=0.0,MaxRange=0.0,AimError=0.0,HRecoil=0.0,VRecoil=0.0,ClipPrice=0,ClipSize=0,ClipMax=0,AltClipPrice=0,AltClipSize=0,AltClipMax=0,AltRPM=0,AltHRecoil=0.0,AltVRecoil=0.0,Weight=0.0)

	NewWeapons(0)=(WeaponName="",WeaponClass="",BotDesirability=0.0,WeaponTeams=0,BuymenuScale=0.0)
	NewWeapons(1)=(WeaponName="",WeaponClass="",BotDesirability=0.0,WeaponTeams=0,BuymenuScale=0.0)
	NewWeapons(2)=(WeaponName="",WeaponClass="",BotDesirability=0.0,WeaponTeams=0,BuymenuScale=0.0)
	NewWeapons(3)=(WeaponName="",WeaponClass="",BotDesirability=0.0,WeaponTeams=0,BuymenuScale=0.0)
	NewWeapons(4)=(WeaponName="",WeaponClass="",BotDesirability=0.0,WeaponTeams=0,BuymenuScale=0.0)
	NewWeapons(5)=(WeaponName="",WeaponClass="",BotDesirability=0.0,WeaponTeams=0,BuymenuScale=0.0)
	NewWeapons(6)=(WeaponName="",WeaponClass="",BotDesirability=0.0,WeaponTeams=0,BuymenuScale=0.0)
	NewWeapons(7)=(WeaponName="",WeaponClass="",BotDesirability=0.0,WeaponTeams=0,BuymenuScale=0.0)
	NewWeapons(8)=(WeaponName="",WeaponClass="",BotDesirability=0.0,WeaponTeams=0,BuymenuScale=0.0)
	NewWeapons(9)=(WeaponName="",WeaponClass="",BotDesirability=0.0,WeaponTeams=0,BuymenuScale=0.0)
	NewWeapons(10)=(WeaponName="",WeaponClass="",BotDesirability=0.0,WeaponTeams=0,BuymenuScale=0.0)
	NewWeapons(11)=(WeaponName="",WeaponClass="",BotDesirability=0.0,WeaponTeams=0,BuymenuScale=0.0)
	NewWeapons(12)=(WeaponName="",WeaponClass="",BotDesirability=0.0,WeaponTeams=0,BuymenuScale=0.0)
	NewWeapons(13)=(WeaponName="",WeaponClass="",BotDesirability=0.0,WeaponTeams=0,BuymenuScale=0.0)
	NewWeapons(14)=(WeaponName="",WeaponClass="",BotDesirability=0.0,WeaponTeams=0,BuymenuScale=0.0)
	NewWeapons(15)=(WeaponName="",WeaponClass="",BotDesirability=0.0,WeaponTeams=0,BuymenuScale=0.0)
	NewWeapons(16)=(WeaponName="",WeaponClass="",BotDesirability=0.0,WeaponTeams=0,BuymenuScale=0.0)
	NewWeapons(17)=(WeaponName="",WeaponClass="",BotDesirability=0.0,WeaponTeams=0,BuymenuScale=0.0)
	NewWeapons(18)=(WeaponName="",WeaponClass="",BotDesirability=0.0,WeaponTeams=0,BuymenuScale=0.0)
	NewWeapons(19)=(WeaponName="",WeaponClass="",BotDesirability=0.0,WeaponTeams=0,BuymenuScale=0.0)
	NewWeapons(20)=(WeaponName="",WeaponClass="",BotDesirability=0.0,WeaponTeams=0,BuymenuScale=0.0)
	NewWeapons(21)=(WeaponName="",WeaponClass="",BotDesirability=0.0,WeaponTeams=0,BuymenuScale=0.0)
	NewWeapons(22)=(WeaponName="",WeaponClass="",BotDesirability=0.0,WeaponTeams=0,BuymenuScale=0.0)
	NewWeapons(23)=(WeaponName="",WeaponClass="",BotDesirability=0.0,WeaponTeams=0,BuymenuScale=0.0)
	NewWeapons(24)=(WeaponName="",WeaponClass="",BotDesirability=0.0,WeaponTeams=0,BuymenuScale=0.0)
	NewWeapons(25)=(WeaponName="",WeaponClass="",BotDesirability=0.0,WeaponTeams=0,BuymenuScale=0.0)
	NewWeapons(26)=(WeaponName="",WeaponClass="",BotDesirability=0.0,WeaponTeams=0,BuymenuScale=0.0)
	NewWeapons(27)=(WeaponName="",WeaponClass="",BotDesirability=0.0,WeaponTeams=0,BuymenuScale=0.0)
	NewWeapons(28)=(WeaponName="",WeaponClass="",BotDesirability=0.0,WeaponTeams=0,BuymenuScale=0.0)
	NewWeapons(29)=(WeaponName="",WeaponClass="",BotDesirability=0.0,WeaponTeams=0,BuymenuScale=0.0)
	NewWeapons(30)=(WeaponName="",WeaponClass="",BotDesirability=0.0,WeaponTeams=0,BuymenuScale=0.0)
	NewWeapons(31)=(WeaponName="",WeaponClass="",BotDesirability=0.0,WeaponTeams=0,BuymenuScale=0.0)
}
