class TOPAMSwatWindow extends s_swatwindow;

function Notify (UWindowWindow B, byte E)
{
	local int W;
	local int H;
	local float XWidth;
	local float YHeight;
	local float XMod;
	local float YMod;
	local float XPos;
	local float YPos;
	local float YOffset;
	local float BottomTop;
	local Color TextColor;
	local int i;
	local PlayerReplicationInfo PRI;

	W=Root.WinWidth/4;
	H=W;
	if ((W>256) || (H>256))
	{
		W=256;
		H=256;
	}
	XMod=4*W;
	YMod=3*H;
	PRI=GetPlayerOwner().PlayerReplicationInfo;
	switch (E)
	{
		case 2:
		switch (B)
		{
			case OptionButtons[0]:
			case OptionButtons[2]:
			case OptionButtons[3]:
			case OptionButtons[4]:
			if (!S_Player(GetPlayerOwner()).bNotPlaying)
			{
				GetPlayerOwner().PlaySound(Sound'SpeechWindowClick',SLOT_Interact);
				SetButtonTextures(SpeechButton(B).Type,False,True);
				HideChildren();
				CurrentType=SpeechButton(B).Type;
				SpeechChild=SpeechWindow(CreateWindow(Class'TO_SpeechChildWindow',100,100,100,100));
				SpeechChild.FadeIn();
			}
			break;
			case OptionButtons[5]:
			if (!S_Player(GetPlayerOwner()).bNotPlaying)
			{
				GetPlayerOwner().PlaySound(Sound'SpeechWindowClick',SLOT_Interact);
				SetButtonTextures(SpeechButton(B).Type,False,True);
				HideChildren();
				CurrentType=SpeechButton(B).Type;
				SpeechChild=SpeechWindow(CreateWindow(Class's_ChildHostageWindow',100,100,100,100));
				SpeechChild.FadeIn();
			}
			break;
			case OptionButtons[6]:
			if (!S_Player(GetPlayerOwner()).bNotPlaying)
			{
				GetPlayerOwner().PlaySound(Sound'SpeechWindowClick',SLOT_Interact);
				SetButtonTextures(SpeechButton(B).Type,False,True);
				HideChildren();
				CurrentType=SpeechButton(B).Type;
				SpeechChild=SpeechWindow(CreateWindow(Class'TO_PhysicalChildWindow',100,100,100,100));
				SpeechChild.FadeIn();
			}
			break;
			case OptionButtons[7]:
			GetPlayerOwner().PlaySound(Sound'SpeechWindowClick',SLOT_Interact);
			SetButtonTextures(SpeechButton(B).Type,False,True);
			HideChildren();
			CurrentType=SpeechButton(B).Type;
			SpeechChild=SpeechWindow(CreateWindow(Class'TOPAMChildChangeTeamWindow',100,100,100,100));
			SpeechChild.FadeIn();
			break;
			case OptionButtons[1]:
			case OptionButtons[8]:
			if (!S_Player(GetPlayerOwner()).bNotPlaying)
			{
				GetPlayerOwner().PlaySound(Sound'SpeechWindowClick',SLOT_Interact);
				SetButtonTextures(SpeechButton(B).Type,False,True);
				HideChildren();
				CurrentType=SpeechButton(B).Type;
				SpeechChild=SpeechWindow(CreateWindow(Class'TO_OrdersChildWindow',100,100,100,100));
				SpeechChild.FadeIn();
				TO_OrdersChildWindow(SpeechChild).TargetPRI=IdentifyTarget;
				TO_OrdersChildWindow(SpeechChild).MessageType=2;
			}
			break;
			default:
		}
		break;
		default:
	}
}

defaultproperties
{
}
