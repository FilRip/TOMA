class VIPTOMA_BuyMenu extends TO_GUITabBuyMenu;

var TO_GUIBaseUpDown GSbox;
var TO_GUIImageListbox EBbox;
var int InitialGlowsticks;
var bool bMAMeshChanged;
var VIPTOMA_Player MA_Player;
var int NVSlot;

simulated function BeforeShow ()
{
	ResetMAitems();
	Super.BeforeShow();
}

simulated function ResetMAitems()
{
	InitialGlowSticks=MA_Player.Glowsticks;
	GSbox.Value=InitialGlowsticks;

	EBbox.Clear();
	EBbox.AddItem(Texture'MABatteryIcon',1,MA_Player.bHasEB,True);

	if ( !MA_Player.MA_ExtraBattery )
	{
		EBbox.HideWindow();
	}

	if ( !MA_Player.MA_GlowSticks )
	{
		GSBox.HideWindow();
	}

	NVSlot = -1;
}

simulated function Created()
{
	Super.Created();

	EBbox=TO_GUIImageListbox(CreateWindow(Class'TO_GUIImageListbox',0.00,0.00,WinWidth,WinHeight));
	EBbox.OwnerTab=self;

	GSbox=TO_GUIBaseUpDown(CreateWindow(Class'TO_GUIBaseUpDown',0.00,0.00,WinWidth,WinHeight));
	GSbox.Label="GlowSticks";
	GSbox.OwnerTab=self;
	GSbox.MaxValue=25;
	GSbox.MinValue=0;
	GSbox.Data=-1;

	MA_Player=VIPTOMA_Player(OwnerPlayer);
}

simulated function Close (optional bool bByParent)
{
	GSbox.Close();
	EBbox.Close();
	Super.Close(bByParent);
}

simulated function BeforePaint (Canvas Canvas, float X, float Y)
{
	if ( !bInitialized )
	{
		Super.BeforePaint(Canvas,X,Y);

		EBbox.SetWidth(Canvas,(Width * 0.25 - Padding[Resolution]) * 0.40);
		EBbox.ClientHeight/=4;
		EBbox.WinHeight/=4;
		EBbox.WinLeft=Left + 0.3 * Width - 2.2 * Padding[Resolution];
		EBbox.WinTop=Top + 1.5 * Padding[Resolution] + EBbox.ClientHeight;

		GSbox.WinLeft=EBbox.WinLeft;
		GSbox.WinTop=EBbox.WinTop + Padding[Resolution]/2 + EBbox.ClientHeight;
		GSbox.SetWidth(Canvas,(Width * 0.25 - Padding[Resolution]) * 0.40);
	}
	else Super.BeforePaint(Canvas,X,Y);

	if ( GSbox.bMouseover )
	{
		MeshClass=Class'MA_StickModel';
		MeshActor.bMeshEnviroMap=True;
		MeshScale=0.07;

		if ( OwnerPlayer.PlayerReplicationInfo.Team == 1 )
		{
			MeshActor.Texture=Texture'Botpack.Icons.I_BlueBox';
		}
		else MeshActor.Texture=Texture'AmmoCountJunk';

		TextInfoRange="Glow Time:";
		TextInfoUMeters="seconds";
		TextInfoClipSize="Base";
		TextInfoNumclips="Max Amount:";

		if ( !bMAMeshChanged )
		{
			MeshFrame=0;
		}

		bMAMeshChanged=True;
	}
	else if ( EBbox.MouseoverIndex != EBbox.LBIT_NONE )
	{
		MeshScale=0.3;
		MeshClass=Class'MA_BatteryModel';
		MeshActor.bMeshEnviroMap=False;

		MeshActor.MultiSkins[0]=Texture'FacePanel0';
		MeshActor.MultiSkins[1]=Texture'Botpack.Icons.I_BlueBox';
		MeshActor.MultiSkins[2]=Texture'BotPack.Ammocount.AmmoCountJunk';

		TextInfoRange="Battery Power:";
		TextInfoUMeters="watts";
		TextInfoClipSize="Extended";
		TextInfoNumclips="Standard Life:";

		if ( !bMAMeshChanged )
		{
			MeshFrame=0;
		}

		bMAMeshChanged=True;
	}
	else if ( bMAMeshChanged )
	{
		MeshRotator.Pitch = 0;
		MeshActor.bMeshEnviroMap=False;
		MeshActor.Texture=None;
		bMAMeshChanged=False;

		MeshActor.MultiSkins[0]=None;
		MeshActor.MultiSkins[1]=None;
		MeshActor.MultiSkins[2]=None;

		TextInfoRange=default.TextInfoRange;
		TextInfoUMeters=default.TextInfoUMeters;
		TextInfoClipSize=default.TextInfoClipSize;
		TextInfoNumclips=default.TextInfoNumclips;
		TextInfoRPM=default.TextInfoRPM;
	}

	if ( !MA_Player.MA_NightVision )
	{
		if ( NVSlot == -1 )
		{
	Retry:		if ( NVSlot < 32 )
			{
				NVSlot++;

				if ( BoxSpecialitems.ItemsImage[NVSlot] == Texture'buymenu_iconnightvision' )
				{
					Goto Found;
				}
				else
				{
					Goto Retry;
				}
			}
		}
	Found:

		BoxSpecialitems.ItemsImage[NVSlot]=None;
		BoxSpecialitems.ItemsData[NVSlot]=-1337;
		BoxSpecialitems.Selected[NVSlot]=0;
	}

	if ( bMAMeshChanged )
	{
		MeshID=30;
		ItemId=-1;
		MeshRotator.Pitch = 8192;
		MeshActor.Mesh=MeshClass.Default.Mesh;
		TextInfoRPM="Item Price:";
	}

	if ( EBbox.IsSelectedByData(1) )
	{
		Capital+=300;
		if ( !MA_Player.bHasEB )
		{
			RemainingMoney-=300;
		}
	}
	else if ( !EBbox.IsSelectedByData(1) && MA_Player.bHasEB )
	{
		RemainingMoney+=300;
	}

	Capital+=GSbox.Value * 25;
	RemainingMoney-=(GSbox.Value - InitialGlowsticks) * 25;
}

simulated function Paint (Canvas Canvas, float X, float Y)
{
	Canvas.Style=3;
	Canvas.DrawColor.R=255;
	Canvas.DrawColor.G=255;
	Canvas.DrawColor.B=255;

	Super.Paint(Canvas,X,Y);

	Canvas.SetPos(EBbox.WinLeft,Top);

	Canvas.DrawTile(Texture'MAbuymenu_Icon',EBbox.WinWidth,EBbox.WinWidth,0,0,64,64);
}

simulated function Notify (UWindowDialogControl control, byte Event)
{
	if ( control == ButtonBuy && Event == 2 && RemainingMoney >= 0 )
	{
		MA_Player.BuyGlowsticks(GSbox.Value);
		MA_Player.BuyExtraBattery(EBbox.IsSelectedByData(1));
	}

	if ( control == EBbox && Event == 8 )
	{
		Hint="Click tu buy Extra Battery";
		AltHint="It will give you Extra Battery Life";
	}
	else if ( control == GSbox && Event == 8)
	{
		Hint="Click to buy GlowSticks";
		AltHint="Bind 'glowstick' to a key to throw";
	}
	else Super.Notify(control,Event);

	if ( control == ButtonRestore && Event == 2)
	{
		ResetMAitems();
	}
}

defaultproperties
{
    NVSlot=-1
}

