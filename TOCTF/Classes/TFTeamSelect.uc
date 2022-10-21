class TFTeamSelect extends TO_TeamSelect;

var string TextureLogo;

function TOTeamsel_Paint_Skin(Canvas C)
{
	Super.TOTeamsel_Paint_Skin(C);
	MeshActor.LoopAnim('Wave');
}

function Paint(Canvas C, float X, float Y)
{
	local string temp;

	if (TextureLogo!="") DrawStretchedTexture(C,0,YO - 208,256,256,Texture(DynamicLoadObject(TextureLogo,class'Texture')));
	temp=Class'TO_MenuBar'.Default.TOVersionText;
	Class'TO_MenuBar'.Default.TOVersionText="Tactical Flags for Tactical Ops 3.4";
	Super.Paint(C,X,Y);
	Class'TO_MenuBar'.Default.TOVersionText=temp;
}

defaultproperties
{
	TextureLogo="TOCTFTex.Logo"
}
