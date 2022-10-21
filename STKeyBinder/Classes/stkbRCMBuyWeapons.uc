//-----------------------------------------------------------
//    RightClickMenu Buy Weapons
//-----------------------------------------------------------
//
// Tactical Ops - SuperTeam KeyBinder -
//
// Source code rights:
// Copyright (C) 2002 Andrew Jakobs
//-----------------------------------------------------------
class stkbRCMBuyWeapons expands stkbRightClickMenu;

var UWindowPulldownMenuItem pmi[24];

//------------------------------------------
//       Created (Override)
//------------------------------------------
function Created()
{
    Super.Created();

    pmi[0] =  AddMenuItemAlt("Flashbang grenade",               "s_kAmmoAuto 114 'Buy Flashbang Grenade", None);
    pmi[1] =  AddMenuItemAlt("Concussion grenade",              "s_kAmmoAuto 115 'Buy Concussion Grenade", None);
    pmi[2] =  AddMenuItemAlt("Smoke grenade",                   "s_kAmmoAuto 120 'Buy Smoke Grenade", None);
    pmi[3] =  AddMenuItemAlt("HE grenade",                      "s_kAmmoAuto 113 'Buy HE Grenade", None);
    AddMenuItem("-", None);
    pmi[4] =  AddMenuItemAlt("t   Glock",                       "s_kAmmoAuto 101 'Buy Glock", None);
    pmi[5] =  AddMenuItemAlt("s   Beretta 92F",                 "s_kAmmoAuto 119 'Buy Beretta", None);
    pmi[6] =  AddMenuItemAlt("t/s Black Hawk (Desert Eagle)",   "s_kAmmoAuto 102 'Buy Black Hawk", None);
    pmi[7] =  AddMenuItemAlt("s   Raging Cobra (Raging Bull)",  "s_kAmmoAuto 123 'Buy Raging Cobra", None);
    AddMenuItem("-", None);
    pmi[8] =  AddMenuItemAlt("t   UZI (Ingram mac10)",          "s_kAmmoAuto 103 'Buy UZI", None);
    pmi[9] =  AddMenuItemAlt("s   APII (HK SMGII)",             "s_kAmmoAuto 122 'Buy APII", None);
    pmi[10] = AddMenuItemAlt("t   HK MP5A2 (Navy)",             "s_kAmmoAuto 104 'Buy MP5A2", None);
    pmi[11] = AddMenuItemAlt("s   HK MP5 SD",                   "s_kAmmoAuto 118 'Buy MP5SD", None);
    pmi[12] = AddMenuItemAlt("t   MossBerg shotgun",            "s_kAmmoAuto 105 'Buy Mossberg Shotgun", None);
    pmi[13] = AddMenuItemAlt("s   BW SPS 12 (Spas 12 shotgun)", "s_kAmmoAuto 106 'Buy Spas Shotgun", None);
    pmi[14] = AddMenuItemAlt("t   AS 12 (Saiga)",               "s_kAmmoAuto 117 'Buy Saiga", None);
    AddMenuItem("-", None);
    pmi[15] = AddMenuItemAlt("t   AK47",                        "s_kAmmoAuto 107 'Buy AK-47", None);
    pmi[16] = AddMenuItemAlt("s   M4A1",                        "s_kAmmoAuto 109 'Buy M4A1", None);
    pmi[17] = AddMenuItemAlt("t/s M16 + Laserattachment",       "s_kAmmoAuto 110 'Buy M16", None);
    pmi[18] = AddMenuItemAlt("t/s SR 90 (MSG 90)",              "s_kAmmoAuto 112 'Buy SR 90", None);
    pmi[19] = AddMenuItemAlt("s   HK33 Rifle",                  "s_kAmmoAuto 111 'Buy HK 33", None);
    pmi[20] = AddMenuItemAlt("s   SW Commando (SG 551)",        "s_kAmmoAuto 108 'Buy SWCommando", None);
    pmi[21] = AddMenuItemAlt("s   Parker-Hale 85 sniperrifle",  "s_kAmmoAuto 116 'Buy Parker-Hale Sniper Rifle", None);
    pmi[22] = AddMenuItemAlt("t   M60",                         "s_kAmmoAuto 124 'Buy M60", None);
    pmi[23] = AddMenuItemAlt("s   M4A2m203",                    "s_kAmmoAuto 121 'Buy M4A2m203", None);
}

//------------------------------------------
//       ExecuteItem (Override)
//------------------------------------------
function ExecuteItem(UWindowPulldownMenuItem I)
{
    //If the AltValue is not empty, set the editbox with its value
    if(stkbPulldownMenuItem(I).AltValue != "")
        stkbDCWKeyBinder(OwnerWindow).InsertCommand(stkbPulldownMenuItem(I).AltValue);
    Super.ExecuteItem(I);
}

