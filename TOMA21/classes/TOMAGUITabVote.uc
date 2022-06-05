class TOMAGUITabVote extends TO_GUIBaseTab;

var TO_GUIBaseButton ButtonVote,ButtonCancel,ButtonSkipM;
var TO_GUITextListBox ListMonsters;
var localized string TextListMonsters;
var bool bInitialized;
var localized string TextTitle,TextCancel,TextVote,TextSkipM;
var byte CurFirstMonster;
var TO_GUIBaseButton mm,lm;

simulated function TOMAVoteR RetourneVoteR()
{
    local TOMAVoteR search;

    if (OwnerPlayer==None) return none;
    foreach OwnerPlayer.AllActors(class'TOMAVoteR',search)
        return search;
}

simulated function OwnerTimer ()
{
    if (RetourneVoteR()==None) return;

    if (ListMonsters!=None) UpdateListMonsters();
    if (ButtonSkipM!=None)
        ButtonSkipM.Text=TextSkipM$"  "$string(RetourneVoteR().VoteS)$" vote(s)";
}

simulated function Created ()
{
	Super.Created();
	Title=TextTitle;

	ListMonsters=TO_GUITextListBox(CreateWindow(class'TO_GUITextListBox', 0, 0, WinWidth, WinHeight));
	ListMonsters.Label=TextListMonsters;
	ListMonsters.OwnerTab = self;
	ListMonsters.bMultiselect=false;

	ButtonVote=TO_GUIBaseButton(CreateWindow(class'TO_GUIBaseButton',0,0,WinWidth,WinHeight));
	ButtonVote.Text=TextVote;
	ButtonVote.OwnerTab=self;

	ButtonSkipM=TO_GUIBaseButton(CreateWindow(class'TO_GUIBaseButton',0,0,WinWidth,WinHeight));
	ButtonSkipM.Text=TextSkipM;
	ButtonSkipM.OwnerTab=self;

	ButtonCancel=TO_GUIBaseButton(CreateWindow(class'TO_GUIBaseButton',0,0,WinWidth,WinHeight));
	ButtonCancel.Text=TextCancel;
	ButtonCancel.OwnerTab=self;

	mm=TO_GUIBaseButton(CreateWindow(class'TO_GUIBaseButton',0,0,WinWidth,WinHeight));
	mm.Text="+";
	mm.OwnerTab=self;
	lm=TO_GUIBaseButton(CreateWindow(class'TO_GUIBaseButton',0,0,WinWidth,WinHeight));
	lm.Text="-";
	lm.OwnerTab=self;

    CurFirstMonster=1;
}

simulated function Close (optional bool bByParent)
{
	ButtonVote.Close();
	ButtonCancel.Close();
	ButtonSkipM.Close();
	ListMonsters.Close();
	mm.Close();
	lm.Close();
	Super.Close(bByParent);
}

simulated function BeforePaint (Canvas Canvas, float x, float y)
{
    Super.BeforePaint(Canvas, x, y);
    if (!bInitialized)
    {
        UpdateListMonsters();
        if (TOMAPlayer(OwnerPlayer).myvote>0) ListMonsters.SelectedIndex=TOMAPlayer(OwnerPlayer).myvote;
        Setup(Canvas);
        bInitialized=True;
	}
}

function string RetourneNomPos(string fullline,byte position)
{
	local string retour,tempchaine;
	local byte i;

	if (position>RetourneNbNom(fullline)) retour="";
	if (position==1)
	{
		if (RetourneNbNom(fullline)==1) retour=fullline;
		else
			retour=OwnerPlayer.left(fullline,instr(fullline,","));
	}
	else
	{
		i=1;
		tempchaine=fullline;
debut:
		if (instr(tempchaine,",")>0)
		{
			i++;
			tempchaine=OwnerPlayer.right(tempchaine,len(tempchaine)-instr(tempchaine,",")-1);
			if (i==position)
			{
				if (instr(tempchaine,",")>0) retour=OwnerPlayer.left(tempchaine,instr(tempchaine,",")); else retour=tempchaine;
			}
			else goto Debut;
		} else
		{
			retour=tempchaine;
		}
	}
	return retour;
}

// return number of string in a BIG string (strings separated by comma)
function int RetourneNbNom(string fullline)
{
	local byte retour;
	local string tempchaine;

	retour=0;
	tempchaine=fullline;
debut:
	if (instr(tempchaine,",")>0)
	{
		tempchaine=OwnerPlayer.right(tempchaine,len(tempchaine)-instr(tempchaine,",")-1);
		retour++;
		goto debut;
	}
	if (len(retour)>0) retour++;
	return retour;
}

simulated function UpdateListMonsters()
{
    local byte i,ls;
    local byte lastone;
    local string fs;

    ls=ListMonsters.SelectedIndex;
    ListMonsters.Clear();
    lastone=CurFirstMonster+16;
    if (lastone>RetourneNbNom(class'TOMAMod'.default.MonstersForVote)) lastone=RetourneNbNom(class'TOMAMod'.default.MonstersForVote);
    for(i=CurFirstMonster;i<lastone+1;i++)
    {
        fs=RetourneNomPos(class'TOMAMod'.default.MonstersForVote,i);
        if (RetourneVoteR()!=None) fs=fs$" "$RetourneVoteR().VoteM[i]$" vote(s)"; else log("Hum, po glop, po de TOMAVoteR");
        if (ls==i-CurFirstMonster) ListMonsters.AddItem(fs,"",i,true); else ListMonsters.AddItem(fs,"",i,false);
    }
}

simulated function Notify (UWindowDialogControl control, byte event)
{
    if (event==DE_Click)
    {
        switch (control)
        {
            case mm:
                if (CurFirstMonster<RetourneNbNom(class'TOMAMod'.default.MonstersForVote)-15)
                {
                    CurFirstMonster++;
                    ListMonsters.SelectedIndex--;
                    UpdateListMonsters();
                }
                break;
            case lm:
                if (CurFirstMonster>1)
                {
                    CurFirstMonster--;
                    ListMonsters.SelectedIndex++;
                    UpdateListMonsters();
                }
                break;
            case ButtonCancel:
                OwnerInterface.Hide();
                break;
            case ButtonSkipM:
                TOMAPlayer(OwnerPlayer).TOMASkip();
                break;
            case ListMonsters:
                break;
            case ButtonVote:
                SendVote();
                break;
            default:
                break;
        }
    }
}

simulated function SendVote()
{
    if (ListMonsters.SelectedIndex>=0)
        TOMAPlayer(OwnerPlayer).TOMAVote(CurFirstMonster+ListMonsters.SelectedIndex);
}

simulated function BeforeShow()
{
    ButtonVote.ShowWindow();
    ButtonSkipM.ShowWindow();
    ButtonCancel.ShowWindow();
    ListMonsters.ShowWindow();
    mm.ShowWindow();
    lm.ShowWindow();
}

simulated function BeforeHide()
{
    ButtonVote.HideWindow();
    ButtonCancel.HideWindow();
    ListMonsters.HideWindow();
    ButtonSkipM.HideWindow();
    mm.HideWindow();
    lm.HideWindow();
}

simulated function Setup(Canvas Canvas)
{
	local float	t,xw,w;

	xw=Width*0.5-3*Padding[Resolution];
	t=Left+Width-Padding[Resolution]-xw;
	w=Width*0.25-Padding[Resolution];

	ListMonsters.WinLeft=Left+Padding[Resolution];
	ListMonsters.WinTop=Top+Padding[Resolution];
	ListMonsters.NumVisItems=16;
	ListMonsters.SetWidth(Canvas,xw);

	ButtonVote.WinLeft=Left+((Width-xw)/2);
	ButtonVote.WinTop=Top + int(0.90*Height);
	ButtonVote.SetWidth(Canvas,xw);

	ButtonSkipM.WinLeft=Left+((Width-(xw/2))/2);
	ButtonSkipM.WinTop=Top + int(0.80*Height);
	ButtonSkipM.SetWidth(Canvas,xw/2);

	mm.WinLeft=ListMonsters.WinLeft+ListMonsters.WinWidth+5;
	mm.WinTop=ListMonsters.WinTop+ListMonsters.WinHeight-20;
	mm.SetWidth(Canvas,30);
	lm.WinLeft=ListMonsters.WinLeft + ListMonsters.WinWidth + 5;
	lm.WinTop=ListMonsters.WinTop+5;
	lm.SetWidth(Canvas,30);

	ButtonCancel.WinLeft=Left+Width-w;
	ButtonCancel.WinTop=Top+int(0.91*Height);
	ButtonCancel.SetWidth(Canvas,w-Padding[Resolution]);
}

defaultproperties
{
    TextListMonsters="Vote monster"
    TextTitle="TOMA Vote System"
    TextCancel="Cancel"
    TextVote="Vote"
    TextSkipM="Skip"
    ShowNav=true
}

