class TMExtSettingsCW extends UMenuPageWindow;

var UWindowCheckbox godeffect;
var UWindowCheckbox keepweapon;
var UWindowCheckbox announcetime;
var UWindowEditControl secgod;
var UWindowEditControl nbfrag;
var UWindowEditControl amount;
var UWindowCheckbox removecarcass;
var localized string keepweaponText,keepweaponHelp,nbfragtext,nbfraghelp,amounttext,amounthelp,announcetimetext,announcetimehelp,godeffecttext,godeffecthelp,secgodtext,secgodhelp,removecarcasstext,removecarcasshelp;
var bool Initialized;
var float ControlOffset;

function Created()
{
	local int ControlWidth;
	local int ControlLeft;

	Super.Created();
	ControlWidth=WinWidth/1.5;
	ControlLeft=WinWidth/2-ControlWidth/2;
	ControlOffset+=20;
	keepweapon=UWindowCheckbox(CreateControl(Class'UWindowCheckbox',ControlLeft,ControlOffset,ControlWidth,1));
	keepweapon.SetText(keepweaponText);
	keepweapon.SetHelpText(keepweaponHelp);
	keepweapon.SetFont(0);
	keepweapon.Align=TA_Left;
	ControlOffset+=15;
	nbfrag=UWindowEditControl(CreateControl(class'UWindowEditControl',ControlLeft,ControlOffset,ControlWidth,1));
	nbfrag.SetText(nbfragtext);
	nbfrag.SetHelpText(nbfraghelp);
	Nbfrag.SetFont(0);
	NbFrag.Align=TA_Left;
	NbFrag.SetNumericOnly(true);
	ControlOffset+=15;
	amount=UWindowEditControl(CreateControl(class'UWindowEditControl',ControlLeft,ControlOffset,ControlWidth,1));
	amount.SetText(amounttext);
	amount.SetHelpText(amounthelp);
	amount.SetFont(0);
	amount.Align=TA_Left;
	amount.SetNumericOnly(true);
	ControlOffset+=15;
	announcetime=UWindowCheckbox(CreateControl(Class'UWindowCheckbox',ControlLeft,ControlOffset,ControlWidth,1));
	announcetime.SetText(announcetimeText);
	announcetime.SetHelpText(announcetimeHelp);
	announcetime.SetFont(0);
	announcetime.Align=TA_Left;
	ControlOffset+=15;
	godeffect=UWindowCheckbox(CreateControl(Class'UWindowCheckbox',ControlLeft,ControlOffset,ControlWidth,1));
	godeffect.SetText(godeffectText);
	godeffect.SetHelpText(godeffectHelp);
	godeffect.SetFont(0);
	godeffect.Align=TA_Left;
	ControlOffset+=15;
	secgod=UWindowEditControl(CreateControl(class'UWindowEditControl',ControlLeft,ControlOffset,ControlWidth,1));
	secgod.SetText(secgodtext);
	secgod.SetHelpText(secgodhelp);
	secgod.SetFont(0);
	secgod.Align=TA_Left;
	secgod.SetNumericOnly(true);
	ControlOffset+=15;
	removecarcass=UWindowCheckbox(CreateControl(Class'UWindowCheckbox',ControlLeft,ControlOffset,ControlWidth,1));
	removecarcass.SetText(removecarcassText);
	removecarcass.SetHelpText(removecarcassHelp);
	removecarcass.SetFont(0);
	removecarcass.Align=TA_Left;
	ControlOffset+=15;
}

function BeforePaint(Canvas C,float X,float Y)
{
	local int ControlWidth;
	local int ControlLeft;

	Super.BeforePaint(C,X,Y);

	ControlWidth=WinWidth/1.5;
	ControlLeft=WinWidth/2-ControlWidth/2;
	keepweapon.SetSize(ControlWidth,1);
	keepweapon.WinLeft=ControlLeft;
	nbfrag.SetSize(ControlWidth,1);
	nbfrag.WinLeft=ControlLeft;
	amount.SetSize(ControlWidth,1);
	amount.WinLeft=ControlLeft;
	announcetime.SetSize(ControlWidth,1);
	announcetime.WinLeft=ControlLeft;
	godeffect.SetSize(ControlWidth,1);
	godeffect.WinLeft=ControlLeft;
	secgod.SetSize(ControlWidth,1);
	secgod.WinLeft=ControlLeft;
	removecarcass.SetSize(ControlWidth,1);
	removecarcass.WinLeft=ControlLeft;
}

function AfterCreate()
{
	Super.AfterCreate();
	DesiredWidth=270;
	DesiredHeight=ControlOffset;
	LoadCurrentValues();
	Initialized=True;
}

function Notify(UWindowDialogControl C,byte E)
{
	if (!Initialized)
		return;
	Super.Notify(C,E);
	switch(E)
	{
		case 1:
		switch (C)
		{
			case keepweapon:
                EnablekeepweaponChanged();
                break;
			case nbfrag:
                ChangeNbFrag();
                break;
            case amount:
                ChangeAmount();
                break;
            case announcetime:
                ChangeAnnounceTime();
                break;
            case godeffect:
                ChangeGodEffect();
                break;
            case secgod:
                ChangeSecGod();
                break;
            case removecarcass:
                Changeremovecarcass();
                break;
            default:
                break;
		}
	}
}

function ChangeRemoveCarcass()
{
	Class'TMMod'.Default.bRemoveCarcass=removecarcass.bChecked;
}

function EnablekeepweaponChanged()
{
	Class'TMMod'.Default.bKeepInventory=keepweapon.bChecked;
}

function ChangeGodEffect()
{
	Class'TMMod'.Default.bShowEffectInvulnerable=GodEffect.bChecked;
}

function ChangeAnnounceTime()
{
	Class'TMMod'.Default.bPlayTimeAnnouncer=announcetime.bChecked;
}

function ChangeSecGod()
{
    if (int(secgod.GetValue())<0) secgod.SetValue("0");
    if (secgod.GetValue()!="") class'TMMod'.default.SecGodMod=int(secgod.GetValue());
}

function ChangeNbFrag()
{
    if (int(NbFrag.GetValue())<0) NbFrag.SetValue("0");
    if (nbfrag.GetValue()!="") class'TMMod'.default.ScorePerRound=int(nbfrag.GetValue());
}

function ChangeAmount()
{
    if (int(Amount.GetValue())>20000) Amount.SetValue("20000");
    if (Amount.GetValue()!="") class'TMMod'.default.AmountForFrag=int(Amount.GetValue());
}


function LoadCurrentValues()
{
	keepweapon.bChecked=Class'TMMod'.Default.bKeepInventory;
	nbfrag.SetValue(string(class'TMMod'.Default.ScorePerRound));
	Amount.SetValue(string(class'TMMod'.Default.AmountForFrag));
	announcetime.bChecked=class'TMMod'.Default.bPlayTimeAnnouncer;
	godeffect.bChecked=class'TMMod'.Default.bShowEffectInvulnerable;
	secgod.SetValue(string(class'TMMod'.Default.SecGodMod));
	removecarcass.bChecked=class'TMMod'.Default.bRemoveCarcass;
}

function SaveConfigs()
{
	Super.SaveConfigs();
	class'TMMod'.StaticSaveConfig();
	GetPlayerOwner().SaveConfig();
}

defaultproperties
{
	keepweaponText="Keep weapons when die"
	keepweaponHelp="Keep weapons in inventory of dead players"
	nbfragtext="Score per round"
	nbfraghelp="Number of kill to reach the round"
	amounttext="Amount for kill"
	amounthelp="Amount give to killer per kill"
	announcetimetext="Time Announcer"
	announcetimehelp="The Announcer say how many time left before map change"
	godeffecttext="Show effect on invulnerable player"
	godeffecthelp="Show an effect around the player who is in 'God' state"
	secgodtext="Seconds of 'God' mod"
	secgodhelp="Seconds of duration of the 'God' state for players"
	removecarcasstext="Remove carcass"
	removecarcasshelp="Remove the carcass of a player from the map when he is respawned"
}
