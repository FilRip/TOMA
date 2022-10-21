class TFModMenu extends UMenuModMenuItem;

var string WindowClassName;

function Execute()
{
	local Class<UMenuStartGameWindow> StartTFGame;

	StartTFGame=Class<UMenuStartGameWindow>(DynamicLoadObject(WindowClassName,Class'Class'));
	MenuItem.Owner.Root.CreateWindow(StartTFGame,100,100,200,200,,True);
}

defaultproperties
{
	WindowClassName="TOCTF.TFNewGame"
}
