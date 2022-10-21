class TOPAMTeamSelect extends TO_TeamSelect config(TOMA);

// TODO : Faire un menu spécial kan on click sur joindre terro (pour browser les models de monstres)

var() string TextureLogo;
var() string TOPAMVersionText;

function Paint(Canvas C, float X, float Y)
{
	local string temp;

	if (TextureLogo!="") DrawStretchedTexture(C,0,YO-208,256,256,Texture(DynamicLoadObject(TextureLogo,class'Texture')));
	temp=Class'TO_MenuBar'.Default.TOVersionText;
	Class'TO_MenuBar'.Default.TOVersionText=TOPAMVersionText;
	Super.Paint(C,X,Y);
	Class'TO_MenuBar'.Default.TOVersionText=temp;
}



defaultproperties
{
	TOPAMVersionText="TOMA Opposite forces v1 for Tactical Ops 3.4"
	TextureLogo=""
	ModelHandlerClass="TOPAM.TOPAMModelHandler"
}
