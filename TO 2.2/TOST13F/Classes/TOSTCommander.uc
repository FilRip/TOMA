//----------------------------------------------------------------------------
// Project : TOST
// File    : TOSTCommander.uc
// Version : 1.2
// Author  : BugBunny
//----------------------------------------------------------------------------

class TOSTCommander expands Inventory;

var TOSTRI zzMaster;

replication
{
	// Things the server should send to the client.
	reliable if( bNetOwner && (Role==ROLE_Authority) )
		zzMaster;
}

exec simulated function TOSTInfo()
{
	zzMaster.zzTOSTInfo();
}

exec simulated function ShowTeamInfo()
{
	zzMaster.zzToggleTeamInfo();
}

exec simulated function ShowWeapon()
{
	zzMaster.zzToggleWeaponInfo();
}

exec simulated function ProtectSrv()
{
	zzMaster.zzProtectSrv();
}

exec simulated function KickTK()
{
	zzMaster.zzKickTK();
}

exec simulated function MkTeams()
{
	zzMaster.zzMkTeams();
}

exec simulated function XSay(coerce string s)
{
	zzMaster.zzXSay(s);
}

exec simulated function XTeamSay(coerce string s)
{
	zzMaster.zzXTeamSay(s);
}

exec simulated function XKick(coerce string s)
{
	zzMaster.zzXKick(s);
}

exec simulated function XPKick(int PID)
{
	zzMaster.zzXPKick(PID);
}

exec simulated function Echo(coerce string s)
{
	zzMaster.zzEcho(s);
}

defaultproperties
{
     Texture=None
}
