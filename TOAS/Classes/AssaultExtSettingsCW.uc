class AssaultExtSettingsCW extends UMenuPageWindow;

var UWindowEditControl supportlimit;
var UWindowEditControl sniperlimit;
var UWindowEditControl assaultlimit;
var UWindowEditControl buytimelimit;
var localized string supportlimitText,supportlimitHelp,sniperlimittext,sniperlimithelp,assaultlimittext,assaultlimithelp,buytimelimittext,buytimelimithelp;
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
	supportlimit=UWindowEditControl(CreateControl(Class'UWindowEditControl',ControlLeft,ControlOffset,ControlWidth,1));
	supportlimit.SetText(supportlimitText);
	supportlimit.SetHelpText(supportlimitHelp);
	supportlimit.SetFont(0);
	supportlimit.Align=TA_Left;
	ControlOffset+=15;
	sniperlimit=UWindowEditControl(CreateControl(class'UWindowEditControl',ControlLeft,ControlOffset,ControlWidth,1));
	sniperlimit.SetText(sniperlimittext);
	sniperlimit.SetHelpText(sniperlimithelp);
	sniperlimit.SetFont(0);
	sniperlimit.Align=TA_Left;
	sniperlimit.SetNumericOnly(true);
	ControlOffset+=15;
	assaultlimit=UWindowEditControl(CreateControl(class'UWindowEditControl',ControlLeft,ControlOffset,ControlWidth,1));
	assaultlimit.SetText(assaultlimittext);
	assaultlimit.SetHelpText(assaultlimithelp);
	assaultlimit.SetFont(0);
	assaultlimit.Align=TA_Left;
	assaultlimit.SetNumericOnly(true);
	ControlOffset+=15;
	buytimelimit=UWindowEditControl(CreateControl(Class'UWindowCheckbox',ControlLeft,ControlOffset,ControlWidth,1));
	buytimelimit.SetText(buytimelimitText);
	buytimelimit.SetHelpText(buytimelimitHelp);
	buytimelimit.SetFont(0);
	buytimelimit.Align=TA_Left;
	ControlOffset+=15;
}

function BeforePaint(Canvas C,float X,float Y)
{
	local int ControlWidth;
	local int ControlLeft;

	Super.BeforePaint(C,X,Y);

	ControlWidth=WinWidth/1.5;
	ControlLeft=WinWidth/2-ControlWidth/2;
	supportlimit.SetSize(ControlWidth,1);
	supportlimit.WinLeft=ControlLeft;
	sniperlimit.SetSize(ControlWidth,1);
	sniperlimit.WinLeft=ControlLeft;
	assaultlimit.SetSize(ControlWidth,1);
	assaultlimit.WinLeft=ControlLeft;
	buytimelimit.SetSize(ControlWidth,1);
	buytimelimit.WinLeft=ControlLeft;
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
			case supportlimit:
                ChangeSupportLimit();
                break;
			case sniperlimit:
                ChangeSniperLimit();
                break;
            case assaultlimit:
                ChangeAssaultLimit();
                break;
            case buytimelimit:
                ChangeBuyTimeLimit();
                break;
            default:
                break;
		}
	}
}

function ChangeSupportLimit()
{
    if (int(supportlimit.GetValue())<0) supportlimit.SetValue("0");
    if (supportlimit.GetValue()!="") class'AssaultMod'.default.LimitOfSupport=int(supportlimit.GetValue());
}

function ChangeSniperLimit()
{
    if (int(sniperlimit.GetValue())<0) sniperlimit.SetValue("0");
    if (sniperlimit.GetValue()!="") class'AssaultMod'.default.LimitOfSniper=int(sniperlimit.GetValue());
}

function ChangeAssaultLimit()
{
    if (int(assaultlimit.GetValue())<0) assaultlimit.SetValue("0");
    if (assaultlimit.GetValue()!="") class'AssaultMod'.default.LimitOfAssault=int(assaultlimit.GetValue());
}

function ChangeBuyTimeLimit()
{
    if (int(buytimelimit.GetValue())<0) buytimelimit.SetValue("0");
    if (buytimelimit.GetValue()!="") class'AssaultMod'.default.LimitBuyTime=int(buytimelimit.GetValue());
}


function LoadCurrentValues()
{
	supportlimit.SetValue(string(class'AssaultMod'.Default.LimitOfSupport));
	sniperlimit.SetValue(string(class'AssaultMod'.Default.LimitOfSniper));
	assaultlimit.SetValue(string(class'AssaultMod'.Default.LimitOfAssault));
	buytimelimit.SetValue(string(class'AssaultMod'.Default.LimitBuyTime));
}

function SaveConfigs()
{
	Super.SaveConfigs();
	class'AssaultMod'.StaticSaveConfig();
	GetPlayerOwner().SaveConfig();
}

defaultproperties
{
	supportlimitText="Support limit"
	supportlimitHelp="Maximum number of players of Support class for each team"
	sniperlimittext="Sniper limit"
	sniperlimithelp="Maximum number of players of Sniper class for each team"
	assaultlimittext="Assault limit"
	assaultlimithelp="Maximum number of players of Assault class for each team"
	buytimelimittext="Buy time limit"
	buytimelimithelp="Time, in second, during players can buy/sell/change inventory"
}
