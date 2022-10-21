class TGAS_BuyMenu extends TO_GUITabBuyMenu;

#exec TEXTURE IMPORT NAME=TGASgasmask  FILE=Textures\TGASgasmask.bmp GROUP="Special" MIPS=off FLAGS=2
#exec TEXTURE IMPORT NAME=TGASthermal  FILE=Textures\TGASthermal.bmp GROUP="Special" MIPS=off FLAGS=2

var TO_GUIImageListbox Thermalbox;
var TO_GUIImageListbox Gasmaskbox;
var TGAS_Player TGAS_Player;

simulated function BeforeShow ()
{
	ResetTGASitems();
	Super.BeforeShow();
}

simulated function ResetTGASitems()
{
	Gasmaskbox.Clear();
	Gasmaskbox.AddItem(Texture'TGASgasmask',1,TGAS_Player.bHasgasmask,True);
	Thermalbox.Clear();
	Thermalbox.AddItem(Texture'TGASthermal',1,TGAS_Player.bHasthermal,True);
}

simulated function Created()
{
	Super.Created();

	Gasmaskbox=TO_GUIImageListbox(CreateWindow(Class'TO_GUIImageListbox',0.00,0.00,WinWidth,WinHeight));
	Gasmaskbox.OwnerTab=self;
	Thermalbox=TO_GUIImageListbox(CreateWindow(Class'TO_GUIImageListbox',0.00,0.00,WinWidth,WinHeight));
	Thermalbox.OwnerTab=self;

	TGAS_Player=TGAS_Player(OwnerPlayer);
}

simulated function Close (optional bool bByParent)
{
	Gasmaskbox.Close();
	Thermalbox.Close();
	Super.Close(bByParent);
}

simulated function Paint (Canvas Canvas, float X, float Y)
{
	local float lh;

	if (  !bDraw )
	{
		return;
	}
	Super.Paint(Canvas,X,Y);

	OwnerInterface.Design.SetScoreboardFont(Canvas);
	lh=OwnerInterface.Design.LineHeight;
	X=Left + Padding[Resolution];
	Y=Top + Padding[Resolution];

	if ( RemainingMoney < 0 )
		Canvas.DrawColor=OwnerInterface.Design.ColorHitlocation * 2 * OwnerHUD.TutIconBlink;
	else
		Canvas.DrawColor=OwnerInterface.Design.ColorTeam[OwnerPlayer.PlayerReplicationInfo.Team];

	if ( Gasmaskbox.MouseoverIndex != Gasmaskbox.LBIT_NONE )
  {
  TGASBuymenu_Drawinfo (canvas,"Protects you against teargas");
	Canvas.SetPos(X + 1.50 * SpaceTitle[Resolution],Y + 3.50 * lh);
	Canvas.DrawText("$ 800",True);
  }
	else if ( Thermalbox.MouseoverIndex != Gasmaskbox.LBIT_NONE )
  {
  TGASBuymenu_Drawinfo (canvas,"upgrades your scopes to thermal");
	Canvas.SetPos(X + 1.50 * SpaceTitle[Resolution],Y + 3.50 * lh);
	Canvas.DrawText("$ 800",True);
  }

}

simulated function BeforePaint (Canvas Canvas, float X, float Y)
{
	if ( !bInitialized )
	{
		Super.BeforePaint(Canvas,X,Y);

		Gasmaskbox.SetWidth(Canvas,(Width * 0.25 - Padding[Resolution]) * 0.40);
		Gasmaskbox.ClientHeight/=4;
		Gasmaskbox.WinHeight/=4;
		Gasmaskbox.WinLeft=Left + 7 * Padding[Resolution];
//		Gasmaskbox.WinLeft=Left + 0.3 * Width - 2.2 * Padding[Resolution];
		Gasmaskbox.WinTop=Top + 11 * Padding[Resolution] + Gasmaskbox.ClientHeight;

		Thermalbox.SetWidth(Canvas,(Width * 0.25 - Padding[Resolution]) * 0.40);
		Thermalbox.ClientHeight/=4;
		Thermalbox.WinHeight/=4;
		Thermalbox.WinLeft=Left + Padding[Resolution];
		Thermalbox.WinTop=Gasmaskbox.WinTop;
	}
	else Super.BeforePaint(Canvas,X,Y);

	if ( Gasmaskbox.IsSelectedByData(1) )
	{
		Capital+=800;
		if ( !TGAS_Player.bHasgasmask )
		{
			RemainingMoney-=800;
		}
	}
	else if ( !Gasmaskbox.IsSelectedByData(1) && TGAS_Player.bHasgasmask )
	{
		RemainingMoney+=800;
	}
	if ( Thermalbox.IsSelectedByData(1) )
	{
		Capital+=800;
		if ( !TGAS_Player.bHasThermal )
		{
			RemainingMoney-=800;
		}
	}
	else if ( !Thermalbox.IsSelectedByData(1) && TGAS_Player.bHasThermal )
	{
		RemainingMoney+=800;
	}


}

simulated function TGASBuymenu_Drawinfo (Canvas Canvas, string TextDesc)
{
	local float oldorigx;
	local float OldClipX;
	local int L;
	local int Chars;

	OwnerInterface.Design.SetScoreboardFont(Canvas);
	Canvas.DrawColor=OwnerInterface.Design.ColorWhite;

	oldorigx=Canvas.OrgX;
	OldClipX=Canvas.ClipX;
	Canvas.OrgX=MeshboxLeft + Padding[Resolution];
	Canvas.ClipX=MeshboxLeft + MeshboxWidth - Padding[Resolution];
	L=Len(TextDesc);
	Chars=Min(L,MeshFrame);
	Canvas.SetPos(0.00,MeshboxTop + Padding[Resolution]);
	if ( bDrawCursor && (Chars < L) )
	{
		Canvas.DrawTextClipped(OwnerInterface.Left(TextDesc,Chars) $ "_",False);
	}
	else
	{
		Canvas.DrawTextClipped(OwnerInterface.Left(TextDesc,Chars),False);
	}
	Canvas.ClipX=OldClipX;
	Canvas.OrgX=oldorigx;

}


simulated function Notify (UWindowDialogControl control, byte Event)
{
	if ( control == ButtonBuy && Event == 2 && RemainingMoney >= 0 )
	{
		TGAS_Player.BuyGasmask(Gasmaskbox.IsSelectedByData(1));
		TGAS_Player.BuyThermal(Thermalbox.IsSelectedByData(1));
	}

	if ( control == Gasmaskbox && Event == 8 )
	{
		Hint="Click to buy a Gasmask";
		AltHint="Protects you against teargas, bind 'gasmask' to a key";
	}
	else if ( control == Thermalbox && Event == 8)
	{
		Hint="Click to upgrade to Thermal Scopes";
		AltHint="All scopes upgraded to thermal scopes, use NVG key to activate";
	}
	else Super.Notify(control,Event);

	if ( control == ButtonRestore && Event == 2)
	{
		ResetTGASitems();
	}
}
