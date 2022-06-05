class TOMAExtSettingsCW extends UMenuPageWindow;

var UWindowCheckbox BuyEveryWhere;
var localized string BuyEveryWhereText,BuyEveryWhereHelp;
var UWindowCheckbox SpawnRandom;
var localized string SpawnRandomText,SpawnRandomHelp;
var UWindowCheckbox RageMode;
var localized string RageModeText,RageModeHelp;
var UWindowCheckbox utsp;
var localized string utspText,utspHelp;
var UWindowCheckbox rp;
var localized string rpText,rpHelp;
var UWindowCheckbox newweapon;
var localized string newweaponText,newweaponHelp;
var bool Initialized;
var float ControlOffset;

function Created ()
{
	local int ControlWidth;
	local int ControlLeft;

	Super.Created();
	ControlWidth=WinWidth/1.5;
	ControlLeft=WinWidth/2-ControlWidth/2;
	ControlOffset += 20;
	BuyEveryWhere=UWindowCheckbox(CreateControl(Class'UWindowCheckbox',ControlLeft,ControlOffset,ControlWidth,1));
	BuyEveryWhere.SetText(BuyEveryWhereText);
	BuyEveryWhere.SetHelpText(BuyEveryWhereHelp);
	BuyEveryWhere.SetFont(0);
	BuyEveryWhere.Align=TA_Left;
	ControlOffset += 15;
	SpawnRandom=UWindowCheckbox(CreateControl(Class'UWindowCheckbox',ControlLeft,ControlOffset,ControlWidth,1));
	SpawnRandom.SetText(SpawnRandomText);
	SpawnRandom.SetHelpText(SpawnRandomHelp);
	SpawnRandom.SetFont(0);
	SpawnRandom.Align=TA_Left;
	ControlOffset += 15;
	RageMode=UWindowCheckbox(CreateControl(Class'UWindowCheckbox',ControlLeft,ControlOffset,ControlWidth,1));
	RageMode.SetText(RageModeText);
	RageMode.SetHelpText(RageModeHelp);
	RageMode.SetFont(0);
	RageMode.Align=TA_Left;
	ControlOffset += 15;
	utsp=UWindowCheckbox(CreateControl(Class'UWindowCheckbox',ControlLeft,ControlOffset,ControlWidth,1));
	utsp.SetText(utspText);
	utsp.SetHelpText(utspHelp);
	utsp.SetFont(0);
	utsp.Align=TA_Left;
	ControlOffset += 15;
	rp=UWindowCheckbox(CreateControl(Class'UWindowCheckbox',ControlLeft,ControlOffset,ControlWidth,1));
	rp.SetText(rpText);
	rp.SetHelpText(rpHelp);
	rp.SetFont(0);
	rp.Align=TA_Left;
	ControlOffset += 15;
	newweapon=UWindowCheckbox(CreateControl(Class'UWindowCheckbox',ControlLeft,ControlOffset,ControlWidth,1));
	newweapon.SetText(newweaponText);
	newweapon.SetHelpText(newweaponHelp);
	newweapon.SetFont(0);
	newweapon.Align=TA_Left;
	ControlOffset += 15;
}

function BeforePaint (Canvas C, float X, float Y)
{
	local int ControlWidth;
	local int ControlLeft;

	Super.BeforePaint(C,X,Y);

	ControlWidth=WinWidth/1.5;
	ControlLeft=WinWidth/2-ControlWidth/2;
	BuyEveryWhere.SetSize(ControlWidth,1);
	BuyEveryWhere.WinLeft=ControlLeft;
	SpawnRandom.SetSize(ControlWidth,1);
	SpawnRandom.WinLeft=ControlLeft;
	RageMode.SetSize(ControlWidth,1);
	RageMode.WinLeft=ControlLeft;
	utsp.SetSize(ControlWidth,1);
	utsp.WinLeft=ControlLeft;
	rp.SetSize(ControlWidth,1);
	rp.WinLeft=ControlLeft;
	newweapon.SetSize(ControlWidth,1);
	newweapon.WinLeft=ControlLeft;
}

function AfterCreate ()
{
	Super.AfterCreate();
	DesiredWidth=270;
	DesiredHeight=ControlOffset;
	LoadCurrentValues();
	Initialized=True;
}

function Notify (UWindowDialogControl C, byte E)
{
	if (!Initialized)
		return;
	Super.Notify(C,E);
	switch (E)
	{
		case 1:
		switch (C)
		{
			case BuyEverywhere:
                EnableBuyEverywhereChanged();
                break;
			case SpawnRandom:
                EnableSpawnRandomChanged();
                break;
			case RageMode:
                EnableRageModeChanged();
                break;
			case utsp:
                ChangeUtsp();
                break;
			case rp:
                ChangeRp();
                break;
			case newweapon:
                ChangeNewWeapon();
                break;
    		default:
                break;
		}
	}
}

function ChangeNewWeapon()
{
	Class'TOMAMod'.Default.EnableNewWeapons=newweapon.bChecked;
}

function Changerp()
{
	Class'TOMAMod'.Default.RespawnPlayer=rp.bChecked;
}

function Changeutsp()
{
	Class'TOMAMod'.Default.TerroristStartPoint=utsp.bChecked;
}

function EnableBuyEverywhereChanged()
{
	Class'TOMAMod'.Default.BuyEverywhere=BuyEverywhere.bChecked;
}

function EnableSpawnRandomChanged()
{
	Class'TOMAMod'.Default.RandomSpawn=SpawnRandom.bChecked;
}

function EnableRageModeChanged()
{
	Class'TOMAMod'.Default.RageMode=RageMode.bChecked;
}

function LoadCurrentValues ()
{
	BuyEverywhere.bChecked=Class'TOMAMod'.Default.BuyEverywhere;
	SpawnRandom.bChecked=Class'TOMAMod'.default.RandomSpawn;
	RageMode.bChecked=Class'TOMAMod'.default.RageMode;
	utsp.bChecked=Class'TOMAMod'.default.TerroristStartPoint;
	rp.bChecked=Class'TOMAMod'.default.RespawnPlayer;
	newweapon.bChecked=Class'TOMAMod'.default.EnableNewWeapons;
}

function SaveConfigs ()
{
	Super.SaveConfigs();
	class'TOMAMod'.StaticSaveConfig();
	GetPlayerOwner().SaveConfig();
}

defaultproperties
{
	BuyEveryWhereText="Buy everywhere in the map"
	BuyEveryWhereHelp="Let's players to buy anywhere in the map"
	SpawnRandomText="Spawn random"
	SpawnRandomHelp="Spawn some monsters randomly on the map too"
	RageModeText="RageMode"
	RageModeHelp="Enable/Disable RageMode, when you have 15HP left, you have norecoil, 255 ammo, run faster"
	utspText="Terrorists Start"
	utspHelp="Use terrorists start point for monsters, if not : randomly on the map"
	rpText="Respawn players"
	rpHelp="Respawn players after death (and after some seconds)"
	newWeapontext="New Weapons"
	newweaponhelp="Add new weapons like special grenades against monsters, Famas, OICW & Steyr Aug"
}

