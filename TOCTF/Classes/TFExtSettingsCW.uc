class TFExtSettingsCW extends UMenuPageWindow;

var UWindowEditControl nbflag;
var UWindowEditControl amount;
var UWindowCheckbox doglow;
var UWindowCheckbox timeannouncer;
var UWindowCheckbox godeffect;
var UWindowCheckbox removecarcass;
var UWindowEditControl secgod;
var localized string nbflagtext,nbflaghelp,amounttext,amounthelp,doglowtext,doglowhelp,timeannouncertext,timeannouncerhelp,godeffecttext,godeffecthelp,secgodtext,secgodhelp,removecarcasstext,removecarcasshelp;
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
	nbflag=UWindowEditControl(CreateControl(class'UWindowEditControl',ControlLeft,ControlOffset,ControlWidth,1));
	nbflag.SetText(nbflagtext);
	nbflag.SetHelpText(nbflaghelp);
	Nbflag.SetFont(0);
	NbFlag.Align=TA_Left;
	NbFlag.SetNumericOnly(true);
	ControlOffset+=15;
	amount=UWindowEditControl(CreateControl(class'UWindowEditControl',ControlLeft,ControlOffset,ControlWidth,1));
	amount.SetText(amounttext);
	amount.SetHelpText(amounthelp);
	amount.SetFont(0);
	amount.Align=TA_Left;
	amount.SetNumericOnly(true);
	ControlOffset+=15;
	timeannouncer=UWindowCheckbox(CreateControl(Class'UWindowCheckbox',ControlLeft,ControlOffset,ControlWidth,1));
	timeannouncer.SetText(timeannouncerText);
	timeannouncer.SetHelpText(timeannouncerHelp);
	timeannouncer.SetFont(0);
	timeannouncer.Align=TA_Left;
	ControlOffset+=15;
	doglow=UWindowCheckbox(CreateControl(Class'UWindowCheckbox',ControlLeft,ControlOffset,ControlWidth,1));
	doglow.SetText(doglowText);
	doglow.SetHelpText(doglowHelp);
	doglow.SetFont(0);
	doglow.Align=TA_Left;
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
	nbflag.SetSize(ControlWidth,1);
	nbflag.WinLeft=ControlLeft;
	amount.SetSize(ControlWidth,1);
	amount.WinLeft=ControlLeft;
	timeannouncer.SetSize(ControlWidth,1);
	timeannouncer.WinLeft=ControlLeft;
	doglow.SetSize(ControlWidth,1);
	doglow.WinLeft=ControlLeft;
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
	switch (E)
	{
		case 1:
		switch (C)
		{
			case nbflag:
                ChangeNbFlag();
                break;
            case amount:
                ChangeAmount();
                break;
            case timeannouncer:
                ChangeAnnouncerTime();
                break;
            case doglow:
                ChangeDoGlow();
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
	Class'TFMod'.Default.bRemoveCarcass=removecarcass.bChecked;
}

function ChangeDoGlow()
{
	Class'TFMod'.Default.DoGlowOnFlagCarrier=DoGlow.bChecked;
}

function ChangeAnnouncerTime()
{
	Class'TFMod'.Default.bPlayTimeAnnouncer=timeannouncer.bChecked;
}

function ChangeGodEffect()
{
	Class'TFMod'.Default.bShowEffectInvulnerable=GodEffect.bChecked;
}

function ChangeSecGod()
{
    if (int(SecGod.GetValue())<0) SecGod.SetValue("0");
    if (SecGod.GetValue()!="") class'TFMod'.default.SecGodMod=int(SecGod.GetValue());
}

function ChangeNbFlag()
{
    if (int(NbFlag.GetValue())<0) NbFlag.SetValue("0");
    if (nbflag.GetValue()!="") class'TFMod'.default.ScorePerRound=int(nbflag.GetValue());
}

function ChangeAmount()
{
    if (int(Amount.GetValue())>20000) Amount.SetValue("20000");
    if (Amount.GetValue()!="") class'TFMod'.default.AmountForFlagScore=int(Amount.GetValue());
}


function LoadCurrentValues()
{
	nbflag.SetValue(string(class'TFMod'.Default.ScorePerRound));
	Amount.SetValue(string(class'TFMod'.Default.AmountForFlagScore));
	timeannouncer.bChecked=class'TFMod'.Default.bPlayTimeAnnouncer;
	doGlow.bChecked=class'TFMod'.Default.DoGlowOnFlagCarrier;
	godeffect.bChecked=class'TFMod'.Default.bShowEffectInvulnerable;
	secgod.SetValue(string(class'TFMod'.Default.SecGodMod));
	removecarcass.bChecked=class'TFMod'.Default.bRemoveCarcass;
}

function SaveConfigs()
{
	Super.SaveConfigs();
	class'TFMod'.StaticSaveConfig();
	GetPlayerOwner().SaveConfig();
}

defaultproperties
{
	nbflagtext="Score per round"
	nbflaghelp="Number of flag score to reach the round"
	amounttext="Amount for flag score"
	amounthelp="Amount give to flag carrier per flag score"
	timeannouncertext="Play time announcer"
	timeannouncerhelp="Announcer play the map time remaining"
	doglowtext="Do glow on flag carrier"
	doglowhelp="Do, around the flag carrier, a light with color of the flag"
	godeffecttext="Effect on 'God' player"
	godeffecthelp="Do an effect around the player that is in 'God' state"
	secgodtext="Seconds of 'God' state"
	secgodhelp="Seconds of 'God' state for players that have just spawned (invulnerable, and can't fire)"
	removecarcasstext="Remove carcass"
	removecarcasshelp="Remove the carcass of a player from the map when he is respawned"
}
