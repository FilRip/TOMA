//----------------------------------------------------------------------------//
// Project : TOSTWeapons (Client)											  //
// File    : TOSTWeaponsCommander.uc										  //
// Version : 0.1															  //
// Version : 1.1	added DefaultSettings									  //
// Version : 1.2	added GasMask											  //
// Author  : H-Lotti														  //
//----------------------------------------------------------------------------//
class TOSTWeaponsCommander extends Inventory;

var TOSTWeaponsClient Connect;

simulated function tick(float delta)
{
	local TOSTWeaponsClient TWC;

	if ( Connect == none )
		foreach allactors(class'TOSTWeaponsClient',TWC)
			Connect = TWC;
}

exec simulated function ShowWeaponTab()
{
    ShowWeaponsTab();
}

exec simulated function ShowWeaponsTab()
{
    Connect.SendClientMessage(112,,,,"TOST WeaponsTab",false);
}

exec simulated function SetWeapon(int WID, int Team, int Free)
{
    SetWeapons(WID, Team, Free);
}

exec simulated function SetWeapons(int WID, int Team, int Free)
{
    Connect.SendMessage(552, WID, Team, Free);
    Connect.SendMessage(551, WID);
}

exec simulated function SetModeMap(int Number, string MapName)
{
	if ( (number < -1) || (number > 10) )
	{
		Connect.MasterTab.OwnerPlayerPawn.clientMessage("usage: SetMapMode <setting number>(default = -1) <MapName>");
		return;
	}
	Connect.SendMessage(556, number,,,MapName);
}

exec simulated function SetDefaultMode(int Number)
{
	if ( (number < -1) || (number > 10) )
	{
		Connect.MasterTab.OwnerPlayerPawn.clientMessage("usage: SetDefaultMapMode <setting number>(TOSTWeapons's default = -1)");
		return;
	}
	Connect.SendMessage(557, number);
}

exec simulated function GasMask()
{
	Connect.GasMask();
}

exec simulated function s_kammoOto(int code)
{
	Connect.keyBindBuy(code);
}

defaultproperties
{
	bHidden=True
}
