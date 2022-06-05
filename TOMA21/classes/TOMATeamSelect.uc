class TOMATeamSelect extends TO_TeamSelect config(TOMA);

var string TOMAVersionText;
var bool DirectToEnterPage;
var bool NoBack;
var string TextureLogo;

function Created ()
{
	Super.Created();
	if (DirectToEnterPage)
	{
		menuItem=MI_TEAM;
		menuTeam=1;
	}
}

function TOTeamsel_Paint_Team (Canvas C)
{
	Super.TOTeamsel_Paint_Team(C);
	if (NoBack) BtnMiscBack.HideWindow();
}

function TOTeamsel_Paint_Skin (Canvas C)
{
	Super.TOTeamsel_Paint_Skin(C);
	MeshActor.LoopAnim('Wave');
	if (NoBack) BtnMiscBack.HideWindow();
}

function TOTeamsel_Paint_Server (Canvas C)
{
	Super.TOTeamsel_Paint_Server(C);
	BtnServerTR.HideWindow();
	BtnServerSF.ShowWindow();
	BtnRndTeam.HideWindow();
}

function Paint(Canvas C, float X, float Y)
{
	local string temp;

	DrawStretchedTexture(C,0,YO - 208,256,256,Texture(DynamicLoadObject(TextureLogo,class'Texture')));
	temp=Class'TO_MenuBar'.Default.TOVersionText;
	Class'TO_MenuBar'.Default.TOVersionText=TOMAVersionText;
	Super.Paint(C,X,Y);
	Class'TO_MenuBar'.Default.TOVersionText=temp;
}

function Notify (UWindowDialogControl C, byte E)
{
	local bool bAnimateMenu;

	bAnimateMenu=True;
	Super(UWindowDialogClientWindow).Notify(C,E);
	if (E==2)
	{
		switch (C)
		{
			case BtnServerSF:
                menuTeam=1;
                if (GetPlayerOwner().Level.NetMode==NM_Standalone)
                {
                    DynamicLoadModelHandler();
                    menuSkin=1;
                    SetMeshActor();
                    MenuItem=MI_Skin;
                }
                else
                    MenuItem=MI_Team;
                break;
			case BtnRndTeam:
                menuTeam=254;
                menuSkin=255;
                TOTeamsel_Tool_ChangeTeam(menuTeam);
                Close();
                break;
			case BtnTeamJnSF:
                DynamicLoadModelHandler();
                menuSkin=1;
                SetMeshActor();
                MenuItem=MI_Skin;
                break;
			case BtnPrev:
                DynamicLoadModelHandler();
                menuSkin--;
                if (menuSkin==9) menuSkin=8;
                if (menuSkin==0) menuSkin=18;
                if (menuSkin==13) menuSkin=12;
                SetMeshActor();
                break;
			case BtnNext:
                DynamicLoadModelHandler();
                menuSkin++;
                if (menuSkin==9) menuSkin=10;
                if (menuSkin==13) menuSkin=15;
                if (menuSkin==19) menuSkin=1;
                SetMeshActor();
                break;
			case BtnEnter:
                TOTeamsel_Tool_ChangeTeam(menuTeam);
                DelMeshActor();
                Close();
                break;
			case BtnExitGame:
                if (MenuItem!=MI_Credits)
                {
                    MenuItem=MI_Credits;
                    Credits=GetPlayerOwner().Spawn(Class'TO_Credits',GetPlayerOwner());
                    if (Credits!=None)
                        Credits.Initialize(XO-40,YO-168,XO+256,YO+192,Font(DynamicLoadObject("LadderFonts.UTLadder10",Class'Font')),15);
                }
                else
                    bAnimateMenu=False;
                break;
			case BtnServerQt:
                Close();
                GetPlayerOwner().ConsoleCommand("exit");
                break;
			case BtnServerDis:
                Close();
                GetPlayerOwner().ConsoleCommand("disconnect");
                break;
			case BtnMiscBack:
                if (MenuItem==MI_Credits)
                {
                    Credits.Destroy();
                    Credits=None;
                }
                else
                    if (MenuItem==MI_Skin)
                        DelMeshActor();
                MenuItem=MI_Server;
                break;
			default:
		}
		if (bAnimateMenu)
		{
			TOTeamsel_Btn_HideAll();
			menuFadingFrame=menuFadingSpeed;
		}
	}
}

defaultproperties
{
	TOMAVersionText="TOMA v2.1 for Tactical Ops 3.4"
	NoBack=false
	DirectToEnterPage=true
	TextureLogo="TOMATex21.Logo.Red"
}

