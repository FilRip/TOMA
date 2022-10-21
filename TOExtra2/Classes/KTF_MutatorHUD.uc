class KTF_MutatorHUD extends mutator;

var KeepTheFlag Data;
var s_hud originalhud;
var KTF_Flag flag;

function PreBeginPlay()
{
    local KeepTheFlag localdata;
    local KTF_Flag localflag;

    foreach AllActors(class'KeepTheFlag',localdata)
        Data=localdata;
    foreach AllActors(class'KTF_Flag',localflag)
        flag=localflag;
}

simulated function postrender(canvas c)
{
// Hack to Fix the Buy weapons problems after pickup weapons (but this is not autorized if set by admin "bCarrierCantFire")
    if ((Data.bCarrierCantFire) && (originalhud.PlayerOwner.PlayerReplicationInfo.HasFlag!=None)) s_Player(originalhud.PlayerOwner).bInBuyZone=false;

	if ((originalhud.bHideHUD) || (originalhud.bHideStatus) || (Data==None)) return;
	C.DrawColor=originalhud.Design.ColorSuperwhite;
	C.Style=3;
	if (originalhud.bDrawBackground)
	{
    	if ((Flag!=None) && (Flag.WhatTeam==1)) C.DrawColor=originalhud.Design.ColorBlack; else C.DrawColor=originalhud.Design.ColorSuperwhite;
		C.SetPos(C.ClipX-79,C.ClipY-169);
		C.DrawTile(Texture'hud_elements',79,18,0,52,79,18);
    	if ((Flag!=None) && (Flag.WhatTeam==0)) C.DrawColor=originalhud.Design.ColorBlack; else C.DrawColor=originalhud.Design.ColorSuperwhite;
		C.SetPos(C.ClipX-79,C.ClipY-145);
		C.DrawTile(Texture'hud_elements',79,18,0,52,79,18);
		C.Style=2;
    	if ((Flag!=None) && (Flag.WhatTeam==1)) C.DrawColor=originalhud.Design.ColorBlack; else C.DrawColor=originalhud.Design.ColorSuperwhite;
		C.SetPos(C.ClipX-79,C.ClipY-169);
		C.DrawTile(Texture'hud_elements',79,18,0,70,79,18);
    	if ((Flag!=None) && (Flag.WhatTeam==0)) C.DrawColor=originalhud.Design.ColorBlack; else C.DrawColor=originalhud.Design.ColorSuperwhite;
		C.SetPos(C.ClipX-79,C.ClipY-145);
		C.DrawTile(Texture'hud_elements',79,18,0,70,79,18);
	}
	originalhud.TOHud_SetTeamColor(C,0);
	C.SetPos(C.ClipX-59,C.ClipY-169);
//	if ((Flag!=None) && (Flag.WhatTeam==0)) originalhud.TOHud_SetTeamColor(C,2);
	originalhud.TOHud_Tool_DrawNum(C,Data.TerroScore,FS_SMALL,3);

	originalhud.TOHud_SetTeamColor(C,1);
//	if ((Flag!=None) && (Flag.WhatTeam==1)) originalhud.TOHud_SetTeamColor(C,2);
	C.SetPos(C.ClipX-59,C.ClipY-145);
	originalhud.TOHud_Tool_DrawNum(C,Data.SFScore,FS_SMALL,3);
}

defaultproperties
{
}

