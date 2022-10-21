class TOASHUD extends s_HUD;

simulated function PostRender(Canvas Canvas)
{
	if ((PlayerOwner!=None) && (PlayerOwner.Player!=None) && (PlayerOwner.Player.Console!=None))
	{
		if (Root==None)
			Root=WindowConsole(PlayerOwner.Player.Console).Root;
		if (UserInterface==None)
		{
			Log("AssaultHUD::AssaultTOHud_Tool_BeforePaint - spawning UserInterface");
			UserInterface=PlayerOwner.Spawn(Class'AssaultTab',PlayerOwner);
			UserInterface.OwnerInit(self,Design);
		}
	}
	Super.PostRender(Canvas);
}

simulated function TOHud_DrawMoney(Canvas Canvas)
{
	local TO_GUIBaseTab				tab;
	local int						money, offset;

	if ( (bHideHud) || (FrameTime > 0) )
	{
		return;
	}

	// background
	if ( bDrawBackground )
	{
		offset = 0;

		Canvas.DrawColor = Design.ColorSuperwhite;
		Canvas.Style = ERenderStyle.STY_Translucent;
		Canvas.SetPos(offset, 31);
		Canvas.DrawTile(Texture'hud_elements2', 151, 18, 0, 180, 151.0, 18.0);

		Canvas.Style = ERenderStyle.STY_Masked;
		Canvas.SetPos(offset, 31);
		Canvas.DrawTile(Texture'hud_elements2', 151, 18, 0, 162, 151.0, 18.0);
	}

	// amount
	Canvas.SetPos(16, 39);

	money = 20000;
	Canvas.DrawColor = Design.ColorSuperwhite;
	TOHud_Tool_DrawDigit(Canvas, 12, FS_SMALL, 1);
	TOHud_Tool_DrawNumR(Canvas, money, FS_SMALL, 5);
}

defaultproperties
{
}
