//----------------------------------------------------------------------------//
//	Project	:	TOSTWeapons (Client)										  //
//	File	:	TOSTWeaponsHUD.uc											  //
//	Version	:	0.1															  //
//	Version	:	0.9		No more steyr famas and oicw shown on other servers   //
//	Version	:	1.1		bug remover improved								  //
//	Version :	1.2		added teargas features								  //
//	Author	:	H-Lotti														  //
//----------------------------------------------------------------------------//
//	Comment	:	this is used to show a correct buymenu...					  //
//				it tries to remove the bug "cant buy when switching server"	  //
//----------------------------------------------------------------------------//

class TOSTWeaponsHUD extends TOSTHUDMutator;

#exec texture IMPORT NAME=gsm FILE=Textures\TearGas\GasMask.pcx
#exec texture IMPORT NAME=gas0 FILE=Textures\TearGas\gas0.bmp LODSET=2 MIPS=OFF FLAGS=2
#exec texture IMPORT NAME=gas1 FILE=Textures\TearGas\gas1.bmp LODSET=2 MIPS=OFF FLAGS=2
#exec texture IMPORT NAME=gas2 FILE=Textures\TearGas\gas2.bmp LODSET=2 MIPS=OFF FLAGS=2
#exec texture IMPORT NAME=gas3 FILE=Textures\TearGas\gas3.bmp LODSET=2 MIPS=OFF FLAGS=2
#exec texture IMPORT NAME=TileWhite FILE=Textures\TearGas\TileWhite.bmp LODSET=2 MIPS=OFF FLAGS=2

var bool bInitTabBuy;
var byte Cheaper[31], Sort[24];
var TOSTWeaponsClient client;
var string WeaponStr[25];

simulated function	Init()
{
	super.Init();
	if ( MyPlayer.isa('TO_Spectator') )
		self.destroy();
}

simulated event tick(float delta)
{
	local TOSTWeaponsClient tmp;

	if ( client == none )
		foreach AllActors(class'TOSTWeaponsClient',tmp)
		{
			client = tmp;
			class'TOST_WeaponBuyMenu'.default.OwnerPlayer = S_player(Owner);
			class'TOST_WeaponBuyMenu'.default.Client = client;
			class'TOST_WeaponBuyMenu'.default.numsortedweapons = 0;
			s_HUD(MyHud).UserInterface.TOUI_Tool_AddTab(138,Class'TOST_WeaponBuyMenu');
		}
	else if ( PlayerPawn(owner).health < 0 )
	{
		client.bGmaskActive = false;
		client.bHasGasMask = false;
	}
}

simulated event PostRender(canvas C)
{
    super.PostRender(C);

	if ( client == none )
		return;

    if ( client.bGmaskActive )
    	RenderMask(C);

	RenderGas(C);

	AmbientSounds();

	if (s_hud(MyHUD).userinterface.currenttab == 4 || s_hud(MyHUD).userinterface.currenttab == 138)
    {
        if (!bInitTabBuy)
        {
        	if ( !client.cwmode )
        	{
        		//fix head swinging if snipe sold
        		client.PawnOwner.EndSZoom();

				s_HUD(myHud).UserInterface.ToggleTab(138);
		    	ShowMyGunMode();
		    }
		    else
		    	ShowCWMode();
			bInitTabBuy = true;
	    }
	}
	else if (bInitTabBuy)
	{
		ShowNormalGunMode();
		bInitTabBuy = false;
	}
	else bInitTabBuy = false;
}

simulated function ShowMyGunMode()
{
    local int i;

	if ( client == none )
		return;

	if ( client.CWMode )
		return;

	TO_GUITabBuyMenu(s_HUD(MyHud).UserInterface.GetCurrentTab()).numsortedweapons=30;

	for (i=1; i<31; i++)
	{
		class'TOModels.TO_WeaponsHandler'.default.WeaponStr[i] = client.WeaponStr[i];
		class'TOModels.TO_WeaponsHandler'.default.WeaponName[i] = client.WeaponName[i];

    	if ( client.WeaponTeam[i] == 0 )
            class'TOModels.TO_WeaponsHandler'.default.WeaponTeam[i] = WT_NONE;
    	else if ( client.WeaponTeam[i] == 1 )
            class'TOModels.TO_WeaponsHandler'.default.WeaponTeam[i] = WT_BOTH;
    	else if ( client.WeaponTeam[i] == 2 )
            class'TOModels.TO_WeaponsHandler'.default.WeaponTeam[i] = WT_SpecialForces;
        else class'TOModels.TO_WeaponsHandler'.default.WeaponTeam[i] = WT_Terrorist;

    	TO_GUITabBuyMenu(s_HUD(MyHud).UserInterface.GetCurrentTab()).sortedweapons[i-1] = Cheaper[i];
    }

	TO_GUITabBuyMenu(s_HUD(MyHud).UserInterface.GetCurrentTab()).TOBuymenu_RefreshInventory();
}

simulated function ShowCWMode()
{
	local int i;

	for ( i = 0 ; i < 24 ; i++ )
	{
		TO_GUITabBuyMenu(s_HUD(MyHud).UserInterface.GetCurrentTab()).sortedweapons[i] = Sort[i];
	}

	TO_GUITabBuyMenu(s_HUD(MyHud).UserInterface.GetCurrentTab()).numsortedweapons = 24;
	TO_GUITabBuyMenu(s_HUD(MyHud).UserInterface.GetCurrentTab()).TOBuymenu_RefreshInventory();
}

simulated function ShowNormalGunMode()
{
	s_HUD(myHud).UserInterface.ToggleTab(138);
	TOST_WeaponBuyMenu(s_HUD(MyHud).UserInterface.GetCurrentTab()).numsortedweapons=0;
	s_HUD(myHud).UserInterface.ToggleTab(4);
	TO_GUITabBuyMenu(s_HUD(MyHud).UserInterface.GetCurrentTab()).numsortedweapons=0;
	s_HUD(MyHud).UserInterface.HideTab(4);

	client.setNormalHandlerWeaponTeam();
}

simulated function RenderGas(canvas Canvas)
{
	local float scale, col;

	canvas.DrawColor.R = 128;
	canvas.DrawColor.G = 128;
	canvas.DrawColor.B = 128;
	Scale = canvas.ClipX/256;
	canvas.SetPos(0.5 * canvas.ClipX - 128 * Scale, 0.5 * canvas.ClipY - 128 * Scale );
	canvas.Style = ERenderStyle.STY_Modulated;

	if (client.Teartime > 120)
		canvas.DrawIcon(Texture'gas3', Scale);
	else if (client.Teartime > 80)
		canvas.DrawIcon(Texture'gas2', Scale);
	else if (client.Teartime > 40)
		canvas.DrawIcon(Texture'gas1', Scale);
	else if (client.Teartime > 0)
		canvas.DrawIcon(Texture'gas0', Scale);

	canvas.Style = ERenderStyle.STY_Translucent ;

	if ( client.TearTime < 235 )
		col = client.TearTime+20;
	else
		col = 255;

	canvas.DrawColor.R = col;
	canvas.DrawColor.G = ( ( Frand() * col) / 100 );
	canvas.DrawColor.B = ( ( Frand() * col) / 100 );
	canvas.SetPos(0, 0);

	if (client.teartime > 0)
		canvas.DrawTile(Texture'TileWhite', canvas.ClipX, canvas.ClipY, 0, 0, 32.0, 32.0);
}

simulated function RenderMask( canvas Canvas )
{
	local float scale;

	scale = Canvas.ClipX/512;
	Canvas.Style = ERenderStyle.STY_modulated;

	TOHud_DrawGasvision(Canvas);
}

simulated function TOHud_DrawGasvision(Canvas Canvas)
{
	local Vector HitLocation;
	local Vector HitNormal;
	local Vector EndTrace;
	local Vector StartTrace;
	local Vector X;
	local Vector Y;
	local Vector Z;

	Canvas.SetPos(0.00,0.00);
	Canvas.DrawColor.R=6;
	Canvas.DrawColor.G=6;
	Canvas.DrawColor.B=6;
	Canvas.Style=3;
	Canvas.DrawIcon(Texture'Static_A00',FMax(Canvas.ClipX,Canvas.ClipY) / 256.00);
	Canvas.SetPos(0.00,0.00);
	Canvas.Style=4;
	Canvas.DrawTile(Texture'gsm',Canvas.ClipX,Canvas.ClipY,0.00,0.00,256.00,256.00);
}

simulated function AmbientSounds()
{
	if (client.bGmaskActive)
	{
		playerpawn(owner).AmbientSound=sound'breath';
		playerpawn(owner).soundvolume=180;
		playerpawn(owner).SoundDampening=0.5;
	    playerpawn(owner).soundradius=20;
		playerpawn(owner).Soundpitch = 60 + (18 - (playerpawn(owner).health * 0.18) );
	}
	else
	{
		playerpawn(owner).AmbientSound=none;
		playerpawn(owner).SoundDampening=1;
	}
}

defaultproperties
{
	bInitTabBuy=true

	bHidden=true

	Cheaper(1)=24
	Cheaper(2)=18
	Cheaper(3)=1
	Cheaper(4)=22
	Cheaper(5)=21
	Cheaper(6)=2
	Cheaper(7)=4
	Cheaper(8)=5
	Cheaper(9)=3
	Cheaper(10)=17
	Cheaper(11)=16
	Cheaper(12)=6
	Cheaper(13)=8
	Cheaper(14)=25
	Cheaper(15)=9
	Cheaper(16)=11
	Cheaper(17)=10
	Cheaper(18)=7
	Cheaper(19)=26
	Cheaper(20)=15
	Cheaper(21)=23
	Cheaper(22)=20
	Cheaper(23)=27
	Cheaper(24)=14
	Cheaper(25)=13
	Cheaper(26)=19
	Cheaper(27)=12
	Cheaper(28)=28
	Cheaper(29)=29
	Cheaper(30)=30

	Sort(0)=14
	Sort(1)=18
	Sort(2)=24
	Sort(3)=13
	Sort(4)=19
	Sort(5)=12
	Sort(6)=1
	Sort(7)=22
	Sort(8)=21
	Sort(9)=2
	Sort(10)=4
	Sort(11)=17
	Sort(12)=5
	Sort(13)=3
	Sort(14)=16
	Sort(15)=6
	Sort(16)=8
	Sort(17)=9
	Sort(18)=11
	Sort(19)=10
	Sort(20)=7
	Sort(21)=15
	Sort(22)=23
	Sort(23)=20
}

