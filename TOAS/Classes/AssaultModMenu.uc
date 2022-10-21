class AssaultModMenu extends UMenuModMenuItem;

var string WindowClassName;

function Execute()
{
	local Class<UMenuStartGameWindow> StartTMGame;

	StartTMGame=Class<UMenuStartGameWindow>(DynamicLoadObject(WindowClassName,Class'Class'));
	MenuItem.Owner.Root.CreateWindow(StartTMGame,100,100,200,200,,True);
}

defaultproperties
{
	WindowClassName="TOAS.AssaultNewGame"
}
