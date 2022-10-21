//----------------------------------------------------------------------------
// Project : TOSTPiece hitparade
// File    : hitdata.uc
// Version : 0.1
// Author  : Stark
//----------------------------------------------------------------------------
// Version	Changes
// 0.1		+ First Release
//          + added "stabbed" for thrown Knifes
//----------------------------------------------------------------------------

class hitdata expands Object;

//linked list:
var hitdata NEXT;

//keys:
var int VID;				// Victim ID
var int WID;				// Weapon ID
//--

var int count;
var int dmg;
var int FF;
var int mirror;
var int hossi;
var int zHead;
var int zBody;
var int zLegs;
var int numKilled;
var int numKilled_TK;
var string lastname; // name-cache...


//=============================================================================
// functions
//=============================================================================

function add (hitdata NewElement)
{
  If (Next!=None)
  	Next.add(NewElement);
  Else
    Next=NewElement;
}

function set (int _VID, int _WID, int _dmg, int _FF, int _mirror,  int _hossi, name DamageType, int HitLocation, bool dead, string _lastname) {
	VID=_VID;
	WID=_WID;
	count++;
	dmg+=_dmg;
	FF+=_FF;
	mirror+=_mirror;
	hossi+=_hossi;

	if (DamageType=='shot' || DamageType=='stab' || DamageType=='stabbed') {
		switch (HitLocation) {
			case 0: zLegs++; break;
			case 1: zBody++; break;
			case 2: zHead++; break;
		}
	}
	if (dead) numKilled++;
	if (FF>0 && dead) numKilled_TK++;
	lastname=_lastname;
}

function string mkLine (string name, string weapon, optional bool bFF) {
	local string toSend, tmp;

	toSend="";
	tmp="";

	if (bFF)
    {
        toSend=toSend$"(TK!) ";
        toSend=toSend$name$": "$FF+mirror$" dmg ";
    }
    else
	   toSend=toSend$name$": "$dmg+hossi$" dmg ";

	if (zHead+zBody+zLegs > 0)
	{
		if (zHead>0) tmp=tmp$zHead$"H ";
		if (zBody>0)	tmp=tmp$zBody$"B ";
		if (zLegs>0) tmp=tmp$zLegs$"L ";
		tmp=Trim(tmp);
		tosend=tosend$"("$tmp$")";
	}
	toSend=toSend$weapon;
	if (numKilled>0) toSend=toSend$" [killed]";

	return toSend;
}

// helpers, again thx to Unreal Wiki ;-)
static final function string LTrim(coerce string S)
{
    while (Left(S, 1) == " ")
        S = Right(S, Len(S) - 1);
    return S;
}

static final function string RTrim(coerce string S)
{
    while (Right(S, 1) == " ")
        S = Left(S, Len(S) - 1);
    return S;
}

static final function string Trim(coerce string S)
{
    return LTrim(RTrim(S));
}
