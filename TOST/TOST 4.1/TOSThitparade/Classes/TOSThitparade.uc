//----------------------------------------------------------------------------
// Project : TOSTPiece hitparade
// File    : TOSThitparade.uc
// Version : 1.0.1
// Author  : [BB]Stark <stark@bbclan.de>
// $LastChange: 21.07.2003 05:58:10$
//----------------------------------------------------------------------------
// Version	Changes
// 0.1		+ First Release
// 0.2		+ rewrote some code...
// 0.3		+ rewrote some code again
//			+ added a console command (togglehithud)
// 0.4      + fixed a major bug
// 0.5      + fixed hitzones
// 0.6      + added set/get-settings support
// 1.0.1      + some adjustments & fixes for TO340
//----------------------------------------------------------------------------
// 	MsgIdx	Details					Param6(PlayerPawn)   Param4(String)
//	250		HUD on/off toggle		Player
//  251     not used anymore (old most-dmg line)
//  252     most dmg Line           -                    Line
//----------------------------------------------------------------------------

class TOSThitparade expands TOSTPiece config;

var	config 	bool 							bEnable;
var	config 	bool 							bDmgOver100;
var config  bool                            Logging;
var 		bool 							bRoundStats;
var			GameReplicationInfo 			GRI;
var			TournamentGameReplicationInfo 	TGRI;
var			String 							wnames[250];
var			int 							mostDamage;
var			int 							mostFF;
var			Pawn							mostDamagePawn;
var			Pawn							mostFFPawn;
var			TOSThitparadeHUD				HUD;
var         string                          ExportLine;

struct hitstruct {
	var	Pawn	Player;
	var hitdata	hit;
};

var hitstruct hits[32];

// *** SETTINGS

function		GetSettings(TOSTPiece Sender)
{
	local int	Bits;

	Bits = 0;
	if (bEnable)
		Bits += 1;
	if (bDmgOver100)
		Bits += 2;

	Params.Param4 = String(Bits);
	SendAnswerMessage(Sender, 143);
}

function		SetSettings(TOSTPiece Sender, string Settings)
{
	local	int			i, j;
	local	string		s;

	s = Settings;
	if (s != "")
	{
		i = int(s);
        bEnable = ((i & 1) == 1);
		bDmgOver100 = ((i & 2) == 2);
	}
	SaveConfig();
}

// ** EVENT HANDLING

function 		EventPlayerConnect(Pawn Player)
{
	local	int		i;
	i = TOST.FindPlayerIndex(PlayerPawn(Player));
	if (i != -1)
	{
		hits[i].Player = Player;
		hits[i].hit = none;
		tLog("connect: "$Player.PlayerReplicationInfo.PlayerID$";"$Player.PlayerReplicationInfo.PlayerName);
	}

	super.EventPlayerConnect(Player);
}

function 		EventPlayerDisconnect(Pawn Player)
{
	local	int		i;

	i = TOST.FindPlayerIndex(PlayerPawn(Player));
	if (i != -1)
	{
		hits[i].Player = none;
		hits[i].hit = none;
		tLog("disconnect: "$Player.PlayerReplicationInfo.PlayerID$";"$Player.PlayerReplicationInfo.PlayerName);
	}

	super.EventPlayerDisconnect(Player);
}

function		EventInit()
{
	local int i;

	if (bEnable)
	{
		TGRI = TournamentGameReplicationInfo(Level.Game.GameReplicationInfo);

        // hotfix for double WeaponID 11 (DE and RagingBull) (=TO Bug)
        // (MadOnion|BZ) 50 ist frei
        class's_SWAT.TO_RagingBull'.default.WeaponID = 50;

		// register a client actor (HUD)
		Params.Param4="TOSTHitparade.TOSTHitparadeHUD";
		SendMessage(160);

		// register a client actor (Inventory)
		Params.Param4="TOSTHitparade.TOSThitparadeInv";
		SendMessage(164);
	}
	super.EventInit();
}

function		EventGamePeriodChanged(int GP)
{
	if (bEnable)
	{
    switch (GP)
	{
		case 0:
			// GP_PreRound
			PreRound();
			break;
		case 1:
			// GP_RoundPlaying
			RoundPlaying();
			break;
		case 2:
			// GP_PostRound
			PostRound();
			break;
		case 3:
			// GP_RoundRestarting
			PreRound();
			break;
		case 4:
			// GP_PostMatch, still TODO!
			break;
	}
    }
	super.EventGamePeriodChanged(GP);
}

function 	PreRound ()
{
	// reset collected hit data
	local int i;
	for (i=0; i<32; i++)
	{
	    hits[i].hit = None;
	}
	bRoundStats=false;
	ExportLine = "";
}

function	RoundPlaying ()
{
	// disable HUD
	Params.Param5 = false;
	BroadcastClientMessage(260);
}

function 	PostRound ()
{
	local Pawn P;

	calcHighScores();

	// reset HUD data
	BroadcastClientMessage(265);

	// calc new data
	for ( P=Level.PawnList; P != None; P=P.nextPawn ) {
		if (  P.IsA('s_Player') )
		{
			showStats(P);
		}
	}
	// enable HUD
	Params.Param1 = 0;
	Params.Param5 = true;
	BroadcastClientMessage(260);

	if (ExportLine!="")
	{
        Params.Param4 = ExportLine;
        SendMessage(252); // send most dmg Line to IRC Reporter
    }
}

function 		EventScoreKill(Pawn Killer, Pawn Other)
{
    if (Logging)
        tLog("kill: " $ Killer.PlayerReplicationInfo.PlayerID $ ";" $
                        getWeapon(Killer) $ ";" $
                        Other.PlayerReplicationInfo.PlayerID $ ";" $
                        getWeapon(Other)
                        );

	if (NextPiece != none)
		NextPiece.EventScoreKill(Killer, Other);
}

function 		EventTakeDamage( out int ActualDamage, Pawn Victim, Pawn InstigatedBy, out Vector HitLocation, out vector Momentum, name DamageType)
{
	local int 		i, j, PID, VID, WID, dest, dmg, FF, mirror, hossi, Backup, gun;
    local hitdata 	tmpHit;
    local vector    Hitheight;
    local PlayerReplicationInfo PRI;

    Backup = ActualDamage;

    if (bEnable)
    {
    PRI = InstigatedBy.PlayerReplicationInfo;

 	if (ActualDamage != 0 && Instigatedby.IsA('s_Player') &&
            (DamageType=='shot' ||
             DamageType=='stab' ||
             DamageType=='stabbed' ||
             DamageType=='Decapitated' ||
             DamageType=='Explosion' ||
             DamageType=='MirrorDamage')
        ) {

        dest = TOST.FindPlayerIndex(PlayerPawn(InstigatedBy));
	    PID = InstigatedBy.PlayerReplicationInfo.PlayerID;
	    VID = Victim.PlayerReplicationInfo.PlayerID;

	    // display damage values > 100 ?
	    if ((Victim.Health < ActualDamage) && !bDmgOver100) { ActualDamage = Victim.Health; }

	    // collect Weaponnames...
	    gun = GetWeaponID(InstigatedBy);
	    if (gun != -1) wnames[gun] = GetWeapon(InstigatedBy);

   	    if (DamageType == 'MirrorDamage') mirror = ActualDamage;
		else if (InstigatedBy.PlayerReplicationInfo.Team==Victim.PlayerReplicationInfo.Team) FF = ActualDamage;
	    else if (Victim.IsA('s_NPCHostage')) hossi = ActualDamage;
	    else dmg = ActualDamage;

	    if (DamageType=='shot' || DamageType=='stab') WID = GetWeaponID(InstigatedBy);
	    else if (DamageType=='Explosion') WID = 99;
	    else if (DamageType=='stabbed') WID = 98;
	    else if (DamageType=='Decapitated') WID = 97;

		Hitheight = Hitlocation-Victim.Location;
        //XLog ("Hitheight.Z:"@Hitheight.Z); //debug

        // add dmg entry to list:
		saveDmg (dest, PID, VID, WID, dmg, FF, mirror, hossi, DamageType, CheckHitPosition(Hitheight), (Victim.Health-ActualDamage <=0), Victim.PlayerReplicationInfo.PlayerName);

	    // show Stats when died
	    if ((Victim.Health - ActualDamage <= 0) && Victim.IsA('s_Player'))
	    {
			Params.Param6 = PlayerPawn(Victim);
            // reset the victim's HUD data
            SendClientMessage(265);
			// calc & show new stats
			showStats(Victim);
			Params.Param1 = 1;
			Params.Param5 = true;
			SendClientMessage(260);
		}

		ActualDamage = Backup;
	}

	}//bEnable

	// --
	if ( NextPiece != None )
		NextPiece.EventTakeDamage(ActualDamage, Victim, InstigatedBy, HitLocation, Momentum, DamageType);
}

// ** MESSAGE HANDLING

function bool	EventCheckClearance(TOSTPiece Sender, PlayerPawn Player, int MsgType, out int Allowed)
{
	local 	int 	i;
	local	bool	b;

	b =	super.EventCheckClearance(Sender, Player, MsgType, Allowed);

	// Allow 'toggleHitHUD' command
	if (MsgType == 250)
	{
		Allowed = 1;
		return true;
	}

	return b;
}


function	EventMessage(TOSTPiece Sender, int MsgIndex)
{
	switch (MsgIndex)
	{
		case BaseMessage+0 :	toggleHitHUD(Sender.Params.Param6);
								break;
		case 203 :				translateMessage(Sender);
								break;
		case 143 :	            GetSettings(Sender);
								break;
	}
	super.EventMessage(Sender, MsgIndex);
}

function	TranslateMessage(TOSTPiece Sender)
{
	switch (Sender.Params.Param1)
	{
		case BaseMessage+0 :	Sender.Params.Param4 = "toggleHitHUD - Turns the Hitparade-Display on/off";
								break;
		default : break;
	}
}

function	EventAnswerMessage(TOSTPiece Sender, int MsgIndex)
{
	switch (MsgIndex)
	{
		// SetSettings - report back error messages
		case 144 			:	SetSettings(Sender, Sender.Params.Param4);
								break;
	}
}

// - END Message Handling

function toggleHitHUD (PlayerPawn Player)
{
	Params.Param6 = Player;
	SendClientMessage(266);
}

function saveDmg (int dest, int PID, int VID, int WID, int dmg, int FF, int mirror, int hossi, name DamageType, int Hitzone, bool dead, string name )
{
	local hitdata Element, newhit;

	if (hits[dest].hit==none) {
		newhit = new (none) class'hitdata';
		newhit.set(VID, WID, dmg, FF, mirror, hossi, DamageType, Hitzone, dead, name);
		hits[dest].hit=newhit;
		return;
	}
	for (Element=hits[dest].hit; Element!=none; Element=Element.Next) {
		if (Element.VID == VID && Element.WID == WID) {
			Element.set(VID, WID, dmg, FF, mirror, hossi, DamageType, Hitzone, dead, name);
			return;
		}
	}
	newhit = new (none) class'hitdata';
	newhit.set(VID, WID, dmg, FF, mirror, hossi, DamageType, Hitzone, dead, name);
	hits[dest].hit.add(newhit);
}

function showStats (Pawn Player)
{
	local float 	skill;
	local int 		i, j;
	local int 		inTotal, inNades, inFF;
	local int 		outTotal, outNades, outFF, hossi;
	local int 		inHead, inBody, inLeg;
	local int 		outHead, outBody, outLeg;
	local float 	outHeadRate, outBodyRate, outLegRate;
	local float 	inHeadRate, inBodyRate, inLegRate;
	local string 	nick;
	local hitdata 	tmphit;

	i = TOST.FindPlayerIndex(PlayerPawn(Player));

	// VICTIMS
	Params.Param6 = PlayerPawn(Player);
	Params.Param4 = "*** VICTIMS ***";
	SendClientMessage(262);

	for (tmphit=hits[i].hit; tmphit!=none; tmphit=tmphit.Next) {
		if (FindPlayerByID(tmphit.VID)!=None) nick=FindPlayerByID(tmphit.VID).PlayerReplicationInfo.PlayerName;
		else nick=tmphit.lastname;

		Params.Param6 = PlayerPawn(Player);
		Params.Param4 = tmpHit.mkLine(nick, getWeaponName(tmphit.WID), (tmphit.FF>0) );
		SendClientMessage(262);

		outTotal+=tmphit.dmg;
		outFF+=tmphit.FF;
		hossi+=tmphit.hossi;
		outHead+=tmphit.zHead;
		outBody+=tmphit.zBody;
		outLeg+=tmphit.zLegs;
	}
	Params.Param6 = PlayerPawn(Player);
	Params.Param4 = " ";
	SendClientMessage(262);
	Params.Param6 = PlayerPawn(Player);
	Params.Param4 = "total: "$outTotal$" dmg ("$outFF$" FF)";
	SendClientMessage(262);

	// ATTACKERS
	Params.Param6 = PlayerPawn(Player);
	Params.Param4 = "*** ATTACKER ***";
	SendClientMessage(261);

	for (j=0; j<32; j++) {
		if (hits[j].Player != None)  {
			for (tmphit=hits[j].hit; tmphit!=none; tmphit=tmphit.Next) {
				if (tmphit.VID==Player.PlayerReplicationInfo.PlayerID) {
					if (hits[j].Player!=None) nick=hits[j].Player.PlayerReplicationInfo.PlayerName;
					else nick=tmphit.lastname;

					Params.Param6 = PlayerPawn(Player);
                    if (tmphit.mirror>0)
                        Params.Param4 = tmpHit.mkLine("FriendlyFire!", "MirrorDamage");
                    else
    					Params.Param4 = tmpHit.mkLine(nick, getWeaponName(tmphit.WID), (tmphit.FF>0) );
					SendClientMessage(261);

					inFF+=tmphit.FF;
					inTotal+=tmphit.dmg;
				}
				}
		}
	}
	Params.Param6 = PlayerPawn(Player);
	Params.Param4 = " ";
	SendClientMessage(261);
	Params.Param6 = PlayerPawn(Player);
	Params.Param4 = "total: "$inTotal$" dmg ("$inFF$" FF)";
	SendClientMessage(261);

	// STATS
	if (intotal+outtotal == 0) skill = 0.0;
	else skill = ( (float(outtotal)-float(outFF)-float(hossi) ) / (float(outtotal)+float(intotal)) ) * 100;

	if (outHead+outBody+outLeg>0) {
		outHeadRate = 100 * float(outHead) / (float(outHead)+float(outBody)+float(outLeg));
		outBodyRate = 100 * float(outBody) / (float(outHead)+float(outBody)+float(outLeg));
		outLegRate  = 100 * float(outLeg) / (float(outHead)+float(outBody)+float(outLeg));
	}

	Params.Param4 = "*** personal stats ***";
	Params.Param6 = PlayerPawn(Player);
	SendClientMessage(263);

	Params.Param4 = "efficiency (dmg): "$cutFloat(skill, 1)$" %";
	Params.Param6 = PlayerPawn(Player);
	SendClientMessage(263);

	if (outHead+outBody+outLeg>0)
	{
		Params.Param4 = "accuracy (head/body/leg): "$cutFloat(outHeadRate,1)@"/"@cutFloat(outBodyRate,1)@"/"@cutFloat(outLegRate,1)@"%";
		Params.Param6 = PlayerPawn(Player);
		SendClientMessage(263);
	}

	if (bRoundStats) {
		Params.Param4 = "*** round stats ***";
		Params.Param6 = PlayerPawn(Player);
		SendClientMessage(264);
        ExportLine = "";

		if (mostDamagePawn != None)	{
			Params.Param4 = "best fragger was "$mostDamagePawn.PlayerReplicationInfo.PlayerName$" ("$mostDamage$" dmg)";
			ExportLine = mostDamagePawn.PlayerReplicationInfo.PlayerID $ ";" $ mostDamage $ ";";
            Params.Param6 = PlayerPawn(Player);
			SendClientMessage(264);
		} else { exportline = "0;0;"; }
		if (mostFFPawn != None) {
			Params.Param4 = mostFFPawn.PlayerReplicationInfo.PlayerName$" did "$mostFF$" damage to his own team...";
			ExportLine = ExportLine $ mostFFPawn.PlayerReplicationInfo.PlayerID $ ";" $ mostFF;
			Params.Param6 = PlayerPawn(Player);
			SendClientMessage(264);
		} else { exportline = exportline $ "0;0"; }
	}

}

function calcHighScores ()
{
	local int 		j, tmpDmg, tmpKill, tmpFF;
	local hitdata 	tmphit;
	local string    logline;

	mostDamage = 0;
	mostDamagePawn = None;
	mostFF = 0;
	mostFFPawn = None;
	logline = "";

	for (j=0; j<32; j++) {
		if (hits[j].Player != None)  {
			tmpDmg=0;
			tmpFF=0;
			for (tmphit=hits[j].hit; tmphit!=none; tmphit=tmphit.Next) {
				tmpDmg+=tmphit.dmg;
				//tmpDmg-=tmphit.FF;
				if (tmpDmg>mostDamage) {
					mostDamage=tmpDmg;
					mostDamagePawn=hits[j].Player;
				}
				tmpFF+=tmphit.FF;
				if (tmpFF>mostFF) {
					mostFF=tmpFF;
					mostFFPawn=hits[j].Player;
				}
			}
			logline = logline $ j $ ":" $ tmpDmg $ "/" $ tmpFF $ ";";
		}
	}
	bRoundStats=true;
	tLog("rounddmg: " $ logline);
}


// tiny HELPERS:

function string GetWeapon(pawn Player)
{
	if (Player.Weapon.ItemName != "") return " "$Player.Weapon.ItemName;
	else return " unknown";
}

function string GetWeaponName(int id) {
	if (id==99) return "Nade";
	else if (id==98) return " Thrown Knife";
	else if (id==97) return " Combatknife";
	else if (id==-1) return " unknown";
    else return wnames[id];
}

function int GetWeaponID(pawn Player)
{
	local s_Weapon w;
	if (Player.IsA('s_Player'))
        w = s_Weapon(Player.Weapon);

	if(w != none && w.WeaponID != 0)
        return w.WeaponID;
    else
        return -1;
}

function int CheckHitPosition( Vector HitLocation )
{
	if (HitLocation.Z > 28) // Head damage
	{
		return 2;
	}
	else if (HitLocation.Z > 0) // body
	{
		return 1;
	}
	else // legs
	{
		return 0;
	}
}


function string cutFloat (float in, int num) {
	local string s;

	s = string(in);
	return Mid(s, 0, Len(s)-6+num);
}

function tLog (string msg)
{
    if (Logging)
        TOST.TOSTLog(PieceName $ msg);
}

defaultproperties
{
	bHidden=true
	bEnable=true
	ServerOnly=false
	PieceName="TOST HitParade"
	PieceVersion="1.0.1.0"
	BaseMessage=250
	bDmgOver100=False
    Logging=False
}
