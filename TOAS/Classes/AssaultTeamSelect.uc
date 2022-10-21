class AssaultTeamSelect extends TO_TeamSelect;

var localized string AssaultVersionText;
var() config string TextureLogo;

function TOTeamsel_Paint_Skin(Canvas C)
{
	local float OldFov;
	local Vector Position;
	local string textname;
	local string classname;
    local bool allowed;

    allowed=true;
	ModelHandler=Class<TO_ModelHandler>(DynamicLoadObject(ModelHandlerClass,Class'Class'));
	textname=ModelHandler.Default.ModelName[menuSkin];
	classname="";
	if (class'AssaultModelHandler'.Default.PClass[menuSkin]==PT_Support) classname="SUPPORT : ";
	if (class'AssaultModelHandler'.Default.PClass[menuSkin]==PT_Sniper) classname="SNIPER : ";
	if (class'AssaultModelHandler'.Default.PClass[menuSkin]==PT_Assault) classname="ASSAULT : ";
	if ((classname=="") || (!IsThereEnoughPlace(class'AssaultModelHandler'.Default.PClass[menuSkin])))
        allowed=false;
	TOTeamsel_Paint_Headline(C,"model selection ::" @ classname$textname);
	if (MeshActor!=None)
	{
		MeshActor.DrawScale=MeshActor.Default.DrawScale * Scale;
		OldFov=GetPlayerOwner().FovAngle;
		GetPlayerOwner().SetFOVAngle(30);
		Position=vect(0,0.8,-0.1) * Scale;
		DrawClippedActor(C,WinWidth/2,WinHeight/2,MeshActor,False,ViewRotator,Position);
		GetPlayerOwner().SetFOVAngle(OldFov);
	}
	BtnPrev.ShowWindow();
	BtnNext.ShowWindow();
	if (allowed) BtnEnter.ShowWindow();
	BtnMiscBack.ShowWindow();
	MeshActor.LoopAnim('Wave');
}

function bool IsThereEnoughPlace(int p)
{
	local int i,j;
	local AssaultGameReplicationInfo ap;

	Ap=AssaultGameReplicationInfo(GetPlayerOwner().GameReplicationInfo);
    for (i=0;i<32;i++)
        if ((ap.PRIArray[i]!=None) && (AssaultPRI(ap.PRIArray[i])!=None) && (ap.PRIArray[i].Team==menuTeam) && (AssaultPRI(ap.PRIArray[i]).PlayerModel==p))
            j++;
/*	i=ap.PlaceInClass(1,menuTeam);
	j=ap.PlaceInClass(2,menuTeam);
	k=ap.PlaceInClass(3,menuTeam);
	if (i==0) && (j==0) && (k==0))
	{
		Notify(BtnMiscBack,2);
		return false;
	}
	if (ap.PlaceInClass(p,menuTeam)==0)
		return false;
    else
        return true;*/

	if (P==1)
    {
        if (Ap.SupportLimit==0) return true; else if (Ap.SupportLimit-j>0) return true;
    }
	if (P==2)
    {
        if (Ap.SniperLimit==0) return true; else if (Ap.SniperLimit-j>0) return true;
    }
	if (P==3)
    {
        if (Ap.AssaultLimit==0) return true; else if (Ap.AssaultLimit-j>0) return true;
    }
    return false;
}

function Paint(Canvas C, float X, float Y)
{
	local string temp;

	if (TextureLogo!="") DrawStretchedTexture(C,0,YO-208,250,128,Texture(DynamicLoadObject(TextureLogo,class'Texture')));
	temp=Class'TO_MenuBar'.Default.TOVersionText;
	Class'TO_MenuBar'.Default.TOVersionText=AssaultVersionText;
	Super.Paint(C,X,Y);
	Class'TO_MenuBar'.Default.TOVersionText=temp;
}

function bool TOTeamsel_Tool_ChangeTeam (int NewTeam)
{
	local int PlayerSpread;
	local int OldTeam;
	local string Msg;
	local int TerrSize;
	local int SWATSize;

	if (GetPlayerOwner()==None)
	{
		Log("TO_TeamSelect::TOTeamsel_Tool_ChangeTeam - GetPlayerOwner() == None");
		Close();
		return False;
	}
	OldTeam=GetPlayerOwner().PlayerReplicationInfo.Team;
	if (TO_SysPlayer(GetPlayerOwner())!=None)
	{
		TO_SysPlayer(GetPlayerOwner()).s_ChangeTeam(menuSkin,NewTeam,False);
		return True;
	}
	else
		Log("TO_TeamSelect::TOTeamsel_Tool_ChangeTeam - TO_SysPlayer(GetPlayerOwner()) == None");
	Close();
	return False;
}

function Notify (UWindowDialogControl C, byte E)
{
    if (E==DE_Click)
    {
        if (C==BtnNext)
        {
            DynamicLoadModelHandler();
            menuSkin=ModelHandler.static.GetNextModel(MenuSkin,menuTeam);
            SetMeshActor();
            if (menuTeam==1) LastUsedSFSkin=menuSkin; else LastUsedTRSkin=menuSkin;
        }
        if (C==BtnPrev)
        {
            DynamicLoadModelHandler();
            menuSkin=ModelHandler.static.GetPrevModel(MenuSkin,menuTeam);
            SetMeshActor();
            if (menuTeam==1) LastUsedSFSkin=menuSkin; else LastUsedTRSkin=menuSkin;
        }
        if (C==BtnTeamJnSF)
        {
            DynamicLoadModelHandler();
            MenuSkin=5;
            SetMeshActor();
            menuItem=MI_SKIN;
		}
		if (C==BtnTeamJnTR)
		{
            DynamicLoadModelHandler();
            MenuSkin=2;
            SetMeshActor();
            menuItem=MI_SKIN;
		}
		if ((C!=BtnTeamJnTR) && (C!=BtnTeamJnSF) && (C!=BtnPrev) && (C!=BtnNext)) super.Notify(C,E);
		else
		{
    		TOTeamsel_Btn_HideAll();
            menuFadingFrame=menuFadingSpeed;
		}
    } else super.Notify(C,E);
}

defaultproperties
{
	AssaultVersionText="Assault for Tactical Ops 3.4"
	TextureLogo="TOASTex.Logo"
    ModelHandlerClass="TOAS.AssaultModelHandler"
}
